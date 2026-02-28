"""Urdu locale."""

from parent_time.locale import AgeLocale

UR = AgeLocale(
    code="ur",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} دن", "other": "{n} دن"},
        "week": {"one": "{n} ہفتہ", "other": "{n} ہفتے"},
        "month": {"one": "{n} مہینہ", "other": "{n} مہینے"},
        "year": {"one": "{n} سال", "other": "{n} سال"},
    },
    half="ساڑھے {n}",
    delimiter="، ",
    just_born="نومولود",
    stages={
        "newborn": "نومولود",
        "infant": "شیرخوار",
        "toddler": "چھوٹا بچہ",
        "child": "بچہ",
        "teenager": "نوجوان",
        "adult": "بالغ",
    },
)
