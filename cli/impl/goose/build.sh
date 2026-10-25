#!/usr/bin/env bash
# Build the Goose CLI natively (goose compiles to C).
#
# Everything goes to stderr: the sayable wrapper builds on demand, and
# stdout belongs to the CLI's answers.
set -euo pipefail

cd "$(dirname "$0")"

goose build -o build/sayable main.goose >&2

# A successful Goose build deserves a goose.
cat >&2 <<'GOOSE'

            __
          <(o )___        HONK!  HONK!
           ( ._> /        Goose CLI build succeeded.
            `---'
       ~~~~~~~~~~~~~~~~
GOOSE
