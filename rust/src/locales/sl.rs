use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Slovenian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "sl".to_string(),
        plural: |n| {
            let mod100 = n % 100;
            if mod100 == 1 {
                PluralCategory::One
            } else if mod100 == 2 {
                PluralCategory::Two
            } else if mod100 == 3 || mod100 == 4 {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dan"),
                (PluralCategory::Two, "{n} dneva"),
                (PluralCategory::Few, "{n} dni"),
                (PluralCategory::Other, "{n} dni"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} teden"),
                (PluralCategory::Two, "{n} tedna"),
                (PluralCategory::Few, "{n} tedne"),
                (PluralCategory::Other, "{n} tednov"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mesec"),
                (PluralCategory::Two, "{n} meseca"),
                (PluralCategory::Few, "{n} mesece"),
                (PluralCategory::Other, "{n} mesecev"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} leto"),
                (PluralCategory::Two, "{n} leti"),
                (PluralCategory::Few, "{n} leta"),
                (PluralCategory::Other, "{n} let"),
            ]),
        },
        half: "{0} in pol".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Novorojenček".to_string(),
        stages: Stages {
            newborn: "Novorojenček".to_string(),
            infant: "Dojenček".to_string(),
            toddler: "Malček".to_string(),
            child: "Otrok".to_string(),
            teenager: "Najstnik".to_string(),
            adult: "Odrasel".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
