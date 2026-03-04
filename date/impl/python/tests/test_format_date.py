"""Tests for sayable-date, matching canonical test spec date/config/tests.json."""

from sayable_date import SayableDate, format_date, format_relative
from sayable_date.locales.ar import AR
from sayable_date.locales.de import DE
from sayable_date.locales.en import EN
from sayable_date.locales.es import ES
from sayable_date.locales.fr import FR
from sayable_date.locales.ja import JA
from sayable_date.locales.ru import RU


# ── Section 1: Null / edge cases ────────────────────────────────────

# 1.1
def test_format_date_null():
    assert format_date(None) is None


# 1.2
def test_format_date_empty():
    assert format_date("") is None


# 1.3
def test_format_date_invalid():
    assert format_date("invalid") is None


# 1.4
def test_format_relative_null_as_of():
    assert format_relative("2025-03-15", as_of=None) is None


# 1.5
def test_format_relative_null_date():
    assert format_relative(None, as_of="2025-03-15") is None


# ── Section 2: format_date — normal compactness (English) ───────────

class TestFormatDateNormalEnglish:
    sd = SayableDate(EN)

    # 2.1
    def test_march_15(self):
        assert self.sd.format_date("2025-03-15") == "March 15th"

    # 2.2
    def test_january_1(self):
        assert self.sd.format_date("2025-01-01") == "January 1st"

    # 2.3
    def test_may_22(self):
        assert self.sd.format_date("2025-05-22") == "May 22nd"

    # 2.4
    def test_july_3(self):
        assert self.sd.format_date("2025-07-03") == "July 3rd"

    # 2.5
    def test_december_31(self):
        assert self.sd.format_date("2025-12-31") == "December 31st"

    # 2.6
    def test_june_11(self):
        assert self.sd.format_date("2025-06-11") == "June 11th"

    # 2.7
    def test_iso_datetime(self):
        assert self.sd.format_date("2025-03-15T14:30:00") == "March 15th"


# ── Section 3: format_date — short compactness (English) ────────────

class TestFormatDateShortEnglish:
    sd = SayableDate(EN, "short")

    # 3.1
    def test_march_15(self):
        assert self.sd.format_date("2025-03-15") == "Mar 15"

    # 3.2
    def test_january_1(self):
        assert self.sd.format_date("2025-01-01") == "Jan 1"

    # 3.3
    def test_december_25(self):
        assert self.sd.format_date("2025-12-25") == "Dec 25"


# ── Section 4: format_date — compact (English) ──────────────────────

class TestFormatDateCompactEnglish:
    sd = SayableDate(EN, "compact")

    # 4.1
    def test_march_15(self):
        assert self.sd.format_date("2025-03-15") == "3/15"

    # 4.2
    def test_january_1(self):
        assert self.sd.format_date("2025-01-01") == "1/1"


# ── Section 5: format_relative — proximity tiers (English) ──────────

class TestFormatRelativeEnglish:
    sd = SayableDate(EN)

    # 5.1
    def test_today(self):
        assert self.sd.format_relative("2025-03-15", as_of="2025-03-15") == "today"

    # 5.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "tomorrow"

    # 5.3
    def test_yesterday(self):
        assert self.sd.format_relative("2025-03-14", as_of="2025-03-15") == "yesterday"

    # 5.4
    def test_day_after_tomorrow(self):
        assert self.sd.format_relative("2025-03-17", as_of="2025-03-15") == "the day after tomorrow"

    # 5.5
    def test_day_before_yesterday(self):
        assert self.sd.format_relative("2025-03-13", as_of="2025-03-15") == "the day before yesterday"

    # 5.6
    def test_this_wednesday(self):
        assert self.sd.format_relative("2025-03-19", as_of="2025-03-15") == "this Wednesday"

    # 5.7
    def test_this_thursday(self):
        assert self.sd.format_relative("2025-03-20", as_of="2025-03-15") == "this Thursday"

    # 5.8
    def test_last_tuesday(self):
        assert self.sd.format_relative("2025-03-11", as_of="2025-03-15") == "last Tuesday"

    # 5.9
    def test_next_saturday(self):
        assert self.sd.format_relative("2025-03-22", as_of="2025-03-15") == "next Saturday"

    # 5.10
    def test_next_thursday(self):
        assert self.sd.format_relative("2025-03-27", as_of="2025-03-15") == "next Thursday"

    # 5.11
    def test_calendar_same_year_past(self):
        assert self.sd.format_relative("2025-03-01", as_of="2025-03-15") == "March 1st"

    # 5.12
    def test_calendar_same_year_future(self):
        assert self.sd.format_relative("2025-04-10", as_of="2025-03-15") == "April 10th"

    # 5.13
    def test_different_year_future(self):
        assert self.sd.format_relative("2026-01-05", as_of="2025-03-15") == "January 5th, 2026"

    # 5.14
    def test_different_year_past(self):
        assert self.sd.format_relative("2024-12-25", as_of="2025-03-15") == "December 25th, 2024"


# ── Section 6: format_relative — compact skips weekday tiers ────────

class TestFormatRelativeCompactEnglish:
    sd = SayableDate(EN, "compact")

    # 6.1
    def test_today(self):
        assert self.sd.format_relative("2025-03-15", as_of="2025-03-15") == "today"

    # 6.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "tomorrow"

    # 6.3
    def test_compact_numeric(self):
        assert self.sd.format_relative("2025-03-19", as_of="2025-03-15") == "3/19"

    # 6.4
    def test_compact_different_year(self):
        assert self.sd.format_relative("2026-01-05", as_of="2025-03-15") == "1/5/26"


# ── Section 7: Locale — German ──────────────────────────────────────

class TestLocaleGerman:
    sd = SayableDate(DE)

    # 7.1
    def test_format_date(self):
        assert self.sd.format_date("2025-03-15") == "15. März"

    # 7.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "morgen"

    # 7.3
    def test_day_after_tomorrow(self):
        assert self.sd.format_relative("2025-03-17", as_of="2025-03-15") == "übermorgen"

    # 7.4
    def test_this_wednesday(self):
        assert self.sd.format_relative("2025-03-19", as_of="2025-03-15") == "diesen Mittwoch"


# ── Section 8: Locale — French ──────────────────────────────────────

class TestLocaleFrench:
    sd = SayableDate(FR)

    # 8.1
    def test_format_date_first(self):
        assert self.sd.format_date("2025-03-01") == "1er mars"

    # 8.2
    def test_format_date(self):
        assert self.sd.format_date("2025-03-15") == "15 mars"

    # 8.3
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "demain"


# ── Section 9: Locale — Japanese ────────────────────────────────────

class TestLocaleJapanese:
    sd = SayableDate(JA)

    # 9.1
    def test_format_date(self):
        assert self.sd.format_date("2025-03-15") == "3月15日"

    # 9.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "明日"

    # 9.3
    def test_this_wednesday(self):
        assert self.sd.format_relative("2025-03-19", as_of="2025-03-15") == "今度の水曜日"


# ── Section 10: Locale — Russian (genitive months) ──────────────────

class TestLocaleRussian:
    sd = SayableDate(RU)

    # 10.1
    def test_format_date_genitive(self):
        assert self.sd.format_date("2025-03-15") == "15 марта"

    # 10.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "завтра"


# ── Section 11: Locale — Arabic ─────────────────────────────────────

class TestLocaleArabic:
    sd = SayableDate(AR)

    # 11.1
    def test_format_date(self):
        assert self.sd.format_date("2025-03-15") == "15 مارس"

    # 11.2
    def test_tomorrow(self):
        assert self.sd.format_relative("2025-03-16", as_of="2025-03-15") == "غداً"


# ── Section 12: Locale — Spanish ────────────────────────────────────

class TestLocaleSpanish:
    sd = SayableDate(ES)

    # 12.1
    def test_format_date(self):
        assert self.sd.format_date("2025-03-15") == "15 de marzo"

    # 12.2
    def test_day_after_tomorrow(self):
        assert self.sd.format_relative("2025-03-17", as_of="2025-03-15") == "pasado mañana"
