#!/usr/bin/env bash
# Installer for Rust via rustup
source "$(dirname "$0")/_common.sh"

_install() {
    if ! has rustc; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
}

install_macos() { _install; }
install_linux() { _install; }

uninstall_macos() { rustup self uninstall -y 2>/dev/null || true; }
uninstall_linux() { rustup self uninstall -y 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Rust..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Rust..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
