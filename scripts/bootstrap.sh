#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export NEEDRESTART_MODE=a

PROFILE="${PROFILE:-fast}"
INSTALL_FAST_TOOLS="${INSTALL_FAST_TOOLS:-1}"
INSTALL_DESKTOP="${INSTALL_DESKTOP:-0}"
INSTALL_OPENCLAW="${INSTALL_OPENCLAW:-0}"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "Need root or sudo." >&2
  exit 1
fi

apt_get() {
  $SUDO apt-get -o Dpkg::Use-Pty=0 -o Acquire::Retries=3 "$@"
}

install_packages() {
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      if ! apt_get install -y --no-install-recommends "$pkg"; then
        echo "Skipping failed install: $pkg" >&2
        apt_get -f install -y || true
      fi
    else
      echo "Skipping unavailable package: $pkg" >&2
    fi
  done
}

apt_get update

BASE_PACKAGES=(
  curl git ca-certificates jq vim wget python3 python3-pip
  procps iproute2 net-tools dnsutils file unzip tar bash-completion
)

FAST_PACKAGES=(
  nmap sqlmap hydra john gobuster ffuf nikto whatweb
  netcat-traditional tcpdump aircrack-ng hashcat seclists
)

DESKTOP_PACKAGES=(
  xfce4 xfce4-goodies xfce4-terminal
  dbus-x11 x11-xserver-utils
  tigervnc-standalone-server websockify novnc
)

install_packages "${BASE_PACKAGES[@]}"

python3 -m pip install --user --upgrade pip kaggle
grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null || \
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"

if [ "$INSTALL_FAST_TOOLS" = "1" ]; then
  install_packages "${FAST_PACKAGES[@]}"
fi

if [ "$INSTALL_DESKTOP" = "1" ] || [ "$PROFILE" = "full" ]; then
  install_packages "${DESKTOP_PACKAGES[@]}"
fi

if [ "$INSTALL_OPENCLAW" = "1" ]; then
  install_packages docker.io docker-compose-plugin
fi

apt_get clean || true
apt_get autoremove -y || true
