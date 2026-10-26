#!/usr/bin/env bash
# Update C version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/#define SAYABLEAGE_VERSION "[^"]*"/#define SAYABLEAGE_VERSION "'"${ver}"'"/' \
    "${ROOT}/age/codegen/targets/c/emitter.py"
