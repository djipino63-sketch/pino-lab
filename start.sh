#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

STACK_PROFILE="${STACK_PROFILE:-full}"
ENABLE_VNC="${ENABLE_VNC:-1}"
TUNNEL_PROVIDER="${TUNNEL_PROVIDER:-none}"

if [ "${RUN_BOOTSTRAP:-1}" = "1" ]; then
  START_STACK=0 bash "$ROOT_DIR/scripts/start-codespaces.sh"
fi

case "$STACK_PROFILE" in
  full)
    bash "$ROOT_DIR/scripts/compose.sh" up -d kali openclaw
    ;;
  kali)
    bash "$ROOT_DIR/scripts/compose.sh" up -d kali
    ;;
  openclaw)
    bash "$ROOT_DIR/scripts/compose.sh" up -d openclaw
    ;;
  *)
    echo "Invalid STACK_PROFILE: $STACK_PROFILE" >&2
    exit 1
    ;;
esac

if [ "$ENABLE_VNC" = "1" ]; then
  nohup bash "$ROOT_DIR/scripts/start-vnc.sh" >/tmp/cloud-pc-vnc.log 2>&1 &
fi

if [ "$TUNNEL_PROVIDER" != "none" ]; then
  nohup bash "$ROOT_DIR/scripts/start-tunnel.sh" >/tmp/cloud-pc-tunnel.log 2>&1 &
fi

trap 'jobs -p | xargs -r kill' EXIT INT TERM
echo "Cloud PC Hybrid started. Press Ctrl-C to stop."
while :; do
  sleep 3600
done
