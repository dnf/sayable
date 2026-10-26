#!/usr/bin/env bash
# Update Groovy version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/static final String VERSION = "[^"]*"/static final String VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/groovy/src/main/groovy/sayableage/SayableAge.groovy"
_sed_i "s/^version = '[^']*'/version = '${ver}'/" \
    "${ROOT}/age/impl/groovy/build.gradle"
