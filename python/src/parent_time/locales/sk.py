"""Slovak locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    if n == 1:
        return "one"
    if 2 <= n <= 4:
        return "few"
    return "other"


SK = AgeLocale(
    code="sk",
    plural=_plural,
    units={
        "day": {"one": "{n} deň", "few": "{n} dni", "other": "{n} dní"},
        "week": {"one": "{n} týždeň", "few": "{n} týždne", "other": "{n} týždňov"},
        "month": {"one": "{n} mesiac", "few": "{n} mesiace", "other": "{n} mesiacov"},
        "year": {"one": "{n} rok", "few": "{n} roky", "other": "{n} rokov"},
    },
    half="{n}\u00bd",
    delimiter=", ",
    just_born="Novorodenec",
    stages={
        "newborn": "Novorodenec",
        "infant": "Dojča",
        "toddler": "Batoľa",
        "child": "Dieťa",
        "teenager": "Tínedžer",
        "adult": "Dospelý",
    },
)
