# Shared helpers for per-language installers (sourced, not executed).
# shellcheck shell=bash

set -euo pipefail

# Platform: "macos" or "linux"
case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

# sudo only when not root
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

# Project root (two levels up from scripts/installers/)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log() { echo "==> $*"; }

has() { command -v "$1" &>/dev/null; }

brew_install() { brew install "$@" || true; }

apt_install() {
    # Refresh package list if stale (>1 hour) or missing
    local stamp="/var/lib/apt/lists/partial"
    if [ ! -d "/var/lib/apt/lists" ] || \
       [ -z "$(find /var/lib/apt/lists -maxdepth 1 -name '*.Release' 2>/dev/null | head -1)" ] || \
       [ -n "$(find "$stamp" -maxdepth 0 -mmin +60 2>/dev/null)" ]; then
        $SUDO apt-get update -qq
    fi
    $SUDO apt-get install -y "$@"
}
