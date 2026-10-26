#!/usr/bin/env bash
# Update Gleam package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i 's/^description = "[^"]*"/description = "'"${PT_DESCRIPTION}"'"/' \
    "${ROOT}/age/impl/gleam/gleam.toml"
_sed_i 's/^licences = \["[^"]*"\]/licences = ["'"${PT_LICENSE}"'"]/' \
    "${ROOT}/age/impl/gleam/gleam.toml"
