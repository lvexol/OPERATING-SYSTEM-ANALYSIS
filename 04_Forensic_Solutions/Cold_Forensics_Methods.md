## **Cold Forensics & Physical Analysis for Privacy‑Focused Systems**

This document covers **post‑shutdown (“cold”) forensic techniques** for systems using privacy‑focused OSes and strong encryption.

---

## **1. Physical Disk Imaging**

### **Write‑Blocking Hardware and Methods**

- Use **hardware write blockers** (SATA/USB/PCIe blockers) whenever imaging drives to:
  - Prevent any writes to evidence media.  
  - Preserve original state for potential re‑imaging and verification.  
- For NVMe and other newer interfaces:
  - Use compatible write‑blocking solutions or **forensic bridges**.  
  - Confirm with tool diagnostics that the drive is mounted read‑only.

### **Imaging Tools**

- **FTK Imager**
  - GUI and CLI tools for creating forensic images (E01/RAW) of disks and removable media.  
  - Supports hashing (MD5/SHA‑1/SHA‑256) and integrity verification.  
- **dd / dc3dd**
  - Command‑line tools on Linux/Unix to create **bit‑for‑bit copies** (`dd if=/dev/sdX of=image.dd`).  
  - `dc3dd` adds hash and logging features tailored to forensics.  
- **Guymager**
  - Open‑source GUI imager for Linux, supports multiple hash algorithms and parallel imaging.  

### **Hashing and Verification**

- For each image:
  - Calculate **cryptographic hashes** (at least SHA‑256; sometimes multiple).  
  - Record hashes in case notes and evidence logs.  
  - Re‑hash images after transfers or copying to confirm **no alteration**.

### **Legal Chain of Custody**

- Maintain detailed records:
  - Who seized the device, when, and where.  
  - Serial numbers, make/model, and condition of media.  
  - Hash values, imaging start/end times, and tools used.  
- Use **tamper‑evident seals** and controlled storage for original media.

---

## **2. Persistence Volume Analysis**

### **Tails Encrypted Persistence**

- Tails persistence appears as:
  - An **encrypted LUKS partition** on the USB device.  
  - Only mounted when the correct passphrase is provided at boot.  
- If keys are unavailable:
  - Offline attacks against strong passphrases are generally infeasible.  
  - Focus shifts to **RAM captures** taken while persistence was mounted, or to **user disclosure** via legal means.

### **Decryption Approaches (If Possible)**

- **Known keys or passphrases**:
  - From RAM dumps, password reuse, or seized notes/password managers.  
- **Key material in memory**:
  - Retrieved via live forensics before shutdown (LiME, etc.).  
- **Brute‑force / dictionary attacks**:
  - Only realistic for **weak passwords** or where partial information is known.

### **What Criminals Store in Persistence**

- Often includes:
  - Cryptocurrency wallets and keys  
  - Encrypted documents and archives  
  - Tool configurations and scripts  
  - Contact lists and OPSEC notes  
- Successful decryption can therefore reveal **high‑value evidence** of operations and identities.

### **Recovery Techniques**

- Once decrypted and mounted in a lab environment:
  - Use standard forensic tools (Autopsy/Sleuth Kit, X‑Ways, etc.) to:
    - Examine file systems and logs  
    - Recover deleted items (subject to secure‑deletion tools)  
    - Build activity timelines within the volume.

---

## **3. Physical RAM Analysis**

### **Cold Boot Attacks – Feasibility and Methods**

- After power‑off, RAM retains data briefly due to capacitor charge:
  - Cold‑boot attacks exploit this to recover **encryption keys and artefacts**.  
- Practical steps:
  - Power‑cycle quickly and boot into a minimal acquisition environment.  
  - Or move RAM modules to a prepared system while keeping them cooled.  
- Modern limitations:
  - Faster DRAM decay and firmware countermeasures  
  - ECC and memory encryption support on some platforms.

### **RAM Decay Rates and Timing**

- Decay depends on:
  - Temperature (cooler RAM retains charge longer)  
  - DRAM generation and module design  
- Windows of opportunity:
  - Often **seconds to a few minutes** at most; real‑world success is highly situation‑dependent.

### **Tools for Physical RAM Extraction**

- Custom boot environments and research‑grade tools designed for:
  - Dumping RAM immediately after reboot  
  - Minimising further writes.  
- Some academic tools are experimental and may not be robust enough for production use.

### **Success Rates and Limitations**

- Highly variable; more feasible in **controlled lab experiments** than chaotic field operations.  
- Not all courts may accept such evidence without strong validation and documentation.  
- Many privacy OS users now operate on devices where **full memory encryption** may be present, further reducing feasibility.

---

## **4. Hidden Data Locations**

### **Swap Files and Hibernation Files**

- Privacy‑focused OSes often:
  - Disable or encrypt swap and hibernation.  
  - Nevertheless, misconfigurations may still leave:
    - **Swap partitions** or `swapfile` entries  
    - Hibernation files containing memory snapshots.  
- Examiners should:
  - Identify and image these areas  
  - Use memory‑forensics tools to parse their contents where not encrypted.

### **Unallocated Space Analysis**

- Even on encrypted systems, once decrypted volumes are accessible:
  - **Unallocated clusters** may contain remnants of deleted files.  
  - Carving tools (Foremost, Scalpel, PhotoRec) can retrieve:
    - Fragments of documents, images, databases, etc.  
- Secure deletion and TRIM on SSDs reduce artefact density but do not guarantee total erasure.

### **Shadow Copies or Backups**

- On hybrid environments (dual‑boot, virtualised, or misconfigured):
  - Windows restore points, macOS Time Machine, or Linux snapshots (btrfs, LVM) may exist.  
- These often contain:
  - Older versions of files  
  - Logs and configuration states with richer artefacts.

### **External Media Examination**

- USB drives, SD cards, external HDDs:
  - May store Tails/Whonix images, persistence volumes, or exfiltrated data.  
  - Require separate imaging and analysis with the same rigour as main system disks.

---

## **5. Firmware & BIOS Analysis**

### **Boot Sequence Examination**

- Review firmware settings to identify:
  - **Boot order** (USB first? network? internal disk?)  
  - Evidence that the system was configured for **live‑USB use**.  
- Some devices log:
  - Recent boot devices  
  - Firmware events relevant to forensic timelines.

### **USB Boot Detection**

- BIOS/UEFI logs or security modules (e.g., some enterprise platforms) can reveal:
  - Attempts to boot from removable media  
  - Warnings or audit logs for unauthorised boot changes.  
- These can corroborate use of **amnesic OSes** in investigations.

### **Firmware‑Level Artifacts**

- Advanced attackers may:
  - Install malicious firmware or UEFI rootkits  
  - Modify option ROMs or embedded controllers.  
- Detection requires:
  - Firmware dumping and comparison against known‑good images  
  - Specialised tools (chip programmers, vendor utilities, Binwalk, UEFITool).

---

## **Key Points for Cold Forensics on Privacy OSes**

- Once devices are **powered down and encrypted**, opportunities are limited primarily to:
  - **Thorough imaging** of all storage and firmware components  
  - **Password/key recovery** via other evidence sources  
  - Exploiting misconfigurations (unencrypted swap, forgotten backups, external media).  
- Cold forensics remains essential but must be combined with:
  - **Live‑response capabilities**,  
  - Robust **network and cloud logging**,  
  - And **cross‑device correlation** to compensate for the deliberate absence of local artefacts.

