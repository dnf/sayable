"""Italian locale."""

from parent_time.locale import AgeLocale

IT = AgeLocale(
    code="it",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} giorno", "other": "{n} giorni"},
        "week": {"one": "{n} settimana", "other": "{n} settimane"},
        "month": {"one": "{n} mese", "other": "{n} mesi"},
        "year": {"one": "{n} anno", "other": "{n} anni"},
    },
    half="{0} e mezzo",
    delimiter=", ",
    just_born="Neonato",
    stages={
        "newborn": "Neonato",
        "infant": "Lattante",
        "toddler": "Bimbo",
        "child": "Bambino",
        "teenager": "Adolescente",
        "adult": "Adulto",
    },
)
