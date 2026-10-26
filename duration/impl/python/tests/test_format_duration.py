"""Tests for sayable-duration Python implementation."""

from __future__ import annotations

from sayable_duration import SayableDuration, format_duration, format_since, format_until
from sayable_duration.locales.de import DE
from sayable_duration.locales.en import EN
from sayable_duration.locales.fr import FR
from sayable_duration.locales.ja import JA
from sayable_duration.locales.men import MEN

# ── Section 1: Null / edge cases ──────────────────────────────────────


class TestNullEdgeCases:
    # 1.1
    def test_format_duration_none(self) -> None:
        assert format_duration(None) is None

    # 1.2
    def test_format_duration_negative(self) -> None:
        assert format_duration(-1) is None

    # 1.3
    def test_format_since_none_start(self) -> None:
        assert format_since(None, "2025-01-15T10:00:00") is None

    # 1.4
    def test_format_until_none_target(self) -> None:
        assert format_until(None, "2025-01-15T10:00:00") is None

    # 1.5
    def test_format_since_future_start(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00") is None

    # 1.6
    def test_format_until_past_target(self) -> None:
        assert format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00") is None


# ── Section 2: Duration — seconds tier (0-59s) ────────────────────────


class TestDurationSeconds:
    # 2.1
    def test_zero(self) -> None:
        assert format_duration(0) == "just now"

    # 2.2
    def test_one_second(self) -> None:
        assert format_duration(1) == "1 second"

    # 2.3
    def test_45_seconds(self) -> None:
        assert format_duration(45) == "45 seconds"

    # 2.4
    def test_59_seconds(self) -> None:
        assert format_duration(59) == "59 seconds"


# ── Section 3: Duration — minutes + seconds tier (1-4 min) ────────────


class TestDurationMinutesSeconds:
    # 3.1
    def test_one_minute(self) -> None:
        assert format_duration(60) == "1 minute"

    # 3.2
    def test_one_minute_thirty(self) -> None:
        assert format_duration(90) == "1 minute, 30 seconds"

    # 3.3
    def test_four_minutes(self) -> None:
        assert format_duration(240) == "4 minutes"

    # 3.4
    def test_four_minutes_thirty(self) -> None:
        assert format_duration(270) == "4 minutes, 30 seconds"


# ── Section 4: Duration — minutes tier (5-59 min) ─────────────────────


class TestDurationMinutes:
    # 4.1
    def test_five_minutes(self) -> None:
        assert format_duration(300) == "5 minutes"

    # 4.2
    def test_25_minutes(self) -> None:
        assert format_duration(1500) == "25 minutes"

    # 4.3
    def test_59_minutes(self) -> None:
        assert format_duration(3540) == "59 minutes"


# ── Section 5: Duration — hours + minutes tier (1-5 hr) ───────────────


class TestDurationHoursMinutes:
    # 5.1
    def test_one_hour(self) -> None:
        assert format_duration(3600) == "1 hour"

    # 5.2
    def test_one_and_half_hours(self) -> None:
        assert format_duration(5400) == "1½ hours"

    # 5.3
    def test_two_hours_15_minutes(self) -> None:
        assert format_duration(8100) == "2 hours, 15 minutes"

    # 5.4
    def test_five_hours(self) -> None:
        assert format_duration(18000) == "5 hours"


# ── Section 6: Duration — hours tier (6-23 hr) ────────────────────────


class TestDurationHours:
    # 6.1
    def test_eight_hours(self) -> None:
        assert format_duration(28800) == "8 hours"

    # 6.2
    def test_23_hours(self) -> None:
        assert format_duration(82800) == "23 hours"


# ── Section 7: Duration — days tier ──────────────────────────────────


class TestDurationDays:
    # 7.1
    def test_one_day(self) -> None:
        assert format_duration(86400) == "1 day"

    # 7.2
    def test_one_day_three_hours(self) -> None:
        assert format_duration(97200) == "1 day, 3 hours"

    # 7.3
    def test_one_and_half_days(self) -> None:
        assert format_duration(129600) == "1½ days"

    # 7.4
    def test_five_days(self) -> None:
        assert format_duration(432000) == "5 days"

    # 7.5
    def test_two_days(self) -> None:
        assert format_duration(172800) == "2 days"


# ── Section 8: Duration — weeks tier ─────────────────────────────────


class TestDurationWeeks:
    # 8.1
    def test_one_week(self) -> None:
        assert format_duration(604800) == "1 week"

    # 8.2
    def test_two_weeks_one_day(self) -> None:
        assert format_duration(1296000) == "2 weeks, 1 day"

    # 8.3
    def test_four_weeks(self) -> None:
        assert format_duration(2419200) == "4 weeks"


# ── Section 9: Duration — months and years tier ──────────────────────


class TestDurationMonthsYears:
    # 9.1
    def test_one_month(self) -> None:
        assert format_duration(2678400) == "1 month"

    # 9.2
    def test_three_months(self) -> None:
        assert format_duration(7884000) == "3 months"

    # 9.3
    def test_one_year(self) -> None:
        assert format_duration(31536000) == "1 year"

    # 9.4
    def test_one_year_three_months(self) -> None:
        assert format_duration(39420000) == "1 year, 3 months"


# ── Section 10: Duration from ISO timestamps ──────────────────────────


class TestDurationISO:
    # 10.1
    def test_iso_one_and_half_hours(self) -> None:
        assert format_duration("2025-01-15T10:00:00", "2025-01-15T11:30:00") == "1½ hours"

    # 10.2
    def test_iso_45_minutes(self) -> None:
        assert format_duration("2025-01-15T10:00:00", "2025-01-15T10:45:00") == "45 minutes"


# ── Section 11: Relative time — since ─────────────────────────────────


class TestFormatSince:
    # 11.1
    def test_just_now(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00") == "just now"

    # 11.2
    def test_30_seconds_ago(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30") == "30 seconds ago"

    # 11.3
    def test_45_minutes_ago(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00") == "45 minutes ago"

    # 11.4
    def test_three_hours_ago(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00") == "3 hours ago"


# ── Section 12: Relative time — until ─────────────────────────────────


class TestFormatUntil:
    # 12.1
    def test_just_now(self) -> None:
        assert format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00") == "just now"

    # 12.2
    def test_in_20_minutes(self) -> None:
        assert format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00") == "in 20 minutes"

    # 12.3
    def test_in_3_hours(self) -> None:
        assert format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00") == "in 3 hours"


# ── Section 13: Locale — German ───────────────────────────────────────


class TestLocaleGerman:
    def setup_method(self) -> None:
        self.sd = SayableDuration(DE)

    # 13.1
    def test_duration_one_hour(self) -> None:
        assert self.sd.format_duration(3600) == "1 Stunde"

    # 13.2
    def test_since(self) -> None:
        result = self.sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00")
        assert result == "vor 5 Minuten"


# ── Section 14: Locale — French ───────────────────────────────────────


class TestLocaleFrench:
    def setup_method(self) -> None:
        self.sd = SayableDuration(FR)

    # 14.1
    def test_duration_two_hours(self) -> None:
        assert self.sd.format_duration(7200) == "2 heures"


# ── Section 15: Locale — Japanese ─────────────────────────────────────


class TestLocaleJapanese:
    def setup_method(self) -> None:
        self.sd = SayableDuration(JA)

    # 15.1
    def test_duration_two_minutes(self) -> None:
        assert self.sd.format_duration(120) == "2分"

    # 15.2
    def test_since_one_hour(self) -> None:
        result = self.sd.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00")
        assert result == "1時間前"


# ── Section 16: Short compactness — duration ──────────────────────────


class TestShortDuration:
    def setup_method(self) -> None:
        self.sd = SayableDuration(EN, "short")

    # 16.1
    def test_one_hour(self) -> None:
        assert self.sd.format_duration(3600) == "1h"

    # 16.2
    def test_one_minute_thirty_seconds(self) -> None:
        assert self.sd.format_duration(90) == "1m, 30s"


# ── Section 17: Compact compactness — duration ────────────────────────


class TestCompactDuration:
    def setup_method(self) -> None:
        self.sd = SayableDuration(EN, "compact")

    # 17.1
    def test_one_hour(self) -> None:
        assert self.sd.format_duration(3600) == "1h"

    # 17.2
    def test_one_minute_thirty_seconds(self) -> None:
        assert self.sd.format_duration(90) == "1m30s"


# ── Section 18: Short compactness — relative time ─────────────────────


class TestShortSince:
    # 18.1
    def test_days_and_hours_both_kept(self) -> None:
        sd = SayableDuration(MEN, "short")
        assert sd.format_since("2025-01-20T01:32:11", "2025-01-22T15:39:16") == "lɔhɔnga 2, awa 14 taa gbɔyɔ"


# ── Section 19: Range (500-year ceiling) ──────────────────────────────


class TestRangeCeiling:
    # 19.1
    def test_500_julian_years_is_the_ceiling(self) -> None:
        assert format_duration(15778800000) == "500 years"

    # 19.2
    def test_over_6000_months(self) -> None:
        assert format_duration(15800000000) is None

    # 19.3
    def test_well_beyond_ceiling(self) -> None:
        assert format_duration(99999999999) is None

    # 19.4
    def test_since_525_years(self) -> None:
        assert format_since("1500-01-01T00:00:00", "2025-01-01T00:00:00") is None

    # 19.5
    def test_until_575_years(self) -> None:
        assert format_until("2600-01-01T00:00:00", "2025-01-01T00:00:00") is None


# ── Section 20: Timestamp validation ──────────────────────────────────


class TestTimestampValidation:
    # 20.1
    def test_seconds_are_optional(self) -> None:
        assert format_duration("2025-01-15T10:00", "2025-01-15T11:30:00") == "1½ hours"

    # 20.2
    def test_minutes_are_required(self) -> None:
        assert format_duration("2025-01-15T10", "2025-01-15T11:30:00") is None

    # 20.3
    def test_unpadded_date(self) -> None:
        assert format_duration("2025-1-5T10:00:00", "2025-01-15T11:30:00") is None

    # 20.4
    def test_impossible_date(self) -> None:
        assert format_duration("2025-02-30T10:00:00", "2025-03-15T11:30:00") is None

    # 20.5
    def test_hour_out_of_range(self) -> None:
        assert format_since("2025-01-15T10:00:00", "2025-01-15T25:00:00") is None
