#!/usr/bin/env bash
# Run ON THE SERVER, from the root of this repo.
# Copies configs into the repo, scrubs secrets, and reports what it couldn't scrub.
# It only READS your live files (via cat/sed) and writes copies here; nothing
# on the server is changed.
#
#   REAL_DOMAIN=yourdomain.tld ./scripts/collect-configs.sh
#
# Review the report at the end BEFORE you commit.
set -euo pipefail
cd "$(dirname "$0")/.."      # always work from the repo root, wherever you run this

SRC="${SRC:-$HOME}"          # where your service folders live
SUDO="${SUDO-sudo}"          # set SUDO="" to skip sudo
SERVICES=(crafty homarr immich-app jellyfin navidrome uptime-kuma)

collect_dir() {              # collect_dir <source dir> <name in repo>
  local d="$1" n="$2" f
  if [ ! -d "$d" ]; then echo "skip    $n (not found: $d)"; return; fi
  mkdir -p "docker/$n"
  for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
    if $SUDO test -f "$d/$f"; then
      $SUDO cat "$d/$f" > "docker/$n/$f"
      echo "copied  $n/$f"
    fi
  done
  if $SUDO test -f "$d/.env"; then
    $SUDO sed -E 's/^([A-Za-z_][A-Za-z0-9_]*)=.*/\1=CHANGE_ME/' "$d/.env" > "docker/$n/.env.example"
    echo "wrote   $n/.env.example (values blanked)"
  fi
}

# 1. Compose projects in your home folder
for s in "${SERVICES[@]}"; do collect_dir "$SRC/$s" "$s"; done

# 2. SearXNG lives outside $HOME; its settings file holds a secret_key
collect_dir /usr/local/searxng-docker searxng
if $SUDO test -f /usr/local/searxng-docker/searxng/settings.yml; then
  $SUDO sed -E 's/^([[:space:]]*secret_key:).*/\1 "CHANGE_ME"/' \
    /usr/local/searxng-docker/searxng/settings.yml > docker/searxng/settings.yml
  echo "copied  searxng/settings.yml (secret_key blanked)"
fi

# 3. Host services: token removed from the unit files
mkdir -p systemd
for u in cloudflared ollama; do
  f="/etc/systemd/system/$u.service"
  if $SUDO test -f "$f"; then
    $SUDO cat "$f" | sed -E 's/(--token[ =])[^ ]+/\1REDACTED/; s/(TUNNEL_TOKEN=)[^ ]+/\1REDACTED/' > "systemd/$u.service"
    echo "copied  systemd/$u.service (tokens redacted)"
  fi
done

# 4. nginx
mkdir -p nginx/sites
for f in /etc/nginx/conf.d/*.conf /etc/nginx/sites-enabled/*; do
  [ -e "$f" ] || continue
  $SUDO cat "$f" > "nginx/sites/$(basename "$f")"
  echo "copied  nginx/$(basename "$f")"
done

# 5. Swap your real domain for example.com
if [ -n "${REAL_DOMAIN:-}" ]; then
  export REAL_DOMAIN
  { grep -rlF "$REAL_DOMAIN" docker nginx systemd 2>/dev/null || true ; } \
    | xargs -r perl -pi -e 's/\Q$ENV{REAL_DOMAIN}\E/example.com/g'
  echo "replaced $REAL_DOMAIN with example.com"
else
  echo "NOTE: REAL_DOMAIN not set; real hostnames are still in the files."
fi

# 6. Report anything that still looks like a secret
echo
echo "== Lines that look like secrets (move each to .env and use \${VAR}) =="
{ grep -rInEi '[A-Za-z_]*(token|secret|password|passwd|key)[A-Za-z_]*[[:space:]]*[:=]|--token' docker nginx systemd \
    | grep -vE '(\.env\.example|CHANGE_ME|REDACTED|\$\{|:[0-9]+:[[:space:]]*#)' ; } || echo "(none matched)"
echo
echo "== Long random-looking strings =="
{ grep -rInE '[A-Za-z0-9_+/=-]{40,}' docker nginx systemd \
    | grep -vE '(\.env\.example|@sha256:|:[0-9]+:[[:space:]]*#)' ; } || echo "(none matched)"
echo
echo "Done. Read the report above, open the copied files, then commit."
