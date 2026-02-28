use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Vietnamese locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "vi".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} ngày"),
            week: UnitForms::simple("{n} tuần"),
            month: UnitForms::simple("{n} tháng"),
            year: UnitForms::simple("{n} tuổi"),
        },
        half: "{0} rưỡi".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Sơ sinh".to_string(),
        stages: Stages {
            newborn: "Sơ sinh".to_string(),
            infant: "Trẻ sơ sinh".to_string(),
            toddler: "Trẻ mới biết đi".to_string(),
            child: "Trẻ em".to_string(),
            teenager: "Thiếu niên".to_string(),
            adult: "Người lớn".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
