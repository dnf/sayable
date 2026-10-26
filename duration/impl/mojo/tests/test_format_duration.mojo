"""Tests for format_duration, format_since, format_until -- all canonical test cases from duration/config/tests.json."""

from testing import assert_equal, assert_true

from sayable_duration.formatter import SayableDuration, format_duration, format_since, format_until, VERSION
from sayable_duration.locales.en import build_en
from sayable_duration.locales.de import build_de
from sayable_duration.locales.fr import build_fr
from sayable_duration.locales.ja import build_ja
from sayable_duration.locales.registry import get_locale, has_locale


# ================================================================
# Null / edge cases
# ================================================================


# 1.1 — null seconds handled by caller; Mojo uses -1 for invalid
# 1.2
fn test_negative_seconds() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_duration_seconds(-1), "")


# 1.3
fn test_null_start_since() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_since("", "2025-01-15T10:00:00"), "")


# 1.4
fn test_null_target_until() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_until("", "2025-01-15T10:00:00"), "")


# 1.5
fn test_since_as_of_before_start() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00"), "")


# 1.6
fn test_until_target_in_past() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00"), "")


# ================================================================
# Duration — seconds tier (0-59s)
# ================================================================


# 2.1
fn test_zero_seconds() raises:
    assert_equal(format_duration(0), "just now")


# 2.2
fn test_one_second() raises:
    assert_equal(format_duration(1), "1 second")


# 2.3
fn test_45_seconds() raises:
    assert_equal(format_duration(45), "45 seconds")


# 2.4
fn test_59_seconds() raises:
    assert_equal(format_duration(59), "59 seconds")


# ================================================================
# Duration — minutes + seconds tier (1-4 min)
# ================================================================


# 3.1
fn test_one_minute() raises:
    assert_equal(format_duration(60), "1 minute")


# 3.2
fn test_one_minute_30_seconds() raises:
    assert_equal(format_duration(90), "1 minute, 30 seconds")


# 3.3
fn test_four_minutes() raises:
    assert_equal(format_duration(240), "4 minutes")


# 3.4
fn test_four_minutes_30_seconds() raises:
    assert_equal(format_duration(270), "4 minutes, 30 seconds")


# ================================================================
# Duration — minutes tier (5-59 min)
# ================================================================


# 4.1
fn test_five_minutes() raises:
    assert_equal(format_duration(300), "5 minutes")


# 4.2
fn test_25_minutes() raises:
    assert_equal(format_duration(1500), "25 minutes")


# 4.3
fn test_59_minutes() raises:
    assert_equal(format_duration(3540), "59 minutes")


# ================================================================
# Duration — hours + minutes tier (1-5 hr)
# ================================================================


# 5.1
fn test_one_hour() raises:
    assert_equal(format_duration(3600), "1 hour")


# 5.2
fn test_one_and_half_hours() raises:
    assert_equal(format_duration(5400), "1½ hours")


# 5.3
fn test_two_hours_15_minutes() raises:
    assert_equal(format_duration(8100), "2 hours, 15 minutes")


# 5.4
fn test_five_hours() raises:
    assert_equal(format_duration(18000), "5 hours")


# ================================================================
# Duration — hours tier (6-23 hr)
# ================================================================


# 6.1
fn test_eight_hours() raises:
    assert_equal(format_duration(28800), "8 hours")


# 6.2
fn test_23_hours() raises:
    assert_equal(format_duration(82800), "23 hours")


# ================================================================
# Duration — days tier
# ================================================================


# 7.1
fn test_one_day() raises:
    assert_equal(format_duration(86400), "1 day")


# 7.2
fn test_one_day_3_hours() raises:
    assert_equal(format_duration(97200), "1 day, 3 hours")


# 7.3
fn test_one_and_half_days() raises:
    assert_equal(format_duration(129600), "1½ days")


# 7.4
fn test_five_days() raises:
    assert_equal(format_duration(432000), "5 days")


# 7.5
fn test_two_days() raises:
    assert_equal(format_duration(172800), "2 days")


# ================================================================
# Duration — weeks tier
# ================================================================


# 8.1
fn test_one_week() raises:
    assert_equal(format_duration(604800), "1 week")


# 8.2
fn test_two_weeks_one_day() raises:
    assert_equal(format_duration(1296000), "2 weeks, 1 day")


# 8.3
fn test_four_weeks() raises:
    assert_equal(format_duration(2419200), "4 weeks")


# ================================================================
# Duration — months and years tier
# ================================================================


# 9.1
fn test_one_month() raises:
    assert_equal(format_duration(2678400), "1 month")


# 9.2
fn test_three_months() raises:
    assert_equal(format_duration(7884000), "3 months")


# 9.3
fn test_one_year() raises:
    assert_equal(format_duration(31536000), "1 year")


# 9.4
fn test_one_year_3_months() raises:
    assert_equal(format_duration(39420000), "1 year, 3 months")


# ================================================================
# Duration from ISO timestamps
# ================================================================


# 10.1
fn test_iso_one_and_half_hours() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T11:30:00"), "1½ hours")


# 10.2
fn test_iso_45_minutes() raises:
    var sd = SayableDuration(build_en())
    assert_equal(sd.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes")


# ================================================================
# Relative time — since
# ================================================================


# 11.1
fn test_since_just_now() raises:
    assert_equal(format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")


# 11.2
fn test_since_30_seconds() raises:
    assert_equal(format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30"), "30 seconds ago")


# 11.3
fn test_since_45_minutes() raises:
    assert_equal(format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes ago")


# 11.4
fn test_since_3_hours() raises:
    assert_equal(format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00"), "3 hours ago")


# ================================================================
# Relative time — until
# ================================================================


# 12.1
fn test_until_just_now() raises:
    assert_equal(format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")


# 12.2
fn test_until_20_minutes() raises:
    assert_equal(format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00"), "in 20 minutes")


# 12.3
fn test_until_3_hours() raises:
    assert_equal(format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00"), "in 3 hours")


# ================================================================
# Locale — German
# ================================================================


# 13.1
fn test_german_one_hour() raises:
    var sd = SayableDuration(build_de())
    assert_equal(sd.format_duration_seconds(3600), "1 Stunde")


# 13.2
fn test_german_since_5_minutes() raises:
    var sd = SayableDuration(build_de())
    assert_equal(sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00"), "vor 5 Minuten")


# ================================================================
# Locale — French
# ================================================================


# 14.1
fn test_french_two_hours() raises:
    var sd = SayableDuration(build_fr())
    assert_equal(sd.format_duration_seconds(7200), "2 heures")


# ================================================================
# Locale — Japanese
# ================================================================


# 15.1
fn test_japanese_two_minutes() raises:
    var sd = SayableDuration(build_ja())
    assert_equal(sd.format_duration_seconds(120), "2分")


# 15.2
fn test_japanese_since_one_hour() raises:
    var sd = SayableDuration(build_ja())
    assert_equal(sd.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00"), "1時間前")


# ================================================================
# Short compactness — duration
# ================================================================


# 16.1
fn test_short_one_hour() raises:
    var sd = SayableDuration(build_en(), "short")
    assert_equal(sd.format_duration_seconds(3600), "1h")


# 16.2
fn test_short_one_minute_30_seconds() raises:
    var sd = SayableDuration(build_en(), "short")
    assert_equal(sd.format_duration_seconds(90), "1m, 30s")


# ================================================================
# Compact compactness — duration
# ================================================================


# 17.1
fn test_compact_one_hour() raises:
    var sd = SayableDuration(build_en(), "compact")
    assert_equal(sd.format_duration_seconds(3600), "1h")


# 17.2
fn test_compact_one_minute_30_seconds() raises:
    var sd = SayableDuration(build_en(), "compact")
    assert_equal(sd.format_duration_seconds(90), "1m30s")


# ================================================================
# Short since keeps days and hours
# ================================================================


# 18.1
fn test_18_1_short_since_keeps_days_and_hours() raises:
    var sd = SayableDuration(get_locale("men"))
    assert_equal(sd.format_since("2025-01-20T01:32:11", "2025-01-22T15:39:16"), "lɔhɔnga 2, awa 14 taa gbɔyɔ")


# ================================================================
# 500-year range
# ================================================================


# 19.1
fn test_19_1_500_julian_years_is_the_ceiling() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_seconds(15778800000), "500 years")


# 19.2
fn test_19_2_over_6000_months_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_seconds(15800000000), "")


# 19.3
fn test_19_3_far_beyond_ceiling_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_seconds(99999999999), "")


# 19.4
fn test_19_4_since_525_years_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_since("1500-01-01T00:00:00", "2025-01-01T00:00:00"), "")


# 19.5
fn test_19_5_until_575_years_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_until("2600-01-01T00:00:00", "2025-01-01T00:00:00"), "")


# ================================================================
# Timestamp validation
# ================================================================


# 20.1
fn test_20_1_seconds_are_optional() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_iso("2025-01-15T10:00", "2025-01-15T11:30:00"), "1½ hours")


# 20.2
fn test_20_2_minutes_are_required() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_iso("2025-01-15T10", "2025-01-15T11:30:00"), "")


# 20.3
fn test_20_3_unpadded_date_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_iso("2025-1-5T10:00:00", "2025-01-15T11:30:00"), "")


# 20.4
fn test_20_4_impossible_date_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_duration_iso("2025-02-30T10:00:00", "2025-03-15T11:30:00"), "")


# 20.5
fn test_20_5_hour_out_of_range_is_invalid() raises:
    var sd = SayableDuration(get_locale("en"))
    assert_equal(sd.format_since("2025-01-15T10:00:00", "2025-01-15T25:00:00"), "")

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
    test_negative_seconds()
    test_null_start_since()
    test_null_target_until()
    test_since_as_of_before_start()
    test_until_target_in_past()
    test_zero_seconds()
    test_one_second()
    test_45_seconds()
    test_59_seconds()
    test_one_minute()
    test_one_minute_30_seconds()
    test_four_minutes()
    test_four_minutes_30_seconds()
    test_five_minutes()
    test_25_minutes()
    test_59_minutes()
    test_one_hour()
    test_one_and_half_hours()
    test_two_hours_15_minutes()
    test_five_hours()
    test_eight_hours()
    test_23_hours()
    test_one_day()
    test_one_day_3_hours()
    test_one_and_half_days()
    test_five_days()
    test_two_days()
    test_one_week()
    test_two_weeks_one_day()
    test_four_weeks()
    test_one_month()
    test_three_months()
    test_one_year()
    test_one_year_3_months()
    test_iso_one_and_half_hours()
    test_iso_45_minutes()
    test_since_just_now()
    test_since_30_seconds()
    test_since_45_minutes()
    test_since_3_hours()
    test_until_just_now()
    test_until_20_minutes()
    test_until_3_hours()
    test_german_one_hour()
    test_german_since_5_minutes()
    test_french_two_hours()
    test_japanese_two_minutes()
    test_japanese_since_one_hour()
    test_short_one_hour()
    test_short_one_minute_30_seconds()
    test_compact_one_hour()
    test_compact_one_minute_30_seconds()
    test_registry_lookup()
    test_registry_fallback()
    test_18_1_short_since_keeps_days_and_hours()
    test_19_1_500_julian_years_is_the_ceiling()
    test_19_2_over_6000_months_is_invalid()
    test_19_3_far_beyond_ceiling_is_invalid()
    test_19_4_since_525_years_is_invalid()
    test_19_5_until_575_years_is_invalid()
    test_20_1_seconds_are_optional()
    test_20_2_minutes_are_required()
    test_20_3_unpadded_date_is_invalid()
    test_20_4_impossible_date_is_invalid()
    test_20_5_hour_out_of_range_is_invalid()
    print("All 65 duration tests passed.")
