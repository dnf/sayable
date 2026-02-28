use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Dutch locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "nl".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dag"),
                (PluralCategory::Other, "{n} dagen"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} week"),
                (PluralCategory::Other, "{n} weken"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} maand"),
                (PluralCategory::Other, "{n} maanden"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} jaar"),
                (PluralCategory::Other, "{n} jaar"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Pasgeboren".to_string(),
        stages: Stages {
            newborn: "Pasgeborene".to_string(),
            infant: "Baby".to_string(),
            toddler: "Peuter".to_string(),
            child: "Kind".to_string(),
            teenager: "Tiener".to_string(),
            adult: "Volwassene".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
