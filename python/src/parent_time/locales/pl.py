"""Polish locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if n == 1:
        return "one"
    if 2 <= mod10 <= 4 and not (12 <= mod100 <= 14):
        return "few"
    return "many"


PL = AgeLocale(
    code="pl",
    plural=_plural,
    units={
        "day": {"one": "{n} dzień", "few": "{n} dni", "many": "{n} dni", "other": "{n} dni"},
        "week": {"one": "{n} tydzień", "few": "{n} tygodnie", "many": "{n} tygodni", "other": "{n} tygodni"},
        "month": {"one": "{n} miesiąc", "few": "{n} miesiące", "many": "{n} miesięcy", "other": "{n} miesięcy"},
        "year": {"one": "{n} rok", "few": "{n} lata", "many": "{n} lat", "other": "{n} lat"},
    },
    half="{n} i pół",
    delimiter=", ",
    just_born="Noworodek",
    stages={
        "newborn": "Noworodek",
        "infant": "Niemowlę",
        "toddler": "Maluch",
        "child": "Dziecko",
        "teenager": {"m": "Nastolatek", "f": "Nastolatka"},
        "adult": {"m": "Dorosły", "f": "Dorosła"},
    },
)
