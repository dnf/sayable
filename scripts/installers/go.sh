#!/usr/bin/env bash
# Installer for Go
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install go; }
install_linux() {
    if ! has go; then
        ARCH="$(dpkg --print-architecture)"
        curl -fsSL "https://go.dev/dl/go1.21.13.linux-${ARCH}.tar.gz" | $SUDO tar -C /usr/local -xz
    fi
}

uninstall_macos() { brew uninstall go 2>/dev/null || true; }
uninstall_linux() { $SUDO rm -rf /usr/local/go; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Go..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Go..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
