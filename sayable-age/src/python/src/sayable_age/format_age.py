"""Human-friendly age formatting for young children."""

from __future__ import annotations

import calendar
from datetime import date
from typing import Literal

from sayable_age.locale import AgeLocale, UnitForms, resolve_stage, resolve_unit
from sayable_age.locales.en import EN

__version__ = "0.5.0"

MAX_AGE_MONTHS = 6000


def _parse_age(
    date_of_birth: str | None,
    as_of: str | None = None,
) -> tuple[int, int] | None:
    """Parse two YYYY-MM-DD strings into (calendar_months, elapsed_days).

    Returns None if date_of_birth is falsy or in the future relative to as_of.
    """
    if not date_of_birth:
        return None

    dob_parts = date_of_birth.split("-")
    dob_y, dob_m, dob_d = int(dob_parts[0]), int(dob_parts[1]), int(dob_parts[2])

    if as_of:
        ref_parts = as_of.split("-")
        ref_y, ref_m, ref_d = int(ref_parts[0]), int(ref_parts[1]), int(ref_parts[2])
    else:
        today = date.today()
        ref_y, ref_m, ref_d = today.year, today.month, today.day

    diff_days = (date(ref_y, ref_m, ref_d) - date(dob_y, dob_m, dob_d)).days
    if diff_days < 0:
        return None

    last_day = calendar.monthrange(ref_y, ref_m)[1]
    clamped_birthday = min(dob_d, last_day)
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m)
    if ref_d < clamped_birthday:
        months -= 1
    if months > MAX_AGE_MONTHS:
        return None

    return months, diff_days


def _stage_key(months: int) -> str:
    """Map calendar months to a stage key."""
    if months < 2:
        return "newborn"
    if months < 12:
        return "infant"
    if months < 36:
        return "toddler"
    if months < 156:
        return "child"
    if months < 216:
        return "teenager"
    return "adult"


def _pick(override: object | None, attr: str, default: object) -> object:
    """Pick override value if set (not None), else default."""
    if override is not None:
        val = getattr(override, attr, None)
        if val is not None:
            return val
    return default


class SayableAge:
    """Locale-aware age formatter.

    Example::

        pt = SayableAge(EN)
        pt.format_age("2025-01-01", "2025-07-15")   # "6 months"

        pt_short = SayableAge(EN, "short")
        pt_short.format_age("2025-01-01", "2025-07-15")  # "6 mo"

        pt_compact = SayableAge(EN, "compact")
        pt_compact.format_age("2025-01-01", "2025-07-15")  # "6m"
    """

    def __init__(
        self,
        locale: AgeLocale,
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
            for k in ("day", "week", "month", "year")
        }
        self._half: str = str(_pick(ovr, "half", locale.half))
        self._delimiter: str = str(_pick(ovr, "delimiter", locale.delimiter))
        self._just_born: str = str(_pick(ovr, "just_born", locale.just_born))

    def format_age(
        self,
        date_of_birth: str | None,
        as_of: str | None = None,
    ) -> str | None:
        """Human-friendly age string.

        Args:
            date_of_birth: YYYY-MM-DD date string.
            as_of: YYYY-MM-DD reference date (defaults to today).
        """
        parsed = _parse_age(date_of_birth, as_of)
        if parsed is None:
            return None
        months, diff_days = parsed
        loc = self._locale

        # Tier 1: 0–6 days
        if diff_days == 0:
            return self._just_born
        if diff_days < 7:
            return resolve_unit(diff_days, self._units["day"], loc)

        # Tier 2: weeks + days until 3 calendar months
        if months < 3:
            weeks = diff_days // 7
            days = diff_days % 7
            result = resolve_unit(weeks, self._units["week"], loc)
            if days > 0:
                result += self._delimiter + resolve_unit(days, self._units["day"], loc)
            return result

        # Tier 3: 3–23 months
        if months < 24:
            return resolve_unit(months, self._units["month"], loc)

        # Tier 4: 24–35 months → years + months
        if months < 36:
            years = months // 12
            rem = months % 12
            if rem == 0:
                return resolve_unit(years, self._units["year"], loc)
            return (
                resolve_unit(years, self._units["year"], loc)
                + self._delimiter
                + resolve_unit(rem, self._units["month"], loc)
            )

        # Tier 5: 3–6 years → years with half marker
        if months < 84:
            years = months // 12
            rem = months % 12
            if rem >= 6:
                return resolve_unit(years, self._units["year"], loc, self._half)
            return resolve_unit(years, self._units["year"], loc)

        # Tier 6: 7+ years
        return resolve_unit(months // 12, self._units["year"], loc)

    def format_stage(
        self,
        date_of_birth: str | None,
        as_of: str | None = None,
        gender: str | None = None,
    ) -> str | None:
        """Developmental stage label based on age.

        Args:
            date_of_birth: YYYY-MM-DD date string.
            as_of: YYYY-MM-DD reference date (defaults to today).
            gender: ``"m"`` or ``"f"`` for gendered locales (default masculine/neutral).
        """
        parsed = _parse_age(date_of_birth, as_of)
        if parsed is None:
            return None
        return resolve_stage(self._locale.stages[_stage_key(parsed[0])], gender)


_default = SayableAge(EN)


def format_age(
    date_of_birth: str | None,
    as_of: str | None = None,
) -> str | None:
    """Human-friendly age string using the default English locale."""
    return _default.format_age(date_of_birth, as_of)


def format_stage(
    date_of_birth: str | None,
    as_of: str | None = None,
    gender: str | None = None,
) -> str | None:
    """Developmental stage label using the default English locale."""
    return _default.format_stage(date_of_birth, as_of, gender)
