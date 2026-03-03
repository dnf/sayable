#!/usr/bin/env bash
# Installer for Gleam (requires Erlang/OTP — shared with Erlang and Elixir)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install gleam; }
install_linux() {
    local version="1.6.1"
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

case "${1:-}" in
    install)   log "Installing Gleam..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Gleam..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
