"""Tests for format_age — mirrors the TypeScript test suite exactly."""

from __future__ import annotations

from datetime import date
from unittest.mock import patch

import pytest

from parent_time import format_age


# ================================================================
# Null / edge cases
# ================================================================
class TestEdgeCases:
    def test_returns_none_for_none_input(self) -> None:
        assert format_age(None, "2025-06-15") is None

    def test_returns_none_for_future_date_of_birth(self) -> None:
        assert format_age("2025-07-01", "2025-06-15") is None

    def test_returns_none_for_empty_string(self) -> None:
        assert format_age("", "2025-06-15") is None


# ================================================================
# Days tier: 0–6 days
# ================================================================
class TestDaysTier:
    def test_born_today(self) -> None:
        assert format_age("2025-06-15", "2025-06-15") == "Newborn"

    def test_born_1_day_ago_singular(self) -> None:
        assert format_age("2025-06-14", "2025-06-15") == "1 day"

    def test_born_3_days_ago(self) -> None:
        assert format_age("2025-06-12", "2025-06-15") == "3 days"

    def test_born_6_days_ago(self) -> None:
        assert format_age("2025-06-09", "2025-06-15") == "6 days"

    def test_never_shows_7_plus_days(self) -> None:
        assert format_age("2025-06-08", "2025-06-15") == "1 week"


# ================================================================
# Weeks+days tier: 7 days to <3 calendar months
# ================================================================
class TestWeeksDaysTier:
    def test_7_days(self) -> None:
        assert format_age("2025-06-08", "2025-06-15") == "1 week"

    def test_8_days(self) -> None:
        assert format_age("2025-06-07", "2025-06-15") == "1 week, 1 day"

    def test_9_days(self) -> None:
        assert format_age("2025-06-06", "2025-06-15") == "1 week, 2 days"

    def test_13_days(self) -> None:
        assert format_age("2025-06-02", "2025-06-15") == "1 week, 6 days"

    def test_14_days(self) -> None:
        assert format_age("2025-06-01", "2025-06-15") == "2 weeks"

    def test_15_days(self) -> None:
        assert format_age("2025-05-31", "2025-06-15") == "2 weeks, 1 day"

    def test_20_days(self) -> None:
        assert format_age("2025-05-26", "2025-06-15") == "2 weeks, 6 days"

    def test_21_days(self) -> None:
        assert format_age("2025-05-25", "2025-06-15") == "3 weeks"

    def test_at_1_calendar_month_still_shows_weeks_days(self) -> None:
        assert format_age("2025-05-15", "2025-06-15") == "4 weeks, 3 days"

    def test_at_2_calendar_months_still_shows_weeks_days(self) -> None:
        assert format_age("2025-04-15", "2025-06-15") == "8 weeks, 5 days"

    def test_one_day_before_3_month_birthday(self) -> None:
        assert format_age("2025-03-15", "2025-06-14") == "13 weeks"

    def test_on_3_month_birthday_switches_to_months(self) -> None:
        assert format_age("2025-03-15", "2025-06-15") == "3 months"


# ================================================================
# Month boundaries — the hard part
# ================================================================
class TestMonthBoundaryStandard:
    def test_born_jan1_check_apr1(self) -> None:
        assert format_age("2025-01-01", "2025-04-01") == "3 months"

    def test_born_jan1_check_mar31_still_weeks(self) -> None:
        result = format_age("2025-01-01", "2025-03-31")
        assert result is not None and "weeks" in result

    def test_born_jun15_check_sep15(self) -> None:
        assert format_age("2025-06-15", "2025-09-15") == "3 months"

    def test_born_jun15_check_sep14_still_weeks(self) -> None:
        result = format_age("2025-06-15", "2025-09-14")
        assert result is not None and "weeks" in result

    def test_born_jun15_check_dec15(self) -> None:
        assert format_age("2025-06-15", "2025-12-15") == "6 months"


class TestMonthBoundaryFebNonLeap:
    def test_born_jan31_check_feb28_nonleap(self) -> None:
        assert format_age("2025-01-31", "2025-02-28") == "4 weeks"

    def test_born_jan31_check_apr30(self) -> None:
        assert format_age("2025-01-31", "2025-04-30") == "3 months"

    def test_born_jan31_check_apr29_still_weeks(self) -> None:
        result = format_age("2025-01-31", "2025-04-29")
        assert result is not None and "weeks" in result

    def test_born_feb1_check_may1(self) -> None:
        assert format_age("2025-02-01", "2025-05-01") == "3 months"

    def test_born_feb1_check_apr30_still_weeks(self) -> None:
        result = format_age("2025-02-01", "2025-04-30")
        assert result is not None and "weeks" in result


class TestMonthBoundaryFebLeap:
    def test_born_jan31_check_feb29_leap(self) -> None:
        assert format_age("2024-01-31", "2024-02-29") == "4 weeks, 1 day"

    def test_born_jan31_check_feb28_leap(self) -> None:
        assert format_age("2024-01-31", "2024-02-28") == "4 weeks"

    def test_born_jan31_check_apr30_leap(self) -> None:
        assert format_age("2024-01-31", "2024-04-30") == "3 months"

    def test_born_jan30_check_feb29_leap_still_weeks(self) -> None:
        result = format_age("2024-01-30", "2024-02-29")
        assert result is not None and "weeks" in result

    def test_born_jan30_check_feb28_leap_still_weeks(self) -> None:
        result = format_age("2024-01-30", "2024-02-28")
        assert result is not None and "weeks" in result


class TestMonthBoundary30DayMonths:
    def test_born_mar31_check_jun30(self) -> None:
        assert format_age("2025-03-31", "2025-06-30") == "3 months"

    def test_born_mar31_check_jun29_still_weeks(self) -> None:
        result = format_age("2025-03-31", "2025-06-29")
        assert result is not None and "weeks" in result

    def test_born_aug31_check_nov30(self) -> None:
        assert format_age("2025-08-31", "2025-11-30") == "3 months"

    def test_born_aug31_check_nov29_still_weeks(self) -> None:
        result = format_age("2025-08-31", "2025-11-29")
        assert result is not None and "weeks" in result


class TestMonthBoundaryLeapYearBaby:
    def test_born_feb29_check_may29(self) -> None:
        assert format_age("2024-02-29", "2024-05-29") == "3 months"

    def test_born_feb29_check_may28_still_weeks(self) -> None:
        result = format_age("2024-02-29", "2024-05-28")
        assert result is not None and "weeks" in result

    def test_born_feb29_check_feb28_nonleap(self) -> None:
        assert format_age("2024-02-29", "2025-02-28") == "12 months"

    def test_born_feb29_check_mar1_next_year(self) -> None:
        assert format_age("2024-02-29", "2025-03-01") == "12 months"


# ================================================================
# Months tier: 3–23 months
# ================================================================
class TestMonthsTier:
    def test_3_months_at_transition(self) -> None:
        assert format_age("2025-01-15", "2025-04-15") == "3 months"

    def test_6_months(self) -> None:
        assert format_age("2025-01-15", "2025-07-15") == "6 months"

    def test_12_months_not_1_year(self) -> None:
        assert format_age("2024-06-15", "2025-06-15") == "12 months"

    def test_23_months_upper_boundary(self) -> None:
        assert format_age("2024-01-15", "2025-12-15") == "23 months"

    def test_one_day_before_month_boundary(self) -> None:
        assert format_age("2025-01-15", "2025-07-14") == "5 months"

    def test_crossing_year_boundary(self) -> None:
        assert format_age("2024-11-10", "2025-04-10") == "5 months"


# ================================================================
# Years+months tier: 24–35 months
# ================================================================
class TestYearsMonthsTier:
    def test_2_years_at_24_months(self) -> None:
        assert format_age("2023-06-15", "2025-06-15") == "2 years"

    def test_2_years_1_month_singular(self) -> None:
        assert format_age("2023-06-15", "2025-07-15") == "2 years, 1 month"

    def test_2_years_6_months(self) -> None:
        assert format_age("2023-06-15", "2025-12-15") == "2 years, 6 months"

    def test_2_years_11_months_upper_boundary(self) -> None:
        assert format_age("2023-06-15", "2026-05-15") == "2 years, 11 months"

    def test_one_day_before_24_months_stays_in_months(self) -> None:
        assert format_age("2023-06-15", "2025-06-14") == "23 months"


# ================================================================
# Half-year tier: 3–6 years
# ================================================================
class TestHalfYearTier:
    def test_3_years_exact(self) -> None:
        assert format_age("2022-06-15", "2025-06-15") == "3 years"

    def test_3_years_5_months(self) -> None:
        assert format_age("2022-06-15", "2025-11-15") == "3 years"

    def test_3_and_half_years(self) -> None:
        assert format_age("2022-06-15", "2025-12-15") == "3½ years"

    def test_3_years_11_months(self) -> None:
        assert format_age("2022-06-15", "2026-05-15") == "3½ years"

    def test_4_years_exact(self) -> None:
        assert format_age("2021-06-15", "2025-06-15") == "4 years"

    def test_4_and_half_years(self) -> None:
        assert format_age("2021-06-15", "2025-12-15") == "4½ years"

    def test_5_years_exact(self) -> None:
        assert format_age("2020-06-15", "2025-06-15") == "5 years"

    def test_5_and_half_years(self) -> None:
        assert format_age("2020-06-15", "2026-02-15") == "5½ years"

    def test_6_years_exact(self) -> None:
        assert format_age("2019-06-15", "2025-06-15") == "6 years"

    def test_6_and_half_years(self) -> None:
        assert format_age("2019-06-15", "2025-12-15") == "6½ years"

    def test_6_years_11_months(self) -> None:
        assert format_age("2019-06-15", "2026-05-15") == "6½ years"

    def test_one_day_before_3rd_birthday(self) -> None:
        assert format_age("2022-06-15", "2025-06-14") == "2 years, 11 months"


# ================================================================
# Integer tier: 7+ years
# ================================================================
class TestIntegerTier:
    def test_7_years_exact(self) -> None:
        assert format_age("2018-06-15", "2025-06-15") == "7 years"

    def test_7_years_6_months_no_half(self) -> None:
        assert format_age("2018-03-20", "2025-06-15") == "7 years"

    def test_45_years_adult(self) -> None:
        assert format_age("1980-01-01", "2025-06-15") == "45 years"


# ================================================================
# Cross-year transitions with short months
# ================================================================
class TestCrossYearWithFeb:
    def test_born_dec31_check_mar31(self) -> None:
        assert format_age("2024-12-31", "2025-03-31") == "3 months"

    def test_born_dec31_check_mar30_still_weeks(self) -> None:
        result = format_age("2024-12-31", "2025-03-30")
        assert result is not None and "weeks" in result

    def test_born_nov30_check_feb28(self) -> None:
        assert format_age("2024-11-30", "2025-02-28") == "3 months"

    def test_born_nov30_check_feb27_still_weeks(self) -> None:
        result = format_age("2024-11-30", "2025-02-27")
        assert result is not None and "weeks" in result


# ================================================================
# Regression: born on 31st tracked through multiple months
# ================================================================
class TestBornOn31stProgression:
    def test_jan31_to_apr30(self) -> None:
        assert format_age("2025-01-31", "2025-04-30") == "3 months"

    def test_jan31_to_may31(self) -> None:
        assert format_age("2025-01-31", "2025-05-31") == "4 months"

    def test_jan31_to_jun30_clamped(self) -> None:
        assert format_age("2025-01-31", "2025-06-30") == "5 months"

    def test_jan31_to_jul1_before_birthday(self) -> None:
        assert format_age("2025-01-31", "2025-07-01") == "5 months"

    def test_jan31_to_jul31(self) -> None:
        assert format_age("2025-01-31", "2025-07-31") == "6 months"


# ================================================================
# Default as_of (uses current date)
# ================================================================
class TestDefaultAsOf:
    def test_returns_correct_age_without_as_of(self) -> None:
        with patch("parent_time.format_age.date") as mock_date:
            mock_date.today.return_value = date(2025, 6, 15)
            mock_date.side_effect = lambda *args, **kw: date(*args, **kw)
            assert format_age("2020-01-01") == "5 years"
            assert format_age("2025-06-10") == "5 days"
