#!/usr/bin/env bash
# Build the Sayable Go CLI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

(
    cd "${SCRIPT_DIR}"
    go build -o "${SCRIPT_DIR}/sayable" .
)

echo "Built: ${SCRIPT_DIR}/sayable"
