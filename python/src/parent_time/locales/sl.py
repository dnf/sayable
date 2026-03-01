"""Slovenian locale."""

from parent_time.locale import AgeLocale, PluralCategory


def _plural(n: int) -> PluralCategory:
    mod100 = n % 100
    if mod100 == 1:
        return "one"
    if mod100 == 2:
        return "two"
    if mod100 in (3, 4):
        return "few"
    return "other"


SL = AgeLocale(
    code="sl",
    plural=_plural,
    units={
        "day": {"one": "{n} dan", "two": "{n} dneva", "few": "{n} dni", "other": "{n} dni"},
        "week": {"one": "{n} teden", "two": "{n} tedna", "few": "{n} tedne", "other": "{n} tednov"},
        "month": {"one": "{n} mesec", "two": "{n} meseca", "few": "{n} mesece", "other": "{n} mesecev"},
        "year": {"one": "{n} leto", "two": "{n} leti", "few": "{n} leta", "other": "{n} let"},
    },
    half="{0} in pol",
    delimiter=", ",
    just_born="Novorojenček",
    stages={
        "newborn": {"m": "Novorojenček", "f": "Novorojenčica"},
        "infant": {"m": "Dojenček", "f": "Dojenčica"},
        "toddler": {"m": "Malček", "f": "Malčica"},
        "child": "Otrok",
        "teenager": {"m": "Najstnik", "f": "Najstnica"},
        "adult": {"m": "Odrasel", "f": "Odrasla"},
    },
)
