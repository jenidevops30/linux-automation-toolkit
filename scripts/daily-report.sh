#!/usr/bin/env bash
set -u

BASE_DIR="/opt/linux-automation-toolkit"
CONFIG_FILE="$BASE_DIR/config/config.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

LOG_DIR="${LOG_DIR:-/var/log/linux-automation-toolkit}"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/daily-report.log"

exec >> "$REPORT" 2>&1

echo
echo "============================================================"
echo "LINUX DAILY SERVER HEALTH REPORT"
echo "============================================================"
echo "Date     : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Hostname : $(hostname)"
echo

"$BASE_DIR/scripts/health-check.sh"

echo
echo "=== DISK HEALTH ==="
"$BASE_DIR/scripts/disk-check.sh" || true

echo
echo "=== SERVICE HEALTH ==="
"$BASE_DIR/scripts/service-check.sh" || true

echo
echo "=== REPORT COMPLETE ==="
echo "============================================================"
