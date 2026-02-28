"""French locale."""

from parent_time.locale import AgeLocale

FR = AgeLocale(
    code="fr",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} jour", "other": "{n} jours"},
        "week": {"one": "{n} semaine", "other": "{n} semaines"},
        "month": "{n} mois",
        "year": {"one": "{n} an", "other": "{n} ans"},
    },
    half="{0} et demi",
    delimiter=", ",
    just_born="Nouveau-n\u00e9",
    stages={
        "newborn": "Nouveau-n\u00e9",
        "infant": "Nourrisson",
        "toddler": "Bambin",
        "child": "Enfant",
        "teenager": "Adolescent",
        "adult": "Adulte",
    },
)
