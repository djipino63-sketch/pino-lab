#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
MAIN_LOG="${MAIN_LOG:-$LOG_DIR/start.log}"
mkdir -p "$LOG_DIR"
touch "$MAIN_LOG"

exec > >(tee -a "$MAIN_LOG") 2>&1

if [ "${DEBUG:-0}" = "1" ]; then
  export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: '
  set -x
fi

log() {
  printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"
}

STACK_PROFILE="${STACK_PROFILE:-full}"
ENABLE_VNC="${ENABLE_VNC:-1}"
TUNNEL_PROVIDER="${TUNNEL_PROVIDER:-auto}"
RUN_BOOTSTRAP="${RUN_BOOTSTRAP:-1}"

if [ "$TUNNEL_PROVIDER" = "auto" ]; then
  if [ -n "${CLOUDFLARE_TUNNEL_TOKEN:-}" ]; then
    TUNNEL_PROVIDER="cloudflare"
  else
    TUNNEL_PROVIDER="none"
  fi
fi

trap 'status=$?; log "Stopping background jobs (exit=$status)."; jobs -pr | xargs -r kill; wait || true; log "Stopped."; exit "$status"' EXIT INT TERM

log "Cloud PC Hybrid starting."
log "Logs:"
log "  main:   $MAIN_LOG"
log "  vnc:    $LOG_DIR/vnc.log"
log "  openclaw: $LOG_DIR/openclaw.log"
log "  tunnel: $LOG_DIR/tunnel.log"

if [ "$RUN_BOOTSTRAP" = "1" ]; then
  log "Bootstrapping the Codespaces/Kali base."
  START_STACK=0 bash "$ROOT_DIR/scripts/start-codespaces.sh"
fi

case "$STACK_PROFILE" in
  full)
    log "Starting stack profile: full"
    bash "$ROOT_DIR/scripts/compose.sh" up -d kali openclaw
    log "Following OpenClaw logs."
    nohup bash "$ROOT_DIR/scripts/compose.sh" logs -f openclaw >>"$LOG_DIR/openclaw.log" 2>&1 &
    ;;
  kali)
    log "Starting stack profile: kali"
    bash "$ROOT_DIR/scripts/compose.sh" up -d kali
    ;;
  openclaw)
    log "Starting stack profile: openclaw"
    bash "$ROOT_DIR/scripts/compose.sh" up -d openclaw
    log "Following OpenClaw logs."
    nohup bash "$ROOT_DIR/scripts/compose.sh" logs -f openclaw >>"$LOG_DIR/openclaw.log" 2>&1 &
    ;;
  *)
    echo "Invalid STACK_PROFILE: $STACK_PROFILE" >&2
    exit 1
    ;;
esac

if [ "$ENABLE_VNC" = "1" ]; then
  log "Starting VNC helper."
  nohup bash "$ROOT_DIR/scripts/start-vnc.sh" >>"$LOG_DIR/vnc.log" 2>&1 &
else
  log "VNC disabled."
fi

if [ "$TUNNEL_PROVIDER" != "none" ]; then
  log "Starting tunnel provider: $TUNNEL_PROVIDER"
  nohup env TUNNEL_PROVIDER="$TUNNEL_PROVIDER" bash "$ROOT_DIR/scripts/start-tunnel.sh" >>"$LOG_DIR/tunnel.log" 2>&1 &
else
  log "No tunnel provider selected."
fi

log "Cloud PC Hybrid started. Press Ctrl-C to stop."
while :; do
  sleep 3600
done
