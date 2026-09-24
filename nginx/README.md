# nginx

nginx runs on the server host and does two jobs: it serves my own web projects, and it reverse-proxies to local apps so each one gets a clean hostname instead of a port number.

Site configs are in `sites/` (sanitized: the real domain is replaced with `example.com`).

## What it serves

- My personal website
- My photography website
- A small color-screen web app ("catscreen")

## How traffic reaches it

Public traffic arrives through the Cloudflare Tunnel, not through port forwarding, so nginx is never directly exposed to the internet. Cloudflare terminates TLS at the edge.

## Patterns used

- **Static site:** `server { listen PORT; server_name ...; root ...; }`
- **Reverse proxy:** `proxy_pass http://127.0.0.1:PORT;` to a local app bound to localhost

## Why

A reverse proxy is the single place to add headers, rate limits, or access rules later, instead of configuring every app separately.

<!-- TODO: add one thing you fixed or learned in nginx (e.g. a proxy header, websocket setting, or 502 you debugged). -->
