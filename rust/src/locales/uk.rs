use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Ukrainian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "uk".to_string(),
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
                (PluralCategory::One, "{n} день"),
                (PluralCategory::Few, "{n} дні"),
                (PluralCategory::Many, "{n} днів"),
                (PluralCategory::Other, "{n} днів"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} тиждень"),
                (PluralCategory::Few, "{n} тижні"),
                (PluralCategory::Many, "{n} тижнів"),
                (PluralCategory::Other, "{n} тижнів"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} місяць"),
                (PluralCategory::Few, "{n} місяці"),
                (PluralCategory::Many, "{n} місяців"),
                (PluralCategory::Other, "{n} місяців"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} рік"),
                (PluralCategory::Few, "{n} роки"),
                (PluralCategory::Many, "{n} років"),
                (PluralCategory::Other, "{n} років"),
            ]),
        },
        half: "{n} з половиною".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Новонароджений".to_string(),
        stages: Stages {
            newborn: "Новонароджений".to_string(),
            infant: "Немовля".to_string(),
            toddler: "Малюк".to_string(),
            child: "Дитина".to_string(),
            teenager: "Підліток".to_string(),
            adult: "Дорослий".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
