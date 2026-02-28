use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Turkish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "tr".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} gün"),
                (PluralCategory::Other, "{n} gün"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} hafta"),
                (PluralCategory::Other, "{n} hafta"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} ay"),
                (PluralCategory::Other, "{n} ay"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} yaş"),
                (PluralCategory::Other, "{n} yaş"),
            ]),
        },
        half: "{n} buçuk".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Yeni doğan".to_string(),
        stages: Stages {
            newborn: "Yeni doğan".to_string(),
            infant: "Bebek".to_string(),
            toddler: "Küçük çocuk".to_string(),
            child: "Çocuk".to_string(),
            teenager: "Ergen".to_string(),
            adult: "Yetişkin".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
