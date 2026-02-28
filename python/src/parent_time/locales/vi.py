"""Vietnamese locale."""

from parent_time.locale import AgeLocale

VI = AgeLocale(
    code="vi",
    plural=lambda _n: "other",
    units={
        "day": "{n} ngày",
        "week": "{n} tuần",
        "month": "{n} tháng",
        "year": "{n} tuổi",
    },
    half="{0} rưỡi",
    delimiter=", ",
    just_born="Sơ sinh",
    stages={
        "newborn": "Sơ sinh",
        "infant": "Trẻ sơ sinh",
        "toddler": "Trẻ mới biết đi",
        "child": "Trẻ em",
        "teenager": "Thiếu niên",
        "adult": "Người lớn",
    },
)
