#!/usr/bin/env bash
# Integration tests for the sayable-age CLI.
# All test cases use canonical IDs from config/tests.json.
set -uo pipefail

CLI="$(cd "$(dirname "$0")" && pwd)/build/sayable-age"
pass=0
fail=0

check() {
    local desc="$1" expected="$2"
    shift 2
    local actual
    if ! actual=$("$@" 2>&1); then
        printf "FAIL: %s\n  command exited non-zero\n  expected: %s\n  got:      %s\n" "$desc" "$expected" "$actual"
        ((++fail)); return
    fi
    if [ "$actual" = "$expected" ]; then
        ((++pass))
    else
        printf "FAIL: %s\n  expected: %s\n  got:      %s\n" "$desc" "$expected" "$actual"
        ((++fail))
    fi
}

check_weeks() {
    local desc="$1"
    shift
    local actual
    if ! actual=$("$@" 2>&1); then
        printf "FAIL: %s\n  command exited non-zero\n  got: %s\n" "$desc" "$actual"
        ((++fail)); return
    fi
    if echo "$actual" | grep -qE "week"; then
        ((++pass))
    else
        printf "FAIL: %s\n  expected weeks pattern\n  got: %s\n" "$desc" "$actual"
        ((++fail))
    fi
}

check_err() {
    local desc="$1" pattern="$2"
    shift 2
    local actual
    if actual=$("$@" 2>&1); then
        printf "FAIL: %s\n  expected non-zero exit, but got 0\n  output: %s\n" "$desc" "$actual"
        ((++fail)); return
    fi
    if echo "$actual" | grep -q "$pattern"; then
        ((++pass))
    else
        printf "FAIL: %s\n  expected stderr containing: %s\n  got: %s\n" "$desc" "$pattern" "$actual"
        ((++fail))
    fi
}

age()   { "$CLI" age   "$@"; }
stage() { "$CLI" stage "$@"; }

# Build first if needed
if [ ! -x "$CLI" ]; then
    echo "Building CLI..."
    (cd "$(dirname "$0")" && cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build) >/dev/null 2>&1
fi

# ── 1. Null / edge cases ─────────────────────────────────────────────
check_err "1.1"  "requires a date"      age                                          # null → missing arg
# 1.2 skipped (undefined — language-specific)
check_err "1.3"  "could not format age"  age "" -d 2025-06-15                         # empty string
check_err "1.4"  "could not format age"  age 2025-07-01 -d 2025-06-15                # future DOB
check     "1.5"  "500 years"             age 1525-06-15 -d 2025-06-15                 # exactly 500 years
check_err "1.6"  "could not format age"  age 1524-06-15 -d 2025-06-15                # 501 years
check_err "1.7"  "could not format age"  age 1025-06-15 -d 2025-06-15                # 1000 years

# ── 2. Days tier (0–6 days) ───────────────────────────────────────────
check "2.1"  "Newborn"  age 2025-06-15 -d 2025-06-15
check "2.2"  "1 day"    age 2025-06-14 -d 2025-06-15
check "2.3"  "3 days"   age 2025-06-12 -d 2025-06-15
check "2.4"  "6 days"   age 2025-06-09 -d 2025-06-15
check "2.5"  "1 week"   age 2025-06-08 -d 2025-06-15

# ── 3. Weeks+days tier ────────────────────────────────────────────────
check "3.1"   "1 week"           age 2025-06-08 -d 2025-06-15
check "3.2"   "1 week, 1 day"    age 2025-06-07 -d 2025-06-15
check "3.3"   "1 week, 2 days"   age 2025-06-06 -d 2025-06-15
check "3.4"   "1 week, 6 days"   age 2025-06-02 -d 2025-06-15
check "3.5"   "2 weeks"          age 2025-06-01 -d 2025-06-15
check "3.6"   "2 weeks, 1 day"   age 2025-05-31 -d 2025-06-15
check "3.7"   "2 weeks, 6 days"  age 2025-05-26 -d 2025-06-15
check "3.8"   "3 weeks"          age 2025-05-25 -d 2025-06-15
check "3.9"   "4 weeks, 3 days"  age 2025-05-15 -d 2025-06-15
check "3.10"  "8 weeks, 5 days"  age 2025-04-15 -d 2025-06-15
check "3.11"  "13 weeks"         age 2025-03-15 -d 2025-06-14
check "3.12"  "3 months"         age 2025-03-15 -d 2025-06-15

# ── 4. Month boundaries — standard months ─────────────────────────────
check       "4.1"  "3 months"  age 2025-01-01 -d 2025-04-01
check_weeks "4.2"              age 2025-01-01 -d 2025-03-31
check       "4.3"  "3 months"  age 2025-06-15 -d 2025-09-15
check_weeks "4.4"              age 2025-06-15 -d 2025-09-14
check       "4.5"  "6 months"  age 2025-06-15 -d 2025-12-15

# ── 5. Month boundaries — February non-leap year ──────────────────────
check       "5.1"  "4 weeks"    age 2025-01-31 -d 2025-02-28
check       "5.2"  "3 months"   age 2025-01-31 -d 2025-04-30
check_weeks "5.3"               age 2025-01-31 -d 2025-04-29
check       "5.4"  "3 months"   age 2025-02-01 -d 2025-05-01
check_weeks "5.5"               age 2025-02-01 -d 2025-04-30

# ── 6. Month boundaries — February leap year ──────────────────────────
check       "6.1"  "4 weeks, 1 day"  age 2024-01-31 -d 2024-02-29
check       "6.2"  "4 weeks"         age 2024-01-31 -d 2024-02-28
check       "6.3"  "3 months"        age 2024-01-31 -d 2024-04-30
check_weeks "6.4"                    age 2024-01-30 -d 2024-02-29
check_weeks "6.5"                    age 2024-01-30 -d 2024-02-28

# ── 7. Month boundaries — 30-day months ───────────────────────────────
check       "7.1"  "3 months"  age 2025-03-31 -d 2025-06-30
check_weeks "7.2"              age 2025-03-31 -d 2025-06-29
check       "7.3"  "3 months"  age 2025-08-31 -d 2025-11-30
check_weeks "7.4"              age 2025-08-31 -d 2025-11-29

# ── 8. Month boundaries — leap year baby ──────────────────────────────
check       "8.1"  "3 months"   age 2024-02-29 -d 2024-05-29
check_weeks "8.2"               age 2024-02-29 -d 2024-05-28
check       "8.3"  "12 months"  age 2024-02-29 -d 2025-02-28
check       "8.4"  "12 months"  age 2024-02-29 -d 2025-03-01

# ── 9. Months tier (3–23 months) ──────────────────────────────────────
check "9.1"  "3 months"   age 2025-01-15 -d 2025-04-15
check "9.2"  "6 months"   age 2025-01-15 -d 2025-07-15
check "9.3"  "12 months"  age 2024-06-15 -d 2025-06-15
check "9.4"  "23 months"  age 2024-01-15 -d 2025-12-15
check "9.5"  "5 months"   age 2025-01-15 -d 2025-07-14
check "9.6"  "5 months"   age 2024-11-10 -d 2025-04-10

# ── 10. Years+months tier (24–35 months) ──────────────────────────────
check "10.1"  "2 years"             age 2023-06-15 -d 2025-06-15
check "10.2"  "2 years, 1 month"    age 2023-06-15 -d 2025-07-15
check "10.3"  "2 years, 6 months"   age 2023-06-15 -d 2025-12-15
check "10.4"  "2 years, 11 months"  age 2023-06-15 -d 2026-05-15
check "10.5"  "23 months"           age 2023-06-15 -d 2025-06-14

# ── 11. Half-year tier (3–6 years) ────────────────────────────────────
check "11.1"   "3 years"             age 2022-06-15 -d 2025-06-15
check "11.2"   "3 years"             age 2022-06-15 -d 2025-11-15
check "11.3"   "3½ years"            age 2022-06-15 -d 2025-12-15
check "11.4"   "3½ years"            age 2022-06-15 -d 2026-05-15
check "11.5"   "4 years"             age 2021-06-15 -d 2025-06-15
check "11.6"   "4½ years"            age 2021-06-15 -d 2025-12-15
check "11.7"   "5 years"             age 2020-06-15 -d 2025-06-15
check "11.8"   "5½ years"            age 2020-06-15 -d 2026-02-15
check "11.9"   "6 years"             age 2019-06-15 -d 2025-06-15
check "11.10"  "6½ years"            age 2019-06-15 -d 2025-12-15
check "11.11"  "6½ years"            age 2019-06-15 -d 2026-05-15
check "11.12"  "2 years, 11 months"  age 2022-06-15 -d 2025-06-14

# ── 12. Integer tier (7+ years) ───────────────────────────────────────
check "12.1"  "7 years"   age 2018-06-15 -d 2025-06-15
check "12.2"  "7 years"   age 2018-03-20 -d 2025-06-15
check "12.3"  "45 years"  age 1980-01-01 -d 2025-06-15

# ── 13. Cross-year transitions with February ──────────────────────────
check       "13.1"  "3 months"  age 2024-12-31 -d 2025-03-31
check_weeks "13.2"              age 2024-12-31 -d 2025-03-30
check       "13.3"  "3 months"  age 2024-11-30 -d 2025-02-28
check_weeks "13.4"              age 2024-11-30 -d 2025-02-27

# ── 14. Born-on-31st progression ──────────────────────────────────────
check "14.1"  "3 months"  age 2025-01-31 -d 2025-04-30
check "14.2"  "4 months"  age 2025-01-31 -d 2025-05-31
check "14.3"  "5 months"  age 2025-01-31 -d 2025-06-30
check "14.4"  "5 months"  age 2025-01-31 -d 2025-07-01
check "14.5"  "6 months"  age 2025-01-31 -d 2025-07-31

# ── 15. Default asOf — skipped (requires clock mocking) ───────────────
# 15.1, 15.2

# ── 16. formatStage — null / edge cases ───────────────────────────────
check_err "16.1"  "requires a date"           stage                                    # null → missing arg
# 16.2 skipped (undefined — language-specific)
check_err "16.3"  "could not determine stage"  stage "" -d 2025-06-15                   # empty string
check_err "16.4"  "could not determine stage"  stage 2025-07-01 -d 2025-06-15           # future DOB
check     "16.5"  "Adult"                      stage 1525-06-15 -d 2025-06-15           # exactly 500 years
check_err "16.6"  "could not determine stage"  stage 1524-06-15 -d 2025-06-15           # 501 years

# ── 17. formatStage — Newborn ─────────────────────────────────────────
check "17.1"  "Newborn"  stage 2025-06-15 -d 2025-06-15
check "17.2"  "Newborn"  stage 2025-06-14 -d 2025-06-15
check "17.3"  "Newborn"  stage 2025-05-25 -d 2025-06-15
check "17.4"  "Newborn"  stage 2025-05-15 -d 2025-06-15
check "17.5"  "Newborn"  stage 2025-04-16 -d 2025-06-15
check "17.6"  "Infant"   stage 2025-04-15 -d 2025-06-15

# ── 18. formatStage — Infant ─────────────────────────────────────────
check "18.1"  "Infant"   stage 2025-04-15 -d 2025-06-15
check "18.2"  "Infant"   stage 2024-12-15 -d 2025-06-15
check "18.3"  "Infant"   stage 2024-07-15 -d 2025-06-15
check "18.4"  "Toddler"  stage 2024-06-15 -d 2025-06-15

# ── 19. formatStage — Toddler ────────────────────────────────────────
check "19.1"  "Toddler"  stage 2024-06-15 -d 2025-06-15
check "19.2"  "Toddler"  stage 2024-01-15 -d 2025-07-15
check "19.3"  "Toddler"  stage 2023-06-15 -d 2025-06-15
check "19.4"  "Toddler"  stage 2023-06-15 -d 2026-05-15
check "19.5"  "Child"    stage 2022-06-15 -d 2025-06-15

# ── 20. formatStage — Child ──────────────────────────────────────────
check "20.1"  "Child"     stage 2022-06-15 -d 2025-06-15
check "20.2"  "Child"     stage 2021-06-15 -d 2025-06-15
check "20.3"  "Child"     stage 2019-06-15 -d 2025-06-15
check "20.4"  "Child"     stage 2016-06-15 -d 2025-06-15
check "20.5"  "Child"     stage 2013-06-15 -d 2026-05-15
check "20.6"  "Teenager"  stage 2012-06-15 -d 2025-06-15

# ── 21. formatStage — Teenager ────────────────────────────────────────
check "21.1"  "Teenager"  stage 2012-06-15 -d 2025-06-15
check "21.2"  "Teenager"  stage 2010-06-15 -d 2025-06-15
check "21.3"  "Teenager"  stage 2008-06-15 -d 2026-05-15
check "21.4"  "Adult"     stage 2007-06-15 -d 2025-06-15

# ── 22. formatStage — Adult ──────────────────────────────────────────
check "22.1"  "Adult"  stage 2007-06-15 -d 2025-06-15
check "22.2"  "Adult"  stage 2000-06-15 -d 2025-06-15
check "22.3"  "Adult"  stage 1980-01-01 -d 2025-06-15

# ── 23. formatStage — default asOf — skipped (requires clock mocking) ─
# 23.1, 23.2, 23.3

# ── 24. Class delegation — CLI is the wrapper ─────────────────────────
check     "24.1"   "Newborn"            age   2025-06-15 -d 2025-06-15
check     "24.2"   "3 days"             age   2025-06-12 -d 2025-06-15
check     "24.3"   "1 week, 1 day"      age   2025-06-07 -d 2025-06-15
check     "24.4"   "6 months"           age   2025-01-15 -d 2025-07-15
check     "24.5"   "2 years, 1 month"   age   2023-06-15 -d 2025-07-15
check     "24.6"   "3½ years"           age   2022-06-15 -d 2025-12-15
check     "24.7"   "7 years"            age   2018-06-15 -d 2025-06-15
check     "24.8"   "Newborn"            stage 2025-06-15 -d 2025-06-15
check     "24.9"   "Infant"             stage 2025-01-15 -d 2025-06-15
check     "24.10"  "Toddler"            stage 2024-06-15 -d 2025-06-15
check     "24.11"  "Child"              stage 2022-06-15 -d 2025-06-15
check     "24.12"  "Teenager"           stage 2012-06-15 -d 2025-06-15
check     "24.13"  "Adult"              stage 2007-06-15 -d 2025-06-15
check_err "24.14"  "requires a date"    age                                            # null
check_err "24.15"  "requires a date"    stage                                          # null

# ── 25. i18n — Spanish locale ─────────────────────────────────────────
check     "25.1"   "Recién nacido"       age   2025-06-15 -d 2025-06-15 -l es
check     "25.2"   "1 día"              age   2025-06-14 -d 2025-06-15 -l es
check     "25.3"   "3 días"             age   2025-06-12 -d 2025-06-15 -l es
check     "25.4"   "1 semana"           age   2025-06-08 -d 2025-06-15 -l es
check     "25.5"   "1 semana, 1 día"    age   2025-06-07 -d 2025-06-15 -l es
check     "25.6"   "2 semanas, 6 días"  age   2025-05-26 -d 2025-06-15 -l es
check     "25.7"   "6 meses"            age   2025-01-15 -d 2025-07-15 -l es
check     "25.8"   "2 años, 1 mes"      age   2023-06-15 -d 2025-07-15 -l es
check     "25.9"   "2 años, 6 meses"    age   2023-06-15 -d 2025-12-15 -l es
check     "25.10"  "3 y medio años"     age   2022-06-15 -d 2025-12-15 -l es
check     "25.11"  "3 años"             age   2022-06-15 -d 2025-06-15 -l es
check     "25.12"  "7 años"             age   2018-06-15 -d 2025-06-15 -l es
check     "25.13"  "Recién nacido"       stage 2025-06-15 -d 2025-06-15 -l es
check     "25.14"  "Bebé"               stage 2025-01-15 -d 2025-06-15 -l es
check     "25.15"  "Niño pequeño"       stage 2024-06-15 -d 2025-06-15 -l es
check     "25.16"  "Niño"               stage 2022-06-15 -d 2025-06-15 -l es
check     "25.17"  "Adolescente"        stage 2012-06-15 -d 2025-06-15 -l es
check     "25.18"  "Adulto"             stage 2007-06-15 -d 2025-06-15 -l es
check_err "25.19"  "could not format age"      age   "" -d 2025-06-15 -l es            # null DOB
check_err "25.20"  "could not determine stage" stage "" -d 2025-06-15 -l es            # null DOB

# ── 26. Compactness — short ───────────────────────────────────────────
check "26.1"  "3 d"          age 2025-06-12 -d 2025-06-15 --short
check "26.2"  "1 wk"         age 2025-06-08 -d 2025-06-15 --short
check "26.3"  "1 wk, 1 d"   age 2025-06-07 -d 2025-06-15 --short
check "26.4"  "6 mo"         age 2025-01-15 -d 2025-07-15 --short
check "26.5"  "2 yr, 1 mo"  age 2023-06-15 -d 2025-07-15 --short
check "26.6"  "3½ yr"        age 2022-06-15 -d 2025-12-15 --short
check "26.7"  "7 yr"         age 2018-06-15 -d 2025-06-15 --short
check "26.8"  "Newborn"      age 2025-06-15 -d 2025-06-15 --short
# 26.9 skipped (stages are unaffected by compactness — not a CLI concern)

# ── 27. Compactness — compact ─────────────────────────────────────────
check "27.1"  "3d"       age 2025-06-12 -d 2025-06-15 --compact
check "27.2"  "1w"       age 2025-06-08 -d 2025-06-15 --compact
check "27.3"  "1w1d"     age 2025-06-07 -d 2025-06-15 --compact
check "27.4"  "6m"       age 2025-01-15 -d 2025-07-15 --compact
check "27.5"  "2y1m"     age 2023-06-15 -d 2025-07-15 --compact
check "27.6"  "3½y"      age 2022-06-15 -d 2025-12-15 --compact
check "27.7"  "7y"       age 2018-06-15 -d 2025-06-15 --compact
check "27.8"  "Newborn"  age 2025-06-15 -d 2025-06-15 --compact

# ── 29.1 Hebrew (he) — dual forms ────────────────────────────────────
check "29.1"   "רק נולד"         age   2025-06-15 -d 2025-06-15 -l he
check "29.2"   "יום 1"           age   2025-06-14 -d 2025-06-15 -l he
check "29.3"   "3 ימים"          age   2025-06-12 -d 2025-06-15 -l he
check "29.4"   "שבועיים"         age   2025-06-01 -d 2025-06-15 -l he
check "29.5"   "3 שבועות"        age   2025-05-25 -d 2025-06-15 -l he
check "29.6"   "6 חודשים"        age   2025-01-15 -d 2025-07-15 -l he
check "29.7"   "3 חודשים"        age   2025-03-15 -d 2025-06-15 -l he
check "29.8"   "שנתיים, חודש 1"  age   2023-06-15 -d 2025-07-15 -l he
check "29.9"   "3 שנים וחצי"     age   2022-06-15 -d 2025-12-15 -l he
check "29.10"  "7 שנים"          age   2018-06-15 -d 2025-06-15 -l he
check "29.11"  "רק נולד"         stage 2025-06-15 -d 2025-06-15 -l he -g m
check "29.12"  "רק נולדה"        stage 2025-06-15 -d 2025-06-15 -l he -g f
check "29.13"  "מבוגר"           stage 2007-06-15 -d 2025-06-15 -l he -g m
check "29.14"  "מבוגרת"          stage 2007-06-15 -d 2025-06-15 -l he -g f

# ── 29.2 Macedonian (mk) — mod10/mod100 rule ─────────────────────────
check "29.15"  "Новороденче"        age 2025-06-15 -d 2025-06-15 -l mk
check "29.16"  "1 ден"              age 2025-06-14 -d 2025-06-15 -l mk
check "29.17"  "3 дена"             age 2025-06-12 -d 2025-06-15 -l mk
check "29.18"  "6 месеци"           age 2025-01-15 -d 2025-07-15 -l mk
check "29.19"  "2 години, 1 месец"  age 2023-06-15 -d 2025-07-15 -l mk
check "29.20"  "3 години и пол"     age 2022-06-15 -d 2025-12-15 -l mk
check "29.21"  "7 години"           age 2018-06-15 -d 2025-06-15 -l mk

# ── 29.3 Swahili (sw) — noun class changes ───────────────────────────
check "29.22"  "Mzaliwa mpya"      age 2025-06-15 -d 2025-06-15 -l sw
check "29.23"  "siku 1"            age 2025-06-14 -d 2025-06-15 -l sw
check "29.24"  "siku 3"            age 2025-06-12 -d 2025-06-15 -l sw
check "29.25"  "miezi 6"           age 2025-01-15 -d 2025-07-15 -l sw
check "29.26"  "miaka 2, mwezi 1"  age 2023-06-15 -d 2025-07-15 -l sw
check "29.27"  "miaka 3 na nusu"   age 2022-06-15 -d 2025-12-15 -l sw

# ── 29.4 Indonesian (id) — other_only ─────────────────────────────────
check "29.28"  "Baru lahir"        age 2025-06-15 -d 2025-06-15 -l id
check "29.29"  "1 hari"            age 2025-06-14 -d 2025-06-15 -l id
check "29.30"  "3 hari"            age 2025-06-12 -d 2025-06-15 -l id
check "29.31"  "6 bulan"           age 2025-01-15 -d 2025-07-15 -l id
check "29.32"  "3 tahun setengah"  age 2022-06-15 -d 2025-12-15 -l id
check "29.33"  "7 tahun"           age 2018-06-15 -d 2025-06-15 -l id

# ── 29.5 Amharic (am) — Ethiopic delimiter ────────────────────────────
check "29.34"  "አዲስ የተወለደ"     age 2025-06-15 -d 2025-06-15 -l am
check "29.35"  "1 ቀን"           age 2025-06-14 -d 2025-06-15 -l am
check "29.36"  "3 ቀናት"          age 2025-06-12 -d 2025-06-15 -l am
check "29.37"  "1 ሳምንት፣ 1 ቀን"  age 2025-06-07 -d 2025-06-15 -l am
check "29.38"  "6 ወራት"          age 2025-01-15 -d 2025-07-15 -l am
check "29.39"  "3 ዓመታት ተኩል"    age 2022-06-15 -d 2025-12-15 -l am

# ── 30. Locale lookup ─────────────────────────────────────────────────
check     "30.1"  "Newborn"          age 2025-06-15 -d 2025-06-15 -l en     # known
check     "30.2"  "Nouveau-né"       age 2025-06-15 -d 2025-06-15 -l fr     # known
check_err "30.3"  "unknown locale"   age 2025-06-15 -d 2025-06-15 -l xx     # unknown
check_err "30.4"  "unknown locale"   age 2025-06-15 -d 2025-06-15 -l ""     # empty
check_err "30.5"  "unknown locale"   age 2025-06-15 -d 2025-06-15 -l EN     # case-sensitive

echo ""
echo "$((pass + fail)) tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
