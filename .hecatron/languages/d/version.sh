#!/usr/bin/env bash
# Update D version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/enum VERSION = "[^"]*"/enum VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/d/source/sayableage/format_age.d"
_sed_i 's/"version": "[^"]*"/"version": "'"${ver}"'"/' \
    "${ROOT}/age/impl/d/dub.json"
