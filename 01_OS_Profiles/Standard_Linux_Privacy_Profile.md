This profile summarises how **standard Linux distributions (Ubuntu, Debian, etc.)** are commonly **hardened and modified with privacy tools**, based on your existing `standard-linux-privacy-profile.md`, but structured to match your OS‑profile template.

---

## **1. COMMON PRIVACY MODIFICATIONS**

### **Privacy Tools Added to Standard Linux**

Attackers and privacy‑focused users often turn a regular Ubuntu/Debian install into a “home‑grown privacy OS” by adding:

* **Tor Browser / tor daemon** – for anonymized browsing and onion service access. ([PubMed][1])  
* **VPN clients** – ProtonVPN, Mullvad, etc., to mask public IPs and chain with Tor. ([sechub.in][2])  
* **Strong encryption utilities** – VeraCrypt/TrueCrypt derivatives, LUKS/dm‑crypt, GnuPG for files and email. ([DIVA][3])  
* **MAC and IP spoofing tools** – such as `macchanger`, custom iptables rules, and spoofed DNS. ([abstru.de][4])  
* **Steganography and deniable filesystems** – e.g., Shufflecake‑style research prototypes and tools embedding data in media. ([arXiv][5])

### **Configuration Changes for Anonymity**

Common system‑level changes include:

* Forcing all traffic through **Tor and/or VPN** with firewall rules that drop non‑tunneled traffic.  
* Enabling **DNS over Tor/DNSCrypt** to reduce DNS leaks.  
* Using **sandboxing frameworks** (Firejail, AppArmor/SELinux hardening) to contain high‑risk apps. ([Wikipedia][6])  
* Modifying SSH, syslog, and auditd settings to reduce or remove logs.  
* Booting from **encrypted disks** and disabling swap or configuring encrypted swap to minimise clear‑text artefacts.

### **Common Hardening Practices (Dual Use)**

Legitimate hardening steps that can become anti‑forensic when abused:

* **Aggressive log rotation or log disabling**, leaving few traces of logins and commands. ([Springer][7])  
* **File timestamp manipulation** (changing `atime`, `mtime`, `ctime`) to obfuscate activity.  
* **Use of tmpfs and RAM‑backed locations** for sensitive workloads so data never touches disk.  
* Regular **secure wiping of temp directories, cache, and browser storage**. ([hashimtech][8])

---

## **2. TOOLS TYPICALLY ADDED**

### **Tor Installation and System‑Wide Routing**

* Installation of `tor` and Tor Browser from official repos or project site.  
* System‑wide transparent Tor gateways created via `iptables` redirection, similar in spirit to Whonix/Tails but manually configured. ([PubMed][1])

### **VPN Clients**

* OpenVPN, WireGuard, or proprietary clients (ProtonVPN, Mullvad, NordVPN).  
* Config files, keys, and routing policies usually stored under `/etc/openvpn/`, `/etc/wireguard/`, or application‑specific directories.

### **Encryption Tools**

* **VeraCrypt** – multi‑platform volumes and hidden volumes for plausible deniability. ([DIVA][3])  
* **LUKS/dm‑crypt** – full‑disk or partition encryption on Linux.  
* **GPG** – for email/file encryption and signing; commonly integrated into mail clients or command‑line workflows.

### **Anti‑Forensic and Secure‑Deletion Tools**

* `shred`, `wipe`, and similar tools to overwrite file contents and unallocated space.  
* **USBKill** or scripts that power down/erase systems when unexpected devices are plugged in. ([USBKill][9])  
* Log‑cleaner scripts that purge shell history, auth logs, and application logs. ([Springer][7])

### **Secure Deletion Utilities**

* Tools to wipe:
  * Individual files and directories  
  * Free space and swap  
  * Removable media before reuse or disposal. ([hashimtech][8])

---

## **3. CRIMINAL USE CASES**

### **Why Criminals Use Modified Standard Linux**

Compared with “out‑of‑the‑box” privacy OSes:

* **Persistence:** Full install allows long‑term use and customisation while retaining anonymity tooling.  
* **Flexibility:** Attackers can pick exactly which tools and configurations they want, mixing offensive, privacy and anti‑forensic utilities.  
* **Blending in:** A hardened Ubuntu server or workstation may attract less attention than obviously using a niche privacy distro.

Use cases described in research and law‑enforcement commentary include:

* Running **C2 servers, hidden services, or drop sites** on hardened Linux boxes.  
* Conducting **fraud, phishing, and ransomware operations** from anonymised workstations.  
* Maintaining **long‑lived encrypted repositories** of stolen data on servers or removable drives.

### **Persistence and Customisation Benefits**

* Persistent Linux installs make it easy to maintain **automated jobs (cron)** that:
  * Periodically wipe logs  
  * Rotate keys  
  * Sync exfiltrated data to off‑site storage  
* Criminals can also load **specialised kernels, rootkits, and monitoring/anti‑monitoring tools** not typically present on live privacy OSes.

---

## **4. FORENSIC CONSIDERATIONS**

### **Identifying Privacy Modifications**

Investigators should:

* Enumerate installed packages for **Tor, VPN clients, MAC spoofers, steganography tools, and secure deletion utilities** (`dpkg -l`, `rpm -qa`).  
* Inspect **firewall and routing rules** (`iptables`, `nftables`, `ufw`, `firewalld`) for forced tunnel routing.  
* Review **systemd units and cron jobs** for scripts that:
  * Start anonymisation or VPN services at boot  
  * Periodically clean or overwrite logs.  
* Look for evidence of **encrypted volumes** (LUKS headers, VeraCrypt containers) and unexplained partitions.

### **Artifacts from Privacy Tools**

Even privacy tooling leaves traces:

* Tor Browser’s profile and cache (if not carefully wiped) – SQLite databases, cookies, downloads. ([PubMed][1])  
* VPN config directories and log files – show provider, endpoints, and keys.  
* `iptables` rules and system logs indicating **Tor/VPN bootstrap and connections**.  
* Error logs from failed anonymisation attempts or misconfigurations.

### **Analysis Strategies**

Effective strategies documented in forensic research include: ([Springer][7]; [MDPI][10])

1. **Comprehensive disk imaging** and analysis of all partitions (including LVM, LUKS and hidden volumes).  
2. **Config triage** – focus on `/etc`, user home directories, and `.config` for anonymisation and encryption tooling.  
3. **Memory acquisition and analysis** – recover running Tor/VPN processes, encryption keys, and decrypted plaintext.  
4. **Cross‑correlation** – match host artefacts with external network logs or OSINT on VPN/Tor exit nodes and service providers.

---

## **SELECTED SOURCES**

* [1]: https://pubmed.ncbi.nlm.nih.gov/30959401/ "Forensic Analysis of Tor Browser"  
* [2]: https://sechub.in/view/2947210 "OSINT: User Privacy in Linux"  
* [3]: https://www.diva-portal.org/smash/get/diva2%3A1870670/FULLTEXT02.pdf "Master’s thesis on encrypted storage"  
* [4]: https://abstru.de/opsec-anonymity.html "OPSEC & Anonymity – abstru.de"  
* [5]: https://arxiv.org/abs/2310.04589 "Shufflecake: Plausible Deniability for Multiple Hidden Filesystems"  
* [6]: https://en.wikipedia.org/wiki/Linux_Kodachi "Linux Kodachi – privacy‑enhanced Ubuntu derivative"  
* [7]: https://link.springer.com/10.1007/s10207-025-01131-y "Countering anti‑forensic tactics – literature review"  
* [8]: https://www.hashimtech.com/blogs/anti-forensics "Anti‑Forensics overview"  
* [9]: https://en.wikipedia.org/wiki/USBKill "USBKill – anti‑forensic kill‑switch"  
* [10]: https://www.mdpi.com/2076-3417/14/12/5302 "Systematic Review: Anti‑Forensic Computer Techniques"

