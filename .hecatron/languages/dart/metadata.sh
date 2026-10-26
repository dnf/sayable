#!/usr/bin/env bash
# Update Dart package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_sed_i "s/^description: .*/description: ${PT_DESCRIPTION}/" \
    "${ROOT}/age/impl/dart/pubspec.yaml"
