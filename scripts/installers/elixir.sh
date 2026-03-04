#!/usr/bin/env bash
# Installer for Elixir (pulls in Erlang/OTP as a dependency)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install elixir; }
install_linux() { apt_install elixir; }

uninstall_macos() { brew uninstall elixir 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y elixir 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/@version "[^"]*"/@version "'"${ver}"'"/' \
        "${ROOT}/src/elixir/lib/parent_time/formatter.ex"
    _sed_i 's/version: "[^"]*"/version: "'"${ver}"'"/' \
        "${ROOT}/src/elixir/mix.exs"
}

case "${1:-}" in
    install)     log "Installing Elixir..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Elixir..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
