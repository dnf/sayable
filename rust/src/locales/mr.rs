use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Marathi locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "mr".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} दिवस"),
                (PluralCategory::Other, "{n} दिवस"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} आठवडा"),
                (PluralCategory::Other, "{n} आठवडे"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} महिना"),
                (PluralCategory::Other, "{n} महिने"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} वर्ष"),
                (PluralCategory::Other, "{n} वर्षे"),
            ]),
        },
        half: "साडे {n}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "नवजात".to_string(),
        stages: Stages {
            newborn: "नवजात".to_string(),
            infant: "अर्भक".to_string(),
            toddler: "बाळ".to_string(),
            child: "मूल".to_string(),
            teenager: "किशोर".to_string(),
            adult: "प्रौढ".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
