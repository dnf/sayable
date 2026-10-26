"""Tests for sayable-time Python implementation."""

from __future__ import annotations

from sayable_time import SayableTime, format_time
from sayable_time.locales.de import DE
from sayable_time.locales.en import EN
from sayable_time.locales.fi import FI
from sayable_time.locales.fr import FR
from sayable_time.locales.ja import JA

# ── Section 1: Null / edge cases ──────────────────────────────────────


class TestNullEdgeCases:
    # 1.1
    def test_format_time_none(self) -> None:
        assert format_time(None) is None

    # 1.2
    def test_format_time_empty(self) -> None:
        assert format_time("") is None

    # 1.3
    def test_format_time_invalid(self) -> None:
        assert format_time("invalid") is None

    # 1.4
    def test_format_time_out_of_range(self) -> None:
        assert format_time("25:00") is None


# ── Section 2: Clock time (normal compactness) ────────────────────────


class TestClockTimeNormal:
    def setup_method(self) -> None:
        self.st = SayableTime(EN)

    # 2.1
    def test_midnight(self) -> None:
        assert self.st.format_time("00:00") == "midnight"

    # 2.2
    def test_noon(self) -> None:
        assert self.st.format_time("12:00") == "noon"

    # 2.3
    def test_oclock(self) -> None:
        assert self.st.format_time("15:00") == "three o'clock"

    # 2.4
    def test_quarter_past(self) -> None:
        assert self.st.format_time("14:15") == "a quarter past two"

    # 2.5
    def test_half_past(self) -> None:
        assert self.st.format_time("09:30") == "half past nine"

    # 2.6
    def test_quarter_to(self) -> None:
        assert self.st.format_time("10:45") == "a quarter to eleven"

    # 2.7
    def test_five_past(self) -> None:
        assert self.st.format_time("08:05") == "five past eight"

    # 2.8
    def test_five_to(self) -> None:
        assert self.st.format_time("16:55") == "five to five"

    # 2.9
    def test_rounds_to_midnight(self) -> None:
        assert self.st.format_time("23:58") == "midnight"

    # 2.10
    def test_rounds_to_twenty(self) -> None:
        assert self.st.format_time("07:22") == "twenty past seven"

    # 2.11
    def test_iso_datetime_input(self) -> None:
        assert self.st.format_time("2025-01-15T14:15:00") == "a quarter past two"


# ── Section 3: Clock time (short compactness) ─────────────────────────


class TestClockTimeShort:
    def setup_method(self) -> None:
        self.st = SayableTime(EN, "short")

    # 3.1
    def test_pm(self) -> None:
        assert self.st.format_time("14:15") == "2:15 PM"

    # 3.2
    def test_am(self) -> None:
        assert self.st.format_time("09:30") == "9:30 AM"

    # 3.3
    def test_midnight(self) -> None:
        assert self.st.format_time("00:00") == "12:00 AM"

    # 3.4
    def test_noon(self) -> None:
        assert self.st.format_time("12:00") == "12:00 PM"


# ── Section 4: Clock time (compact) ───────────────────────────────────


class TestClockTimeCompact:
    def setup_method(self) -> None:
        self.st = SayableTime(EN, "compact")

    # 4.1
    def test_pm(self) -> None:
        assert self.st.format_time("14:15") == "2:15p"

    # 4.2
    def test_am(self) -> None:
        assert self.st.format_time("09:30") == "9:30a"


# ── Section 5: Locale — German ───────────────────────────────────────


class TestLocaleGerman:
    # 5.1
    def test_half_to_pattern(self) -> None:
        st = SayableTime(DE)
        assert st.format_time("15:30") == "halb vier"


# ── Section 6: Locale — French ───────────────────────────────────────


class TestLocaleFrench:
    # 6.1
    def test_quarter_past(self) -> None:
        st = SayableTime(FR)
        assert st.format_time("15:15") == "trois heures et quart"

    # 6.2
    def test_one_oclock(self) -> None:
        st = SayableTime(FR)
        assert st.format_time("13:00") == "une heure"

    # 6.3
    def test_half_past_one(self) -> None:
        st = SayableTime(FR)
        assert st.format_time("13:30") == "une heure et demie"

    # 6.4
    def test_quarter_to_three(self) -> None:
        st = SayableTime(FR)
        assert st.format_time("14:45") == "trois heures moins le quart"

    # 6.5
    def test_ten_to_three(self) -> None:
        st = SayableTime(FR)
        assert st.format_time("14:50") == "trois heures moins dix"


# ── Section 7: Locale — Japanese ─────────────────────────────────────


class TestLocaleJapanese:
    # 7.1
    def test_half_past(self) -> None:
        st = SayableTime(JA)
        assert st.format_time("15:30") == "三時半"


# ── Section 8: Locale — Finnish (dot separator, short) ────────────────


class TestLocaleFinnishDotSeparator:
    def setup_method(self) -> None:
        self.st = SayableTime(FI, "short")

    # 8.1
    def test_dot_separator(self) -> None:
        assert self.st.format_time("14:15") == "14.15"

    # 8.2
    def test_midnight_dot(self) -> None:
        assert self.st.format_time("00:00") == "0.00"


# ── Section 9: Minutes in short and compact modes ─────────────────────


class TestExactMinutesDigital:
    # 9.1
    def test_short_keeps_exact_minute(self) -> None:
        assert SayableTime(EN, "short").format_time("18:01") == "6:01 PM"

    # 9.2
    def test_compact_keeps_exact_minute(self) -> None:
        assert SayableTime(EN, "compact").format_time("19:05") == "7:05p"


# ── Section 10: Input validation ──────────────────────────────────────


class TestInputValidation:
    # 10.1
    def test_one_digit_hour(self) -> None:
        assert format_time("9:30") == "half past nine"

    # 10.2
    def test_two_digit_hour(self) -> None:
        assert format_time("09:30") == "half past nine"

    # 10.3
    def test_leading_whitespace(self) -> None:
        assert format_time(" 9:30") is None

    # 10.4
    def test_trailing_whitespace(self) -> None:
        assert format_time("9:30 ") is None

    # 10.5
    def test_minutes_need_two_digits(self) -> None:
        assert format_time("9:5") is None

    # 10.6
    def test_hour_out_of_range(self) -> None:
        assert format_time("24:00") is None

    # 10.7
    def test_seconds_allowed_and_ignored(self) -> None:
        assert format_time("14:15:30") == "a quarter past two"

    # 10.8
    def test_iso_datetime_with_zone_suffix(self) -> None:
        assert format_time("2025-01-15T14:15:00Z") == "a quarter past two"

    # 10.9
    def test_iso_datetime_with_impossible_date(self) -> None:
        assert format_time("2025-02-30T14:15:00") is None
