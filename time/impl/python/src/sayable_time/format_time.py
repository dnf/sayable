"""Human-friendly clock time formatting."""

from __future__ import annotations

from typing import Literal

from sayable_time.locale import (
    CompactnessOverride,
    ShortClockConfig,
    TimeLocale,
)
from sayable_time.locales.en import EN

__version__ = "0.5.0"


def _parse_time(input_str: str) -> tuple[int, int] | None:
    """Parse HH:MM or ISO datetime to (hour, minute). Returns None on failure."""
    if not input_str:
        return None
    t = input_str
    if "T" in t:
        t = t.split("T")[1]
    if "+" in t:
        t = t.split("+")[0]
    if "Z" in t:
        t = t.split("Z")[0]
    parts = t.split(":")
    if len(parts) < 2:
        return None
    try:
        hour = int(parts[0])
        minute = int(parts[1].split(".")[0])
    except ValueError:
        return None
    if hour < 0 or hour > 23 or minute < 0 or minute > 59:
        return None
    return (hour, minute)


def _round_to_5(minute: int) -> int:
    """Round minute to nearest 5."""
    return ((minute + 2) // 5) * 5


class SayableTime:
    """Locale-aware clock time formatter.

    Example::

        st = SayableTime(EN)
        st.format_time("14:15")          # "a quarter past two"
        st.format_time("09:30")          # "half past nine"

        st_short = SayableTime(EN, "short")
        st_short.format_time("14:15")    # "2:15 PM"
    """

    def __init__(
        self,
        locale: TimeLocale,
        compactness: Literal["normal", "short", "compact"] = "normal",
    ) -> None:
        self._locale = locale
        self._compactness = compactness
        ovr = (
            locale.short if compactness == "short"
            else locale.compact if compactness == "compact"
            else None
        )
        self._short_clock: ShortClockConfig | None = ovr.clock if ovr else None

    def format_time(self, input_str: str | None) -> str | None:
        """Format a time as natural language clock reading.

        Args:
            input_str: Time as "HH:MM" or ISO datetime string.
        """
        if not input_str:
            return None
        parsed = _parse_time(input_str)
        if parsed is None:
            return None
        hour, minute = parsed

        if self._compactness != "normal" and self._short_clock:
            return self._format_digital(hour, minute)
        return self._format_natural(hour, minute)

    def _format_natural(self, hour: int, minute: int) -> str:
        clock = self._locale.clock
        rounded = _round_to_5(minute)
        h = hour
        if rounded == 60:
            rounded = 0
            h = (h + 1) % 24
        if rounded == 0:
            if h == 0:
                return clock.midnight
            if h == 12:
                return clock.noon
        h12 = h % 12
        next_h12 = (h + 1) % 12
        h_name = clock.hours[h12]
        next_h_name = clock.hours[next_h12]
        pattern = clock.patterns.get(rounded, clock.patterns.get(0, "{h}"))
        return pattern.replace("{h}", h_name).replace("{next_h}", next_h_name)

    def _format_digital(self, hour: int, minute: int) -> str:
        sc = self._short_clock
        assert sc is not None
        fmt = sc.format
        if sc.use24h:
            return fmt.replace("{h}", str(hour)).replace("{mm}", str(minute).zfill(2))
        h12 = hour % 12
        if h12 == 0:
            h12 = 12
        am_pm = sc.am_pm or ("AM", "PM")
        ampm_str = am_pm[0] if hour < 12 else am_pm[1]
        return (
            fmt.replace("{h}", str(h12))
            .replace("{mm}", str(minute).zfill(2))
            .replace("{ampm}", ampm_str)
        )


_default = SayableTime(EN)


def format_time(input_str: str | None) -> str | None:
    """Format clock time using the default English locale."""
    return _default.format_time(input_str)
