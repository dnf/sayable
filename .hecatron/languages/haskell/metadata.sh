#!/usr/bin/env bash
# Update Haskell package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i "s/^license:       .*/license:       ${PT_LICENSE}/" \
    "${ROOT}/age/impl/haskell/sayable-age.cabal"
