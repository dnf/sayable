"""Spanish locale."""

from parent_time.locale import AgeLocale

ES = AgeLocale(
    code="es",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} d\u00eda", "other": "{n} d\u00edas"},
        "week": {"one": "{n} semana", "other": "{n} semanas"},
        "month": {"one": "{n} mes", "other": "{n} meses"},
        "year": {"one": "{n} a\u00f1o", "other": "{n} a\u00f1os"},
    },
    half="{n} y medio",
    delimiter=", ",
    just_born="Reci\u00e9n nacido",
    stages={
        "newborn": "Reci\u00e9n nacido",
        "infant": "Beb\u00e9",
        "toddler": "Ni\u00f1o peque\u00f1o",
        "child": "Ni\u00f1o",
        "teenager": "Adolescente",
        "adult": "Adulto",
    },
)
