"""Marathi locale."""

from parent_time.locale import AgeLocale

MR = AgeLocale(
    code="mr",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} दिवस", "other": "{n} दिवस"},
        "week": {"one": "{n} आठवडा", "other": "{n} आठवडे"},
        "month": {"one": "{n} महिना", "other": "{n} महिने"},
        "year": {"one": "{n} वर्ष", "other": "{n} वर्षे"},
    },
    half="साडे {n}",
    delimiter=", ",
    just_born="नवजात",
    stages={
        "newborn": "नवजात",
        "infant": "अर्भक",
        "toddler": "बाळ",
        "child": "मूल",
        "teenager": "किशोर",
        "adult": "प्रौढ",
    },
)
