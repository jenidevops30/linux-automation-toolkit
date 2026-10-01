#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/opt/linux-automation-toolkit"
SCRIPT_DIR="$REPO_DIR/scripts"
CONFIG_DIR="$REPO_DIR/config"
LOG_DIR="/var/log/linux-automation-toolkit"
SYSTEMD_DIR="/etc/systemd/system"

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root: sudo ./setup.sh"
  exit 1
fi

mkdir -p "$SCRIPT_DIR" "$CONFIG_DIR" "$LOG_DIR"

SCRIPT_SOURCE="$(cd "$(dirname "$0")" && pwd)"

cp -f "$SCRIPT_SOURCE"/scripts/*.sh "$SCRIPT_DIR/"
cp -f "$SCRIPT_SOURCE"/config/config.conf "$CONFIG_DIR/"

chmod 0755 "$SCRIPT_DIR"/*.sh
chmod 0644 "$CONFIG_DIR/config.conf"

cat > "$SYSTEMD_DIR/linux-automation-toolkit.service" <<'EOF'
[Unit]
Description=Linux Automation Toolkit Daily Health Report
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/linux-automation-toolkit/scripts/daily-report.sh
EOF

cat > "$SYSTEMD_DIR/linux-automation-toolkit.timer" <<'EOF'
[Unit]
Description=Run Linux Automation Toolkit Daily Report

[Timer]
OnCalendar=*-*-* 09:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now linux-automation-toolkit.timer

echo
echo "Linux Automation Toolkit installed."
echo "Location : $REPO_DIR"
echo "Logs     : $LOG_DIR/daily-report.log"
echo "Timer    : systemctl status linux-automation-toolkit.timer"
echo "Run now  : systemctl start linux-automation-toolkit.service"
