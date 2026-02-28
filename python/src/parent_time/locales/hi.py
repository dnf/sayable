"""Hindi locale."""

from parent_time.locale import AgeLocale

HI = AgeLocale(
    code="hi",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} दिन", "other": "{n} दिन"},
        "week": {"one": "{n} सप्ताह", "other": "{n} सप्ताह"},
        "month": {"one": "{n} महीना", "other": "{n} महीने"},
        "year": {"one": "{n} साल", "other": "{n} साल"},
    },
    half="साढ़े {n}",
    delimiter=", ",
    just_born="नवजात",
    stages={
        "newborn": "नवजात",
        "infant": "शिशु",
        "toddler": "छोटा बच्चा",
        "child": "बच्चा",
        "teenager": "किशोर",
        "adult": "वयस्क",
    },
)
