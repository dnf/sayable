#!/usr/bin/env bash
# Installer for OCaml (opam + dune + alcotest)
source "$(dirname "$0")/_common.sh"

install_macos() {
    if ! has opam; then
        brew_install opam
    fi
    opam init --auto-setup --disable-sandboxing --yes 2>/dev/null || true
    eval "$(opam env)"
    opam install dune alcotest --yes
}

install_linux() {
    if ! has opam; then
        apt_install opam
    fi
    opam init --auto-setup --disable-sandboxing --yes 2>/dev/null || true
    eval "$(opam env)"
    opam install dune alcotest --yes
}

uninstall_macos() {
    brew uninstall opam 2>/dev/null || true
    rm -rf "$HOME/.opam"
}

uninstall_linux() {
    $SUDO apt-get remove -y opam 2>/dev/null || true
    rm -rf "$HOME/.opam"
}

deps() {
    cd "$ROOT/src/ocaml"
    eval "$(opam env)" 2>/dev/null || true
}

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/^let version = "[^"]*"/let version = "'"${ver}"'"/' \
        "${ROOT}/src/ocaml/lib/formatter.ml"
    _sed_i 's/^version: "[^"]*"/version: "'"${ver}"'"/' \
        "${ROOT}/src/ocaml/parent_time.opam"
    _sed_i 's/(version [^)]*)/(version '"${ver}"')/' \
        "${ROOT}/src/ocaml/dune-project"
}

case "${1:-}" in
    install)     log "Installing OCaml..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling OCaml..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's/^synopsis: "[^"]*"/synopsis: "'"${PT_DESCRIPTION}"'"/' \
            "${ROOT}/src/ocaml/parent_time.opam"
        _sed_i 's/^maintainer: \["[^"]*"\]/maintainer: ["'"${PT_AUTHOR}"'"]/' \
            "${ROOT}/src/ocaml/parent_time.opam"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
