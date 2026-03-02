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

case "${1:-}" in
    install)   log "Installing PHP..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling PHP..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
