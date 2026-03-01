"""Latvian locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    if n % 10 == 0 or (n % 100 >= 11 and n % 100 <= 19):
        return "zero"
    if n % 10 == 1 and n % 100 != 11:
        return "one"
    return "other"


LV = AgeLocale(
    code="lv",
    plural=_plural,
    units={
        "day": {"zero": "{n} dienu", "one": "{n} diena", "other": "{n} dienas"},
        "week": {"zero": "{n} nedēļu", "one": "{n} nedēļa", "other": "{n} nedēļas"},
        "month": {"zero": "{n} mēnešu", "one": "{n} mēnesis", "other": "{n} mēneši"},
        "year": {"zero": "{n} gadu", "one": "{n} gads", "other": "{n} gadi"},
    },
    half="{n}\u00bd",
    delimiter=", ",
    just_born="Jaundzimušais",
    stages={
        "newborn": {"m": "Jaundzimušais", "f": "Jaundzimušā"},
        "infant": {"m": "Zīdainis", "f": "Zīdaine"},
        "toddler": {"m": "Mazulis", "f": "Mazule"},
        "child": "Bērns",
        "teenager": {"m": "Pusaudzis", "f": "Pusaudze"},
        "adult": {"m": "Pieaugušais", "f": "Pieaugusī"},
    },
)
