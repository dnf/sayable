#!/usr/bin/env bash
# Update Erlang package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i 's/{description, "[^"]*"}/{description, "'"${PT_DESCRIPTION}"'"}/' \
    "${ROOT}/age/impl/erlang/src/sayableage.app.src"
_sed_i 's/{licenses, \["[^"]*"\]}/{licenses, ["'"${PT_LICENSE}"'"]}/' \
    "${ROOT}/age/impl/erlang/src/sayableage.app.src"
