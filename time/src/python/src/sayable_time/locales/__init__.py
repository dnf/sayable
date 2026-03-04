"""Locale definitions for sayable-time."""

from sayable_time.locale import TimeLocale
from sayable_time.locales.de import DE
from sayable_time.locales.en import EN
from sayable_time.locales.fr import FR
from sayable_time.locales.ja import JA

_ALL: dict[str, TimeLocale] = {
    "de": DE, "en": EN, "fr": FR, "ja": JA,
}


def get_locale(code: str) -> TimeLocale | None:
    """Look up a locale by its code string."""
    return _ALL.get(code)

__all__ = ["DE", "EN", "FR", "JA", "get_locale"]
