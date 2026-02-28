use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Spanish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "es".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} día"),
                (PluralCategory::Other, "{n} días"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} semana"),
                (PluralCategory::Other, "{n} semanas"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mes"),
                (PluralCategory::Other, "{n} meses"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} año"),
                (PluralCategory::Other, "{n} años"),
            ]),
        },
        half: "{n} y medio".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Recién nacido".to_string(),
        stages: Stages {
            newborn: "Recién nacido".to_string(),
            infant: "Bebé".to_string(),
            toddler: "Niño pequeño".to_string(),
            child: "Niño".to_string(),
            teenager: "Adolescente".to_string(),
            adult: "Adulto".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
