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
        $SUDO mkdir -p /opt/zig
        curl -fsSL "https://ziglang.org/download/0.14.0/zig-linux-${ZIG_ARCH}-0.14.0.tar.xz" | \
            $SUDO tar -C /opt/zig --strip-components=1 -xJ
        $SUDO ln -sf /opt/zig/zig /usr/local/bin/zig
    fi
}

uninstall_macos() { brew uninstall zig 2>/dev/null || true; }
uninstall_linux() { $SUDO rm -rf /opt/zig /usr/local/bin/zig; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/pub const version = "[^"]*"/pub const version = "'"${ver}"'"/' \
        "${ROOT}/src/zig/src/parenttime.zig"
    _sed_i 's/\.version = "[^"]*"/.version = "'"${ver}"'"/' \
        "${ROOT}/src/zig/build.zig.zon"
}

case "${1:-}" in
    install)     log "Installing Zig..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Zig..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata) ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
