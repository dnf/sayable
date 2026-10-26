#!/usr/bin/env bash
# Update Erlang version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/-define(VERSION, "[^"]*")/-define(VERSION, "'"${ver}"'")/' \
    "${ROOT}/age/impl/erlang/include/sayableage.hrl"
_sed_i 's/{vsn, "[^"]*"}/{vsn, "'"${ver}"'"}/' \
    "${ROOT}/age/impl/erlang/src/sayableage.app.src"
