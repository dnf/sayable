"""Romanian locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    mod100 = n % 100
    if n == 1:
        return "one"
    if n == 0 or (1 <= mod100 <= 19):
        return "few"
    return "other"


RO = AgeLocale(
    code="ro",
    plural=_plural,
    units={
        "day": {"one": "{n} zi", "few": "{n} zile", "other": "{n} de zile"},
        "week": {"one": "{n} săptămână", "few": "{n} săptămâni", "other": "{n} de săptămâni"},
        "month": {"one": "{n} lună", "few": "{n} luni", "other": "{n} de luni"},
        "year": {"one": "{n} an", "few": "{n} ani", "other": "{n} de ani"},
    },
    half="{0} și jumătate",
    delimiter=", ",
    just_born="Nou-născut",
    stages={
        "newborn": {"m": "Nou-născut", "f": "Nou-născută"},
        "infant": "Sugar",
        "toddler": "Copil mic",
        "child": "Copil",
        "teenager": {"m": "Adolescent", "f": "Adolescentă"},
        "adult": {"m": "Adult", "f": "Adultă"},
    },
)
