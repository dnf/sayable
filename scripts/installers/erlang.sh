#!/usr/bin/env bash
# Installer for Erlang/OTP + rebar3
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install erlang rebar3; }
install_linux() { apt_install erlang-dev erlang-tools rebar3; }

uninstall_macos() { brew uninstall erlang rebar3 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y erlang-dev erlang-tools rebar3 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/-define(VERSION, "[^"]*")/-define(VERSION, "'"${ver}"'")/' \
        "${ROOT}/src/erlang/include/parenttime.hrl"
    _sed_i 's/{vsn, "[^"]*"}/{vsn, "'"${ver}"'"}/' \
        "${ROOT}/src/erlang/src/parenttime.app.src"
}

case "${1:-}" in
    install)     log "Installing Erlang..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Erlang..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's/{description, "[^"]*"}/{description, "'"${PT_DESCRIPTION}"'"}/' \
            "${ROOT}/src/erlang/src/parenttime.app.src"
        _sed_i 's/{licenses, \["[^"]*"\]}/{licenses, ["'"${PT_LICENSE}"'"]}/' \
            "${ROOT}/src/erlang/src/parenttime.app.src"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
