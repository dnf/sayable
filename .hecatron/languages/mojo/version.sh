#!/usr/bin/env bash
# Update Mojo version in source
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^alias VERSION = "[^"]*"/alias VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/mojo/src/sayable_age/formatter.mojo"
