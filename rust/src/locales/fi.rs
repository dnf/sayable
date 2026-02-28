use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Finnish locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "fi".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} päivä"),
                (PluralCategory::Other, "{n} päivää"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} viikko"),
                (PluralCategory::Other, "{n} viikkoa"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} kuukausi"),
                (PluralCategory::Other, "{n} kuukautta"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} vuosi"),
                (PluralCategory::Other, "{n} vuotta"),
            ]),
        },
        half: "{n} ja puoli".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Vastasyntynyt".to_string(),
        stages: Stages {
            newborn: "Vastasyntynyt".to_string(),
            infant: "Vauva".to_string(),
            toddler: "Taapero".to_string(),
            child: "Lapsi".to_string(),
            teenager: "Teini".to_string(),
            adult: "Aikuinen".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
