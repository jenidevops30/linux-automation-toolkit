# Linux Automation Toolkit

A provider-neutral toolkit for automating routine health checks and daily status reports on Linux servers.

## What it checks

The toolkit is designed to provide a practical daily Linux server health report covering:

- CPU utilization (%)
- CPU core count
- CPU load average (1, 5, and 15 minutes)
- CPU warning/critical status
- Memory usage
- Disk/filesystem usage
- Uptime
- Failed systemd services
- Configured application service status
- Listening network ports
- Recent system errors from the last 24 hours

## Supported environments

Designed for common Linux distributions, including:

- Ubuntu
- Debian
- RHEL
- Rocky Linux
- AlmaLinux
- CentOS
- Fedora
- Amazon Linux
- Other systemd-based Linux distributions

The toolkit is infrastructure-provider agnostic. It does not depend on DigitalOcean, AWS, Azure, GCP, containers, or Kubernetes.

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
│   └── .gitkeep
├── setup.sh
└── README.md
```

## Quick start

Clone the repository:

```bash
git clone https://github.com/jenidevops30/linux-automation-toolkit.git
cd linux-automation-toolkit
```

Make the setup script executable and install the toolkit:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

The setup installs the toolkit under:

```
/opt/linux-automation-toolkit
```

and configures a systemd timer for a daily health report.

## Run a health check manually

```bash
sudo /opt/linux-automation-toolkit/scripts/health-check.sh
```

## Run the daily report manually

```bash
sudo /opt/linux-automation-toolkit/scripts/daily-report.sh
```

## CPU health monitoring

CPU utilization is measured from Linux's `/proc/stat` counters over a one-second interval.

Default thresholds:

```text
CPU warning  = 80%
CPU critical = 90%
```

Example output:

```text
=== CPU HEALTH ===
Usage    : 23%
Cores    : 4
Load 1m  : 0.62
Status   : OK
```

Change the thresholds in:

```
/opt/linux-automation-toolkit/config/config.conf
```

For example:

```bash
CPU_WARNING=75
CPU_CRITICAL=90
```

## Disk and memory thresholds

Default thresholds:

```text
Disk warning   = 80%
Disk critical  = 90%
Memory warning = 80%
```

These can also be changed in `config/config.conf`.

## Configure services

You can optionally define services that should always be running:

```bash
SERVICES_TO_CHECK="nginx ssh mysql"
```

The service check will report any configured service that is not active, in addition to detecting failed systemd units.

## Daily automation

The setup script creates:

```text
linux-automation-toolkit.service
linux-automation-toolkit.timer
```

The timer runs the report daily at approximately 09:00 local server time, with a small randomized delay.

Check the timer:

```bash
systemctl status linux-automation-toolkit.timer
systemctl list-timers linux-automation-toolkit.timer
```

Run the service immediately:

```bash
sudo systemctl start linux-automation-toolkit.service
```

## Logs

Reports are stored on the server at:

```
/var/log/linux-automation-toolkit/daily-report.log
```

View the latest report:

```bash
sudo tail -100 /var/log/linux-automation-toolkit/daily-report.log
```

## Remote notifications

The core toolkit generates reports locally and does not require cloud-provider credentials.

A notification layer such as Slack, email, or a generic webhook can be added separately so reports can be delivered remotely.

## Security

The toolkit only performs local read-oriented health checks by default. Review scripts and configuration before deploying them to production systems.

## License

MIT
