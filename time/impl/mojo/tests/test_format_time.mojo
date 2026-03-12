"""Tests for format_time -- all canonical test cases from time/config/tests.json."""

from testing import assert_equal, assert_true

from sayable_time.formatter import SayableTime, format_time, VERSION
from sayable_time.locales.en import build_en
from sayable_time.locales.de import build_de
from sayable_time.locales.fr import build_fr
from sayable_time.locales.ja import build_ja
from sayable_time.locales.fi import build_fi
from sayable_time.locales.registry import get_locale, has_locale


# ================================================================
# Null / edge cases
# ================================================================


# 1.1 — null handled by caller; Mojo uses empty string
# 1.2
fn test_empty_string() raises:
    assert_equal(format_time(""), "")


# 1.3
fn test_invalid_input() raises:
    assert_equal(format_time("invalid"), "")


# 1.4
fn test_invalid_hour() raises:
    assert_equal(format_time("25:00"), "")


# ================================================================
# Clock time (normal compactness)
# ================================================================


# 2.1
fn test_midnight() raises:
    assert_equal(format_time("00:00"), "midnight")


# 2.2
fn test_noon() raises:
    assert_equal(format_time("12:00"), "noon")


# 2.3
fn test_three_oclock() raises:
    assert_equal(format_time("15:00"), "three o'clock")


# 2.4
fn test_quarter_past_two() raises:
    assert_equal(format_time("14:15"), "a quarter past two")


# 2.5
fn test_half_past_nine() raises:
    assert_equal(format_time("09:30"), "half past nine")


# 2.6
fn test_quarter_to_eleven() raises:
    assert_equal(format_time("10:45"), "a quarter to eleven")


# 2.7
fn test_five_past_eight() raises:
    assert_equal(format_time("08:05"), "five past eight")


# 2.8
fn test_five_to_five() raises:
    assert_equal(format_time("16:55"), "five to five")


# 2.9
fn test_rounds_to_midnight() raises:
    assert_equal(format_time("23:58"), "midnight")


# 2.10
fn test_rounds_to_20() raises:
    assert_equal(format_time("07:22"), "twenty past seven")


# 2.11
fn test_iso_datetime_input() raises:
    assert_equal(format_time("2025-01-15T14:15:00"), "a quarter past two")


# ================================================================
# Clock time (short compactness)
# ================================================================


# 3.1
fn test_short_pm() raises:
    var st = SayableTime(build_en(), "short")
    assert_equal(st.format_time("14:15"), "2:15 PM")


# 3.2
fn test_short_am() raises:
    var st = SayableTime(build_en(), "short")
    assert_equal(st.format_time("09:30"), "9:30 AM")


# 3.3
fn test_short_midnight() raises:
    var st = SayableTime(build_en(), "short")
    assert_equal(st.format_time("00:00"), "12:00 AM")


# 3.4
fn test_short_noon() raises:
    var st = SayableTime(build_en(), "short")
    assert_equal(st.format_time("12:00"), "12:00 PM")


# ================================================================
# Clock time (compact)
# ================================================================


# 4.1
fn test_compact_pm() raises:
    var st = SayableTime(build_en(), "compact")
    assert_equal(st.format_time("14:15"), "2:15p")


# 4.2
fn test_compact_am() raises:
    var st = SayableTime(build_en(), "compact")
    assert_equal(st.format_time("09:30"), "9:30a")


# ================================================================
# Locale — German
# ================================================================


# 5.1
fn test_german_half_to() raises:
    var st = SayableTime(build_de())
    assert_equal(st.format_time("15:30"), "halb vier")


# ================================================================
# Locale — French
# ================================================================


# 6.1
fn test_french_quarter_past() raises:
    var st = SayableTime(build_fr())
    assert_equal(st.format_time("15:15"), "trois heures et quart")


# ================================================================
# Locale — Japanese
# ================================================================


# 7.1
fn test_japanese_half_past() raises:
    var st = SayableTime(build_ja())
    assert_equal(st.format_time("15:30"), "三時半")


# ================================================================
# Locale — Finnish (dot separator, short)
# ================================================================


# 8.1
fn test_finnish_short_dot() raises:
    var st = SayableTime(build_fi(), "short")
    assert_equal(st.format_time("14:15"), "14.15")


# 8.2
fn test_finnish_short_midnight() raises:
    var st = SayableTime(build_fi(), "short")
    assert_equal(st.format_time("00:00"), "0.00")


# ================================================================
# Registry
# ================================================================


fn test_registry_lookup() raises:
    assert_true(has_locale("en"))
    assert_true(has_locale("de"))
    var loc = get_locale("en")
    assert_equal(loc.code, "en")


fn test_registry_fallback() raises:
    var loc = get_locale("xx-unknown")
    assert_equal(loc.code, "en")


# ================================================================
# Main
# ================================================================


fn main() raises:
    test_empty_string()
    test_invalid_input()
    test_invalid_hour()
    test_midnight()
    test_noon()
    test_three_oclock()
    test_quarter_past_two()
    test_half_past_nine()
    test_quarter_to_eleven()
    test_five_past_eight()
    test_five_to_five()
    test_rounds_to_midnight()
    test_rounds_to_20()
    test_iso_datetime_input()
    test_short_pm()
    test_short_am()
    test_short_midnight()
    test_short_noon()
    test_compact_pm()
    test_compact_am()
    test_german_half_to()
    test_french_quarter_past()
    test_japanese_half_past()
    test_finnish_short_dot()
    test_finnish_short_midnight()
    test_registry_lookup()
    test_registry_fallback()
    print("All 26 time tests passed.")
