#!/usr/bin/env bash
# Update F# version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/\[<Literal>\] Version = "[^"]*"/[<Literal>] Version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/fsharp/SayableAge/Formatter.fs"
_sed_i 's/<Version>[^<]*<\/Version>/<Version>'"${ver}"'<\/Version>/' \
    "${ROOT}/age/impl/fsharp/SayableAge/SayableAge.fsproj"
