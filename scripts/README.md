# scripts

Helpers that pull configs off the server into this repo without leaking secrets. Both run **on the server**, never on your laptop, and only read live files.

## collect-configs.sh

Run from the repo root:

```bash
REAL_DOMAIN=yourdomain.tld ./scripts/collect-configs.sh
```

It:
1. copies each service's compose file into `docker/<service>/`
2. turns each `.env` into a `.env.example` with every value replaced by `CHANGE_ME`
3. copies the systemd units for cloudflared and Ollama with the tunnel token redacted
4. copies nginx configs into `nginx/sites/`
5. swaps your real domain for `example.com`
6. prints a report of anything that still looks like a secret

Read the report and open the copied files before committing. The script blanks what it recognizes; you are the last check.

## inspect-containers.sh

For containers started with `docker run` instead of compose. Prints image, ports, mounts, and environment variable *names* (never values) so a compose file can be written from them.
