#!/usr/bin/env bash
# Update COBOL version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i '/PT-VERSION/s/VALUE "[^"]*"/VALUE "'"${ver}"'"/' \
    "${ROOT}/age/impl/cobol/src/Types.cbl"
