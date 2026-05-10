#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

TUNNEL_PROVIDER="${TUNNEL_PROVIDER:-none}"

case "$TUNNEL_PROVIDER" in
  none|"")
    echo "No tunnel provider selected."
    ;;
  cloudflare)
    exec bash "$ROOT_DIR/scripts/start-cloudflare.sh" "$@"
    ;;
  tailscale)
    exec bash "$ROOT_DIR/scripts/start-tailscale.sh" "$@"
    ;;
  *)
    echo "Invalid TUNNEL_PROVIDER: $TUNNEL_PROVIDER (use none, cloudflare, or tailscale)." >&2
    exit 1
    ;;
esac
