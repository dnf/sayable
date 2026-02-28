use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Albanian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "sq".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} ditë"),
                (PluralCategory::Other, "{n} ditë"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} javë"),
                (PluralCategory::Other, "{n} javë"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} muaj"),
                (PluralCategory::Other, "{n} muaj"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} vit"),
                (PluralCategory::Other, "{n} vjet"),
            ]),
        },
        half: "{0} e gjysmë".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Sapolindur".to_string(),
        stages: Stages {
            newborn: "Sapolindur".to_string(),
            infant: "Foshnjë".to_string(),
            toddler: "Fëmijë i vogël".to_string(),
            child: "Fëmijë".to_string(),
            teenager: "Adoleshent".to_string(),
            adult: "I rritur".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
