"""Irish locale."""

from parent_time.locale import AgeLocale

GA = AgeLocale(
    code="ga",
    plural=lambda _n: "other",
    units={
        "day": "{n} lá",
        "week": "{n} seachtain",
        "month": "{n} mí",
        "year": "{n} bliain",
    },
    half="{0} go leith",
    delimiter=", ",
    just_born="Nuabheirthe",
    stages={
        "newborn": "Nuabheirthe",
        "infant": "Naíonán",
        "toddler": "Lapadán",
        "child": "Páiste",
        "teenager": "Déagóir",
        "adult": "Duine fásta",
    },
)
