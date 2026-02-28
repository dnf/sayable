use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Bengali locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "bn".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} দিন"),
                (PluralCategory::Other, "{n} দিন"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} সপ্তাহ"),
                (PluralCategory::Other, "{n} সপ্তাহ"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} মাস"),
                (PluralCategory::Other, "{n} মাস"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} বছর"),
                (PluralCategory::Other, "{n} বছর"),
            ]),
        },
        half: "সাড়ে {n}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "নবজাতক".to_string(),
        stages: Stages {
            newborn: "নবজাতক".to_string(),
            infant: "শিশু".to_string(),
            toddler: "ছোট শিশু".to_string(),
            child: "শিশু".to_string(),
            teenager: "কিশোর".to_string(),
            adult: "প্রাপ্তবয়স্ক".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
