#!/usr/bin/env bash
# Update R version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/SAYABLEAGE_VERSION <- "[^"]*"/SAYABLEAGE_VERSION <- "'"${ver}"'"/' \
    "${ROOT}/age/impl/r/R/version.R"
_sed_i 's/^Version: .*/Version: '"${ver}"'/' \
    "${ROOT}/age/impl/r/DESCRIPTION"
