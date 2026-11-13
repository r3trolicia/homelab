# Security

How the network is defended today, what I found when I audited my own setup, and what I'm changing next.

## Threat model

- Internet scanners and opportunistic attacks against anything exposed
- A compromised or careless device on my own LAN (game console, guest phone, IoT)
- Stolen or leaked credentials, including the tokens my own services use
- Disk or hardware failure, or a house-level event, taking my data with it

## Layers in place

| Layer | What I did |
|---|---|
| Perimeter | ISP router in bridge mode; OPNsense is the only router/firewall, default-deny for inbound WAN traffic; no port forwards |
| Segmentation | Seven VLANs with per-interface rules: trusted can start connections anywhere; servers, console, guest, and IoT can't start connections into private networks; the console has no internet; guest Wi-Fi has client isolation |
| Exposure | Only selected apps are published, through a Cloudflare Zero Trust tunnel that the server opens outbound |
| Identity | Admin surfaces (Portainer, SSH) require a Cloudflare Access identity check before they are reachable |
| Remote admin | Tailscale on the firewall as a subnet router (no open WAN ports); remote devices get their own firewall interface |
| Host firewall | UFW on the server: default deny incoming, explicit allow rules per service |
| DNS | Unbound on OPNsense for every VLAN; DNS on servers, guest, and IoT is forced through it by destination NAT; Pi-hole on the server for tracker and malware-domain blocking |
| Monitoring | OPNsense monitoring at the network edge; Uptime Kuma for service health |
| Data access | Samba share limited to one authenticated user; no guest access |
| Secrets | Passwords in a self-hosted Vaultwarden with scheduled backups; no secrets in this repo, enforced by a gitleaks pre-commit hook |
| Backups | Media and photos copied to an external drive |

## Segmentation: what a compromise can reach

The VLAN policy is easiest to judge by asking what an attacker gets from each foothold. Trusted devices can start connections anywhere; nothing can start a connection into trusted.

| If this is compromised… | …it can reach | …it cannot reach |
|---|---|---|
| An IoT device (smart bulb, streaming stick) | The internet, DNS | PCs, laptop, phone, server, NAS, any admin page |
| A guest's phone | The internet, rate-limited | Any private address; other guests (client isolation) |
| The homelab server (e.g. a vulnerable container) | The internet | PCs, laptop, phone, console. It can't pivot to the machines holding my sessions and keys |
| The game console | Nothing | The internet and every other VLAN |
| A non-admin device on trusted Wi-Fi | Internet, server services | Switch, AP, and firewall admin pages |
| A leaked guest Wi-Fi password | The internet | Everything private |

Supporting controls: only a short list of admin hosts can open management pages; DNS from servers, guest, and IoT is forced through the firewall's resolver; remote admin comes in over Tailscale on its own firewall interface; and no WAN port is open.

### Known gaps

- The management VLAN still carries a few legacy clients until the old AP and lab bench move to their own VLANs.
- Wi-Fi is WPA2-AES, not WPA3 (the AP's standalone firmware doesn't offer it here).
- The managed switch's web UI is plain HTTP; only admin hosts can reach it.
- One router is a single point of failure; a current config export keeps a rebuild short.
- Inside a VLAN, host firewalls still matter: Docker can bypass UFW, so the per-host items below still apply.

## What I found auditing my own setup

Reading my own `ufw status`, `ss -tulpn`, `docker ps`, and `systemctl status` output turned up several things. Writing them down is the point: a hardening plan starts with an honest inventory.

1. **Secrets in plain sight.** The tunnel connector was started with its token as a command-line argument, which puts it in the unit file and in the process list for every local user. Separately, my own secret scan found an app encryption key sitting in a compose file. Fix: root-only environment files and `.env` files, then rotate both.
2. **Docker bypasses UFW.** Published container ports are wired into iptables ahead of UFW's rules, so my allow-list does not actually gate them. The perimeter still protects me from the internet, but any device on my LAN can reach them.
3. **Admin interfaces listen on every interface.** Portainer, a web console on port 9090, and the CasaOS gateway on port 81 are reachable from the whole LAN. They should listen on localhost or the Tailscale address only.
4. **Stale firewall rules.** Several UFW rules allow ports no current service uses. Unused allow rules are attack surface with no benefit.
5. **Flat network.** The server, gaming PC, PS4, and wireless clients shared one subnet, so anything on Wi-Fi could talk to the server. *Fixed November 2026:* VLANs separate trusted, servers, console, guest, and IoT (see [network/README.md](../network/README.md)).
6. **Public password vault on default settings.** Vaultwarden is reachable from the internet, but nothing overrides its defaults: registration is probably open, and its restart policy was `no`, so a reboot left the vault down. The admin page is already off because no admin token is set, which is the right default.
7. **Floating image tags.** Most containers use `:latest`, so an update can change behavior without me choosing it.
8. **Memory pressure.** Swap is fully used and free RAM is near zero, which is a reliability risk.
9. **Backups share a building with the server.** The external drive protects against disk failure but not fire, flood, or theft.

## Hardening roadmap

- [x] Cloudflare Access identity policy in front of Portainer and SSH
- [x] Media and photos copied to an external drive
- [ ] Rotate the tunnel token and load it from a root-only environment file (`chmod 600`)
- [ ] Prune UFW to only the ports a current service needs
- [ ] Bind admin UIs (Portainer, Crafty, Uptime Kuma, Homarr) to `127.0.0.1` or the Tailscale IP; add `DOCKER-USER` chain rules where needed
- [ ] Restrict the CasaOS gateway (port 81) and the port-9090 web console to the LAN or Tailscale only
- [ ] Vaultwarden: close signups (`SIGNUPS_ALLOWED=false`), `restart: unless-stopped`, 2FA on every account
- [ ] Rate limiting or an Access policy for the other published apps
- [x] VLANs in OPNsense: trusted, servers, console sandbox, guest, IoT, lab, on a TL-SG108E managed switch and an Omada EAP225 with per-VLAN SSIDs
- [ ] Finish the IoT and lab VLAN rollout (old AP on VLAN 60, bench switch on VLAN 70), then lock down the management VLAN
- [ ] Keep an encrypted, off-box copy of the OPNsense config backup
- [ ] Re-scope UFW rules from the old flat `10.0.0.0/24` to the trusted VLAN `10.0.20.0/24`, and allow the router address for Tailscale-routed traffic
- [ ] SSH: key-only authentication, password login off, rate limiting with fail2ban
- [ ] Pin container images to version tags and update on a schedule after reading release notes
- [ ] Offsite backup copy, and automate the external-drive copy (3-2-1: three copies, two media, one offsite)
- [ ] Add RAM or trim services to stop swap thrashing

## Lessons so far

- Layers matter more than any single control: the perimeter, identity checks, host firewall, and per-service settings each cover the others' gaps.
- An outbound tunnel plus default-deny at the edge removed the need for port forwarding entirely.
- Secrets leak in boring places: command lines, process lists, and forgotten compose files.
- Auditing my own setup found problems no tutorial had warned me about.
