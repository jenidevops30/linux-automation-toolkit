#!/usr/bin/env bash
set -u

CONFIG_DIR="${CONFIG_DIR:-/opt/linux-automation-toolkit/config}"
[ -f "$CONFIG_DIR/config.conf" ] && . "$CONFIG_DIR/config.conf"

DISK_WARNING="${DISK_WARNING:-80}"
DISK_CRITICAL="${DISK_CRITICAL:-90}"
MEMORY_WARNING="${MEMORY_WARNING:-80}"
LOAD_WARNING="${LOAD_WARNING:-2.0}"

echo "=== SYSTEM ==="
echo "Hostname : $(hostname)"
echo "OS       : $(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-unknown}")"
echo "Kernel   : $(uname -r)"
echo "Uptime   : $(uptime -p 2>/dev/null || uptime)"
echo "Load     : $(awk '{print $1" "$2" "$3}' /proc/loadavg)"

if command -v free >/dev/null 2>&1; then
  free -h
fi

echo
echo "=== DISK ==="
df -hT --exclude-type=tmpfs --exclude-type=devtmpfs 2>/dev/null || df -h

echo
echo "=== FAILED SERVICES ==="
if command -v systemctl >/dev/null 2>&1; then
  failed="$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)"
  if [ -n "$failed" ]; then
    printf '%s\n' "$failed"
  else
    echo "None"
  fi
else
  echo "systemd not available"
fi

echo
echo "=== LISTENING PORTS ==="
if command -v ss >/dev/null 2>&1; then
  ss -lntup 2>/dev/null || ss -lnt 2>/dev/null
else
  echo "ss command not available"
fi

echo
echo "=== RECENT ERRORS ==="
if command -v journalctl >/dev/null 2>&1; then
  journalctl --since "24 hours ago" -p err --no-pager 2>/dev/null | tail -20 || true
else
  echo "journalctl not available"
fi
