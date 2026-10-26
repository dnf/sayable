"""Human-friendly duration and relative time formatting."""

from __future__ import annotations

import re
from typing import Literal

from sayable_duration.locale import (
    DurationLocale,
    UnitForms,
    resolve_unit,
)
from sayable_duration.locales.en import EN

__version__ = "0.5.0"


MAX_DURATION_MONTHS = 6000  # 500 years, the same ceiling as sayable-age

# YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
_TIMESTAMP = re.compile(
    r"([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})"
    r"(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?"
)


def _parse_iso_to_seconds(iso_str: str) -> int | None:
    """Parse an ISO datetime to epoch-ish seconds for diffing; None if malformed."""
    if not iso_str:
        return None
    m = _TIMESTAMP.fullmatch(iso_str)
    if not m:
        return None
    year, month, day, hour, minute = (int(m[i]) for i in range(1, 6))
    second = int(m[6]) if m[6] else 0
    if not 1 <= month <= 12 or not 1 <= day <= _days_in_month(year, month):
        return None
    if hour > 23 or minute > 59 or second > 59:
        return None
    days = _days_since_epoch(year, month, day)
    return days * 86400 + hour * 3600 + minute * 60 + second


def _is_leap_year(year: int) -> bool:
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


def _days_in_month(year: int, month: int) -> int:
    if month in (1, 3, 5, 7, 8, 10, 12):
        return 31
    if month in (4, 6, 9, 11):
        return 30
    return 29 if _is_leap_year(year) else 28


def _days_since_epoch(year: int, month: int, day: int) -> int:
    """Calculate days since a reference epoch (2000-01-01)."""
    days = 0
    if year >= 2000:
        for y in range(2000, year):
            days += 366 if _is_leap_year(y) else 365
    else:
        for y in range(year, 2000):
            days -= 366 if _is_leap_year(y) else 365
    for m in range(1, month):
        days += _days_in_month(year, m)
    days += day - 1
    return days


def _pick(override: object | None, attr: str, default: object) -> object:
    """Pick override value if set (not None), else default."""
    if override is not None:
        val = getattr(override, attr, None)
        if val is not None:
            return val
    return default


class SayableDuration:
    """Locale-aware duration and relative time formatter.

    Example::

        sd = SayableDuration(EN)
        sd.format_duration(3600)                            # "1 hour"
        sd.format_duration("2025-01-15T10:00", "2025-01-15T11:30")  # "1½ hours"
        sd.format_since("2025-01-15T10:00", "2025-01-15T10:45")     # "45 minutes ago"
        sd.format_until("2025-01-15T15:00", "2025-01-15T14:40")     # "in 20 minutes"
    """

    def __init__(
        self,
        locale: DurationLocale,
        compactness: Literal["normal", "short", "compact"] = "normal",
    ) -> None:
        self._locale = locale
        ovr = (
            locale.short if compactness == "short"
            else locale.compact if compactness == "compact"
            else None
        )
        ovr_units = ovr.units if ovr else None
        self._units: dict[str, UnitForms] = {
            k: (ovr_units.get(k) if ovr_units else None) or locale.units[k]
            for k in ("second", "minute", "hour", "day", "week", "month", "year")
        }
        self._half: str = str(_pick(ovr, "half", locale.half))
        self._delimiter: str = str(_pick(ovr, "delimiter", locale.delimiter))
        self._just_now: str = locale.just_now
        self._ago: str = str(_pick(ovr, "ago", locale.ago))
        self._in_future: str = str(_pick(ovr, "in_future", locale.in_future))

    def format_duration(
        self,
        start_or_seconds: str | int | None,
        end: str | None = None,
    ) -> str | None:
        """Format a duration in human-friendly terms.

        Args:
            start_or_seconds: Either seconds (int) or ISO datetime start.
            end: ISO datetime end (required if start_or_seconds is a string).
        """
        if start_or_seconds is None:
            return None

        if isinstance(start_or_seconds, int):
            total_seconds = start_or_seconds
        else:
            if end is None:
                return None
            s = _parse_iso_to_seconds(start_or_seconds)
            e = _parse_iso_to_seconds(end)
            if s is None or e is None:
                return None
            total_seconds = abs(e - s)

        if total_seconds < 0:
            return None

        return self._format_duration_seconds(total_seconds)

    def _format_duration_seconds(self, total: int) -> str | None:
        """Apply duration tiers to total seconds."""
        loc = self._locale

        # 0 seconds
        if total == 0:
            return self._just_now

        # 1-59 seconds
        if total < 60:
            return resolve_unit(total, self._units["second"], loc)

        total_minutes = total // 60
        remainder_seconds = total % 60

        # 1-4 minutes: minutes + seconds
        if total_minutes < 5:
            result = resolve_unit(total_minutes, self._units["minute"], loc)
            if remainder_seconds > 0:
                result += self._delimiter + resolve_unit(remainder_seconds, self._units["second"], loc)
            return result

        # 5-59 minutes
        if total_minutes < 60:
            return resolve_unit(total_minutes, self._units["minute"], loc)

        total_hours = total // 3600
        remainder_minutes = (total % 3600) // 60

        # 1-5 hours: hours + minutes (with half marker)
        if total_hours <= 5:
            if remainder_minutes == 30:
                return resolve_unit(total_hours, self._units["hour"], loc, self._half)
            result = resolve_unit(total_hours, self._units["hour"], loc)
            if remainder_minutes > 0:
                result += self._delimiter + resolve_unit(remainder_minutes, self._units["minute"], loc)
            return result

        # 6-23 hours
        if total_hours < 24:
            return resolve_unit(total_hours, self._units["hour"], loc)

        total_days = total // 86400
        remainder_hours = (total % 86400) // 3600

        # 1-2 days: days + hours (with half marker)
        if total_days <= 2:
            if remainder_hours == 12:
                return resolve_unit(total_days, self._units["day"], loc, self._half)
            result = resolve_unit(total_days, self._units["day"], loc)
            if remainder_hours > 0:
                result += self._delimiter + resolve_unit(remainder_hours, self._units["hour"], loc)
            return result

        # 3-6 days
        if total_days < 7:
            return resolve_unit(total_days, self._units["day"], loc)

        total_weeks = total_days // 7
        remainder_days = total_days % 7

        # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if total_days < 30:
            result = resolve_unit(total_weeks, self._units["week"], loc)
            if remainder_days > 0:
                result += self._delimiter + resolve_unit(remainder_days, self._units["day"], loc)
            return result

        # Approximate months (30.44 days average)
        total_months = round(total_days / 30.44)
        if total_months > MAX_DURATION_MONTHS:
            return None

        # 1-11 months
        if total_months < 12:
            if total_months == 0:
                total_months = 1
            return resolve_unit(total_months, self._units["month"], loc)

        # 12+ months: years + months
        total_years = total_months // 12
        remainder_months = total_months % 12
        result = resolve_unit(total_years, self._units["year"], loc)
        if remainder_months > 0:
            result += self._delimiter + resolve_unit(remainder_months, self._units["month"], loc)
        return result

    def format_since(
        self,
        start: str | None,
        as_of: str | None,
    ) -> str | None:
        """Format elapsed time as 'X ago'.

        Args:
            start: ISO datetime of the past event.
            as_of: ISO datetime of the reference point (now).
        """
        if not start or not as_of:
            return None
        s = _parse_iso_to_seconds(start)
        a = _parse_iso_to_seconds(as_of)
        if s is None or a is None:
            return None
        diff = a - s
        if diff < 0:
            return None
        if diff == 0:
            return self._just_now
        dur = self._format_duration_seconds(diff)
        return None if dur is None else self._ago.replace("{0}", dur)

    def format_until(
        self,
        target: str | None,
        as_of: str | None,
    ) -> str | None:
        """Format time until a future event as 'in X'.

        Args:
            target: ISO datetime of the future event.
            as_of: ISO datetime of the reference point (now).
        """
        if not target or not as_of:
            return None
        t = _parse_iso_to_seconds(target)
        a = _parse_iso_to_seconds(as_of)
        if t is None or a is None:
            return None
        diff = t - a
        if diff < 0:
            return None
        if diff == 0:
            return self._just_now
        dur = self._format_duration_seconds(diff)
        return None if dur is None else self._in_future.replace("{0}", dur)


_default = SayableDuration(EN)


def format_duration(
    start_or_seconds: str | int | None,
    end: str | None = None,
) -> str | None:
    """Format duration using the default English locale."""
    return _default.format_duration(start_or_seconds, end)


def format_since(start: str | None, as_of: str | None) -> str | None:
    """Format elapsed time using the default English locale."""
    return _default.format_since(start, as_of)


def format_until(target: str | None, as_of: str | None) -> str | None:
    """Format time until event using the default English locale."""
    return _default.format_until(target, as_of)
