use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Swedish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "sv".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dag"),
                (PluralCategory::Other, "{n} dagar"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} vecka"),
                (PluralCategory::Other, "{n} veckor"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} månad"),
                (PluralCategory::Other, "{n} månader"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} år"),
                (PluralCategory::Other, "{n} år"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nyfödd".to_string(),
        stages: Stages {
            newborn: "Nyfödd".to_string(),
            infant: "Spädbarn".to_string(),
            toddler: "Litet barn".to_string(),
            child: "Barn".to_string(),
            teenager: "Tonåring".to_string(),
            adult: "Vuxen".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
