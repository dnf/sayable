"""Tests for format_age and format_stage — mirrors the TypeScript test suite."""

from __future__ import annotations

from datetime import date
from unittest.mock import patch

from importlib import import_module

from parent_time import EN, AgeLocale, ParentTime, format_age, format_stage, get_locale, resolve_stage

_format_age_mod = import_module("parent_time.format_age")
from parent_time.locales import AM, AR, ES, HE, ID, MK, SW


# ================================================================
# Null / edge cases
# ================================================================
class TestEdgeCases:
    # 1.1
    def test_returns_none_for_none_input(self) -> None:
        assert format_age(None, "2025-06-15") is None

    # 1.4
    def test_returns_none_for_future_date_of_birth(self) -> None:
        assert format_age("2025-07-01", "2025-06-15") is None

    # 1.3
    def test_returns_none_for_empty_string(self) -> None:
        assert format_age("", "2025-06-15") is None

    # 1.5
    def test_exactly_500_years_is_allowed(self) -> None:
        assert format_age("1525-06-15", "2025-06-15") == "500 years"

    # 1.6
    def test_501_years_exceeds_max_age(self) -> None:
        assert format_age("1524-06-15", "2025-06-15") is None

    # 1.7
    def test_1000_years_exceeds_max_age(self) -> None:
        assert format_age("1025-06-15", "2025-06-15") is None


# ================================================================
# Days tier: 0–6 days
# ================================================================
class TestDaysTier:
    # 2.1
    def test_born_today(self) -> None:
        assert format_age("2025-06-15", "2025-06-15") == "Newborn"

    # 2.2
    def test_born_1_day_ago_singular(self) -> None:
        assert format_age("2025-06-14", "2025-06-15") == "1 day"

    # 2.3
    def test_born_3_days_ago(self) -> None:
        assert format_age("2025-06-12", "2025-06-15") == "3 days"

    # 2.4
    def test_born_6_days_ago(self) -> None:
        assert format_age("2025-06-09", "2025-06-15") == "6 days"

    # 2.5
    def test_never_shows_7_plus_days(self) -> None:
        assert format_age("2025-06-08", "2025-06-15") == "1 week"


# ================================================================
# Weeks+days tier: 7 days to <3 calendar months
# ================================================================
class TestWeeksDaysTier:
    # 3.1
    def test_7_days(self) -> None:
        assert format_age("2025-06-08", "2025-06-15") == "1 week"

    # 3.2
    def test_8_days(self) -> None:
        assert format_age("2025-06-07", "2025-06-15") == "1 week, 1 day"

    # 3.3
    def test_9_days(self) -> None:
        assert format_age("2025-06-06", "2025-06-15") == "1 week, 2 days"

    # 3.4
    def test_13_days(self) -> None:
        assert format_age("2025-06-02", "2025-06-15") == "1 week, 6 days"

    # 3.5
    def test_14_days(self) -> None:
        assert format_age("2025-06-01", "2025-06-15") == "2 weeks"

    # 3.6
    def test_15_days(self) -> None:
        assert format_age("2025-05-31", "2025-06-15") == "2 weeks, 1 day"

    # 3.7
    def test_20_days(self) -> None:
        assert format_age("2025-05-26", "2025-06-15") == "2 weeks, 6 days"

    # 3.8
    def test_21_days(self) -> None:
        assert format_age("2025-05-25", "2025-06-15") == "3 weeks"

    # 3.9
    def test_at_1_calendar_month_still_shows_weeks_days(self) -> None:
        assert format_age("2025-05-15", "2025-06-15") == "4 weeks, 3 days"

    # 3.10
    def test_at_2_calendar_months_still_shows_weeks_days(self) -> None:
        assert format_age("2025-04-15", "2025-06-15") == "8 weeks, 5 days"

    # 3.11
    def test_one_day_before_3_month_birthday(self) -> None:
        assert format_age("2025-03-15", "2025-06-14") == "13 weeks"

    # 3.12
    def test_on_3_month_birthday_switches_to_months(self) -> None:
        assert format_age("2025-03-15", "2025-06-15") == "3 months"


# ================================================================
# Month boundaries — the hard part
# ================================================================
class TestMonthBoundaryStandard:
    # 4.1
    def test_born_jan1_check_apr1(self) -> None:
        assert format_age("2025-01-01", "2025-04-01") == "3 months"

    # 4.2
    def test_born_jan1_check_mar31_still_weeks(self) -> None:
        result = format_age("2025-01-01", "2025-03-31")
        assert result is not None and "weeks" in result

    # 4.3
    def test_born_jun15_check_sep15(self) -> None:
        assert format_age("2025-06-15", "2025-09-15") == "3 months"

    # 4.4
    def test_born_jun15_check_sep14_still_weeks(self) -> None:
        result = format_age("2025-06-15", "2025-09-14")
        assert result is not None and "weeks" in result

    # 4.5
    def test_born_jun15_check_dec15(self) -> None:
        assert format_age("2025-06-15", "2025-12-15") == "6 months"


class TestMonthBoundaryFebNonLeap:
    # 5.1
    def test_born_jan31_check_feb28_nonleap(self) -> None:
        assert format_age("2025-01-31", "2025-02-28") == "4 weeks"

    # 5.2
    def test_born_jan31_check_apr30(self) -> None:
        assert format_age("2025-01-31", "2025-04-30") == "3 months"

    # 5.3
    def test_born_jan31_check_apr29_still_weeks(self) -> None:
        result = format_age("2025-01-31", "2025-04-29")
        assert result is not None and "weeks" in result

    # 5.4
    def test_born_feb1_check_may1(self) -> None:
        assert format_age("2025-02-01", "2025-05-01") == "3 months"

    # 5.5
    def test_born_feb1_check_apr30_still_weeks(self) -> None:
        result = format_age("2025-02-01", "2025-04-30")
        assert result is not None and "weeks" in result


class TestMonthBoundaryFebLeap:
    # 6.1
    def test_born_jan31_check_feb29_leap(self) -> None:
        assert format_age("2024-01-31", "2024-02-29") == "4 weeks, 1 day"

    # 6.2
    def test_born_jan31_check_feb28_leap(self) -> None:
        assert format_age("2024-01-31", "2024-02-28") == "4 weeks"

    # 6.3
    def test_born_jan31_check_apr30_leap(self) -> None:
        assert format_age("2024-01-31", "2024-04-30") == "3 months"

    # 6.4
    def test_born_jan30_check_feb29_leap_still_weeks(self) -> None:
        result = format_age("2024-01-30", "2024-02-29")
        assert result is not None and "weeks" in result

    # 6.5
    def test_born_jan30_check_feb28_leap_still_weeks(self) -> None:
        result = format_age("2024-01-30", "2024-02-28")
        assert result is not None and "weeks" in result


class TestMonthBoundary30DayMonths:
    # 7.1
    def test_born_mar31_check_jun30(self) -> None:
        assert format_age("2025-03-31", "2025-06-30") == "3 months"

    # 7.2
    def test_born_mar31_check_jun29_still_weeks(self) -> None:
        result = format_age("2025-03-31", "2025-06-29")
        assert result is not None and "weeks" in result

    # 7.3
    def test_born_aug31_check_nov30(self) -> None:
        assert format_age("2025-08-31", "2025-11-30") == "3 months"

    # 7.4
    def test_born_aug31_check_nov29_still_weeks(self) -> None:
        result = format_age("2025-08-31", "2025-11-29")
        assert result is not None and "weeks" in result


class TestMonthBoundaryLeapYearBaby:
    # 8.1
    def test_born_feb29_check_may29(self) -> None:
        assert format_age("2024-02-29", "2024-05-29") == "3 months"

    # 8.2
    def test_born_feb29_check_may28_still_weeks(self) -> None:
        result = format_age("2024-02-29", "2024-05-28")
        assert result is not None and "weeks" in result

    # 8.3
    def test_born_feb29_check_feb28_nonleap(self) -> None:
        assert format_age("2024-02-29", "2025-02-28") == "12 months"

    # 8.4
    def test_born_feb29_check_mar1_next_year(self) -> None:
        assert format_age("2024-02-29", "2025-03-01") == "12 months"


# ================================================================
# Months tier: 3–23 months
# ================================================================
class TestMonthsTier:
    # 9.1
    def test_3_months_at_transition(self) -> None:
        assert format_age("2025-01-15", "2025-04-15") == "3 months"

    # 9.2
    def test_6_months(self) -> None:
        assert format_age("2025-01-15", "2025-07-15") == "6 months"

    # 9.3
    def test_12_months_not_1_year(self) -> None:
        assert format_age("2024-06-15", "2025-06-15") == "12 months"

    # 9.4
    def test_23_months_upper_boundary(self) -> None:
        assert format_age("2024-01-15", "2025-12-15") == "23 months"

    # 9.5
    def test_one_day_before_month_boundary(self) -> None:
        assert format_age("2025-01-15", "2025-07-14") == "5 months"

    # 9.6
    def test_crossing_year_boundary(self) -> None:
        assert format_age("2024-11-10", "2025-04-10") == "5 months"


# ================================================================
# Years+months tier: 24–35 months
# ================================================================
class TestYearsMonthsTier:
    # 10.1
    def test_2_years_at_24_months(self) -> None:
        assert format_age("2023-06-15", "2025-06-15") == "2 years"

    # 10.2
    def test_2_years_1_month_singular(self) -> None:
        assert format_age("2023-06-15", "2025-07-15") == "2 years, 1 month"

    # 10.3
    def test_2_years_6_months(self) -> None:
        assert format_age("2023-06-15", "2025-12-15") == "2 years, 6 months"

    # 10.4
    def test_2_years_11_months_upper_boundary(self) -> None:
        assert format_age("2023-06-15", "2026-05-15") == "2 years, 11 months"

    # 10.5
    def test_one_day_before_24_months_stays_in_months(self) -> None:
        assert format_age("2023-06-15", "2025-06-14") == "23 months"


# ================================================================
# Half-year tier: 3–6 years
# ================================================================
class TestHalfYearTier:
    # 11.1
    def test_3_years_exact(self) -> None:
        assert format_age("2022-06-15", "2025-06-15") == "3 years"

    # 11.2
    def test_3_years_5_months(self) -> None:
        assert format_age("2022-06-15", "2025-11-15") == "3 years"

    # 11.3
    def test_3_and_half_years(self) -> None:
        assert format_age("2022-06-15", "2025-12-15") == "3½ years"

    # 11.4
    def test_3_years_11_months(self) -> None:
        assert format_age("2022-06-15", "2026-05-15") == "3½ years"

    # 11.5
    def test_4_years_exact(self) -> None:
        assert format_age("2021-06-15", "2025-06-15") == "4 years"

    # 11.6
    def test_4_and_half_years(self) -> None:
        assert format_age("2021-06-15", "2025-12-15") == "4½ years"

    # 11.7
    def test_5_years_exact(self) -> None:
        assert format_age("2020-06-15", "2025-06-15") == "5 years"

    # 11.8
    def test_5_and_half_years(self) -> None:
        assert format_age("2020-06-15", "2026-02-15") == "5½ years"

    # 11.9
    def test_6_years_exact(self) -> None:
        assert format_age("2019-06-15", "2025-06-15") == "6 years"

    # 11.10
    def test_6_and_half_years(self) -> None:
        assert format_age("2019-06-15", "2025-12-15") == "6½ years"

    # 11.11
    def test_6_years_11_months(self) -> None:
        assert format_age("2019-06-15", "2026-05-15") == "6½ years"

    # 11.12
    def test_one_day_before_3rd_birthday(self) -> None:
        assert format_age("2022-06-15", "2025-06-14") == "2 years, 11 months"


# ================================================================
# Integer tier: 7+ years
# ================================================================
class TestIntegerTier:
    # 12.1
    def test_7_years_exact(self) -> None:
        assert format_age("2018-06-15", "2025-06-15") == "7 years"

    # 12.2
    def test_7_years_6_months_no_half(self) -> None:
        assert format_age("2018-03-20", "2025-06-15") == "7 years"

    # 12.3
    def test_45_years_adult(self) -> None:
        assert format_age("1980-01-01", "2025-06-15") == "45 years"


# ================================================================
# Cross-year transitions with short months
# ================================================================
class TestCrossYearWithFeb:
    # 13.1
    def test_born_dec31_check_mar31(self) -> None:
        assert format_age("2024-12-31", "2025-03-31") == "3 months"

    # 13.2
    def test_born_dec31_check_mar30_still_weeks(self) -> None:
        result = format_age("2024-12-31", "2025-03-30")
        assert result is not None and "weeks" in result

    # 13.3
    def test_born_nov30_check_feb28(self) -> None:
        assert format_age("2024-11-30", "2025-02-28") == "3 months"

    # 13.4
    def test_born_nov30_check_feb27_still_weeks(self) -> None:
        result = format_age("2024-11-30", "2025-02-27")
        assert result is not None and "weeks" in result


# ================================================================
# Regression: born on 31st tracked through multiple months
# ================================================================
class TestBornOn31stProgression:
    # 14.1
    def test_jan31_to_apr30(self) -> None:
        assert format_age("2025-01-31", "2025-04-30") == "3 months"

    # 14.2
    def test_jan31_to_may31(self) -> None:
        assert format_age("2025-01-31", "2025-05-31") == "4 months"

    # 14.3
    def test_jan31_to_jun30_clamped(self) -> None:
        assert format_age("2025-01-31", "2025-06-30") == "5 months"

    # 14.4
    def test_jan31_to_jul1_before_birthday(self) -> None:
        assert format_age("2025-01-31", "2025-07-01") == "5 months"

    # 14.5
    def test_jan31_to_jul31(self) -> None:
        assert format_age("2025-01-31", "2025-07-31") == "6 months"


# ================================================================
# Default as_of (uses current date)
# ================================================================
class TestDefaultAsOf:
    # 15.1, 15.2
    def test_returns_correct_age_without_as_of(self) -> None:
        with patch.object(_format_age_mod, "date", wraps=date) as mock_date:
            mock_date.today.return_value = date(2025, 6, 15)
            assert format_age("2020-01-01") == "5 years"
            assert format_age("2025-06-10") == "5 days"


# ================================================================
# format_stage
# ================================================================


class TestStageEdgeCases:
    # 16.1
    def test_returns_none_for_none(self) -> None:
        assert format_stage(None, "2025-06-15") is None

    # 16.4
    def test_returns_none_for_future_dob(self) -> None:
        assert format_stage("2025-07-01", "2025-06-15") is None

    # 16.3
    def test_returns_none_for_empty_string(self) -> None:
        assert format_stage("", "2025-06-15") is None

    # 16.5
    def test_exactly_500_years_returns_adult(self) -> None:
        assert format_stage("1525-06-15", "2025-06-15") == "Adult"

    # 16.6
    def test_501_years_exceeds_max_age(self) -> None:
        assert format_stage("1524-06-15", "2025-06-15") is None


class TestStageNewborn:
    # 17.1
    def test_born_today(self) -> None:
        assert format_stage("2025-06-15", "2025-06-15") == "Newborn"

    # 17.2
    def test_1_day_old(self) -> None:
        assert format_stage("2025-06-14", "2025-06-15") == "Newborn"

    # 17.3
    def test_3_weeks_old(self) -> None:
        assert format_stage("2025-05-25", "2025-06-15") == "Newborn"

    # 17.4
    def test_1_month_old(self) -> None:
        assert format_stage("2025-05-15", "2025-06-15") == "Newborn"

    # 17.5
    def test_1_month_29_days_still_newborn(self) -> None:
        assert format_stage("2025-04-16", "2025-06-15") == "Newborn"

    # 17.6
    def test_exactly_2_months_becomes_infant(self) -> None:
        assert format_stage("2025-04-15", "2025-06-15") == "Infant"


class TestStageInfant:
    # 18.1
    def test_2_months(self) -> None:
        assert format_stage("2025-04-15", "2025-06-15") == "Infant"

    # 18.2
    def test_6_months(self) -> None:
        assert format_stage("2024-12-15", "2025-06-15") == "Infant"

    # 18.3
    def test_11_months(self) -> None:
        assert format_stage("2024-07-15", "2025-06-15") == "Infant"

    # 18.4
    def test_exactly_12_months_becomes_toddler(self) -> None:
        assert format_stage("2024-06-15", "2025-06-15") == "Toddler"


class TestStageToddler:
    # 19.1
    def test_12_months(self) -> None:
        assert format_stage("2024-06-15", "2025-06-15") == "Toddler"

    # 19.2
    def test_18_months(self) -> None:
        assert format_stage("2024-01-15", "2025-07-15") == "Toddler"

    # 19.3
    def test_24_months(self) -> None:
        assert format_stage("2023-06-15", "2025-06-15") == "Toddler"

    # 19.4
    def test_35_months_still_toddler(self) -> None:
        assert format_stage("2023-06-15", "2026-05-15") == "Toddler"

    # 19.5
    def test_exactly_36_months_becomes_child(self) -> None:
        assert format_stage("2022-06-15", "2025-06-15") == "Child"


class TestStageChild:
    # 20.1
    def test_3_years(self) -> None:
        assert format_stage("2022-06-15", "2025-06-15") == "Child"

    # 20.2
    def test_4_years(self) -> None:
        assert format_stage("2021-06-15", "2025-06-15") == "Child"

    # 20.3
    def test_6_years(self) -> None:
        assert format_stage("2019-06-15", "2025-06-15") == "Child"

    # 20.4
    def test_9_years(self) -> None:
        assert format_stage("2016-06-15", "2025-06-15") == "Child"

    # 20.5
    def test_12_years_11_months_still_child(self) -> None:
        assert format_stage("2013-06-15", "2026-05-15") == "Child"

    # 20.6
    def test_exactly_13_years_becomes_teenager(self) -> None:
        assert format_stage("2012-06-15", "2025-06-15") == "Teenager"


class TestStageTeenager:
    # 21.1
    def test_13_years(self) -> None:
        assert format_stage("2012-06-15", "2025-06-15") == "Teenager"

    # 21.2
    def test_15_years(self) -> None:
        assert format_stage("2010-06-15", "2025-06-15") == "Teenager"

    # 21.3
    def test_17_years_11_months_still_teenager(self) -> None:
        assert format_stage("2008-06-15", "2026-05-15") == "Teenager"

    # 21.4
    def test_exactly_18_years_becomes_adult(self) -> None:
        assert format_stage("2007-06-15", "2025-06-15") == "Adult"


class TestStageAdult:
    # 22.1
    def test_18_years(self) -> None:
        assert format_stage("2007-06-15", "2025-06-15") == "Adult"

    # 22.2
    def test_25_years(self) -> None:
        assert format_stage("2000-06-15", "2025-06-15") == "Adult"

    # 22.3
    def test_45_years(self) -> None:
        assert format_stage("1980-01-01", "2025-06-15") == "Adult"


class TestStageDefaultAsOf:
    # 23.1, 23.2, 23.3
    def test_returns_correct_stage_without_as_of(self) -> None:
        with patch.object(_format_age_mod, "date", wraps=date) as mock_date:
            mock_date.today.return_value = date(2025, 6, 15)
            assert format_stage("2025-06-15") == "Newborn"
            assert format_stage("2020-01-01") == "Child"
            assert format_stage("1980-01-01") == "Adult"


# ================================================================
# ParentTime class
# ================================================================


class TestParentTimeEnglish:
    """ParentTime with built-in English locale produces identical output."""

    # 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
    def test_format_age_delegates(self) -> None:
        pt = ParentTime(EN)
        assert pt.format_age("2025-06-15", "2025-06-15") == "Newborn"
        assert pt.format_age("2025-06-12", "2025-06-15") == "3 days"
        assert pt.format_age("2025-06-07", "2025-06-15") == "1 week, 1 day"
        assert pt.format_age("2025-01-15", "2025-07-15") == "6 months"
        assert pt.format_age("2023-06-15", "2025-07-15") == "2 years, 1 month"
        assert pt.format_age("2022-06-15", "2025-12-15") == "3½ years"
        assert pt.format_age("2018-06-15", "2025-06-15") == "7 years"

    # 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
    def test_format_stage_delegates(self) -> None:
        pt = ParentTime(EN)
        assert pt.format_stage("2025-06-15", "2025-06-15") == "Newborn"
        assert pt.format_stage("2025-01-15", "2025-06-15") == "Infant"
        assert pt.format_stage("2024-06-15", "2025-06-15") == "Toddler"
        assert pt.format_stage("2022-06-15", "2025-06-15") == "Child"
        assert pt.format_stage("2012-06-15", "2025-06-15") == "Teenager"
        assert pt.format_stage("2007-06-15", "2025-06-15") == "Adult"

    # 24.14, 24.15
    def test_returns_none_for_invalid(self) -> None:
        pt = ParentTime(EN)
        assert pt.format_age(None, "2025-06-15") is None
        assert pt.format_stage(None, "2025-06-15") is None


class TestParentTimeSpanish:
    """ParentTime with a mock Spanish-like locale."""

    ES = AgeLocale(
        code="es",
        plural=lambda n: "one" if n == 1 else "other",
        units={
            "day": {"one": "{n} día", "other": "{n} días"},
            "week": {"one": "{n} semana", "other": "{n} semanas"},
            "month": {"one": "{n} mes", "other": "{n} meses"},
            "year": {"one": "{n} año", "other": "{n} años"},
        },
        half="{n} y medio",
        delimiter=", ",
        just_born="Recién nacido",
        stages={
            "newborn": "Recién nacido",
            "infant": "Bebé",
            "toddler": "Niño pequeño",
            "child": "Niño",
            "teenager": "Adolescente",
            "adult": "Adulto",
        },
    )

    def setup_method(self) -> None:
        self.pt = ParentTime(self.ES)

    # 25.1
    def test_just_born_label(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Recién nacido"

    # 25.2
    def test_singular_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "1 día"

    # 25.3
    def test_plural_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 días"

    # 25.4
    def test_singular_week(self) -> None:
        assert self.pt.format_age("2025-06-08", "2025-06-15") == "1 semana"

    # 25.5
    def test_compound_weeks_days(self) -> None:
        assert self.pt.format_age("2025-06-07", "2025-06-15") == "1 semana, 1 día"

    # 25.6
    def test_plural_weeks_plural_days(self) -> None:
        assert self.pt.format_age("2025-05-26", "2025-06-15") == "2 semanas, 6 días"

    # 25.7
    def test_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 meses"

    # 25.8
    def test_singular_month_in_compound(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "2 años, 1 mes"

    # 25.9
    def test_years_months_compound(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-12-15") == "2 años, 6 meses"

    # 25.10
    def test_half_marker(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3 y medio años"

    # 25.11
    def test_integer_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-06-15") == "3 años"

    # 25.12
    def test_7_plus_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7 años"

    # 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
    def test_stage_labels(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15") == "Recién nacido"
        assert self.pt.format_stage("2025-01-15", "2025-06-15") == "Bebé"
        assert self.pt.format_stage("2024-06-15", "2025-06-15") == "Niño pequeño"
        assert self.pt.format_stage("2022-06-15", "2025-06-15") == "Niño"
        assert self.pt.format_stage("2012-06-15", "2025-06-15") == "Adolescente"
        assert self.pt.format_stage("2007-06-15", "2025-06-15") == "Adulto"

    # 25.19, 25.20
    def test_null_handling(self) -> None:
        assert self.pt.format_age(None, "2025-06-15") is None
        assert self.pt.format_stage(None, "2025-06-15") is None


# ================================================================
# Compactness levels
# ================================================================


class TestCompactnessShort:
    def setup_method(self) -> None:
        self.pt = ParentTime(EN, "short")

    # 26.1
    def test_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 d"

    # 26.2
    def test_weeks(self) -> None:
        assert self.pt.format_age("2025-06-08", "2025-06-15") == "1 wk"

    # 26.3
    def test_weeks_days(self) -> None:
        assert self.pt.format_age("2025-06-07", "2025-06-15") == "1 wk, 1 d"

    # 26.4
    def test_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 mo"

    # 26.5
    def test_years_months(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "2 yr, 1 mo"

    # 26.6
    def test_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3½ yr"

    # 26.7
    def test_integer_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7 yr"

    # 26.8
    def test_just_born_unchanged(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Newborn"

    # 26.9
    def test_stages_unchanged(self) -> None:
        assert self.pt.format_stage("2025-01-15", "2025-06-15") == "Infant"


class TestCompactnessCompact:
    def setup_method(self) -> None:
        self.pt = ParentTime(EN, "compact")

    # 27.1
    def test_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3d"

    # 27.2
    def test_weeks(self) -> None:
        assert self.pt.format_age("2025-06-08", "2025-06-15") == "1w"

    # 27.3
    def test_weeks_days_no_delimiter(self) -> None:
        assert self.pt.format_age("2025-06-07", "2025-06-15") == "1w1d"

    # 27.4
    def test_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6m"

    # 27.5
    def test_years_months_no_delimiter(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "2y1m"

    # 27.6
    def test_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3½y"

    # 27.7
    def test_integer_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7y"

    # 27.8
    def test_just_born_unchanged(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Newborn"


# ================================================================
# resolve_stage helper
# ================================================================


class TestResolveStage:
    def test_plain_string_returns_as_is(self) -> None:
        assert resolve_stage("Newborn") == "Newborn"

    def test_plain_string_ignores_gender(self) -> None:
        assert resolve_stage("Newborn", "f") == "Newborn"
        assert resolve_stage("Newborn", "m") == "Newborn"

    def test_gendered_dict_returns_masculine_by_default(self) -> None:
        label = {"m": "Adulto", "f": "Adulta"}
        assert resolve_stage(label) == "Adulto"

    def test_gendered_dict_returns_masculine_for_m(self) -> None:
        label = {"m": "Adulto", "f": "Adulta"}
        assert resolve_stage(label, "m") == "Adulto"

    def test_gendered_dict_returns_feminine_for_f(self) -> None:
        label = {"m": "Adulto", "f": "Adulta"}
        assert resolve_stage(label, "f") == "Adulta"

    def test_gendered_dict_returns_masculine_for_none(self) -> None:
        label = {"m": "Adulto", "f": "Adulta"}
        assert resolve_stage(label, None) == "Adulto"


# ================================================================
# format_stage with gender — Arabic (fully gendered)
# ================================================================


class TestStageGenderArabic:
    def setup_method(self) -> None:
        self.pt = ParentTime(AR)

    def test_newborn_masculine(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15") == "حديث الولادة"

    def test_newborn_feminine(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="f") == "حديثة الولادة"

    def test_infant_masculine(self) -> None:
        assert self.pt.format_stage("2025-04-15", "2025-06-15") == "رضيع"

    def test_infant_feminine(self) -> None:
        assert self.pt.format_stage("2025-04-15", "2025-06-15", gender="f") == "رضيعة"

    def test_toddler_masculine(self) -> None:
        assert self.pt.format_stage("2024-06-15", "2025-06-15") == "طفل صغير"

    def test_toddler_feminine(self) -> None:
        assert self.pt.format_stage("2024-06-15", "2025-06-15", gender="f") == "طفلة صغيرة"

    def test_child_masculine(self) -> None:
        assert self.pt.format_stage("2022-06-15", "2025-06-15") == "طفل"

    def test_child_feminine(self) -> None:
        assert self.pt.format_stage("2022-06-15", "2025-06-15", gender="f") == "طفلة"

    def test_teenager_masculine(self) -> None:
        assert self.pt.format_stage("2012-06-15", "2025-06-15") == "مراهق"

    def test_teenager_feminine(self) -> None:
        assert self.pt.format_stage("2012-06-15", "2025-06-15", gender="f") == "مراهقة"

    def test_adult_masculine(self) -> None:
        assert self.pt.format_stage("2007-06-15", "2025-06-15") == "بالغ"

    def test_adult_feminine(self) -> None:
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="f") == "بالغة"


# ================================================================
# format_stage with gender — English (no gendered stages)
# ================================================================


class TestStageGenderEnglish:
    def setup_method(self) -> None:
        self.pt = ParentTime(EN)

    def test_english_ignores_gender_f(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="f") == "Newborn"
        assert self.pt.format_stage("2024-06-15", "2025-06-15", gender="f") == "Toddler"
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="f") == "Adult"

    def test_english_ignores_gender_m(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="m") == "Newborn"
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="m") == "Adult"


# ================================================================
# format_stage with gender — Spanish (partial gendering)
# ================================================================


class TestStageGenderSpanish:
    def setup_method(self) -> None:
        self.pt = ParentTime(ES)

    def test_newborn_masculine(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15") == "Recién nacido"

    def test_newborn_feminine(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="f") == "Recién nacida"

    def test_infant_ungendered(self) -> None:
        assert self.pt.format_stage("2025-04-15", "2025-06-15") == "Bebé"
        assert self.pt.format_stage("2025-04-15", "2025-06-15", gender="f") == "Bebé"

    def test_toddler_feminine(self) -> None:
        assert self.pt.format_stage("2024-06-15", "2025-06-15", gender="f") == "Niña pequeña"

    def test_child_feminine(self) -> None:
        assert self.pt.format_stage("2022-06-15", "2025-06-15", gender="f") == "Niña"

    def test_teenager_ungendered(self) -> None:
        assert self.pt.format_stage("2012-06-15", "2025-06-15") == "Adolescente"
        assert self.pt.format_stage("2012-06-15", "2025-06-15", gender="f") == "Adolescente"

    def test_adult_feminine(self) -> None:
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="f") == "Adulta"


# ================================================================
# Module-level format_stage with gender
# ================================================================


class TestModuleLevelFormatStageGender:
    def test_module_level_format_stage_accepts_gender(self) -> None:
        # English has no gendered stages, so result is the same
        assert format_stage("2007-06-15", "2025-06-15", gender="f") == "Adult"
        assert format_stage("2007-06-15", "2025-06-15", gender="m") == "Adult"
        assert format_stage("2007-06-15", "2025-06-15") == "Adult"


# ================================================================
# Section 29: Locale-specific edge cases — new plural rules
# ================================================================


class TestLocaleHebrew:
    """Hebrew (he) — dual forms."""

    def setup_method(self) -> None:
        self.pt = ParentTime(HE)

    # 29.1
    def test_29_1_just_born(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "רק נולד"

    # 29.2
    def test_29_2_one_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "יום 1"

    # 29.3
    def test_29_3_three_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 ימים"

    # 29.4
    def test_29_4_two_weeks_dual(self) -> None:
        assert self.pt.format_age("2025-06-01", "2025-06-15") == "שבועיים"

    # 29.5
    def test_29_5_three_weeks(self) -> None:
        assert self.pt.format_age("2025-05-25", "2025-06-15") == "3 שבועות"

    # 29.6
    def test_29_6_six_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 חודשים"

    # 29.7
    def test_29_7_three_months(self) -> None:
        assert self.pt.format_age("2025-03-15", "2025-06-15") == "3 חודשים"

    # 29.8
    def test_29_8_two_years_dual_one_month(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "שנתיים, חודש 1"

    # 29.9
    def test_29_9_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3 שנים וחצי"

    # 29.10
    def test_29_10_seven_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7 שנים"

    # 29.11
    def test_29_11_stage_masculine_newborn(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="m") == "רק נולד"

    # 29.12
    def test_29_12_stage_feminine_newborn(self) -> None:
        assert self.pt.format_stage("2025-06-15", "2025-06-15", gender="f") == "רק נולדה"

    # 29.13
    def test_29_13_stage_masculine_adult(self) -> None:
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="m") == "מבוגר"

    # 29.14
    def test_29_14_stage_feminine_adult(self) -> None:
        assert self.pt.format_stage("2007-06-15", "2025-06-15", gender="f") == "מבוגרת"


class TestLocaleMacedonian:
    """Macedonian (mk) — mod10/mod100 rule."""

    def setup_method(self) -> None:
        self.pt = ParentTime(MK)

    # 29.15
    def test_29_15_just_born(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Новороденче"

    # 29.16
    def test_29_16_one_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "1 ден"

    # 29.17
    def test_29_17_three_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 дена"

    # 29.18
    def test_29_18_six_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 месеци"

    # 29.19
    def test_29_19_two_years_one_month(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "2 години, 1 месец"

    # 29.20
    def test_29_20_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3 години и пол"

    # 29.21
    def test_29_21_seven_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7 години"


class TestLocaleSwahili:
    """Swahili (sw) — noun class changes."""

    def setup_method(self) -> None:
        self.pt = ParentTime(SW)

    # 29.22
    def test_29_22_just_born(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Mzaliwa mpya"

    # 29.23
    def test_29_23_one_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "siku 1"

    # 29.24
    def test_29_24_three_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "siku 3"

    # 29.25
    def test_29_25_six_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "miezi 6"

    # 29.26
    def test_29_26_two_years_one_month(self) -> None:
        assert self.pt.format_age("2023-06-15", "2025-07-15") == "miaka 2, mwezi 1"

    # 29.27
    def test_29_27_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "miaka 3 na nusu"


class TestLocaleIndonesian:
    """Indonesian (id) — other_only (no plural forms)."""

    def setup_method(self) -> None:
        self.pt = ParentTime(ID)

    # 29.28
    def test_29_28_just_born(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "Baru lahir"

    # 29.29
    def test_29_29_one_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "1 hari"

    # 29.30
    def test_29_30_three_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 hari"

    # 29.31
    def test_29_31_six_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 bulan"

    # 29.32
    def test_29_32_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3 tahun setengah"

    # 29.33
    def test_29_33_seven_years(self) -> None:
        assert self.pt.format_age("2018-06-15", "2025-06-15") == "7 tahun"


class TestLocaleAmharic:
    """Amharic (am) — Ethiopic delimiter."""

    def setup_method(self) -> None:
        self.pt = ParentTime(AM)

    # 29.34
    def test_29_34_just_born(self) -> None:
        assert self.pt.format_age("2025-06-15", "2025-06-15") == "አዲስ የተወለደ"

    # 29.35
    def test_29_35_one_day(self) -> None:
        assert self.pt.format_age("2025-06-14", "2025-06-15") == "1 ቀን"

    # 29.36
    def test_29_36_three_days(self) -> None:
        assert self.pt.format_age("2025-06-12", "2025-06-15") == "3 ቀናት"

    # 29.37
    def test_29_37_one_week_one_day_ethiopic_delimiter(self) -> None:
        assert self.pt.format_age("2025-06-07", "2025-06-15") == "1 ሳምንት፣ 1 ቀን"

    # 29.38
    def test_29_38_six_months(self) -> None:
        assert self.pt.format_age("2025-01-15", "2025-07-15") == "6 ወራት"

    # 29.39
    def test_29_39_half_years(self) -> None:
        assert self.pt.format_age("2022-06-15", "2025-12-15") == "3 ዓመታት ተኩል"


# ================================================================
# Section 30: Locale lookup by code string
# ================================================================


class TestLocaleLookup:
    # 30.1
    def test_30_1_known_locale_en(self) -> None:
        loc = get_locale("en")
        assert loc is not None
        assert loc.code == "en"

    # 30.2
    def test_30_2_known_locale_fr(self) -> None:
        loc = get_locale("fr")
        assert loc is not None
        assert loc.code == "fr"

    # 30.3
    def test_30_3_unknown_code(self) -> None:
        assert get_locale("xx") is None

    # 30.4
    def test_30_4_empty_string(self) -> None:
        assert get_locale("") is None

    # 30.5
    def test_30_5_case_sensitive(self) -> None:
        assert get_locale("EN") is None
