use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Greek locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "el".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} μέρα"),
                (PluralCategory::Other, "{n} μέρες"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} εβδομάδα"),
                (PluralCategory::Other, "{n} εβδομάδες"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} μήνας"),
                (PluralCategory::Other, "{n} μήνες"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} χρόνος"),
                (PluralCategory::Other, "{n} χρόνια"),
            ]),
        },
        half: "{0} και μισό".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Νεογέννητο".to_string(),
        stages: Stages {
            newborn: "Νεογέννητο".to_string(),
            infant: "Βρέφος".to_string(),
            toddler: "Νήπιο".to_string(),
            child: "Παιδί".to_string(),
            teenager: "Έφηβος".to_string(),
            adult: "Ενήλικας".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
