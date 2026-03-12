#!/usr/bin/env bash
# Build the Sayable Fortran CLI
# Compiles main.f90 against all four component libraries (age, date, time, duration)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

AGE_DIR="${PROJECT_ROOT}/age/impl/fortran"
DATE_DIR="${PROJECT_ROOT}/date/impl/fortran"
TIME_DIR="${PROJECT_ROOT}/time/impl/fortran"
DURATION_DIR="${PROJECT_ROOT}/duration/impl/fortran"

# Build each component library if not already built
for component_dir in "${AGE_DIR}" "${DATE_DIR}" "${TIME_DIR}" "${DURATION_DIR}"; do
    component_build="${component_dir}/build"
    if [[ ! -d "${component_build}" ]]; then
        mkdir -p "${component_build}"
    fi
    (
        cd "${component_build}"
        cmake .. -DCMAKE_BUILD_TYPE=Release >/dev/null 2>&1
        cmake --build . --parallel >/dev/null 2>&1
    )
done

mkdir -p "${BUILD_DIR}"

# Collect module directories (where .mod files live)
AGE_MOD="${AGE_DIR}/build/modules"
DATE_MOD="${DATE_DIR}/build/modules"
TIME_MOD="${TIME_DIR}/build/modules"
DURATION_MOD="${DURATION_DIR}/build/modules"

# Collect static libraries
AGE_LIB="${AGE_DIR}/build/libsayableage_fortran.a"
DATE_LIB="${DATE_DIR}/build/libsayabledate.a"
TIME_LIB="${TIME_DIR}/build/libsayabletime.a"
DURATION_LIB="${DURATION_DIR}/build/libsayableduration.a"

# Compile and link
gfortran -O2 -ffree-form -std=f2008 \
    -I "${AGE_MOD}" \
    -I "${DATE_MOD}" \
    -I "${TIME_MOD}" \
    -I "${DURATION_MOD}" \
    "${SCRIPT_DIR}/main.f90" \
    "${AGE_LIB}" \
    "${DATE_LIB}" \
    "${TIME_LIB}" \
    "${DURATION_LIB}" \
    -o "${BUILD_DIR}/sayable"

echo "Built: ${BUILD_DIR}/sayable"
