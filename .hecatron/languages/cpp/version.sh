#!/usr/bin/env bash
# Update C++ version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/constexpr const char\* VERSION = "[^"]*"/constexpr const char* VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/cpp/include/sayableage/types.hpp"
_sed_i 's/VERSION [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/VERSION '"${ver}"'/' \
    "${ROOT}/age/impl/cpp/CMakeLists.txt"
