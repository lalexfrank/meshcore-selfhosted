# MeshCore Web Docker

Self-hosted Docker container for the [MeshCore](https://meshcore.nz) web application.

Automatically downloads the latest MeshCore web release on startup.

## Quick Start

```bash
docker-compose up -d
```

Access at `http://localhost:7171`

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `TZ` | `UTC` | Timezone |
| `MESHCORE_BASE_URL` | `https://files.liamcottle.net/MeshCore` | Base URL for releases |
| `MESHCORE_VERSION` | (latest) | Pin to a specific version e.g. `v1.43.0`. If set, auto-updates are disabled. |
| `UPDATE_INTERVAL` | `3600` | How often to check for updates in seconds (default: 1 hour) |

## HTTPS / Bluetooth

Bluetooth requires HTTPS. Use a reverse proxy (Cloudflare Tunnel, Nginx Proxy Manager, Caddy, etc.) in front of this container.

## Unraid

Set container port `80` to your desired host port (e.g. `7171`).

No volume mapping required — the app downloads fresh on each container start.
