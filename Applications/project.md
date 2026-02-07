Got it. I’ll give you a **clean, professional, ready-to-paste project description** that you can directly hand to another agent or use as a master prompt.
No illegal behavior, no ambiguity, no “agent hallucination traps”.

Below is **exactly what your system must do — nothing more, nothing less.**

---

# Project Title

**Centralized Linux Telemetry & Forensic Metadata Collection Platform**

---

## 1. Project Overview (High-level Description)

This project implements a **centralized system for collecting forensic-relevant telemetry from Linux machines** using an **administrator-installed agent** and a **central analysis server**.

The system is designed for **enterprise security monitoring, incident response, and digital forensics**, where Linux systems must be monitored in a **legally compliant and auditable manner**.

Each Linux system runs a lightweight agent that collects **non-intrusive system metadata** and securely transmits it to a central server, where the data is **stored, correlated, and transformed into structured system documentation**.

The platform does **not** collect user passwords, keystrokes, private content, or personal data beyond system-level metadata.

---

## 2. System Architecture

### Components

#### 1. Linux Agent (Client)

* Installed manually by an administrator
* Runs as a background system service
* Uses privileged access granted at installation time
* Performs periodic data collection
* Sends collected data to the central server

#### 2. Central Server

* Receives telemetry from multiple agents
* Stores and correlates system data
* Generates detailed forensic and configuration reports
* Maintains audit logs of all incoming data

---

## 3. Agent Responsibilities (What the Agent Must Do)

The Linux agent **only collects system metadata**, never credentials or user input.

### A. System Identification

* Hostname
* OS name and version
* Kernel version
* CPU architecture
* System uptime
* Boot time

### B. Hardware & Virtualization Detection

* CPU model and core count
* Total and available RAM
* Disk devices and mounted filesystems
* Virtualization detection (VM / container / bare metal)

  * KVM
  * VMware
  * VirtualBox
  * Docker / container environment

### C. Process & Application Telemetry

* List of running processes (PID, name, owner)
* System services and their states
* Installed packages (package name + version)
* Recently started services

### D. Network Telemetry

* Active network interfaces
* IP addresses
* Routing table
* Open TCP/UDP ports
* Active network connections (metadata only)
* DNS configuration

### E. User & Access Metadata

* Local user account names
* Login shells
* UID/GID
* Last login time (metadata only)

### F. Security & System State

* Firewall status
* SELinux / AppArmor status
* Kernel taint flags
* Loaded kernel modules (names only)
* System time & timezone

---

## 4. Data Handling Rules (Strict)

The agent **MUST NOT**:

* Capture passwords
* Capture keystrokes
* Capture file contents
* Monitor user activity in real time
* Bypass system security controls
* Persist stealthily

All data collection must be:

* Read-only
* Metadata-only
* Transparent
* Logged

---

## 5. Privilege Model

* The agent is installed using `sudo`
* Privileges are granted via:

  * Linux capabilities
  * Limited sudo rules
* No passwords are stored or transmitted
* The agent never prompts users for credentials

---

## 6. Data Transmission

* Data is serialized as JSON
* Transmission occurs over:

  * HTTPS (preferred)
  * Authenticated API endpoint
* Each agent has:

  * Unique agent ID
  * Registration token
* All communication is logged

---

## 7. Central Server Responsibilities

### A. Data Ingestion

* Accept telemetry from multiple agents
* Validate agent identity
* Store raw data securely

### B. Data Consolidation

* Correlate system snapshots over time
* Track configuration changes
* Detect anomalies (optional)

### C. Reporting & Documentation

Generate structured reports per system:

* System profile report
* Network state report
* Running application inventory
* Virtualization status
* Security posture summary

Reports must be:

* Human-readable
* Timestamped
* Exportable (JSON / PDF / text)

---

## 8. Logging & Auditability

* All agent actions are logged locally
* All server interactions are logged centrally
* Each data submission includes:

  * Timestamp
  * Agent ID
  * Collection version
* Logs are immutable once stored

---

## 9. Deployment Model

### Agent

* Python-based
* Runs as:

  * `systemd` service
* Minimal resource usage
* Configurable collection interval

### Server

* Python / Flask or FastAPI
* Scalable to multiple agents
* Can run on-prem or cloud

---

## 10. Intended Use Cases

* Incident response
* Linux system forensics
* Enterprise asset inventory
* Security compliance monitoring
* Law-enforcement forensic analysis (with legal authorization)

---

## 11. Non-Goals (Explicit)

This project is **not**:

* Malware
* Spyware
* Surveillance software
* Credential harvesting tool
* Keylogging system

---

## 12. Deliverables

* Linux agent source code
* Central server source code
* Installation guide
* Architecture documentation
* Sample forensic report
* Security & ethics statement

---

## 13. Evaluation Criteria

* Correctness of data collection
* Stability of agent
* Accuracy of reports
* Security of communication
* Compliance with ethical boundaries

---

## One-line summary (for prompt headers)

> “Build a centralized Linux forensic telemetry platform using an admin-installed agent that collects system, process, and network metadata and consolidates it into structured forensic reports on a central server.”

---

If you want next:

* I can compress this into a **single master prompt**
* I can turn this into a **final academic project report**
* I can create a **checklist for the agent to implement**

Just say what format you want.
