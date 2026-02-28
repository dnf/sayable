use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Portuguese locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "pt".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} dia"),
                (PluralCategory::Other, "{n} dias"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} semana"),
                (PluralCategory::Other, "{n} semanas"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mês"),
                (PluralCategory::Other, "{n} meses"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} ano"),
                (PluralCategory::Other, "{n} anos"),
            ]),
        },
        half: "{0} e meio".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Recém-nascido".to_string(),
        stages: Stages {
            newborn: "Recém-nascido".to_string(),
            infant: "Bebê".to_string(),
            toddler: "Criança pequena".to_string(),
            child: "Criança".to_string(),
            teenager: "Adolescente".to_string(),
            adult: "Adulto".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
