"""Greek locale."""

from parent_time.locale import AgeLocale

EL = AgeLocale(
    code="el",
    plural=lambda n: "one" if n == 1 else "other",
    units={
        "day": {"one": "{n} μέρα", "other": "{n} μέρες"},
        "week": {"one": "{n} εβδομάδα", "other": "{n} εβδομάδες"},
        "month": {"one": "{n} μήνας", "other": "{n} μήνες"},
        "year": {"one": "{n} χρόνος", "other": "{n} χρόνια"},
    },
    half="{0} και μισό",
    delimiter=", ",
    just_born="Νεογέννητο",
    stages={
        "newborn": "Νεογέννητο",
        "infant": "Βρέφος",
        "toddler": "Νήπιο",
        "child": "Παιδί",
        "teenager": "Έφηβος",
        "adult": "Ενήλικας",
    },
)
