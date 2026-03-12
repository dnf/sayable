#!/usr/bin/env bash
# Tests for sayableage — mirrors canonical tests from age/config/tests.json
set -uo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${_script_dir}/sayableage.sh"

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

assert_contains() {
    local actual="$1" substring="$2" id="$3" desc="${4:-}"
    if [[ "${actual}" == *"${substring}"* ]]; then
        _pass=$(( _pass + 1 ))
    else
        _fail=$(( _fail + 1 ))
        _errors+=("${id}: expected '${actual}' to contain '${substring}' ${desc}")
    fi
}

# ================================================================
# Section 1: Null / edge cases
# ================================================================
echo "Section 1: Null / edge cases"

# 1.1 — null input (empty string in Bash)
assert_eq "$(sayableage_format_age "en" "" "2025-06-15")" "" "1.1"

# 1.3 — empty string
assert_eq "$(sayableage_format_age "en" "" "2025-06-15")" "" "1.3"

# 1.4 — future DOB
assert_eq "$(sayableage_format_age "en" "2025-07-01" "2025-06-15")" "" "1.4"

# 1.5 — exactly 500 years
assert_eq "$(sayableage_format_age "en" "1525-06-15" "2025-06-15")" "500 years" "1.5"

# 1.6 — 501 years
assert_eq "$(sayableage_format_age "en" "1524-06-15" "2025-06-15")" "" "1.6"

# 1.7 — 1000 years
assert_eq "$(sayableage_format_age "en" "1025-06-15" "2025-06-15")" "" "1.7"

# ================================================================
# Section 2: Days tier (0-6 days)
# ================================================================
echo "Section 2: Days tier"

# 2.1
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-06-15")" "Newborn" "2.1"

# 2.2
assert_eq "$(sayableage_format_age "en" "2025-06-14" "2025-06-15")" "1 day" "2.2"

# 2.3
assert_eq "$(sayableage_format_age "en" "2025-06-12" "2025-06-15")" "3 days" "2.3"

# 2.4
assert_eq "$(sayableage_format_age "en" "2025-06-09" "2025-06-15")" "6 days" "2.4"

# 2.5
assert_eq "$(sayableage_format_age "en" "2025-06-08" "2025-06-15")" "1 week" "2.5"

# ================================================================
# Section 3: Weeks+days tier
# ================================================================
echo "Section 3: Weeks+days tier"

# 3.1
assert_eq "$(sayableage_format_age "en" "2025-06-08" "2025-06-15")" "1 week" "3.1"

# 3.2
assert_eq "$(sayableage_format_age "en" "2025-06-07" "2025-06-15")" "1 week, 1 day" "3.2"

# 3.3
assert_eq "$(sayableage_format_age "en" "2025-06-06" "2025-06-15")" "1 week, 2 days" "3.3"

# 3.4
assert_eq "$(sayableage_format_age "en" "2025-06-02" "2025-06-15")" "1 week, 6 days" "3.4"

# 3.5
assert_eq "$(sayableage_format_age "en" "2025-06-01" "2025-06-15")" "2 weeks" "3.5"

# 3.6
assert_eq "$(sayableage_format_age "en" "2025-05-31" "2025-06-15")" "2 weeks, 1 day" "3.6"

# 3.7
assert_eq "$(sayableage_format_age "en" "2025-05-26" "2025-06-15")" "2 weeks, 6 days" "3.7"

# 3.8
assert_eq "$(sayableage_format_age "en" "2025-05-25" "2025-06-15")" "3 weeks" "3.8"

# 3.9
assert_eq "$(sayableage_format_age "en" "2025-05-15" "2025-06-15")" "4 weeks, 3 days" "3.9"

# 3.10
assert_eq "$(sayableage_format_age "en" "2025-04-15" "2025-06-15")" "8 weeks, 5 days" "3.10"

# 3.11
assert_eq "$(sayableage_format_age "en" "2025-03-15" "2025-06-14")" "13 weeks" "3.11"

# 3.12
assert_eq "$(sayableage_format_age "en" "2025-03-15" "2025-06-15")" "3 months" "3.12"

# ================================================================
# Section 4: Month boundaries — standard months
# ================================================================
echo "Section 4: Month boundaries — standard"

# 4.1
assert_eq "$(sayableage_format_age "en" "2025-01-01" "2025-04-01")" "3 months" "4.1"

# 4.2
assert_contains "$(sayableage_format_age "en" "2025-01-01" "2025-03-31")" "weeks" "4.2"

# 4.3
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-09-15")" "3 months" "4.3"

# 4.4
assert_contains "$(sayableage_format_age "en" "2025-06-15" "2025-09-14")" "weeks" "4.4"

# 4.5
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-12-15")" "6 months" "4.5"

# ================================================================
# Section 5: Month boundaries — February non-leap year
# ================================================================
echo "Section 5: Month boundaries — Feb non-leap"

# 5.1
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-02-28")" "4 weeks" "5.1"

# 5.2
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-04-30")" "3 months" "5.2"

# 5.3
assert_contains "$(sayableage_format_age "en" "2025-01-31" "2025-04-29")" "weeks" "5.3"

# 5.4
assert_eq "$(sayableage_format_age "en" "2025-02-01" "2025-05-01")" "3 months" "5.4"

# 5.5
assert_contains "$(sayableage_format_age "en" "2025-02-01" "2025-04-30")" "weeks" "5.5"

# ================================================================
# Section 6: Month boundaries — February leap year
# ================================================================
echo "Section 6: Month boundaries — Feb leap year"

# 6.1
assert_eq "$(sayableage_format_age "en" "2024-01-31" "2024-02-29")" "4 weeks, 1 day" "6.1"

# 6.2
assert_eq "$(sayableage_format_age "en" "2024-01-31" "2024-02-28")" "4 weeks" "6.2"

# 6.3
assert_eq "$(sayableage_format_age "en" "2024-01-31" "2024-04-30")" "3 months" "6.3"

# 6.4
assert_contains "$(sayableage_format_age "en" "2024-01-30" "2024-02-29")" "weeks" "6.4"

# 6.5
assert_contains "$(sayableage_format_age "en" "2024-01-30" "2024-02-28")" "weeks" "6.5"

# ================================================================
# Section 7: Month boundaries — 30-day months
# ================================================================
echo "Section 7: Month boundaries — 30-day months"

# 7.1
assert_eq "$(sayableage_format_age "en" "2025-03-31" "2025-06-30")" "3 months" "7.1"

# 7.2
assert_contains "$(sayableage_format_age "en" "2025-03-31" "2025-06-29")" "weeks" "7.2"

# 7.3
assert_eq "$(sayableage_format_age "en" "2025-08-31" "2025-11-30")" "3 months" "7.3"

# 7.4
assert_contains "$(sayableage_format_age "en" "2025-08-31" "2025-11-29")" "weeks" "7.4"

# ================================================================
# Section 8: Month boundaries — leap year baby
# ================================================================
echo "Section 8: Leap year baby"

# 8.1
assert_eq "$(sayableage_format_age "en" "2024-02-29" "2024-05-29")" "3 months" "8.1"

# 8.2
assert_contains "$(sayableage_format_age "en" "2024-02-29" "2024-05-28")" "weeks" "8.2"

# 8.3
assert_eq "$(sayableage_format_age "en" "2024-02-29" "2025-02-28")" "12 months" "8.3"

# 8.4
assert_eq "$(sayableage_format_age "en" "2024-02-29" "2025-03-01")" "12 months" "8.4"

# ================================================================
# Section 9: Months tier (3-23 months)
# ================================================================
echo "Section 9: Months tier"

# 9.1
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-04-15")" "3 months" "9.1"

# 9.2
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-07-15")" "6 months" "9.2"

# 9.3
assert_eq "$(sayableage_format_age "en" "2024-06-15" "2025-06-15")" "12 months" "9.3"

# 9.4
assert_eq "$(sayableage_format_age "en" "2024-01-15" "2025-12-15")" "23 months" "9.4"

# 9.5
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-07-14")" "5 months" "9.5"

# 9.6
assert_eq "$(sayableage_format_age "en" "2024-11-10" "2025-04-10")" "5 months" "9.6"

# ================================================================
# Section 10: Years+months tier (24-35 months)
# ================================================================
echo "Section 10: Years+months tier"

# 10.1
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-06-15")" "2 years" "10.1"

# 10.2
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-07-15")" "2 years, 1 month" "10.2"

# 10.3
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-12-15")" "2 years, 6 months" "10.3"

# 10.4
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2026-05-15")" "2 years, 11 months" "10.4"

# 10.5
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-06-14")" "23 months" "10.5"

# ================================================================
# Section 11: Half-year tier (3-6 years)
# ================================================================
echo "Section 11: Half-year tier"

# 11.1
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-06-15")" "3 years" "11.1"

# 11.2
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-11-15")" "3 years" "11.2"

# 11.3
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-12-15")" "3½ years" "11.3"

# 11.4
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2026-05-15")" "3½ years" "11.4"

# 11.5
assert_eq "$(sayableage_format_age "en" "2021-06-15" "2025-06-15")" "4 years" "11.5"

# 11.6
assert_eq "$(sayableage_format_age "en" "2021-06-15" "2025-12-15")" "4½ years" "11.6"

# 11.7
assert_eq "$(sayableage_format_age "en" "2020-06-15" "2025-06-15")" "5 years" "11.7"

# 11.8
assert_eq "$(sayableage_format_age "en" "2020-06-15" "2026-02-15")" "5½ years" "11.8"

# 11.9
assert_eq "$(sayableage_format_age "en" "2019-06-15" "2025-06-15")" "6 years" "11.9"

# 11.10
assert_eq "$(sayableage_format_age "en" "2019-06-15" "2025-12-15")" "6½ years" "11.10"

# 11.11
assert_eq "$(sayableage_format_age "en" "2019-06-15" "2026-05-15")" "6½ years" "11.11"

# 11.12
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-06-14")" "2 years, 11 months" "11.12"

# ================================================================
# Section 12: Integer tier (7+ years)
# ================================================================
echo "Section 12: Integer tier"

# 12.1
assert_eq "$(sayableage_format_age "en" "2018-06-15" "2025-06-15")" "7 years" "12.1"

# 12.2
assert_eq "$(sayableage_format_age "en" "2018-03-20" "2025-06-15")" "7 years" "12.2"

# 12.3
assert_eq "$(sayableage_format_age "en" "1980-01-01" "2025-06-15")" "45 years" "12.3"

# ================================================================
# Section 13: Cross-year transitions with February
# ================================================================
echo "Section 13: Cross-year transitions"

# 13.1
assert_eq "$(sayableage_format_age "en" "2024-12-31" "2025-03-31")" "3 months" "13.1"

# 13.2
assert_contains "$(sayableage_format_age "en" "2024-12-31" "2025-03-30")" "weeks" "13.2"

# 13.3
assert_eq "$(sayableage_format_age "en" "2024-11-30" "2025-02-28")" "3 months" "13.3"

# 13.4
assert_contains "$(sayableage_format_age "en" "2024-11-30" "2025-02-27")" "weeks" "13.4"

# ================================================================
# Section 14: Born-on-31st progression
# ================================================================
echo "Section 14: Born-on-31st progression"

# 14.1
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-04-30")" "3 months" "14.1"

# 14.2
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-05-31")" "4 months" "14.2"

# 14.3
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-06-30")" "5 months" "14.3"

# 14.4
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-07-01")" "5 months" "14.4"

# 14.5
assert_eq "$(sayableage_format_age "en" "2025-01-31" "2025-07-31")" "6 months" "14.5"

# ================================================================
# Section 15: Skipped (requires system date mocking)
# ================================================================

# ================================================================
# Section 16: formatStage — null / edge cases
# ================================================================
echo "Section 16: formatStage — null/edge"

# 16.1
assert_eq "$(sayableage_format_stage "en" "" "2025-06-15")" "" "16.1"

# 16.3
assert_eq "$(sayableage_format_stage "en" "" "2025-06-15")" "" "16.3"

# 16.4
assert_eq "$(sayableage_format_stage "en" "2025-07-01" "2025-06-15")" "" "16.4"

# 16.5
assert_eq "$(sayableage_format_stage "en" "1525-06-15" "2025-06-15")" "Adult" "16.5"

# 16.6
assert_eq "$(sayableage_format_stage "en" "1524-06-15" "2025-06-15")" "" "16.6"

# ================================================================
# Section 17: formatStage — Newborn
# ================================================================
echo "Section 17: formatStage — Newborn"

# 17.1
assert_eq "$(sayableage_format_stage "en" "2025-06-15" "2025-06-15")" "Newborn" "17.1"

# 17.2
assert_eq "$(sayableage_format_stage "en" "2025-06-14" "2025-06-15")" "Newborn" "17.2"

# 17.3
assert_eq "$(sayableage_format_stage "en" "2025-05-25" "2025-06-15")" "Newborn" "17.3"

# 17.4
assert_eq "$(sayableage_format_stage "en" "2025-05-15" "2025-06-15")" "Newborn" "17.4"

# 17.5
assert_eq "$(sayableage_format_stage "en" "2025-04-16" "2025-06-15")" "Newborn" "17.5"

# 17.6
assert_eq "$(sayableage_format_stage "en" "2025-04-15" "2025-06-15")" "Infant" "17.6"

# ================================================================
# Section 18: formatStage — Infant
# ================================================================
echo "Section 18: formatStage — Infant"

# 18.1
assert_eq "$(sayableage_format_stage "en" "2025-04-15" "2025-06-15")" "Infant" "18.1"

# 18.2
assert_eq "$(sayableage_format_stage "en" "2024-12-15" "2025-06-15")" "Infant" "18.2"

# 18.3
assert_eq "$(sayableage_format_stage "en" "2024-07-15" "2025-06-15")" "Infant" "18.3"

# 18.4
assert_eq "$(sayableage_format_stage "en" "2024-06-15" "2025-06-15")" "Toddler" "18.4"

# ================================================================
# Section 19: formatStage — Toddler
# ================================================================
echo "Section 19: formatStage — Toddler"

# 19.1
assert_eq "$(sayableage_format_stage "en" "2024-06-15" "2025-06-15")" "Toddler" "19.1"

# 19.2
assert_eq "$(sayableage_format_stage "en" "2024-01-15" "2025-07-15")" "Toddler" "19.2"

# 19.3
assert_eq "$(sayableage_format_stage "en" "2023-06-15" "2025-06-15")" "Toddler" "19.3"

# 19.4
assert_eq "$(sayableage_format_stage "en" "2023-06-15" "2026-05-15")" "Toddler" "19.4"

# 19.5
assert_eq "$(sayableage_format_stage "en" "2022-06-15" "2025-06-15")" "Child" "19.5"

# ================================================================
# Section 20: formatStage — Child
# ================================================================
echo "Section 20: formatStage — Child"

# 20.1
assert_eq "$(sayableage_format_stage "en" "2022-06-15" "2025-06-15")" "Child" "20.1"

# 20.2
assert_eq "$(sayableage_format_stage "en" "2021-06-15" "2025-06-15")" "Child" "20.2"

# 20.3
assert_eq "$(sayableage_format_stage "en" "2019-06-15" "2025-06-15")" "Child" "20.3"

# 20.4
assert_eq "$(sayableage_format_stage "en" "2016-06-15" "2025-06-15")" "Child" "20.4"

# 20.5
assert_eq "$(sayableage_format_stage "en" "2013-06-15" "2026-05-15")" "Child" "20.5"

# 20.6
assert_eq "$(sayableage_format_stage "en" "2012-06-15" "2025-06-15")" "Teenager" "20.6"

# ================================================================
# Section 21: formatStage — Teenager
# ================================================================
echo "Section 21: formatStage — Teenager"

# 21.1
assert_eq "$(sayableage_format_stage "en" "2012-06-15" "2025-06-15")" "Teenager" "21.1"

# 21.2
assert_eq "$(sayableage_format_stage "en" "2010-06-15" "2025-06-15")" "Teenager" "21.2"

# 21.3
assert_eq "$(sayableage_format_stage "en" "2008-06-15" "2026-05-15")" "Teenager" "21.3"

# 21.4
assert_eq "$(sayableage_format_stage "en" "2007-06-15" "2025-06-15")" "Adult" "21.4"

# ================================================================
# Section 22: formatStage — Adult
# ================================================================
echo "Section 22: formatStage — Adult"

# 22.1
assert_eq "$(sayableage_format_stage "en" "2007-06-15" "2025-06-15")" "Adult" "22.1"

# 22.2
assert_eq "$(sayableage_format_stage "en" "2000-06-15" "2025-06-15")" "Adult" "22.2"

# 22.3
assert_eq "$(sayableage_format_stage "en" "1980-01-01" "2025-06-15")" "Adult" "22.3"

# ================================================================
# Section 23: Skipped (requires system date mocking)
# ================================================================

# ================================================================
# Section 24: SayableAge class — English locale delegation
# ================================================================
echo "Section 24: SayableAge class — English"

# 24.1
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-06-15")" "Newborn" "24.1"

# 24.2
assert_eq "$(sayableage_format_age "en" "2025-06-12" "2025-06-15")" "3 days" "24.2"

# 24.3
assert_eq "$(sayableage_format_age "en" "2025-06-07" "2025-06-15")" "1 week, 1 day" "24.3"

# 24.4
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-07-15")" "6 months" "24.4"

# 24.5
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-07-15")" "2 years, 1 month" "24.5"

# 24.6
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-12-15")" "3½ years" "24.6"

# 24.7
assert_eq "$(sayableage_format_age "en" "2018-06-15" "2025-06-15")" "7 years" "24.7"

# 24.8
assert_eq "$(sayableage_format_stage "en" "2025-06-15" "2025-06-15")" "Newborn" "24.8"

# 24.9
assert_eq "$(sayableage_format_stage "en" "2025-01-15" "2025-06-15")" "Infant" "24.9"

# 24.10
assert_eq "$(sayableage_format_stage "en" "2024-06-15" "2025-06-15")" "Toddler" "24.10"

# 24.11
assert_eq "$(sayableage_format_stage "en" "2022-06-15" "2025-06-15")" "Child" "24.11"

# 24.12
assert_eq "$(sayableage_format_stage "en" "2012-06-15" "2025-06-15")" "Teenager" "24.12"

# 24.13
assert_eq "$(sayableage_format_stage "en" "2007-06-15" "2025-06-15")" "Adult" "24.13"

# 24.14
assert_eq "$(sayableage_format_age "en" "" "2025-06-15")" "" "24.14"

# 24.15
assert_eq "$(sayableage_format_stage "en" "" "2025-06-15")" "" "24.15"

# ================================================================
# Section 25: i18n — Spanish locale
# ================================================================
echo "Section 25: i18n — Spanish"

# 25.1
assert_eq "$(sayableage_format_age "es" "2025-06-15" "2025-06-15")" "Recién nacido" "25.1"

# 25.2
assert_eq "$(sayableage_format_age "es" "2025-06-14" "2025-06-15")" "1 día" "25.2"

# 25.3
assert_eq "$(sayableage_format_age "es" "2025-06-12" "2025-06-15")" "3 días" "25.3"

# 25.4
assert_eq "$(sayableage_format_age "es" "2025-06-08" "2025-06-15")" "1 semana" "25.4"

# 25.5
assert_eq "$(sayableage_format_age "es" "2025-06-07" "2025-06-15")" "1 semana, 1 día" "25.5"

# 25.6
assert_eq "$(sayableage_format_age "es" "2025-05-26" "2025-06-15")" "2 semanas, 6 días" "25.6"

# 25.7
assert_eq "$(sayableage_format_age "es" "2025-01-15" "2025-07-15")" "6 meses" "25.7"

# 25.8
assert_eq "$(sayableage_format_age "es" "2023-06-15" "2025-07-15")" "2 años, 1 mes" "25.8"

# 25.9
assert_eq "$(sayableage_format_age "es" "2023-06-15" "2025-12-15")" "2 años, 6 meses" "25.9"

# 25.10
assert_eq "$(sayableage_format_age "es" "2022-06-15" "2025-12-15")" "3 y medio años" "25.10"

# 25.11
assert_eq "$(sayableage_format_age "es" "2022-06-15" "2025-06-15")" "3 años" "25.11"

# 25.12
assert_eq "$(sayableage_format_age "es" "2018-06-15" "2025-06-15")" "7 años" "25.12"

# 25.13
assert_eq "$(sayableage_format_stage "es" "2025-06-15" "2025-06-15")" "Recién nacido" "25.13"

# 25.14
assert_eq "$(sayableage_format_stage "es" "2025-01-15" "2025-06-15")" "Bebé" "25.14"

# 25.15
assert_eq "$(sayableage_format_stage "es" "2024-06-15" "2025-06-15")" "Niño pequeño" "25.15"

# 25.16
assert_eq "$(sayableage_format_stage "es" "2022-06-15" "2025-06-15")" "Niño" "25.16"

# 25.17
assert_eq "$(sayableage_format_stage "es" "2012-06-15" "2025-06-15")" "Adolescente" "25.17"

# 25.18
assert_eq "$(sayableage_format_stage "es" "2007-06-15" "2025-06-15")" "Adulto" "25.18"

# 25.19
assert_eq "$(sayableage_format_age "es" "" "2025-06-15")" "" "25.19"

# 25.20
assert_eq "$(sayableage_format_stage "es" "" "2025-06-15")" "" "25.20"

# ================================================================
# Section 26: Compactness — short
# ================================================================
echo "Section 26: Compactness — short"

# 26.1
assert_eq "$(sayableage_format_age "en" "2025-06-12" "2025-06-15" "short")" "3 d" "26.1"

# 26.2
assert_eq "$(sayableage_format_age "en" "2025-06-08" "2025-06-15" "short")" "1 wk" "26.2"

# 26.3
assert_eq "$(sayableage_format_age "en" "2025-06-07" "2025-06-15" "short")" "1 wk, 1 d" "26.3"

# 26.4
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-07-15" "short")" "6 mo" "26.4"

# 26.5
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-07-15" "short")" "2 yr, 1 mo" "26.5"

# 26.6
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-12-15" "short")" "3½ yr" "26.6"

# 26.7
assert_eq "$(sayableage_format_age "en" "2018-06-15" "2025-06-15" "short")" "7 yr" "26.7"

# 26.8
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-06-15" "short")" "Newborn" "26.8"

# 26.9
assert_eq "$(sayableage_format_stage "en" "2025-01-15" "2025-06-15")" "Infant" "26.9"

# ================================================================
# Section 27: Compactness — compact
# ================================================================
echo "Section 27: Compactness — compact"

# 27.1
assert_eq "$(sayableage_format_age "en" "2025-06-12" "2025-06-15" "compact")" "3d" "27.1"

# 27.2
assert_eq "$(sayableage_format_age "en" "2025-06-08" "2025-06-15" "compact")" "1w" "27.2"

# 27.3
assert_eq "$(sayableage_format_age "en" "2025-06-07" "2025-06-15" "compact")" "1w1d" "27.3"

# 27.4
assert_eq "$(sayableage_format_age "en" "2025-01-15" "2025-07-15" "compact")" "6m" "27.4"

# 27.5
assert_eq "$(sayableage_format_age "en" "2023-06-15" "2025-07-15" "compact")" "2y1m" "27.5"

# 27.6
assert_eq "$(sayableage_format_age "en" "2022-06-15" "2025-12-15" "compact")" "3½y" "27.6"

# 27.7
assert_eq "$(sayableage_format_age "en" "2018-06-15" "2025-06-15" "compact")" "7y" "27.7"

# 27.8
assert_eq "$(sayableage_format_age "en" "2025-06-15" "2025-06-15" "compact")" "Newborn" "27.8"

# ================================================================
# Section 29: Locale-specific edge cases — plural rules
# ================================================================
echo "Section 29: Locale-specific edge cases"

# --- Hebrew ---

# 29.1
assert_eq "$(sayableage_format_age "he" "2025-06-15" "2025-06-15")" "רק נולד" "29.1"

# 29.2
assert_eq "$(sayableage_format_age "he" "2025-06-14" "2025-06-15")" "יום 1" "29.2"

# 29.3
assert_eq "$(sayableage_format_age "he" "2025-06-12" "2025-06-15")" "3 ימים" "29.3"

# 29.4
assert_eq "$(sayableage_format_age "he" "2025-06-01" "2025-06-15")" "שבועיים" "29.4"

# 29.5
assert_eq "$(sayableage_format_age "he" "2025-05-25" "2025-06-15")" "3 שבועות" "29.5"

# 29.6
assert_eq "$(sayableage_format_age "he" "2025-01-15" "2025-07-15")" "6 חודשים" "29.6"

# 29.7
assert_eq "$(sayableage_format_age "he" "2025-03-15" "2025-06-15")" "3 חודשים" "29.7"

# 29.8
assert_eq "$(sayableage_format_age "he" "2023-06-15" "2025-07-15")" "שנתיים, חודש 1" "29.8"

# 29.9
assert_eq "$(sayableage_format_age "he" "2022-06-15" "2025-12-15")" "3 שנים וחצי" "29.9"

# 29.10
assert_eq "$(sayableage_format_age "he" "2018-06-15" "2025-06-15")" "7 שנים" "29.10"

# 29.11
assert_eq "$(sayableage_format_stage "he" "2025-06-15" "2025-06-15" "m")" "רק נולד" "29.11"

# 29.12
assert_eq "$(sayableage_format_stage "he" "2025-06-15" "2025-06-15" "f")" "רק נולדה" "29.12"

# 29.13
assert_eq "$(sayableage_format_stage "he" "2007-06-15" "2025-06-15" "m")" "מבוגר" "29.13"

# 29.14
assert_eq "$(sayableage_format_stage "he" "2007-06-15" "2025-06-15" "f")" "מבוגרת" "29.14"

# --- Macedonian ---

# 29.15
assert_eq "$(sayableage_format_age "mk" "2025-06-15" "2025-06-15")" "Новороденче" "29.15"

# 29.16
assert_eq "$(sayableage_format_age "mk" "2025-06-14" "2025-06-15")" "1 ден" "29.16"

# 29.17
assert_eq "$(sayableage_format_age "mk" "2025-06-12" "2025-06-15")" "3 дена" "29.17"

# 29.18
assert_eq "$(sayableage_format_age "mk" "2025-01-15" "2025-07-15")" "6 месеци" "29.18"

# 29.19
assert_eq "$(sayableage_format_age "mk" "2023-06-15" "2025-07-15")" "2 години, 1 месец" "29.19"

# 29.20
assert_eq "$(sayableage_format_age "mk" "2022-06-15" "2025-12-15")" "3 години и пол" "29.20"

# 29.21
assert_eq "$(sayableage_format_age "mk" "2018-06-15" "2025-06-15")" "7 години" "29.21"

# --- Swahili ---

# 29.22
assert_eq "$(sayableage_format_age "sw" "2025-06-15" "2025-06-15")" "Mzaliwa mpya" "29.22"

# 29.23
assert_eq "$(sayableage_format_age "sw" "2025-06-14" "2025-06-15")" "siku 1" "29.23"

# 29.24
assert_eq "$(sayableage_format_age "sw" "2025-06-12" "2025-06-15")" "siku 3" "29.24"

# 29.25
assert_eq "$(sayableage_format_age "sw" "2025-01-15" "2025-07-15")" "miezi 6" "29.25"

# 29.26
assert_eq "$(sayableage_format_age "sw" "2023-06-15" "2025-07-15")" "miaka 2, mwezi 1" "29.26"

# 29.27
assert_eq "$(sayableage_format_age "sw" "2022-06-15" "2025-12-15")" "miaka 3 na nusu" "29.27"

# --- Indonesian ---

# 29.28
assert_eq "$(sayableage_format_age "id" "2025-06-15" "2025-06-15")" "Baru lahir" "29.28"

# 29.29
assert_eq "$(sayableage_format_age "id" "2025-06-14" "2025-06-15")" "1 hari" "29.29"

# 29.30
assert_eq "$(sayableage_format_age "id" "2025-06-12" "2025-06-15")" "3 hari" "29.30"

# 29.31
assert_eq "$(sayableage_format_age "id" "2025-01-15" "2025-07-15")" "6 bulan" "29.31"

# 29.32
assert_eq "$(sayableage_format_age "id" "2022-06-15" "2025-12-15")" "3 tahun setengah" "29.32"

# 29.33
assert_eq "$(sayableage_format_age "id" "2018-06-15" "2025-06-15")" "7 tahun" "29.33"

# --- Amharic ---

# 29.34
assert_eq "$(sayableage_format_age "am" "2025-06-15" "2025-06-15")" "አዲስ የተወለደ" "29.34"

# 29.35
assert_eq "$(sayableage_format_age "am" "2025-06-14" "2025-06-15")" "1 ቀን" "29.35"

# 29.36
assert_eq "$(sayableage_format_age "am" "2025-06-12" "2025-06-15")" "3 ቀናት" "29.36"

# 29.37
assert_eq "$(sayableage_format_age "am" "2025-06-07" "2025-06-15")" "1 ሳምንት፣ 1 ቀን" "29.37"

# 29.38
assert_eq "$(sayableage_format_age "am" "2025-01-15" "2025-07-15")" "6 ወራት" "29.38"

# 29.39
assert_eq "$(sayableage_format_age "am" "2022-06-15" "2025-12-15")" "3 ዓመታት ተኩል" "29.39"

# ================================================================
# Section 30: Locale lookup by code string
# ================================================================
echo "Section 30: Locale lookup"

# 30.1
if sayableage_get_locale "en" 2>/dev/null; then
    assert_eq "true" "true" "30.1" "en locale found"
else
    assert_eq "false" "true" "30.1" "en locale found"
fi

# 30.2
if sayableage_get_locale "fr" 2>/dev/null; then
    assert_eq "true" "true" "30.2" "fr locale found"
else
    assert_eq "false" "true" "30.2" "fr locale found"
fi

# 30.3
if sayableage_get_locale "xx" 2>/dev/null; then
    assert_eq "found" "not found" "30.3"
else
    assert_eq "not found" "not found" "30.3"
fi

# 30.4
if sayableage_get_locale "" 2>/dev/null; then
    assert_eq "found" "not found" "30.4"
else
    assert_eq "not found" "not found" "30.4"
fi

# 30.5
if sayableage_get_locale "EN" 2>/dev/null; then
    assert_eq "found" "not found" "30.5"
else
    assert_eq "not found" "not found" "30.5"
fi

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
