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


## A problem I fixed: the search engine that never started

My private search engine (SearXNG) sat in the `Created` state for 13 months without ever running. Its logs were empty, because no process had ever started.

`docker inspect` held the answer in its error field: the container's port mapping tried to claim host port 52345, which my nginx site for the same service was already listening on ("address already in use"). Two things were fighting over one port.

I fixed it by binding the container to `127.0.0.1:8889` (localhost only) and letting nginx, which listens on 52345, proxy to it. That also keeps the search engine off the open network, so the only way in is through nginx.

Lesson: when a container won't start and its logs are empty, the failure happened before the app ran. Check `docker inspect` for the error instead of the logs.
