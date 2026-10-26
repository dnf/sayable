#!/usr/bin/env bash
# Update Janet version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/^(def version "[^"]*")/(def version "'"${ver}"'")/' \
    "${ROOT}/age/impl/janet/sayableage.janet"
_sed_i 's/:version "[^"]*"/:version "'"${ver}"'"/' \
    "${ROOT}/age/impl/janet/project.janet"
