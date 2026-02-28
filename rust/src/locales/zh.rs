use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Chinese locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "zh".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n}天"),
            week: UnitForms::simple("{n}周"),
            month: UnitForms::simple("{n}个月"),
            year: UnitForms::simple("{n}岁"),
        },
        half: "{0}半".to_string(),
        delimiter: String::new(),
        just_born: "新生儿".to_string(),
        stages: Stages {
            newborn: "新生儿".to_string(),
            infant: "婴儿".to_string(),
            toddler: "幼儿".to_string(),
            child: "儿童".to_string(),
            teenager: "青少年".to_string(),
            adult: "成人".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
