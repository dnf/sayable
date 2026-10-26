#!/usr/bin/env bash
# Update C# version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/public const string Version = "[^"]*"/public const string Version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/csharp/SayableAge/SayableAge.cs"
_sed_i 's/<Version>[^<]*<\/Version>/<Version>'"${ver}"'<\/Version>/' \
    "${ROOT}/age/impl/csharp/SayableAge/SayableAge.csproj"
