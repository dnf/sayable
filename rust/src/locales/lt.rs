use crate::types::{AgeLocale, PluralCategory, Units, UnitForms, Stages};

/// Lithuanian locale.
pub fn locale() -> AgeLocale {
    AgeLocale {
        code: "lt".to_string(),
        plural: |n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 {
                PluralCategory::One
            } else if (2..=9).contains(&mod10) && !(12..=19).contains(&mod100) {
                PluralCategory::Few
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} diena"),
                (PluralCategory::Few, "{n} dienos"),
                (PluralCategory::Other, "{n} dienų"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} savaitė"),
                (PluralCategory::Few, "{n} savaitės"),
                (PluralCategory::Other, "{n} savaičių"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mėnuo"),
                (PluralCategory::Few, "{n} mėnesiai"),
                (PluralCategory::Other, "{n} mėnesių"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} metai"),
                (PluralCategory::Few, "{n} metai"),
                (PluralCategory::Other, "{n} metų"),
            ]),
        },
        half: "{n}\u{00BD}".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Naujagimis".to_string(),
        stages: Stages {
            newborn: "Naujagimis".to_string(),
            infant: "Kūdikis".to_string(),
            toddler: "Mažylis".to_string(),
            child: "Vaikas".to_string(),
            teenager: "Paauglys".to_string(),
            adult: "Suaugęs".to_string(),
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    }
}
