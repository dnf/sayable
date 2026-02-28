use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Irish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ga".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} lá"),
            week: UnitForms::simple("{n} seachtain"),
            month: UnitForms::simple("{n} mí"),
            year: UnitForms::simple("{n} bliain"),
        },
        half: "{0} go leith".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nuabheirthe".to_string(),
        stages: Stages {
            newborn: "Nuabheirthe".to_string(),
            infant: "Naíonán".to_string(),
            toddler: "Lapadán".to_string(),
            child: "Páiste".to_string(),
            teenager: "Déagóir".to_string(),
            adult: "Duine fásta".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
