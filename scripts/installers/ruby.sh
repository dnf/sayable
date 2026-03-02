#!/usr/bin/env bash
# Installer for Ruby
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install ruby; }
install_linux() { apt_install ruby ruby-bundler; }

uninstall_macos() { brew uninstall ruby 2>/dev/null || true; }
uninstall_linux() { $SUDO apt-get remove -y ruby ruby-bundler 2>/dev/null || true; }

deps() { (cd "$ROOT/src/ruby" && bundle install); }

case "${1:-}" in
    install)   log "Installing Ruby..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Ruby..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
