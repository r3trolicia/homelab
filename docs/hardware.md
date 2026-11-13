# Hardware

## Server

| Part | Detail |
|---|---|
| Machine | Dell Precision T3500 workstation |
| CPU | Intel Xeon W3565 @ 3.2 GHz |
| RAM | 12 GB ECC|
| Boot disk | 477 GB, mounted at `/` |
| Data disk | 3.6 TB, mounted at `/mnt/data` (NAS share) |
| GPU | NVIDIA GeForce GT 1030 (GP108), HDMI (replaced a Quadro 5000) |
| OS | Debian 12 (bookworm), kernel 6.1 |
| Network | One gigabit NIC on the SERVERS VLAN at `10.0.30.10/24` |

The T3500 is old, which is the point: a cheap, reliable workstation-class board is plenty for this workload, and it taught me to watch resource limits (RAM and swap are the first things to run out).

## Router

An AWOW AK34 mini PC (Intel Celeron J3455, 4 cores at 1.5 GHz) with two NICs running OPNsense. One NIC faces the ISP router (WAN), the other faces the switch (LAN).

<!-- TODO: add the router's RAM. -->

## Switching and wireless

- TP-Link TL-SG108E (v6, managed 8-port, 802.1Q VLANs) in my room, the core switch
- TP-Link Omada EAP225 (AC1350, dual-band) access point in standalone mode, with one SSID per VLAN
- TP-Link TL-WA801N (N300, 2.4 GHz) kept as a future IoT-only access point
- TP-Link TL-SG105 (unmanaged 5-port) kept as a lab bench switch and a cold spare for the core switch
- ISP router in bridge mode in the living room

