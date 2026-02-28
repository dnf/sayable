use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Croatian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "hr".to_string(),
        plural: |n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Many
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dan"),
                (PluralCategory::Few, "{n} dana"),
                (PluralCategory::Many, "{n} dana"),
                (PluralCategory::Other, "{n} dana"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} tjedan"),
                (PluralCategory::Few, "{n} tjedna"),
                (PluralCategory::Many, "{n} tjedana"),
                (PluralCategory::Other, "{n} tjedana"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mjesec"),
                (PluralCategory::Few, "{n} mjeseca"),
                (PluralCategory::Many, "{n} mjeseci"),
                (PluralCategory::Other, "{n} mjeseci"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} godina"),
                (PluralCategory::Few, "{n} godine"),
                (PluralCategory::Many, "{n} godina"),
                (PluralCategory::Other, "{n} godina"),
            ]),
        },
        half: "{0} i pol".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Novorođenče".to_string(),
        stages: Stages {
            newborn: "Novorođenče".to_string(),
            infant: "Dojenče".to_string(),
            toddler: "Malo dijete".to_string(),
            child: "Dijete".to_string(),
            teenager: "Tinejdžer".to_string(),
            adult: "Odrasla osoba".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
