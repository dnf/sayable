#!/usr/bin/env bash
# Build the Sayable Mojo CLI binary (build/sayable).
# Requires mojo on PATH, or pixi with the Mojo environment that the Mojo CI
# workflow creates in age/impl/mojo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
OUT="${SCRIPT_DIR}/build/sayable"
PIXI_MANIFEST="${PROJECT_ROOT}/age/impl/mojo/pixi.toml"

if command -v mojo &>/dev/null; then
    mojo=(mojo)
elif command -v pixi &>/dev/null && [[ -f "${PIXI_MANIFEST}" ]]; then
    mojo=(pixi run --manifest-path "${PIXI_MANIFEST}" mojo)
else
    echo "error: mojo not found (install it, or pixi with ${PIXI_MANIFEST})" >&2
    exit 2
fi

mkdir -p "${SCRIPT_DIR}/build"
# -g0: without debug info the build peaks at ~3.4 GB instead of ~8.9 GB.
"${mojo[@]}" build -g0 \
    -I "${PROJECT_ROOT}/age/impl/mojo/src" \
    -I "${PROJECT_ROOT}/date/impl/mojo/src" \
    -I "${PROJECT_ROOT}/duration/impl/mojo/src" \
    -I "${PROJECT_ROOT}/time/impl/mojo/src" \
    -o "${OUT}" \
    "${SCRIPT_DIR}/main.mojo"

echo "Built: ${OUT}"
