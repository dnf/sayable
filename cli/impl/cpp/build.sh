#!/usr/bin/env bash
# Build the Sayable C++ CLI
# Compiles main.cpp with all four component libraries (age, date, time, duration)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

AGE_CPP="${PROJECT_ROOT}/age/impl/cpp"
DATE_CPP="${PROJECT_ROOT}/date/impl/cpp"
TIME_CPP="${PROJECT_ROOT}/time/impl/cpp"
DURATION_CPP="${PROJECT_ROOT}/duration/impl/cpp"

# Detect compiler
if command -v g++ &>/dev/null; then
    CXX="g++"
elif command -v clang++ &>/dev/null; then
    CXX="clang++"
else
    echo "error: no C++ compiler found (need g++ or clang++)" >&2
    exit 1
fi

# Collect all source files
SOURCES=(
    "${SCRIPT_DIR}/main.cpp"
)

for component_dir in "${AGE_CPP}" "${DATE_CPP}" "${TIME_CPP}" "${DURATION_CPP}"; do
    while IFS= read -r -d '' src; do
        SOURCES+=("${src}")
    done < <(find "${component_dir}/src" -name "*.cpp" -print0)
done

mkdir -p "${BUILD_DIR}"

# Compile and link
"${CXX}" -std=c++17 -Wall -Wextra -O2 \
    -I "${AGE_CPP}/include" \
    -I "${DATE_CPP}/include" \
    -I "${TIME_CPP}/include" \
    -I "${DURATION_CPP}/include" \
    "${SOURCES[@]}" \
    -o "${BUILD_DIR}/sayable"

echo "Built: ${BUILD_DIR}/sayable"
