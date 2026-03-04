"""Locale definitions for duration formatting."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

if TYPE_CHECKING:
    from collections.abc import Callable

PluralCategory = Literal["zero", "one", "two", "few", "many", "other"]

Compactness = Literal["normal", "short", "compact"]

UnitForms = str | dict[str, str]
"""A unit's display forms: either a single ``{n}``-template string
or a dict mapping :data:`PluralCategory` keys to templates
(``"other"`` is required, rest optional)."""


@dataclass(frozen=True)
class CompactnessOverride:
    """Optional overrides for short/compact display modes."""

    units: dict[str, UnitForms] | None = None
    half: str | None = None
    delimiter: str | None = None
    ago: str | None = None
    in_future: str | None = None


@dataclass(frozen=True)
class DurationLocale:
    """Locale definition for duration formatting."""

    code: str
    plural: Callable[[int], PluralCategory]
    units: dict[str, UnitForms]
    half: str
    delimiter: str
    just_now: str
    ago: str
    in_future: str
    short: CompactnessOverride | None = None
    compact: CompactnessOverride | None = None
    format_number: Callable[[int], str] | None = None
    format_unit: Callable[[int, str], str] | None = None


def resolve_unit(
    count: int,
    unit_forms: UnitForms,
    locale: DurationLocale,
    half: str = "",
) -> str:
    """Resolve a unit count to its display string using locale rules.

    The ``half`` template supports two placeholders:

    * ``{n}`` — replaces the formatted number *before* unit substitution
      (e.g. ``"{n}½"`` → "3½ hours")
    * ``{0}`` — wraps the fully resolved expression *after* unit substitution
      (e.g. ``"{0}半"`` → "3時間半")

    When a half marker is applied, the plural category is forced to
    ``"other"`` (e.g. "1½ hours" not "1½ hour").
    """
    base_n = locale.format_number(count) if locale.format_number else str(count)
    n = half.replace("{n}", base_n) if (half and "{n}" in half) else base_n
    if isinstance(unit_forms, str):
        template = unit_forms
    else:
        # Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
        category = "other" if half else locale.plural(count)
        template = unit_forms.get(category, unit_forms["other"])
    result = template.replace("{n}", n)
    if locale.format_unit:
        result = locale.format_unit(count, result)
    if half and "{0}" in half:
        result = half.replace("{0}", result)
    return result
