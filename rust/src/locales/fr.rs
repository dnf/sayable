use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// French locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "fr".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} jour"),
                (PluralCategory::Other, "{n} jours"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} semaine"),
                (PluralCategory::Other, "{n} semaines"),
            ]),
            month: UnitForms::simple("{n} mois"),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} an"),
                (PluralCategory::Other, "{n} ans"),
            ]),
        },
        half: "{0} et demi".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Nouveau-né".to_string(),
        stages: Stages {
            newborn: "Nouveau-né".to_string(),
            infant: "Nourrisson".to_string(),
            toddler: "Bambin".to_string(),
            child: "Enfant".to_string(),
            teenager: "Adolescent".to_string(),
            adult: "Adulte".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
