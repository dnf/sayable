use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Tamil locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "ta".to_string(),
        plural: |n| {
            if n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} நாள்"),
                (PluralCategory::Other, "{n} நாட்கள்"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} வாரம்"),
                (PluralCategory::Other, "{n} வாரங்கள்"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} மாதம்"),
                (PluralCategory::Other, "{n} மாதங்கள்"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} வயது"),
                (PluralCategory::Other, "{n} வயது"),
            ]),
        },
        half: "{0}ரை".to_string(),
        delimiter: ", ".to_string(),
        just_born: "பிறந்த குழந்தை".to_string(),
        stages: Stages {
            newborn: "பிறந்த குழந்தை".to_string(),
            infant: "குழந்தை".to_string(),
            toddler: "சிறு குழந்தை".to_string(),
            child: "சிறுவர்".to_string(),
            teenager: "இளம்பருவம்".to_string(),
            adult: "பெரியவர்".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
