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

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/const Version = "[^"]*"/const Version = "'"${ver}"'"/' \
        "${ROOT}/src/go/parenttime.go"
}

case "${1:-}" in
    install)     log "Installing Go..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Go..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
