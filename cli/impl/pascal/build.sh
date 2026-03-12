#!/bin/bash
# Build the Sayable Pascal CLI binary.
# Requires fpc (Free Pascal Compiler).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

mkdir -p "${BUILD_DIR}"

fpc \
    -Fu"${PROJECT_ROOT}/age/impl/pascal" \
    -Fu"${PROJECT_ROOT}/age/impl/pascal/locales" \
    -Fu"${PROJECT_ROOT}/date/impl/pascal" \
    -Fu"${PROJECT_ROOT}/date/impl/pascal/locales" \
    -Fu"${PROJECT_ROOT}/duration/impl/pascal" \
    -Fu"${PROJECT_ROOT}/duration/impl/pascal/locales" \
    -Fu"${PROJECT_ROOT}/time/impl/pascal" \
    -Fu"${PROJECT_ROOT}/time/impl/pascal/locales" \
    -FE"${BUILD_DIR}" \
    -FU"${BUILD_DIR}" \
    "${SCRIPT_DIR}/sayable.pas"

echo "Built: ${BUILD_DIR}/sayable"
