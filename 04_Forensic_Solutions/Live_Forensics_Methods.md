## **Live Forensics Acquisition Methods for Privacy‑Focused Operating Systems**

This document outlines **tools, procedures, data targets, network capture practices, and limitations** for live forensics on Linux‑based privacy OSes (Tails, Whonix, Qubes, Parrot, Kali, hardened Ubuntu/Debian, etc.).

---

## **1. Memory Acquisition Tools & Techniques**

### **LiME (Linux Memory Extractor)**

- **Usage & Capabilities**
  - Kernel module designed for **raw memory acquisition on Linux**.  
  - Supports dumping RAM over **TCP** or to a local **file/device**, useful when disks are encrypted.  
  - Works across many Linux kernels when built with appropriate headers; can be used on desktop and server distributions.
- **Considerations on Privacy OSes**
  - On **live‑USB OSes** (Tails, Parrot live), LiME can capture:
    - Encryption keys, Tor circuits, chat contents, open documents.  
  - Loading a kernel module **modifies system state**, which may be challenged in court if not well‑documented.

### **AVML (Azure VM Linux Memory)**

- **Features**
  - Open‑source tool by Microsoft for **acquiring memory from Linux systems**, especially in cloud/VM contexts.  
  - Minimal dependency footprint; generates ELF‑core dumps usable by Volatility and similar tools.
- **Relevance**
  - Useful when privacy‑oriented systems run as **guests in virtualised/cloud environments**.  
  - Acquisition can sometimes be performed from the **hypervisor or host**, reducing contamination of the guest.

### **Volatility & Rekall (for Analysis, Not Acquisition)**

- **Role**
  - **Volatility Framework** and **Rekall** are **post‑acquisition analysis frameworks**.  
  - Once memory is captured, they extract:
    - Process lists, network connections, loaded modules  
    - Encryption keys and in‑memory artefacts  
    - Command histories and injected code.
- **Limitations with Privacy OS**
  - Need appropriate **Linux profiles / symbol tables**; non‑standard kernels may require custom work.  
  - Some artefacts are reduced because privacy OSes minimise logging and caching.

### **Other Linux Memory Tools**

- **fmem, pmem, /dev/crash, dd of /dev/mem** (where available):
  - Provide alternative or legacy ways to capture RAM.  
  - Many modern kernels **restrict /dev/mem and /dev/kmem**, limiting their use.  
- **Hypervisor‑level snapshots**:
  - In Qubes/Whonix or cloud contexts, memory snapshots may be generated from the hypervisor side, avoiding in‑guest tools.

---

## **2. Acquisition Procedures**

### **Step‑by‑Step Live Acquisition Process (High Level)**

1. **Legal and Operational Preparation**
   - Confirm **warrant/authority** explicitly covers live acquisition and potential decryption key collection.  
   - Pre‑plan **roles, tools, and evidence containers**; ensure write‑blocked storage and hash logging.
2. **Scene Securing & Initial Assessment**
   - Immediately **prevent shutdown or sleep** of target devices.  
   - Photograph and document:
     - Screen contents (open apps, chats, documents)  
     - Connected devices and network topology.  
3. **Triage Decision**
   - Decide if live acquisition is:
     - **Necessary** (e.g., encryption keys clearly in use).  
     - **Proportionate and technically feasible** on this OS.  
4. **Memory Acquisition**
   - Use tools like **LiME or AVML** (or hypervisor snapshots) to capture RAM.  
   - Store dumps on **trusted, hashed media**; record exact commands, tool versions, and timestamps.  
5. **Volatile Data Collection**
   - Enumerate:
     - Running processes and services  
     - Open files and network connections  
     - Mounted volumes and encryption mappings  
     - Environment variables and clipboard.  
6. **Graceful Shutdown or Image Capture**
   - After volatile collection, consider:
     - Imaging encrypted disks **while keys may still be in RAM**, or  
     - Performing a controlled shutdown if warranted to preserve integrity.  
7. **Chain of Custody Documentation**
   - Log every action, operator, tool, time, and media ID.  
   - Maintain secure transport and storage of all images and logs.

### **Chain of Custody Considerations**

- Each acquisition:
  - Must be **uniquely identifiable** (hashes, serial numbers).  
  - Should be accompanied by **detailed notes** on environment and commands.  
- Courts scrutinise:
  - Tool reliability, operator competence, and potential for **evidence alteration**.

### **Legal Requirements (Jurisdiction‑Dependent)**

- Some regions require:
  - Explicit warrant language for **memory acquisition** and **live decryption**.  
  - Data‑protection safeguards (segregation of privileged or unrelated data).  
- Failure to meet requirements may:
  - Render evidence inadmissible,  
  - Or expose investigators/agencies to legal risk.

---

## **3. Data to Capture While System Is Live**

### **Core Targets**

- **Running Processes**
  - Process lists, parent/child relationships, command lines.  
  - Identify unknown binaries, obfuscated names, injected processes.

- **Network Connections**
  - Active TCP/UDP connections, listening sockets, routing tables.  
  - Hostnames/IPs for Tor entry/bridges, VPN endpoints, C2 servers.

- **Mounted Filesystems**
  - List of mounted volumes, including **encrypted containers** currently decrypted.  
  - Paths to persistence volumes on USB or VM disks.

- **Loaded Kernel Modules**
  - Identify custom modules (LiME, rootkits, anti‑forensics).  
  - Verify integrity of critical modules.

- **Open Files and Handles**
  - Files currently in use by suspicious processes (logs, wallets, configs, exfiltrated data).  
  - Temporary files in `/tmp`, `/dev/shm`, and RAM disks.

- **Encryption Keys in Memory**
  - LUKS, VeraCrypt, SSH keys, TLS session keys where recoverable.  
  - Critical for decrypting seized volumes and captured traffic.

- **Clipboard Contents & GUI State**
  - Clipboard may hold passwords, URLs, or fragments of conversations.  
  - Screenshots preserve UI with context (chat apps, browser tabs, document titles).

### **Why Live Capture Matters**

- Once the system powers off:
  - **Memory contents are lost** or highly degraded.  
  - Encrypted volumes and sessions revert to **locked states**, often irreversibly without keys.

---

## **4. Network Traffic Capture**

### **Tools: Wireshark, tcpdump, NetworkMiner, etc.**

- **tcpdump**
  - Lightweight CLI tool; ideal for **on‑scene capture** with minimal overhead.  
  - Can capture raw packets for later analysis in Wireshark.

- **Wireshark**
  - Deep interactive analysis of pcaps; protocol decoding, filtering, reconstruction.  
  - Useful for identifying Tor/VPN patterns, C2 traffic, and suspicious flows.

- **NetworkMiner**
  - Passive network sniffer and **forensic analysis tool**; extracts files, credentials, and metadata from pcaps.  
  - Useful in lab environments to reconstruct sessions from captured traffic.

### **What to Capture Even If Encrypted**

- **Metadata still has value** even when payloads are opaque:
  - Source/destination IPs and ports  
  - Timing and volume of connections  
  - Protocol fingerprints and TLS handshakes  
  - SNI and certificate information (when present).

- Particularly important:
  - **Tor/VPN entry/exit nodes**  
  - Repeated connections to known C2 or dark‑web infrastructure  
  - Unusual protocols over common ports (e.g., DNS tunnelling, covert channels).

### **Metadata Analysis Value**

- Enables:
  - Linking suspect devices to specific **service providers or infrastructures**.  
  - Correlating **activity windows** with other evidence (logins, messages).  
  - Identifying **patterns of life** even without content.

### **Connection Pattern Documentation**

- Investigators should:
  - Keep **high‑level connection logs** with timestamps summarising key flows.  
  - Note **anomalies** (e.g., constant Tor traffic, rapid IP hopping).  
  - Preserve pcaps with **cryptographic hashes** for integrity.

---

## **5. Challenges & Limitations of Live Forensics**

### **Evidence Alteration Risks**

- Any interaction with a live system:
  - Changes memory and possibly disk state (new processes, logs, caches).  
  - May trigger **anti‑forensic routines** or booby‑traps (e.g., USBKill‑like behaviour).  
- Mitigation:
  - Use **trusted, tested tools** with known footprints.  
  - Meticulously document all actions and anticipate cross‑examination.

### **Tool Footprint on System**

- Kernel modules, agents, and scripts:
  - Leave entries in process lists, kernel logs, and memory.  
  - Could be misinterpreted as malicious or compromise evidentiary purity.  
- Some privacy OSes may **resist or break** when non‑standard modules/tools are loaded.

### **Legal Admissibility Concerns**

- Courts may question:
  - Reliability of tools on niche OSes  
  - Whether the acquisition was **repeatable and validated**  
  - Scope of data collection vs. warrant and privacy protections.  
- Agencies need:
  - **Policies and validation studies** for live tools on Linux/privacy OSes.

### **Practical Time Constraints**

- On‑scene conditions:
  - Limited time before users can trigger shutdown or self‑destruct.  
  - Network‑connected devices may receive remote wipe commands.  
- Teams must:
  - Work from **predefined playbooks**,  
  - Prioritise **high‑value volatile artefacts**,  
  - Accept that some data will remain inaccessible.

---

## **Key Takeaways**

- Live forensics is often **the only viable route** to meaningful evidence on privacy‑focused OSes.  
- Success depends on:
  - **Rapid, well‑authorised intervention**,  
  - **Appropriate Linux‑compatible tools**,  
  - And **rigorous documentation** to preserve evidentiary value.  
- Ongoing research and training are essential to keep pace with evolving privacy technologies and to ensure live methods remain both **effective and legally defensible**.

