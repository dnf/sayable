#!/usr/bin/env bash
# Update Nim version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/const Version\* = "[^"]*"/const Version* = "'"${ver}"'"/' \
    "${ROOT}/age/impl/nim/src/sayable_age/formatter.nim"
_sed_i 's/^version  *= "[^"]*"/version       = "'"${ver}"'"/' \
    "${ROOT}/age/impl/nim/sayable_age.nimble"
