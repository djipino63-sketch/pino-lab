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

VNC_DISPLAY="${VNC_DISPLAY:-1}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1600x900}"
VNC_DEPTH="${VNC_DEPTH:-16}"
VNC_PASSWORD="${VNC_PASSWORD:-kali-vnc}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_PORT=$((5900 + VNC_DISPLAY))

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

apt_get update
apt_get install -y --no-install-recommends \
  xfce4 xfce4-goodies xfce4-terminal \
  dbus-x11 x11-xserver-utils \
  tigervnc-standalone-server websockify novnc tightvncpasswd

mkdir -p "$HOME/.vnc"

cat >"$HOME/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=XFCE
exec dbus-launch --exit-with-session startxfce4
EOF
chmod +x "$HOME/.vnc/xstartup"

vncserver -kill ":$VNC_DISPLAY" >/dev/null 2>&1 || true
rm -f "/tmp/.X${VNC_DISPLAY}-lock" "/tmp/.X11-unix/X${VNC_DISPLAY}"

VNC_PASS_TOOL="$(command -v vncpasswd || command -v tigervncpasswd || command -v tightvncpasswd || true)"
if [ -z "$VNC_PASS_TOOL" ]; then
  echo "No VNC password tool found." >&2
  exit 1
fi

printf '%s\n%s\nn\n' "$VNC_PASSWORD" "$VNC_PASSWORD" | "$VNC_PASS_TOOL" >/dev/null

nohup vncserver ":$VNC_DISPLAY" -geometry "$VNC_GEOMETRY" -depth "$VNC_DEPTH" -localhost no >/tmp/vnc.log 2>&1 &
sleep 6
nohup websockify --web=/usr/share/novnc/ "$NOVNC_PORT" "localhost:$VNC_PORT" >/tmp/websockify.log 2>&1 &
sleep 2

echo "VNC ready on port $VNC_PORT and noVNC on $NOVNC_PORT"
