#!/usr/bin/env tclsh
# Tests for sayabletime — mirrors canonical tests from time/config/tests.json

set script_dir [file dirname [info script]]
source [file join $script_dir format_time.tcl]

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

# Create default English formatter
set en_locale [::sayabletime::get_locale "en"]
set en [::sayabletime::new $en_locale]

# ================================================================
# Section 1: Null / edge cases
# ================================================================
puts "Section 1: Null / edge cases"

# 1.1 — null input
assert_eq [::sayabletime::format_time $en ""] "" "1.1"

# 1.2 — empty string
assert_eq [::sayabletime::format_time $en ""] "" "1.2"

# 1.3 — invalid time
assert_eq [::sayabletime::format_time $en "invalid"] "" "1.3"

# 1.4 — out of range
assert_eq [::sayabletime::format_time $en "25:00"] "" "1.4"

# ================================================================
# Section 2: Clock time (normal compactness)
# ================================================================
puts "Section 2: Clock time — normal"

# 2.1 — midnight
assert_eq [::sayabletime::format_time $en "00:00"] "midnight" "2.1"

# 2.2 — noon
assert_eq [::sayabletime::format_time $en "12:00"] "noon" "2.2"

# 2.3 — three o'clock
assert_eq [::sayabletime::format_time $en "15:00"] "three o'clock" "2.3"

# 2.4 — quarter past
assert_eq [::sayabletime::format_time $en "14:15"] "a quarter past two" "2.4"

# 2.5 — half past
assert_eq [::sayabletime::format_time $en "09:30"] "half past nine" "2.5"

# 2.6 — quarter to
assert_eq [::sayabletime::format_time $en "10:45"] "a quarter to eleven" "2.6"

# 2.7 — five past
assert_eq [::sayabletime::format_time $en "08:05"] "five past eight" "2.7"

# 2.8 — five to five
assert_eq [::sayabletime::format_time $en "16:55"] "five to five" "2.8"

# 2.9 — rounds to midnight
assert_eq [::sayabletime::format_time $en "23:58"] "midnight" "2.9"

# 2.10 — 22 rounds to 20
assert_eq [::sayabletime::format_time $en "07:22"] "twenty past seven" "2.10"

# 2.11 — ISO datetime input
assert_eq [::sayabletime::format_time $en "2025-01-15T14:15:00"] "a quarter past two" "2.11"

# ================================================================
# Section 3: Clock time (short compactness)
# ================================================================
puts "Section 3: Clock time — short"

set en_short [::sayabletime::new $en_locale "short"]

# 3.1
assert_eq [::sayabletime::format_time $en_short "14:15"] "2:15 PM" "3.1"

# 3.2
assert_eq [::sayabletime::format_time $en_short "09:30"] "9:30 AM" "3.2"

# 3.3
assert_eq [::sayabletime::format_time $en_short "00:00"] "12:00 AM" "3.3"

# 3.4
assert_eq [::sayabletime::format_time $en_short "12:00"] "12:00 PM" "3.4"

# ================================================================
# Section 4: Clock time (compact)
# ================================================================
puts "Section 4: Clock time — compact"

set en_compact [::sayabletime::new $en_locale "compact"]

# 4.1
assert_eq [::sayabletime::format_time $en_compact "14:15"] "2:15p" "4.1"

# 4.2
assert_eq [::sayabletime::format_time $en_compact "09:30"] "9:30a" "4.2"

# ================================================================
# Section 5: Locale — German
# ================================================================
puts "Section 5: Locale — German"

set de_locale [::sayabletime::get_locale "de"]
set de [::sayabletime::new $de_locale]

# 5.1
assert_eq [::sayabletime::format_time $de "15:30"] "halb vier" "5.1"

# ================================================================
# Section 6: Locale — French
# ================================================================
puts "Section 6: Locale — French"

set fr_locale [::sayabletime::get_locale "fr"]
set fr [::sayabletime::new $fr_locale]

# 6.1
assert_eq [::sayabletime::format_time $fr "15:15"] "trois heures et quart" "6.1"

# 6.2
assert_eq [::sayabletime::format_time $fr "13:00"] "une heure" "6.2"

# 6.3
assert_eq [::sayabletime::format_time $fr "13:30"] "une heure et demie" "6.3"

# 6.4
assert_eq [::sayabletime::format_time $fr "14:45"] "trois heures moins le quart" "6.4"

# 6.5
assert_eq [::sayabletime::format_time $fr "14:50"] "trois heures moins dix" "6.5"

# ================================================================
# Section 7: Locale — Japanese
# ================================================================
puts "Section 7: Locale — Japanese"

set ja_locale [::sayabletime::get_locale "ja"]
set ja [::sayabletime::new $ja_locale]

# 7.1
assert_eq [::sayabletime::format_time $ja "15:30"] "三時半" "7.1"

# ================================================================
# Section 8: Locale — Finnish (dot separator, short)
# ================================================================
puts "Section 8: Locale — Finnish"

set fi_locale [::sayabletime::get_locale "fi"]
set fi_short [::sayabletime::new $fi_locale "short"]

# 8.1
assert_eq [::sayabletime::format_time $fi_short "14:15"] "14.15" "8.1"

# 8.2
assert_eq [::sayabletime::format_time $fi_short "00:00"] "0.00" "8.2"

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================
puts "Sections 9-10: minutes in short/compact, input validation"

# 9.1
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en] short] "18:01"] "6:01 PM" "9.1"

# 9.2
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en] compact] "19:05"] "7:05p" "9.2"

# 10.1
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "9:30"] "half past nine" "10.1"

# 10.2
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "09:30"] "half past nine" "10.2"

# 10.3
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] " 9:30"] "" "10.3"

# 10.4
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "9:30 "] "" "10.4"

# 10.5
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "9:5"] "" "10.5"

# 10.6
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "24:00"] "" "10.6"

# 10.7
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "14:15:30"] "a quarter past two" "10.7"

# 10.8
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "2025-01-15T14:15:00Z"] "a quarter past two" "10.8"

# 10.9
assert_eq [::sayabletime::format_time [::sayabletime::new [::sayabletime::get_locale en]] "2025-02-30T14:15:00"] "" "10.9"


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
