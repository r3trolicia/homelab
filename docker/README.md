# Docker and host services

Each containerized service lives in its own folder with a `docker-compose.yml`. Compose creates a separate bridge network per project, which keeps stacks isolated from each other by default.

## Containers

| Service | What it does | Port(s) | Notes |
|---|---|---|---|
| Immich | Photo/video library, with ML search | 2283 | 4 containers: server, machine learning, Postgres (vector search), Valkey |
| Jellyfin | Video streaming | 8096 | Host networking (for DLNA/discovery) |
| Navidrome | Music streaming for my FLAC library | 4533 | Reads the same files as the NAS |
| Vaultwarden | Password manager | 6969 | Backed up by a script; web vault needs HTTPS |
| Pi-hole | DNS filtering for the network | 53 | Host networking |
| Uptime Kuma | Uptime monitoring and alerts | 3001 | |
| Homarr | Dashboard | 7575 | Encryption key loads from `.env` |
| Portainer | Container management UI | 9000 | Behind a Cloudflare Access policy when published |
| Crafty Controller | Minecraft server manager | 8123, 8443, 25500-25600, 19132/udp | Wide port range for game servers |
| OpenSpeedTest | LAN speed test | 6767, 6768 | Handy for checking cabling and Wi-Fi |
| SearXNG | Private metasearch engine | via nginx | Comes with its own Valkey cache |

## Host services (not containers)

| Service | What it does | Notes |
|---|---|---|
| cloudflared | Outbound-only Cloudflare Tunnel | systemd unit in `systemd/` |
| Ollama | Local LLM runtime | systemd unit in `systemd/`; listens on localhost only |
| CasaOS | Home-server dashboard and app manager | Gateway on port 81 |
| Tailscale | Private remote access | |
| nginx | Websites and reverse proxy | See [nginx/](../nginx/README.md) |
| Samba | NAS | See [docs/storage.md](../docs/storage.md) |

## Containers started with `docker run`

Vaultwarden, Portainer, Pi-hole, and OpenSpeedTest were originally started by hand. Their compose files were rebuilt from `scripts/inspect-containers.sh` output so they are reproducible. The Vaultwarden file also fixes two things I found: it now restarts after a reboot, and open registration is off.

## Deploying a service

```bash
cd docker/<service>
cp .env.example .env      # fill in real values; .env is gitignored
docker compose up -d
docker compose logs -f
```

## Conventions

- **No secrets in compose files.** Tokens and passwords go in `.env`; compose references them as `${VAR}`.
- **Data stays out of git.** Config and database folders are in `.gitignore`.
- **Why containers.** Each app's dependencies are isolated, upgrades are `pull` + `up -d`, and rolling back is changing a tag.

## Known issues

- Most images use `:latest`. Pinning versions is on the [roadmap](../docs/security.md).
- The server runs low on RAM; Immich's machine-learning container is the heaviest tenant.
