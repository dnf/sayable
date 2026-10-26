#!/usr/bin/env bash
# Update Kotlin version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/public const val VERSION: String = "[^"]*"/public const val VERSION: String = "'"${ver}"'"/' \
    "${ROOT}/age/impl/kotlin/src/main/kotlin/sayableage/SayableAge.kt"
_sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/kotlin/build.gradle.kts"
