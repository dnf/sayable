"""Tests for format_age and format_stage -- all canonical test cases from age/config/tests.json."""

from testing import assert_equal, assert_true

from sayable_age.locale import (
    AgeLocale,
    CompactnessOverride,
    StageLabel,
    UnitForms,
    simple_unit,
    plural_unit,
    stage_neutral,
    stage_gendered,
    resolve_stage,
)
from sayable_age.formatter import SayableAge, format_age, format_stage, VERSION
from sayable_age.locales.en import build_en
from sayable_age.locales.es import build_es
from sayable_age.locales.ar import build_ar
from sayable_age.locales.he import build_he
from sayable_age.locales.mk import build_mk
from sayable_age.locales.sw import build_sw
from sayable_age.locales.id import build_id
from sayable_age.locales.am import build_am
from sayable_age.locales.registry import get_locale, has_locale


# ================================================================
# Null / edge cases
# ================================================================


# 1.3
fn test_returns_empty_for_empty_string() raises:
    assert_equal(format_age("", "2025-06-15"), "")


# 1.4
fn test_returns_empty_for_future_date_of_birth() raises:
    assert_equal(format_age("2025-07-01", "2025-06-15"), "")


# 1.5
fn test_exactly_500_years_is_allowed() raises:
    assert_equal(format_age("1525-06-15", "2025-06-15"), "500 years")


# 1.6
fn test_501_years_exceeds_max_age() raises:
    assert_equal(format_age("1524-06-15", "2025-06-15"), "")


# 1.7
fn test_1000_years_exceeds_max_age() raises:
    assert_equal(format_age("1025-06-15", "2025-06-15"), "")


# ================================================================
# Days tier: 0-6 days
# ================================================================


# 2.1
fn test_born_today() raises:
    assert_equal(format_age("2025-06-15", "2025-06-15"), "Newborn")


# 2.2
fn test_born_1_day_ago_singular() raises:
    assert_equal(format_age("2025-06-14", "2025-06-15"), "1 day")


# 2.3
fn test_born_3_days_ago() raises:
    assert_equal(format_age("2025-06-12", "2025-06-15"), "3 days")


# 2.4
fn test_born_6_days_ago() raises:
    assert_equal(format_age("2025-06-09", "2025-06-15"), "6 days")


# 2.5
fn test_never_shows_7_plus_days() raises:
    assert_equal(format_age("2025-06-08", "2025-06-15"), "1 week")


# ================================================================
# Weeks+days tier: 7 days to <3 calendar months
# ================================================================


# 3.1
fn test_7_days() raises:
    assert_equal(format_age("2025-06-08", "2025-06-15"), "1 week")


# 3.2
fn test_8_days() raises:
    assert_equal(format_age("2025-06-07", "2025-06-15"), "1 week, 1 day")


# 3.3
fn test_9_days() raises:
    assert_equal(format_age("2025-06-06", "2025-06-15"), "1 week, 2 days")


# 3.4
fn test_13_days() raises:
    assert_equal(format_age("2025-06-02", "2025-06-15"), "1 week, 6 days")


# 3.5
fn test_14_days() raises:
    assert_equal(format_age("2025-06-01", "2025-06-15"), "2 weeks")


# 3.6
fn test_15_days() raises:
    assert_equal(format_age("2025-05-31", "2025-06-15"), "2 weeks, 1 day")


# 3.7
fn test_20_days() raises:
    assert_equal(format_age("2025-05-26", "2025-06-15"), "2 weeks, 6 days")


# 3.8
fn test_21_days() raises:
    assert_equal(format_age("2025-05-25", "2025-06-15"), "3 weeks")


# 3.9
fn test_at_1_calendar_month_still_shows_weeks_days() raises:
    assert_equal(format_age("2025-05-15", "2025-06-15"), "4 weeks, 3 days")


# 3.10
fn test_at_2_calendar_months_still_shows_weeks_days() raises:
    assert_equal(format_age("2025-04-15", "2025-06-15"), "8 weeks, 5 days")


# 3.11
fn test_one_day_before_3_month_birthday() raises:
    assert_equal(format_age("2025-03-15", "2025-06-14"), "13 weeks")


# 3.12
fn test_on_3_month_birthday_switches_to_months() raises:
    assert_equal(format_age("2025-03-15", "2025-06-15"), "3 months")


# ================================================================
# Month boundaries -- the hard part
# ================================================================


# 4.1
fn test_born_jan1_check_apr1() raises:
    assert_equal(format_age("2025-01-01", "2025-04-01"), "3 months")


# 4.2
fn test_born_jan1_check_mar31_still_weeks() raises:
    var result = format_age("2025-01-01", "2025-03-31")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 4.3
fn test_born_jun15_check_sep15() raises:
    assert_equal(format_age("2025-06-15", "2025-09-15"), "3 months")


# 4.4
fn test_born_jun15_check_sep14_still_weeks() raises:
    var result = format_age("2025-06-15", "2025-09-14")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 4.5
fn test_born_jun15_check_dec15() raises:
    assert_equal(format_age("2025-06-15", "2025-12-15"), "6 months")


# ================================================================
# February non-leap boundaries
# ================================================================


# 5.1
fn test_born_jan31_check_feb28_nonleap() raises:
    assert_equal(format_age("2025-01-31", "2025-02-28"), "4 weeks")


# 5.2
fn test_born_jan31_check_apr30() raises:
    assert_equal(format_age("2025-01-31", "2025-04-30"), "3 months")


# 5.3
fn test_born_jan31_check_apr29_still_weeks() raises:
    var result = format_age("2025-01-31", "2025-04-29")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 5.4
fn test_born_feb1_check_may1() raises:
    assert_equal(format_age("2025-02-01", "2025-05-01"), "3 months")


# 5.5
fn test_born_feb1_check_apr30_still_weeks() raises:
    var result = format_age("2025-02-01", "2025-04-30")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# ================================================================
# February leap boundaries
# ================================================================


# 6.1
fn test_born_jan31_check_feb29_leap() raises:
    assert_equal(format_age("2024-01-31", "2024-02-29"), "4 weeks, 1 day")


# 6.2
fn test_born_jan31_check_feb28_leap() raises:
    assert_equal(format_age("2024-01-31", "2024-02-28"), "4 weeks")


# 6.3
fn test_born_jan31_check_apr30_leap() raises:
    assert_equal(format_age("2024-01-31", "2024-04-30"), "3 months")


# 6.4
fn test_born_jan30_check_feb29_leap_still_weeks() raises:
    var result = format_age("2024-01-30", "2024-02-29")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 6.5
fn test_born_jan30_check_feb28_leap_still_weeks() raises:
    var result = format_age("2024-01-30", "2024-02-28")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# ================================================================
# 30-day month boundaries
# ================================================================


# 7.1
fn test_born_mar31_check_jun30() raises:
    assert_equal(format_age("2025-03-31", "2025-06-30"), "3 months")


# 7.2
fn test_born_mar31_check_jun29_still_weeks() raises:
    var result = format_age("2025-03-31", "2025-06-29")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 7.3
fn test_born_aug31_check_nov30() raises:
    assert_equal(format_age("2025-08-31", "2025-11-30"), "3 months")


# 7.4
fn test_born_aug31_check_nov29_still_weeks() raises:
    var result = format_age("2025-08-31", "2025-11-29")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# ================================================================
# Leap year baby boundaries
# ================================================================


# 8.1
fn test_born_feb29_check_may29() raises:
    assert_equal(format_age("2024-02-29", "2024-05-29"), "3 months")


# 8.2
fn test_born_feb29_check_may28_still_weeks() raises:
    var result = format_age("2024-02-29", "2024-05-28")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 8.3
fn test_born_feb29_check_feb28_nonleap() raises:
    assert_equal(format_age("2024-02-29", "2025-02-28"), "12 months")


# 8.4
fn test_born_feb29_check_mar1_next_year() raises:
    assert_equal(format_age("2024-02-29", "2025-03-01"), "12 months")


# ================================================================
# Months tier: 3-23 months
# ================================================================


# 9.1
fn test_3_months_at_transition() raises:
    assert_equal(format_age("2025-01-15", "2025-04-15"), "3 months")


# 9.2
fn test_6_months() raises:
    assert_equal(format_age("2025-01-15", "2025-07-15"), "6 months")


# 9.3
fn test_12_months_not_1_year() raises:
    assert_equal(format_age("2024-06-15", "2025-06-15"), "12 months")


# 9.4
fn test_23_months_upper_boundary() raises:
    assert_equal(format_age("2024-01-15", "2025-12-15"), "23 months")


# 9.5
fn test_one_day_before_month_boundary() raises:
    assert_equal(format_age("2025-01-15", "2025-07-14"), "5 months")


# 9.6
fn test_crossing_year_boundary() raises:
    assert_equal(format_age("2024-11-10", "2025-04-10"), "5 months")


# ================================================================
# Years+months tier: 24-35 months
# ================================================================


# 10.1
fn test_2_years_at_24_months() raises:
    assert_equal(format_age("2023-06-15", "2025-06-15"), "2 years")


# 10.2
fn test_2_years_1_month_singular() raises:
    assert_equal(format_age("2023-06-15", "2025-07-15"), "2 years, 1 month")


# 10.3
fn test_2_years_6_months() raises:
    assert_equal(format_age("2023-06-15", "2025-12-15"), "2 years, 6 months")


# 10.4
fn test_2_years_11_months_upper_boundary() raises:
    assert_equal(format_age("2023-06-15", "2026-05-15"), "2 years, 11 months")


# 10.5
fn test_one_day_before_24_months_stays_in_months() raises:
    assert_equal(format_age("2023-06-15", "2025-06-14"), "23 months")


# ================================================================
# Half-year tier: 3-6 years
# ================================================================


# 11.1
fn test_3_years_exact() raises:
    assert_equal(format_age("2022-06-15", "2025-06-15"), "3 years")


# 11.2
fn test_3_years_5_months() raises:
    assert_equal(format_age("2022-06-15", "2025-11-15"), "3 years")


# 11.3
fn test_3_and_half_years() raises:
    assert_equal(format_age("2022-06-15", "2025-12-15"), String("3\xc2\xbd years"))


# 11.4
fn test_3_years_11_months() raises:
    assert_equal(format_age("2022-06-15", "2026-05-15"), String("3\xc2\xbd years"))


# 11.5
fn test_4_years_exact() raises:
    assert_equal(format_age("2021-06-15", "2025-06-15"), "4 years")


# 11.6
fn test_4_and_half_years() raises:
    assert_equal(format_age("2021-06-15", "2025-12-15"), String("4\xc2\xbd years"))


# 11.7
fn test_5_years_exact() raises:
    assert_equal(format_age("2020-06-15", "2025-06-15"), "5 years")


# 11.8
fn test_5_and_half_years() raises:
    assert_equal(format_age("2020-06-15", "2026-02-15"), String("5\xc2\xbd years"))


# 11.9
fn test_6_years_exact() raises:
    assert_equal(format_age("2019-06-15", "2025-06-15"), "6 years")


# 11.10
fn test_6_and_half_years() raises:
    assert_equal(format_age("2019-06-15", "2025-12-15"), String("6\xc2\xbd years"))


# 11.11
fn test_6_years_11_months() raises:
    assert_equal(format_age("2019-06-15", "2026-05-15"), String("6\xc2\xbd years"))


# 11.12
fn test_one_day_before_3rd_birthday() raises:
    assert_equal(format_age("2022-06-15", "2025-06-14"), "2 years, 11 months")


# ================================================================
# Integer tier: 7+ years
# ================================================================


# 12.1
fn test_7_years_exact() raises:
    assert_equal(format_age("2018-06-15", "2025-06-15"), "7 years")


# 12.2
fn test_7_years_6_months_no_half() raises:
    assert_equal(format_age("2018-03-20", "2025-06-15"), "7 years")


# 12.3
fn test_45_years_adult() raises:
    assert_equal(format_age("1980-01-01", "2025-06-15"), "45 years")


# ================================================================
# Cross-year transitions with short months
# ================================================================


# 13.1
fn test_born_dec31_check_mar31() raises:
    assert_equal(format_age("2024-12-31", "2025-03-31"), "3 months")


# 13.2
fn test_born_dec31_check_mar30_still_weeks() raises:
    var result = format_age("2024-12-31", "2025-03-30")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# 13.3
fn test_born_nov30_check_feb28() raises:
    assert_equal(format_age("2024-11-30", "2025-02-28"), "3 months")


# 13.4
fn test_born_nov30_check_feb27_still_weeks() raises:
    var result = format_age("2024-11-30", "2025-02-27")
    assert_true(len(result) > 0 and result.find("weeks") != -1)


# ================================================================
# Born on 31st progression
# ================================================================


# 14.1
fn test_jan31_to_apr30() raises:
    assert_equal(format_age("2025-01-31", "2025-04-30"), "3 months")


# 14.2
fn test_jan31_to_may31() raises:
    assert_equal(format_age("2025-01-31", "2025-05-31"), "4 months")


# 14.3
fn test_jan31_to_jun30_clamped() raises:
    assert_equal(format_age("2025-01-31", "2025-06-30"), "5 months")


# 14.4
fn test_jan31_to_jul1_before_birthday() raises:
    assert_equal(format_age("2025-01-31", "2025-07-01"), "5 months")


# 14.5
fn test_jan31_to_jul31() raises:
    assert_equal(format_age("2025-01-31", "2025-07-31"), "6 months")


# ================================================================
# format_stage
# ================================================================


# 16.3
fn test_stage_returns_empty_for_empty_string() raises:
    assert_equal(format_stage("", "2025-06-15"), "")


# 16.4
fn test_stage_returns_empty_for_future_dob() raises:
    assert_equal(format_stage("2025-07-01", "2025-06-15"), "")


# 16.5
fn test_stage_exactly_500_years_returns_adult() raises:
    assert_equal(format_stage("1525-06-15", "2025-06-15"), "Adult")


# 16.6
fn test_stage_501_years_exceeds_max_age() raises:
    assert_equal(format_stage("1524-06-15", "2025-06-15"), "")


# 17.1
fn test_stage_born_today() raises:
    assert_equal(format_stage("2025-06-15", "2025-06-15"), "Newborn")


# 17.2
fn test_stage_1_day_old() raises:
    assert_equal(format_stage("2025-06-14", "2025-06-15"), "Newborn")


# 17.3
fn test_stage_3_weeks_old() raises:
    assert_equal(format_stage("2025-05-25", "2025-06-15"), "Newborn")


# 17.4
fn test_stage_1_month_old() raises:
    assert_equal(format_stage("2025-05-15", "2025-06-15"), "Newborn")


# 17.5
fn test_stage_1_month_29_days_still_newborn() raises:
    assert_equal(format_stage("2025-04-16", "2025-06-15"), "Newborn")


# 17.6
fn test_stage_exactly_2_months_becomes_infant() raises:
    assert_equal(format_stage("2025-04-15", "2025-06-15"), "Infant")


# 18.1
fn test_stage_2_months() raises:
    assert_equal(format_stage("2025-04-15", "2025-06-15"), "Infant")


# 18.2
fn test_stage_6_months() raises:
    assert_equal(format_stage("2024-12-15", "2025-06-15"), "Infant")


# 18.3
fn test_stage_11_months() raises:
    assert_equal(format_stage("2024-07-15", "2025-06-15"), "Infant")


# 18.4
fn test_stage_exactly_12_months_becomes_toddler() raises:
    assert_equal(format_stage("2024-06-15", "2025-06-15"), "Toddler")


# 19.1
fn test_stage_12_months() raises:
    assert_equal(format_stage("2024-06-15", "2025-06-15"), "Toddler")


# 19.2
fn test_stage_18_months() raises:
    assert_equal(format_stage("2024-01-15", "2025-07-15"), "Toddler")


# 19.3
fn test_stage_24_months() raises:
    assert_equal(format_stage("2023-06-15", "2025-06-15"), "Toddler")


# 19.4
fn test_stage_35_months_still_toddler() raises:
    assert_equal(format_stage("2023-06-15", "2026-05-15"), "Toddler")


# 19.5
fn test_stage_exactly_36_months_becomes_child() raises:
    assert_equal(format_stage("2022-06-15", "2025-06-15"), "Child")


# 20.1
fn test_stage_3_years() raises:
    assert_equal(format_stage("2022-06-15", "2025-06-15"), "Child")


# 20.2
fn test_stage_4_years() raises:
    assert_equal(format_stage("2021-06-15", "2025-06-15"), "Child")


# 20.3
fn test_stage_6_years() raises:
    assert_equal(format_stage("2019-06-15", "2025-06-15"), "Child")


# 20.4
fn test_stage_9_years() raises:
    assert_equal(format_stage("2016-06-15", "2025-06-15"), "Child")


# 20.5
fn test_stage_12_years_11_months_still_child() raises:
    assert_equal(format_stage("2013-06-15", "2026-05-15"), "Child")


# 20.6
fn test_stage_exactly_13_years_becomes_teenager() raises:
    assert_equal(format_stage("2012-06-15", "2025-06-15"), "Teenager")


# 21.1
fn test_stage_13_years() raises:
    assert_equal(format_stage("2012-06-15", "2025-06-15"), "Teenager")


# 21.2
fn test_stage_15_years() raises:
    assert_equal(format_stage("2010-06-15", "2025-06-15"), "Teenager")


# 21.3
fn test_stage_17_years_11_months_still_teenager() raises:
    assert_equal(format_stage("2008-06-15", "2026-05-15"), "Teenager")


# 21.4
fn test_stage_exactly_18_years_becomes_adult() raises:
    assert_equal(format_stage("2007-06-15", "2025-06-15"), "Adult")


# 22.1
fn test_stage_18_years() raises:
    assert_equal(format_stage("2007-06-15", "2025-06-15"), "Adult")


# 22.2
fn test_stage_25_years() raises:
    assert_equal(format_stage("2000-06-15", "2025-06-15"), "Adult")


# 22.3
fn test_stage_45_years() raises:
    assert_equal(format_stage("1980-01-01", "2025-06-15"), "Adult")


# ================================================================
# SayableAge class
# ================================================================


# 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
fn test_sayable_age_format_age_delegates() raises:
    var sa = SayableAge(build_en())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Newborn")
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 days")
    assert_equal(sa.format_age("2025-06-07", "2025-06-15"), "1 week, 1 day")
    assert_equal(sa.format_age("2025-01-15", "2025-07-15"), "6 months")
    assert_equal(sa.format_age("2023-06-15", "2025-07-15"), "2 years, 1 month")
    assert_equal(sa.format_age("2022-06-15", "2025-12-15"), String("3\xc2\xbd years"))
    assert_equal(sa.format_age("2018-06-15", "2025-06-15"), "7 years")


# 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
fn test_sayable_age_format_stage_delegates() raises:
    var sa = SayableAge(build_en())
    assert_equal(sa.format_stage("2025-06-15", "2025-06-15"), "Newborn")
    assert_equal(sa.format_stage("2025-01-15", "2025-06-15"), "Infant")
    assert_equal(sa.format_stage("2024-06-15", "2025-06-15"), "Toddler")
    assert_equal(sa.format_stage("2022-06-15", "2025-06-15"), "Child")
    assert_equal(sa.format_stage("2012-06-15", "2025-06-15"), "Teenager")
    assert_equal(sa.format_stage("2007-06-15", "2025-06-15"), "Adult")


# 24.14, 24.15
fn test_sayable_age_returns_empty_for_invalid() raises:
    var sa = SayableAge(build_en())
    assert_equal(sa.format_age("", "2025-06-15"), "")
    assert_equal(sa.format_stage("", "2025-06-15"), "")


# ================================================================
# SayableAge with Spanish locale
# ================================================================


fn _build_mock_es() -> AgeLocale:
    """Build a mock Spanish locale for tests (matching test expectations)."""
    fn plural(n: Int) -> String:
        if n == 1:
            return "one"
        return "other"

    var units = Dict[String, UnitForms]()
    units["day"] = plural_unit(
        List[Tuple[String, String]](("one", "{n} d\xc3\xada"), ("other", "{n} d\xc3\xadas"))
    )
    units["week"] = plural_unit(
        List[Tuple[String, String]](("one", "{n} semana"), ("other", "{n} semanas"))
    )
    units["month"] = plural_unit(
        List[Tuple[String, String]](("one", "{n} mes"), ("other", "{n} meses"))
    )
    units["year"] = plural_unit(
        List[Tuple[String, String]](("one", "{n} a\xc3\xb1o"), ("other", "{n} a\xc3\xb1os"))
    )

    var stages = Dict[String, StageLabel]()
    stages["newborn"] = stage_neutral("Reci\xc3\xa9n nacido")
    stages["infant"] = stage_neutral("Beb\xc3\xa9")
    stages["toddler"] = stage_neutral("Ni\xc3\xb1o peque\xc3\xb1o")
    stages["child"] = stage_neutral("Ni\xc3\xb1o")
    stages["teenager"] = stage_neutral("Adolescente")
    stages["adult"] = stage_neutral("Adulto")

    return AgeLocale(
        code="es",
        plural_fn=plural,
        units=units,
        half="{n} y medio",
        delimiter=", ",
        just_born="Reci\xc3\xa9n nacido",
        stages=stages,
    )


# 25.1
fn test_es_just_born_label() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Reci\xc3\xa9n nacido")


# 25.2
fn test_es_singular_day() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-06-14", "2025-06-15"), "1 d\xc3\xada")


# 25.3
fn test_es_plural_days() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 d\xc3\xadas")


# 25.4
fn test_es_singular_week() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-06-08", "2025-06-15"), "1 semana")


# 25.5
fn test_es_compound_weeks_days() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-06-07", "2025-06-15"), "1 semana, 1 d\xc3\xada")


# 25.6
fn test_es_plural_weeks_plural_days() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-05-26", "2025-06-15"), "2 semanas, 6 d\xc3\xadas")


# 25.7
fn test_es_months() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2025-01-15", "2025-07-15"), "6 meses")


# 25.8
fn test_es_singular_month_in_compound() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2023-06-15", "2025-07-15"), "2 a\xc3\xb1os, 1 mes")


# 25.9
fn test_es_years_months_compound() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2023-06-15", "2025-12-15"), "2 a\xc3\xb1os, 6 meses")


# 25.10
fn test_es_half_marker() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2022-06-15", "2025-12-15"), "3 y medio a\xc3\xb1os")


# 25.11
fn test_es_integer_years() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2022-06-15", "2025-06-15"), "3 a\xc3\xb1os")


# 25.12
fn test_es_7_plus_years() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("2018-06-15", "2025-06-15"), "7 a\xc3\xb1os")


# 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
fn test_es_stage_labels() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_stage("2025-06-15", "2025-06-15"), "Reci\xc3\xa9n nacido")
    assert_equal(sa.format_stage("2025-01-15", "2025-06-15"), "Beb\xc3\xa9")
    assert_equal(sa.format_stage("2024-06-15", "2025-06-15"), "Ni\xc3\xb1o peque\xc3\xb1o")
    assert_equal(sa.format_stage("2022-06-15", "2025-06-15"), "Ni\xc3\xb1o")
    assert_equal(sa.format_stage("2012-06-15", "2025-06-15"), "Adolescente")
    assert_equal(sa.format_stage("2007-06-15", "2025-06-15"), "Adulto")


# 25.19, 25.20
fn test_es_null_handling() raises:
    var sa = SayableAge(_build_mock_es())
    assert_equal(sa.format_age("", "2025-06-15"), "")
    assert_equal(sa.format_stage("", "2025-06-15"), "")


# ================================================================
# Compactness levels
# ================================================================


# 26.1
fn test_short_days() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 d")


# 26.2
fn test_short_weeks() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2025-06-08", "2025-06-15"), "1 wk")


# 26.3
fn test_short_weeks_days() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2025-06-07", "2025-06-15"), "1 wk, 1 d")


# 26.4
fn test_short_months() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2025-01-15", "2025-07-15"), "6 mo")


# 26.5
fn test_short_years_months() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2023-06-15", "2025-07-15"), "2 yr, 1 mo")


# 26.6
fn test_short_half_years() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2022-06-15", "2025-12-15"), String("3\xc2\xbd yr"))


# 26.7
fn test_short_integer_years() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2018-06-15", "2025-06-15"), "7 yr")


# 26.8
fn test_short_just_born_unchanged() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Newborn")


# 26.9
fn test_short_stages_unchanged() raises:
    var sa = SayableAge(build_en(), "short")
    assert_equal(sa.format_stage("2025-01-15", "2025-06-15"), "Infant")


# 27.1
fn test_compact_days() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3d")


# 27.2
fn test_compact_weeks() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2025-06-08", "2025-06-15"), "1w")


# 27.3
fn test_compact_weeks_days_no_delimiter() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2025-06-07", "2025-06-15"), "1w1d")


# 27.4
fn test_compact_months() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2025-01-15", "2025-07-15"), "6m")


# 27.5
fn test_compact_years_months_no_delimiter() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2023-06-15", "2025-07-15"), "2y1m")


# 27.6
fn test_compact_half_years() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2022-06-15", "2025-12-15"), String("3\xc2\xbdy"))


# 27.7
fn test_compact_integer_years() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2018-06-15", "2025-06-15"), "7y")


# 27.8
fn test_compact_just_born_unchanged() raises:
    var sa = SayableAge(build_en(), "compact")
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Newborn")


# ================================================================
# resolve_stage helper
# ================================================================


fn test_resolve_stage_plain_string() raises:
    assert_equal(resolve_stage(stage_neutral("Newborn")), "Newborn")


fn test_resolve_stage_gendered_default() raises:
    assert_equal(resolve_stage(stage_gendered("Adulto", "Adulta")), "Adulto")


fn test_resolve_stage_gendered_masculine() raises:
    assert_equal(resolve_stage(stage_gendered("Adulto", "Adulta"), "m"), "Adulto")


fn test_resolve_stage_gendered_feminine() raises:
    assert_equal(resolve_stage(stage_gendered("Adulto", "Adulta"), "f"), "Adulta")


# ================================================================
# Locale-specific edge cases -- Section 29
# ================================================================


# 29.1
fn test_29_1_he_just_born() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93")


# 29.2
fn test_29_2_he_one_day() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-06-14", "2025-06-15"), "\xd7\x99\xd7\x95\xd7\x9d 1")


# 29.3
fn test_29_3_he_three_days() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 \xd7\x99\xd7\x9e\xd7\x99\xd7\x9d")


# 29.4
fn test_29_4_he_two_weeks_dual() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-06-01", "2025-06-15"), "\xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x99\xd7\x99\xd7\x9d")


# 29.5
fn test_29_5_he_three_weeks() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-05-25", "2025-06-15"), "3 \xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x95\xd7\xaa")


# 29.6
fn test_29_6_he_six_months() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-01-15", "2025-07-15"), "6 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d")


# 29.7
fn test_29_7_he_three_months() raises:
    var sa = SayableAge(build_he())
    assert_equal(sa.format_age("2025-03-15", "2025-06-15"), "3 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d")


# 29.8
fn test_29_8_he_two_years_dual_one_month() raises:
    var sa = SayableAge(build_he())
    assert_equal(
        sa.format_age("2023-06-15", "2025-07-15"),
        "\xd7\xa9\xd7\xa0\xd7\xaa\xd7\x99\xd7\x99\xd7\x9d, \xd7\x97\xd7\x95\xd7\x93\xd7\xa9 1",
    )


# 29.15
fn test_29_15_mk_just_born() raises:
    var sa = SayableAge(build_mk())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "\xd0\x9d\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb4\xd0\xb5\xd0\xbd\xd1\x87\xd0\xb5")


# 29.16
fn test_29_16_mk_one_day() raises:
    var sa = SayableAge(build_mk())
    assert_equal(sa.format_age("2025-06-14", "2025-06-15"), "1 \xd0\xb4\xd0\xb5\xd0\xbd")


# 29.17
fn test_29_17_mk_three_days() raises:
    var sa = SayableAge(build_mk())
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 \xd0\xb4\xd0\xb5\xd0\xbd\xd0\xb0")


# 29.22
fn test_29_22_sw_just_born() raises:
    var sa = SayableAge(build_sw())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Mzaliwa mpya")


# 29.23
fn test_29_23_sw_one_day() raises:
    var sa = SayableAge(build_sw())
    assert_equal(sa.format_age("2025-06-14", "2025-06-15"), "siku 1")


# 29.24
fn test_29_24_sw_three_days() raises:
    var sa = SayableAge(build_sw())
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "siku 3")


# 29.28
fn test_29_28_id_just_born() raises:
    var sa = SayableAge(build_id())
    assert_equal(sa.format_age("2025-06-15", "2025-06-15"), "Baru lahir")


# 29.29
fn test_29_29_id_one_day() raises:
    var sa = SayableAge(build_id())
    assert_equal(sa.format_age("2025-06-14", "2025-06-15"), "1 hari")


# 29.30
fn test_29_30_id_three_days() raises:
    var sa = SayableAge(build_id())
    assert_equal(sa.format_age("2025-06-12", "2025-06-15"), "3 hari")


# 29.34
fn test_29_34_am_just_born() raises:
    var sa = SayableAge(build_am())
    assert_equal(
        sa.format_age("2025-06-15", "2025-06-15"),
        "\xe1\x8a\xa0\xe1\x8b\xb2\xe1\x88\xb5 \xe1\x8b\xa8\xe1\x89\xb0\xe1\x8b\x88\xe1\x88\x88\xe1\x8b\xb0",
    )


# ================================================================
# Locale lookup
# ================================================================


# 30.1
fn test_30_1_known_locale_en() raises:
    assert_true(has_locale("en"))


# 30.2
fn test_30_2_known_locale_fr() raises:
    assert_true(has_locale("fr"))


# 30.3
fn test_30_3_unknown_code() raises:
    assert_true(not has_locale("xx"))


# 30.4
fn test_30_4_empty_string() raises:
    assert_true(not has_locale(""))


# 30.5
fn test_30_5_case_sensitive() raises:
    assert_true(not has_locale("EN"))


# ================================================================
# Stage gender tests -- Arabic
# ================================================================


fn test_stage_gender_ar_newborn_masculine() raises:
    var sa = SayableAge(build_ar())
    assert_equal(
        sa.format_stage("2025-06-15", "2025-06-15"),
        "\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9",
    )


fn test_stage_gender_ar_newborn_feminine() raises:
    var sa = SayableAge(build_ar())
    assert_equal(
        sa.format_stage("2025-06-15", "2025-06-15", "f"),
        "\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab\xd8\xa9 \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9",
    )


fn test_stage_gender_ar_adult_masculine() raises:
    var sa = SayableAge(build_ar())
    assert_equal(sa.format_stage("2007-06-15", "2025-06-15"), "\xd8\xa8\xd8\xa7\xd9\x84\xd8\xba")


fn test_stage_gender_ar_adult_feminine() raises:
    var sa = SayableAge(build_ar())
    assert_equal(
        sa.format_stage("2007-06-15", "2025-06-15", "f"),
        "\xd8\xa8\xd8\xa7\xd9\x84\xd8\xba\xd8\xa9",
    )


# ================================================================
# English ignores gender
# ================================================================


fn test_stage_gender_en_ignores_gender_f() raises:
    var sa = SayableAge(build_en())
    assert_equal(sa.format_stage("2025-06-15", "2025-06-15", "f"), "Newborn")
    assert_equal(sa.format_stage("2007-06-15", "2025-06-15", "f"), "Adult")


fn test_stage_gender_en_ignores_gender_m() raises:
    var sa = SayableAge(build_en())
    assert_equal(sa.format_stage("2025-06-15", "2025-06-15", "m"), "Newborn")
    assert_equal(sa.format_stage("2007-06-15", "2025-06-15", "m"), "Adult")


# ================================================================
# Version constant
# ================================================================


fn test_version() raises:
    assert_equal(VERSION, "0.5.0")


# ================================================================
# Main test runner
# ================================================================


fn main() raises:
    # Null / edge cases
    test_returns_empty_for_empty_string()
    test_returns_empty_for_future_date_of_birth()
    test_exactly_500_years_is_allowed()
    test_501_years_exceeds_max_age()
    test_1000_years_exceeds_max_age()

    # Days tier
    test_born_today()
    test_born_1_day_ago_singular()
    test_born_3_days_ago()
    test_born_6_days_ago()
    test_never_shows_7_plus_days()

    # Weeks+days tier
    test_7_days()
    test_8_days()
    test_9_days()
    test_13_days()
    test_14_days()
    test_15_days()
    test_20_days()
    test_21_days()
    test_at_1_calendar_month_still_shows_weeks_days()
    test_at_2_calendar_months_still_shows_weeks_days()
    test_one_day_before_3_month_birthday()
    test_on_3_month_birthday_switches_to_months()

    # Month boundaries
    test_born_jan1_check_apr1()
    test_born_jan1_check_mar31_still_weeks()
    test_born_jun15_check_sep15()
    test_born_jun15_check_sep14_still_weeks()
    test_born_jun15_check_dec15()

    # Feb non-leap
    test_born_jan31_check_feb28_nonleap()
    test_born_jan31_check_apr30()
    test_born_jan31_check_apr29_still_weeks()
    test_born_feb1_check_may1()
    test_born_feb1_check_apr30_still_weeks()

    # Feb leap
    test_born_jan31_check_feb29_leap()
    test_born_jan31_check_feb28_leap()
    test_born_jan31_check_apr30_leap()
    test_born_jan30_check_feb29_leap_still_weeks()
    test_born_jan30_check_feb28_leap_still_weeks()

    # 30-day months
    test_born_mar31_check_jun30()
    test_born_mar31_check_jun29_still_weeks()
    test_born_aug31_check_nov30()
    test_born_aug31_check_nov29_still_weeks()

    # Leap year baby
    test_born_feb29_check_may29()
    test_born_feb29_check_may28_still_weeks()
    test_born_feb29_check_feb28_nonleap()
    test_born_feb29_check_mar1_next_year()

    # Months tier
    test_3_months_at_transition()
    test_6_months()
    test_12_months_not_1_year()
    test_23_months_upper_boundary()
    test_one_day_before_month_boundary()
    test_crossing_year_boundary()

    # Years+months tier
    test_2_years_at_24_months()
    test_2_years_1_month_singular()
    test_2_years_6_months()
    test_2_years_11_months_upper_boundary()
    test_one_day_before_24_months_stays_in_months()

    # Half-year tier
    test_3_years_exact()
    test_3_years_5_months()
    test_3_and_half_years()
    test_3_years_11_months()
    test_4_years_exact()
    test_4_and_half_years()
    test_5_years_exact()
    test_5_and_half_years()
    test_6_years_exact()
    test_6_and_half_years()
    test_6_years_11_months()
    test_one_day_before_3rd_birthday()

    # Integer tier
    test_7_years_exact()
    test_7_years_6_months_no_half()
    test_45_years_adult()

    # Cross-year
    test_born_dec31_check_mar31()
    test_born_dec31_check_mar30_still_weeks()
    test_born_nov30_check_feb28()
    test_born_nov30_check_feb27_still_weeks()

    # Born on 31st progression
    test_jan31_to_apr30()
    test_jan31_to_may31()
    test_jan31_to_jun30_clamped()
    test_jan31_to_jul1_before_birthday()
    test_jan31_to_jul31()

    # format_stage
    test_stage_returns_empty_for_empty_string()
    test_stage_returns_empty_for_future_dob()
    test_stage_exactly_500_years_returns_adult()
    test_stage_501_years_exceeds_max_age()
    test_stage_born_today()
    test_stage_1_day_old()
    test_stage_3_weeks_old()
    test_stage_1_month_old()
    test_stage_1_month_29_days_still_newborn()
    test_stage_exactly_2_months_becomes_infant()
    test_stage_2_months()
    test_stage_6_months()
    test_stage_11_months()
    test_stage_exactly_12_months_becomes_toddler()
    test_stage_12_months()
    test_stage_18_months()
    test_stage_24_months()
    test_stage_35_months_still_toddler()
    test_stage_exactly_36_months_becomes_child()
    test_stage_3_years()
    test_stage_4_years()
    test_stage_6_years()
    test_stage_9_years()
    test_stage_12_years_11_months_still_child()
    test_stage_exactly_13_years_becomes_teenager()
    test_stage_13_years()
    test_stage_15_years()
    test_stage_17_years_11_months_still_teenager()
    test_stage_exactly_18_years_becomes_adult()
    test_stage_18_years()
    test_stage_25_years()
    test_stage_45_years()

    # SayableAge class
    test_sayable_age_format_age_delegates()
    test_sayable_age_format_stage_delegates()
    test_sayable_age_returns_empty_for_invalid()

    # Spanish locale
    test_es_just_born_label()
    test_es_singular_day()
    test_es_plural_days()
    test_es_singular_week()
    test_es_compound_weeks_days()
    test_es_plural_weeks_plural_days()
    test_es_months()
    test_es_singular_month_in_compound()
    test_es_years_months_compound()
    test_es_half_marker()
    test_es_integer_years()
    test_es_7_plus_years()
    test_es_stage_labels()
    test_es_null_handling()

    # Compactness
    test_short_days()
    test_short_weeks()
    test_short_weeks_days()
    test_short_months()
    test_short_years_months()
    test_short_half_years()
    test_short_integer_years()
    test_short_just_born_unchanged()
    test_short_stages_unchanged()
    test_compact_days()
    test_compact_weeks()
    test_compact_weeks_days_no_delimiter()
    test_compact_months()
    test_compact_years_months_no_delimiter()
    test_compact_half_years()
    test_compact_integer_years()
    test_compact_just_born_unchanged()

    # resolve_stage
    test_resolve_stage_plain_string()
    test_resolve_stage_gendered_default()
    test_resolve_stage_gendered_masculine()
    test_resolve_stage_gendered_feminine()

    # Locale-specific
    test_29_1_he_just_born()
    test_29_2_he_one_day()
    test_29_3_he_three_days()
    test_29_4_he_two_weeks_dual()
    test_29_5_he_three_weeks()
    test_29_6_he_six_months()
    test_29_7_he_three_months()
    test_29_8_he_two_years_dual_one_month()
    test_29_15_mk_just_born()
    test_29_16_mk_one_day()
    test_29_17_mk_three_days()
    test_29_22_sw_just_born()
    test_29_23_sw_one_day()
    test_29_24_sw_three_days()
    test_29_28_id_just_born()
    test_29_29_id_one_day()
    test_29_30_id_three_days()
    test_29_34_am_just_born()

    # Locale lookup
    test_30_1_known_locale_en()
    test_30_2_known_locale_fr()
    test_30_3_unknown_code()
    test_30_4_empty_string()
    test_30_5_case_sensitive()

    # Stage gender
    test_stage_gender_ar_newborn_masculine()
    test_stage_gender_ar_newborn_feminine()
    test_stage_gender_ar_adult_masculine()
    test_stage_gender_ar_adult_feminine()
    test_stage_gender_en_ignores_gender_f()
    test_stage_gender_en_ignores_gender_m()

    # Version
    test_version()

    print("All tests passed!")
