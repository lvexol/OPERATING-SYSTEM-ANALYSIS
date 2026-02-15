import json

HIGH_RISK_PROCESSES = {
    'nmap', 'nc', 'netcat', 'metasploit', 'meterpreter', 'tor', 'xmrig', 'minerd', 
    'burpsuite', 'sqlmap', 'nikto', 'dirb', 'hydra', 'john', 'hashcat'
}

SUSPICIOUS_USERNAMES = {'toor', 'hacker', 'anon', 'temp', 'guest'}

def analyze_telemetry(data):
    """
    Analyzes parsed telemetry data and returns a risk score (0-100) and analysis report.
    """
    score = 0
    report = []
    
    # 1. Check processes
    processes = data.get('process_info', [])
    detected_tools = []
    for proc in processes:
        name = proc.get('name', '').lower()
        if any(tool in name for tool in HIGH_RISK_PROCESSES):
            detected_tools.append(name)
            score += 20
    
    if detected_tools:
        report.append(f"High risk tools detected: {', '.join(set(detected_tools))}")

    # 2. Check Resource Usage
    cpu_usage = data.get('cpu_info', {}).get('usage_percent', 0)
    if cpu_usage > 80:
        score += 10
        report.append(f"High CPU usage: {cpu_usage}%")
        
    for disk in data.get('disk_info', []):
        if disk.get('percent', 0) > 95:
            score += 10
            report.append(f"Disk critical: {disk.get('mountpoint')} ({disk.get('percent')}%)")

    # 3. Check Users
    # Assuming user info might be in system info or separate, tailored to input format
    # The prompt described: 5. Process list: array of {"pid", "name", "username", "status"}
    for proc in processes:
        user = proc.get('username', '').lower()
        if user in SUSPICIOUS_USERNAMES:
            score += 15
            report.append(f"Suspicious process user: {user} (PID: {proc.get('pid')})")

    # 4. OS/Kernel checks (fingerprinting)
    os_name = data.get('system_info', {}).get('os_name', '').lower()
    if 'kali' in os_name or 'parrot' in os_name or 'blackarch' in os_name:
        score += 30
        report.append(f"Offensive OS detected: {data.get('system_info', {}).get('os_name')}")

    return min(score, 100), report
