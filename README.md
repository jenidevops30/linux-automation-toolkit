# Linux Automation Toolkit

A provider-neutral toolkit for automating routine health checks and daily status reports on Linux servers.

## Supported environments

Designed for common Linux distributions, including Ubuntu, Debian, RHEL, Rocky Linux, AlmaLinux, CentOS, Fedora, Amazon Linux, and other systemd-based systems.

It does not depend on DigitalOcean, AWS, Azure, GCP, containers, or Kubernetes.

## Repository structure

```
linux-automation-toolkit/
├── scripts/
│   ├── health-check.sh
│   ├── disk-check.sh
│   ├── service-check.sh
│   └── daily-report.sh
├── config/
│   └── config.conf
├── logs/
├── setup.sh
└── README.md
```

## Quick start

Clone the repository and run:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

The setup installs the toolkit under `/opt/linux-automation-toolkit`, creates a systemd service and timer, and schedules a daily report.

Run a report manually:

```sudo /opt/linux-automation-toolkit/scripts/daily-report.sh```

View timer status:

```systemctl status linux-automation-toolkit.timer```

View the latest report:

```tail -100 /var/log/linux-automation-toolkit/daily-report.log```

## Configuration

Edit:

```
/opt/linux-automation-toolkit/config/config.conf
```

Default thresholds are intentionally conservative:

- Disk warning: 80%
- Disk critical: 90%
- Memory warning: 80%
- Load warning: 2.0

The toolkit uses local Linux commands and systemd; no cloud-provider credentials are required.

## Remote delivery

The daily report is generated locally. A webhook/Slack/email delivery layer can be added later without coupling the core health checks to a cloud provider.

## License

MIT
