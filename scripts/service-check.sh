#!/usr/bin/env bash
set -u

CONFIG_DIR="${CONFIG_DIR:-/opt/linux-automation-toolkit/config}"
[ -f "$CONFIG_DIR/config.conf" ] && . "$CONFIG_DIR/config.conf"

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemd is not available."
  exit 0
fi

status=0

echo "=== FAILED SYSTEMD SERVICES ==="
failed="$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)"
if [ -n "$failed" ]; then
  printf '%s\n' "$failed"
  status=2
else
  echo "None"
fi

if [ -n "${SERVICES_TO_CHECK:-}" ]; then
  echo
  echo "=== CONFIGURED SERVICES ==="
  for service in $SERVICES_TO_CHECK; do
    if systemctl is-active --quiet "$service"; then
      echo "OK       $service"
    else
      echo "FAILED   $service"
      status=2
    fi
  done
fi

exit "$status"
