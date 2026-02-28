"""Punjabi locale."""

from parent_time.locale import AgeLocale

PA = AgeLocale(
    code="pa",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} ਦਿਨ", "other": "{n} ਦਿਨ"},
        "week": {"one": "{n} ਹਫ਼ਤਾ", "other": "{n} ਹਫ਼ਤੇ"},
        "month": {"one": "{n} ਮਹੀਨਾ", "other": "{n} ਮਹੀਨੇ"},
        "year": {"one": "{n} ਸਾਲ", "other": "{n} ਸਾਲ"},
    },
    half="ਸਾਢੇ {n}",
    delimiter=", ",
    just_born="ਨਵਜੰਮਿਆ",
    stages={
        "newborn": "ਨਵਜੰਮਿਆ",
        "infant": "ਸ਼ਿਸ਼ੂ",
        "toddler": "ਛੋਟਾ ਬੱਚਾ",
        "child": "ਬੱਚਾ",
        "teenager": "ਕਿਸ਼ੋਰ",
        "adult": "ਬਾਲਗ",
    },
)
