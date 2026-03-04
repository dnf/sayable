#!/usr/bin/env bash
# Installer for COBOL toolchain (GnuCOBOL + cmake)
# COBOL uses cmake for the build system and cobc (GnuCOBOL) as the compiler.
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install gnu-cobol cmake; }
install_linux() { apt_install gnucobol cmake; }

uninstall_macos() { brew uninstall gnu-cobol 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y gnucobol 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i '/PT-VERSION/s/VALUE "[^"]*"/VALUE "'"${ver}"'"/' \
        "${ROOT}/src/cobol/src/Types.cbl"
}

case "${1:-}" in
    install)     log "Installing COBOL..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling COBOL..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
