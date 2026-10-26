#!/usr/bin/env bash
# Update TypeScript version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/export const VERSION = "[^"]*"/export const VERSION = "'"${ver}"'"/' \
    "${ROOT}/age/impl/typescript/src/format-age.ts"
_sed_i 's/"version": "[^"]*"/"version": "'"${ver}"'"/' \
    "${ROOT}/age/impl/typescript/package.json"
if has npm; then
    (cd "${ROOT}/age/impl/typescript" && npm install --package-lock-only)
fi
