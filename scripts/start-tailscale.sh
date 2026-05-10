#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

if [ -f "$HOME/.tailscale-hybrid.env" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.tailscale-hybrid.env"
fi

TAILSCALE_MODE="${TAILSCALE_MODE:-serve}"
TAILSCALE_PORT="${TAILSCALE_PORT:-443}"
TAILSCALE_TARGET="${TAILSCALE_TARGET:-localhost:18789}"

if ! command -v tailscale >/dev/null 2>&1; then
  echo "tailscale binary not found." >&2
  echo "Install Tailscale on the host or inside your Codespaces base image." >&2
  exit 1
fi

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

case "$TAILSCALE_MODE" in
  serve)
    exec $SUDO tailscale serve --bg --yes --https="$TAILSCALE_PORT" "$TAILSCALE_TARGET" "$@"
    ;;
  funnel)
    exec $SUDO tailscale funnel --bg --https="$TAILSCALE_PORT" "$TAILSCALE_TARGET" "$@"
    ;;
  *)
    echo "Invalid TAILSCALE_MODE: $TAILSCALE_MODE (use serve or funnel)." >&2
    exit 1
    ;;
esac
