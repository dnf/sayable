use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// German locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "de".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} Tag"),
                (PluralCategory::Other, "{n} Tage"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} Woche"),
                (PluralCategory::Other, "{n} Wochen"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} Monat"),
                (PluralCategory::Other, "{n} Monate"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} Jahr"),
                (PluralCategory::Other, "{n} Jahre"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Neugeboren".to_string(),
        stages: Stages {
            newborn: "Neugeborenes".to_string(),
            infant: "Säugling".to_string(),
            toddler: "Kleinkind".to_string(),
            child: "Kind".to_string(),
            teenager: "Teenager".to_string(),
            adult: "Erwachsener".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
