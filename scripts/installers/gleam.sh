#!/usr/bin/env bash
# Installer for Gleam (requires Erlang/OTP — shared with Erlang and Elixir)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install gleam; }
install_linux() {
    local version="1.14.0"
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
        *)       echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
    local url="https://github.com/gleam-lang/gleam/releases/download/v${version}/gleam-v${version}-${arch}-unknown-linux-musl.tar.gz"
    curl -fsSL "$url" | $SUDO tar xz -C /usr/local/bin gleam
}

uninstall_macos() { brew uninstall gleam 2>/dev/null || true; }
uninstall_linux() { $SUDO rm -f /usr/local/bin/gleam; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/pub const version = "[^"]*"/pub const version = "'"${ver}"'"/' \
        "${ROOT}/src/gleam/src/parenttime/formatter.gleam"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/gleam/gleam.toml"
}

case "${1:-}" in
    install)     log "Installing Gleam..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Gleam..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's/^description = "[^"]*"/description = "'"${PT_DESCRIPTION}"'"/' \
            "${ROOT}/src/gleam/gleam.toml"
        _sed_i 's/^licences = \["[^"]*"\]/licences = ["'"${PT_LICENSE}"'"]/' \
            "${ROOT}/src/gleam/gleam.toml"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
