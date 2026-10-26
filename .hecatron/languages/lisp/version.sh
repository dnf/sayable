#!/usr/bin/env bash
# Update Common Lisp version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^(defvar +version+ "[^"]*"/(defvar +version+ "'"${ver}"'"/' \
    "${ROOT}/age/impl/lisp/formatter.lisp"
_sed_i 's/:version "[^"]*"/:version "'"${ver}"'"/' \
    "${ROOT}/age/impl/lisp/sayable-age.asd"
