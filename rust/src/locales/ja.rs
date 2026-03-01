use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages, StageLabel};

/// Japanese locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ja".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n}日"),
            week: UnitForms::simple("{n}週"),
            month: UnitForms::simple("{n}ヶ月"),
            year: UnitForms::simple("{n}歳"),
        },
        half: "{0}半".to_string(),
        delimiter: String::new(),
        just_born: "新生児".to_string(),
        stages: Stages {
            newborn: StageLabel::Neutral("新生児".to_string()),
            infant: StageLabel::Neutral("乳児".to_string()),
            toddler: StageLabel::Neutral("幼児".to_string()),
            child: StageLabel::Neutral("児童".to_string()),
            teenager: StageLabel::Neutral("青少年".to_string()),
            adult: StageLabel::Neutral("成人".to_string()),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
