#!/usr/bin/env bash
# Installer for Python 3 + uv
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install python uv; }
install_linux() {
    apt_install python3 python3-venv
    if ! has uv; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

uninstall_macos() { brew uninstall python uv 2>/dev/null || true; }
uninstall_linux() {
    $SUDO apt-get remove -y python3 python3-venv 2>/dev/null || true
    rm -f "$HOME/.local/bin/uv"
}

deps() { (cd "$ROOT/src/python" && uv sync --extra dev); }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/__version__ = "[^"]*"/__version__ = "'"${ver}"'"/' \
        "${ROOT}/src/python/src/parent_time/format_age.py"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/python/pyproject.toml"
    if has uv; then
        (cd "${ROOT}/src/python" && uv lock)
    fi
}

case "${1:-}" in
    install)     log "Installing Python..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Python..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i 's/^description = "[^"]*"/description = "'"${PT_DESCRIPTION}"'"/' \
            "${ROOT}/src/python/pyproject.toml"
        _sed_i 's/^license = "[^"]*"/license = "'"${PT_LICENSE}"'"/' \
            "${ROOT}/src/python/pyproject.toml"
        _sed_i 's/authors = \[{ name = "[^"]*" }\]/authors = [{ name = "'"${PT_AUTHOR}"'" }]/' \
            "${ROOT}/src/python/pyproject.toml"
        _sed_i 's|^Repository = "[^"]*"|Repository = "'"${PT_REPOSITORY}"'"|' \
            "${ROOT}/src/python/pyproject.toml"
        _sed_i 's|^Documentation = "[^"]*"|Documentation = "'"${PT_REPOSITORY}"'/tree/main/src/python#readme"|' \
            "${ROOT}/src/python/pyproject.toml"
        _sed_i 's|^Issues = "[^"]*"|Issues = "'"${PT_REPOSITORY}"'/issues"|' \
            "${ROOT}/src/python/pyproject.toml"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
