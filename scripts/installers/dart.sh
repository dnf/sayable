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

set_version() {
    local ver="${1:?version required}"
    _sed_i "s/const String version = '[^']*'/const String version = '${ver}'/" \
        "${ROOT}/src/dart/lib/src/format_age.dart"
    _sed_i "s/^version: .*/version: ${ver}/" \
        "${ROOT}/src/dart/pubspec.yaml"
}

case "${1:-}" in
    install)     log "Installing Dart..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Dart..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _sed_i "s/^description: .*/description: ${PT_DESCRIPTION}/" \
            "${ROOT}/src/dart/pubspec.yaml"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
