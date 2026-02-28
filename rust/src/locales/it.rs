use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Italian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "it".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} giorno"),
                (PluralCategory::Other, "{n} giorni"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} settimana"),
                (PluralCategory::Other, "{n} settimane"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mese"),
                (PluralCategory::Other, "{n} mesi"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} anno"),
                (PluralCategory::Other, "{n} anni"),
            ]),
        },
        half: "{0} e mezzo".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Neonato".to_string(),
        stages: Stages {
            newborn: "Neonato".to_string(),
            infant: "Lattante".to_string(),
            toddler: "Bimbo".to_string(),
            child: "Bambino".to_string(),
            teenager: "Adolescente".to_string(),
            adult: "Adulto".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
