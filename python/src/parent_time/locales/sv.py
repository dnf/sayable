"""Swedish locale."""

from parent_time.locale import AgeLocale

SV = AgeLocale(
    code="sv",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} dag", "other": "{n} dagar"},
        "week": {"one": "{n} vecka", "other": "{n} veckor"},
        "month": {"one": "{n} månad", "other": "{n} månader"},
        "year": {"one": "{n} år", "other": "{n} år"},
    },
    half="{n}\u00bd",
    delimiter=", ",
    just_born="Nyfödd",
    stages={
        "newborn": "Nyfödd",
        "infant": "Spädbarn",
        "toddler": "Litet barn",
        "child": "Barn",
        "teenager": "Tonåring",
        "adult": "Vuxen",
    },
)
