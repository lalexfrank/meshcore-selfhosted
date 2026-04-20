# MeshCore Self-Hosted

Self-hosted Docker container for the [MeshCore](https://meshcore.nz) web application.

Automatically downloads the latest MeshCore web release on startup and checks for updates hourly.

## Quick Start

```bash
docker-compose up -d
```

Access at `http://localhost:7171`

## Connection Methods

### USB (No HTTPS required)
Plug your MeshCore companion radio into your Unraid server via USB and connect directly in Chrome/Edge over HTTP. This is the simplest setup and works without any additional configuration.

### Bluetooth (HTTPS required)
Bluetooth requires a secure context (HTTPS) in the browser. You must put this container behind a reverse proxy with a valid SSL certificate. Options:

- **Cloudflare Tunnel** — Easiest. Create a tunnel pointing to `localhost:7171` and you get HTTPS automatically with no port forwarding needed.
- **Nginx Proxy Manager** — GUI-based reverse proxy, available in Unraid Community Applications.
- **Caddy** — Minimal config, auto-handles Let's Encrypt certificates.

> **Note:** Your MeshCore companion radio must be flashed with BLE companion firmware to use Bluetooth. USB serial and BLE are separate firmware builds — you can only use one at a time.

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `TZ` | `UTC` | Timezone |
| `MESHCORE_BASE_URL` | `https://files.liamcottle.net/MeshCore` | Base URL for releases |
| `MESHCORE_VERSION` | (latest) | Pin to a specific version e.g. `v1.43.0`. If set, auto-updates are disabled. |
| `UPDATE_INTERVAL` | `3600` | How often to check for updates in seconds (default: 1 hour) |

## Auto-Updates

The container checks for a new MeshCore release every `UPDATE_INTERVAL` seconds. When a new version is found it downloads and replaces the web files in place — nginx serves the new version immediately without a restart.

To disable auto-updates, pin to a specific version using `MESHCORE_VERSION`.

## Unraid

Set container port `80` to your desired host port (e.g. `7171`).

No volume mapping required — the app downloads fresh on each container start.
