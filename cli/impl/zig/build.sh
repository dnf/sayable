#!/usr/bin/env bash
# Build the Sayable Zig CLI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

mkdir -p "${BUILD_DIR}"

(
    cd "${SCRIPT_DIR}"
    zig build -Doptimize=ReleaseFast --prefix "${BUILD_DIR}" 2>&1
)

echo "Built: ${BUILD_DIR}/bin/sayable"
