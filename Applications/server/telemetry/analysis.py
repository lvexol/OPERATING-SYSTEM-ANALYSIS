"""
Telemetry risk analysis module.

Produces a 0-100 risk score and a human-readable findings list
from a parsed telemetry payload.
"""

HIGH_RISK_PROCESSES = {
    'nmap', 'nc', 'netcat', 'ncat', 'metasploit', 'meterpreter', 'msf',
    'tor', 'xmrig', 'minerd', 'cpuminer',
    'burpsuite', 'burp',
    'sqlmap', 'nikto', 'dirb', 'dirbuster', 'gobuster', 'feroxbuster',
    'hydra', 'medusa', 'john', 'hashcat',
    'aircrack', 'kismet', 'reaver',
    'wireshark', 'tcpdump',
    'msfvenom', 'setoolkit',
}

SUSPICIOUS_USERNAMES = {'toor', 'hacker', 'anon', 'temp', 'guest', 'exploit', 'pwn', 'r00t'}

OFFENSIVE_OS_KEYWORDS = {
    'kali', 'parrot', 'blackarch', 'backbox', 'pentoo', 'whonix', 'tails',
}

# Ports commonly used by RATs, C2 frameworks, reverse shells, miners
SUSPICIOUS_PORTS = {
    4444,   # Metasploit default
    4445,
    5555,   # Android ADB / common RAT
    6666,
    1337,   # "leet" – generic backdoor
    31337,  # Back Orifice
    9001,   # Tor relay
    9050,   # Tor SOCKS proxy
    9150,   # Tor browser
    8888,   # Common miner/C2
    3333,   # Monero mining pool
    14444,  # Monero mining pool
    45700,
}


def _score_processes(processes):
    score = 0
    findings = []
    detected = set()
    suspicious_users = set()

    for proc in processes:
        name = proc.get('name', '').lower()
        for tool in HIGH_RISK_PROCESSES:
            if tool in name:
                detected.add(name)
                score += 20
                break

        user = proc.get('username', '').lower()
        if user in SUSPICIOUS_USERNAMES:
            suspicious_users.add(f"{user} (PID {proc.get('pid', '?')})")
            score += 15

    if detected:
        findings.append(f"High-risk tools running: {', '.join(sorted(detected))}")
    if suspicious_users:
        findings.append(f"Suspicious process owners: {', '.join(sorted(suspicious_users))}")

    return score, findings


def _score_resources(cpu_info, disk_info, memory_info):
    score = 0
    findings = []

    cpu_usage = cpu_info.get('usage_percent', 0)
    if cpu_usage > 90:
        score += 15
        findings.append(f"Critical CPU usage: {cpu_usage}%")
    elif cpu_usage > 80:
        score += 10
        findings.append(f"High CPU usage: {cpu_usage}%")

    mem_used = memory_info.get('used_percent', 0)
    if mem_used > 95:
        score += 10
        findings.append(f"Critical memory usage: {mem_used}%")

    for disk in disk_info:
        pct = disk.get('percent', 0)
        if pct > 95:
            score += 10
            findings.append(f"Disk critical: {disk.get('mountpoint', '?')} ({pct}%)")

    return score, findings


def _score_os(system_info):
    score = 0
    findings = []

    os_fields = ' '.join([
        system_info.get('os_name', ''),
        system_info.get('os_version', ''),
        system_info.get('kernel_version', ''),
        system_info.get('hostname', ''),
    ]).lower()

    for keyword in OFFENSIVE_OS_KEYWORDS:
        if keyword in os_fields:
            score += 30
            findings.append(
                f"Offensive/privacy OS detected: "
                f"{system_info.get('os_name', '')} {system_info.get('os_version', '')}".strip()
            )
            break

    return score, findings


def _score_network(security_info, network_info):
    score = 0
    findings = []

    open_ports = set(security_info.get('open_ports', []))
    hit_ports = open_ports & SUSPICIOUS_PORTS
    if hit_ports:
        score += min(len(hit_ports) * 15, 40)
        findings.append(f"Suspicious open ports: {sorted(hit_ports)}")

    # Many network interfaces can indicate bridging, VPN stacking, or tunneling
    if len(network_info) > 8:
        score += 10
        findings.append(f"Unusually high number of network interfaces: {len(network_info)}")

    return score, findings


def _score_users(users_info):
    score = 0
    findings = []

    for user in users_info:
        name = user.get('name', '').lower()
        if name in SUSPICIOUS_USERNAMES:
            score += 10
            findings.append(f"Suspicious user account: {name}")
        # UID 0 with non-root name is unusual
        if user.get('uid') == 0 and name != 'root':
            score += 20
            findings.append(f"Non-root account has UID 0: {name}")

    return score, findings


def analyze_telemetry(data):
    """
    Analyzes parsed telemetry data.

    Returns:
        (risk_score: int 0-100, findings: list[str])
    """
    total_score = 0
    all_findings = []

    for scorer, args in [
        (_score_processes, (data.get('process_info', []),)),
        (_score_resources, (data.get('cpu_info', {}), data.get('disk_info', []), data.get('memory_info', {}))),
        (_score_os, (data.get('system_info', {}),)),
        (_score_network, (data.get('security_info', {}), data.get('network_info', []))),
        (_score_users, (data.get('users_info', []),)),
    ]:
        s, f = scorer(*args)
        total_score += s
        all_findings.extend(f)

    return min(total_score, 100), all_findings
