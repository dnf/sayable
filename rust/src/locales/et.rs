use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Estonian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "et".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} päev"),
                (PluralCategory::Other, "{n} päeva"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} nädal"),
                (PluralCategory::Other, "{n} nädalat"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} kuu"),
                (PluralCategory::Other, "{n} kuud"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} aasta"),
                (PluralCategory::Other, "{n} aastat"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Vastsündinu".to_string(),
        stages: Stages {
            newborn: "Vastsündinu".to_string(),
            infant: "Imik".to_string(),
            toddler: "Väikelaps".to_string(),
            child: "Laps".to_string(),
            teenager: "Teismeline".to_string(),
            adult: "Täiskasvanu".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
