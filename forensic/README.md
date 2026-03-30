# 🔍 Forensic Bootable OS Evidence Analyzer

> **A Python-based digital forensics tool for Linux** — designed to detect evidence of bootable OS usage, suspicious activity, and unauthorized access on confiscated systems.

---

## ⚠️ Legal Disclaimer

This tool is intended **exclusively for authorized forensic investigations** by law enforcement, cybersecurity professionals, or certified digital forensic analysts. Unauthorized use on systems you do not have legal authority to examine may violate computer crime laws including but not limited to:

- Computer Fraud and Abuse Act (CFAA) — USA
- Computer Misuse Act — UK
- IT Act 2000 — India
- And equivalent laws in your jurisdiction

**Always obtain proper legal authorization before running this tool.**

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [How to Run](#how-to-run)
5. [Module Breakdown](#module-breakdown)
6. [Understanding the Output](#understanding-the-output)
7. [Report File](#report-file)
8. [Best Practices](#best-practices)
9. [Limitations](#limitations)
10. [Glossary](#glossary)

---

## Overview

When a device is confiscated as part of a criminal or security investigation, analysts need to determine whether:

- A **bootable operating system** (e.g., Kali Linux, Tails, Parrot OS live USB) was used on the device
- **Unauthorized users** accessed the system
- **Suspicious files or commands** were executed
- **External storage devices** were connected
- Evidence has been **tampered with or wiped**

This tool automates that investigation process, scanning the system across 10 forensic modules and generating a structured, timestamped report suitable for use as evidence documentation.

---

## Requirements

| Requirement | Details |
|---|---|
| **OS** | Linux (Ubuntu, Debian, Fedora, Kali, etc.) |
| **Python** | Python 3.6 or higher |
| **Privileges** | Root (`sudo`) strongly recommended |
| **Dependencies** | No external Python packages required — uses only standard library |
| **Disk Space** | Minimal (~50KB for the report file) |

**System tools used** (pre-installed on most Linux distros):

- `lsblk`, `fdisk`, `dmesg`, `journalctl`
- `last`, `lastb`, `ps`, `arp`, `ip`
- `efibootmgr`, `dd`, `find`, `grep`
- `crontab`, `systemctl`

---

## Installation

No installation required. Simply download the script and run it.

```bash
# Download or copy the script to the evidence machine
wget https://your-source/forensic_analyzer.py

# Give it execute permissions
chmod +x forensic_analyzer.py
```

Or just run it directly with Python:

```bash
python3 forensic_analyzer.py
```

---

## How to Run

### Standard Run (Recommended — as root)

```bash
sudo python3 forensic_analyzer.py
```

### Run Without Root (Limited results)

```bash
python3 forensic_analyzer.py
```

> Some checks like disk hashing, boot logs, and auth logs require root. A warning will be shown for each restricted section.

### Run and Save Output to Terminal Log

```bash
sudo python3 forensic_analyzer.py | tee terminal_output.txt
```

### Run on a Specific Mounted Forensic Image

If you've mounted a forensic disk image to `/mnt/evidence`, you can adapt paths manually inside the script or point log parsers at the mounted path.

```bash
sudo mount -o ro,loop evidence.img /mnt/evidence
sudo python3 forensic_analyzer.py
```

---

## Module Breakdown

The tool is divided into **10 analysis modules**, each targeting a specific area of forensic interest.

---

### Module 1 — System Information

**Purpose:** Establishes baseline identity of the machine under investigation.

**What it collects:**
- Hostname of the machine
- Full kernel version (`uname -a`)
- Operating system name and version
- Last recorded boot time

**Why it matters:**  
The hostname and OS version help confirm you're analyzing the correct device. The last boot time is a critical timestamp — if it doesn't match the suspect's claimed usage timeline, it may indicate the system was booted from a live OS (which wouldn't update the installed OS's boot record in the same way).

---

### Module 2 — Disk & Partition Analysis

**Purpose:** Identify all storage devices, partitions, and filesystems — including any that don't belong to the installed OS.

**What it collects:**
- All block devices with size, type, filesystem, and mount point (`lsblk`)
- Currently attached USB storage devices
- Linux-type partitions (ext2/3/4, btrfs, xfs) that may be live OS remnants
- Currently active mount points from `/proc/mounts`

**Suspicious indicators:**
- A USB device present with a Linux filesystem (possible live OS drive)
- Extra partitions not associated with the installed OS
- Mounts pointing to removable media locations like `/media/` or `/mnt/`

---

### Module 3 — USB Device History

**Purpose:** Identify all USB devices that have ever been connected to this machine, even if they're no longer attached.

**What it collects:**
- Kernel ring buffer (`dmesg`) entries for USB events
- `udev` journal entries for block device plug/unplug events
- USB references from `/var/log/syslog`, `/var/log/messages`, `/var/log/kern.log`
- Persistent USB disk IDs from `/dev/disk/by-id/`

**Why it matters:**  
Even if a live USB is removed, the kernel and system logs retain records of its connection, including timestamps, device serial numbers, and manufacturer info. This is often the most direct proof that a bootable USB was used.

**Suspicious indicators:**
- USB mass storage device connected outside of normal working hours
- Multiple USB connections in a short time span
- Vendor/product IDs matching known live OS USB drives (e.g., SanDisk, Kingston)
- Cleared or missing dmesg logs (itself a red flag)

---

### Module 4 — Boot History & GRUB Analysis

**Purpose:** Determine how many times the system was booted, from where, and whether any non-standard boot entries exist.

**What it collects:**
- Full list of boot sessions with timestamps (`journalctl --list-boots`)
- GRUB configuration menu entries
- EFI/UEFI boot manager entries (`efibootmgr`)
- Keywords in GRUB config matching known live OS names (Kali, Tails, Parrot, Ubuntu Live, etc.)

**Why it matters:**  
Every time a system boots from a live USB, it creates a new boot session entry in the journal. A high number of unexplained boot sessions — especially at odd hours — is a strong indicator of live OS usage. GRUB entries showing live OS names are direct evidence.

**Suspicious indicators:**
- Boot sessions outside of claimed usage hours
- GRUB entries mentioning "live", "usb", "kali", "tails", "parrot"
- EFI entries for operating systems not installed on the drive
- Unusually high boot count

---

### Module 5 — Auth & Login History

**Purpose:** Identify who logged in, when, from where, and whether any suspicious privilege escalation occurred.

**What it collects:**
- Full login history with timestamps (`last -F`)
- Failed login attempts (`lastb`)
- Auth log entries for `sudo`, `su`, and session events
- Non-system user accounts from `/etc/passwd`

**Why it matters:**  
Unauthorized logins, especially at unusual times or from unknown IPs, are key evidence. Repeated failed logins may indicate a brute-force attempt. Suspicious `sudo` usage could reveal privilege escalation to cover tracks.

**Suspicious indicators:**
- Logins at 2AM, 3AM, or other unusual hours
- Multiple failed login attempts followed by a success
- Unknown user accounts with UID ≥ 1000
- `sudo su` or `sudo -i` usage (escalation to root)

---

### Module 6 — Recently Accessed / Modified Files

**Purpose:** Find files that were created, modified, or accessed recently — potentially during unauthorized sessions.

**What it collects:**
- All files modified within the last 7 days (excluding `/proc`, `/sys`, `/dev`)
- Bash history files for all user accounts
- Hidden files and directories in home folders

**Why it matters:**  
Files modified during a suspicious time window can directly link to unauthorized activity. Bash history is one of the most valuable artifacts — it records every command typed, including downloads, file access, and encryption tools. Hidden files may be used to store stolen data or tools.

**Suspicious indicators:**
- Files modified during times the suspect claims not to have used the device
- Bash history containing commands like `wget`, `curl`, `nc`, `gpg`, `shred`, `wipe`, `dd`
- Hidden directories storing unusual executables or archives
- Evidence of history being cleared (`history -c` in bash history itself)

---

### Module 7 — Network Activity History

**Purpose:** Determine what networks the device connected to and when.

**What it collects:**
- Saved WiFi network profiles from NetworkManager
- Network connection and activation log from journalctl
- Current network interface configuration
- ARP cache (recent LAN connections)

**Why it matters:**  
Saved WiFi networks reveal locations the suspect visited with the device. Connecting to an unknown or suspicious network during the investigation window is strong evidence. The ARP cache shows recent local network connections.

**Suspicious indicators:**
- WiFi networks matching locations the suspect claims not to have visited
- VPN or Tor-related network interfaces
- Connections to unusual IP ranges
- Network activity at times that don't match the suspect's account

---

### Module 8 — Running Processes & Scheduled Tasks

**Purpose:** Identify currently running suspicious processes and any persistence mechanisms.

**What it collects:**
- All running processes sorted by CPU usage
- Cron jobs for all system users
- Active systemd timers

**Why it matters:**  
Malware, keyloggers, or data exfiltration tools may still be running. Cron jobs are commonly used to establish persistence — running scripts automatically at set intervals, even after reboot.

**Suspicious indicators:**
- Unknown processes running as root
- Cron jobs pointing to scripts in `/tmp`, `/dev/shm`, or hidden directories
- Processes with garbled or misleading names
- Outbound network connections from unusual processes

---

### Module 9 — Disk Hash (Chain of Custody)

**Purpose:** Generate cryptographic hashes of the disk to prove evidence integrity.

**What it collects:**
- MD5 hash of the Master Boot Record (first 512 bytes of `/dev/sda`)
- SHA256 hash of the same

**Why it matters:**  
Chain of custody is a legal requirement for digital evidence. Before and after any analysis, the hash must be recorded. If the hash changes, it proves the disk was modified. These hashes should be recorded in official case documentation.

**Usage in legal proceedings:**  
Present both hash values in your evidence report. Any subsequent analysis of the disk by another party should produce the same hash values — proving the evidence has not been tampered with.

---

### Module 10 — Report Generation

**Purpose:** Compile all findings into a structured, timestamped report file.

**What it produces:**
- A plain-text `.txt` file named `forensic_report_YYYYMMDD_HHMMSS.txt`
- A **Suspicious Findings Summary** at the top listing all high-priority items
- Full detailed findings from all 10 modules below

---

## Understanding the Output

### Terminal Color Coding

| Color | Meaning |
|---|---|
| 🔴 Red `[ALERT]` | High-priority suspicious finding |
| 🟡 Yellow `[WARN]` | Potentially suspicious, needs review |
| 🟢 Green `[OK]` | Normal / expected finding |
| 🔵 Blue / Cyan | Section headers and neutral info |
| White `[INFO]` | General informational output |

### Example Terminal Output

```
──────────────────────────────────────────────────────────
  ▶  3. USB DEVICE HISTORY
──────────────────────────────────────────────────────────
  [INFO] 14:32:01 — Parsing kernel messages for USB events...
  [ALERT] 14:32:01 — USB device(s) found:
  
  usb 1-1: new high-speed USB device number 3 using xhci_hcd
  usb 1-1: New USB device found, idVendor=0781, idProduct=5581
  usb 1-1: Product: Ultra
  usb 1-1: Manufacturer: SanDisk
  usb-storage 1-1:1.0: USB Mass Storage device detected
```

---

## Report File

The report file is saved in the **same directory** where the script is run.

**Filename format:** `forensic_report_20250223_143205.txt`

**Report structure:**

```
============================================================
  FORENSIC BOOTABLE OS EVIDENCE REPORT
  Generated  : 2025-02-23 14:32:05
  Hostname   : SUSPECT-LAPTOP-01
  Analyst    : root
  Tool       : Forensic Bootable OS Analyzer v1.0
============================================================

⚠️  SUSPICIOUS FINDINGS SUMMARY
────────────────────────────────────────────────────────────
  [!] USB Devices Detected: sdb — SanDisk Ultra 32GB (USB 3.0)
  [!] Live OS GRUB Entries: menuentry "Kali Linux Live" ...
  [!] Boot Count: 23 sessions found
  [!] Bash History (/root/.bash_history): wget http://...
  ...

DETAILED FINDINGS
============================================================
  1. SYSTEM INFORMATION
============================================================
  Hostname: SUSPECT-LAPTOP-01
  Kernel: Linux 5.15.0-91-generic ...
  ...
```

---

## Best Practices

### Before Running the Tool

1. **Never work on the original drive.** Always create a forensic image first using tools like `dd` or `FTK Imager`, then analyze the copy.

   ```bash
   sudo dd if=/dev/sda of=/mnt/backup/evidence.img bs=4M status=progress
   ```

2. **Document the hash of the original drive** before touching anything.

3. **Note the exact time** you started the investigation and any actions taken.

4. **Photograph the device** before and after seizure.

### During the Investigation

5. Run the tool as `root` for complete access.
6. Save the terminal output as well as the report file.
7. Do not shut down or reboot the system before running the tool — volatile data (RAM, current processes) will be lost.

### After Running the Tool

8. Store the report file securely with restricted access.
9. Include the report and hash values in the official case file.
10. If proceeding to legal proceedings, have the analysis reviewed by a certified digital forensic examiner.

---

## Limitations

| Limitation | Details |
|---|---|
| **Cleared logs** | If the suspect wiped system logs, this tool cannot recover them. Use disk imaging tools for deeper recovery. |
| **Encrypted drives** | If the drive is encrypted (LUKS, VeraCrypt), partition analysis will be limited without the decryption key. |
| **RAM artifacts** | This tool does not perform memory forensics. Use Volatility or LiME for RAM analysis. |
| **Windows systems** | This tool is for Linux only. Windows artifacts (Registry, Event Viewer) are not analyzed. |
| **Live OS sessions** | Activity performed entirely within a live OS session may leave little trace on the host drive, by design (especially Tails OS). |
| **Root required** | Without root, several modules (disk hash, auth logs, boot logs) will return incomplete results. |
| **Network forensics** | Deep packet inspection and network traffic analysis are not included. Use Wireshark or tcpdump separately. |

---

## Glossary

| Term | Definition |
|---|---|
| **Bootable OS** | An operating system loaded from external media (USB, DVD) rather than the installed hard drive |
| **Live USB** | A USB drive containing a complete operating system that runs entirely from the USB, leaving minimal traces on the host machine |
| **GRUB** | Grand Unified Bootloader — the boot manager used by most Linux systems that controls which OS loads at startup |
| **EFI/UEFI** | Unified Extensible Firmware Interface — modern firmware that manages boot entries on the hardware level |
| **dmesg** | Kernel ring buffer — a log of hardware and kernel events including USB connections |
| **Chain of Custody** | Legal documentation proving that evidence has not been altered from collection to court |
| **MBR** | Master Boot Record — the first 512 bytes of a disk, containing boot code and partition table |
| **Hash (MD5/SHA256)** | A cryptographic fingerprint of data — if the hash matches, the data is unchanged |
| **ARP Cache** | A record of recent local network (LAN) connections |
| **Cron Job** | A scheduled task in Linux that runs automatically at defined times |
| **Volatile Data** | Data that only exists while the system is powered on (RAM contents, running processes, network connections) |
| **Forensic Image** | A bit-for-bit copy of a storage device used for analysis without touching the original |

---

## Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | 2025-02-23 | Initial release — 10 modules, report generation, color-coded output |

---

*Developed for authorized forensic use only. Always follow your jurisdiction's laws and your organization's policies when conducting digital forensic investigations.*
