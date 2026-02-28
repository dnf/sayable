use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Telugu locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "te".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} రోజు"),
                (PluralCategory::Other, "{n} రోజులు"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} వారం"),
                (PluralCategory::Other, "{n} వారాలు"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} నెల"),
                (PluralCategory::Other, "{n} నెలలు"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} సంవత్సరం"),
                (PluralCategory::Other, "{n} సంవత్సరాలు"),
            ]),
        },
        half: "{0}న్నర".to_string(),
        delimiter: ", ".to_string(),
        just_born: "నవజాత శిశువు".to_string(),
        stages: Stages {
            newborn: "నవజాత శిశువు".to_string(),
            infant: "శిశువు".to_string(),
            toddler: "చిన్న పిల్లవాడు".to_string(),
            child: "పిల్లవాడు".to_string(),
            teenager: "కౌమారదశ".to_string(),
            adult: "వయోజనుడు".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
