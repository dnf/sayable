#!/usr/bin/env bash
# Update Scala package metadata
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

_set_metadata_gradle_kts "${ROOT}/age/impl/scala/build.gradle.kts"
