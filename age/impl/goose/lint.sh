#!/usr/bin/env bash
# Typecheck the library and tests with zero warnings allowed.
#
# Goose has no linter and warnings never fail a check, so read the JSON
# diagnostics instead: an empty list is the only passing result.
set -euo pipefail

cd "$(dirname "$0")"

status=0
for entry in sayableage/sayableage.goose tests/test_format_age.goose; do
    diagnostics=$(goose check --diagnostics json "${entry}" 2>/dev/null) || status=$?
    if [ "${diagnostics}" != "[]" ]; then
        echo "${entry}: ${diagnostics}"
        status=1
    fi
done

if [ "${status}" -eq 0 ]; then
    echo "goose check: no warnings"
fi
exit "${status}"
