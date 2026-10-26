#!/usr/bin/env bash
# Update Elm version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^    "[0-9][^"]*"/    "'"${ver}"'"/' \
    "${ROOT}/age/impl/elm/src/SayableAge/Formatter.elm"
