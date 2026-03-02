#!/usr/bin/env bash
# Installer for Erlang/OTP + rebar3
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install erlang rebar3; }
install_linux() { apt_install erlang-dev erlang-tools rebar3; }

uninstall_macos() { brew uninstall erlang rebar3 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y erlang-dev erlang-tools rebar3 2>/dev/null || true; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Erlang..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Erlang..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
