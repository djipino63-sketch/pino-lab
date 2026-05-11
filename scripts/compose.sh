#!/usr/bin/env bash
set -euo pipefail

COMPOSE_PLUGIN=""
for candidate in \
  /usr/libexec/docker/cli-plugins/docker-compose \
  /usr/lib/docker/cli-plugins/docker-compose \
  /usr/local/lib/docker/cli-plugins/docker-compose
do
  if [ -x "$candidate" ]; then
    COMPOSE_PLUGIN="$candidate"
    break
  fi
done

if [ -n "$COMPOSE_PLUGIN" ]; then
  exec "$COMPOSE_PLUGIN" "$@"
fi

if docker compose version >/dev/null 2>&1; then
  exec docker compose "$@"
fi

if command -v docker-compose >/dev/null 2>&1; then
  exec docker-compose "$@"
fi

echo "Need either 'docker compose' or 'docker-compose' installed." >&2
exit 1
