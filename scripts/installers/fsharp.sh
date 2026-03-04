#!/usr/bin/env bash
# Installer for .NET SDK (F#) — shares .NET SDK with C#
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install dotnet; }
install_linux() {
    if ! dotnet --list-sdks 2>/dev/null | grep -q '^10\.'; then
        $SUDO apt-get update
        apt_install dotnet-sdk-10.0
    fi
}

uninstall_macos() { brew uninstall dotnet 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y dotnet-sdk-10.0 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing F#..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling F#..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
