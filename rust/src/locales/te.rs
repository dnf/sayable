use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages, StageLabel};

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
            newborn: StageLabel::Neutral("నవజాత శిశువు".to_string()),
            infant: StageLabel::Neutral("శిశువు".to_string()),
            toddler: StageLabel::Neutral("చిన్న బిడ్డ".to_string()),
            child: StageLabel::Neutral("బిడ్డ".to_string()),
            teenager: StageLabel::Neutral("కౌమారదశ".to_string()),
            adult: StageLabel::Neutral("వయోజనులు".to_string()),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
