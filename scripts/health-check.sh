#!/usr/bin/env bash
set -u

CONFIG_DIR="${CONFIG_DIR:-/opt/linux-automation-toolkit/config}"
[ -f "$CONFIG_DIR/config.conf" ] && . "$CONFIG_DIR/config.conf"

CPU_WARNING="${CPU_WARNING:-80}"
CPU_CRITICAL="${CPU_CRITICAL:-90}"
MEMORY_WARNING="${MEMORY_WARNING:-80}"

echo "=== SYSTEM ==="
echo "Hostname : $(hostname)"
echo "OS       : $(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
echo "Kernel   : $(uname -r)"
echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"

echo
echo "=== CPU HEALTH ==="
if [ -r /proc/stat ]; then
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle1=$((idle + iowait))
  sleep 1
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
  idle2=$((idle + iowait))
  total_delta=$((total2 - total1))
  idle_delta=$((idle2 - idle1))
  if [ "$total_delta" -gt 0 ]; then
    cpu_usage=$(( (100 * (total_delta - idle_delta)) / total_delta ))
  else
    cpu_usage=0
  fi
  cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo "unknown")
  load1=$(awk '{print $1}' /proc/loadavg)
  if [ "$cpu_usage" -ge "$CPU_CRITICAL" ]; then
    cpu_status="CRITICAL"
  elif [ "$cpu_usage" -ge "$CPU_WARNING" ]; then
    cpu_status="WARNING"
  else
    cpu_status="OK"
  fi
  echo "Usage    : ${cpu_usage}%"
  echo "Cores    : $cores"
  echo "Load 1m  : $load1"
  echo "Status   : $cpu_status"
else
  echo "CPU metrics unavailable"
fi

echo
echo "=== MEMORY ==="
if command -v free >/dev/null 2>&1; then
  free -h
  memory_usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')
  if [ "$memory_usage" -ge "$MEMORY_WARNING" ]; then
    echo "Status   : WARNING (${memory_usage}% used)"
  else
    echo "Status   : OK (${memory_usage}% used)"
  fi
fi

echo
echo "=== LOAD ==="
echo "1m  5m  15m : $(awk '{print $1" "$2" "$3}' /proc/loadavg)"

echo
echo "=== DISK ==="
df -hT --exclude-type=tmpfs --exclude-type=devtmpfs 2>/dev/null || df -h

echo
echo "=== FAILED SERVICES ==="
if command -v systemctl >/dev/null 2>&1; then
  failed="$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)"
  if [ -n "$failed" ]; then printf "%s\n" "$failed"; else echo "None"; fi
else
  echo "systemd not available"
fi

echo
echo "=== LISTENING PORTS ==="
if command -v ss >/dev/null 2>&1; then ss -lntup 2>/dev/null || ss -lnt 2>/dev/null; else echo "ss command not available"; fi

echo
echo "=== RECENT ERRORS ==="
if command -v journalctl >/dev/null 2>&1; then journalctl --since "24 hours ago" -p err --no-pager 2>/dev/null | tail -20 || true; else echo "journalctl not available"; fi
