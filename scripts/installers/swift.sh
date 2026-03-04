#!/usr/bin/env bash
# Installer for Swift
source "$(dirname "$0")/_common.sh"

install_macos() { log "Using Xcode Swift (no install needed)."; }
install_linux() {
    if ! has swift; then
        ARCH="$(dpkg --print-architecture)"
        # Swift URL pattern differs by architecture:
        #   x86: ubuntu2404/swift-VER-RELEASE/swift-VER-RELEASE-ubuntu24.04.tar.gz
        #   arm: ubuntu2404-aarch64/swift-VER-RELEASE/swift-VER-RELEASE-ubuntu24.04-aarch64.tar.gz
        VER="5.10.1"
        if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
            SWIFT_URL="https://download.swift.org/swift-${VER}-release/ubuntu2404-aarch64/swift-${VER}-RELEASE/swift-${VER}-RELEASE-ubuntu24.04-aarch64.tar.gz"
        else
            SWIFT_URL="https://download.swift.org/swift-${VER}-release/ubuntu2404/swift-${VER}-RELEASE/swift-${VER}-RELEASE-ubuntu24.04.tar.gz"
        fi
        curl -fsSL "$SWIFT_URL" | $SUDO tar -C /usr/local --strip-components=2 -xz
    fi
}

uninstall_macos() { echo "Xcode Swift — not removing."; }
uninstall_linux() { echo "Manual Swift install — remove from /usr/local manually if needed."; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/public static let version = "[^"]*"/public static let version = "'"${ver}"'"/' \
        "${ROOT}/src/swift/Sources/ParentTime/ParentTime.swift"
}

case "${1:-}" in
    install)     log "Installing Swift..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Swift..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
