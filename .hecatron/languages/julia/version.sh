#!/usr/bin/env bash
# Update Julia version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/julia/Project.toml"
_sed_i 's/const VERSION = "[^"]*"/const VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/julia/src/SayableAge.jl"
