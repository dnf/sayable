#!/usr/bin/env bash
# Update Ruby version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i "s/VERSION = '[^']*'/VERSION = '${ver}'/" \
    "${ROOT}/age/impl/ruby/lib/sayable_age/version.rb"
