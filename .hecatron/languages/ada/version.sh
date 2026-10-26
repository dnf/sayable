#!/usr/bin/env bash
# Update Ada version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/Version : constant String := "[^"]*"/Version : constant String := "'"${ver}"'"/' \
    "${ROOT}/age/impl/ada/src/sayableage.ads"
