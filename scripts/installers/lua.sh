#!/usr/bin/env bash
# Installer for Lua + LuaRocks + busted + luacheck
source "$(dirname "$0")/_common.sh"

install_macos() {
    brew_install lua luarocks
}
install_linux() {
    apt_install lua5.4 liblua5.4-dev luarocks
}

uninstall_macos() {
    brew uninstall luarocks lua 2>/dev/null || true
}
uninstall_linux() {
    $SUDO apt-get remove -y luarocks lua5.4 liblua5.4-dev 2>/dev/null || true
}

deps() {
    luarocks install busted
    luarocks install luacheck
}

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/M\.VERSION = "[^"]*"/M.VERSION = "'"${ver}"'"/' \
        "${ROOT}/src/lua/parenttime.lua"
}

case "${1:-}" in
    install)     log "Installing Lua..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Lua..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
