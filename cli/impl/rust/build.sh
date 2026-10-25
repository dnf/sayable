#!/usr/bin/env bash
# Build the Sayable Rust CLI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

cargo build --release --manifest-path "${SCRIPT_DIR}/Cargo.toml"

echo "Built: ${SCRIPT_DIR}/target/release/sayable"
