#!/usr/bin/env bash
# Update Fortran version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/PT_VERSION = "[^"]*"/PT_VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/fortran/src/sayableage.f90"
