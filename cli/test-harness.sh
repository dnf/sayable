#!/usr/bin/env bash
# ==========================================================================
# Sayable CLI Test Harness
# Generated from canonical test JSON files — do not edit by hand.
# Regenerate: python3 cli/generate-test-harness.py
#
# Runs every test through one `<cli> --repl` process (see cli/SPEC.md).
# ==========================================================================
set -euo pipefail

CLI="${1:?Usage: $0 <path-to-cli-binary>}"

# Verify the CLI exists and is executable
if [[ ! -x "${CLI}" ]] && ! command -v "${CLI}" &>/dev/null; then
    echo "error: ${CLI} is not executable or not found" >&2
    exit 2
fi

# Counters
_pass=0
_fail=0
_total=0

# Color support
if [[ -t 1 ]]; then
    _red="\033[31m"
    _green="\033[32m"
    _reset="\033[0m"
else
    _red="" _green="" _reset=""
fi

# Requests are queued, answered by a single `--repl` process, then checked.
# Request: the CLI arguments joined by tabs. Response: "<exit>\t<output>".
_tab=$'\t'
_ids=()
_kinds=()
_expects=()
_requests=""

_queue() {
    local id="$1" kind="$2" expected="$3"
    shift 3
    local IFS="${_tab}"
    _ids+=("${id}")
    _kinds+=("${kind}")
    _expects+=("${expected}")
    _requests+="$*"$'\n'
}

run_test() { local id="$1" expected="$2"; shift 2; _queue "${id}" test "${expected}" "$@"; }
run_null() { local id="$1"; shift; _queue "${id}" null "" "$@"; }
run_regex() { local id="$1" pattern="$2"; shift 2; _queue "${id}" regex "${pattern}" "$@"; }

# ══════════════════════════════════════════════════════════════
# AGE COMPONENT
# ══════════════════════════════════════════════════════════════

# === Age 1: Null / edge cases ===
run_null 'age:1.1' age null
# Skipped: 1.2 — 'undefined' is language-specific
run_null 'age:1.3' age ''
run_null 'age:1.4' age 2025-07-01 -d 2025-06-15
run_test 'age:1.5' '500 years' age 1525-06-15 -d 2025-06-15
run_null 'age:1.6' age 1524-06-15 -d 2025-06-15
run_null 'age:1.7' age 1025-06-15 -d 2025-06-15

# === Age 2: Days tier (0–6 days) ===
run_test 'age:2.1' 'Newborn' age 2025-06-15 -d 2025-06-15
run_test 'age:2.2' '1 day' age 2025-06-14 -d 2025-06-15
run_test 'age:2.3' '3 days' age 2025-06-12 -d 2025-06-15
run_test 'age:2.4' '6 days' age 2025-06-09 -d 2025-06-15
run_test 'age:2.5' '1 week' age 2025-06-08 -d 2025-06-15

# === Age 3: Weeks+days tier (7 days to <3 calendar months) ===
run_test 'age:3.1' '1 week' age 2025-06-08 -d 2025-06-15
run_test 'age:3.2' '1 week, 1 day' age 2025-06-07 -d 2025-06-15
run_test 'age:3.3' '1 week, 2 days' age 2025-06-06 -d 2025-06-15
run_test 'age:3.4' '1 week, 6 days' age 2025-06-02 -d 2025-06-15
run_test 'age:3.5' '2 weeks' age 2025-06-01 -d 2025-06-15
run_test 'age:3.6' '2 weeks, 1 day' age 2025-05-31 -d 2025-06-15
run_test 'age:3.7' '2 weeks, 6 days' age 2025-05-26 -d 2025-06-15
run_test 'age:3.8' '3 weeks' age 2025-05-25 -d 2025-06-15
run_test 'age:3.9' '4 weeks, 3 days' age 2025-05-15 -d 2025-06-15
run_test 'age:3.10' '8 weeks, 5 days' age 2025-04-15 -d 2025-06-15
run_test 'age:3.11' '13 weeks' age 2025-03-15 -d 2025-06-14
run_test 'age:3.12' '3 months' age 2025-03-15 -d 2025-06-15

# === Age 4: Month boundaries — standard months ===
run_test 'age:4.1' '3 months' age 2025-01-01 -d 2025-04-01
run_regex 'age:4.2' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-01-01 -d 2025-03-31
run_test 'age:4.3' '3 months' age 2025-06-15 -d 2025-09-15
run_regex 'age:4.4' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-06-15 -d 2025-09-14
run_test 'age:4.5' '6 months' age 2025-06-15 -d 2025-12-15

# === Age 5: Month boundaries — February non-leap year ===
run_test 'age:5.1' '4 weeks' age 2025-01-31 -d 2025-02-28
run_test 'age:5.2' '3 months' age 2025-01-31 -d 2025-04-30
run_regex 'age:5.3' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-01-31 -d 2025-04-29
run_test 'age:5.4' '3 months' age 2025-02-01 -d 2025-05-01
run_regex 'age:5.5' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-02-01 -d 2025-04-30

# === Age 6: Month boundaries — February leap year ===
run_test 'age:6.1' '4 weeks, 1 day' age 2024-01-31 -d 2024-02-29
run_test 'age:6.2' '4 weeks' age 2024-01-31 -d 2024-02-28
run_test 'age:6.3' '3 months' age 2024-01-31 -d 2024-04-30
run_regex 'age:6.4' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2024-01-30 -d 2024-02-29
run_regex 'age:6.5' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2024-01-30 -d 2024-02-28

# === Age 7: Month boundaries — 30-day months ===
run_test 'age:7.1' '3 months' age 2025-03-31 -d 2025-06-30
run_regex 'age:7.2' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-03-31 -d 2025-06-29
run_test 'age:7.3' '3 months' age 2025-08-31 -d 2025-11-30
run_regex 'age:7.4' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2025-08-31 -d 2025-11-29

# === Age 8: Month boundaries — leap year baby (born Feb 29) ===
run_test 'age:8.1' '3 months' age 2024-02-29 -d 2024-05-29
run_regex 'age:8.2' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2024-02-29 -d 2024-05-28
run_test 'age:8.3' '12 months' age 2024-02-29 -d 2025-02-28
run_test 'age:8.4' '12 months' age 2024-02-29 -d 2025-03-01

# === Age 9: Months tier (3–23 months) ===
run_test 'age:9.1' '3 months' age 2025-01-15 -d 2025-04-15
run_test 'age:9.2' '6 months' age 2025-01-15 -d 2025-07-15
run_test 'age:9.3' '12 months' age 2024-06-15 -d 2025-06-15
run_test 'age:9.4' '23 months' age 2024-01-15 -d 2025-12-15
run_test 'age:9.5' '5 months' age 2025-01-15 -d 2025-07-14
run_test 'age:9.6' '5 months' age 2024-11-10 -d 2025-04-10

# === Age 10: Years+months tier (24–35 months) ===
run_test 'age:10.1' '2 years' age 2023-06-15 -d 2025-06-15
run_test 'age:10.2' '2 years, 1 month' age 2023-06-15 -d 2025-07-15
run_test 'age:10.3' '2 years, 6 months' age 2023-06-15 -d 2025-12-15
run_test 'age:10.4' '2 years, 11 months' age 2023-06-15 -d 2026-05-15
run_test 'age:10.5' '23 months' age 2023-06-15 -d 2025-06-14

# === Age 11: Half-year tier (3–6 years) ===
run_test 'age:11.1' '3 years' age 2022-06-15 -d 2025-06-15
run_test 'age:11.2' '3 years' age 2022-06-15 -d 2025-11-15
run_test 'age:11.3' '3½ years' age 2022-06-15 -d 2025-12-15
run_test 'age:11.4' '3½ years' age 2022-06-15 -d 2026-05-15
run_test 'age:11.5' '4 years' age 2021-06-15 -d 2025-06-15
run_test 'age:11.6' '4½ years' age 2021-06-15 -d 2025-12-15
run_test 'age:11.7' '5 years' age 2020-06-15 -d 2025-06-15
run_test 'age:11.8' '5½ years' age 2020-06-15 -d 2026-02-15
run_test 'age:11.9' '6 years' age 2019-06-15 -d 2025-06-15
run_test 'age:11.10' '6½ years' age 2019-06-15 -d 2025-12-15
run_test 'age:11.11' '6½ years' age 2019-06-15 -d 2026-05-15
run_test 'age:11.12' '2 years, 11 months' age 2022-06-15 -d 2025-06-14

# === Age 12: Integer tier (7+ years) ===
run_test 'age:12.1' '7 years' age 2018-06-15 -d 2025-06-15
run_test 'age:12.2' '7 years' age 2018-03-20 -d 2025-06-15
run_test 'age:12.3' '45 years' age 1980-01-01 -d 2025-06-15

# === Age 13: Cross-year transitions with February ===
run_test 'age:13.1' '3 months' age 2024-12-31 -d 2025-03-31
run_regex 'age:13.2' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2024-12-31 -d 2025-03-30
run_test 'age:13.3' '3 months' age 2024-11-30 -d 2025-02-28
run_regex 'age:13.4' '^[0-9]+ weeks?(, [0-9]+ days?)?$' age 2024-11-30 -d 2025-02-27

# === Age 14: Born-on-31st progression ===
run_test 'age:14.1' '3 months' age 2025-01-31 -d 2025-04-30
run_test 'age:14.2' '4 months' age 2025-01-31 -d 2025-05-31
run_test 'age:14.3' '5 months' age 2025-01-31 -d 2025-06-30
run_test 'age:14.4' '5 months' age 2025-01-31 -d 2025-07-01
run_test 'age:14.5' '6 months' age 2025-01-31 -d 2025-07-31
# Skipped: section 15 — Default asOf (current date)

# === Age 16: formatStage — null / edge cases ===
run_null 'age:16.1' stage null
run_null 'age:16.2' stage undefined
run_null 'age:16.3' stage ''
run_null 'age:16.4' stage 2025-07-01 -d 2025-06-15
run_test 'age:16.5' 'Adult' stage 1525-06-15 -d 2025-06-15
run_null 'age:16.6' stage 1524-06-15 -d 2025-06-15

# === Age 17: formatStage — Newborn (0–1 months, <2 calendar months) ===
run_test 'age:17.1' 'Newborn' stage 2025-06-15 -d 2025-06-15
run_test 'age:17.2' 'Newborn' stage 2025-06-14 -d 2025-06-15
run_test 'age:17.3' 'Newborn' stage 2025-05-25 -d 2025-06-15
run_test 'age:17.4' 'Newborn' stage 2025-05-15 -d 2025-06-15
run_test 'age:17.5' 'Newborn' stage 2025-04-16 -d 2025-06-15
run_test 'age:17.6' 'Infant' stage 2025-04-15 -d 2025-06-15

# === Age 18: formatStage — Infant (2–11 months) ===
run_test 'age:18.1' 'Infant' stage 2025-04-15 -d 2025-06-15
run_test 'age:18.2' 'Infant' stage 2024-12-15 -d 2025-06-15
run_test 'age:18.3' 'Infant' stage 2024-07-15 -d 2025-06-15
run_test 'age:18.4' 'Toddler' stage 2024-06-15 -d 2025-06-15

# === Age 19: formatStage — Toddler (12–35 months) ===
run_test 'age:19.1' 'Toddler' stage 2024-06-15 -d 2025-06-15
run_test 'age:19.2' 'Toddler' stage 2024-01-15 -d 2025-07-15
run_test 'age:19.3' 'Toddler' stage 2023-06-15 -d 2025-06-15
run_test 'age:19.4' 'Toddler' stage 2023-06-15 -d 2026-05-15
run_test 'age:19.5' 'Child' stage 2022-06-15 -d 2025-06-15

# === Age 20: formatStage — Child (36–155 months, 3–12 years) ===
run_test 'age:20.1' 'Child' stage 2022-06-15 -d 2025-06-15
run_test 'age:20.2' 'Child' stage 2021-06-15 -d 2025-06-15
run_test 'age:20.3' 'Child' stage 2019-06-15 -d 2025-06-15
run_test 'age:20.4' 'Child' stage 2016-06-15 -d 2025-06-15
run_test 'age:20.5' 'Child' stage 2013-06-15 -d 2026-05-15
run_test 'age:20.6' 'Teenager' stage 2012-06-15 -d 2025-06-15

# === Age 21: formatStage — Teenager (156–215 months, 13–17 years) ===
run_test 'age:21.1' 'Teenager' stage 2012-06-15 -d 2025-06-15
run_test 'age:21.2' 'Teenager' stage 2010-06-15 -d 2025-06-15
run_test 'age:21.3' 'Teenager' stage 2008-06-15 -d 2026-05-15
run_test 'age:21.4' 'Adult' stage 2007-06-15 -d 2025-06-15

# === Age 22: formatStage — Adult (216+ months, 18+ years) ===
run_test 'age:22.1' 'Adult' stage 2007-06-15 -d 2025-06-15
run_test 'age:22.2' 'Adult' stage 2000-06-15 -d 2025-06-15
run_test 'age:22.3' 'Adult' stage 1980-01-01 -d 2025-06-15
# Skipped: section 23 — formatStage — default asOf

# === Age 24: SayableAge class — English locale delegation ===
run_test 'age:24.1' 'Newborn' age 2025-06-15 -d 2025-06-15
run_test 'age:24.2' '3 days' age 2025-06-12 -d 2025-06-15
run_test 'age:24.3' '1 week, 1 day' age 2025-06-07 -d 2025-06-15
run_test 'age:24.4' '6 months' age 2025-01-15 -d 2025-07-15
run_test 'age:24.5' '2 years, 1 month' age 2023-06-15 -d 2025-07-15
run_test 'age:24.6' '3½ years' age 2022-06-15 -d 2025-12-15
run_test 'age:24.7' '7 years' age 2018-06-15 -d 2025-06-15
run_test 'age:24.8' 'Newborn' stage 2025-06-15 -d 2025-06-15
run_test 'age:24.9' 'Infant' stage 2025-01-15 -d 2025-06-15
run_test 'age:24.10' 'Toddler' stage 2024-06-15 -d 2025-06-15
run_test 'age:24.11' 'Child' stage 2022-06-15 -d 2025-06-15
run_test 'age:24.12' 'Teenager' stage 2012-06-15 -d 2025-06-15
run_test 'age:24.13' 'Adult' stage 2007-06-15 -d 2025-06-15
run_null 'age:24.14' age null -d 2025-06-15
run_null 'age:24.15' stage null -d 2025-06-15

# === Age 25: i18n — locale with all plural features ===
run_test 'age:25.1' 'Recién nacido' age 2025-06-15 -d 2025-06-15 -l es
run_test 'age:25.2' '1 día' age 2025-06-14 -d 2025-06-15 -l es
run_test 'age:25.3' '3 días' age 2025-06-12 -d 2025-06-15 -l es
run_test 'age:25.4' '1 semana' age 2025-06-08 -d 2025-06-15 -l es
run_test 'age:25.5' '1 semana, 1 día' age 2025-06-07 -d 2025-06-15 -l es
run_test 'age:25.6' '2 semanas, 6 días' age 2025-05-26 -d 2025-06-15 -l es
run_test 'age:25.7' '6 meses' age 2025-01-15 -d 2025-07-15 -l es
run_test 'age:25.8' '2 años, 1 mes' age 2023-06-15 -d 2025-07-15 -l es
run_test 'age:25.9' '2 años, 6 meses' age 2023-06-15 -d 2025-12-15 -l es
run_test 'age:25.10' '3 años y medio' age 2022-06-15 -d 2025-12-15 -l es
run_test 'age:25.11' '3 años' age 2022-06-15 -d 2025-06-15 -l es
run_test 'age:25.12' '7 años' age 2018-06-15 -d 2025-06-15 -l es
run_test 'age:25.13' 'Recién nacido' stage 2025-06-15 -d 2025-06-15 -l es
run_test 'age:25.14' 'Bebé' stage 2025-01-15 -d 2025-06-15 -l es
run_test 'age:25.15' 'Niño pequeño' stage 2024-06-15 -d 2025-06-15 -l es
run_test 'age:25.16' 'Niño' stage 2022-06-15 -d 2025-06-15 -l es
run_test 'age:25.17' 'Adolescente' stage 2012-06-15 -d 2025-06-15 -l es
run_test 'age:25.18' 'Adulto' stage 2007-06-15 -d 2025-06-15 -l es
run_null 'age:25.19' age null -d 2025-06-15 -l es
run_null 'age:25.20' stage null -d 2025-06-15 -l es

# === Age 26: Compactness — short ===
run_test 'age:26.1' '3 d' age 2025-06-12 -d 2025-06-15 --short
run_test 'age:26.2' '1 wk' age 2025-06-08 -d 2025-06-15 --short
run_test 'age:26.3' '1 wk, 1 d' age 2025-06-07 -d 2025-06-15 --short
run_test 'age:26.4' '6 mo' age 2025-01-15 -d 2025-07-15 --short
run_test 'age:26.5' '2 yr, 1 mo' age 2023-06-15 -d 2025-07-15 --short
run_test 'age:26.6' '3½ yr' age 2022-06-15 -d 2025-12-15 --short
run_test 'age:26.7' '7 yr' age 2018-06-15 -d 2025-06-15 --short
run_test 'age:26.8' 'Newborn' age 2025-06-15 -d 2025-06-15 --short
run_test 'age:26.9' 'Infant' stage 2025-01-15 -d 2025-06-15 --short

# === Age 27: Compactness — compact ===
run_test 'age:27.1' '3d' age 2025-06-12 -d 2025-06-15 --compact
run_test 'age:27.2' '1w' age 2025-06-08 -d 2025-06-15 --compact
run_test 'age:27.3' '1w1d' age 2025-06-07 -d 2025-06-15 --compact
run_test 'age:27.4' '6m' age 2025-01-15 -d 2025-07-15 --compact
run_test 'age:27.5' '2y1m' age 2023-06-15 -d 2025-07-15 --compact
run_test 'age:27.6' '3½y' age 2022-06-15 -d 2025-12-15 --compact
run_test 'age:27.7' '7y' age 2018-06-15 -d 2025-06-15 --compact
run_test 'age:27.8' 'Newborn' age 2025-06-15 -d 2025-06-15 --compact

# === Age 29: Locale-specific edge cases — plural rules ===
run_test 'age:29.1' 'רק נולד' age 2025-06-15 -d 2025-06-15 -l he
run_test 'age:29.2' 'יום' age 2025-06-14 -d 2025-06-15 -l he
run_test 'age:29.3' '3 ימים' age 2025-06-12 -d 2025-06-15 -l he
run_test 'age:29.4' 'שבועיים' age 2025-06-01 -d 2025-06-15 -l he
run_test 'age:29.5' '3 שבועות' age 2025-05-25 -d 2025-06-15 -l he
run_test 'age:29.6' '6 חודשים' age 2025-01-15 -d 2025-07-15 -l he
run_test 'age:29.7' '3 חודשים' age 2025-03-15 -d 2025-06-15 -l he
run_test 'age:29.8' 'שנתיים, חודש' age 2023-06-15 -d 2025-07-15 -l he
run_test 'age:29.9' '3 שנים וחצי' age 2022-06-15 -d 2025-12-15 -l he
run_test 'age:29.10' '7 שנים' age 2018-06-15 -d 2025-06-15 -l he
run_test 'age:29.11' 'רק נולד' stage 2025-06-15 -d 2025-06-15 -l he -g m
run_test 'age:29.12' 'רק נולדה' stage 2025-06-15 -d 2025-06-15 -l he -g f
run_test 'age:29.13' 'מבוגר' stage 2007-06-15 -d 2025-06-15 -l he -g m
run_test 'age:29.14' 'מבוגרת' stage 2007-06-15 -d 2025-06-15 -l he -g f
run_test 'age:29.15' 'Новороденче' age 2025-06-15 -d 2025-06-15 -l mk
run_test 'age:29.16' '1 ден' age 2025-06-14 -d 2025-06-15 -l mk
run_test 'age:29.17' '3 дена' age 2025-06-12 -d 2025-06-15 -l mk
run_test 'age:29.18' '6 месеци' age 2025-01-15 -d 2025-07-15 -l mk
run_test 'age:29.19' '2 години, 1 месец' age 2023-06-15 -d 2025-07-15 -l mk
run_test 'age:29.20' '3 години и пол' age 2022-06-15 -d 2025-12-15 -l mk
run_test 'age:29.21' '7 години' age 2018-06-15 -d 2025-06-15 -l mk
run_test 'age:29.22' 'Mzaliwa mpya' age 2025-06-15 -d 2025-06-15 -l sw
run_test 'age:29.23' 'siku 1' age 2025-06-14 -d 2025-06-15 -l sw
run_test 'age:29.24' 'siku 3' age 2025-06-12 -d 2025-06-15 -l sw
run_test 'age:29.25' 'miezi 6' age 2025-01-15 -d 2025-07-15 -l sw
run_test 'age:29.26' 'miaka 2, mwezi 1' age 2023-06-15 -d 2025-07-15 -l sw
run_test 'age:29.27' 'miaka 3 na nusu' age 2022-06-15 -d 2025-12-15 -l sw
run_test 'age:29.28' 'Baru lahir' age 2025-06-15 -d 2025-06-15 -l id
run_test 'age:29.29' '1 hari' age 2025-06-14 -d 2025-06-15 -l id
run_test 'age:29.30' '3 hari' age 2025-06-12 -d 2025-06-15 -l id
run_test 'age:29.31' '6 bulan' age 2025-01-15 -d 2025-07-15 -l id
run_test 'age:29.32' '3 setengah tahun' age 2022-06-15 -d 2025-12-15 -l id
run_test 'age:29.33' '7 tahun' age 2018-06-15 -d 2025-06-15 -l id
run_test 'age:29.34' 'አዲስ የተወለደ' age 2025-06-15 -d 2025-06-15 -l am
run_test 'age:29.35' '1 ቀን' age 2025-06-14 -d 2025-06-15 -l am
run_test 'age:29.36' '3 ቀናት' age 2025-06-12 -d 2025-06-15 -l am
run_test 'age:29.37' '1 ሳምንት፣ 1 ቀን' age 2025-06-07 -d 2025-06-15 -l am
run_test 'age:29.38' '6 ወራት' age 2025-01-15 -d 2025-07-15 -l am
run_test 'age:29.39' '3 ዓመታት ተኩል' age 2022-06-15 -d 2025-12-15 -l am
# Skipped: section 30 — Locale lookup by code string

# === Age 31: Weeks and days across month ends ===
run_test 'age:31.1' '12 weeks, 4 days' age 2016-12-31 -d 2017-03-29
run_test 'age:31.2' '12 weeks, 6 days' age 1991-11-27 -d 1992-02-25
run_test 'age:31.3' '4 weeks, 5 days' age 2020-11-30 -d 2021-01-02
run_test 'age:31.4' '12w4d' age 2016-12-31 -d 2017-03-29 --compact

# === Age 32: Half years take their plural form from whole years ===
run_test 'age:32.1' '3 i pół lata' age 2021-06-15 -d 2025-01-15 -l pl
run_test 'age:32.2' '5 i pół lat' age 2020-06-15 -d 2025-12-15 -l pl --short
run_test 'age:32.3' '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ' age 2005-06-08 -d 2012-06-07 -l shi

# === Age 33: Input validation ===
run_null 'age:33.1' age 2025-02-30 -d 2032-06-25
run_null 'age:33.2' age 2025-13-01 -d 2027-01-31
run_null 'age:33.3' age 2023-02-29 -d 2025-03-01
run_null 'age:33.4' age 2025-06-00 -d 2027-02-25
run_null 'age:33.5' age 2025-6-1 -d 2027-02-25
run_null 'age:33.6' age ' 2025-06-01' -d 2027-02-25
run_null 'age:33.7' age 2025-06-15T10:00:00 -d 2027-02-25
run_null 'age:33.8' age 2020-01-01 -d 2025-04-31
run_null 'age:33.9' stage 2025-02-30 -d 2027-09-05
run_test 'age:33.10' '2 years' age 2024-02-29 -d 2026-03-01

# ══════════════════════════════════════════════════════════════
# DATE COMPONENT
# ══════════════════════════════════════════════════════════════

# === Date: Null / edge cases ===
run_null 'date:1.1' date null
run_null 'date:1.2' date ''
run_null 'date:1.3' date invalid
run_null 'date:1.4' relative 2025-03-15 -d null
run_null 'date:1.5' relative null -d 2025-03-15

# === Date: format_date — normal compactness (English) ===
run_test 'date:2.1' 'March 15th' date 2025-03-15 -l en
run_test 'date:2.2' 'January 1st' date 2025-01-01 -l en
run_test 'date:2.3' 'May 22nd' date 2025-05-22 -l en
run_test 'date:2.4' 'July 3rd' date 2025-07-03 -l en
run_test 'date:2.5' 'December 31st' date 2025-12-31 -l en
run_test 'date:2.6' 'June 11th' date 2025-06-11 -l en
run_test 'date:2.7' 'March 15th' date 2025-03-15T14:30:00 -l en

# === Date: format_date — short compactness (English) ===
run_test 'date:3.1' 'Mar 15' date 2025-03-15 -l en --short
run_test 'date:3.2' 'Jan 1' date 2025-01-01 -l en --short
run_test 'date:3.3' 'Dec 25' date 2025-12-25 -l en --short

# === Date: format_date — compact (English) ===
run_test 'date:4.1' '3/15' date 2025-03-15 -l en --compact
run_test 'date:4.2' '1/1' date 2025-01-01 -l en --compact

# === Date: format_relative — proximity tiers (English) ===
run_test 'date:5.1' 'today' relative 2025-03-15 -d 2025-03-15 -l en
run_test 'date:5.2' 'tomorrow' relative 2025-03-16 -d 2025-03-15 -l en
run_test 'date:5.3' 'yesterday' relative 2025-03-14 -d 2025-03-15 -l en
run_test 'date:5.4' 'the day after tomorrow' relative 2025-03-17 -d 2025-03-15 -l en
run_test 'date:5.5' 'the day before yesterday' relative 2025-03-13 -d 2025-03-15 -l en
run_test 'date:5.6' 'this Wednesday' relative 2025-03-19 -d 2025-03-15 -l en
run_test 'date:5.7' 'this Thursday' relative 2025-03-20 -d 2025-03-15 -l en
run_test 'date:5.8' 'last Tuesday' relative 2025-03-11 -d 2025-03-15 -l en
run_test 'date:5.9' 'next Saturday' relative 2025-03-22 -d 2025-03-15 -l en
run_test 'date:5.10' 'next Thursday' relative 2025-03-27 -d 2025-03-15 -l en
run_test 'date:5.11' 'March 1st' relative 2025-03-01 -d 2025-03-15 -l en
run_test 'date:5.12' 'April 10th' relative 2025-04-10 -d 2025-03-15 -l en
run_test 'date:5.13' 'January 5th, 2026' relative 2026-01-05 -d 2025-03-15 -l en
run_test 'date:5.14' 'December 25th, 2024' relative 2024-12-25 -d 2025-03-15 -l en

# === Date: format_relative — compact skips weekday tiers ===
run_test 'date:6.1' 'today' relative 2025-03-15 -d 2025-03-15 -l en --compact
run_test 'date:6.2' 'tomorrow' relative 2025-03-16 -d 2025-03-15 -l en --compact
run_test 'date:6.3' '3/19' relative 2025-03-19 -d 2025-03-15 -l en --compact
run_test 'date:6.4' '1/5/26' relative 2026-01-05 -d 2025-03-15 -l en --compact

# === Date: Locale — German ===
run_test 'date:7.1' '15. März' date 2025-03-15 -l de
run_test 'date:7.2' 'morgen' relative 2025-03-16 -d 2025-03-15 -l de
run_test 'date:7.3' 'übermorgen' relative 2025-03-17 -d 2025-03-15 -l de
run_test 'date:7.4' 'diesen Mittwoch' relative 2025-03-19 -d 2025-03-15 -l de

# === Date: Locale — French ===
run_test 'date:8.1' '1er mars' date 2025-03-01 -l fr
run_test 'date:8.2' '15 mars' date 2025-03-15 -l fr
run_test 'date:8.3' 'demain' relative 2025-03-16 -d 2025-03-15 -l fr

# === Date: Locale — Japanese ===
run_test 'date:9.1' '3月15日' date 2025-03-15 -l ja
run_test 'date:9.2' '明日' relative 2025-03-16 -d 2025-03-15 -l ja
run_test 'date:9.3' '今度の水曜日' relative 2025-03-19 -d 2025-03-15 -l ja

# === Date: Locale — Russian (genitive months) ===
run_test 'date:10.1' '15 марта' date 2025-03-15 -l ru
run_test 'date:10.2' 'завтра' relative 2025-03-16 -d 2025-03-15 -l ru

# === Date: Locale — Arabic ===
run_test 'date:11.1' '15 مارس' date 2025-03-15 -l ar
run_test 'date:11.2' 'غداً' relative 2025-03-16 -d 2025-03-15 -l ar

# === Date: Locale — Spanish ===
run_test 'date:12.1' '15 de marzo' date 2025-03-15 -l es
run_test 'date:12.2' 'pasado mañana' relative 2025-03-17 -d 2025-03-15 -l es

# === Date: format_date_with_year ===
run_test 'date:13.1' 'February 4th, 2018' date 2018-02-04 -l en --with-year
run_test 'date:13.2' 'Mar 15, 2025' date 2025-03-15 -l en --short --with-year
run_test 'date:13.3' '1/21/97' date 1997-01-21 -l en --compact --with-year
run_test 'date:13.4' '20/5/07' date 2007-05-20 -l tg --compact --with-year
run_test 'date:13.5' '21. kesäkuuta 1996' date 1996-06-21 -l 'fi' --short --with-year

# === Date: Short month names (locales that keep the full genitive) ===
run_test 'date:14.1' '15. februára' date 2031-02-15 -l sk --short
run_test 'date:14.2' '10. prosince' date 2025-12-10 -l cs --short
run_test 'date:14.3' '5 листопада' date 2025-11-05 -l uk --short
run_test 'date:14.4' '8. elokuuta' relative 1998-08-08 -d 1998-08-15 -l 'fi' --short

# === Date: format_relative — short phrases ===
run_test 'date:15.1' 'an Mth ma' relative 2035-12-04 -d 2035-12-02 -l kw --short
run_test 'date:15.2' 'Dom nchi'\''j' relative 2000-01-23 -d 2000-01-25 -l mam --short
run_test 'date:15.3' 'a'\''in Vie' relative 2014-10-24 -d 2014-10-22 -l kek --short

# === Date: Input validation ===
run_null 'date:16.1' date 2025-02-30 -l en
run_null 'date:16.2' date 2025-13-01 -l en
run_null 'date:16.3' date 2025-6-1 -l en
run_null 'date:16.4' date ' 2025-06-01' -l en
run_test 'date:16.5' 'June 1st' date 2025-06-01T10:00:00 -l en
run_null 'date:16.6' date 2023-02-29 -l en --with-year
run_null 'date:16.7' relative 2025-03-16 -d 2025-04-31 -l en

# ══════════════════════════════════════════════════════════════
# TIME COMPONENT
# ══════════════════════════════════════════════════════════════

# === Time 1: Null / edge cases ===
run_null 'time:1.1' time null
run_null 'time:1.2' time ''
run_null 'time:1.3' time invalid
run_null 'time:1.4' time 25:00

# === Time 2: Clock time (normal compactness) ===
run_test 'time:2.1' 'midnight' time 00:00
run_test 'time:2.2' 'noon' time 12:00
run_test 'time:2.3' 'three o'\''clock' time 15:00
run_test 'time:2.4' 'a quarter past two' time 14:15
run_test 'time:2.5' 'half past nine' time 09:30
run_test 'time:2.6' 'a quarter to eleven' time 10:45
run_test 'time:2.7' 'five past eight' time 08:05
run_test 'time:2.8' 'five to five' time 16:55
run_test 'time:2.9' 'midnight' time 23:58
run_test 'time:2.10' 'twenty past seven' time 07:22
run_test 'time:2.11' 'a quarter past two' time 2025-01-15T14:15:00

# === Time 3: Clock time (short compactness) ===
run_test 'time:3.1' '2:15 PM' time 14:15 --short
run_test 'time:3.2' '9:30 AM' time 09:30 --short
run_test 'time:3.3' '12:00 AM' time 00:00 --short
run_test 'time:3.4' '12:00 PM' time 12:00 --short

# === Time 4: Clock time (compact) ===
run_test 'time:4.1' '2:15p' time 14:15 --compact
run_test 'time:4.2' '9:30a' time 09:30 --compact

# === Time 5: Locale — German ===
run_test 'time:5.1' 'halb vier' time 15:30 -l de

# === Time 6: Locale — French ===
run_test 'time:6.1' 'trois heures et quart' time 15:15 -l fr
run_test 'time:6.2' 'une heure' time 13:00 -l fr
run_test 'time:6.3' 'une heure et demie' time 13:30 -l fr
run_test 'time:6.4' 'trois heures moins le quart' time 14:45 -l fr
run_test 'time:6.5' 'trois heures moins dix' time 14:50 -l fr

# === Time 7: Locale — Japanese ===
run_test 'time:7.1' '三時半' time 15:30 -l ja

# === Time 8: Locale — Finnish (dot separator, short) ===
run_test 'time:8.1' '14.15' time 14:15 -l 'fi' --short
run_test 'time:8.2' '0.00' time 00:00 -l 'fi' --short

# === Time 9: Minutes in short and compact modes ===
run_test 'time:9.1' '6:01 PM' time 18:01 --short
run_test 'time:9.2' '7:05p' time 19:05 --compact

# === Time 10: Input validation ===
run_test 'time:10.1' 'half past nine' time 9:30
run_test 'time:10.2' 'half past nine' time 09:30
run_null 'time:10.3' time ' 9:30'
run_null 'time:10.4' time '9:30 '
run_null 'time:10.5' time 9:5
run_null 'time:10.6' time 24:00
run_test 'time:10.7' 'a quarter past two' time 14:15:30
run_test 'time:10.8' 'a quarter past two' time 2025-01-15T14:15:00Z
run_null 'time:10.9' time 2025-02-30T14:15:00

# ══════════════════════════════════════════════════════════════
# DURATION COMPONENT
# ══════════════════════════════════════════════════════════════

# === Duration 1: Null / edge cases ===
run_null 'dur:1.1' duration null
run_null 'dur:1.2' duration -- -1
run_null 'dur:1.3' since null -d 2025-01-15T10:00:00
run_null 'dur:1.4' 'until' null -d 2025-01-15T10:00:00
run_null 'dur:1.5' since 2025-01-15T10:00:00 -d 2025-01-15T09:00:00
run_null 'dur:1.6' 'until' 2025-01-15T09:00:00 -d 2025-01-15T10:00:00

# === Duration 2: Duration — seconds tier (0-59s) ===
run_test 'dur:2.1' 'just now' duration 0
run_test 'dur:2.2' '1 second' duration 1
run_test 'dur:2.3' '45 seconds' duration 45
run_test 'dur:2.4' '59 seconds' duration 59

# === Duration 3: Duration — minutes + seconds tier (1-4 min) ===
run_test 'dur:3.1' '1 minute' duration 60
run_test 'dur:3.2' '1 minute, 30 seconds' duration 90
run_test 'dur:3.3' '4 minutes' duration 240
run_test 'dur:3.4' '4 minutes, 30 seconds' duration 270

# === Duration 4: Duration — minutes tier (5-59 min) ===
run_test 'dur:4.1' '5 minutes' duration 300
run_test 'dur:4.2' '25 minutes' duration 1500
run_test 'dur:4.3' '59 minutes' duration 3540

# === Duration 5: Duration — hours + minutes tier (1-5 hr) ===
run_test 'dur:5.1' '1 hour' duration 3600
run_test 'dur:5.2' '1½ hours' duration 5400
run_test 'dur:5.3' '2 hours, 15 minutes' duration 8100
run_test 'dur:5.4' '5 hours' duration 18000

# === Duration 6: Duration — hours tier (6-23 hr) ===
run_test 'dur:6.1' '8 hours' duration 28800
run_test 'dur:6.2' '23 hours' duration 82800

# === Duration 7: Duration — days tier ===
run_test 'dur:7.1' '1 day' duration 86400
run_test 'dur:7.2' '1 day, 3 hours' duration 97200
run_test 'dur:7.3' '1½ days' duration 129600
run_test 'dur:7.4' '5 days' duration 432000
run_test 'dur:7.5' '2 days' duration 172800

# === Duration 8: Duration — weeks tier ===
run_test 'dur:8.1' '1 week' duration 604800
run_test 'dur:8.2' '2 weeks, 1 day' duration 1296000
run_test 'dur:8.3' '4 weeks' duration 2419200

# === Duration 9: Duration — months and years tier ===
run_test 'dur:9.1' '1 month' duration 2678400
run_test 'dur:9.2' '3 months' duration 7884000
run_test 'dur:9.3' '1 year' duration 31536000
run_test 'dur:9.4' '1 year, 3 months' duration 39420000

# === Duration 10: Duration from ISO timestamps ===
run_test 'dur:10.1' '1½ hours' duration 2025-01-15T10:00:00 2025-01-15T11:30:00
run_test 'dur:10.2' '45 minutes' duration 2025-01-15T10:00:00 2025-01-15T10:45:00

# === Duration 11: Relative time — since ===
run_test 'dur:11.1' 'just now' since 2025-01-15T10:00:00 -d 2025-01-15T10:00:00
run_test 'dur:11.2' '30 seconds ago' since 2025-01-15T10:00:00 -d 2025-01-15T10:00:30
run_test 'dur:11.3' '45 minutes ago' since 2025-01-15T10:00:00 -d 2025-01-15T10:45:00
run_test 'dur:11.4' '3 hours ago' since 2025-01-15T10:00:00 -d 2025-01-15T13:00:00

# === Duration 12: Relative time — until ===
run_test 'dur:12.1' 'just now' 'until' 2025-01-15T10:00:00 -d 2025-01-15T10:00:00
run_test 'dur:12.2' 'in 20 minutes' 'until' 2025-01-15T10:20:00 -d 2025-01-15T10:00:00
run_test 'dur:12.3' 'in 3 hours' 'until' 2025-01-15T13:00:00 -d 2025-01-15T10:00:00

# === Duration 13: Locale — German ===
run_test 'dur:13.1' '1 Stunde' duration 3600 -l de
run_test 'dur:13.2' 'vor 5 Minuten' since 2025-01-15T10:00:00 -d 2025-01-15T10:05:00 -l de

# === Duration 14: Locale — French ===
run_test 'dur:14.1' '2 heures' duration 7200 -l fr

# === Duration 15: Locale — Japanese ===
run_test 'dur:15.1' '2分' duration 120 -l ja
run_test 'dur:15.2' '1時間前' since 2025-01-15T10:00:00 -d 2025-01-15T11:00:00 -l ja

# === Duration 16: Short compactness — duration ===
run_test 'dur:16.1' '1h' duration 3600 --short
run_test 'dur:16.2' '1m, 30s' duration 90 --short

# === Duration 17: Compact compactness — duration ===
run_test 'dur:17.1' '1h' duration 3600 --compact
run_test 'dur:17.2' '1m30s' duration 90 --compact

# === Duration 18: Short compactness — relative time ===
run_test 'dur:18.1' 'lɔhɔnga 2, awa 14 taa gbɔyɔ' since 2025-01-20T01:32:11 -d 2025-01-22T15:39:16 -l men --short

# === Duration 19: Range (500-year ceiling) ===
run_test 'dur:19.1' '500 years' duration 15778800000
run_null 'dur:19.2' duration 15800000000
run_null 'dur:19.3' duration 99999999999
run_null 'dur:19.4' since 1500-01-01T00:00:00 -d 2025-01-01T00:00:00
run_null 'dur:19.5' 'until' 2600-01-01T00:00:00 -d 2025-01-01T00:00:00

# === Duration 20: Timestamp validation ===
run_test 'dur:20.1' '1½ hours' duration 2025-01-15T10:00 2025-01-15T11:30:00
run_null 'dur:20.2' duration 2025-01-15T10 2025-01-15T11:30:00
run_null 'dur:20.3' duration 2025-1-5T10:00:00 2025-01-15T11:30:00
run_null 'dur:20.4' duration 2025-02-30T10:00:00 2025-03-15T11:30:00
run_null 'dur:20.5' since 2025-01-15T10:00:00 -d 2025-01-15T25:00:00

# ══════════════════════════════════════════════════════════════
# RUN AND CHECK
# ══════════════════════════════════════════════════════════════
_responses=()
while IFS= read -r _line; do
    _responses+=("${_line}")
done < <(printf '%s' "${_requests}" | "${CLI}" --repl 2>/dev/null || true)

if [[ ${#_responses[@]} -ne ${#_ids[@]} ]]; then
    printf "${_red}FAIL${_reset} REPL answered %d of %d requests\n" "${#_responses[@]}" "${#_ids[@]}"
    exit 1
fi

# Every CLI implements all four libraries (cli/SPEC.md), so nothing is
# skipped: a missing library shows up as failing tests.
echo "Testing: ${CLI}"

for _i in "${!_ids[@]}"; do
    _id="${_ids[_i]}"
    _kind="${_kinds[_i]}"
    _expected="${_expects[_i]}"
    _total=$((_total + 1))
    _response="${_responses[_i]}"
    _rc="${_response%%${_tab}*}"
    _output="${_response#*${_tab}}"
    case "${_kind}" in
        test) [[ "${_rc}" == 0 && "${_output}" == "${_expected}" ]] ;;
        null) [[ "${_rc}" == 1 && -z "${_output}" ]] ;;
        regex) [[ "${_rc}" == 0 && "${_output}" =~ ${_expected} ]] ;;
    esac && _ok=true || _ok=false
    if ${_ok}; then
        _pass=$((_pass + 1))
    else
        _fail=$((_fail + 1))
        case "${_kind}" in
            test) printf "${_red}FAIL${_reset} %s: expected %q, got %q (exit %s)\n" "${_id}" "${_expected}" "${_output}" "${_rc}" ;;
            null) printf "${_red}FAIL${_reset} %s: expected null (exit 1), got exit %s, output: %q\n" "${_id}" "${_rc}" "${_output}" ;;
            regex) printf "${_red}FAIL${_reset} %s: expected match %q, got %q (exit %s)\n" "${_id}" "${_expected}" "${_output}" "${_rc}" ;;
        esac
    fi
done

# ══════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════
echo
if [[ ${_fail} -eq 0 ]]; then
    printf "${_green}All %d tests passed.${_reset}\n" "${_total}"
else
    printf "${_red}%d failed${_reset}, ${_green}%d passed${_reset} out of %d tests.\n" "${_fail}" "${_pass}" "${_total}"
fi

[[ ${_fail} -eq 0 ]]
