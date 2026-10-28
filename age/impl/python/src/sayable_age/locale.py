"""Locale definitions for age formatting."""

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

StageLabel = str | dict[str, str]
"""A stage label: either a plain string or ``{"m": ..., "f": ...}``
for gendered variants."""


@dataclass(frozen=True)
class CompactnessOverride:
    """Optional overrides for short/compact display modes."""

    units: dict[str, UnitForms] | None = None
    half: str | None = None
    delimiter: str | None = None
    just_born: str | None = None


@dataclass(frozen=True)
class AgeLocale:
    """Locale definition for age formatting."""

    code: str
    plural: Callable[[int], PluralCategory]
    units: dict[str, UnitForms]
    half: str
    delimiter: str
    just_born: str
    stages: dict[str, StageLabel]
    short: CompactnessOverride | None = None
    compact: CompactnessOverride | None = None
    format_number: Callable[[int], str] | None = None
    format_unit: Callable[[int, str], str] | None = None


def resolve_unit(
    count: int,
    unit_forms: UnitForms,
    locale: AgeLocale,
    half: str = "",
) -> str:
    """Resolve a unit count to its display string using locale rules.

    The ``half`` template supports two placeholders:

    * ``{n}`` — replaces the formatted number *before* unit substitution
      (e.g. ``"{n}½"`` → "3½ years", ``"साढ़े {n}"`` → "साढ़े 3 साल")
    * ``{0}`` — wraps the fully resolved expression *after* unit substitution
      (e.g. ``"{0}半"`` → "3歳半", ``"{0} et demi"`` → "3 ans et demi")
    """
    base_n = locale.format_number(count) if locale.format_number else str(count)
    n = half.replace("{n}", base_n) if (half and "{n}" in half) else base_n
    if isinstance(unit_forms, str):
        template = unit_forms
    else:
        template = unit_forms.get(locale.plural(count), unit_forms["other"])
    result = template.replace("{n}", n)
    if locale.format_unit:
        result = locale.format_unit(count, result)
    if half and "{0}" in half:
        result = half.replace("{0}", result)
    return result


def resolve_stage(label: StageLabel, gender: str | None = None) -> str:
    """Resolve a stage label, optionally selecting a gendered variant.

    If *label* is a plain string it is returned as-is.  If it is a dict
    with ``"m"`` / ``"f"`` keys, the feminine form is returned when
    *gender* is ``"f"``; otherwise the masculine form is returned.
    """
    if isinstance(label, str):
        return label
    return label["f"] if gender == "f" else label["m"]
