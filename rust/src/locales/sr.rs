use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages, StageLabel};

/// Serbian (Cyrillic) locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "sr".to_string(),
        plural: |n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=4).contains(&mod10) && !(12..=14).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} дан"),
                (PluralCategory::Few, "{n} дана"),
                (PluralCategory::Many, "{n} дана"),
                (PluralCategory::Other, "{n} дана"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} недеља"),
                (PluralCategory::Few, "{n} недеље"),
                (PluralCategory::Many, "{n} недеља"),
                (PluralCategory::Other, "{n} недеља"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} месец"),
                (PluralCategory::Few, "{n} месеца"),
                (PluralCategory::Many, "{n} месеци"),
                (PluralCategory::Other, "{n} месеци"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} година"),
                (PluralCategory::Few, "{n} године"),
                (PluralCategory::Many, "{n} година"),
                (PluralCategory::Other, "{n} година"),
            ]),
        },
        half: "{0} и по".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Новорођенче".to_string(),
        stages: Stages {
            newborn: StageLabel::Neutral("Новорођенче".to_string()),
            infant: StageLabel::Neutral("Одојче".to_string()),
            toddler: StageLabel::Neutral("Мало дете".to_string()),
            child: StageLabel::Neutral("Дете".to_string()),
            teenager: StageLabel::Neutral("Тинејџер".to_string()),
            adult: StageLabel::Neutral("Одрасла особа".to_string()),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
