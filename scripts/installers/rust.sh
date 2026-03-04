#!/usr/bin/env bash
# Installer for Rust via rustup
source "$(dirname "$0")/_common.sh"

_install() {
    if ! has rustc; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
}

install_macos() { _install; }
install_linux() { _install; }

uninstall_macos() { rustup self uninstall -y 2>/dev/null || true; }
uninstall_linux() { rustup self uninstall -y 2>/dev/null || true; }

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/pub const VERSION: &str = "[^"]*"/pub const VERSION: \&str = "'"${ver}"'"/' \
        "${ROOT}/src/rust/src/formatter.rs"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/rust/Cargo.toml"
    if has cargo; then
        (cd "${ROOT}/src/rust" && cargo generate-lockfile)
    fi
}

case "${1:-}" in
    install)     log "Installing Rust..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Rust..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's/^description = "[^"]*"/description = "'"${PT_DESCRIPTION}"'"/' \
            "${ROOT}/src/rust/Cargo.toml"
        _sed_i 's/^license = "[^"]*"/license = "'"${PT_LICENSE}"'"/' \
            "${ROOT}/src/rust/Cargo.toml"
        _sed_i 's/^authors = \["[^"]*"\]/authors = ["'"${PT_AUTHOR}"'"]/' \
            "${ROOT}/src/rust/Cargo.toml"
        _sed_i 's|^repository = "[^"]*"|repository = "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/rust/Cargo.toml"
        _sed_i 's|^homepage = "[^"]*"|homepage = "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/rust/Cargo.toml"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
