#!/usr/bin/env python3
"""
=============================================================
  FORENSIC BOOTABLE OS EVIDENCE ANALYZER
  For use on confiscated/evidence Linux systems
  Run as ROOT for full access
=============================================================
"""

import os
import sys
import json
import subprocess
import hashlib
import datetime
import platform
import glob
import re
from pathlib import Path

# ── Color codes ──────────────────────────────────────────────
R = "\033[91m"   # Red
G = "\033[92m"   # Green
Y = "\033[93m"   # Yellow
B = "\033[94m"   # Blue
C = "\033[96m"   # Cyan
W = "\033[97m"   # White
BOLD = "\033[1m"
RESET = "\033[0m"

REPORT = []   # Collects all findings for the final report
SUSPICIOUS = []  # High-priority suspicious findings

def banner():
    print(f"""{C}{BOLD}
╔══════════════════════════════════════════════════════════════╗
║         FORENSIC BOOTABLE OS EVIDENCE ANALYZER              ║
║         Digital Forensics Tool — Authorized Use Only        ║
╚══════════════════════════════════════════════════════════════╝{RESET}
""")

def log(msg, level="INFO"):
    ts = datetime.datetime.now().strftime("%H:%M:%S")
    colors = {"INFO": W, "OK": G, "WARN": Y, "ALERT": R, "HEAD": C}
    c = colors.get(level, W)
    print(f"  {c}[{level}]{RESET} {ts} — {msg}")

def section(title):
    print(f"\n{B}{BOLD}{'─'*60}{RESET}")
    print(f"{B}{BOLD}  ▶  {title}{RESET}")
    print(f"{B}{BOLD}{'─'*60}{RESET}")
    REPORT.append(f"\n{'='*60}\n  {title}\n{'='*60}")

def add_finding(key, value, suspicious=False):
    entry = f"  {key}: {value}"
    REPORT.append(entry)
    if suspicious:
        SUSPICIOUS.append(f"[!] {key}: {value}")

def run_cmd(cmd):
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=15)
        return result.stdout.strip()
    except Exception as e:
        return f"ERROR: {e}"

# ─────────────────────────────────────────────────────────────
# 1. SYSTEM INFORMATION
# ─────────────────────────────────────────────────────────────
def system_info():
    section("1. SYSTEM INFORMATION")
    
    hostname = run_cmd("hostname")
    log(f"Hostname       : {hostname}")
    add_finding("Hostname", hostname)

    uname = run_cmd("uname -a")
    log(f"Kernel         : {uname}")
    add_finding("Kernel", uname)

    uptime = run_cmd("uptime -s")
    log(f"System Boot    : {uptime}")
    add_finding("Last Boot Time", uptime)

    distro = run_cmd("cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2")
    log(f"OS             : {distro}")
    add_finding("OS", distro)

# ─────────────────────────────────────────────────────────────
# 2. DISK & PARTITION ANALYSIS
# ─────────────────────────────────────────────────────────────
def disk_analysis():
    section("2. DISK & PARTITION ANALYSIS")

    log("Listing all block devices...")
    lsblk = run_cmd("lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL,UUID 2>/dev/null")
    print(f"\n{Y}{lsblk}{RESET}\n")
    add_finding("Block Devices", "\n" + lsblk)

    # Check for non-standard filesystems (ext4, btrfs etc on USB)
    log("Checking for removable/USB storage devices...")
    usb_devs = run_cmd("lsblk -d -o NAME,TRAN,SIZE,MODEL | grep -i usb 2>/dev/null")
    if usb_devs:
        log(f"USB device(s) found:\n{usb_devs}", "ALERT")
        add_finding("USB Devices Detected", usb_devs, suspicious=True)
    else:
        log("No USB devices currently attached.", "OK")
        add_finding("USB Devices", "None currently attached")

    # Check for Linux-type partitions that may be live OS remnants
    log("Checking for Linux-type filesystems on all partitions...")
    fdisk = run_cmd("fdisk -l 2>/dev/null | grep -E 'Linux|ext[234]|btrfs|xfs'")
    if fdisk:
        log(f"Linux partitions found:\n{fdisk}", "WARN")
        add_finding("Linux Partitions", fdisk, suspicious=True)

    # Check for recently mounted devices in /etc/mtab or /proc/mounts
    log("Checking /proc/mounts for any unusual mounts...")
    mounts = run_cmd("cat /proc/mounts 2>/dev/null | grep -vE 'proc|sysfs|devpts|tmpfs|cgroup|none|sys'")
    print(f"{Y}{mounts}{RESET}")
    add_finding("Active Mounts", mounts)

# ─────────────────────────────────────────────────────────────
# 3. USB DEVICE HISTORY
# ─────────────────────────────────────────────────────────────
def usb_history():
    section("3. USB DEVICE HISTORY")

    log("Parsing kernel messages for USB events...")
    dmesg_usb = run_cmd("dmesg 2>/dev/null | grep -iE 'usb|removable|mass.storage' | tail -40")
    if dmesg_usb:
        print(f"{Y}{dmesg_usb}{RESET}")
        add_finding("dmesg USB Events", dmesg_usb, suspicious=True)
    else:
        log("No USB events in current dmesg (may be cleared).", "WARN")
        add_finding("dmesg USB Events", "None found — log may have been cleared", suspicious=True)

    # Check udev logs
    log("Checking udev rules / device history...")
    udev = run_cmd("journalctl -b -u systemd-udevd 2>/dev/null | grep -iE 'usb|block|sd[a-z]' | tail -30")
    if udev:
        print(f"{Y}{udev}{RESET}")
        add_finding("Udev USB Journal", udev, suspicious=True)

    # /var/log/syslog or messages
    for logfile in ["/var/log/syslog", "/var/log/messages", "/var/log/kern.log"]:
        if os.path.exists(logfile):
            log(f"Scanning {logfile} for USB references...")
            usb_log = run_cmd(f"grep -iE 'usb|removable' {logfile} 2>/dev/null | tail -30")
            if usb_log:
                print(f"{Y}{usb_log}{RESET}")
                add_finding(f"USB Entries in {logfile}", usb_log, suspicious=True)

    # Check /dev/disk/by-id for any persistent USB entries
    log("Checking /dev/disk/by-id for USB disk entries...")
    by_id = run_cmd("ls -la /dev/disk/by-id/ 2>/dev/null | grep -i usb")
    if by_id:
        log(f"USB disk IDs:\n{by_id}", "ALERT")
        add_finding("USB Disk IDs (/dev/disk/by-id)", by_id, suspicious=True)

# ─────────────────────────────────────────────────────────────
# 4. BOOT HISTORY & GRUB ANALYSIS
# ─────────────────────────────────────────────────────────────
def boot_history():
    section("4. BOOT HISTORY & GRUB ANALYSIS")

    log("Checking system boot log (journalctl)...")
    boots = run_cmd("journalctl --list-boots 2>/dev/null")
    if boots:
        print(f"{Y}{boots}{RESET}")
        add_finding("Boot Sessions", boots)
        boot_count = len(boots.strip().split('\n'))
        log(f"Total boot sessions found: {boot_count}", "OK")
        if boot_count > 5:
            log(f"High number of boot sessions ({boot_count}) — could indicate frequent reboots or live OS use.", "WARN")
            add_finding("Boot Count", str(boot_count), suspicious=True)

    log("Checking GRUB configuration for boot entries...")
    grub_cfg = run_cmd("cat /boot/grub/grub.cfg 2>/dev/null | grep -E 'menuentry|set default|set timeout'")
    if grub_cfg:
        print(f"{C}{grub_cfg}{RESET}")
        add_finding("GRUB Menu Entries", grub_cfg)

    # Check for external/live OS entries in GRUB
    live_entries = run_cmd("cat /boot/grub/grub.cfg 2>/dev/null | grep -iE 'live|usb|kali|tails|ubuntu|parrot|boot'")
    if live_entries:
        log(f"Potential Live OS GRUB entries found!", "ALERT")
        print(f"{R}{live_entries}{RESET}")
        add_finding("Live OS GRUB Entries", live_entries, suspicious=True)

    # EFI boot entries
    log("Checking EFI boot entries...")
    efi = run_cmd("efibootmgr 2>/dev/null")
    if efi and "EFI" in efi:
        print(f"{Y}{efi}{RESET}")
        add_finding("EFI Boot Entries", efi)
        if re.search(r'usb|kali|tails|live|parrot', efi, re.IGNORECASE):
            log("Suspicious EFI boot entry found!", "ALERT")
            add_finding("Suspicious EFI Entry", efi, suspicious=True)

# ─────────────────────────────────────────────────────────────
# 5. AUTH & LOGIN HISTORY
# ─────────────────────────────────────────────────────────────
def login_history():
    section("5. AUTH & LOGIN HISTORY")

    log("Checking last logins (last command)...")
    last = run_cmd("last -F 2>/dev/null | head -40")
    print(f"{Y}{last}{RESET}")
    add_finding("Login History (last)", last)

    log("Checking failed login attempts...")
    lastb = run_cmd("lastb 2>/dev/null | head -20")
    if lastb and "lastb" not in lastb.lower():
        print(f"{R}{lastb}{RESET}")
        add_finding("Failed Logins (lastb)", lastb, suspicious=True)

    log("Checking /var/log/auth.log for sudo/su usage...")
    auth = run_cmd("grep -iE 'sudo|su|FAILED|session opened' /var/log/auth.log 2>/dev/null | tail -40")
    if auth:
        print(f"{Y}{auth}{RESET}")
        add_finding("Auth Log (sudo/su/sessions)", auth)

    log("Checking /etc/passwd for unusual users...")
    users = run_cmd("awk -F: '$3 >= 1000 && $3 != 65534 {print $1, $3, $6, $7}' /etc/passwd")
    print(f"{C}{users}{RESET}")
    add_finding("Non-system Users", users)

# ─────────────────────────────────────────────────────────────
# 6. RECENTLY ACCESSED / MODIFIED FILES
# ─────────────────────────────────────────────────────────────
def recent_files():
    section("6. RECENTLY ACCESSED / MODIFIED FILES")

    log("Finding files modified in the last 7 days (excluding /proc, /sys)...")
    recent = run_cmd("find / -not \\( -path /proc -prune \\) -not \\( -path /sys -prune \\) -not \\( -path /dev -prune \\) -mtime -7 -type f 2>/dev/null | grep -vE '.cache|.dbus|.mozilla' | head -60")
    if recent:
        print(f"{Y}{recent}{RESET}")
        add_finding("Files Modified Last 7 Days", recent)

    log("Checking bash history files for all users...")
    histories = glob.glob("/home/*/.bash_history") + ["/root/.bash_history"]
    for hfile in histories:
        if os.path.exists(hfile):
            content = run_cmd(f"cat {hfile} 2>/dev/null | tail -50")
            if content:
                log(f"History found: {hfile}", "ALERT")
                print(f"{R}{content}{RESET}")
                add_finding(f"Bash History ({hfile})", content, suspicious=True)

    log("Checking for hidden files/dirs in home directories...")
    hidden = run_cmd("find /home /root -maxdepth 3 -name '.*' -type f 2>/dev/null | grep -vE '.bashrc|.profile|.bash_logout|.bash_history|.cache|.config|.local'")
    if hidden:
        print(f"{Y}{hidden}{RESET}")
        add_finding("Hidden Files in Home", hidden, suspicious=True)

# ─────────────────────────────────────────────────────────────
# 7. NETWORK HISTORY
# ─────────────────────────────────────────────────────────────
def network_history():
    section("7. NETWORK ACTIVITY HISTORY")

    log("Checking known WiFi connections (NetworkManager)...")
    nm_conns = run_cmd("ls /etc/NetworkManager/system-connections/ 2>/dev/null")
    if nm_conns:
        print(f"{Y}{nm_conns}{RESET}")
        add_finding("Saved WiFi Networks", nm_conns, suspicious=True)

    log("Checking NetworkManager connection log...")
    nm_log = run_cmd("journalctl -u NetworkManager 2>/dev/null | grep -iE 'connect|activated|AP' | tail -30")
    if nm_log:
        print(f"{Y}{nm_log}{RESET}")
        add_finding("NetworkManager Log", nm_log)

    log("Checking current network interfaces...")
    ifaces = run_cmd("ip a 2>/dev/null")
    print(f"{C}{ifaces}{RESET}")
    add_finding("Network Interfaces", ifaces)

    log("Checking ARP cache for recent connections...")
    arp = run_cmd("arp -n 2>/dev/null")
    print(f"{C}{arp}{RESET}")
    add_finding("ARP Cache", arp)

# ─────────────────────────────────────────────────────────────
# 8. RUNNING PROCESSES & SCHEDULED TASKS
# ─────────────────────────────────────────────────────────────
def processes_and_tasks():
    section("8. RUNNING PROCESSES & SCHEDULED TASKS")

    log("Listing all running processes...")
    ps = run_cmd("ps aux --sort=-%cpu 2>/dev/null | head -30")
    print(f"{C}{ps}{RESET}")
    add_finding("Top Running Processes", ps)

    log("Checking cron jobs for all users...")
    cron = run_cmd("for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null | grep -v '^#' | grep -v '^$' && echo \"  -> user: $user\"; done")
    if cron:
        print(f"{Y}{cron}{RESET}")
        add_finding("Cron Jobs", cron, suspicious=True)

    log("Checking systemd timers...")
    timers = run_cmd("systemctl list-timers --all 2>/dev/null | head -20")
    print(f"{C}{timers}{RESET}")
    add_finding("Systemd Timers", timers)

# ─────────────────────────────────────────────────────────────
# 9. DISK IMAGE HASH (Chain of Custody)
# ─────────────────────────────────────────────────────────────
def disk_hash():
    section("9. DISK HASH — CHAIN OF CUSTODY")

    log("Generating MD5/SHA256 hash of primary disk (first 512 bytes / MBR)...")
    mbr_hash_md5 = run_cmd("dd if=/dev/sda bs=512 count=1 2>/dev/null | md5sum")
    mbr_hash_sha = run_cmd("dd if=/dev/sda bs=512 count=1 2>/dev/null | sha256sum")
    
    if mbr_hash_md5 and "error" not in mbr_hash_md5.lower():
        log(f"MBR MD5    : {mbr_hash_md5}", "OK")
        log(f"MBR SHA256 : {mbr_hash_sha}", "OK")
        add_finding("MBR MD5 Hash", mbr_hash_md5)
        add_finding("MBR SHA256 Hash", mbr_hash_sha)
    else:
        log("Could not hash /dev/sda — run as root or specify correct device.", "WARN")
        add_finding("MBR Hash", "Failed — run as root")

# ─────────────────────────────────────────────────────────────
# 10. GENERATE REPORT
# ─────────────────────────────────────────────────────────────
def generate_report():
    section("10. GENERATING FINAL REPORT")

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = f"forensic_report_{timestamp}.txt"

    header = f"""
{'='*60}
  FORENSIC BOOTABLE OS EVIDENCE REPORT
  Generated  : {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
  Hostname   : {run_cmd("hostname")}
  Analyst    : {run_cmd("whoami")}
  Tool       : Forensic Bootable OS Analyzer v1.0
{'='*60}

⚠️  SUSPICIOUS FINDINGS SUMMARY
{'─'*60}
"""
    if SUSPICIOUS:
        for s in SUSPICIOUS:
            header += f"  {s}\n"
    else:
        header += "  No high-priority suspicious findings.\n"

    full_report = header + "\n\nDETAILED FINDINGS\n" + "\n".join(REPORT)

    with open(report_file, "w") as f:
        f.write(full_report)

    log(f"Report saved to: {report_file}", "OK")
    print(f"\n{G}{BOLD}  ✔  REPORT FILE: {report_file}{RESET}")

    # Print suspicious summary to terminal
    print(f"\n{R}{BOLD}{'─'*60}")
    print(f"  ⚠️   SUSPICIOUS FINDINGS ({len(SUSPICIOUS)} items)")
    print(f"{'─'*60}{RESET}")
    for s in SUSPICIOUS:
        print(f"  {R}{s}{RESET}")

    return report_file

# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────
def main():
    banner()

    if os.geteuid() != 0:
        print(f"\n  {Y}[WARN] Not running as root. Some checks may be limited.{RESET}")
        print(f"  {Y}       Re-run with: sudo python3 forensic_analyzer.py{RESET}\n")

    print(f"  {C}Starting forensic analysis at {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{RESET}\n")

    try:
        system_info()
        disk_analysis()
        usb_history()
        boot_history()
        login_history()
        recent_files()
        network_history()
        processes_and_tasks()
        disk_hash()
        report = generate_report()
    except KeyboardInterrupt:
        print(f"\n\n  {R}Analysis interrupted by user.{RESET}")
        sys.exit(1)

    print(f"\n{G}{BOLD}  ✔  Analysis complete. Review the report file for full details.{RESET}\n")

if __name__ == "__main__":
    main()
