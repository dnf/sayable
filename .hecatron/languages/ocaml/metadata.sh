#!/usr/bin/env bash
# Update OCaml package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i 's/^synopsis: "[^"]*"/synopsis: "'"${PT_DESCRIPTION}"'"/' \
    "${ROOT}/age/impl/ocaml/sayable_age.opam"
_sed_i 's/^maintainer: \["[^"]*"\]/maintainer: ["'"${PT_AUTHOR}"'"]/' \
    "${ROOT}/age/impl/ocaml/sayable_age.opam"
