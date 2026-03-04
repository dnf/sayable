#!/usr/bin/env bash
# Installer for Clojure CLI
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install clojure/tools/clojure; }
install_linux() {
    if ! has clojure; then
        curl -fsSL https://download.clojure.org/install/linux-install.sh | $SUDO bash
    fi
}

uninstall_macos() { brew uninstall clojure/tools/clojure 2>/dev/null || true; }
uninstall_linux() { $SUDO rm -f /usr/local/bin/clojure /usr/local/bin/clj; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/(def version "[^"]*")/(def version "'"${ver}"'")/' \
        "${ROOT}/src/clojure/src/parenttime/formatter.clj"
}

case "${1:-}" in
    install)     log "Installing Clojure..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Clojure..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
