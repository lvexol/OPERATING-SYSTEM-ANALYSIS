## **Hacking & Intrusion Tools Commonly Misused by Cybercriminals**

Format: **Tool \| Category \| Function \| Criminal Misuse \| Forensic Indicators \| Risk Rating**

---

### **1. Exploitation Frameworks**

**Metasploit Framework**

- **Category**: Exploitation Framework  
- **Function**: Develop, test, and execute exploits and payloads against remote targets.  
- **Criminal Misuse**: Launching remote code execution attacks, establishing reverse shells, automating post‑exploitation.  
- **Forensic Indicators**: Metasploit project files and logs, typical payload artefacts (e.g., `meterpreter`), unusual listening ports, signatures in IDS/AV logs.  
- **Risk Rating**: **High** – Widely available, powerful, and often seen in intrusions.  

**Cobalt Strike (and cracked variants)**

- **Category**: Commercial C2 & Post‑Exploitation Suite  
- **Function**: Red‑team platform for beaconing, lateral movement, and persistence.  
- **Criminal Misuse**: Pirated builds widely used by APT and ransomware groups for stealthy C2 and lateral movement.  
- **Forensic Indicators**: Beacon traffic patterns, malleable C2 profiles, specific PE artefacts, YARA signatures, known C2 domain/IP infrastructure.  
- **Risk Rating**: **High** – Heavily associated with serious intrusions and ransomware campaigns.  

**Empire / Covenant / Sliver (C2 Frameworks)**

- **Category**: Post‑Exploitation / C2 Frameworks  
- **Function**: Provide scripted, multi‑platform agents for persistence, lateral movement, and data theft.  
- **Criminal Misuse**: Long‑term footholds in victim networks, data exfiltration, credential harvesting.  
- **Forensic Indicators**: Agent binaries/scripts, unusual scheduled tasks/services, C2 domain/IPs, encrypted beaconing traffic on non‑standard ports.  
- **Risk Rating**: **High** – Designed for stealthy operations.  

---

### **2. Network Scanners**

**Nmap**

- **Category**: Network Scanner  
- **Function**: Host discovery, port scanning, and service identification.  
- **Criminal Misuse**: Reconnaissance for vulnerable hosts/services before exploitation.  
- **Forensic Indicators**: Unusual scan patterns in firewall logs, characteristic Nmap signatures in pcaps (e.g., TCP SYN scans), scan logs on attacker systems.  
- **Risk Rating**: **High** – Extremely common in both legit and malicious activity.  

**Masscan**

- **Category**: High‑Speed Network Scanner  
- **Function**: Internet‑scale port scanning at very high rates.  
- **Criminal Misuse**: Rapid scanning of large IP ranges to find open ports and weak services (e.g., for botnet growth, RDP/SSH brute‑force).  
- **Forensic Indicators**: Large volumes of short‑lived connections from single IPs, distinctive Masscan banner in some configs, blocked‑connection spikes in firewall logs.  
- **Risk Rating**: **High** – Favoured for mass reconnaissance.  

---

### **3. Vulnerability Scanners**

**Nessus / Tenable.sc**

- **Category**: Vulnerability Scanner  
- **Function**: Authenticated/unauthenticated scanning for known vulnerabilities and misconfigurations.  
- **Criminal Misuse**: Identifying exploitable weaknesses at scale in poorly defended networks.  
- **Forensic Indicators**: Scanner user‑agents and banners in logs, sequences of vulnerability‑probe traffic, scanner reports found on attacker infrastructure.  
- **Risk Rating**: **Medium–High** – Commercial licensing but often misused via pirated or misconfigured instances.  

**OpenVAS / Greenbone**

- **Category**: Open‑Source Vulnerability Scanner  
- **Function**: Network vulnerability scanning and reporting.  
- **Criminal Misuse**: Similar to Nessus; enumeration of targets for later exploitation.  
- **Forensic Indicators**: Characteristic probe patterns; logs indicating OpenVAS scanner IPs; report files on compromised hosts.  
- **Risk Rating**: **Medium–High**.  

**Nikto**

- **Category**: Web Vulnerability Scanner  
- **Function**: Scan web servers for dangerous files, outdated software, and misconfigurations.  
- **Criminal Misuse**: Reconnaissance for web exploitation (e.g., outdated CMS, misconfig).  
- **Forensic Indicators**: Nikto user‑agent strings, rapid requests across many URLs, logs on attacker machines.  
- **Risk Rating**: **Medium**.  

---

### **4. Password Crackers**

**John the Ripper**

- **Category**: Password Cracker  
- **Function**: Offline cracking of password hashes (Unix, Windows, databases, etc.).  
- **Criminal Misuse**: Cracking dumped credential hashes to escalate privileges and pivot.  
- **Forensic Indicators**: Hash files, wordlists, cracking session logs on attacker systems; CPU‑intensive workloads on compromised hosts running cracks.  
- **Risk Rating**: **High** – Central to many intrusion workflows once hashes are obtained.  

**Hashcat**

- **Category**: GPU‑Accelerated Password Cracker  
- **Function**: High‑performance cracking of many hash types using GPUs.  
- **Criminal Misuse**: Rapid cracking of large hash dumps (e.g., domain controller dumps, leaked databases).  
- **Forensic Indicators**: Hashcat config and potfiles, GPU utilisation anomalies, presence of large wordlists/rulesets.  
- **Risk Rating**: **High** – Very effective at scale.  

**Hydra**

- **Category**: Online Password Guessing Tool  
- **Function**: Brute‑force or dictionary attacks against network services (SSH, FTP, RDP, HTTP auth, etc.).  
- **Criminal Misuse**: Credential‑stuffing and brute‑force attacks on exposed services.  
- **Forensic Indicators**: Multiple failed login attempts from single IP ranges, Hydra user‑agent strings in some protocols, tool logs on attacker hosts.  
- **Risk Rating**: **High** – Often seen in brute‑force campaigns.  

---

### **5. Wireless Tools**

**Aircrack‑ng Suite**

- **Category**: Wireless Attack Tools  
- **Function**: Packet capture, WEP/WPA/WPA2 key cracking, replay attacks.  
- **Criminal Misuse**: Cracking Wi‑Fi passwords to gain unauthorised network access.  
- **Forensic Indicators**: Capture files (`.cap`), injection traffic in wireless logs, tool binaries on attacker laptops, channel hopping in pcaps.  
- **Risk Rating**: **High** – Widely used in Wi‑Fi intrusions.  

**Reaver**

- **Category**: WPS Attack Tool  
- **Function**: Exploit weaknesses in Wi‑Fi Protected Setup (WPS) to recover WPA/WPA2 passphrases.  
- **Criminal Misuse**: Rapid compromise of poorly configured access points.  
- **Forensic Indicators**: Logs showing repeated WPS PIN attempts, Reaver fingerprints in access point logs, tool artefacts on attacker devices.  
- **Risk Rating**: **Medium–High** – Highly effective against vulnerable APs.  

**Wifite**

- **Category**: Automated Wireless Attack Tool  
- **Function**: Automates capture and cracking of WPA/WPA2 handshakes using Aircrack‑ng and others.  
- **Criminal Misuse**: Low‑effort Wi‑Fi attacks by less skilled actors.  
- **Forensic Indicators**: Similar to Aircrack‑ng; scripted attacks with predictable timing; presence of Wifite configs.  
- **Risk Rating**: **High** – Lowers the barrier to entry.  

---

### **6. Web Application Tools**

**Burp Suite**

- **Category**: Web Application Testing Platform  
- **Function**: Intercepting proxy, scanner, and manual web app testing.  
- **Criminal Misuse**: Crafting and automating complex web attacks (SQLi, XSS, auth bypass), manipulating requests and sessions.  
- **Forensic Indicators**: Characteristic scanning patterns, Burp user‑agents and headers, Burp project files on attacker disks.  
- **Risk Rating**: **High** – Powerful and widely used.  

**OWASP ZAP**

- **Category**: Web Application Scanner  
- **Function**: Automated and semi‑automated scanning for web vulnerabilities.  
- **Criminal Misuse**: Recon and vulnerability detection prior to exploitation.  
- **Forensic Indicators**: ZAP user‑agents, spidering/scanning patterns in web logs, ZAP session files on attacker hosts.  
- **Risk Rating**: **Medium–High**.  

**SQLmap**

- **Category**: SQL Injection Tool  
- **Function**: Automate detection and exploitation of SQL injection flaws.  
- **Criminal Misuse**: Dumping databases, escalating privileges, and maintaining DB‑level persistence.  
- **Forensic Indicators**: Repeated crafted SQL payloads in logs, sqlmap user‑agent (if not changed), dumped DB data on attacker machines.  
- **Risk Rating**: **High** – Frequently associated with database breaches.  

---

### **7. Social Engineering Tools**

**SET (Social‑Engineer Toolkit)**

- **Category**: Social Engineering Framework  
- **Function**: Phishing page cloning, credential harvesting, payload delivery via social vectors.  
- **Criminal Misuse**: Credential theft, malware delivery via phishing campaigns.  
- **Forensic Indicators**: Phishing web server artefacts, cloned login pages, SET logs/templates on attacker systems, email campaign traces.  
- **Risk Rating**: **High** – Directly facilitates social‑engineering attacks.  

---

### **8. Post‑Exploitation & Credential Tools**

**Mimikatz**

- **Category**: Credential Theft Tool  
- **Function**: Extract plaintext passwords, hashes, and Kerberos tickets from Windows memory.  
- **Criminal Misuse**: Rapid escalation and lateral movement across Windows domains.  
- **Forensic Indicators**: Mimikatz binaries/scripts, event logs indicating LSASS access, unusual `sekurlsa`/Kerberos activity, AV/EDR alerts.  
- **Risk Rating**: **High** – Central to many Windows intrusions.  

**BloodHound / SharpHound**

- **Category**: AD Mapping / Post‑Exploitation  
- **Function**: Enumerate and visualise Active Directory relationships to find attack paths.  
- **Criminal Misuse**: Planning lateral movement and privilege escalation in victim domains.  
- **Forensic Indicators**: LDAP/SMB enumeration spikes, BloodHound data files and graph databases, SharpHound collectors on endpoints.  
- **Risk Rating**: **High** – Provides attackers with detailed privilege maps.  

**PowerShell Empire / PowerSploit**

- **Category**: PowerShell‑Based Post‑Exploitation  
- **Function**: Post‑exploitation scripts for persistence, data theft, and lateral movement.  
- **Criminal Misuse**: Fileless or script‑based attacks that evade some AV signatures.  
- **Forensic Indicators**: PowerShell logs (ScriptBlock, Module), encoded command usage, suspicious PowerShell transcripts, artefacts in Windows event logs and memory.  
- **Risk Rating**: **High** – Frequently used in advanced intrusions.  

---

## **Summary**

Across categories, these tools are **dual‑use**: essential in authorised testing, but strongly represented in cybercrime. Forensic analysts should:

* Maintain **signatures and detection rules** for major frameworks and scanners.  
* Correlate **tool artefacts on attacker infrastructure** with **victim‑side logs and pcaps**.  
* Use frameworks like **MITRE ATT&CK** to map observed tool usage to tactics and techniques during investigations.

