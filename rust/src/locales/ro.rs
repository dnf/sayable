use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Romanian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ro".to_string(),
        plural: |n| {
            if n == 1 {
                PluralCategory::One
            } else {
                let mod100 = n % 100;
                if n == 0 || (1..=19).contains(&mod100) {
                    PluralCategory::Few
                } else {
                    PluralCategory::Other
                }
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} zi"),
                (PluralCategory::Few, "{n} zile"),
                (PluralCategory::Other, "{n} de zile"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} săptămână"),
                (PluralCategory::Few, "{n} săptămâni"),
                (PluralCategory::Other, "{n} de săptămâni"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} lună"),
                (PluralCategory::Few, "{n} luni"),
                (PluralCategory::Other, "{n} de luni"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} an"),
                (PluralCategory::Few, "{n} ani"),
                (PluralCategory::Other, "{n} de ani"),
            ]),
        },
        half: "{0} și jumătate".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nou-născut".to_string(),
        stages: Stages {
            newborn: "Nou-născut".to_string(),
            infant: "Sugar".to_string(),
            toddler: "Copil mic".to_string(),
            child: "Copil".to_string(),
            teenager: "Adolescent".to_string(),
            adult: "Adult".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
