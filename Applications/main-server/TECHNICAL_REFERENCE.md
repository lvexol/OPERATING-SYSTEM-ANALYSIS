# Main Server — Technical Reference

## Overview

**Main Server** is a browser-side Command & Control (C2) framework (Browser Exploitation Framework). It hooks target browsers via an injected JavaScript snippet and allows remote control through a web admin panel or REST API.

- Version: `0.6.0.0`
- Language: Ruby (server-side), JavaScript (client-side hook)
- Database: SQLite 3 (via ActiveRecord ORM)
- Web framework: Sinatra 4.x on Thin/EventMachine
- Architecture: Event-driven, async I/O via EventMachine

---

## Architecture

```
Admin Panel / REST API
        |
    Sinatra (Thin HTTP server, port 3000)
        |
    EventMachine (async I/O)
        |
    SQLite (server.db) — sessions, commands, results, logs
        |
    hook.js (XHR polling / WebSocket) ←→ Hooked Browser
```

### Core Components

| Path | Role |
|------|------|
| `server` | Entry point — loads all core, extensions, modules |
| `core/main/server.rb` | Main server class, starts Thin/EM |
| `core/main/configuration.rb` | Parses and exposes `config.yaml` |
| `core/main/router/` | Route registration for HTTP handlers |
| `core/main/handlers/` | HTTP request handlers (hook, API, static) |
| `core/main/models/` | ActiveRecord models (HookedBrowser, Command, Log…) |
| `core/main/rest/` | REST API endpoint implementations |
| `core/main/client/` | Source for `hook.js` — the browser-side agent |
| `core/main/autorun_engine/` | Autorun Rule Engine (ARE) |
| `core/main/network_stack/` | Network utilities (CORS, DNS, WebRTC helpers) |
| `core/main/crypto.rb` | Token generation and crypto helpers |
| `core/api.rb` | Plugin/hook registration API for extensions |
| `core/loader.rb` | Gem and dependency loader |

### Extension Components

| Extension | Port / Path | Function |
|-----------|-------------|----------|
| `admin_ui` | `/ui/panel` | Web-based operator dashboard |
| `proxy` | `127.0.0.1:6789` | HTTP tunneling through hooked browser |
| `network` | — | LAN discovery + vis.js network graph |
| `xssrays` | — | Automated reflected XSS scanner |
| `evasion` | — | hook.js obfuscation (minify → Base64 → whitespace) |
| `metasploit` | `127.0.0.1:55552` | Metasploit RPC bridge |
| `social_engineering` | — | Web cloner with auto-hook injection |
| `webrtc` | — | Real IP extraction via STUN leak |
| `notifications` | — | New-hook alerts (email, Slack, Pushover, ntfy) |
| `dns_rebinding` | — | DNS rebinding to bypass Same-Origin Policy |
| `events` | — | Internal event logging bus |

---

## Technology Stack

### Server-Side (Ruby)

| Gem | Version | Purpose |
|-----|---------|---------|
| `sinatra` | ~4.1 | HTTP routing / controllers |
| `thin` | ~2.0 | Rack-compatible web server |
| `eventmachine` | ~1.2.7 | Async I/O event loop |
| `em-websocket` | ~0.5.3 | WebSocket server |
| `activerecord` | ~8.0 | ORM for SQLite |
| `sqlite3` | ~2.7 | Database driver |
| `rack` | ~3.2 | Middleware stack |
| `rack-protection` | ~4.2.1 | CSRF / security middleware |
| `uglifier` | ~4.2 | JS minification (evasion) |
| `execjs` | ~2.10 | Run JS from Ruby (module processing) |
| `rubyzip` | ~3.2 | ZIP handling |
| `erubis` | ~2.7 | ERB templating |
| `maxmind-db` | ~1.3 | GeoIP lookups (optional) |
| `msfrpc-client` | ~1.1 | Metasploit RPC (optional) |
| `async-dns` | ~1.4 | DNS rebinding extension (optional) |

### Client-Side (JavaScript)

The hook (`hook.js`) runs entirely in the browser:

- **Transport:** XHR polling (default, 1000 ms interval) or WebSocket (`port 61985`)
- **Session tracking:** Cookie `SERVERHOOK`
- **Module execution:** `eval()` of server-returned JS payloads
- **Data exfiltration:** XHR POST back to `http://SERVER:3000/`

---

## Communication Flow

```
1. Browser loads hook.js
2. hook.js sends initial fingerprint (UA, OS, platform, cookies…)
3. Server creates HookedBrowser record in SQLite
4. Browser polls /hook_receiver every 1s (or opens WS)
5. Operator sends module → server queues Command in DB
6. Browser receives command in next poll response
7. Browser eval()s JS payload, captures result
8. Browser POSTs result back → server stores in DB
9. Admin panel displays result
```

---

## Database Schema (SQLite — `server.db`)

Key tables managed by ActiveRecord:

| Table | Contents |
|-------|----------|
| `hooked_browsers` | Session ID, IP, UA, OS, platform, fingerprint data |
| `commands` | Queued / executed modules per browser (status, JS payload) |
| `command_results` | Module output, execution timestamp |
| `logs` | Per-browser event log |
| `network_hosts` | LAN hosts discovered via network extension |
| `network_services` | Open ports/services per discovered host |

Migrations live in `core/main/ar-migrations/`.

---

## REST API

**Base:** `http://HOST:3000/api`  
**Auth:** POST `/api/admin/login` → returns bearer token; append `?token=TOKEN` to all calls.

### Endpoint Summary

| Method | Path | Action |
|--------|------|--------|
| POST | `/api/admin/login` | Authenticate, get token |
| GET | `/api/hooked_browsers` | List online browsers |
| GET | `/api/hooked_browsers/all` | All browsers (online + offline) |
| GET | `/api/hooked_browsers/:id` | Full browser details |
| GET | `/api/modules` | List all 206 modules |
| GET | `/api/modules/:mod_id` | Module info + parameters |
| POST | `/api/modules/:hb/:mod_id` | Execute module on one browser |
| GET | `/api/modules/:hb/:mod_id/:cmd_id` | Get execution result |
| POST | `/api/modules/multi_browser` | Execute module on multiple browsers |
| POST | `/api/modules/multi_module` | Execute multiple modules on one browser |
| GET | `/api/logs` | All logs |
| GET | `/api/logs/:hb` | Logs for specific browser |
| POST | `/api/server/bind` | Mount a file for HTTP delivery |
| GET | `/api/server/version` | Framework version |
| GET/POST/PATCH/DELETE | `/api/autorun_engine/…` | CRUD + run autorun rules |

---

## Module System

206 modules, each a `.rb` file defining:
- Module metadata (name, description, category, options)
- JavaScript payload string executed in the hooked browser
- Return value parsing logic

### Categories

| Category | Path | Count |
|----------|------|-------|
| Browser fingerprinting | `modules/browser/` | 31 |
| Host enumeration | `modules/host/` | 25 |
| Network reconnaissance | `modules/network/` | 23 |
| Social engineering | `modules/social_engineering/` | 24 |
| Exploits | `modules/exploits/` | 40 |
| Persistence | `modules/persistence/` | 8 |
| PhoneGap/Cordova | `modules/phonegap/` | 16 |
| Miscellaneous | `modules/misc/` | 13 |
| Inter-protocol (IPEC) | `modules/ipec/` | 10 |
| Chrome extensions | `modules/chrome_extensions/` | 6 |
| Metasploit bridge | `modules/metasploit/` | 1 |
| Debug/testing | `modules/debug/` | 9 |

---

## Autorun Rule Engine (ARE)

Automatically executes module chains against every new hooked browser.

Rules are JSON files in `arerules/`. Key fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Display name |
| `browser` | string | Filter: `FF`, `C`, `IE`, `S`, `all` |
| `modules` | array | Ordered module execution steps |
| `modules[].condition` | JS expr | Gate: `null` = always run; `status==1` = only if previous succeeded |
| `modules[].code` | JS | Transform previous output before passing to next module |
| `modules[].options` | object | Module params; `<<mod_input>>` injects computed value |
| `execution_order` | array | Index order of module execution |
| `execution_delay` | array | Per-step delay in milliseconds |
| `chain_mode` | string | `sequential` (fire-and-forget) or `nested-forward` (wait for result) |

Previous module output accessible as: `<module_name>_mod_output`

Nested-forward polling: every `300ms`, timeout after `5000ms` (both configurable).

---

## Configuration (`config.yaml`)

### Key Settings

| Key | Default | Notes |
|-----|---------|-------|
| `server.credentials.user` | `server` | Admin login username |
| `server.credentials.passwd` | `server1337` | **Change before deploying** |
| `server.http.host` | `0.0.0.0` | Bind address |
| `server.http.port` | `3000` | HTTP port |
| `server.http.xhr_poll_timeout` | `1000` ms | Hook polling interval |
| `server.http.websocket.enable` | `false` | Enable WS instead of XHR |
| `server.http.websocket.port` | `61985` | WebSocket port |
| `server.http.https.enable` | `false` | TLS on/off |
| `server.restrictions.permitted_ui_subnet` | `0.0.0.0/0` | IPs allowed on admin panel |
| `server.restrictions.permitted_hooking_subnet` | `0.0.0.0/0` | IPs that can be hooked |
| `server.database.file` | `server.db` | SQLite file path |
| `server.geoip.enable` | `false` | GeoIP lookups |
| `server.autorun.result_poll_interval` | `300` ms | ARE nested-forward poll rate |
| `server.autorun.result_poll_timeout` | `5000` ms | ARE max wait per step |

---

## Network Ports

| Port | Protocol | Service |
|------|----------|---------|
| 3000 | HTTP(S) | Main server (hook serving, admin UI, REST API) |
| 61985 | WS | WebSocket hook channel (if enabled) |
| 61986 | WSS | Secure WebSocket (if HTTPS + WS enabled) |
| 6789 | HTTP | Proxy extension (tunnels traffic through hooked browser) |

---

## Security Notes

- Default credentials (`server:server1337`) must be changed before any deployment.
- `permitted_ui_subnet` should be locked to operator IPs in production.
- `allow_reverse_proxy: true` causes the server to trust `X-Forwarded-For` — only enable when actually behind a trusted reverse proxy.
- HTTPS uses self-signed certs by default (`server_cert.pem` / `server_key.pem`).
- Evasion extension applies JS obfuscation to the hook payload: minify → Base64-encode → whitespace encode.

---

## Dependencies Summary

- **Ruby** 3.0+ (tested on 3.2.x)
- **SQLite** 3.x (`libsqlite3-dev`)
- **Node.js** 10+ (only for JS tooling / docs)
- **GeoIP** (optional): `libmaxminddb-dev` + MaxMind GeoLite2-City database
- **Metasploit** (optional): running with `msgrpc` loaded
- All Ruby gems are vendored locally in `vendor/bundle/` — no system-wide installation required after initial setup.
