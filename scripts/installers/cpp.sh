#!/usr/bin/env bash
# Installer for C++ toolchain (g++/clang++ + cmake)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install cmake; }
install_linux() { apt_install build-essential cmake; }

uninstall_macos() { brew uninstall cmake 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y cmake 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing C++..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling C++..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
