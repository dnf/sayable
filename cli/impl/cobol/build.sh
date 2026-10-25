#!/usr/bin/env bash
# Build the Sayable COBOL CLI
# Links the entry point and the component programs (age, date, time,
# duration) into one executable
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

mkdir -p "${BUILD_DIR}"

# Suppress Clang's -Winvalid-source-encoding for UTF-8 locale strings
COB_CFLAGS_BASE="$(cobc --info 2>/dev/null | grep 'COB_CFLAGS' | head -1 | sed 's/COB_CFLAGS[[:space:]]*://')"
export COB_CFLAGS="${COB_CFLAGS_BASE} -Wno-invalid-source-encoding"

echo "Building COBOL CLI..."

cd "${PROJECT_ROOT}"

# One executable: sayable.cbl is the entry point and statically CALLs
# the component programs, so --repl answers every command in-process.
cobc -free -x -fstatic-call \
    -o "${BUILD_DIR}/sayable" \
    "${SCRIPT_DIR}/sayable.cbl" \
    "${SCRIPT_DIR}/age_cli.cbl" \
    "${SCRIPT_DIR}/date_cli.cbl" \
    "${SCRIPT_DIR}/time_cli.cbl" \
    "${SCRIPT_DIR}/duration_cli.cbl" 2>/dev/null

echo "Built: ${BUILD_DIR}/sayable"
