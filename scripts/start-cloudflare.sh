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

if ! command -v cloudflared >/dev/null 2>&1; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64) pkg_arch="amd64" ;;
    aarch64|arm64) pkg_arch="arm64" ;;
    *)
      echo "Unsupported architecture for cloudflared auto-install: $arch" >&2
      exit 1
      ;;
  esac

  tmp_deb="$(mktemp /tmp/cloudflared.XXXXXX.deb)"
  curl -fsSL -o "$tmp_deb" \
    "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${pkg_arch}.deb"

  if [ "$(id -u)" -eq 0 ]; then
    dpkg -i "$tmp_deb" >/dev/null
  elif command -v sudo >/dev/null 2>&1; then
    sudo dpkg -i "$tmp_deb" >/dev/null
  else
    echo "Need root or sudo to install cloudflared." >&2
    exit 1
  fi

  rm -f "$tmp_deb"
fi

exec cloudflared tunnel run --token "$CLOUDFLARE_TUNNEL_TOKEN" "$@"
