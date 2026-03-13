#!/usr/bin/env bash
# Build the V CLI by copying component locales under unique module names.
#
# V's module system requires all files in a directory to share one module name.
# The four Sayable components each have their own `module locales`, so we can't
# import them all into one binary directly. This script copies each component's
# locales into a uniquely-named module directory, rewrites the module declaration,
# and compiles the unified CLI.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

cd "${SCRIPT_DIR}"

# Copy component locales with unique module names
for comp in age date duration time; do
    target="${comp}_locales"
    rm -rf "${target}"
    mkdir -p "${target}"
    src="${ROOT}/${comp}/impl/v/locales"
    for f in "${src}"/*.v; do
        base="$(basename "${f}")"
        # Skip test files
        case "${base}" in
            *_test.v) continue ;;
        esac
        sed "s/^module locales$/module ${target}/" "${f}" > "${target}/${base}"
    done
done

# Compile
mkdir -p build
v -o build/sayable "${SCRIPT_DIR}/sayable.v"

# Clean up temporary module directories (binary is cached)
rm -rf age_locales date_locales duration_locales time_locales
