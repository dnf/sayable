use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Korean locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ko".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n}일"),
            week: UnitForms::simple("{n}주"),
            month: UnitForms::simple("{n}개월"),
            year: UnitForms::simple("{n}살"),
        },
        half: "{0} 반".to_string(),
        delimiter: " ".to_string(),
        just_born: "신생아".to_string(),
        stages: Stages {
            newborn: "신생아".to_string(),
            infant: "영아".to_string(),
            toddler: "유아".to_string(),
            child: "아동".to_string(),
            teenager: "청소년".to_string(),
            adult: "성인".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
