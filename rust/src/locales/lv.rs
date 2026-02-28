use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Latvian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "lv".to_string(),
        plural: |n| {
            if n == 0 {
                PluralCategory::Zero
            } else if n % 10 == 1 && n % 100 != 11 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} dienu"),
                (PluralCategory::One, "{n} diena"),
                (PluralCategory::Other, "{n} dienas"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} nedēļu"),
                (PluralCategory::One, "{n} nedēļa"),
                (PluralCategory::Other, "{n} nedēļas"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} mēnešu"),
                (PluralCategory::One, "{n} mēnesis"),
                (PluralCategory::Other, "{n} mēneši"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} gadu"),
                (PluralCategory::One, "{n} gads"),
                (PluralCategory::Other, "{n} gadi"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Jaundzimušais".to_string(),
        stages: Stages {
            newborn: "Jaundzimušais".to_string(),
            infant: "Zīdainis".to_string(),
            toddler: "Mazulis".to_string(),
            child: "Bērns".to_string(),
            teenager: "Pusaudzis".to_string(),
            adult: "Pieaugušais".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
