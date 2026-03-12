#!/usr/bin/env bash
# Build the Sayable Odin CLI binary.
# Requires odin.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
OUT="${SCRIPT_DIR}/sayable"

odin build "${SCRIPT_DIR}" \
    -collection:sayable="${PROJECT_ROOT}" \
    -out:"${OUT}" \
    -o:speed

echo "Built: ${OUT}"
