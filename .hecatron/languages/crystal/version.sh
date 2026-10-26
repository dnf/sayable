#!/usr/bin/env bash
# Update Crystal version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/VERSION = "[^"]*"/VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/crystal/src/sayable_age/version.cr"
_sed_i 's/^version: .*/version: '"${ver}"'/' \
    "${ROOT}/age/impl/crystal/shard.yml"
