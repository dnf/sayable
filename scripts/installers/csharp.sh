#!/usr/bin/env bash
# Installer for .NET SDK (C#) — shares .NET SDK with F#
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

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/public const string Version = "[^"]*"/public const string Version = "'"${ver}"'"/' \
        "${ROOT}/src/csharp/ParentTime/ParentTime.cs"
    _sed_i 's/<Version>[^<]*<\/Version>/<Version>'"${ver}"'<\/Version>/' \
        "${ROOT}/src/csharp/ParentTime/ParentTime.csproj"
}

case "${1:-}" in
    install)     log "Installing C#..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling C#..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
