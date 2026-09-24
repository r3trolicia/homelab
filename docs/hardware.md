# Hardware

## Server

| Part | Detail |
|---|---|
| Machine | Dell Precision T3500 workstation |
| CPU | Intel Xeon W3565 @ 3.2 GHz |
| RAM | 12 GB |
| Boot disk | 477 GB, mounted at `/` |
| Data disk | 3.6 TB, mounted at `/mnt/data` (NAS share) |
| GPU | NVIDIA GeForce GT 1030 (GP108), HDMI (replaced a Quadro 5000) |
| OS | Debian 12 (bookworm), kernel 6.1 |
| Network | One gigabit NIC on the LAN at `10.0.0.128/24` |

The T3500 is old, which is the point: a cheap, reliable workstation-class board is plenty for this workload, and it taught me to watch resource limits (RAM and swap are the first things to run out).

## Router

An AWOW AK34 mini PC (Intel Celeron J3455, 4 cores at 1.5 GHz) with two NICs running OPNsense. One NIC faces the ISP router (WAN), the other faces the switch (LAN).

<!-- TODO: add the router's RAM. -->

## Switching and wireless

- TP-Link TL-SG105 (unmanaged 5-port) in my room
- Wireless access point on the switch
- ISP router in bridge mode in the living room

<!-- TODO: add the access point model. -->
