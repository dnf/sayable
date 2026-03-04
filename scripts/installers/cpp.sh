#!/usr/bin/env bash
# Installer for C++ toolchain (g++/clang++ + cmake)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install cmake; }
install_linux() { apt_install build-essential cmake; }

uninstall_macos() { brew uninstall cmake 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y cmake 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/constexpr const char\* VERSION = "[^"]*"/constexpr const char* VERSION = "'"${ver}"'"/' \
        "${ROOT}/src/cpp/include/parenttime/types.hpp"
    _sed_i 's/VERSION [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/VERSION '"${ver}"'/' \
        "${ROOT}/src/cpp/CMakeLists.txt"
}

case "${1:-}" in
    install)     log "Installing C++..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling C++..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's|DESCRIPTION "[^"]*"|DESCRIPTION "'"${PT_DESCRIPTION}"'"|' \
            "${ROOT}/src/cpp/CMakeLists.txt"
        _sed_i 's|HOMEPAGE_URL "[^"]*"|HOMEPAGE_URL "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/cpp/CMakeLists.txt"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
