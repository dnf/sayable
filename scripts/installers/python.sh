#!/usr/bin/env bash
# Installer for Python 3 + uv
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install python uv; }
install_linux() {
    apt_install python3 python3-venv
    if ! has uv; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

uninstall_macos() { brew uninstall python uv 2>/dev/null || true; }
uninstall_linux() {
    $SUDO apt-get remove -y python3 python3-venv 2>/dev/null || true
    rm -f "$HOME/.local/bin/uv"
}

deps() { (cd "$ROOT/src/python" && uv sync --extra dev); }

case "${1:-}" in
    install)   log "Installing Python..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Python..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
