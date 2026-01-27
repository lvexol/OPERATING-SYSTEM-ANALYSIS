## **Memory & Artifact Analysis for Privacy‑Focused Systems**

This document covers **memory‑centric forensics**, recoverable artefacts, disk analysis when persistence exists, network artefact analysis, and cross‑correlation strategies.

---

## **1. Volatility Framework Usage (Linux & Privacy OSes)**

### **Linux Memory Analysis Plugins**

- **Core capabilities**:
  - Enumerate **processes and threads** (`linux_pslist`, `linux_pstree`).  
  - List **open files, sockets, and network connections** (`linux_lsof`, `linux_netstat`).  
  - Inspect **loaded kernel modules** (`linux_lsmod`).  
  - Extract **bash histories, environment variables, and command lines** (`linux_bash`, `linux_cmdline`).  
  - Dump **process memory** and specific regions for deeper manual analysis.  
- Requires appropriate **symbol files / profiles** for the target kernel; custom or hardened kernels may require manual profile generation.

### **What Can Be Extracted**

- **Processes & Services**
  - Running attack tools, anonymisation daemons (Tor, VPN clients), C2 agents.  
- **Network Connections**
  - Live Tor circuits, VPN tunnels, SSH sessions.  
- **Keys and Credentials**
  - Disk encryption keys (LUKS, VeraCrypt), SSH keys, cached passwords.  
- **Commands and Scripts**
  - In‑memory bash histories, command lines, scripts being executed.  
- **User Data**
  - Decrypted documents, chat fragments, browser contents, clipboard data.

### **Step‑by‑Step Analysis Workflow**

1. **Verify Image Integrity**
   - Confirm hashes of the RAM dump; record acquisition details.  
2. **Identify OS and Kernel Version**
   - Use Volatility plugins to detect Linux distro, kernel, and build.  
3. **Load Appropriate Profile / Symbols**
   - Use existing Linux profiles or generate new ones for hardened kernels.  
4. **Baseline Enumeration**
   - Run process, network, and module listing plugins to get a high‑level view.  
5. **Focused Queries**
   - Target suspicious processes and connections; dump their memory regions.  
6. **Key Hunting**
   - Apply plugins and signatures to search for **crypto keys and passwords**.  
7. **Reporting & Correlation**
   - Document findings and correlate with disk, network, and external logs.

### **Limitations with Privacy OS**

- Reduced logging and ephemeral sessions mean:
  - Less structured data (e.g., small or non‑existent log buffers, minimal caches).  
- Custom kernels (e.g., hardened, Xen‑based in Qubes) may not have readily available profiles, increasing upfront work.  
- Anti‑forensic measures may attempt to overwrite memory or encrypt in‑RAM structures, though this remains uncommon.

---

## **2. Recoverable Artifacts from Memory**

### **Encryption Keys**

- RAM captures often contain:
  - **LUKS master keys** and passphrases in transformed form.  
  - **VeraCrypt/TrueCrypt keys** for mounted containers.  
  - **TLS session keys**, SSH private keys, and agent data.  
- Recovering these enables:
  - Decryption of disk images and network captures that would otherwise remain opaque.

### **Tor Circuits and Connections**

- Memory may reveal:
  - Tor process state, including **guard and exit node information**.  
  - Configuration details (bridges, pluggable transports).  
- Helpful for:
  - Correlating with **network‑level observations** and known Tor infrastructure.

### **Recently Used Commands**

- Plugins can reconstruct:
  - **Shell command histories** lingering in memory, even if not saved to disk.  
  - Command lines for active and recently‑terminated processes.  
- Provides insight into:
  - Tools installed/executed, attack scripts, and anti‑forensic operations.

### **Open Documents / Files**

- Decrypted content of:
  - Text documents, spreadsheets, PDFs, configuration files.  
  - Partial or full reconstruction possible from process memory.  
- Critical for:
  - Capturing **what the suspect was working on** at time of seizure.

### **Chat Conversations & Messaging**

- In‑memory buffers of:
  - Encrypted chat clients (Signal desktop, Matrix clients, XMPP with OTR/OMEMO) often hold plaintext while in use.  
- Even when E2EE prevents server‑side access, RAM can reveal:
  - Recent messages, contact names, and conversation threads.

### **Clipboard Data**

- Clipboard contents:
  - Often stored in or accessible via GUI process memory.  
- May contain:
  - Passwords, URLs, cryptocurrency addresses, or fragments of sensitive text.

### **SSH Keys and Sessions**

- SSH agents and processes store:
  - **Private keys** and session state in memory.  
- Captured dumps can:
  - Reveal keys for further infrastructure, enabling pivot analysis (with strict legal controls).

---

## **3. Disk Artifact Analysis (When Persistence is Used)**

### **File System Analysis Tools**

- **Autopsy / The Sleuth Kit**
  - Parse file systems (ext4, NTFS, FAT, etc.).  
  - Recover deleted files, build timelines, and search artefacts.  
- **X‑Ways / EnCase / Magnet AXIOM**
  - Commercial suites with deep parsers and automation; useful once encrypted volumes are decrypted.

### **Deleted File Recovery**

- On decrypted, non‑securely wiped volumes:
  - File system metadata and unallocated space can yield deleted content.  
- Secure‑deletion tools may significantly reduce recoverability, but partial artefacts sometimes remain in:
  - Journal areas, slack space, or older snapshots.

### **Timeline Analysis**

- Tools like **Plaso/log2timeline**:
  - Correlate events from multiple artefact sources (files, logs, browser data) to reconstruct activity.  
- On privacy OSes:
  - Timelines may be **sparse**, but can still reveal:
    - Use of encrypted containers,  
    - Instances of tool execution,  
    - Mount/unmount events and USB usage.

### **File Carving Techniques**

- Tools like **Foremost, Scalpel, PhotoRec**:
  - Recover files by scanning raw data for known headers/footers.  
- Useful when:
  - File system structures are damaged,  
  - Or after partial overwrites where remnants remain.

---

## **4. Network Artifact Analysis**

### **PCAP File Analysis**

- Use **Wireshark, NetworkMiner, Zeek** on captured pcaps to examine:
  - Connection patterns and protocol use.  
  - HTTP headers, DNS requests, TLS handshakes, and Tor/VPN usage.  
- Even with encrypted payloads, these artefacts support:
  - Attribution, infrastructure mapping, and timing correlation.

### **Connection Patterns Even with Tor**

- Tor traffic characteristics:
  - Connections to known guard/bridge IPs.  
  - Long‑lived TCP sessions, specific port distributions.  
- Analysts can:
  - Confirm Tor use,  
  - Link usage periods to endpoint activity (e.g., when certain qubes/VMs were active in Qubes OS).

### **Timing Correlations**

- By comparing:
  - Network timestamps with disk and memory artefacts,  
  - Investigators can infer when:
    - Particular tools were in operation  
    - Exfiltration or C2 sessions occurred.

### **Protocol Fingerprinting**

- Even with encryption, protocols often have:
  - Distinctive handshake patterns, packet sizes, and timing.  
- Zeek and similar tools can:
  - Generate high‑level logs and alerts for suspicious or covert protocols (e.g., DNS tunnelling, custom C2).

---

## **5. Cross‑Correlation Techniques**

### **Matching Memory to Disk Artifacts**

- Use memory findings to guide disk analysis:
  - Process paths and filenames → locate corresponding binaries and configs on disk.  
  - In‑memory encryption keys → decrypt captured disk images.  
  - Open documents → search for stored or deleted versions.

### **Timeline Synchronisation**

- Combine:
  - Memory acquisition time,  
  - File timestamps,  
  - Network logs,  
  - And external service logs,  
  to build a coherent **chronology of events**.  
- This can compensate for missing local logs, especially on privacy OSes.

### **Multi‑Source Evidence Correlation**

- Integrate artefacts from:
  - Endpoints (RAM, disk)  
  - Network infrastructure (firewalls, routers, VPN logs)  
  - Cloud services and communication providers.  
- Aim to answer:
  - **Who did what, when, from where, and against which targets?**

---

## **Key Takeaways**

- Memory analysis is **central** to investigations involving privacy‑focused systems: it is often the only place where decrypted data and keys coexist.  
- When persistence is used, traditional disk forensics regains importance, but results remain constrained by encryption and anti‑forensics.  
- Effective investigations rely on **cross‑correlating memory, disk, and network artefacts**, supported by well‑validated tools (Volatility, Sleuth Kit, Wireshark, Zeek, etc.) and rigorous documentation.

