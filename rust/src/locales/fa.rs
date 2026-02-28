use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Persian (Farsi) locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "fa".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} روز"),
                (PluralCategory::Other, "{n} روز"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} هفته"),
                (PluralCategory::Other, "{n} هفته"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} ماه"),
                (PluralCategory::Other, "{n} ماه"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} سال"),
                (PluralCategory::Other, "{n} سال"),
            ]),
        },
        half: "{0} و نیم".to_string(),
        delimiter: " و ".to_string(),
        just_born: "نوزاد".to_string(),
        stages: Stages {
            newborn: "نوزاد".to_string(),
            infant: "شیرخوار".to_string(),
            toddler: "نوپا".to_string(),
            child: "کودک".to_string(),
            teenager: "نوجوان".to_string(),
            adult: "بزرگسال".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
