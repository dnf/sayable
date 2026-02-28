use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Polish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "pl".to_string(),
        plural: |n| {
            if n == 1 {
                PluralCategory::One
            } else {
                let mod10 = n % 10;
                let mod100 = n % 100;
                if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                    PluralCategory::Few
                } else {
                    PluralCategory::Many
                }
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dzień"),
                (PluralCategory::Few, "{n} dni"),
                (PluralCategory::Many, "{n} dni"),
                (PluralCategory::Other, "{n} dni"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} tydzień"),
                (PluralCategory::Few, "{n} tygodnie"),
                (PluralCategory::Many, "{n} tygodni"),
                (PluralCategory::Other, "{n} tygodni"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} miesiąc"),
                (PluralCategory::Few, "{n} miesiące"),
                (PluralCategory::Many, "{n} miesięcy"),
                (PluralCategory::Other, "{n} miesięcy"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} rok"),
                (PluralCategory::Few, "{n} lata"),
                (PluralCategory::Many, "{n} lat"),
                (PluralCategory::Other, "{n} lat"),
            ]),
        },
        half: "{n} i pół".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Noworodek".to_string(),
        stages: Stages {
            newborn: "Noworodek".to_string(),
            infant: "Niemowlę".to_string(),
            toddler: "Maluch".to_string(),
            child: "Dziecko".to_string(),
            teenager: "Nastolatek".to_string(),
            adult: "Dorosły".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
