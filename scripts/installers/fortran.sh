#!/usr/bin/env bash
# Installer for Fortran toolchain (gfortran + cmake)
# Fortran shares cmake with C/C++; gfortran comes from the gcc package.
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install gcc cmake; }
install_linux() { apt_install gfortran cmake; }

uninstall_macos() { brew uninstall gcc 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y gfortran 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/PT_VERSION = "[^"]*"/PT_VERSION = "'"${ver}"'"/' \
        "${ROOT}/src/fortran/src/parenttime.f90"
}

case "${1:-}" in
    install)     log "Installing Fortran..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Fortran..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
