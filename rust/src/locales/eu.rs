use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Basque locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "eu".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} egun"),
            week: UnitForms::simple("{n} aste"),
            month: UnitForms::simple("{n} hilabete"),
            year: UnitForms::simple("{n} urte"),
        },
        half: "{0} eta erdi".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Jaioberria".to_string(),
        stages: Stages {
            newborn: "Jaioberria".to_string(),
            infant: "Haurra".to_string(),
            toddler: "Haur txikia".to_string(),
            child: "Umea".to_string(),
            teenager: "Nerabea".to_string(),
            adult: "Heldua".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
