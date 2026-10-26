#!/usr/bin/env bash
# Update OCaml version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^let version = "[^"]*"/let version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/ocaml/lib/formatter.ml"
_sed_i 's/^version: "[^"]*"/version: "'"${ver}"'"/' \
    "${ROOT}/age/impl/ocaml/sayable_age.opam"
_sed_i 's/(version [^)]*)/(version '"${ver}"')/' \
    "${ROOT}/age/impl/ocaml/dune-project"
