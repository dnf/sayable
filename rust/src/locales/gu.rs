use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Gujarati locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "gu".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} દિવસ"),
                (PluralCategory::Other, "{n} દિવસ"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} અઠવાડિયું"),
                (PluralCategory::Other, "{n} અઠવાડિયા"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} મહિનો"),
                (PluralCategory::Other, "{n} મહિના"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} વર્ષ"),
                (PluralCategory::Other, "{n} વર્ષ"),
            ]),
        },
        half: "સાડે {n}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "નવજાત".to_string(),
        stages: Stages {
            newborn: "નવજાત".to_string(),
            infant: "શિશુ".to_string(),
            toddler: "નાનું બાળક".to_string(),
            child: "બાળક".to_string(),
            teenager: "કિશોર".to_string(),
            adult: "પુખ્ત".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
