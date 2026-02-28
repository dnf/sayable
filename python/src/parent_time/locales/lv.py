"""Latvian locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    if n == 0:
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
        "newborn": "Jaundzimušais",
        "infant": "Zīdainis",
        "toddler": "Mazulis",
        "child": "Bērns",
        "teenager": "Pusaudzis",
        "adult": "Pieaugušais",
    },
)
