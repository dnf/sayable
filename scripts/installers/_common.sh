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

apt_install() { $SUDO apt-get install -y "$@"; }
