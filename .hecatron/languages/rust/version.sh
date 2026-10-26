#!/usr/bin/env bash
# Update Rust version in source and manifests
# _common.sh ships with hecatron, outside this repository.
# shellcheck source=/dev/null
source "${HECATRON_HOME}/languages/_common.sh"

ver="${1:?version required}"
_sed_i 's/pub const VERSION: &str = "[^"]*"/pub const VERSION: \&str = "'"${ver}"'"/' \
    "${ROOT}/age/impl/rust/src/formatter.rs"
_sed_i 's/^version = "[^"]*"/version = "'"${ver}"'"/' \
    "${ROOT}/age/impl/rust/Cargo.toml"
if has cargo; then
    (cd "${ROOT}/age/impl/rust" && cargo generate-lockfile)
fi
