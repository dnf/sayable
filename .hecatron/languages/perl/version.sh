#!/usr/bin/env bash
# Update Perl version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i "s/our \$VERSION = '[^']*'/our \$VERSION = '${ver}'/" \
    "${ROOT}/age/impl/perl/lib/SayableAge/Formatter.pm"
