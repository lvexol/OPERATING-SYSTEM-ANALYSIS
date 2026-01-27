## **Communication & Encryption Tools Used by Cybercriminals**

Format: **Tool \| Type \| Encryption Method \| Criminal Use \| Forensic Challenges \| Detection Difficulty**

---

### **1. Encrypted Messaging**

**Signal**

- **Type**: Encrypted Messaging (mobile/desktop)  
- **Encryption Method**: Signal Protocol (Double Ratchet, X3DH, pre‑keys), end‑to‑end by default.  
- **Criminal Use**: Secure coordination of operations, exchange of credentials, and planning without server‑side access to content.  
- **Forensic Challenges**: Messages encrypted on server; limited metadata retention; local device stores protected by OS‑level encryption; artefact recovery hinges on physical access and mobile forensics.  
- **Detection Difficulty**: **High** – Network traffic appears as TLS to Signal infrastructure; content inaccessible without device compromise.  

**Telegram**

- **Type**: Messaging Platform  
- **Encryption Method**: MTProto; end‑to‑end only in “Secret Chats”, otherwise server‑client encryption.  
- **Criminal Use**: Running channels for malware distribution, data leaks, fraud markets, and coordination.  
- **Forensic Challenges**: Cloud‑chats stored on Telegram servers (some access may be possible via lawful requests); secret chats are E2EE; usernames/handles often pseudonymous.  
- **Detection Difficulty**: **Medium–High** – Network traffic identifiable; content access depends on cooperation and chat type.  

**Element / Matrix**

- **Type**: Federated Encrypted Messaging (Matrix protocol)  
- **Encryption Method**: Olm/Megolm end‑to‑end encryption for rooms and DMs.  
- **Criminal Use**: Self‑hosted or federated E2EE chat rooms for coordination outside major platforms.  
- **Forensic Challenges**: E2EE rooms store ciphertext on servers; keys live on client devices; self‑hosting complicates legal access.  
- **Detection Difficulty**: **Medium–High** – Domain‑based detection possible, but content locked without keys.  

**Wickr / Session (and similar privacy‑focused messengers)**

- **Type**: Encrypted / Metadata‑Minimising Messengers  
- **Encryption Method**: E2EE with forward secrecy; Session routes over decentralised infrastructure and onion‑style routing.  
- **Criminal Use**: High‑privacy comms with metadata reduction, often cited in criminal forums.  
- **Forensic Challenges**: Short‑lived message retention, local secure storage, and limited central logs; device forensics is primary avenue.  
- **Detection Difficulty**: **High** – Limited metadata and decentralised models reduce visibility.  

---

### **2. Email Encryption**

**PGP/GPG (OpenPGP)**

- **Type**: Email & File Encryption  
- **Encryption Method**: Public‑key cryptography (RSA/EdDSA + symmetric ciphers like AES); web‑of‑trust or keyservers.  
- **Criminal Use**: Encrypting threat emails (ransom notes), key exchanges, and sensitive instructions.  
- **Forensic Challenges**: Encrypted email bodies/attachments unreadable without private keys; keys may be stored on local systems, smart cards, or tokens.  
- **Detection Difficulty**: **Medium** – Encrypted blocks detectable in email content; strong cryptography resists breaking.  

**ProtonMail / Tutanota and Similar Encrypted Email Providers**

- **Type**: Encrypted Email Services  
- **Encryption Method**: End‑to‑end encryption between users of the same service; strong TLS in transit; server‑side encryption at rest.  
- **Criminal Use**: Anonymous or pseudonymous email accounts for extortion, fraud, and coordination.  
- **Forensic Challenges**: Providers based in privacy‑friendly jurisdictions; limited logging; full message content may be inaccessible without user keys.  
- **Detection Difficulty**: **Medium–High** – Domain‑based detection trivial; content recovery dependent on provider cooperation and legal frameworks.  

---

### **3. File Encryption**

**VeraCrypt**

- **Type**: Disk/Volume Encryption  
- **Encryption Method**: AES, Serpent, Twofish and cascades; support for hidden volumes and plausible deniability.  
- **Criminal Use**: Storing stolen data, malware source, and operational docs in encrypted containers.  
- **Forensic Challenges**: Strong cryptography; hidden‑volume feature complicates proof of existence; brute‑forcing strong passphrases infeasible.  
- **Detection Difficulty**: **High** – Containers identifiable by structure, but contents opaque without keys.  

**LUKS / dm‑crypt**

- **Type**: Full‑Disk / Partition Encryption  
- **Encryption Method**: AES‑XTS and others via dm‑crypt, with LUKS headers.  
- **Criminal Use**: Encrypting full systems (e.g., attack workstations, servers holding exfiltrated data).  
- **Forensic Challenges**: Post‑shutdown analysis impossible without keys; live acquisition required to capture decrypted view or keys from RAM.  
- **Detection Difficulty**: **Medium** – Encrypted partitions visible, but contents protected.  

**7‑Zip with Encryption**

- **Type**: Archive & File Encryption  
- **Encryption Method**: AES‑256 in 7z format.  
- **Criminal Use**: Packaging and encrypting exfiltrated data for exfil or sale; layering over other channels (e.g., cloud storage, email).  
- **Forensic Challenges**: Encrypted archives unreadable without password; brute‑force may be possible for weak passwords; archive metadata sometimes helpful.  
- **Detection Difficulty**: **Medium** – Encrypted 7z structures detectable; strength depends on password.  

---

### **4. Steganography**

**Steghide**

- **Type**: Steganography Tool  
- **Encryption Method**: Embeds encrypted data into image/audio files using steganographic techniques plus passphrase‑based crypto.  
- **Criminal Use**: Hiding configuration data, exfiltrated files, or keys in innocuous media to evade DLP and casual inspection.  
- **Forensic Challenges**: Stego objects often visually indistinguishable from normal files; detection requires statistical analysis or known‑cover comparison.  
- **Detection Difficulty**: **High** – Low signal for detection without specific indicators.  

**OpenStego / OutGuess (and similar)**  

- **Type**: Steganography Tools  
- **Encryption Method**: Embeds encrypted payloads into images/other media; may provide integrity checks.  
- **Criminal Use**: Covert communication channels and hidden dead‑drops in public image repositories.  
- **Forensic Challenges**: Similar to Steghide; analysis is resource‑intensive and prone to false positives without strong hypotheses.  
- **Detection Difficulty**: **High**.  

---

### **5. Secure File Transfer**

**OnionShare**

- **Type**: Secure Anonymous File Transfer (over Tor)  
- **Encryption Method**: Tor’s multi‑hop encryption; ephemeral onion services; optional TLS.  
- **Criminal Use**: Sharing stolen data or tools anonymously; setting up anonymous drop sites.  
- **Forensic Challenges**: No central server; transfers occur over Tor; only endpoints see plaintext; minimal server‑side logs.  
- **Detection Difficulty**: **High** – Appears as Tor traffic; onion URLs ephemeral and hard to enumerate.  

**Magic Wormhole**

- **Type**: Encrypted Peer‑to‑Peer File Transfer  
- **Encryption Method**: PAKE‑based key exchange and symmetric encryption; single‑use “wormhole code”.  
- **Criminal Use**: Quickly transferring files between endpoints without persistent infrastructure.  
- **Forensic Challenges**: Minimal residual logs; traffic may resemble generic encrypted connections; requires endpoint artefact analysis.  
- **Detection Difficulty**: **Medium–High**.  

**Resilio Sync / Syncthing (and similar P2P sync tools)**

- **Type**: Encrypted P2P File Synchronisation  
- **Encryption Method**: Encrypted tunnels and distributed metadata; keys per shared folder.  
- **Criminal Use**: Maintaining synchronised repositories of stolen data across multiple compromised or safe‑house systems.  
- **Forensic Challenges**: Encrypted channels, decentralised architecture; artifacts on endpoints (config files, logs) important.  
- **Detection Difficulty**: **Medium–High** – Recognisable protocols, but content protected.  

---

### **6. Encrypted Voice/Video**

**Jitsi (self‑hosted or via public instances)**

- **Type**: Encrypted Voice/Video Conferencing  
- **Encryption Method**: SRTP with DTLS‑SRTP for media; E2EE options in some deployments.  
- **Criminal Use**: Secure voice/video briefings outside mainstream commercial platforms.  
- **Forensic Challenges**: Self‑hosting allows control over logs and retention; media streams encrypted end‑to‑end or hop‑by‑hop.  
- **Detection Difficulty**: **Medium** – Traffic patterns visible; content typically protected.  

**Mumble with Encryption / Other VoIP**

- **Type**: Encrypted VoIP  
- **Encryption Method**: TLS for control, Opus/Speex audio over encrypted channels.  
- **Criminal Use**: Real‑time coordination for gaming‑style ops (e.g., DDoS crews, fraud rings).  
- **Forensic Challenges**: Need access to servers or endpoints for recordings; network‑level monitoring reveals only metadata.  
- **Detection Difficulty**: **Medium**.  

---

## **Summary**

These tools collectively **reduce visibility into communications and stored data**. Forensic and investigative strategies often require:

* **Endpoint device access** (mobile and desktop) for decrypted views and key recovery.  
* **Metadata analysis** (timing, IPs, domains, contact graphs) when content is unavailable.  
* **Provider cooperation** within legal frameworks, especially for encrypted‑email and messaging services.

