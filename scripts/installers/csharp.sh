#!/usr/bin/env bash
# Installer for .NET SDK 8.0 (C#)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install dotnet; }
install_linux() {
    if ! has dotnet; then
        curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o /tmp/ms.deb
        $SUDO dpkg -i /tmp/ms.deb && rm /tmp/ms.deb
        $SUDO apt-get update
        apt_install dotnet-sdk-8.0
    fi
}

uninstall_macos() { brew uninstall dotnet 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y dotnet-sdk-8.0 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing C#..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling C#..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
