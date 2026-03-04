#!/usr/bin/env bash
# Installer for PHP + Composer
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install php composer; }
install_linux() {
    apt_install php-cli php-xml php-mbstring
    if ! has composer; then
        curl -sS https://getcomposer.org/installer | $SUDO php -- --install-dir=/usr/local/bin --filename=composer
    fi
}

uninstall_macos() { brew uninstall php composer 2>/dev/null || true; }
uninstall_linux() {
    # Remove both metapackages and versioned packages (e.g. php8.3-cli)
    $SUDO apt-get remove -y 'php*' 2>/dev/null || true
    $SUDO apt-get autoremove -y 2>/dev/null || true
    $SUDO rm -f /usr/local/bin/composer
}

deps() { (cd "$ROOT/src/php" && composer install); }

set_version() {
    local ver="${1:?version required}"
    _sed_i "s/public const VERSION = '[^']*'/public const VERSION = '${ver}'/" \
        "${ROOT}/src/php/src/ParentTime.php"
}

case "${1:-}" in
    install)     log "Installing PHP..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling PHP..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        python3 -c "
import json, os
f = os.path.join('${ROOT}', 'src', 'php', 'composer.json')
with open(f) as fh: data = json.load(fh)
data['description'] = os.environ['PT_DESCRIPTION']
data['license'] = os.environ['PT_LICENSE']
data['authors'] = [{'name': os.environ['PT_AUTHOR']}]
data['homepage'] = os.environ['PT_REPOSITORY']
data['support']['source'] = os.environ['PT_REPOSITORY'] + '/tree/main/src/php'
data['support']['issues'] = os.environ['PT_REPOSITORY'] + '/issues'
with open(f, 'w') as fh:
    json.dump(data, fh, indent=4, ensure_ascii=False)
    fh.write('\n')
"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
