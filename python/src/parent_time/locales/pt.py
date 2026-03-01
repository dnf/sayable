"""Portuguese locale."""

from parent_time.locale import AgeLocale

PT = AgeLocale(
    code="pt",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} dia", "other": "{n} dias"},
        "week": {"one": "{n} semana", "other": "{n} semanas"},
        "month": {"one": "{n} m\u00eas", "other": "{n} meses"},
        "year": {"one": "{n} ano", "other": "{n} anos"},
    },
    half="{0} e meio",
    delimiter=", ",
    just_born="Rec\u00e9m-nascido",
    stages={
        "newborn": {"m": "Recém-nascido", "f": "Recém-nascida"},
        "infant": "Bebê",
        "toddler": "Criança pequena",
        "child": "Criança",
        "teenager": "Adolescente",
        "adult": {"m": "Adulto", "f": "Adulta"},
    },
)
