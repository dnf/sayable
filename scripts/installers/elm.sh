#!/usr/bin/env bash
# Installer for Elm (requires Node.js)
source "$(dirname "$0")/_common.sh"

install_macos() {
    # Ensure Node.js is available
    if ! has node; then
        bash "$(dirname "$0")/typescript.sh" install
    fi
    npm install -g elm elm-test
}

install_linux() {
    if ! has node; then
        bash "$(dirname "$0")/typescript.sh" install
    fi
    npm install -g elm elm-test
}

uninstall_macos() { npm uninstall -g elm elm-test 2>/dev/null || true; }
uninstall_linux() { npm uninstall -g elm elm-test 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Elm..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Elm..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
