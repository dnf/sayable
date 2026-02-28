"""Persian (Farsi) locale."""

from parent_time.locale import AgeLocale

FA = AgeLocale(
    code="fa",
    plural=lambda n: "one" if n in (0, 1) else "other",
    units={
        "day": {"one": "{n} روز", "other": "{n} روز"},
        "week": {"one": "{n} هفته", "other": "{n} هفته"},
        "month": {"one": "{n} ماه", "other": "{n} ماه"},
        "year": {"one": "{n} سال", "other": "{n} سال"},
    },
    half="{0} و نیم",
    delimiter=" و ",
    just_born="نوزاد",
    stages={
        "newborn": "نوزاد",
        "infant": "شیرخوار",
        "toddler": "نوپا",
        "child": "کودک",
        "teenager": "نوجوان",
        "adult": "بزرگسال",
    },
)
