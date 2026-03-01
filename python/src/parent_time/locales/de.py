"""German locale."""

from parent_time.locale import AgeLocale

DE = AgeLocale(
    code="de",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} Tag", "other": "{n} Tage"},
        "week": {"one": "{n} Woche", "other": "{n} Wochen"},
        "month": {"one": "{n} Monat", "other": "{n} Monate"},
        "year": {"one": "{n} Jahr", "other": "{n} Jahre"},
    },
    half="{n}\u00bd",
    delimiter=", ",
    just_born="Neugeboren",
    stages={
        "newborn": "Neugeborenes",
        "infant": "S\u00e4ugling",
        "toddler": "Kleinkind",
        "child": "Kind",
        "teenager": "Teenager",
        "adult": {"m": "Erwachsener", "f": "Erwachsene"},
    },
)
