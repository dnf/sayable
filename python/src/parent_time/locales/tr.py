"""Turkish locale."""

from parent_time.locale import AgeLocale

TR = AgeLocale(
    code="tr",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} g\u00fcn", "other": "{n} g\u00fcn"},
        "week": {"one": "{n} hafta", "other": "{n} hafta"},
        "month": {"one": "{n} ay", "other": "{n} ay"},
        "year": {"one": "{n} ya\u015f", "other": "{n} ya\u015f"},
    },
    half="{n} bu\u00e7uk",
    delimiter=", ",
    just_born="Yeni do\u011fan",
    stages={
        "newborn": "Yeni do\u011fan",
        "infant": "Bebek",
        "toddler": "K\u00fc\u00e7\u00fck \u00e7ocuk",
        "child": "\u00c7ocuk",
        "teenager": "Ergen",
        "adult": "Yeti\u015fkin",
    },
)
