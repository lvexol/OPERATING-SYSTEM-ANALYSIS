# Linux Telemetry & Forensic Platform

A centralized system for collecting forensic-relevant telemetry from Linux machines using an administrator-installed agent and a central analysis server.

## Components

- **Agent**: Python-based service running on client machines to collect metadata.
- **Server**: FastAPI backend to receive, store, and report on telemetry.

## Setup

1. **Server**:
   ```bash
   cd server
   pip install -r requirements.txt
   python app.py
   ```

2. **Agent**:
   ```bash
   cd agent
   pip install -r requirements.txt
   sudo python main.py
   ```
