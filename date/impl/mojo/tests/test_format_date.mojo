"""Tests for format_date and format_relative -- all canonical test cases from date/config/tests.json."""

from testing import assert_equal, assert_true

from sayable_date.formatter import SayableDate, format_date, format_relative, VERSION
from sayable_date.locales.en import build_en
from sayable_date.locales.de import build_de
from sayable_date.locales.fr import build_fr
from sayable_date.locales.ja import build_ja
from sayable_date.locales.ru import build_ru
from sayable_date.locales.ar import build_ar
from sayable_date.locales.es import build_es
from sayable_date.locales.registry import get_locale, has_locale


# ================================================================
# Null / edge cases
# ================================================================


# 1.1
fn test_null_date() raises:
    assert_equal(format_date(""), "")


# 1.2
fn test_empty_string_date() raises:
    assert_equal(format_date(""), "")


# 1.3
fn test_invalid_date() raises:
    assert_equal(format_date("invalid"), "")


# 1.4
fn test_null_as_of() raises:
    assert_equal(format_relative("2025-03-15", ""), "")


# 1.5
fn test_null_date_in_relative() raises:
    assert_equal(format_relative("", "2025-03-15"), "")


# ================================================================
# format_date — normal compactness (English)
# ================================================================


# 2.1
fn test_format_date_march_15() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-03-15"), "March 15th")


# 2.2
fn test_format_date_jan_1() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-01-01"), "January 1st")


# 2.3
fn test_format_date_may_22() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-05-22"), "May 22nd")


# 2.4
fn test_format_date_jul_3() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-07-03"), "July 3rd")


# 2.5
fn test_format_date_dec_31() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-12-31"), "December 31st")


# 2.6
fn test_format_date_jun_11() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-06-11"), "June 11th")


# 2.7
fn test_format_date_iso_datetime() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_date("2025-03-15T14:30:00"), "March 15th")


# ================================================================
# format_date — short compactness (English)
# ================================================================


# 3.1
fn test_format_date_short_march() raises:
    var sd = SayableDate(build_en(), "short")
    assert_equal(sd.format_date("2025-03-15"), "Mar 15")


# 3.2
fn test_format_date_short_jan() raises:
    var sd = SayableDate(build_en(), "short")
    assert_equal(sd.format_date("2025-01-01"), "Jan 1")


# 3.3
fn test_format_date_short_dec() raises:
    var sd = SayableDate(build_en(), "short")
    assert_equal(sd.format_date("2025-12-25"), "Dec 25")


# ================================================================
# format_date — compact (English)
# ================================================================


# 4.1
fn test_format_date_compact_march() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_date("2025-03-15"), "3/15")


# 4.2
fn test_format_date_compact_jan() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_date("2025-01-01"), "1/1")


# ================================================================
# format_relative — proximity tiers (English)
# ================================================================


# 5.1
fn test_relative_today() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-15", "2025-03-15"), "today")


# 5.2
fn test_relative_tomorrow() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "tomorrow")


# 5.3
fn test_relative_yesterday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-14", "2025-03-15"), "yesterday")


# 5.4
fn test_relative_day_after_tomorrow() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-17", "2025-03-15"), "the day after tomorrow")


# 5.5
fn test_relative_day_before_yesterday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-13", "2025-03-15"), "the day before yesterday")


# 5.6
fn test_relative_this_weekday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-19", "2025-03-15"), "this Wednesday")


# 5.7
fn test_relative_this_thursday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-20", "2025-03-15"), "this Thursday")


# 5.8
fn test_relative_last_weekday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-11", "2025-03-15"), "last Tuesday")


# 5.9
fn test_relative_next_weekday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-22", "2025-03-15"), "next Saturday")


# 5.10
fn test_relative_next_thursday() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-27", "2025-03-15"), "next Thursday")


# 5.11
fn test_relative_calendar_same_year() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-03-01", "2025-03-15"), "March 1st")


# 5.12
fn test_relative_calendar_future_same_year() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2025-04-10", "2025-03-15"), "April 10th")


# 5.13
fn test_relative_different_year_future() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2026-01-05", "2025-03-15"), "January 5th, 2026")


# 5.14
fn test_relative_different_year_past() raises:
    var sd = SayableDate(build_en())
    assert_equal(sd.format_relative("2024-12-25", "2025-03-15"), "December 25th, 2024")


# ================================================================
# format_relative — compact skips weekday tiers
# ================================================================


# 6.1
fn test_compact_relative_today() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_relative("2025-03-15", "2025-03-15"), "today")


# 6.2
fn test_compact_relative_tomorrow() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "tomorrow")


# 6.3
fn test_compact_relative_skips_weekday() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_relative("2025-03-19", "2025-03-15"), "3/19")


# 6.4
fn test_compact_relative_diff_year() raises:
    var sd = SayableDate(build_en(), "compact")
    assert_equal(sd.format_relative("2026-01-05", "2025-03-15"), "1/5/26")


# ================================================================
# Locale — German
# ================================================================


# 7.1
fn test_german_format_date() raises:
    var sd = SayableDate(build_de())
    assert_equal(sd.format_date("2025-03-15"), "15. März")


# 7.2
fn test_german_tomorrow() raises:
    var sd = SayableDate(build_de())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "morgen")


# 7.3
fn test_german_day_after_tomorrow() raises:
    var sd = SayableDate(build_de())
    assert_equal(sd.format_relative("2025-03-17", "2025-03-15"), "übermorgen")


# 7.4
fn test_german_this_weekday() raises:
    var sd = SayableDate(build_de())
    assert_equal(sd.format_relative("2025-03-19", "2025-03-15"), "diesen Mittwoch")


# ================================================================
# Locale — French
# ================================================================


# 8.1
fn test_french_format_date_1er() raises:
    var sd = SayableDate(build_fr())
    assert_equal(sd.format_date("2025-03-01"), "1er mars")


# 8.2
fn test_french_format_date_15() raises:
    var sd = SayableDate(build_fr())
    assert_equal(sd.format_date("2025-03-15"), "15 mars")


# 8.3
fn test_french_tomorrow() raises:
    var sd = SayableDate(build_fr())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "demain")


# ================================================================
# Locale — Japanese
# ================================================================


# 9.1
fn test_japanese_format_date() raises:
    var sd = SayableDate(build_ja())
    assert_equal(sd.format_date("2025-03-15"), "3月15日")


# 9.2
fn test_japanese_tomorrow() raises:
    var sd = SayableDate(build_ja())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "明日")


# 9.3
fn test_japanese_this_weekday() raises:
    var sd = SayableDate(build_ja())
    assert_equal(sd.format_relative("2025-03-19", "2025-03-15"), "今度の水曜日")


# ================================================================
# Locale — Russian (genitive months)
# ================================================================


# 10.1
fn test_russian_format_date() raises:
    var sd = SayableDate(build_ru())
    assert_equal(sd.format_date("2025-03-15"), "15 марта")


# 10.2
fn test_russian_tomorrow() raises:
    var sd = SayableDate(build_ru())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "завтра")


# ================================================================
# Locale — Arabic
# ================================================================


# 11.1
fn test_arabic_format_date() raises:
    var sd = SayableDate(build_ar())
    assert_equal(sd.format_date("2025-03-15"), "15 مارس")


# 11.2
fn test_arabic_tomorrow() raises:
    var sd = SayableDate(build_ar())
    assert_equal(sd.format_relative("2025-03-16", "2025-03-15"), "غداً")


# ================================================================
# Locale — Spanish
# ================================================================


# 12.1
fn test_spanish_format_date() raises:
    var sd = SayableDate(build_es())
    assert_equal(sd.format_date("2025-03-15"), "15 de marzo")


# 12.2
fn test_spanish_day_after_tomorrow() raises:
    var sd = SayableDate(build_es())
    assert_equal(sd.format_relative("2025-03-17", "2025-03-15"), "pasado mañana")


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
    test_null_date()
    test_empty_string_date()
    test_invalid_date()
    test_null_as_of()
    test_null_date_in_relative()
    test_format_date_march_15()
    test_format_date_jan_1()
    test_format_date_may_22()
    test_format_date_jul_3()
    test_format_date_dec_31()
    test_format_date_jun_11()
    test_format_date_iso_datetime()
    test_format_date_short_march()
    test_format_date_short_jan()
    test_format_date_short_dec()
    test_format_date_compact_march()
    test_format_date_compact_jan()
    test_relative_today()
    test_relative_tomorrow()
    test_relative_yesterday()
    test_relative_day_after_tomorrow()
    test_relative_day_before_yesterday()
    test_relative_this_weekday()
    test_relative_this_thursday()
    test_relative_last_weekday()
    test_relative_next_weekday()
    test_relative_next_thursday()
    test_relative_calendar_same_year()
    test_relative_calendar_future_same_year()
    test_relative_different_year_future()
    test_relative_different_year_past()
    test_compact_relative_today()
    test_compact_relative_tomorrow()
    test_compact_relative_skips_weekday()
    test_compact_relative_diff_year()
    test_german_format_date()
    test_german_tomorrow()
    test_german_day_after_tomorrow()
    test_german_this_weekday()
    test_french_format_date_1er()
    test_french_format_date_15()
    test_french_tomorrow()
    test_japanese_format_date()
    test_japanese_tomorrow()
    test_japanese_this_weekday()
    test_russian_format_date()
    test_russian_tomorrow()
    test_arabic_format_date()
    test_arabic_tomorrow()
    test_spanish_format_date()
    test_spanish_day_after_tomorrow()
    test_registry_lookup()
    test_registry_fallback()
    print("All 52 date tests passed.")
