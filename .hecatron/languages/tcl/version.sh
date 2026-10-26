#!/usr/bin/env bash
# Update Tcl version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/variable VERSION "[^"]*"/variable VERSION "'"${ver}"'"/' \
    "${ROOT}/age/impl/tcl/sayableage.tcl"
_sed_i 's/package provide sayableage [^ ]*/package provide sayableage '"${ver}"'/' \
    "${ROOT}/age/impl/tcl/sayableage.tcl"
_sed_i 's/package ifneeded sayableage [^ ]*/package ifneeded sayableage '"${ver}"'/' \
    "${ROOT}/age/impl/tcl/pkgIndex.tcl"
