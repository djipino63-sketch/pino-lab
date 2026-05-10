#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PROFILE="${PROFILE:-fast}" \
INSTALL_FAST_TOOLS="${INSTALL_FAST_TOOLS:-1}" \
INSTALL_DESKTOP="${INSTALL_DESKTOP:-0}" \
INSTALL_OPENCLAW="${INSTALL_OPENCLAW:-1}" \
bash "$ROOT_DIR/scripts/bootstrap.sh"

mkdir -p "$HOME/bin"

cat >"$HOME/bin/start-vnc" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$ROOT_DIR"
bash "\$ROOT_DIR/scripts/start-vnc.sh"
EOF
chmod +x "$HOME/bin/start-vnc"

cat >"$HOME/bin/start-openclaw" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$ROOT_DIR"
bash "\$ROOT_DIR/scripts/start-openclaw.sh"
EOF
chmod +x "$HOME/bin/start-openclaw"

grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" || printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc"

if [ "${START_STACK:-1}" = "1" ]; then
  bash "$ROOT_DIR/scripts/compose.sh" up -d kali openclaw
fi

echo "Codespaces ready."
