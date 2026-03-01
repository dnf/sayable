use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages, StageLabel};

/// Punjabi locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "pa".to_string(),
        plural: |n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} ਦਿਨ"),
                (PluralCategory::Other, "{n} ਦਿਨ"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} ਹਫ਼ਤਾ"),
                (PluralCategory::Other, "{n} ਹਫ਼ਤੇ"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} ਮਹੀਨਾ"),
                (PluralCategory::Other, "{n} ਮਹੀਨੇ"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} ਸਾਲ"),
                (PluralCategory::Other, "{n} ਸਾਲ"),
            ]),
        },
        half: "ਸਾਢੇ {n}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "ਨਵਜੰਮਿਆ".to_string(),
        stages: Stages {
            newborn: StageLabel::Gendered { m: "ਨਵਜੰਮਿਆ".to_string(), f: "ਨਵਜੰਮੀ".to_string() },
            infant: StageLabel::Neutral("ਸ਼ਿਸ਼ੂ".to_string()),
            toddler: StageLabel::Gendered { m: "ਛੋਟਾ ਬੱਚਾ".to_string(), f: "ਛੋਟੀ ਬੱਚੀ".to_string() },
            child: StageLabel::Gendered { m: "ਬੱਚਾ".to_string(), f: "ਬੱਚੀ".to_string() },
            teenager: StageLabel::Gendered { m: "ਕਿਸ਼ੋਰ".to_string(), f: "ਕਿਸ਼ੋਰੀ".to_string() },
            adult: StageLabel::Neutral("ਬਾਲਗ".to_string()),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
