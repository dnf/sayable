#!/usr/bin/env bash
# Build the Sayable C CLI
# Compiles main.c against all four component libraries (age, date, time, duration)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

AGE_C="${PROJECT_ROOT}/age/impl/c"
DATE_C="${PROJECT_ROOT}/date/impl/c"
TIME_C="${PROJECT_ROOT}/time/impl/c"
DURATION_C="${PROJECT_ROOT}/duration/impl/c"

# Build each component library if not already built
for component_dir in "${AGE_C}" "${DATE_C}" "${TIME_C}" "${DURATION_C}"; do
    component_build="${component_dir}/build"
    if [[ ! -d "${component_build}" ]]; then
        mkdir -p "${component_build}"
    fi
    # Build the static library
    (
        cd "${component_build}"
        cmake .. -DCMAKE_BUILD_TYPE=Release >/dev/null 2>&1
        cmake --build . --parallel >/dev/null 2>&1
    )
done

mkdir -p "${BUILD_DIR}"

# Compile and link
cc -std=c11 -Wall -Wextra -O2 \
    -I "${AGE_C}/include" \
    -I "${DATE_C}/include" \
    -I "${TIME_C}/include" \
    -I "${DURATION_C}/include" \
    "${SCRIPT_DIR}/main.c" \
    "${AGE_C}/build/libsayableage_c.a" \
    "${DATE_C}/build/libsayabledate_c.a" \
    "${TIME_C}/build/libsayabletime_c.a" \
    "${DURATION_C}/build/libsayableduration_c.a" \
    -o "${BUILD_DIR}/sayable"

echo "Built: ${BUILD_DIR}/sayable"
