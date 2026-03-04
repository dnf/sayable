#!/usr/bin/env bash
# Installer for C toolchain (gcc/clang + cmake)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install cmake; }
install_linux() { apt_install build-essential cmake; }

uninstall_macos() { brew uninstall cmake 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y cmake 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/#define PARENTTIME_VERSION "[^"]*"/#define PARENTTIME_VERSION "'"${ver}"'"/' \
        "${ROOT}/codegen/targets/c/emitter.py"
}

case "${1:-}" in
    install)     log "Installing C..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling C..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
