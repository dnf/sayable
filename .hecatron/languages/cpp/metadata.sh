#!/usr/bin/env bash
# Update C++ package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i 's|DESCRIPTION "[^"]*"|DESCRIPTION "'"${PT_DESCRIPTION}"'"|' \
    "${ROOT}/age/impl/cpp/CMakeLists.txt"
_sed_i 's|HOMEPAGE_URL "[^"]*"|HOMEPAGE_URL "'"${PT_REPOSITORY}"'"|' \
    "${ROOT}/age/impl/cpp/CMakeLists.txt"
