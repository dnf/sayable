use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Hungarian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "hu".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} nap"),
            week: UnitForms::simple("{n} hét"),
            month: UnitForms::simple("{n} hónap"),
            year: UnitForms::simple("{n} év"),
        },
        half: "{n} és fél".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Újszülött".to_string(),
        stages: Stages {
            newborn: "Újszülött".to_string(),
            infant: "Csecsemő".to_string(),
            toddler: "Kisgyermek".to_string(),
            child: "Gyermek".to_string(),
            teenager: "Tinédzser".to_string(),
            adult: "Felnőtt".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
