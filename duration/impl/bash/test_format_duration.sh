#!/usr/bin/env bash
# Tests for sayableduration — mirrors canonical tests from duration/config/tests.json
set -uo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_script_dir}/sayableduration.sh"

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
assert_eq "$(sayableduration_format_duration "en" "")" "" "1.1"

# 1.2 — negative seconds
assert_eq "$(sayableduration_format_duration "en" "-1")" "" "1.2"

# 1.3 — format_since with null start
assert_eq "$(sayableduration_format_since "en" "" "2025-01-15T10:00:00")" "" "1.3"

# 1.4 — format_until with null target
assert_eq "$(sayableduration_format_until "en" "" "2025-01-15T10:00:00")" "" "1.4"

# 1.5 — format_since: asOf before start
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T09:00:00")" "" "1.5"

# 1.6 — format_until: target in the past
assert_eq "$(sayableduration_format_until "en" "2025-01-15T09:00:00" "2025-01-15T10:00:00")" "" "1.6"

# ================================================================
# Section 2: Duration — seconds tier (0-59s)
# ================================================================
echo "Section 2: Seconds tier"

# 2.1
assert_eq "$(sayableduration_format_duration "en" "0")" "just now" "2.1"

# 2.2
assert_eq "$(sayableduration_format_duration "en" "1")" "1 second" "2.2"

# 2.3
assert_eq "$(sayableduration_format_duration "en" "45")" "45 seconds" "2.3"

# 2.4
assert_eq "$(sayableduration_format_duration "en" "59")" "59 seconds" "2.4"

# ================================================================
# Section 3: Duration — minutes + seconds tier (1-4 min)
# ================================================================
echo "Section 3: Minutes + seconds"

# 3.1
assert_eq "$(sayableduration_format_duration "en" "60")" "1 minute" "3.1"

# 3.2
assert_eq "$(sayableduration_format_duration "en" "90")" "1 minute, 30 seconds" "3.2"

# 3.3
assert_eq "$(sayableduration_format_duration "en" "240")" "4 minutes" "3.3"

# 3.4
assert_eq "$(sayableduration_format_duration "en" "270")" "4 minutes, 30 seconds" "3.4"

# ================================================================
# Section 4: Duration — minutes tier (5-59 min)
# ================================================================
echo "Section 4: Minutes tier"

# 4.1
assert_eq "$(sayableduration_format_duration "en" "300")" "5 minutes" "4.1"

# 4.2
assert_eq "$(sayableduration_format_duration "en" "1500")" "25 minutes" "4.2"

# 4.3
assert_eq "$(sayableduration_format_duration "en" "3540")" "59 minutes" "4.3"

# ================================================================
# Section 5: Duration — hours + minutes tier (1-5 hr)
# ================================================================
echo "Section 5: Hours + minutes"

# 5.1
assert_eq "$(sayableduration_format_duration "en" "3600")" "1 hour" "5.1"

# 5.2
assert_eq "$(sayableduration_format_duration "en" "5400")" "1½ hours" "5.2"

# 5.3
assert_eq "$(sayableduration_format_duration "en" "8100")" "2 hours, 15 minutes" "5.3"

# 5.4
assert_eq "$(sayableduration_format_duration "en" "18000")" "5 hours" "5.4"

# ================================================================
# Section 6: Duration — hours tier (6-23 hr)
# ================================================================
echo "Section 6: Hours tier"

# 6.1
assert_eq "$(sayableduration_format_duration "en" "28800")" "8 hours" "6.1"

# 6.2
assert_eq "$(sayableduration_format_duration "en" "82800")" "23 hours" "6.2"

# ================================================================
# Section 7: Duration — days tier
# ================================================================
echo "Section 7: Days tier"

# 7.1
assert_eq "$(sayableduration_format_duration "en" "86400")" "1 day" "7.1"

# 7.2
assert_eq "$(sayableduration_format_duration "en" "97200")" "1 day, 3 hours" "7.2"

# 7.3
assert_eq "$(sayableduration_format_duration "en" "129600")" "1½ days" "7.3"

# 7.4
assert_eq "$(sayableduration_format_duration "en" "432000")" "5 days" "7.4"

# 7.5
assert_eq "$(sayableduration_format_duration "en" "172800")" "2 days" "7.5"

# ================================================================
# Section 8: Duration — weeks tier
# ================================================================
echo "Section 8: Weeks tier"

# 8.1
assert_eq "$(sayableduration_format_duration "en" "604800")" "1 week" "8.1"

# 8.2
assert_eq "$(sayableduration_format_duration "en" "1296000")" "2 weeks, 1 day" "8.2"

# 8.3
assert_eq "$(sayableduration_format_duration "en" "2419200")" "4 weeks" "8.3"

# ================================================================
# Section 9: Duration — months and years tier
# ================================================================
echo "Section 9: Months and years"

# 9.1
assert_eq "$(sayableduration_format_duration "en" "2678400")" "1 month" "9.1"

# 9.2
assert_eq "$(sayableduration_format_duration "en" "7884000")" "3 months" "9.2"

# 9.3
assert_eq "$(sayableduration_format_duration "en" "31536000")" "1 year" "9.3"

# 9.4
assert_eq "$(sayableduration_format_duration "en" "39420000")" "1 year, 3 months" "9.4"

# ================================================================
# Section 10: Duration from ISO timestamps
# ================================================================
echo "Section 10: ISO timestamps"

# 10.1
assert_eq "$(sayableduration_format_duration "en" "2025-01-15T10:00:00" "2025-01-15T11:30:00")" "1½ hours" "10.1"

# 10.2
assert_eq "$(sayableduration_format_duration "en" "2025-01-15T10:00:00" "2025-01-15T10:45:00")" "45 minutes" "10.2"

# ================================================================
# Section 11: Relative time — since
# ================================================================
echo "Section 11: format_since"

# 11.1
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T10:00:00")" "just now" "11.1"

# 11.2
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T10:00:30")" "30 seconds ago" "11.2"

# 11.3
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T10:45:00")" "45 minutes ago" "11.3"

# 11.4
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T13:00:00")" "3 hours ago" "11.4"

# ================================================================
# Section 12: Relative time — until
# ================================================================
echo "Section 12: format_until"

# 12.1
assert_eq "$(sayableduration_format_until "en" "2025-01-15T10:00:00" "2025-01-15T10:00:00")" "just now" "12.1"

# 12.2
assert_eq "$(sayableduration_format_until "en" "2025-01-15T10:20:00" "2025-01-15T10:00:00")" "in 20 minutes" "12.2"

# 12.3
assert_eq "$(sayableduration_format_until "en" "2025-01-15T13:00:00" "2025-01-15T10:00:00")" "in 3 hours" "12.3"

# ================================================================
# Section 13: Locale — German
# ================================================================
echo "Section 13: German"

# 13.1
assert_eq "$(sayableduration_format_duration "de" "3600")" "1 Stunde" "13.1"

# 13.2
assert_eq "$(sayableduration_format_since "de" "2025-01-15T10:00:00" "2025-01-15T10:05:00")" "vor 5 Minuten" "13.2"

# ================================================================
# Section 14: Locale — French
# ================================================================
echo "Section 14: French"

# 14.1
assert_eq "$(sayableduration_format_duration "fr" "7200")" "2 heures" "14.1"

# ================================================================
# Section 15: Locale — Japanese
# ================================================================
echo "Section 15: Japanese"

# 15.1
assert_eq "$(sayableduration_format_duration "ja" "120")" "2分" "15.1"

# 15.2
assert_eq "$(sayableduration_format_since "ja" "2025-01-15T10:00:00" "2025-01-15T11:00:00")" "1時間前" "15.2"

# ================================================================
# Section 16: Short compactness — duration
# ================================================================
echo "Section 16: Short compactness"

# 16.1
assert_eq "$(sayableduration_format_duration "en" "3600" "" "short")" "1h" "16.1"

# 16.2
assert_eq "$(sayableduration_format_duration "en" "90" "" "short")" "1m, 30s" "16.2"

# ================================================================
# Section 17: Compact compactness — duration
# ================================================================
echo "Section 17: Compact compactness"

# 17.1
assert_eq "$(sayableduration_format_duration "en" "3600" "" "compact")" "1h" "17.1"

# 17.2
assert_eq "$(sayableduration_format_duration "en" "90" "" "compact")" "1m30s" "17.2"

# ================================================================
# Sections 18-20: short since, 500-year ceiling, timestamp validation
# ================================================================
echo "Sections 18-20: short since, 500-year ceiling, timestamp validation"

# 18.1 — days and hours both kept
assert_eq "$(sayableduration_format_since "men" "2025-01-20T01:32:11" "2025-01-22T15:39:16" "short")" "lɔhɔnga 2, awa 14 taa gbɔyɔ" "18.1"

# 19.1 — 500 Julian years: 6000 months, the ceiling
assert_eq "$(sayableduration_format_duration "en" "15778800000" "" "normal")" "500 years" "19.1"

# 19.2 — over 6000 months
assert_eq "$(sayableduration_format_duration "en" "15800000000" "" "normal")" "" "19.2"

# 19.3 — well beyond the ceiling (and 32-bit range)
assert_eq "$(sayableduration_format_duration "en" "99999999999" "" "normal")" "" "19.3"

# 19.4 — 525 years ago
assert_eq "$(sayableduration_format_since "en" "1500-01-01T00:00:00" "2025-01-01T00:00:00" "normal")" "" "19.4"

# 19.5 — 575 years from now
assert_eq "$(sayableduration_format_until "en" "2600-01-01T00:00:00" "2025-01-01T00:00:00" "normal")" "" "19.5"

# 20.1 — seconds are optional
assert_eq "$(sayableduration_format_duration "en" "2025-01-15T10:00" "2025-01-15T11:30:00" "normal")" "1½ hours" "20.1"

# 20.2 — minutes are required
assert_eq "$(sayableduration_format_duration "en" "2025-01-15T10" "2025-01-15T11:30:00" "normal")" "" "20.2"

# 20.3 — unpadded date
assert_eq "$(sayableduration_format_duration "en" "2025-1-5T10:00:00" "2025-01-15T11:30:00" "normal")" "" "20.3"

# 20.4 — impossible date
assert_eq "$(sayableduration_format_duration "en" "2025-02-30T10:00:00" "2025-03-15T11:30:00" "normal")" "" "20.4"

# 20.5 — hour out of range
assert_eq "$(sayableduration_format_since "en" "2025-01-15T10:00:00" "2025-01-15T25:00:00" "normal")" "" "20.5"


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
