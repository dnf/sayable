"""Locale definitions for clock time formatting."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Compactness = Literal["normal", "short", "compact"]


@dataclass(frozen=True)
class ClockConfig:
    """Natural language clock reading configuration."""

    hours: list[str]
    midnight: str
    noon: str
    patterns: dict[int, str]


@dataclass(frozen=True)
class ShortClockConfig:
    """Digital clock display configuration for short/compact modes."""

    use24h: bool
    format: str
    am_pm: tuple[str, str] | None = None


@dataclass(frozen=True)
class CompactnessOverride:
    """Optional overrides for short/compact display modes."""

    clock: ShortClockConfig | None = None


@dataclass(frozen=True)
class TimeLocale:
    """Locale definition for clock time formatting."""

    code: str
    clock: ClockConfig
    short: CompactnessOverride | None = None
    compact: CompactnessOverride | None = None
