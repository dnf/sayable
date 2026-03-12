"""sayable-duration: Human-friendly duration formatting."""

from .locale import DurationLocale, CompactnessOverride, UnitForms
from .locale import simple_unit, plural_unit, resolve_unit
from .formatter import SayableDuration, format_duration, format_since, format_until
