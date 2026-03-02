#!/usr/bin/env bash
# Installer for Node.js (TypeScript runtime)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install node; }
install_linux() {
    if ! has node || ! node -v | grep -q '^v2[2-9]'; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | $SUDO bash -
        apt_install nodejs
    fi
}

uninstall_macos() { brew uninstall node 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y nodejs 2>/dev/null || true; }

deps() { (cd "$ROOT/src/typescript" && npm install); }

case "${1:-}" in
    install)   log "Installing TypeScript (Node.js)..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling TypeScript (Node.js)..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
