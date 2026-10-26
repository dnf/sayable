#!/usr/bin/env bash
# Update Wren version in source
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/static version { "[^"]*" }/static version { "'"${ver}"'" }/' \
    "${ROOT}/age/impl/wren/sayableage.wren"
