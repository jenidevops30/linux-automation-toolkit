#!/usr/bin/env bash
set -u

CONFIG_DIR="${CONFIG_DIR:-/opt/linux-automation-toolkit/config}"
[ -f "$CONFIG_DIR/config.conf" ] && . "$CONFIG_DIR/config.conf"
DISK_WARNING="${DISK_WARNING:-80}"
DISK_CRITICAL="${DISK_CRITICAL:-90}"

status=0

while read -r filesystem size used avail percent mount; do
  usage="${percent%%%}"
  if [ "$usage" -ge "$DISK_CRITICAL" ]; then
    level="CRITICAL"; status=2
  elif [ "$usage" -ge "$DISK_WARNING" ]; then
    level="WARNING"; [ "$status" -lt 1 ] && status=1
  else
    level="OK"
  fi
  printf '%-10s %-6s %-6s %-8s %-8s %s\n' "$level" "$percent" "$size" "$used" "$avail" "$mount"
done < <(df -P --exclude-type=tmpfs --exclude-type=devtmpfs 2>/dev/null | awk 'NR>1 {print $1,$2,$3,$4,$5,$6}')

exit "$status"
