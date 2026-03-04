"""Tests for sayable-time Python implementation."""

from __future__ import annotations

from sayable_time import SayableTime, format_time
from sayable_time.locales.de import DE
from sayable_time.locales.en import EN
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


# ── Section 7: Locale — Japanese ─────────────────────────────────────

class TestLocaleJapanese:
    # 7.1
    def test_half_past(self) -> None:
        st = SayableTime(JA)
        assert st.format_time("15:30") == "三時半"
