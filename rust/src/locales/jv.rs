use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Javanese locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "jv".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} dina"),
            week: UnitForms::simple("{n} minggu"),
            month: UnitForms::simple("{n} wulan"),
            year: UnitForms::simple("{n} taun"),
        },
        half: "{0} setengah".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Bayi anyar".to_string(),
        stages: Stages {
            newborn: "Bayi anyar".to_string(),
            infant: "Bayi".to_string(),
            toddler: "Balita".to_string(),
            child: "Bocah".to_string(),
            teenager: "Remaja".to_string(),
            adult: "Diwasa".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
