"""Catalan locale."""

from parent_time.locale import AgeLocale

CA = AgeLocale(
    code="ca",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} dia", "other": "{n} dies"},
        "week": {"one": "{n} setmana", "other": "{n} setmanes"},
        "month": {"one": "{n} mes", "other": "{n} mesos"},
        "year": {"one": "{n} any", "other": "{n} anys"},
    },
    half="{n} i mig",
    delimiter=", ",
    just_born="Nounat",
    stages={
        "newborn": "Nounat",
        "infant": "Nadó",
        "toddler": "Infant",
        "child": "Nen",
        "teenager": "Adolescent",
        "adult": "Adult",
    },
)
