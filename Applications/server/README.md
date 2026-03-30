# DefendOS Forensics — Telemetry Server

A centralized Linux telemetry collection and risk analysis platform built for forensic investigations, incident response, and enterprise security monitoring.

Lightweight agents run on Linux endpoints and periodically POST structured metadata to this Django server. The server analyzes each snapshot for risk indicators, stores the history, and surfaces everything through a web dashboard.

---

## What It Does

### Agent (Client Side)
Runs on monitored Linux machines and collects:

| Category | Data Collected |
|---|---|
| System | Hostname, OS, kernel version, architecture, uptime, boot time |
| Hardware | CPU model/cores/usage, RAM total/available/usage %, disks |
| Processes | All running processes: PID, name, owner, status |
| Network | Interface names, IP addresses, MAC addresses, open ports |
| Users | Account names, UID/GID, shell (no passwords) |
| Security | Firewall status, AppArmor/SELinux state |

Two agent implementations are provided:
- **`client/linux/client.sh`** — portable Bash script, requires only `curl`
- **`client/legacy_python/`** — Python agent using `psutil` and `pydantic`

### Server Side
- Receives and stores telemetry JSON from agents
- Runs heuristic **risk scoring** (0–100) on every snapshot
- Exposes a **web dashboard** with per-host latest state and history
- Provides a **JSON API** for programmatic access
- Includes a **Django admin** panel for full data management

---

## Risk Scoring

Each telemetry snapshot is assigned a score from 0–100 based on:

| Check | Score Added |
|---|---|
| High-risk tool running (nmap, sqlmap, metasploit, hydra, etc.) | +20 per tool |
| Offensive/privacy OS detected (Kali, Parrot, Tails, Whonix, etc.) | +30 |
| Suspicious open port (4444, 9050, 31337, etc.) | +15 per port (max +40) |
| Non-root account with UID 0 | +20 |
| Suspicious usernames (toor, hacker, pwn, etc.) | +10–15 |
| Critical CPU usage (>90%) | +15 |
| High CPU usage (>80%) | +10 |
| Critical memory usage (>95%) | +10 |
| Disk full (>95%) | +10 per disk |
| Excessive network interfaces (>8) | +10 |

Scores are capped at 100. Systems with a score above 50 are flagged as **High Risk** on the dashboard.

---

## Tech Stack

- **Backend:** Django 5.x, Python 3.12+
- **Database:** SQLite (default) or PostgreSQL via `DATABASE_URL`
- **Frontend:** Bootstrap 5.3 (dark theme), HTMX, Django templates
- **Agent:** Bash shell script or Python with psutil/pydantic

---

## Quick Start

### 1. Install dependencies

```bash
cd Applications/server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env — at minimum change SECRET_KEY and DJANGO_SUPERUSER_PASSWORD
```

### 3. Initialize the database

```bash
python manage.py migrate
python manage.py setup_admin   # creates superuser from .env values
```

### 4. Run the development server

```bash
python manage.py runserver
```

Open [http://localhost:8000/dashboard/](http://localhost:8000/dashboard/)

---

## API Reference

### `POST /api/v1/telemetry/`
Submit a telemetry snapshot from an agent.

**Headers** (if `TELEMETRY_API_KEY` is set):
```
Authorization: Bearer <key>
Content-Type: application/json
```

**Body** (JSON):
```json
{
  "system": { "hostname": "server-01", "os_name": "Ubuntu", "os_version": "22.04", "kernel_version": "5.15.0", "cpu_arch": "x86_64", "uptime_seconds": 86400 },
  "cpu": { "model": "Intel Xeon E5", "cores": 4, "usage_percent": 45.2 },
  "memory": { "total_bytes": 8589934592, "available_bytes": 4294967296, "used_percent": 50.0 },
  "disks": [{ "device": "/dev/sda1", "mountpoint": "/", "total_bytes": 107374182400, "used_bytes": 53687091200, "percent": 50.0 }],
  "processes": [{ "pid": 1, "name": "systemd", "username": "root", "status": "S" }],
  "network_interfaces": [{ "name": "eth0", "ip_address": "192.168.1.10", "mac_address": "aa:bb:cc:dd:ee:ff", "is_up": true }],
  "users": [{ "name": "alice", "uid": 1000, "gid": 1000, "shell": "/bin/bash" }],
  "security": { "open_ports": [22, 80, 443], "firewall_active": true }
}
```

**Response:**
```json
{ "status": "success", "risk_score": 0 }
```

---

### `GET /api/v1/systems/`
Returns the latest snapshot for every known host.

```json
{
  "systems": [
    {
      "hostname": "server-01",
      "ip_address": "192.168.1.10",
      "timestamp": "2026-03-19T14:30:00Z",
      "risk_score": 0,
      "findings": []
    }
  ]
}
```

---

## Management Commands

```bash
# Create/verify superuser from environment variables
python manage.py setup_admin

# Re-run risk analysis on all unanalyzed logs
python manage.py analyze_risks

# Delete logs older than N days (default: 30)
python manage.py cleanup_old --days 60
```

---

## Configuration Reference

All settings are loaded from environment variables (or a `.env` file in the server directory):

| Variable | Default | Description |
|---|---|---|
| `SECRET_KEY` | insecure dev key | Django secret key — must be changed in production |
| `DEBUG` | `True` | Set to `False` in production |
| `ALLOWED_HOSTS` | `*` | Comma-separated list of allowed hostnames |
| `TELEMETRY_API_KEY` | *(empty)* | Bearer token required on ingest endpoint; empty = no auth |
| `DATABASE_URL` | *(SQLite)* | PostgreSQL connection string |
| `LOG_LEVEL` | `INFO` | Python logging level |
| `DJANGO_SUPERUSER_USERNAME` | `admin` | Used by `setup_admin` command |
| `DJANGO_SUPERUSER_EMAIL` | `admin@example.com` | Used by `setup_admin` command |
| `DJANGO_SUPERUSER_PASSWORD` | `admin` | Used by `setup_admin` command |

---

## Production Checklist

Before deploying to a production environment:

- [ ] Set a strong random `SECRET_KEY`
- [ ] Set `DEBUG=False`
- [ ] Set `ALLOWED_HOSTS` to specific hostnames
- [ ] Set a strong `TELEMETRY_API_KEY` and configure agents to send it
- [ ] Switch to PostgreSQL via `DATABASE_URL`
- [ ] Run behind a reverse proxy (nginx/Caddy) with TLS
- [ ] Run `python manage.py collectstatic` and serve `/staticfiles/` from nginx
- [ ] Configure a cron job or systemd timer for `cleanup_old` to manage disk usage
- [ ] Change the default admin password

---

## Project Structure

```
server/
├── core/                  # Django project: settings, urls, wsgi/asgi
├── telemetry/             # Main app
│   ├── models.py          # TelemetryLog model
│   ├── views.py           # Ingest endpoint, dashboard, detail view, JSON API
│   ├── analysis.py        # Risk scoring engine
│   ├── admin.py           # Django admin config
│   ├── urls.py            # URL routing
│   ├── templates/         # HTML templates (base, dashboard, system_detail)
│   └── management/commands/
│       ├── setup_admin.py
│       ├── analyze_risks.py
│       └── cleanup_old.py
├── .env.example           # Environment variable template
├── requirements.txt
└── manage.py
```

---

## Disclaimer

This platform is designed exclusively for **authorized forensic investigations, enterprise security monitoring, and incident response**. It collects system metadata only — no passwords, keystrokes, or personal user data are gathered. All collection is transparent and read-only. Do not deploy agents on systems without proper authorization.
