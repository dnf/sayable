#!/usr/bin/env bash
# Update Swift version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/public static let version = "[^"]*"/public static let version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/swift/Sources/SayableAge/SayableAge.swift"
