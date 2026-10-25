#!/usr/bin/env tclsh
# Tests for sayabledate — mirrors canonical tests from date/config/tests.json

set script_dir [file dirname [info script]]
source [file join $script_dir format_date.tcl]

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
set en_locale [::sayabledate::get_locale "en"]
set en [::sayabledate::new $en_locale]

# ================================================================
# Section 1: Null / edge cases
# ================================================================
puts "Section 1: Null / edge cases"

# 1.1 — null input
assert_eq [::sayabledate::format_date $en ""] "" "1.1"

# 1.2 — empty string
assert_eq [::sayabledate::format_date $en ""] "" "1.2"

# 1.3 — invalid date
assert_eq [::sayabledate::format_date $en "invalid"] "" "1.3"

# 1.4 — format_relative with null asOf
assert_eq [::sayabledate::format_relative $en "2025-03-15" ""] "" "1.4"

# 1.5 — format_relative with null date
assert_eq [::sayabledate::format_relative $en "" "2025-03-15"] "" "1.5"

# ================================================================
# Section 2: format_date — normal compactness (English)
# ================================================================
puts "Section 2: format_date — normal"

# 2.1
assert_eq [::sayabledate::format_date $en "2025-03-15"] "March 15th" "2.1"

# 2.2
assert_eq [::sayabledate::format_date $en "2025-01-01"] "January 1st" "2.2"

# 2.3
assert_eq [::sayabledate::format_date $en "2025-05-22"] "May 22nd" "2.3"

# 2.4
assert_eq [::sayabledate::format_date $en "2025-07-03"] "July 3rd" "2.4"

# 2.5
assert_eq [::sayabledate::format_date $en "2025-12-31"] "December 31st" "2.5"

# 2.6
assert_eq [::sayabledate::format_date $en "2025-06-11"] "June 11th" "2.6"

# 2.7 — ISO datetime input
assert_eq [::sayabledate::format_date $en "2025-03-15T14:30:00"] "March 15th" "2.7"

# ================================================================
# Section 3: format_date — short compactness (English)
# ================================================================
puts "Section 3: format_date — short"

set en_short [::sayabledate::new $en_locale "short"]

# 3.1
assert_eq [::sayabledate::format_date $en_short "2025-03-15"] "Mar 15" "3.1"

# 3.2
assert_eq [::sayabledate::format_date $en_short "2025-01-01"] "Jan 1" "3.2"

# 3.3
assert_eq [::sayabledate::format_date $en_short "2025-12-25"] "Dec 25" "3.3"

# ================================================================
# Section 4: format_date — compact (English)
# ================================================================
puts "Section 4: format_date — compact"

set en_compact [::sayabledate::new $en_locale "compact"]

# 4.1
assert_eq [::sayabledate::format_date $en_compact "2025-03-15"] "3/15" "4.1"

# 4.2
assert_eq [::sayabledate::format_date $en_compact "2025-01-01"] "1/1" "4.2"

# ================================================================
# Section 5: format_relative — proximity tiers (English)
# ================================================================
puts "Section 5: format_relative — proximity tiers"

# 5.1 — today
assert_eq [::sayabledate::format_relative $en "2025-03-15" "2025-03-15"] "today" "5.1"

# 5.2 — tomorrow
assert_eq [::sayabledate::format_relative $en "2025-03-16" "2025-03-15"] "tomorrow" "5.2"

# 5.3 — yesterday
assert_eq [::sayabledate::format_relative $en "2025-03-14" "2025-03-15"] "yesterday" "5.3"

# 5.4 — day after tomorrow
assert_eq [::sayabledate::format_relative $en "2025-03-17" "2025-03-15"] "the day after tomorrow" "5.4"

# 5.5 — day before yesterday
assert_eq [::sayabledate::format_relative $en "2025-03-13" "2025-03-15"] "the day before yesterday" "5.5"

# 5.6 — this weekday (+4)
assert_eq [::sayabledate::format_relative $en "2025-03-19" "2025-03-15"] "this Wednesday" "5.6"

# 5.7 — this weekday (+5)
assert_eq [::sayabledate::format_relative $en "2025-03-20" "2025-03-15"] "this Thursday" "5.7"

# 5.8 — last weekday (-4)
assert_eq [::sayabledate::format_relative $en "2025-03-11" "2025-03-15"] "last Tuesday" "5.8"

# 5.9 — next weekday (+7)
assert_eq [::sayabledate::format_relative $en "2025-03-22" "2025-03-15"] "next Saturday" "5.9"

# 5.10 — next weekday (+12)
assert_eq [::sayabledate::format_relative $en "2025-03-27" "2025-03-15"] "next Thursday" "5.10"

# 5.11 — calendar fallback same year (-14)
assert_eq [::sayabledate::format_relative $en "2025-03-01" "2025-03-15"] "March 1st" "5.11"

# 5.12 — calendar fallback same year (+26)
assert_eq [::sayabledate::format_relative $en "2025-04-10" "2025-03-15"] "April 10th" "5.12"

# 5.13 — different year includes year
assert_eq [::sayabledate::format_relative $en "2026-01-05" "2025-03-15"] "January 5th, 2026" "5.13"

# 5.14 — past year includes year
assert_eq [::sayabledate::format_relative $en "2024-12-25" "2025-03-15"] "December 25th, 2024" "5.14"

# ================================================================
# Section 6: format_relative — compact skips weekday tiers
# ================================================================
puts "Section 6: format_relative — compact"

# 6.1 — compact today
assert_eq [::sayabledate::format_relative $en_compact "2025-03-15" "2025-03-15"] "today" "6.1"

# 6.2 — compact tomorrow
assert_eq [::sayabledate::format_relative $en_compact "2025-03-16" "2025-03-15"] "tomorrow" "6.2"

# 6.3 — compact goes straight to numeric
assert_eq [::sayabledate::format_relative $en_compact "2025-03-19" "2025-03-15"] "3/19" "6.3"

# 6.4 — compact different year
assert_eq [::sayabledate::format_relative $en_compact "2026-01-05" "2025-03-15"] "1/5/26" "6.4"

# ================================================================
# Section 7: Locale — German
# ================================================================
puts "Section 7: Locale — German"

set de_locale [::sayabledate::get_locale "de"]
set de [::sayabledate::new $de_locale]

# 7.1
assert_eq [::sayabledate::format_date $de "2025-03-15"] "15. März" "7.1"

# 7.2
assert_eq [::sayabledate::format_relative $de "2025-03-16" "2025-03-15"] "morgen" "7.2"

# 7.3
assert_eq [::sayabledate::format_relative $de "2025-03-17" "2025-03-15"] "übermorgen" "7.3"

# 7.4
assert_eq [::sayabledate::format_relative $de "2025-03-19" "2025-03-15"] "diesen Mittwoch" "7.4"

# ================================================================
# Section 8: Locale — French
# ================================================================
puts "Section 8: Locale — French"

set fr_locale [::sayabledate::get_locale "fr"]
set fr [::sayabledate::new $fr_locale]

# 8.1
assert_eq [::sayabledate::format_date $fr "2025-03-01"] "1er mars" "8.1"

# 8.2
assert_eq [::sayabledate::format_date $fr "2025-03-15"] "15 mars" "8.2"

# 8.3
assert_eq [::sayabledate::format_relative $fr "2025-03-16" "2025-03-15"] "demain" "8.3"

# ================================================================
# Section 9: Locale — Japanese
# ================================================================
puts "Section 9: Locale — Japanese"

set ja_locale [::sayabledate::get_locale "ja"]
set ja [::sayabledate::new $ja_locale]

# 9.1
assert_eq [::sayabledate::format_date $ja "2025-03-15"] "3月15日" "9.1"

# 9.2
assert_eq [::sayabledate::format_relative $ja "2025-03-16" "2025-03-15"] "明日" "9.2"

# 9.3
assert_eq [::sayabledate::format_relative $ja "2025-03-19" "2025-03-15"] "今度の水曜日" "9.3"

# ================================================================
# Section 10: Locale — Russian (genitive months)
# ================================================================
puts "Section 10: Locale — Russian"

set ru_locale [::sayabledate::get_locale "ru"]
set ru [::sayabledate::new $ru_locale]

# 10.1
assert_eq [::sayabledate::format_date $ru "2025-03-15"] "15 марта" "10.1"

# 10.2
assert_eq [::sayabledate::format_relative $ru "2025-03-16" "2025-03-15"] "завтра" "10.2"

# ================================================================
# Section 11: Locale — Arabic
# ================================================================
puts "Section 11: Locale — Arabic"

set ar_locale [::sayabledate::get_locale "ar"]
set ar [::sayabledate::new $ar_locale]

# 11.1
assert_eq [::sayabledate::format_date $ar "2025-03-15"] "15 مارس" "11.1"

# 11.2
assert_eq [::sayabledate::format_relative $ar "2025-03-16" "2025-03-15"] "غداً" "11.2"

# ================================================================
# Section 12: Locale — Spanish
# ================================================================
puts "Section 12: Locale — Spanish"

set es_locale [::sayabledate::get_locale "es"]
set es [::sayabledate::new $es_locale]

# 12.1
assert_eq [::sayabledate::format_date $es "2025-03-15"] "15 de marzo" "12.1"

# 12.2
assert_eq [::sayabledate::format_relative $es "2025-03-17" "2025-03-15"] "pasado mañana" "12.2"

# ================================================================
# Sections 13-16: with year, short months, short phrases, input validation
# ================================================================
puts "Sections 13-16: with year, short months, short phrases, input validation"

# 13.1
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale en]] "2018-02-04"] "February 4th, 2018" "13.1"

# 13.2
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale en] short] "2025-03-15"] "Mar 15, 2025" "13.2"

# 13.3
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale en] compact] "1997-01-21"] "1/21/97" "13.3"

# 13.4
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale tg] compact] "2007-05-20"] "20/5/07" "13.4"

# 13.5
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale fi] short] "1996-06-21"] "21. kesäkuuta 1996" "13.5"

# 14.1
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale sk] short] "2031-02-15"] "15. februára" "14.1"

# 14.2
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale cs] short] "2025-12-10"] "10. prosince" "14.2"

# 14.3
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale uk] short] "2025-11-05"] "5 листопада" "14.3"

# 14.4
assert_eq [::sayabledate::format_relative [::sayabledate::new [::sayabledate::get_locale fi] short] "1998-08-08" "1998-08-15"] "8. elokuuta" "14.4"

# 15.1
assert_eq [::sayabledate::format_relative [::sayabledate::new [::sayabledate::get_locale kw] short] "2035-12-04" "2035-12-02"] "an Mth ma" "15.1"

# 15.2
assert_eq [::sayabledate::format_relative [::sayabledate::new [::sayabledate::get_locale mam] short] "2000-01-23" "2000-01-25"] "Dom nchi'j" "15.2"

# 15.3
assert_eq [::sayabledate::format_relative [::sayabledate::new [::sayabledate::get_locale kek] short] "2014-10-24" "2014-10-22"] "a'in Vie" "15.3"

# 16.1
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale en]] "2025-02-30"] "" "16.1"

# 16.2
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale en]] "2025-13-01"] "" "16.2"

# 16.3
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale en]] "2025-6-1"] "" "16.3"

# 16.4
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale en]] " 2025-06-01"] "" "16.4"

# 16.5
assert_eq [::sayabledate::format_date [::sayabledate::new [::sayabledate::get_locale en]] "2025-06-01T10:00:00"] "June 1st" "16.5"

# 16.6
assert_eq [::sayabledate::format_date_with_year [::sayabledate::new [::sayabledate::get_locale en]] "2023-02-29"] "" "16.6"

# 16.7
assert_eq [::sayabledate::format_relative [::sayabledate::new [::sayabledate::get_locale en]] "2025-03-16" "2025-04-31"] "" "16.7"


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
