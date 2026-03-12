#!/usr/bin/env bash
# Build the Sayable COBOL CLI
# Compiles separate COBOL programs for each component (age, date, time, duration)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

mkdir -p "${BUILD_DIR}"

# Suppress Clang's -Winvalid-source-encoding for UTF-8 locale strings
COB_CFLAGS_BASE="$(cobc --info 2>/dev/null | grep 'COB_CFLAGS' | head -1 | sed 's/COB_CFLAGS[[:space:]]*://')"
export COB_CFLAGS="${COB_CFLAGS_BASE} -Wno-invalid-source-encoding"

echo "Building COBOL CLI components..."

cd "${PROJECT_ROOT}"

cobc -free -x \
    -o "${BUILD_DIR}/age_cli" \
    "${SCRIPT_DIR}/age_cli.cbl" 2>/dev/null
echo "  Built: age_cli"

cobc -free -x \
    -o "${BUILD_DIR}/date_cli" \
    "${SCRIPT_DIR}/date_cli.cbl" 2>/dev/null
echo "  Built: date_cli"

cobc -free -x \
    -o "${BUILD_DIR}/time_cli" \
    "${SCRIPT_DIR}/time_cli.cbl" 2>/dev/null
echo "  Built: time_cli"

cobc -free -x \
    -o "${BUILD_DIR}/duration_cli" \
    "${SCRIPT_DIR}/duration_cli.cbl" 2>/dev/null
echo "  Built: duration_cli"

echo "Built: ${BUILD_DIR}/"
