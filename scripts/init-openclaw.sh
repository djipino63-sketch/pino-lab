#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"
EXAMPLE_FILE="$ROOT_DIR/.env.example"

if [ ! -f "$ENV_FILE" ]; then
  cp "$EXAMPLE_FILE" "$ENV_FILE"
fi

mkdir -p "$ROOT_DIR/logs" "$ROOT_DIR/.openclaw"

python3 - "$ENV_FILE" <<'PY'
from pathlib import Path
import secrets
import sys

env_path = Path(sys.argv[1])
lines = env_path.read_text().splitlines()

defaults = {
    "OPENCLAW_HOME": "./.openclaw",
    "OPENCLAW_STATE_DIR": "./.openclaw",
    "OPENCLAW_GATEWAY_PORT": "18789",
}

updated = []
seen = set()
token = None

for line in lines:
    if "=" not in line or line.lstrip().startswith("#"):
        updated.append(line)
        continue

    key, value = line.split("=", 1)
    key = key.strip()
    value = value.strip()

    if key == "OPENCLAW_GATEWAY_TOKEN":
        if not value or value == "replace-me":
            token = secrets.token_hex(32)
            value = token
            print("Generated new OPENCLAW_GATEWAY_TOKEN.")
        else:
            token = value
            print("Reusing existing OPENCLAW_GATEWAY_TOKEN.")
        updated.append(f"{key}={value}")
        seen.add(key)
        continue

    if key in defaults:
        updated.append(f"{key}={defaults[key]}")
        seen.add(key)
        continue

    updated.append(line)

for key, value in defaults.items():
    if key not in seen:
        updated.append(f"{key}={value}")

if "OPENCLAW_GATEWAY_TOKEN" not in seen:
    token = secrets.token_hex(32)
    updated.append(f"OPENCLAW_GATEWAY_TOKEN={token}")
    print("Generated new OPENCLAW_GATEWAY_TOKEN.")

env_path.write_text("\n".join(updated).rstrip() + "\n")
print(f"Updated {env_path}")
PY

echo "OpenClaw configuration ready."
