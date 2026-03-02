#!/usr/bin/env bash
# Installer for Perl (system perl on macOS, apt on Linux)
source "$(dirname "$0")/_common.sh"

install_macos() { log "Using system Perl (no install needed)."; }
install_linux() { apt_install perl; }

uninstall_macos() { echo "System Perl — not removing."; }
uninstall_linux() { echo "System Perl — not removing."; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Perl..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Perl..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
