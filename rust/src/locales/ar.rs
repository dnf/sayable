use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Arabic locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ar".to_string(),
        plural: |n| {
            if n == 0 {
                PluralCategory::Zero
            } else if n == 1 {
                PluralCategory::One
            } else if n == 2 {
                PluralCategory::Two
            } else {
                let mod100 = n % 100;
                if (3..=10).contains(&mod100) {
                    PluralCategory::Few
                } else if (11..=99).contains(&mod100) {
                    PluralCategory::Many
                } else {
                    PluralCategory::Other
                }
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} \u{064A}\u{0648}\u{0645}"),
                (PluralCategory::One, "\u{064A}\u{0648}\u{0645}"),
                (PluralCategory::Two, "\u{064A}\u{0648}\u{0645}\u{0627}\u{0646}"),
                (PluralCategory::Few, "{n} \u{0623}\u{064A}\u{0627}\u{0645}"),
                (PluralCategory::Many, "{n} \u{064A}\u{0648}\u{0645}\u{064B}\u{0627}"),
                (PluralCategory::Other, "{n} \u{064A}\u{0648}\u{0645}"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} \u{0623}\u{0633}\u{0628}\u{0648}\u{0639}"),
                (PluralCategory::One, "\u{0623}\u{0633}\u{0628}\u{0648}\u{0639}"),
                (PluralCategory::Two, "\u{0623}\u{0633}\u{0628}\u{0648}\u{0639}\u{0627}\u{0646}"),
                (PluralCategory::Few, "{n} \u{0623}\u{0633}\u{0627}\u{0628}\u{064A}\u{0639}"),
                (PluralCategory::Many, "{n} \u{0623}\u{0633}\u{0628}\u{0648}\u{0639}\u{064B}\u{0627}"),
                (PluralCategory::Other, "{n} \u{0623}\u{0633}\u{0628}\u{0648}\u{0639}"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} \u{0634}\u{0647}\u{0631}"),
                (PluralCategory::One, "\u{0634}\u{0647}\u{0631}"),
                (PluralCategory::Two, "\u{0634}\u{0647}\u{0631}\u{0627}\u{0646}"),
                (PluralCategory::Few, "{n} \u{0623}\u{0634}\u{0647}\u{0631}"),
                (PluralCategory::Many, "{n} \u{0634}\u{0647}\u{0631}\u{064B}\u{0627}"),
                (PluralCategory::Other, "{n} \u{0634}\u{0647}\u{0631}"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::Zero, "{n} \u{0633}\u{0646}\u{0629}"),
                (PluralCategory::One, "\u{0633}\u{0646}\u{0629}"),
                (PluralCategory::Two, "\u{0633}\u{0646}\u{062A}\u{0627}\u{0646}"),
                (PluralCategory::Few, "{n} \u{0633}\u{0646}\u{0648}\u{0627}\u{062A}"),
                (PluralCategory::Many, "{n} \u{0633}\u{0646}\u{0629}"),
                (PluralCategory::Other, "{n} \u{0633}\u{0646}\u{0629}"),
            ]),
        },
        half: "{0} \u{0648}\u{0646}\u{0635}\u{0641}".to_string(),
        delimiter: " \u{0648}".to_string(),
        just_born: "\u{062D}\u{062F}\u{064A}\u{062B} \u{0627}\u{0644}\u{0648}\u{0644}\u{0627}\u{062F}\u{0629}".to_string(),
        stages: Stages {
            newborn: "\u{062D}\u{062F}\u{064A}\u{062B} \u{0627}\u{0644}\u{0648}\u{0644}\u{0627}\u{062F}\u{0629}".to_string(),
            infant: "\u{0631}\u{0636}\u{064A}\u{0639}".to_string(),
            toddler: "\u{0637}\u{0641}\u{0644} \u{0635}\u{063A}\u{064A}\u{0631}".to_string(),
            child: "\u{0637}\u{0641}\u{0644}".to_string(),
            teenager: "\u{0645}\u{0631}\u{0627}\u{0647}\u{0642}".to_string(),
            adult: "\u{0628}\u{0627}\u{0644}\u{063A}".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
