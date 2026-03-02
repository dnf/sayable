#!/usr/bin/env bash
# Installer for Swift
source "$(dirname "$0")/_common.sh"

install_macos() { log "Using Xcode Swift (no install needed)."; }
install_linux() {
    if ! has swift; then
        ARCH="$(dpkg --print-architecture)"
        SWIFT_URL="https://download.swift.org/swift-5.10.1-release/ubuntu2404/${ARCH}/swift-5.10.1-RELEASE-ubuntu24.04-${ARCH}.tar.gz"
        curl -fsSL "$SWIFT_URL" | $SUDO tar -C /usr/local --strip-components=2 -xz
    fi
}

uninstall_macos() { echo "Xcode Swift — not removing."; }
uninstall_linux() { echo "Manual Swift install — remove from /usr/local manually if needed."; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Swift..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Swift..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
