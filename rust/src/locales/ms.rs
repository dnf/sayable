use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Malay locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ms".to_string(),
        plural: |_n| PluralCategory::Other,
        units: Units {
            day: UnitForms::simple("{n} hari"),
            week: UnitForms::simple("{n} minggu"),
            month: UnitForms::simple("{n} bulan"),
            year: UnitForms::simple("{n} tahun"),
        },
        half: "{0} setengah".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Baru lahir".to_string(),
        stages: Stages {
            newborn: "Baru lahir".to_string(),
            infant: "Bayi".to_string(),
            toddler: "Kanak-kanak kecil".to_string(),
            child: "Kanak-kanak".to_string(),
            teenager: "Remaja".to_string(),
            adult: "Dewasa".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
