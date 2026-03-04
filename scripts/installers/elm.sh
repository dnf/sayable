#!/usr/bin/env bash
# Installer for Elm (requires Node.js)
source "$(dirname "$0")/_common.sh"

install_macos() {
    # Ensure Node.js is available
    if ! has node; then
        bash "$(dirname "$0")/typescript.sh" install
    fi
    npm install -g elm elm-test
}

install_linux() {
    if ! has node; then
        bash "$(dirname "$0")/typescript.sh" install
    fi
    ARCH="$(dpkg --print-architecture)"
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
        echo "WARNING: Elm does not provide pre-built arm64 Linux binaries." >&2
        echo "See https://github.com/elm/compiler/issues/2292 for details." >&2
        echo "Skipping Elm installation on arm64." >&2
        return 1
    fi
    npm install -g elm elm-test
}

uninstall_macos() { npm uninstall -g elm elm-test 2>/dev/null || true; }
uninstall_linux() { npm uninstall -g elm elm-test 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/^    "[0-9][^"]*"/    "'"${ver}"'"/' \
        "${ROOT}/src/elm/src/ParentTime/Formatter.elm"
}

case "${1:-}" in
    install)     log "Installing Elm..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Elm..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
