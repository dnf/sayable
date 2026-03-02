#!/usr/bin/env bash
# Installer for Scala (uses JDK 17 — delegates to java.sh)
source "$(dirname "$0")/_common.sh"

install_macos() {
    if ! has java; then
        bash "$(dirname "$0")/java.sh" install
    fi
}

install_linux() {
    if ! has java; then
        bash "$(dirname "$0")/java.sh" install
    fi
}

uninstall_macos() {
    echo "JDK 17 is shared by Java, Kotlin, and Scala — not removing."
    echo "To force: brew uninstall openjdk@17"
}

uninstall_linux() {
    echo "JDK 17 is shared by Java, Kotlin, and Scala — not removing."
    echo "To force: sudo apt-get remove -y openjdk-17-jdk-headless"
}

deps() { :; }

case "${1:-}" in
    install)   log "Installing Scala (JDK 17)..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Scala..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
