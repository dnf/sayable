#!/usr/bin/env bash
# Tests for sayabletime — mirrors canonical tests from time/config/tests.json
set -uo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_script_dir}/sayabletime.sh"

# Simple test framework
_pass=0
_fail=0
_errors=()

assert_eq() {
    local actual="$1" expected="$2" id="$3" desc="${4:-}"
    if [ "${actual}" = "${expected}" ]; then
        _pass=$(( _pass + 1 ))
    else
        _fail=$(( _fail + 1 ))
        _errors+=("${id}: expected '${expected}', got '${actual}' ${desc}")
    fi
}

# ================================================================
# Section 1: Null / edge cases
# ================================================================
echo "Section 1: Null / edge cases"

# 1.1 — null input
assert_eq "$(sayabletime_format_time "en" "")" "" "1.1"

# 1.2 — empty string
assert_eq "$(sayabletime_format_time "en" "")" "" "1.2"

# 1.3 — invalid input
assert_eq "$(sayabletime_format_time "en" "invalid")" "" "1.3"

# 1.4 — out of range
assert_eq "$(sayabletime_format_time "en" "25:00")" "" "1.4"

# ================================================================
# Section 2: Clock time (normal compactness)
# ================================================================
echo "Section 2: Normal compactness"

# 2.1
assert_eq "$(sayabletime_format_time "en" "00:00")" "midnight" "2.1"

# 2.2
assert_eq "$(sayabletime_format_time "en" "12:00")" "noon" "2.2"

# 2.3
assert_eq "$(sayabletime_format_time "en" "15:00")" "three o'clock" "2.3"

# 2.4
assert_eq "$(sayabletime_format_time "en" "14:15")" "a quarter past two" "2.4"

# 2.5
assert_eq "$(sayabletime_format_time "en" "09:30")" "half past nine" "2.5"

# 2.6
assert_eq "$(sayabletime_format_time "en" "10:45")" "a quarter to eleven" "2.6"

# 2.7
assert_eq "$(sayabletime_format_time "en" "08:05")" "five past eight" "2.7"

# 2.8
assert_eq "$(sayabletime_format_time "en" "16:55")" "five to five" "2.8"

# 2.9
assert_eq "$(sayabletime_format_time "en" "23:58")" "midnight" "2.9"

# 2.10
assert_eq "$(sayabletime_format_time "en" "07:22")" "twenty past seven" "2.10"

# 2.11
assert_eq "$(sayabletime_format_time "en" "2025-01-15T14:15:00")" "a quarter past two" "2.11"

# ================================================================
# Section 3: Clock time (short compactness)
# ================================================================
echo "Section 3: Short compactness"

# 3.1
assert_eq "$(sayabletime_format_time "en" "14:15" "short")" "2:15 PM" "3.1"

# 3.2
assert_eq "$(sayabletime_format_time "en" "09:30" "short")" "9:30 AM" "3.2"

# 3.3
assert_eq "$(sayabletime_format_time "en" "00:00" "short")" "12:00 AM" "3.3"

# 3.4
assert_eq "$(sayabletime_format_time "en" "12:00" "short")" "12:00 PM" "3.4"

# ================================================================
# Section 4: Clock time (compact)
# ================================================================
echo "Section 4: Compact"

# 4.1
assert_eq "$(sayabletime_format_time "en" "14:15" "compact")" "2:15p" "4.1"

# 4.2
assert_eq "$(sayabletime_format_time "en" "09:30" "compact")" "9:30a" "4.2"

# ================================================================
# Section 5: Locale — German
# ================================================================
echo "Section 5: German"

# 5.1
assert_eq "$(sayabletime_format_time "de" "15:30")" "halb vier" "5.1"

# ================================================================
# Section 6: Locale — French
# ================================================================
echo "Section 6: French"

# 6.1
assert_eq "$(sayabletime_format_time "fr" "15:15")" "trois heures et quart" "6.1"

# 6.2
assert_eq "$(sayabletime_format_time "fr" "13:00")" "une heure" "6.2"

# 6.3
assert_eq "$(sayabletime_format_time "fr" "13:30")" "une heure et demie" "6.3"

# 6.4
assert_eq "$(sayabletime_format_time "fr" "14:45")" "trois heures moins le quart" "6.4"

# 6.5
assert_eq "$(sayabletime_format_time "fr" "14:50")" "trois heures moins dix" "6.5"

# ================================================================
# Section 7: Locale — Japanese
# ================================================================
echo "Section 7: Japanese"

# 7.1
assert_eq "$(sayabletime_format_time "ja" "15:30")" "三時半" "7.1"

# ================================================================
# Section 8: Locale — Finnish (dot separator, short)
# ================================================================
echo "Section 8: Finnish"

# 8.1
assert_eq "$(sayabletime_format_time "fi" "14:15" "short")" "14.15" "8.1"

# 8.2
assert_eq "$(sayabletime_format_time "fi" "00:00" "short")" "0.00" "8.2"

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================
echo "Sections 9-10: minutes in short/compact, input validation"

# 9.1 — digital modes keep the exact minute
assert_eq "$(sayabletime_format_time "en" "18:01" "short")" "6:01 PM" "9.1"

# 9.2 — digital modes keep the exact minute
assert_eq "$(sayabletime_format_time "en" "19:05" "compact")" "7:05p" "9.2"

# 10.1 — one-digit hour
assert_eq "$(sayabletime_format_time "en" "9:30" "normal")" "half past nine" "10.1"

# 10.2 — two-digit hour
assert_eq "$(sayabletime_format_time "en" "09:30" "normal")" "half past nine" "10.2"

# 10.3 — leading whitespace
assert_eq "$(sayabletime_format_time "en" " 9:30" "normal")" "" "10.3"

# 10.4 — trailing whitespace
assert_eq "$(sayabletime_format_time "en" "9:30 " "normal")" "" "10.4"

# 10.5 — minutes need two digits
assert_eq "$(sayabletime_format_time "en" "9:5" "normal")" "" "10.5"

# 10.6 — hour out of range
assert_eq "$(sayabletime_format_time "en" "24:00" "normal")" "" "10.6"

# 10.7 — seconds are allowed and ignored
assert_eq "$(sayabletime_format_time "en" "14:15:30" "normal")" "a quarter past two" "10.7"

# 10.8 — ISO datetime with zone suffix (ignored)
assert_eq "$(sayabletime_format_time "en" "2025-01-15T14:15:00Z" "normal")" "a quarter past two" "10.8"

# 10.9 — ISO datetime with an impossible date
assert_eq "$(sayabletime_format_time "en" "2025-02-30T14:15:00" "normal")" "" "10.9"


# ================================================================
# Summary
# ================================================================
echo ""
echo "============================================"
echo "Results: ${_pass} passed, ${_fail} failed"
echo "============================================"

if [ ${_fail} -gt 0 ]; then
    echo ""
    echo "Failures:"
    for err in "${_errors[@]}"; do
        echo "  FAIL: ${err}"
    done
    exit 1
fi
exit 0
