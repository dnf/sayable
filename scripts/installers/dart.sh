#!/usr/bin/env bash
# Installer for Dart
source "$(dirname "$0")/_common.sh"

install_macos() { brew_install dart-sdk; }
install_linux() {
    if ! has dart; then
        ARCH="$(dpkg --print-architecture)"
        curl -fsSL "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-${ARCH}-release.zip" -o /tmp/dart-sdk.zip
        $SUDO unzip -q -o /tmp/dart-sdk.zip -d /opt
        rm -f /tmp/dart-sdk.zip
        $SUDO ln -sf /opt/dart-sdk/bin/dart /usr/local/bin/dart
    fi
}

uninstall_macos() { brew uninstall dart-sdk 2>/dev/null || true; }
uninstall_linux() { $SUDO rm -rf /opt/dart-sdk && $SUDO rm -f /usr/local/bin/dart; }

deps() {
    if [ -d "src/dart" ] && has dart; then
        (cd src/dart && dart pub get)
    fi
}

case "${1:-}" in
    install)   log "Installing Dart..."; "install_${OS}"; deps ;;
    uninstall) log "Uninstalling Dart..."; "uninstall_${OS}" ;;
    *)         echo "Usage: $0 {install|uninstall}" >&2; exit 1 ;;
esac
