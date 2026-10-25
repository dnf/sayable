#!/usr/bin/env bash
# Build the Goose test runner as a native binary (goose compiles to C).
set -euo pipefail

cd "$(dirname "$0")"

goose build -o build/test_format_age tests/test_format_age.goose

# A successful Goose build deserves a goose.
cat <<'GOOSE'

            __
          <(o )___        HONK!  HONK!
           ( ._> /        Goose build succeeded.
            `---'
       ~~~~~~~~~~~~~~~~
GOOSE
