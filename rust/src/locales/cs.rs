use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Czech locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "cs".to_string(),
        plural: |n| {
            if n == 1 {
                PluralCategory::One
            } else if (2..=4).contains(&n) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} den"),
                (PluralCategory::Few, "{n} dny"),
                (PluralCategory::Other, "{n} dní"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} týden"),
                (PluralCategory::Few, "{n} týdny"),
                (PluralCategory::Other, "{n} týdnů"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} měsíc"),
                (PluralCategory::Few, "{n} měsíce"),
                (PluralCategory::Other, "{n} měsíců"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} rok"),
                (PluralCategory::Few, "{n} roky"),
                (PluralCategory::Other, "{n} let"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Novorozenec".to_string(),
        stages: Stages {
            newborn: "Novorozenec".to_string(),
            infant: "Kojenec".to_string(),
            toddler: "Batole".to_string(),
            child: "Dítě".to_string(),
            teenager: "Teenager".to_string(),
            adult: "Dospělý".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
