# Storage

## NAS

A Samba share at `/mnt/data/share` on a dedicated 4 TB disk serves as my NAS. Access is restricted to a single authenticated user; there is no guest access.

Ports 137-139/445 are allowed through the host firewall for Samba (LAN use only).

## Why it exists

My media library, especially my FLAC collection, is the data I care most about keeping long-term. Keeping it on a plain filesystem behind open protocols (Samba, plus Navidrome and Jellyfin reading the same files) means no vendor can lock it up.

## Backups

- Media and photos are copied to an external drive.
- Vaultwarden has a scheduled backup script.

Gap: the external drive sits in the same house as the server, so a fire, flood, or theft could take both. An offsite copy and an automated schedule are on the roadmap in [security.md](security.md).

<!-- TODO: say how often the external copy runs and whether you've tested restoring from it. -->
