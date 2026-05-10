#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

export OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$OPENCLAW_HOME}"
OPENCLAW_TOKEN_FILE="${OPENCLAW_TOKEN_FILE:-$OPENCLAW_HOME/gateway.token}"
umask 077

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw binary not found." >&2
  echo "Use the OpenClaw container image or install it globally first." >&2
  exit 1
fi

mkdir -p "$OPENCLAW_HOME"

if [ -n "${OPENCLAW_GATEWAY_TOKEN:-}" ]; then
  printf '%s' "$OPENCLAW_GATEWAY_TOKEN" >"$OPENCLAW_TOKEN_FILE"
elif [ -f "$OPENCLAW_TOKEN_FILE" ]; then
  OPENCLAW_GATEWAY_TOKEN="$(cat "$OPENCLAW_TOKEN_FILE")"
  export OPENCLAW_GATEWAY_TOKEN
else
  OPENCLAW_GATEWAY_TOKEN="$(node -e 'process.stdout.write(require("crypto").randomBytes(32).toString("hex"))')"
  export OPENCLAW_GATEWAY_TOKEN
  printf '%s' "$OPENCLAW_GATEWAY_TOKEN" >"$OPENCLAW_TOKEN_FILE"
  echo "Generated OPENCLAW_GATEWAY_TOKEN for this session."
fi

chmod 600 "$OPENCLAW_TOKEN_FILE" 2>/dev/null || true

exec openclaw gateway run \
  --dev \
  --bind lan \
  --port "${OPENCLAW_GATEWAY_PORT:-18789}" \
  --token "$OPENCLAW_GATEWAY_TOKEN" \
  "$@"
