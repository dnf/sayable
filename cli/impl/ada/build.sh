#!/usr/bin/env bash
# Build the Sayable Ada CLI
# Compiles main.adb against all four component libraries (age, date, time, duration)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

# Add Alire toolchain bins to PATH if gprbuild is not already available
if ! command -v gprbuild &>/dev/null; then
    for dir in "${HOME}/.local/share/alire/toolchains"/*/bin; do
        if [[ -d "${dir}" ]]; then
            export PATH="${dir}:${PATH}"
        fi
    done
fi

if ! command -v gprbuild &>/dev/null; then
    echo "error: gprbuild not found. Install GNAT via 'just install ada'" >&2
    exit 1
fi

# Find macOS SDK library path for linker (needed on newer macOS with Alire GNAT)
SDK_LIB=""
if [[ "$(uname -s)" == "Darwin" ]]; then
    SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null || true)"
    if [[ -n "${SDK_PATH}" ]]; then
        SDK_LIB="${SDK_PATH}/usr/lib"
    fi
fi

mkdir -p "${BUILD_DIR}"

# Build using GPR project (handles non-standard file naming)
gprbuild -P "${SCRIPT_DIR}/sayable_cli.gpr" \
    -XSDK_LIB="${SDK_LIB}" \
    -p -q

echo "Built: ${BUILD_DIR}/main"
