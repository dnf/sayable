#!/usr/bin/env tclsh
# Tests for sayableage — mirrors canonical tests from age/config/tests.json

set script_dir [file dirname [info script]]
source [file join $script_dir sayableage.tcl]

# Simple test framework
variable _pass 0
variable _fail 0
variable _errors {}

proc assert_eq {actual expected id {desc ""}} {
    variable _pass
    variable _fail
    variable _errors
    if {$actual eq $expected} {
        incr _pass
    } else {
        incr _fail
        lappend _errors "$id: expected '$expected', got '$actual' $desc"
    }
}

proc assert_contains {actual substring id {desc ""}} {
    variable _pass
    variable _fail
    variable _errors
    if {[string first $substring $actual] >= 0} {
        incr _pass
    } else {
        incr _fail
        lappend _errors "$id: expected '$actual' to contain '$substring' $desc"
    }
}

# Create default English formatter
set en_locale [::sayableage::get_locale "en"]
set en [::sayableage::new $en_locale]

# ================================================================
# Section 1: Null / edge cases
# ================================================================
puts "Section 1: Null / edge cases"

# 1.1 — null input (empty string in Tcl)
assert_eq [::sayableage::format_age $en "" "2025-06-15"] "" "1.1"

# 1.3 — empty string
assert_eq [::sayableage::format_age $en "" "2025-06-15"] "" "1.3"

# 1.4 — future DOB
assert_eq [::sayableage::format_age $en "2025-07-01" "2025-06-15"] "" "1.4"

# 1.5 — exactly 500 years
assert_eq [::sayableage::format_age $en "1525-06-15" "2025-06-15"] "500 years" "1.5"

# 1.6 — 501 years
assert_eq [::sayableage::format_age $en "1524-06-15" "2025-06-15"] "" "1.6"

# 1.7 — 1000 years
assert_eq [::sayableage::format_age $en "1025-06-15" "2025-06-15"] "" "1.7"

# ================================================================
# Section 2: Days tier (0-6 days)
# ================================================================
puts "Section 2: Days tier"

# 2.1
assert_eq [::sayableage::format_age $en "2025-06-15" "2025-06-15"] "Newborn" "2.1"

# 2.2
assert_eq [::sayableage::format_age $en "2025-06-14" "2025-06-15"] "1 day" "2.2"

# 2.3
assert_eq [::sayableage::format_age $en "2025-06-12" "2025-06-15"] "3 days" "2.3"

# 2.4
assert_eq [::sayableage::format_age $en "2025-06-09" "2025-06-15"] "6 days" "2.4"

# 2.5
assert_eq [::sayableage::format_age $en "2025-06-08" "2025-06-15"] "1 week" "2.5"

# ================================================================
# Section 3: Weeks+days tier
# ================================================================
puts "Section 3: Weeks+days tier"

# 3.1
assert_eq [::sayableage::format_age $en "2025-06-08" "2025-06-15"] "1 week" "3.1"

# 3.2
assert_eq [::sayableage::format_age $en "2025-06-07" "2025-06-15"] "1 week, 1 day" "3.2"

# 3.3
assert_eq [::sayableage::format_age $en "2025-06-06" "2025-06-15"] "1 week, 2 days" "3.3"

# 3.4
assert_eq [::sayableage::format_age $en "2025-06-02" "2025-06-15"] "1 week, 6 days" "3.4"

# 3.5
assert_eq [::sayableage::format_age $en "2025-06-01" "2025-06-15"] "2 weeks" "3.5"

# 3.6
assert_eq [::sayableage::format_age $en "2025-05-31" "2025-06-15"] "2 weeks, 1 day" "3.6"

# 3.7
assert_eq [::sayableage::format_age $en "2025-05-26" "2025-06-15"] "2 weeks, 6 days" "3.7"

# 3.8
assert_eq [::sayableage::format_age $en "2025-05-25" "2025-06-15"] "3 weeks" "3.8"

# 3.9
assert_eq [::sayableage::format_age $en "2025-05-15" "2025-06-15"] "4 weeks, 3 days" "3.9"

# 3.10
assert_eq [::sayableage::format_age $en "2025-04-15" "2025-06-15"] "8 weeks, 5 days" "3.10"

# 3.11
assert_eq [::sayableage::format_age $en "2025-03-15" "2025-06-14"] "13 weeks" "3.11"

# 3.12
assert_eq [::sayableage::format_age $en "2025-03-15" "2025-06-15"] "3 months" "3.12"

# ================================================================
# Section 4: Month boundaries — standard months
# ================================================================
puts "Section 4: Month boundaries — standard"

# 4.1
assert_eq [::sayableage::format_age $en "2025-01-01" "2025-04-01"] "3 months" "4.1"

# 4.2
set result_4_2 [::sayableage::format_age $en "2025-01-01" "2025-03-31"]
assert_contains $result_4_2 "weeks" "4.2"

# 4.3
assert_eq [::sayableage::format_age $en "2025-06-15" "2025-09-15"] "3 months" "4.3"

# 4.4
set result_4_4 [::sayableage::format_age $en "2025-06-15" "2025-09-14"]
assert_contains $result_4_4 "weeks" "4.4"

# 4.5
assert_eq [::sayableage::format_age $en "2025-06-15" "2025-12-15"] "6 months" "4.5"

# ================================================================
# Section 5: Month boundaries — February non-leap year
# ================================================================
puts "Section 5: Month boundaries — Feb non-leap"

# 5.1
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-02-28"] "4 weeks" "5.1"

# 5.2
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-04-30"] "3 months" "5.2"

# 5.3
set result_5_3 [::sayableage::format_age $en "2025-01-31" "2025-04-29"]
assert_contains $result_5_3 "weeks" "5.3"

# 5.4
assert_eq [::sayableage::format_age $en "2025-02-01" "2025-05-01"] "3 months" "5.4"

# 5.5
set result_5_5 [::sayableage::format_age $en "2025-02-01" "2025-04-30"]
assert_contains $result_5_5 "weeks" "5.5"

# ================================================================
# Section 6: Month boundaries — February leap year
# ================================================================
puts "Section 6: Month boundaries — Feb leap year"

# 6.1
assert_eq [::sayableage::format_age $en "2024-01-31" "2024-02-29"] "4 weeks, 1 day" "6.1"

# 6.2
assert_eq [::sayableage::format_age $en "2024-01-31" "2024-02-28"] "4 weeks" "6.2"

# 6.3
assert_eq [::sayableage::format_age $en "2024-01-31" "2024-04-30"] "3 months" "6.3"

# 6.4
set result_6_4 [::sayableage::format_age $en "2024-01-30" "2024-02-29"]
assert_contains $result_6_4 "weeks" "6.4"

# 6.5
set result_6_5 [::sayableage::format_age $en "2024-01-30" "2024-02-28"]
assert_contains $result_6_5 "weeks" "6.5"

# ================================================================
# Section 7: Month boundaries — 30-day months
# ================================================================
puts "Section 7: Month boundaries — 30-day months"

# 7.1
assert_eq [::sayableage::format_age $en "2025-03-31" "2025-06-30"] "3 months" "7.1"

# 7.2
set result_7_2 [::sayableage::format_age $en "2025-03-31" "2025-06-29"]
assert_contains $result_7_2 "weeks" "7.2"

# 7.3
assert_eq [::sayableage::format_age $en "2025-08-31" "2025-11-30"] "3 months" "7.3"

# 7.4
set result_7_4 [::sayableage::format_age $en "2025-08-31" "2025-11-29"]
assert_contains $result_7_4 "weeks" "7.4"

# ================================================================
# Section 8: Month boundaries — leap year baby
# ================================================================
puts "Section 8: Leap year baby"

# 8.1
assert_eq [::sayableage::format_age $en "2024-02-29" "2024-05-29"] "3 months" "8.1"

# 8.2
set result_8_2 [::sayableage::format_age $en "2024-02-29" "2024-05-28"]
assert_contains $result_8_2 "weeks" "8.2"

# 8.3
assert_eq [::sayableage::format_age $en "2024-02-29" "2025-02-28"] "12 months" "8.3"

# 8.4
assert_eq [::sayableage::format_age $en "2024-02-29" "2025-03-01"] "12 months" "8.4"

# ================================================================
# Section 9: Months tier (3-23 months)
# ================================================================
puts "Section 9: Months tier"

# 9.1
assert_eq [::sayableage::format_age $en "2025-01-15" "2025-04-15"] "3 months" "9.1"

# 9.2
assert_eq [::sayableage::format_age $en "2025-01-15" "2025-07-15"] "6 months" "9.2"

# 9.3
assert_eq [::sayableage::format_age $en "2024-06-15" "2025-06-15"] "12 months" "9.3"

# 9.4
assert_eq [::sayableage::format_age $en "2024-01-15" "2025-12-15"] "23 months" "9.4"

# 9.5
assert_eq [::sayableage::format_age $en "2025-01-15" "2025-07-14"] "5 months" "9.5"

# 9.6
assert_eq [::sayableage::format_age $en "2024-11-10" "2025-04-10"] "5 months" "9.6"

# ================================================================
# Section 10: Years+months tier (24-35 months)
# ================================================================
puts "Section 10: Years+months tier"

# 10.1
assert_eq [::sayableage::format_age $en "2023-06-15" "2025-06-15"] "2 years" "10.1"

# 10.2
assert_eq [::sayableage::format_age $en "2023-06-15" "2025-07-15"] "2 years, 1 month" "10.2"

# 10.3
assert_eq [::sayableage::format_age $en "2023-06-15" "2025-12-15"] "2 years, 6 months" "10.3"

# 10.4
assert_eq [::sayableage::format_age $en "2023-06-15" "2026-05-15"] "2 years, 11 months" "10.4"

# 10.5
assert_eq [::sayableage::format_age $en "2023-06-15" "2025-06-14"] "23 months" "10.5"

# ================================================================
# Section 11: Half-year tier (3-6 years)
# ================================================================
puts "Section 11: Half-year tier"

# 11.1
assert_eq [::sayableage::format_age $en "2022-06-15" "2025-06-15"] "3 years" "11.1"

# 11.2
assert_eq [::sayableage::format_age $en "2022-06-15" "2025-11-15"] "3 years" "11.2"

# 11.3
assert_eq [::sayableage::format_age $en "2022-06-15" "2025-12-15"] "3½ years" "11.3"

# 11.4
assert_eq [::sayableage::format_age $en "2022-06-15" "2026-05-15"] "3½ years" "11.4"

# 11.5
assert_eq [::sayableage::format_age $en "2021-06-15" "2025-06-15"] "4 years" "11.5"

# 11.6
assert_eq [::sayableage::format_age $en "2021-06-15" "2025-12-15"] "4½ years" "11.6"

# 11.7
assert_eq [::sayableage::format_age $en "2020-06-15" "2025-06-15"] "5 years" "11.7"

# 11.8
assert_eq [::sayableage::format_age $en "2020-06-15" "2026-02-15"] "5½ years" "11.8"

# 11.9
assert_eq [::sayableage::format_age $en "2019-06-15" "2025-06-15"] "6 years" "11.9"

# 11.10
assert_eq [::sayableage::format_age $en "2019-06-15" "2025-12-15"] "6½ years" "11.10"

# 11.11
assert_eq [::sayableage::format_age $en "2019-06-15" "2026-05-15"] "6½ years" "11.11"

# 11.12
assert_eq [::sayableage::format_age $en "2022-06-15" "2025-06-14"] "2 years, 11 months" "11.12"

# ================================================================
# Section 12: Integer tier (7+ years)
# ================================================================
puts "Section 12: Integer tier"

# 12.1
assert_eq [::sayableage::format_age $en "2018-06-15" "2025-06-15"] "7 years" "12.1"

# 12.2
assert_eq [::sayableage::format_age $en "2018-03-20" "2025-06-15"] "7 years" "12.2"

# 12.3
assert_eq [::sayableage::format_age $en "1980-01-01" "2025-06-15"] "45 years" "12.3"

# ================================================================
# Section 13: Cross-year transitions with February
# ================================================================
puts "Section 13: Cross-year transitions"

# 13.1
assert_eq [::sayableage::format_age $en "2024-12-31" "2025-03-31"] "3 months" "13.1"

# 13.2
set result_13_2 [::sayableage::format_age $en "2024-12-31" "2025-03-30"]
assert_contains $result_13_2 "weeks" "13.2"

# 13.3
assert_eq [::sayableage::format_age $en "2024-11-30" "2025-02-28"] "3 months" "13.3"

# 13.4
set result_13_4 [::sayableage::format_age $en "2024-11-30" "2025-02-27"]
assert_contains $result_13_4 "weeks" "13.4"

# ================================================================
# Section 14: Born-on-31st progression
# ================================================================
puts "Section 14: Born-on-31st progression"

# 14.1
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-04-30"] "3 months" "14.1"

# 14.2
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-05-31"] "4 months" "14.2"

# 14.3
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-06-30"] "5 months" "14.3"

# 14.4
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-07-01"] "5 months" "14.4"

# 14.5
assert_eq [::sayableage::format_age $en "2025-01-31" "2025-07-31"] "6 months" "14.5"

# ================================================================
# Section 15: Skipped (requires system date mocking)
# ================================================================

# ================================================================
# Section 16: formatStage — null / edge cases
# ================================================================
puts "Section 16: formatStage — null/edge"

# 16.1
assert_eq [::sayableage::format_stage $en "" "2025-06-15"] "" "16.1"

# 16.3
assert_eq [::sayableage::format_stage $en "" "2025-06-15"] "" "16.3"

# 16.4
assert_eq [::sayableage::format_stage $en "2025-07-01" "2025-06-15"] "" "16.4"

# 16.5
assert_eq [::sayableage::format_stage $en "1525-06-15" "2025-06-15"] "Adult" "16.5"

# 16.6
assert_eq [::sayableage::format_stage $en "1524-06-15" "2025-06-15"] "" "16.6"

# ================================================================
# Section 17: formatStage — Newborn
# ================================================================
puts "Section 17: formatStage — Newborn"

# 17.1
assert_eq [::sayableage::format_stage $en "2025-06-15" "2025-06-15"] "Newborn" "17.1"

# 17.2
assert_eq [::sayableage::format_stage $en "2025-06-14" "2025-06-15"] "Newborn" "17.2"

# 17.3
assert_eq [::sayableage::format_stage $en "2025-05-25" "2025-06-15"] "Newborn" "17.3"

# 17.4
assert_eq [::sayableage::format_stage $en "2025-05-15" "2025-06-15"] "Newborn" "17.4"

# 17.5
assert_eq [::sayableage::format_stage $en "2025-04-16" "2025-06-15"] "Newborn" "17.5"

# 17.6
assert_eq [::sayableage::format_stage $en "2025-04-15" "2025-06-15"] "Infant" "17.6"

# ================================================================
# Section 18: formatStage — Infant
# ================================================================
puts "Section 18: formatStage — Infant"

# 18.1
assert_eq [::sayableage::format_stage $en "2025-04-15" "2025-06-15"] "Infant" "18.1"

# 18.2
assert_eq [::sayableage::format_stage $en "2024-12-15" "2025-06-15"] "Infant" "18.2"

# 18.3
assert_eq [::sayableage::format_stage $en "2024-07-15" "2025-06-15"] "Infant" "18.3"

# 18.4
assert_eq [::sayableage::format_stage $en "2024-06-15" "2025-06-15"] "Toddler" "18.4"

# ================================================================
# Section 19: formatStage — Toddler
# ================================================================
puts "Section 19: formatStage — Toddler"

# 19.1
assert_eq [::sayableage::format_stage $en "2024-06-15" "2025-06-15"] "Toddler" "19.1"

# 19.2
assert_eq [::sayableage::format_stage $en "2024-01-15" "2025-07-15"] "Toddler" "19.2"

# 19.3
assert_eq [::sayableage::format_stage $en "2023-06-15" "2025-06-15"] "Toddler" "19.3"

# 19.4
assert_eq [::sayableage::format_stage $en "2023-06-15" "2026-05-15"] "Toddler" "19.4"

# 19.5
assert_eq [::sayableage::format_stage $en "2022-06-15" "2025-06-15"] "Child" "19.5"

# ================================================================
# Section 20: formatStage — Child
# ================================================================
puts "Section 20: formatStage — Child"

# 20.1
assert_eq [::sayableage::format_stage $en "2022-06-15" "2025-06-15"] "Child" "20.1"

# 20.2
assert_eq [::sayableage::format_stage $en "2021-06-15" "2025-06-15"] "Child" "20.2"

# 20.3
assert_eq [::sayableage::format_stage $en "2019-06-15" "2025-06-15"] "Child" "20.3"

# 20.4
assert_eq [::sayableage::format_stage $en "2016-06-15" "2025-06-15"] "Child" "20.4"

# 20.5
assert_eq [::sayableage::format_stage $en "2013-06-15" "2026-05-15"] "Child" "20.5"

# 20.6
assert_eq [::sayableage::format_stage $en "2012-06-15" "2025-06-15"] "Teenager" "20.6"

# ================================================================
# Section 21: formatStage — Teenager
# ================================================================
puts "Section 21: formatStage — Teenager"

# 21.1
assert_eq [::sayableage::format_stage $en "2012-06-15" "2025-06-15"] "Teenager" "21.1"

# 21.2
assert_eq [::sayableage::format_stage $en "2010-06-15" "2025-06-15"] "Teenager" "21.2"

# 21.3
assert_eq [::sayableage::format_stage $en "2008-06-15" "2026-05-15"] "Teenager" "21.3"

# 21.4
assert_eq [::sayableage::format_stage $en "2007-06-15" "2025-06-15"] "Adult" "21.4"

# ================================================================
# Section 22: formatStage — Adult
# ================================================================
puts "Section 22: formatStage — Adult"

# 22.1
assert_eq [::sayableage::format_stage $en "2007-06-15" "2025-06-15"] "Adult" "22.1"

# 22.2
assert_eq [::sayableage::format_stage $en "2000-06-15" "2025-06-15"] "Adult" "22.2"

# 22.3
assert_eq [::sayableage::format_stage $en "1980-01-01" "2025-06-15"] "Adult" "22.3"

# ================================================================
# Section 23: Skipped (requires system date mocking)
# ================================================================

# ================================================================
# Section 24: SayableAge class — English locale delegation
# ================================================================
puts "Section 24: SayableAge class — English"

set en24 [::sayableage::new $en_locale]

# 24.1
assert_eq [::sayableage::format_age $en24 "2025-06-15" "2025-06-15"] "Newborn" "24.1"

# 24.2
assert_eq [::sayableage::format_age $en24 "2025-06-12" "2025-06-15"] "3 days" "24.2"

# 24.3
assert_eq [::sayableage::format_age $en24 "2025-06-07" "2025-06-15"] "1 week, 1 day" "24.3"

# 24.4
assert_eq [::sayableage::format_age $en24 "2025-01-15" "2025-07-15"] "6 months" "24.4"

# 24.5
assert_eq [::sayableage::format_age $en24 "2023-06-15" "2025-07-15"] "2 years, 1 month" "24.5"

# 24.6
assert_eq [::sayableage::format_age $en24 "2022-06-15" "2025-12-15"] "3½ years" "24.6"

# 24.7
assert_eq [::sayableage::format_age $en24 "2018-06-15" "2025-06-15"] "7 years" "24.7"

# 24.8
assert_eq [::sayableage::format_stage $en24 "2025-06-15" "2025-06-15"] "Newborn" "24.8"

# 24.9
assert_eq [::sayableage::format_stage $en24 "2025-01-15" "2025-06-15"] "Infant" "24.9"

# 24.10
assert_eq [::sayableage::format_stage $en24 "2024-06-15" "2025-06-15"] "Toddler" "24.10"

# 24.11
assert_eq [::sayableage::format_stage $en24 "2022-06-15" "2025-06-15"] "Child" "24.11"

# 24.12
assert_eq [::sayableage::format_stage $en24 "2012-06-15" "2025-06-15"] "Teenager" "24.12"

# 24.13
assert_eq [::sayableage::format_stage $en24 "2007-06-15" "2025-06-15"] "Adult" "24.13"

# 24.14
assert_eq [::sayableage::format_age $en24 "" "2025-06-15"] "" "24.14"

# 24.15
assert_eq [::sayableage::format_stage $en24 "" "2025-06-15"] "" "24.15"

# ================================================================
# Section 25: i18n — Spanish locale
# ================================================================
puts "Section 25: i18n — Spanish"

set es_locale [::sayableage::get_locale "es"]
set es [::sayableage::new $es_locale]

# 25.1
assert_eq [::sayableage::format_age $es "2025-06-15" "2025-06-15"] "Recién nacido" "25.1"

# 25.2
assert_eq [::sayableage::format_age $es "2025-06-14" "2025-06-15"] "1 día" "25.2"

# 25.3
assert_eq [::sayableage::format_age $es "2025-06-12" "2025-06-15"] "3 días" "25.3"

# 25.4
assert_eq [::sayableage::format_age $es "2025-06-08" "2025-06-15"] "1 semana" "25.4"

# 25.5
assert_eq [::sayableage::format_age $es "2025-06-07" "2025-06-15"] "1 semana, 1 día" "25.5"

# 25.6
assert_eq [::sayableage::format_age $es "2025-05-26" "2025-06-15"] "2 semanas, 6 días" "25.6"

# 25.7
assert_eq [::sayableage::format_age $es "2025-01-15" "2025-07-15"] "6 meses" "25.7"

# 25.8
assert_eq [::sayableage::format_age $es "2023-06-15" "2025-07-15"] "2 años, 1 mes" "25.8"

# 25.9
assert_eq [::sayableage::format_age $es "2023-06-15" "2025-12-15"] "2 años, 6 meses" "25.9"

# 25.10
assert_eq [::sayableage::format_age $es "2022-06-15" "2025-12-15"] "3 y medio años" "25.10"

# 25.11
assert_eq [::sayableage::format_age $es "2022-06-15" "2025-06-15"] "3 años" "25.11"

# 25.12
assert_eq [::sayableage::format_age $es "2018-06-15" "2025-06-15"] "7 años" "25.12"

# 25.13
assert_eq [::sayableage::format_stage $es "2025-06-15" "2025-06-15"] "Recién nacido" "25.13"

# 25.14
assert_eq [::sayableage::format_stage $es "2025-01-15" "2025-06-15"] "Bebé" "25.14"

# 25.15
assert_eq [::sayableage::format_stage $es "2024-06-15" "2025-06-15"] "Niño pequeño" "25.15"

# 25.16
assert_eq [::sayableage::format_stage $es "2022-06-15" "2025-06-15"] "Niño" "25.16"

# 25.17
assert_eq [::sayableage::format_stage $es "2012-06-15" "2025-06-15"] "Adolescente" "25.17"

# 25.18
assert_eq [::sayableage::format_stage $es "2007-06-15" "2025-06-15"] "Adulto" "25.18"

# 25.19
assert_eq [::sayableage::format_age $es "" "2025-06-15"] "" "25.19"

# 25.20
assert_eq [::sayableage::format_stage $es "" "2025-06-15"] "" "25.20"

# ================================================================
# Section 26: Compactness — short
# ================================================================
puts "Section 26: Compactness — short"

set en_short [::sayableage::new $en_locale "short"]

# 26.1
assert_eq [::sayableage::format_age $en_short "2025-06-12" "2025-06-15"] "3 d" "26.1"

# 26.2
assert_eq [::sayableage::format_age $en_short "2025-06-08" "2025-06-15"] "1 wk" "26.2"

# 26.3
assert_eq [::sayableage::format_age $en_short "2025-06-07" "2025-06-15"] "1 wk, 1 d" "26.3"

# 26.4
assert_eq [::sayableage::format_age $en_short "2025-01-15" "2025-07-15"] "6 mo" "26.4"

# 26.5
assert_eq [::sayableage::format_age $en_short "2023-06-15" "2025-07-15"] "2 yr, 1 mo" "26.5"

# 26.6
assert_eq [::sayableage::format_age $en_short "2022-06-15" "2025-12-15"] "3½ yr" "26.6"

# 26.7
assert_eq [::sayableage::format_age $en_short "2018-06-15" "2025-06-15"] "7 yr" "26.7"

# 26.8
assert_eq [::sayableage::format_age $en_short "2025-06-15" "2025-06-15"] "Newborn" "26.8"

# 26.9
assert_eq [::sayableage::format_stage $en_short "2025-01-15" "2025-06-15"] "Infant" "26.9"

# ================================================================
# Section 27: Compactness — compact
# ================================================================
puts "Section 27: Compactness — compact"

set en_compact [::sayableage::new $en_locale "compact"]

# 27.1
assert_eq [::sayableage::format_age $en_compact "2025-06-12" "2025-06-15"] "3d" "27.1"

# 27.2
assert_eq [::sayableage::format_age $en_compact "2025-06-08" "2025-06-15"] "1w" "27.2"

# 27.3
assert_eq [::sayableage::format_age $en_compact "2025-06-07" "2025-06-15"] "1w1d" "27.3"

# 27.4
assert_eq [::sayableage::format_age $en_compact "2025-01-15" "2025-07-15"] "6m" "27.4"

# 27.5
assert_eq [::sayableage::format_age $en_compact "2023-06-15" "2025-07-15"] "2y1m" "27.5"

# 27.6
assert_eq [::sayableage::format_age $en_compact "2022-06-15" "2025-12-15"] "3½y" "27.6"

# 27.7
assert_eq [::sayableage::format_age $en_compact "2018-06-15" "2025-06-15"] "7y" "27.7"

# 27.8
assert_eq [::sayableage::format_age $en_compact "2025-06-15" "2025-06-15"] "Newborn" "27.8"

# ================================================================
# Section 29: Locale-specific edge cases — plural rules
# ================================================================
puts "Section 29: Locale-specific edge cases"

# --- Hebrew ---
set he_locale [::sayableage::get_locale "he"]
set he [::sayableage::new $he_locale]

# 29.1
assert_eq [::sayableage::format_age $he "2025-06-15" "2025-06-15"] "רק נולד" "29.1"

# 29.2
assert_eq [::sayableage::format_age $he "2025-06-14" "2025-06-15"] "יום 1" "29.2"

# 29.3
assert_eq [::sayableage::format_age $he "2025-06-12" "2025-06-15"] "3 ימים" "29.3"

# 29.4
assert_eq [::sayableage::format_age $he "2025-06-01" "2025-06-15"] "שבועיים" "29.4"

# 29.5
assert_eq [::sayableage::format_age $he "2025-05-25" "2025-06-15"] "3 שבועות" "29.5"

# 29.6
assert_eq [::sayableage::format_age $he "2025-01-15" "2025-07-15"] "6 חודשים" "29.6"

# 29.7
assert_eq [::sayableage::format_age $he "2025-03-15" "2025-06-15"] "3 חודשים" "29.7"

# 29.8
assert_eq [::sayableage::format_age $he "2023-06-15" "2025-07-15"] "שנתיים, חודש 1" "29.8"

# 29.9
assert_eq [::sayableage::format_age $he "2022-06-15" "2025-12-15"] "3 שנים וחצי" "29.9"

# 29.10
assert_eq [::sayableage::format_age $he "2018-06-15" "2025-06-15"] "7 שנים" "29.10"

# 29.11
assert_eq [::sayableage::format_stage $he "2025-06-15" "2025-06-15" "m"] "רק נולד" "29.11"

# 29.12
assert_eq [::sayableage::format_stage $he "2025-06-15" "2025-06-15" "f"] "רק נולדה" "29.12"

# 29.13
assert_eq [::sayableage::format_stage $he "2007-06-15" "2025-06-15" "m"] "מבוגר" "29.13"

# 29.14
assert_eq [::sayableage::format_stage $he "2007-06-15" "2025-06-15" "f"] "מבוגרת" "29.14"

# --- Macedonian ---
set mk_locale [::sayableage::get_locale "mk"]
set mk [::sayableage::new $mk_locale]

# 29.15
assert_eq [::sayableage::format_age $mk "2025-06-15" "2025-06-15"] "Новороденче" "29.15"

# 29.16
assert_eq [::sayableage::format_age $mk "2025-06-14" "2025-06-15"] "1 ден" "29.16"

# 29.17
assert_eq [::sayableage::format_age $mk "2025-06-12" "2025-06-15"] "3 дена" "29.17"

# 29.18
assert_eq [::sayableage::format_age $mk "2025-01-15" "2025-07-15"] "6 месеци" "29.18"

# 29.19
assert_eq [::sayableage::format_age $mk "2023-06-15" "2025-07-15"] "2 години, 1 месец" "29.19"

# 29.20
assert_eq [::sayableage::format_age $mk "2022-06-15" "2025-12-15"] "3 години и пол" "29.20"

# 29.21
assert_eq [::sayableage::format_age $mk "2018-06-15" "2025-06-15"] "7 години" "29.21"

# --- Swahili ---
set sw_locale [::sayableage::get_locale "sw"]
set sw [::sayableage::new $sw_locale]

# 29.22
assert_eq [::sayableage::format_age $sw "2025-06-15" "2025-06-15"] "Mzaliwa mpya" "29.22"

# 29.23
assert_eq [::sayableage::format_age $sw "2025-06-14" "2025-06-15"] "siku 1" "29.23"

# 29.24
assert_eq [::sayableage::format_age $sw "2025-06-12" "2025-06-15"] "siku 3" "29.24"

# 29.25
assert_eq [::sayableage::format_age $sw "2025-01-15" "2025-07-15"] "miezi 6" "29.25"

# 29.26
assert_eq [::sayableage::format_age $sw "2023-06-15" "2025-07-15"] "miaka 2, mwezi 1" "29.26"

# 29.27
assert_eq [::sayableage::format_age $sw "2022-06-15" "2025-12-15"] "miaka 3 na nusu" "29.27"

# --- Indonesian ---
set id_locale [::sayableage::get_locale "id"]
set id_fmt [::sayableage::new $id_locale]

# 29.28
assert_eq [::sayableage::format_age $id_fmt "2025-06-15" "2025-06-15"] "Baru lahir" "29.28"

# 29.29
assert_eq [::sayableage::format_age $id_fmt "2025-06-14" "2025-06-15"] "1 hari" "29.29"

# 29.30
assert_eq [::sayableage::format_age $id_fmt "2025-06-12" "2025-06-15"] "3 hari" "29.30"

# 29.31
assert_eq [::sayableage::format_age $id_fmt "2025-01-15" "2025-07-15"] "6 bulan" "29.31"

# 29.32
assert_eq [::sayableage::format_age $id_fmt "2022-06-15" "2025-12-15"] "3 tahun setengah" "29.32"

# 29.33
assert_eq [::sayableage::format_age $id_fmt "2018-06-15" "2025-06-15"] "7 tahun" "29.33"

# --- Amharic ---
set am_locale [::sayableage::get_locale "am"]
set am [::sayableage::new $am_locale]

# 29.34
assert_eq [::sayableage::format_age $am "2025-06-15" "2025-06-15"] "አዲስ የተወለደ" "29.34"

# 29.35
assert_eq [::sayableage::format_age $am "2025-06-14" "2025-06-15"] "1 ቀን" "29.35"

# 29.36
assert_eq [::sayableage::format_age $am "2025-06-12" "2025-06-15"] "3 ቀናት" "29.36"

# 29.37
assert_eq [::sayableage::format_age $am "2025-06-07" "2025-06-15"] "1 ሳምንት፣ 1 ቀን" "29.37"

# 29.38
assert_eq [::sayableage::format_age $am "2025-01-15" "2025-07-15"] "6 ወራት" "29.38"

# 29.39
assert_eq [::sayableage::format_age $am "2022-06-15" "2025-12-15"] "3 ዓመታት ተኩል" "29.39"

# ================================================================
# Section 30: Locale lookup by code string
# ================================================================
puts "Section 30: Locale lookup"

# 30.1
set loc_en [::sayableage::get_locale "en"]
assert_eq [expr {$loc_en ne ""}] 1 "30.1" "en locale found"
assert_eq [dict get $loc_en code] "en" "30.1b"

# 30.2
set loc_fr [::sayableage::get_locale "fr"]
assert_eq [expr {$loc_fr ne ""}] 1 "30.2" "fr locale found"
assert_eq [dict get $loc_fr code] "fr" "30.2b"

# 30.3
assert_eq [::sayableage::get_locale "xx"] "" "30.3"

# 30.4
assert_eq [::sayableage::get_locale ""] "" "30.4"

# 30.5
assert_eq [::sayableage::get_locale "EN"] "" "30.5"

# ================================================================
# Summary
# ================================================================
puts ""
puts "============================================"
puts "Results: $_pass passed, $_fail failed"
puts "============================================"

if {$_fail > 0} {
    puts ""
    puts "Failures:"
    foreach err $_errors {
        puts "  FAIL: $err"
    }
    exit 1
}
exit 0
