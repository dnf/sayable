#!/usr/bin/env tclsh
# Tests for sayableduration — mirrors canonical tests from duration/config/tests.json

set script_dir [file dirname [info script]]
source [file join $script_dir format_duration.tcl]

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
set en_locale [::sayableduration::get_locale "en"]
set en [::sayableduration::new $en_locale]

# ================================================================
# Section 1: Null / edge cases
# ================================================================
puts "Section 1: Null / edge cases"

# 1.1 — null input (empty string in Tcl)
assert_eq [::sayableduration::format_duration $en ""] "" "1.1"

# 1.2 — negative seconds
assert_eq [::sayableduration::format_duration $en -1] "" "1.2"

# 1.3 — format_since with null start
assert_eq [::sayableduration::format_since $en "" "2025-01-15T10:00:00"] "" "1.3"

# 1.4 — format_until with null target
assert_eq [::sayableduration::format_until $en "" "2025-01-15T10:00:00"] "" "1.4"

# 1.5 — format_since with asOf before start
assert_eq [::sayableduration::format_since $en "2025-01-15T10:00:00" "2025-01-15T09:00:00"] "" "1.5"

# 1.6 — format_until with target in the past
assert_eq [::sayableduration::format_until $en "2025-01-15T09:00:00" "2025-01-15T10:00:00"] "" "1.6"

# ================================================================
# Section 2: Duration — seconds tier (0-59s)
# ================================================================
puts "Section 2: Seconds tier"

# 2.1
assert_eq [::sayableduration::format_duration $en 0] "just now" "2.1"

# 2.2
assert_eq [::sayableduration::format_duration $en 1] "1 second" "2.2"

# 2.3
assert_eq [::sayableduration::format_duration $en 45] "45 seconds" "2.3"

# 2.4
assert_eq [::sayableduration::format_duration $en 59] "59 seconds" "2.4"

# ================================================================
# Section 3: Duration — minutes + seconds tier (1-4 min)
# ================================================================
puts "Section 3: Minutes + seconds tier"

# 3.1
assert_eq [::sayableduration::format_duration $en 60] "1 minute" "3.1"

# 3.2
assert_eq [::sayableduration::format_duration $en 90] "1 minute, 30 seconds" "3.2"

# 3.3
assert_eq [::sayableduration::format_duration $en 240] "4 minutes" "3.3"

# 3.4
assert_eq [::sayableduration::format_duration $en 270] "4 minutes, 30 seconds" "3.4"

# ================================================================
# Section 4: Duration — minutes tier (5-59 min)
# ================================================================
puts "Section 4: Minutes tier"

# 4.1
assert_eq [::sayableduration::format_duration $en 300] "5 minutes" "4.1"

# 4.2
assert_eq [::sayableduration::format_duration $en 1500] "25 minutes" "4.2"

# 4.3
assert_eq [::sayableduration::format_duration $en 3540] "59 minutes" "4.3"

# ================================================================
# Section 5: Duration — hours + minutes tier (1-5 hr)
# ================================================================
puts "Section 5: Hours + minutes tier"

# 5.1
assert_eq [::sayableduration::format_duration $en 3600] "1 hour" "5.1"

# 5.2 — half marker
assert_eq [::sayableduration::format_duration $en 5400] "1½ hours" "5.2"

# 5.3
assert_eq [::sayableduration::format_duration $en 8100] "2 hours, 15 minutes" "5.3"

# 5.4
assert_eq [::sayableduration::format_duration $en 18000] "5 hours" "5.4"

# ================================================================
# Section 6: Duration — hours tier (6-23 hr)
# ================================================================
puts "Section 6: Hours tier"

# 6.1
assert_eq [::sayableduration::format_duration $en 28800] "8 hours" "6.1"

# 6.2
assert_eq [::sayableduration::format_duration $en 82800] "23 hours" "6.2"

# ================================================================
# Section 7: Duration — days tier
# ================================================================
puts "Section 7: Days tier"

# 7.1
assert_eq [::sayableduration::format_duration $en 86400] "1 day" "7.1"

# 7.2
assert_eq [::sayableduration::format_duration $en 97200] "1 day, 3 hours" "7.2"

# 7.3 — half marker
assert_eq [::sayableduration::format_duration $en 129600] "1½ days" "7.3"

# 7.4
assert_eq [::sayableduration::format_duration $en 432000] "5 days" "7.4"

# 7.5
assert_eq [::sayableduration::format_duration $en 172800] "2 days" "7.5"

# ================================================================
# Section 8: Duration — weeks tier
# ================================================================
puts "Section 8: Weeks tier"

# 8.1
assert_eq [::sayableduration::format_duration $en 604800] "1 week" "8.1"

# 8.2
assert_eq [::sayableduration::format_duration $en 1296000] "2 weeks, 1 day" "8.2"

# 8.3
assert_eq [::sayableduration::format_duration $en 2419200] "4 weeks" "8.3"

# ================================================================
# Section 9: Duration — months and years tier
# ================================================================
puts "Section 9: Months and years tier"

# 9.1
assert_eq [::sayableduration::format_duration $en 2678400] "1 month" "9.1"

# 9.2
assert_eq [::sayableduration::format_duration $en 7884000] "3 months" "9.2"

# 9.3
assert_eq [::sayableduration::format_duration $en 31536000] "1 year" "9.3"

# 9.4
assert_eq [::sayableduration::format_duration $en 39420000] "1 year, 3 months" "9.4"

# ================================================================
# Section 10: Duration from ISO timestamps
# ================================================================
puts "Section 10: ISO timestamps"

# 10.1
assert_eq [::sayableduration::format_duration $en "2025-01-15T10:00:00" "2025-01-15T11:30:00"] "1½ hours" "10.1"

# 10.2
assert_eq [::sayableduration::format_duration $en "2025-01-15T10:00:00" "2025-01-15T10:45:00"] "45 minutes" "10.2"

# ================================================================
# Section 11: Relative time — since
# ================================================================
puts "Section 11: format_since"

# 11.1
assert_eq [::sayableduration::format_since $en "2025-01-15T10:00:00" "2025-01-15T10:00:00"] "just now" "11.1"

# 11.2
assert_eq [::sayableduration::format_since $en "2025-01-15T10:00:00" "2025-01-15T10:00:30"] "30 seconds ago" "11.2"

# 11.3
assert_eq [::sayableduration::format_since $en "2025-01-15T10:00:00" "2025-01-15T10:45:00"] "45 minutes ago" "11.3"

# 11.4
assert_eq [::sayableduration::format_since $en "2025-01-15T10:00:00" "2025-01-15T13:00:00"] "3 hours ago" "11.4"

# ================================================================
# Section 12: Relative time — until
# ================================================================
puts "Section 12: format_until"

# 12.1
assert_eq [::sayableduration::format_until $en "2025-01-15T10:00:00" "2025-01-15T10:00:00"] "just now" "12.1"

# 12.2
assert_eq [::sayableduration::format_until $en "2025-01-15T10:20:00" "2025-01-15T10:00:00"] "in 20 minutes" "12.2"

# 12.3
assert_eq [::sayableduration::format_until $en "2025-01-15T13:00:00" "2025-01-15T10:00:00"] "in 3 hours" "12.3"

# ================================================================
# Section 13: Locale — German
# ================================================================
puts "Section 13: Locale — German"

set de_locale [::sayableduration::get_locale "de"]
set de [::sayableduration::new $de_locale]

# 13.1
assert_eq [::sayableduration::format_duration $de 3600] "1 Stunde" "13.1"

# 13.2
assert_eq [::sayableduration::format_since $de "2025-01-15T10:00:00" "2025-01-15T10:05:00"] "vor 5 Minuten" "13.2"

# ================================================================
# Section 14: Locale — French
# ================================================================
puts "Section 14: Locale — French"

set fr_locale [::sayableduration::get_locale "fr"]
set fr [::sayableduration::new $fr_locale]

# 14.1
assert_eq [::sayableduration::format_duration $fr 7200] "2 heures" "14.1"

# ================================================================
# Section 15: Locale — Japanese
# ================================================================
puts "Section 15: Locale — Japanese"

set ja_locale [::sayableduration::get_locale "ja"]
set ja [::sayableduration::new $ja_locale]

# 15.1
assert_eq [::sayableduration::format_duration $ja 120] "2分" "15.1"

# 15.2
assert_eq [::sayableduration::format_since $ja "2025-01-15T10:00:00" "2025-01-15T11:00:00"] "1時間前" "15.2"

# ================================================================
# Section 16: Short compactness
# ================================================================
puts "Section 16: Short compactness"

set en_short [::sayableduration::new $en_locale "short"]

# 16.1
assert_eq [::sayableduration::format_duration $en_short 3600] "1h" "16.1"

# 16.2
assert_eq [::sayableduration::format_duration $en_short 90] "1m, 30s" "16.2"

# ================================================================
# Section 17: Compact compactness
# ================================================================
puts "Section 17: Compact compactness"

set en_compact [::sayableduration::new $en_locale "compact"]

# 17.1
assert_eq [::sayableduration::format_duration $en_compact 3600] "1h" "17.1"

# 17.2
assert_eq [::sayableduration::format_duration $en_compact 90] "1m30s" "17.2"

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
