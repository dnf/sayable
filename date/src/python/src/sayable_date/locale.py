"""Locale definitions for date formatting."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal

Compactness = Literal["normal", "short", "compact"]


@dataclass(frozen=True)
class CompactnessOverride:
    """Optional overrides for short/compact display modes."""

    months: list[str] | None = None
    months_in_date: list[str] | None = None
    weekdays: list[str] | None = None
    day_format: str | None = None
    day_format_exceptions: dict[str, str] | None = None
    date_pattern: str | None = None
    date_pattern_with_year: str | None = None
    today: str | None = None
    tomorrow: str | None = None
    yesterday: str | None = None


@dataclass(frozen=True)
class DateLocale:
    """Locale definition for date formatting."""

    code: str
    months: list[str]
    weekdays: list[str]
    day_format: str
    day_format_exceptions: dict[str, str] = field(default_factory=dict)
    date_pattern: str = "{day} {month}"
    date_pattern_with_year: str = "{day} {month} {year}"
    today: str = "today"
    tomorrow: str = "tomorrow"
    yesterday: str = "yesterday"
    day_after_tomorrow: str | None = None
    day_before_yesterday: str | None = None
    this_weekday: str | None = None
    next_weekday: str | None = None
    last_weekday: str | None = None
    months_in_date: list[str] | None = None
    short: CompactnessOverride | None = None
    compact: CompactnessOverride | None = None
