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
├── ansible/
│   ├── inventory/production.ini.example
│   ├── group_vars/production.yml
│   ├── playbooks/server.yml
│   ├── roles/server/
│   │   ├── defaults/main.yml
│   │   ├── handlers/main.yml
│   │   ├── tasks/main.yml
│   │   └── templates/
│   ├── requirements.yml
│   └── ansible.cfg
└── README.md
```

## Remote Linux server configuration with Ansible

The repository now also contains an Ansible configuration layer under `ansible/`. It complements the existing local health-report scripts and configures remote Linux hosts over SSH.

It automates:

- creation of a `devops` user and SSH public key
- common package installation
- SSH hardening
- Nginx installation and configuration
- UFW on Debian/Ubuntu or firewalld on Red Hat-family systems
- application directories
- a managed application configuration file
- starting and enabling Nginx

Install the required collections:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Create the inventory from the example and edit the server address:

```bash
cp inventory/production.ini.example inventory/production.ini
```

Set your real public key in `group_vars/production.yml`. Do not commit private keys or secrets.

Validate and preview before applying:

```bash
ansible-playbook --syntax-check -i inventory/production.ini playbooks/server.yml
ansible-playbook --check -i inventory/production.ini playbooks/server.yml
```

Apply the configuration:

```bash
ansible-playbook -i inventory/production.ini playbooks/server.yml
```

**SSH safety:** the playbook creates the automation user and installs its public key before disabling password authentication. Test a second SSH session with the `devops` user before making any additional SSH lockdown changes.

The Ansible role uses declarative, idempotent tasks so repeated runs converge the host toward the desired state. Ansible's official documentation describes this control-node/inventory/managed-node model and recommends playbooks for repeatable automation. citeturn0search6turn0search8

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
