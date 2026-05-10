#!/usr/bin/env bash
set -euo pipefail

export OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-$OPENCLAW_HOME}"
OPENCLAW_TOKEN_FILE="${OPENCLAW_TOKEN_FILE:-$OPENCLAW_HOME/gateway.token}"

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

exec openclaw gateway run \
  --dev \
  --bind lan \
  --port "${OPENCLAW_GATEWAY_PORT:-18789}" \
  --token "$OPENCLAW_GATEWAY_TOKEN" \
  "$@"
