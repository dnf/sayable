"""Norwegian Bokmål locale."""

from parent_time.locale import AgeLocale

NB = AgeLocale(
    code="nb",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} dag", "other": "{n} dager"},
        "week": {"one": "{n} uke", "other": "{n} uker"},
        "month": {"one": "{n} måned", "other": "{n} måneder"},
        "year": {"one": "{n} år", "other": "{n} år"},
    },
    half="{n}\u00bd",
    delimiter=", ",
    just_born="Nyfødt",
    stages={
        "newborn": "Nyfødt",
        "infant": "Spedbarn",
        "toddler": "Småbarn",
        "child": "Barn",
        "teenager": "Tenåring",
        "adult": "Voksen",
    },
)
