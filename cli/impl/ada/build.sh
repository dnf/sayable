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

# Newer macOS with Alire GNAT needs the SDK library path to link. Elsewhere
# no path is passed: a bare "-L" would swallow the next linker argument.
LINKER_ARGS=()
if [[ "$(uname -s)" == "Darwin" ]]; then
    SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null || true)"
    if [[ -n "${SDK_PATH}" ]]; then
        LINKER_ARGS=(-largs "-L${SDK_PATH}/usr/lib")
    fi
fi

mkdir -p "${BUILD_DIR}"

gprbuild -P "${SCRIPT_DIR}/sayable_cli.gpr" -p -q ${LINKER_ARGS[@]+"${LINKER_ARGS[@]}"}

echo "Built: ${BUILD_DIR}/main"
