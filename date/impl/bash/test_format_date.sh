#!/usr/bin/env bash
# Tests for sayabledate — mirrors canonical tests from date/config/tests.json
set -uo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_script_dir}/sayabledate.sh"

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
assert_eq "$(sayabledate_format_date "en" "")" "" "1.1"

# 1.2 — empty string
assert_eq "$(sayabledate_format_date "en" "")" "" "1.2"

# 1.3 — invalid date
assert_eq "$(sayabledate_format_date "en" "invalid")" "" "1.3"

# 1.4 — format_relative with null asOf
assert_eq "$(sayabledate_format_relative "en" "2025-03-15" "")" "" "1.4"

# 1.5 — format_relative with null date
assert_eq "$(sayabledate_format_relative "en" "" "2025-03-15")" "" "1.5"

# ================================================================
# Section 2: format_date — normal compactness (English)
# ================================================================
echo "Section 2: format_date — normal (English)"

# 2.1
assert_eq "$(sayabledate_format_date "en" "2025-03-15")" "March 15th" "2.1"

# 2.2
assert_eq "$(sayabledate_format_date "en" "2025-01-01")" "January 1st" "2.2"

# 2.3
assert_eq "$(sayabledate_format_date "en" "2025-05-22")" "May 22nd" "2.3"

# 2.4
assert_eq "$(sayabledate_format_date "en" "2025-07-03")" "July 3rd" "2.4"

# 2.5
assert_eq "$(sayabledate_format_date "en" "2025-12-31")" "December 31st" "2.5"

# 2.6
assert_eq "$(sayabledate_format_date "en" "2025-06-11")" "June 11th" "2.6"

# 2.7
assert_eq "$(sayabledate_format_date "en" "2025-03-15T14:30:00")" "March 15th" "2.7"

# ================================================================
# Section 3: format_date — short compactness (English)
# ================================================================
echo "Section 3: format_date — short (English)"

# 3.1
assert_eq "$(sayabledate_format_date "en" "2025-03-15" "short")" "Mar 15" "3.1"

# 3.2
assert_eq "$(sayabledate_format_date "en" "2025-01-01" "short")" "Jan 1" "3.2"

# 3.3
assert_eq "$(sayabledate_format_date "en" "2025-12-25" "short")" "Dec 25" "3.3"

# ================================================================
# Section 4: format_date — compact (English)
# ================================================================
echo "Section 4: format_date — compact (English)"

# 4.1
assert_eq "$(sayabledate_format_date "en" "2025-03-15" "compact")" "3/15" "4.1"

# 4.2
assert_eq "$(sayabledate_format_date "en" "2025-01-01" "compact")" "1/1" "4.2"

# ================================================================
# Section 5: format_relative — proximity tiers (English)
# ================================================================
echo "Section 5: format_relative — proximity (English)"

# 5.1
assert_eq "$(sayabledate_format_relative "en" "2025-03-15" "2025-03-15")" "today" "5.1"

# 5.2
assert_eq "$(sayabledate_format_relative "en" "2025-03-16" "2025-03-15")" "tomorrow" "5.2"

# 5.3
assert_eq "$(sayabledate_format_relative "en" "2025-03-14" "2025-03-15")" "yesterday" "5.3"

# 5.4
assert_eq "$(sayabledate_format_relative "en" "2025-03-17" "2025-03-15")" "the day after tomorrow" "5.4"

# 5.5
assert_eq "$(sayabledate_format_relative "en" "2025-03-13" "2025-03-15")" "the day before yesterday" "5.5"

# 5.6
assert_eq "$(sayabledate_format_relative "en" "2025-03-19" "2025-03-15")" "this Wednesday" "5.6"

# 5.7
assert_eq "$(sayabledate_format_relative "en" "2025-03-20" "2025-03-15")" "this Thursday" "5.7"

# 5.8
assert_eq "$(sayabledate_format_relative "en" "2025-03-11" "2025-03-15")" "last Tuesday" "5.8"

# 5.9
assert_eq "$(sayabledate_format_relative "en" "2025-03-22" "2025-03-15")" "next Saturday" "5.9"

# 5.10
assert_eq "$(sayabledate_format_relative "en" "2025-03-27" "2025-03-15")" "next Thursday" "5.10"

# 5.11
assert_eq "$(sayabledate_format_relative "en" "2025-03-01" "2025-03-15")" "March 1st" "5.11"

# 5.12
assert_eq "$(sayabledate_format_relative "en" "2025-04-10" "2025-03-15")" "April 10th" "5.12"

# 5.13
assert_eq "$(sayabledate_format_relative "en" "2026-01-05" "2025-03-15")" "January 5th, 2026" "5.13"

# 5.14
assert_eq "$(sayabledate_format_relative "en" "2024-12-25" "2025-03-15")" "December 25th, 2024" "5.14"

# ================================================================
# Section 6: format_relative — compact skips weekday tiers
# ================================================================
echo "Section 6: format_relative — compact"

# 6.1
assert_eq "$(sayabledate_format_relative "en" "2025-03-15" "2025-03-15" "compact")" "today" "6.1"

# 6.2
assert_eq "$(sayabledate_format_relative "en" "2025-03-16" "2025-03-15" "compact")" "tomorrow" "6.2"

# 6.3
assert_eq "$(sayabledate_format_relative "en" "2025-03-19" "2025-03-15" "compact")" "3/19" "6.3"

# 6.4
assert_eq "$(sayabledate_format_relative "en" "2026-01-05" "2025-03-15" "compact")" "1/5/26" "6.4"

# ================================================================
# Section 7: Locale — German
# ================================================================
echo "Section 7: German"

# 7.1
assert_eq "$(sayabledate_format_date "de" "2025-03-15")" "15. März" "7.1"

# 7.2
assert_eq "$(sayabledate_format_relative "de" "2025-03-16" "2025-03-15")" "morgen" "7.2"

# 7.3
assert_eq "$(sayabledate_format_relative "de" "2025-03-17" "2025-03-15")" "übermorgen" "7.3"

# 7.4
assert_eq "$(sayabledate_format_relative "de" "2025-03-19" "2025-03-15")" "diesen Mittwoch" "7.4"

# ================================================================
# Section 8: Locale — French
# ================================================================
echo "Section 8: French"

# 8.1
assert_eq "$(sayabledate_format_date "fr" "2025-03-01")" "1er mars" "8.1"

# 8.2
assert_eq "$(sayabledate_format_date "fr" "2025-03-15")" "15 mars" "8.2"

# 8.3
assert_eq "$(sayabledate_format_relative "fr" "2025-03-16" "2025-03-15")" "demain" "8.3"

# ================================================================
# Section 9: Locale — Japanese
# ================================================================
echo "Section 9: Japanese"

# 9.1
assert_eq "$(sayabledate_format_date "ja" "2025-03-15")" "3月15日" "9.1"

# 9.2
assert_eq "$(sayabledate_format_relative "ja" "2025-03-16" "2025-03-15")" "明日" "9.2"

# 9.3
assert_eq "$(sayabledate_format_relative "ja" "2025-03-19" "2025-03-15")" "今度の水曜日" "9.3"

# ================================================================
# Section 10: Locale — Russian (genitive months)
# ================================================================
echo "Section 10: Russian"

# 10.1
assert_eq "$(sayabledate_format_date "ru" "2025-03-15")" "15 марта" "10.1"

# 10.2
assert_eq "$(sayabledate_format_relative "ru" "2025-03-16" "2025-03-15")" "завтра" "10.2"

# ================================================================
# Section 11: Locale — Arabic
# ================================================================
echo "Section 11: Arabic"

# 11.1
assert_eq "$(sayabledate_format_date "ar" "2025-03-15")" "15 مارس" "11.1"

# 11.2
assert_eq "$(sayabledate_format_relative "ar" "2025-03-16" "2025-03-15")" "غداً" "11.2"

# ================================================================
# Section 12: Locale — Spanish
# ================================================================
echo "Section 12: Spanish"

# 12.1
assert_eq "$(sayabledate_format_date "es" "2025-03-15")" "15 de marzo" "12.1"

# 12.2
assert_eq "$(sayabledate_format_relative "es" "2025-03-17" "2025-03-15")" "pasado mañana" "12.2"

# ================================================================
# Sections 13-16: with year, short months, short phrases, input validation
# ================================================================
echo "Sections 13-16: with year, short months, short phrases, input validation"

# 13.1
assert_eq "$(sayabledate_format_date_with_year "en" "2018-02-04" "normal")" "February 4th, 2018" "13.1"

# 13.2
assert_eq "$(sayabledate_format_date_with_year "en" "2025-03-15" "short")" "Mar 15, 2025" "13.2"

# 13.3
assert_eq "$(sayabledate_format_date_with_year "en" "1997-01-21" "compact")" "1/21/97" "13.3"

# 13.4 — two-digit year keeps its leading zero
assert_eq "$(sayabledate_format_date_with_year "tg" "2007-05-20" "compact")" "20/5/07" "13.4"

# 13.5
assert_eq "$(sayabledate_format_date_with_year "fi" "1996-06-21" "short")" "21. kesäkuuta 1996" "13.5"

# 14.1
assert_eq "$(sayabledate_format_date "sk" "2031-02-15" "short")" "15. februára" "14.1"

# 14.2
assert_eq "$(sayabledate_format_date "cs" "2025-12-10" "short")" "10. prosince" "14.2"

# 14.3
assert_eq "$(sayabledate_format_date "uk" "2025-11-05" "short")" "5 листопада" "14.3"

# 14.4
assert_eq "$(sayabledate_format_relative "fi" "1998-08-08" "1998-08-15" "short")" "8. elokuuta" "14.4"

# 15.1 — day after tomorrow
assert_eq "$(sayabledate_format_relative "kw" "2035-12-04" "2035-12-02" "short")" "an Mth ma" "15.1"

# 15.2 — day before yesterday
assert_eq "$(sayabledate_format_relative "mam" "2000-01-23" "2000-01-25" "short")" "Dom nchi'j" "15.2"

# 15.3 — day after tomorrow
assert_eq "$(sayabledate_format_relative "kek" "2014-10-24" "2014-10-22" "short")" "a'in Vie" "15.3"

# 16.1 — February 30 doesn't exist
assert_eq "$(sayabledate_format_date "en" "2025-02-30" "normal")" "" "16.1"

# 16.2 — Month 13
assert_eq "$(sayabledate_format_date "en" "2025-13-01" "normal")" "" "16.2"

# 16.3 — Unpadded month and day
assert_eq "$(sayabledate_format_date "en" "2025-6-1" "normal")" "" "16.3"

# 16.4 — Surrounding whitespace
assert_eq "$(sayabledate_format_date "en" " 2025-06-01" "normal")" "" "16.4"

# 16.5 — An ISO datetime: only the date part is used
assert_eq "$(sayabledate_format_date "en" "2025-06-01T10:00:00" "normal")" "June 1st" "16.5"

# 16.6 — February 29 in a non-leap year
assert_eq "$(sayabledate_format_date_with_year "en" "2023-02-29" "normal")" "" "16.6"

# 16.7 — Invalid asOf
assert_eq "$(sayabledate_format_relative "en" "2025-03-16" "2025-04-31" "normal")" "" "16.7"


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
