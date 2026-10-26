#!/usr/bin/env bash
# Update Raku version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/"version": "[^"]*"/"version": "'"${ver}"'"/' \
    "${ROOT}/age/impl/raku/META6.json"
