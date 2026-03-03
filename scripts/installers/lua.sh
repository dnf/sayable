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

case "${1:-}" in
    install)   log "Installing Lua..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Lua..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
