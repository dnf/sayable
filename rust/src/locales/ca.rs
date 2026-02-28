use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Catalan locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ca".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dia"),
                (PluralCategory::Other, "{n} dies"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} setmana"),
                (PluralCategory::Other, "{n} setmanes"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mes"),
                (PluralCategory::Other, "{n} mesos"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} any"),
                (PluralCategory::Other, "{n} anys"),
            ]),
        },
        half: "{n} i mig".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nounat".to_string(),
        stages: Stages {
            newborn: "Nounat".to_string(),
            infant: "Nadó".to_string(),
            toddler: "Infant".to_string(),
            child: "Nen".to_string(),
            teenager: "Adolescent".to_string(),
            adult: "Adult".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
