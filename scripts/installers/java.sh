#!/usr/bin/env bash
# Installer for OpenJDK 17 (shared by Java, Kotlin, Scala, Groovy)
source "$(dirname "$0")/_common.sh"

install_macos() {
    brew_install openjdk@17
    # Make Java 17 available to /usr/libexec/java_home
    OPENJDK_PATH="$(brew --prefix openjdk@17)/libexec/openjdk.jdk"
    JVM_DIR="/Library/Java/JavaVirtualMachines/openjdk-17.jdk"
    if [ -d "$OPENJDK_PATH" ] && [ ! -e "$JVM_DIR" ]; then
        log "Symlinking OpenJDK 17 (requires sudo)..."
        $SUDO ln -sfn "$OPENJDK_PATH" "$JVM_DIR" || \
            echo "   Skipped (run manually: sudo ln -sfn $OPENJDK_PATH $JVM_DIR)"
    fi
}

install_linux() { apt_install openjdk-17-jdk-headless; }

uninstall_macos() {
    echo "JDK 17 is shared by Java, Kotlin, Scala, and Groovy — not removing."
    echo "To force: brew uninstall openjdk@17"
}

uninstall_linux() {
    echo "JDK 17 is shared by Java, Kotlin, Scala, and Groovy — not removing."
    echo "To force: sudo apt-get remove -y openjdk-17-jdk-headless"
}

deps() { :; }

set_version() {
    local ver="${1:?version required}"
    _sed_i 's/public static final String VERSION = "[^"]*"/public static final String VERSION = "'"${ver}"'"/' \
        "${ROOT}/src/java/src/main/java/parenttime/ParentTime.java"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/java/build.gradle.kts"
}

case "${1:-}" in
    install)     log "Installing Java (OpenJDK 17)..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Java..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _set_metadata_gradle_kts "${ROOT}/src/java/build.gradle.kts"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
