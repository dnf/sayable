use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Slovak locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "sk".to_string(),
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
                (PluralCategory::One, "{n} deň"),
                (PluralCategory::Few, "{n} dni"),
                (PluralCategory::Other, "{n} dní"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} týždeň"),
                (PluralCategory::Few, "{n} týždne"),
                (PluralCategory::Other, "{n} týždňov"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mesiac"),
                (PluralCategory::Few, "{n} mesiace"),
                (PluralCategory::Other, "{n} mesiacov"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} rok"),
                (PluralCategory::Few, "{n} roky"),
                (PluralCategory::Other, "{n} rokov"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Novorodenec".to_string(),
        stages: Stages {
            newborn: "Novorodenec".to_string(),
            infant: "Dojča".to_string(),
            toddler: "Batoľa".to_string(),
            child: "Dieťa".to_string(),
            teenager: "Tínedžer".to_string(),
            adult: "Dospelý".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
