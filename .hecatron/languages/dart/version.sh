#!/usr/bin/env bash
# Update Dart version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i "s/const String version = '[^']*'/const String version = '${ver}'/" \
    "${ROOT}/age/impl/dart/lib/src/format_age.dart"
_sed_i "s/^version: .*/version: ${ver}/" \
    "${ROOT}/age/impl/dart/pubspec.yaml"
