#!/usr/bin/env bash
# Update Pascal version in source
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i "s/SayableAgeVersion = '[^']*'/SayableAgeVersion = '${ver}'/" \
    "${ROOT}/age/impl/pascal/SayableAge.pas"
