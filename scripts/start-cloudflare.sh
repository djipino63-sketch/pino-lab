#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

if [ -f "$HOME/.cloudflare-hybrid.env" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.cloudflare-hybrid.env"
fi

if [ -z "${CLOUDFLARE_TUNNEL_TOKEN:-}" ]; then
  echo "CLOUDFLARE_TUNNEL_TOKEN is missing." >&2
  echo "Set it in .env or ~/.cloudflare-hybrid.env." >&2
  exit 1
fi

if command -v cloudflared >/dev/null 2>&1; then
  exec cloudflared tunnel run --token "$CLOUDFLARE_TUNNEL_TOKEN" "$@"
fi

if command -v docker >/dev/null 2>&1; then
  exec docker run --rm -i \
    -e TUNNEL_TOKEN="$CLOUDFLARE_TUNNEL_TOKEN" \
    cloudflare/cloudflared:latest \
    tunnel --no-autoupdate run --token "$CLOUDFLARE_TUNNEL_TOKEN" "$@"
fi

echo "Need cloudflared or Docker for Cloudflare Tunnel." >&2
exit 1
