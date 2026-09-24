#!/usr/bin/env bash
# Run ON THE SERVER. For containers that were started with `docker run` (no compose
# file), prints their settings so a compose file can be written from them.
# Environment variable NAMES are shown, VALUES never are, so the output is safe to share.
#
#   ./scripts/inspect-containers.sh                      # vaultwarden portainer pihole openspeedtest
#   ./scripts/inspect-containers.sh name1 name2 ...
set -uo pipefail
CONTAINERS=("$@")
[ ${#CONTAINERS[@]} -gt 0 ] || CONTAINERS=(vaultwarden portainer pihole openspeedtest)

for c in "${CONTAINERS[@]}"; do
  echo "=============== $c"
  docker inspect "$c" --format 'image:    {{.Config.Image}}
network:  {{.HostConfig.NetworkMode}}
restart:  {{.HostConfig.RestartPolicy.Name}}
ports:    {{json .HostConfig.PortBindings}}
cap_add:  {{json .HostConfig.CapAdd}}
cmd:      {{json .Config.Cmd}}' || continue
  echo "mounts:"
  docker inspect "$c" --format '{{range .Mounts}}  {{.Source}} -> {{.Destination}} ({{.Mode}}){{println}}{{end}}'
  echo "env variable names only:"
  docker inspect "$c" --format '{{range .Config.Env}}{{println .}}{{end}}' | cut -d= -f1 | sed 's/^/  /'
done
