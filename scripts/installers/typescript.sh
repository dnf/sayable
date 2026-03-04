#!/usr/bin/env bash
# Installer for Node.js (TypeScript runtime)
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install node; }
install_linux() {
    if ! has node || ! node -v | grep -q '^v2[2-9]'; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | $SUDO bash -
        apt_install nodejs
    fi
}

uninstall_macos() { brew uninstall node 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y nodejs 2>/dev/null || true; }

deps() { (cd "$ROOT/src/typescript" && npm install); }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/export const VERSION = "[^"]*"/export const VERSION = "'"${ver}"'"/' \
        "${ROOT}/src/typescript/src/format-age.ts"
    _sed_i 's/"version": "[^"]*"/"version": "'"${ver}"'"/' \
        "${ROOT}/src/typescript/package.json"
    if has npm; then
        (cd "${ROOT}/src/typescript" && npm install --package-lock-only)
    fi
}

case "${1:-}" in
    install)     log "Installing TypeScript (Node.js)..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling TypeScript (Node.js)..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        python3 -c "
import json, os
f = os.path.join('${ROOT}', 'src', 'typescript', 'package.json')
with open(f) as fh: data = json.load(fh)
data['description'] = os.environ['PT_DESCRIPTION']
data['author'] = os.environ['PT_AUTHOR']
data['license'] = os.environ['PT_LICENSE']
data['repository']['url'] = os.environ['PT_REPOSITORY'] + '.git'
data['homepage'] = os.environ['PT_REPOSITORY']
data['bugs'] = os.environ['PT_REPOSITORY'] + '/issues'
with open(f, 'w') as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write('\n')
"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
