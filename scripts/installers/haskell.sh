#!/usr/bin/env bash
# Installer for Haskell (GHC + cabal via ghcup)
source "$(dirname "$0")/_common.sh"

_install() {
    if ! has ghc; then
        curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | \
            BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
            BOOTSTRAP_HASKELL_INSTALL_CABAL=1 \
            BOOTSTRAP_HASKELL_INSTALL_GHC=1 \
            sh
    fi
}

install_macos() { _install; }
install_linux() { _install; }

uninstall_macos() { rm -rf "$HOME/.ghcup"; }
uninstall_linux() { rm -rf "$HOME/.ghcup"; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    local pvp="${ver}.0"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/haskell/src/ParentTime/Formatter.hs"
    _sed_i 's/^version:       [0-9][^ ]*/version:       '"${pvp}"'/' \
        "${ROOT}/src/haskell/parent-time.cabal"
}

case "${1:-}" in
    install)     log "Installing Haskell..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Haskell..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i "s/^license:       .*/license:       ${PT_LICENSE}/" \
            "${ROOT}/src/haskell/parent-time.cabal"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
