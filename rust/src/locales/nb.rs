use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Norwegian Bokmål locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "nb".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dag"),
                (PluralCategory::Other, "{n} dager"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} uke"),
                (PluralCategory::Other, "{n} uker"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} måned"),
                (PluralCategory::Other, "{n} måneder"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} år"),
                (PluralCategory::Other, "{n} år"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nyfødt".to_string(),
        stages: Stages {
            newborn: "Nyfødt".to_string(),
            infant: "Spedbarn".to_string(),
            toddler: "Småbarn".to_string(),
            child: "Barn".to_string(),
            teenager: "Tenåring".to_string(),
            adult: "Voksen".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
