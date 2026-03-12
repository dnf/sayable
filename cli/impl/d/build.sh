#!/bin/bash
# Build the Sayable D CLI binary.
# Requires ldc2.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

AGE_SRC="${PROJECT_ROOT}/age/impl/d/source"
DATE_SRC="${PROJECT_ROOT}/date/impl/d/source"
DURATION_SRC="${PROJECT_ROOT}/duration/impl/d/source"
TIME_SRC="${PROJECT_ROOT}/time/impl/d/source"
CLI_SRC="${SCRIPT_DIR}/source"
OUT="${SCRIPT_DIR}/sayable"

ldc2 \
    -I="${AGE_SRC}" \
    -I="${DATE_SRC}" \
    -I="${DURATION_SRC}" \
    -I="${TIME_SRC}" \
    -I="${CLI_SRC}" \
    -of="${OUT}" \
    "${AGE_SRC}"/sayableage/locale.d \
    "${AGE_SRC}"/sayableage/locales.d \
    "${AGE_SRC}"/sayableage/format_age.d \
    "${DATE_SRC}"/sayabledate/locale.d \
    "${DATE_SRC}"/sayabledate/locales.d \
    "${DATE_SRC}"/sayabledate/format_date.d \
    "${DURATION_SRC}"/sayableduration/locale.d \
    "${DURATION_SRC}"/sayableduration/locales.d \
    "${DURATION_SRC}"/sayableduration/format_duration.d \
    "${TIME_SRC}"/sayabletime/locale.d \
    "${TIME_SRC}"/sayabletime/locales.d \
    "${TIME_SRC}"/sayabletime/format_time.d \
    "${CLI_SRC}"/main.d

echo "Built: ${OUT}"
