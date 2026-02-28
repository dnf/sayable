use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Urdu locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ur".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} دن"),
                (PluralCategory::Other, "{n} دن"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} ہفتہ"),
                (PluralCategory::Other, "{n} ہفتے"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} مہینہ"),
                (PluralCategory::Other, "{n} مہینے"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} سال"),
                (PluralCategory::Other, "{n} سال"),
            ]),
        },
        half: "ساڑھے {n}".to_string(),
        delimiter: "، ".to_string(),
        just_born: "نومولود".to_string(),
        stages: Stages {
            newborn: "نومولود".to_string(),
            infant: "شیرخوار".to_string(),
            toddler: "چھوٹا بچہ".to_string(),
            child: "بچہ".to_string(),
            teenager: "نوجوان".to_string(),
            adult: "بالغ".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
