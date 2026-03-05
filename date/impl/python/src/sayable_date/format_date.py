"""Human-friendly date formatting."""

from __future__ import annotations

from typing import Literal

from sayable_date.locale import CompactnessOverride, DateLocale
from sayable_date.locales.en import EN

__version__ = "0.5.0"


def _parse_date(s: str) -> tuple[int, int, int] | None:
    """Parse YYYY-MM-DD or ISO datetime to (year, month, day). Returns None on failure."""
    if not s:
        return None
    try:
        date_part = s.split("T")[0] if "T" in s else s
        parts = date_part.split("-")
        if len(parts) != 3:
            return None
        year, month, day = int(parts[0]), int(parts[1]), int(parts[2])
        if month < 1 or month > 12 or day < 1 or day > 31:
            return None
        return (year, month, day)
    except (ValueError, IndexError):
        return None


def _is_leap_year(year: int) -> bool:
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


def _days_in_month(year: int, month: int) -> int:
    if month in (1, 3, 5, 7, 8, 10, 12):
        return 31
    if month in (4, 6, 9, 11):
        return 30
    return 29 if _is_leap_year(year) else 28


def _to_jdn(year: int, month: int, day: int) -> int:
    """Convert a date to Julian Day Number for day-difference arithmetic."""
    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    return day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045


def _weekday(year: int, month: int, day: int) -> int:
    """Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday."""
    jdn = _to_jdn(year, month, day)
    return (jdn + 1) % 7


def _pick(override: CompactnessOverride | None, attr: str, default: object) -> object:
    """Pick override value if set (not None), else default."""
    if override is not None:
        val = getattr(override, attr, None)
        if val is not None:
            return val
    return default


class SayableDate:
    """Locale-aware date formatter.

    Example::

        sd = SayableDate(EN)
        sd.format_date("2025-03-15")                             # "March 15th"
        sd.format_relative("2025-03-16", as_of="2025-03-15")    # "tomorrow"
    """

    def __init__(
        self,
        locale: DateLocale,
        compactness: Literal["normal", "short", "compact"] = "normal",
    ) -> None:
        self._locale = locale
        self._compactness = compactness
        ovr = (
            locale.short if compactness == "short"
            else locale.compact if compactness == "compact"
            else None
        )
        self._months: list[str] = list(_pick(ovr, "months", locale.months))  # type: ignore[arg-type]
        self._months_in_date: list[str] | None = _pick(ovr, "months_in_date", locale.months_in_date)  # type: ignore[assignment]
        self._weekdays: list[str] = list(_pick(ovr, "weekdays", locale.weekdays))  # type: ignore[arg-type]
        self._day_format: str = str(_pick(ovr, "day_format", locale.day_format))
        if ovr is not None and ovr.day_format is not None and ovr.day_format_exceptions is None:
            self._day_format_exceptions: dict[str, str] = {}
        else:
            self._day_format_exceptions = _pick(ovr, "day_format_exceptions", locale.day_format_exceptions)  # type: ignore[assignment]
        self._date_pattern: str = str(_pick(ovr, "date_pattern", locale.date_pattern))
        self._date_pattern_with_year: str = str(_pick(ovr, "date_pattern_with_year", locale.date_pattern_with_year))
        self._today: str = str(_pick(ovr, "today", locale.today))
        self._tomorrow: str = str(_pick(ovr, "tomorrow", locale.tomorrow))
        self._yesterday: str = str(_pick(ovr, "yesterday", locale.yesterday))

    def format_date(self, date: str | None) -> str | None:
        """Format a calendar date in locale-appropriate form.

        Always absolute — no proximity logic.
        """
        if not date:
            return None
        parsed = _parse_date(date)
        if parsed is None:
            return None
        return self._format_absolute(*parsed, include_year=False)

    def format_date_with_year(self, date: str | None) -> str | None:
        """Format a calendar date with year in locale-appropriate form."""
        if not date:
            return None
        parsed = _parse_date(date)
        if parsed is None:
            return None
        return self._format_absolute(*parsed, include_year=True)

    def format_relative(self, date: str | None, *, as_of: str | None) -> str | None:
        """Format a date relative to as_of, picking the most natural reference.

        Falls back to absolute date for distant dates.
        """
        if not date or not as_of:
            return None
        parsed_date = _parse_date(date)
        parsed_as_of = _parse_date(as_of)
        if parsed_date is None or parsed_as_of is None:
            return None

        dy, dm, dd = parsed_date
        ay, am, ad = parsed_as_of

        date_jdn = _to_jdn(dy, dm, dd)
        asof_jdn = _to_jdn(ay, am, ad)
        diff = date_jdn - asof_jdn

        # Today
        if diff == 0:
            return self._today

        # Tomorrow
        if diff == 1:
            return self._tomorrow

        # Yesterday
        if diff == -1:
            return self._yesterday

        loc = self._locale
        is_compact = self._compactness == "compact"

        # Day after tomorrow (optional)
        if diff == 2 and loc.day_after_tomorrow and not is_compact:
            return loc.day_after_tomorrow

        # Day before yesterday (optional)
        if diff == -2 and loc.day_before_yesterday and not is_compact:
            return loc.day_before_yesterday

        # Compact mode: skip weekday references, go straight to calendar date
        if is_compact:
            include_year = dy != ay
            return self._format_absolute(dy, dm, dd, include_year=include_year)

        # This weekday (+2 to +6)
        if 2 <= diff <= 6 and loc.this_weekday:
            dow = _weekday(dy, dm, dd)
            weekday_name = self._weekdays[dow]
            return loc.this_weekday.replace("{weekday}", weekday_name)

        # Last weekday (-2 to -6)
        if -6 <= diff <= -2 and loc.last_weekday:
            dow = _weekday(dy, dm, dd)
            weekday_name = self._weekdays[dow]
            return loc.last_weekday.replace("{weekday}", weekday_name)

        # Next weekday (+7 to +13)
        if 7 <= diff <= 13 and loc.next_weekday:
            dow = _weekday(dy, dm, dd)
            weekday_name = self._weekdays[dow]
            return loc.next_weekday.replace("{weekday}", weekday_name)

        # Calendar fallback
        include_year = dy != ay
        return self._format_absolute(dy, dm, dd, include_year=include_year)

    def _format_absolute(self, year: int, month: int, day: int, *, include_year: bool) -> str:
        """Format a date as an absolute calendar reference."""
        # Format the day with ordinal
        day_str = str(day)
        fmt = self._day_format_exceptions.get(day_str, self._day_format)
        formatted_day = fmt.replace("{n}", day_str)

        # Pick month name (genitive form if available)
        month_names = self._months_in_date if self._months_in_date else self._months
        month_name = month_names[month - 1]

        pattern = self._date_pattern_with_year if include_year else self._date_pattern
        result = pattern.replace("{month}", month_name)
        result = result.replace("{day}", formatted_day)
        result = result.replace("{d}", str(day))
        result = result.replace("{m}", str(month))
        if include_year:
            result = result.replace("{year}", str(year))
            result = result.replace("{yy}", str(year % 100).zfill(2))

        return result


_default = SayableDate(EN)


def format_date(date: str | None) -> str | None:
    """Format date using the default English locale."""
    return _default.format_date(date)


def format_relative(date: str | None, *, as_of: str | None) -> str | None:
    """Format relative date using the default English locale."""
    return _default.format_relative(date, as_of=as_of)
