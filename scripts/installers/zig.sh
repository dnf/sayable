#!/usr/bin/env bash
# Installer for Zig
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install zig; }
install_linux() {
    if ! has zig; then
        ARCH="$(dpkg --print-architecture)"
        ZIG_ARCH="$ARCH"
        if [ "$ARCH" = "amd64" ]; then ZIG_ARCH="x86_64"; fi
        if [ "$ARCH" = "arm64" ]; then ZIG_ARCH="aarch64"; fi
        curl -fsSL "https://ziglang.org/download/0.14.1/zig-linux-${ZIG_ARCH}-0.14.1.tar.xz" | \
            $SUDO tar -C /usr/local --strip-components=1 -xJ
    fi
}

uninstall_macos() { brew uninstall zig 2>/dev/null || true; }
uninstall_linux() { echo "Manual Zig install — remove from /usr/local manually if needed."; }

deps() { :; }

case "${1:-}" in
    install)   log "Installing Zig..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Zig..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
