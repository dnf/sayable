"""Human-friendly age formatting for young children."""

from __future__ import annotations

import calendar
from datetime import date


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

    return months, diff_days


def format_age(
    date_of_birth: str | None,
    as_of: str | None = None,
) -> str | None:
    """Human-friendly age string for young children.

    - 0 days    → "Newborn"
    - 1–6 days  → "3 days"
    - 7 days–<3 months → "2 weeks, 4 days"
    - 3–23 months → "14 months"
    - 24–35 months → "2 years, 3 months"
    - 3–6 years → "3 years", "3½ years", "4 years", …
    - 7+ years → "7 years"

    Calendar-month boundaries use day-of-month clamping: a child born on the
    31st turns N months on the last day of a 30-day (or shorter) month.

    Args:
        date_of_birth: YYYY-MM-DD date string.
        as_of: YYYY-MM-DD reference date (defaults to today).
    """
    parsed = _parse_age(date_of_birth, as_of)
    if parsed is None:
        return None
    months, diff_days = parsed

    # Tier 1: 0–6 days
    if diff_days == 0:
        return "Newborn"
    if diff_days < 7:
        return "1 day" if diff_days == 1 else f"{diff_days} days"

    # Tier 2: weeks + days until 3 calendar months
    if months < 3:
        weeks = diff_days // 7
        days = diff_days % 7
        result = "1 week" if weeks == 1 else f"{weeks} weeks"
        if days > 0:
            result += ", 1 day" if days == 1 else f", {days} days"
        return result

    # Tier 3: 3–23 months
    if months < 24:
        return f"{months} months"

    # Tier 4: 24–35 months → years + months
    if months < 36:
        years = months // 12
        rem = months % 12
        if rem == 0:
            return f"{years} years"
        if rem == 1:
            return f"{years} years, 1 month"
        return f"{years} years, {rem} months"

    # Tier 5: 3–6 years → years with ½ marker
    if months < 84:
        years = months // 12
        rem = months % 12
        return f"{years}\u00bd years" if rem >= 6 else f"{years} years"

    # Tier 6: 7+ years
    return f"{months // 12} years"


def format_stage(
    date_of_birth: str | None,
    as_of: str | None = None,
) -> str | None:
    """Developmental stage label based on age.

    | Stage        | Age range          |
    |--------------|--------------------|
    | Newborn      | 0–1 months         |
    | Infant       | 2–11 months        |
    | Toddler      | 1–2 years          |
    | Child        | 3–12 years         |
    | Teenager     | 13–17 years        |
    | Adult        | 18+ years          |

    Boundaries follow AAP/CDC consensus.

    Args:
        date_of_birth: YYYY-MM-DD date string.
        as_of: YYYY-MM-DD reference date (defaults to today).
    """
    parsed = _parse_age(date_of_birth, as_of)
    if parsed is None:
        return None
    months = parsed[0]

    if months < 2:
        return "Newborn"
    if months < 12:
        return "Infant"
    if months < 36:
        return "Toddler"
    if months < 156:
        return "Child"
    if months < 216:
        return "Teenager"
    return "Adult"
