#!/usr/bin/env bash
# Installer for Kotlin (uses JDK 17 — delegates to java.sh)
source "$(dirname "$0")/_common.sh"

install_macos() {
    if ! has java; then
        bash "$(dirname "$0")/java.sh" install
    fi
}

install_linux() {
    if ! has java; then
        bash "$(dirname "$0")/java.sh" install
    fi
}

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
    _sed_i 's/public const val VERSION: String = "[^"]*"/public const val VERSION: String = "'"${ver}"'"/' \
        "${ROOT}/src/kotlin/src/main/kotlin/parenttime/ParentTime.kt"
    _sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
        "${ROOT}/src/kotlin/build.gradle.kts"
}

case "${1:-}" in
    install)     log "Installing Kotlin (JDK 17)..."; "install_${OS}"; deps ;;
    uninstall)   log "Uninstalling Kotlin..."; "uninstall_${OS}" ;;
    set-version)  set_version "$2" ;;
    set-metadata)
        _set_metadata_gradle_kts "${ROOT}/src/kotlin/build.gradle.kts"
        ;;
    *)            echo "Usage: $0 {install|uninstall|set-version|set-metadata}" >&2; exit 1 ;;
esac
