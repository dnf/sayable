#![allow(missing_docs)]

use parent_time::formatter::{format_age, format_stage, ParentTime};
use parent_time::locales;
use parent_time::types::*;
use parent_time::Gender;

// ================================================================
// Helper functions
// ================================================================

fn assert_age(name: &str, got: Option<String>, want: &str) {
    match got {
        None => panic!("{name}: got None, want {want:?}"),
        Some(ref s) => assert_eq!(s, want, "{name}: got {s:?}, want {want:?}"),
    }
}

fn assert_nil(name: &str, got: Option<String>) {
    if let Some(ref s) = got {
        panic!("{name}: got {s:?}, want None");
    }
}

fn assert_contains(name: &str, got: Option<String>, substr: &str) {
    match got {
        None => panic!("{name}: got None, want string containing {substr:?}"),
        Some(ref s) => {
            assert!(
                s.contains(substr),
                "{name}: got {s:?}, want string containing {substr:?}"
            );
        }
    }
}

// ================================================================
// formatAge -- null/edge cases
// ================================================================
#[test]
fn test_format_age_null_edge_cases() {
    assert_nil("empty string", format_age("", Some("2025-06-15")));
    assert_nil("future dob", format_age("2025-07-01", Some("2025-06-15")));
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
#[test]
fn test_format_age_days_tier() {
    let tests = vec![
        ("born today", "2025-06-15", "2025-06-15", "Newborn"),
        ("1 day ago (singular)", "2025-06-14", "2025-06-15", "1 day"),
        ("3 days ago", "2025-06-12", "2025-06-15", "3 days"),
        ("6 days ago", "2025-06-09", "2025-06-15", "6 days"),
        ("7 days -> 1 week", "2025-06-08", "2025-06-15", "1 week"),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- weeks+days tier (7 days to <3 months)
// ================================================================
#[test]
fn test_format_age_weeks_days_tier() {
    let tests = vec![
        ("7 days", "2025-06-08", "2025-06-15", "1 week"),
        ("8 days", "2025-06-07", "2025-06-15", "1 week, 1 day"),
        ("9 days", "2025-06-06", "2025-06-15", "1 week, 2 days"),
        ("13 days", "2025-06-02", "2025-06-15", "1 week, 6 days"),
        ("14 days", "2025-06-01", "2025-06-15", "2 weeks"),
        ("15 days", "2025-05-31", "2025-06-15", "2 weeks, 1 day"),
        ("20 days", "2025-05-26", "2025-06-15", "2 weeks, 6 days"),
        ("21 days", "2025-05-25", "2025-06-15", "3 weeks"),
        (
            "at 1 cal month still weeks+days",
            "2025-05-15",
            "2025-06-15",
            "4 weeks, 3 days",
        ),
        (
            "at 2 cal months still weeks+days",
            "2025-04-15",
            "2025-06-15",
            "8 weeks, 5 days",
        ),
        (
            "one day before 3mo still weeks",
            "2025-03-15",
            "2025-06-14",
            "13 weeks",
        ),
        (
            "on 3mo birthday switches",
            "2025-03-15",
            "2025-06-15",
            "3 months",
        ),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================
#[test]
fn test_format_age_month_boundary_standard() {
    assert_age(
        "Jan1 -> Apr1 = 3mo",
        format_age("2025-01-01", Some("2025-04-01")),
        "3 months",
    );
    assert_contains(
        "Jan1 -> Mar31 still weeks",
        format_age("2025-01-01", Some("2025-03-31")),
        "weeks",
    );
    assert_age(
        "Jun15 -> Sep15 = 3mo",
        format_age("2025-06-15", Some("2025-09-15")),
        "3 months",
    );
    assert_contains(
        "Jun15 -> Sep14 still weeks",
        format_age("2025-06-15", Some("2025-09-14")),
        "weeks",
    );
    assert_age(
        "Jun15 -> Dec15 = 6mo",
        format_age("2025-06-15", Some("2025-12-15")),
        "6 months",
    );
}

// ================================================================
// formatAge -- month boundaries: February non-leap
// ================================================================
#[test]
fn test_format_age_month_boundary_feb_non_leap() {
    assert_age(
        "Jan31 -> Feb28 non-leap",
        format_age("2025-01-31", Some("2025-02-28")),
        "4 weeks",
    );
    assert_age(
        "Jan31 -> Apr30 = 3mo (clamp)",
        format_age("2025-01-31", Some("2025-04-30")),
        "3 months",
    );
    assert_contains(
        "Jan31 -> Apr29 still weeks",
        format_age("2025-01-31", Some("2025-04-29")),
        "weeks",
    );
    assert_age(
        "Feb1 -> May1 = 3mo",
        format_age("2025-02-01", Some("2025-05-01")),
        "3 months",
    );
    assert_contains(
        "Feb1 -> Apr30 still weeks",
        format_age("2025-02-01", Some("2025-04-30")),
        "weeks",
    );
}

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================
#[test]
fn test_format_age_month_boundary_feb_leap() {
    assert_age(
        "Jan31 -> Feb29 leap",
        format_age("2024-01-31", Some("2024-02-29")),
        "4 weeks, 1 day",
    );
    assert_age(
        "Jan31 -> Feb28 leap",
        format_age("2024-01-31", Some("2024-02-28")),
        "4 weeks",
    );
    assert_age(
        "Jan31 -> Apr30 leap = 3mo",
        format_age("2024-01-31", Some("2024-04-30")),
        "3 months",
    );
    assert_contains(
        "Jan30 -> Feb29 leap still weeks",
        format_age("2024-01-30", Some("2024-02-29")),
        "weeks",
    );
    assert_contains(
        "Jan30 -> Feb28 leap still weeks",
        format_age("2024-01-30", Some("2024-02-28")),
        "weeks",
    );
}

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================
#[test]
fn test_format_age_month_boundary_30_day() {
    assert_age(
        "Mar31 -> Jun30 = 3mo (clamped)",
        format_age("2025-03-31", Some("2025-06-30")),
        "3 months",
    );
    assert_contains(
        "Mar31 -> Jun29 still weeks",
        format_age("2025-03-31", Some("2025-06-29")),
        "weeks",
    );
    assert_age(
        "Aug31 -> Nov30 = 3mo",
        format_age("2025-08-31", Some("2025-11-30")),
        "3 months",
    );
    assert_contains(
        "Aug31 -> Nov29 still weeks",
        format_age("2025-08-31", Some("2025-11-29")),
        "weeks",
    );
}

// ================================================================
// formatAge -- month boundaries: leap year baby (born Feb 29)
// ================================================================
#[test]
fn test_format_age_leap_year_baby() {
    assert_age(
        "Feb29 -> May29 = 3mo",
        format_age("2024-02-29", Some("2024-05-29")),
        "3 months",
    );
    assert_contains(
        "Feb29 -> May28 still weeks",
        format_age("2024-02-29", Some("2024-05-28")),
        "weeks",
    );
    assert_age(
        "Feb29 2024 -> Feb28 2025 = 12mo",
        format_age("2024-02-29", Some("2025-02-28")),
        "12 months",
    );
    assert_age(
        "Feb29 2024 -> Mar1 2025 = 12mo",
        format_age("2024-02-29", Some("2025-03-01")),
        "12 months",
    );
}

// ================================================================
// formatAge -- months tier (3-23)
// ================================================================
#[test]
fn test_format_age_months_tier() {
    let tests = vec![
        (
            "3 months at transition",
            "2025-01-15",
            "2025-04-15",
            "3 months",
        ),
        ("6 months", "2025-01-15", "2025-07-15", "6 months"),
        (
            "12 months (not 1 year)",
            "2024-06-15",
            "2025-06-15",
            "12 months",
        ),
        (
            "23 months at upper",
            "2024-01-15",
            "2025-12-15",
            "23 months",
        ),
        (
            "one day before boundary",
            "2025-01-15",
            "2025-07-14",
            "5 months",
        ),
        (
            "crossing year boundary",
            "2024-11-10",
            "2025-04-10",
            "5 months",
        ),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================
#[test]
fn test_format_age_years_months_tier() {
    let tests = vec![
        ("2 years at 24mo", "2023-06-15", "2025-06-15", "2 years"),
        (
            "2 years 1 month",
            "2023-06-15",
            "2025-07-15",
            "2 years, 1 month",
        ),
        (
            "2 years 6 months",
            "2023-06-15",
            "2025-12-15",
            "2 years, 6 months",
        ),
        (
            "2 years 11 months",
            "2023-06-15",
            "2026-05-15",
            "2 years, 11 months",
        ),
        (
            "one day before 24mo",
            "2023-06-15",
            "2025-06-14",
            "23 months",
        ),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================
#[test]
fn test_format_age_half_year_tier() {
    let tests = vec![
        ("3 years exactly", "2022-06-15", "2025-06-15", "3 years"),
        ("3 years 5 months", "2022-06-15", "2025-11-15", "3 years"),
        (
            "3\u{00BD} years at 3y6m",
            "2022-06-15",
            "2025-12-15",
            "3\u{00BD} years",
        ),
        (
            "3\u{00BD} years at 3y11m",
            "2022-06-15",
            "2026-05-15",
            "3\u{00BD} years",
        ),
        ("4 years exactly", "2021-06-15", "2025-06-15", "4 years"),
        (
            "4\u{00BD} years",
            "2021-06-15",
            "2025-12-15",
            "4\u{00BD} years",
        ),
        ("5 years", "2020-06-15", "2025-06-15", "5 years"),
        (
            "5\u{00BD} years at 5y8m",
            "2020-06-15",
            "2026-02-15",
            "5\u{00BD} years",
        ),
        ("6 years", "2019-06-15", "2025-06-15", "6 years"),
        (
            "6\u{00BD} years",
            "2019-06-15",
            "2025-12-15",
            "6\u{00BD} years",
        ),
        (
            "6\u{00BD} years at 6y11m",
            "2019-06-15",
            "2026-05-15",
            "6\u{00BD} years",
        ),
        (
            "one day before 3rd bday",
            "2022-06-15",
            "2025-06-14",
            "2 years, 11 months",
        ),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================
#[test]
fn test_format_age_integer_tier() {
    assert_age(
        "7 years exactly",
        format_age("2018-06-15", Some("2025-06-15")),
        "7 years",
    );
    assert_age(
        "7 years 6 months (no half)",
        format_age("2018-03-20", Some("2025-06-15")),
        "7 years",
    );
    assert_age(
        "45 years",
        format_age("1980-01-01", Some("2025-06-15")),
        "45 years",
    );
}

// ================================================================
// formatAge -- cross-year transitions with Feb
// ================================================================
#[test]
fn test_format_age_cross_year_feb() {
    assert_age(
        "Dec31 -> Mar31 = 3mo",
        format_age("2024-12-31", Some("2025-03-31")),
        "3 months",
    );
    assert_contains(
        "Dec31 -> Mar30 still weeks",
        format_age("2024-12-31", Some("2025-03-30")),
        "weeks",
    );
    assert_age(
        "Nov30 -> Feb28 = 3mo",
        format_age("2024-11-30", Some("2025-02-28")),
        "3 months",
    );
    assert_contains(
        "Nov30 -> Feb27 still weeks",
        format_age("2024-11-30", Some("2025-02-27")),
        "weeks",
    );
}

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================
#[test]
fn test_format_age_born_on_31st() {
    let tests = vec![
        (
            "Jan31 -> Apr30 = 3mo",
            "2025-01-31",
            "2025-04-30",
            "3 months",
        ),
        (
            "Jan31 -> May31 = 4mo",
            "2025-01-31",
            "2025-05-31",
            "4 months",
        ),
        (
            "Jan31 -> Jun30 = 5mo (clamped)",
            "2025-01-31",
            "2025-06-30",
            "5 months",
        ),
        (
            "Jan31 -> Jul1 = 5mo",
            "2025-01-31",
            "2025-07-01",
            "5 months",
        ),
        (
            "Jan31 -> Jul31 = 6mo",
            "2025-01-31",
            "2025-07-31",
            "6 months",
        ),
    ];
    for (name, dob, as_of, want) in tests {
        assert_age(name, format_age(dob, Some(as_of)), want);
    }
}

// ================================================================
// formatAge -- default asOf (uses current date)
// ================================================================
// Note: We can't easily mock time in Rust without test-specific machinery.
#[test]
fn test_format_age_default_as_of() {
    parent_time::_set_now_for_testing(Some((2025, 6, 15)));
    assert_age("5 years from today", format_age("2020-01-01", None), "5 years");
    assert_age("5 days from today", format_age("2025-06-10", None), "5 days");
    parent_time::_set_now_for_testing(None);
}

// ================================================================
// formatStage -- null/edge cases
// ================================================================
#[test]
fn test_format_stage_null_edge_cases() {
    assert_nil("empty string", format_stage("", Some("2025-06-15"), None));
    assert_nil(
        "future dob",
        format_stage("2025-07-01", Some("2025-06-15"), None),
    );
}

// ================================================================
// formatStage -- Newborn
// ================================================================
#[test]
fn test_format_stage_newborn() {
    assert_age(
        "born today",
        format_stage("2025-06-15", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "1 day old",
        format_stage("2025-06-14", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "3 weeks old",
        format_stage("2025-05-25", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "1 month old",
        format_stage("2025-05-15", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "1 month 29 days",
        format_stage("2025-04-16", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "exactly 2 months -> Infant",
        format_stage("2025-04-15", Some("2025-06-15"), None),
        "Infant",
    );
}

// ================================================================
// formatStage -- Infant
// ================================================================
#[test]
fn test_format_stage_infant() {
    assert_age(
        "2 months",
        format_stage("2025-04-15", Some("2025-06-15"), None),
        "Infant",
    );
    assert_age(
        "6 months",
        format_stage("2024-12-15", Some("2025-06-15"), None),
        "Infant",
    );
    assert_age(
        "11 months",
        format_stage("2024-07-15", Some("2025-06-15"), None),
        "Infant",
    );
    assert_age(
        "exactly 12mo -> Toddler",
        format_stage("2024-06-15", Some("2025-06-15"), None),
        "Toddler",
    );
}

// ================================================================
// formatStage -- Toddler
// ================================================================
#[test]
fn test_format_stage_toddler() {
    assert_age(
        "12 months",
        format_stage("2024-06-15", Some("2025-06-15"), None),
        "Toddler",
    );
    assert_age(
        "18 months",
        format_stage("2024-01-15", Some("2025-07-15"), None),
        "Toddler",
    );
    assert_age(
        "24 months",
        format_stage("2023-06-15", Some("2025-06-15"), None),
        "Toddler",
    );
    assert_age(
        "35 months",
        format_stage("2023-06-15", Some("2026-05-15"), None),
        "Toddler",
    );
    assert_age(
        "exactly 36mo -> Child",
        format_stage("2022-06-15", Some("2025-06-15"), None),
        "Child",
    );
}

// ================================================================
// formatStage -- Child
// ================================================================
#[test]
fn test_format_stage_child() {
    assert_age(
        "3 years",
        format_stage("2022-06-15", Some("2025-06-15"), None),
        "Child",
    );
    assert_age(
        "4 years",
        format_stage("2021-06-15", Some("2025-06-15"), None),
        "Child",
    );
    assert_age(
        "6 years",
        format_stage("2019-06-15", Some("2025-06-15"), None),
        "Child",
    );
    assert_age(
        "9 years",
        format_stage("2016-06-15", Some("2025-06-15"), None),
        "Child",
    );
    assert_age(
        "12y 11mo",
        format_stage("2013-06-15", Some("2026-05-15"), None),
        "Child",
    );
    assert_age(
        "exactly 13y -> Teenager",
        format_stage("2012-06-15", Some("2025-06-15"), None),
        "Teenager",
    );
}

// ================================================================
// formatStage -- Teenager
// ================================================================
#[test]
fn test_format_stage_teenager() {
    assert_age(
        "13 years",
        format_stage("2012-06-15", Some("2025-06-15"), None),
        "Teenager",
    );
    assert_age(
        "15 years",
        format_stage("2010-06-15", Some("2025-06-15"), None),
        "Teenager",
    );
    assert_age(
        "17y 11mo",
        format_stage("2008-06-15", Some("2026-05-15"), None),
        "Teenager",
    );
    assert_age(
        "exactly 18y -> Adult",
        format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    );
}

// ================================================================
// formatStage -- Adult
// ================================================================
#[test]
fn test_format_stage_adult() {
    assert_age(
        "18 years",
        format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    );
    assert_age(
        "25 years",
        format_stage("2000-06-15", Some("2025-06-15"), None),
        "Adult",
    );
    assert_age(
        "45 years",
        format_stage("1980-01-01", Some("2025-06-15"), None),
        "Adult",
    );
}

// ================================================================
// formatStage -- default asOf
// ================================================================
#[test]
fn test_format_stage_default_as_of() {
    parent_time::_set_now_for_testing(Some((2025, 6, 15)));
    assert_age("Newborn", format_stage("2025-06-15", None, None), "Newborn");
    assert_age("Child", format_stage("2020-01-01", None, None), "Child");
    assert_age("Adult", format_stage("1980-01-01", None, None), "Adult");
    parent_time::_set_now_for_testing(None);
}

// ================================================================
// ParentTime class with English locale
// ================================================================
#[test]
fn test_parent_time_english() {
    let pt = ParentTime::new(&locales::EN, Compactness::Normal);
    assert_age(
        "Newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Newborn",
    );
    assert_age(
        "3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 days",
    );
    assert_age(
        "1 week 1 day",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 week, 1 day",
    );
    assert_age(
        "6 months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 months",
    );
    assert_age(
        "2y 1mo",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 years, 1 month",
    );
    assert_age(
        "3\u{00BD} years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD} years",
    );
    assert_age(
        "7 years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 years",
    );

    assert_age(
        "stage Newborn",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "stage Infant",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Infant",
    );
    assert_age(
        "stage Toddler",
        pt.format_stage("2024-06-15", Some("2025-06-15"), None),
        "Toddler",
    );
    assert_age(
        "stage Child",
        pt.format_stage("2022-06-15", Some("2025-06-15"), None),
        "Child",
    );
    assert_age(
        "stage Teenager",
        pt.format_stage("2012-06-15", Some("2025-06-15"), None),
        "Teenager",
    );
    assert_age(
        "stage Adult",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    );

    assert_nil("null age", pt.format_age("", None));
    assert_nil("null stage", pt.format_stage("", None, None));
}

// ================================================================
// ParentTime with Spanish locale
// ================================================================
#[test]
fn test_parent_time_spanish() {
    let es = AgeLocale {
        code: "es".to_string(),
        plural: |n| {
            if n == 1 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        },
        units: Units {
            day: UnitForms::plural(&[
                (PluralCategory::One, "{n} d\u{00ED}a"),
                (PluralCategory::Other, "{n} d\u{00ED}as"),
            ]),
            week: UnitForms::plural(&[
                (PluralCategory::One, "{n} semana"),
                (PluralCategory::Other, "{n} semanas"),
            ]),
            month: UnitForms::plural(&[
                (PluralCategory::One, "{n} mes"),
                (PluralCategory::Other, "{n} meses"),
            ]),
            year: UnitForms::plural(&[
                (PluralCategory::One, "{n} a\u{00F1}o"),
                (PluralCategory::Other, "{n} a\u{00F1}os"),
            ]),
        },
        half: "{n} y medio".to_string(),
        delimiter: ", ".to_string(),
        just_born: "Reci\u{00E9}n nacido".to_string(),
        stages: Stages {
            newborn: StageLabel::Gendered { m: "Reci\u{00E9}n nacido".to_string(), f: "Reci\u{00E9}n nacida".to_string() },
            infant: StageLabel::Neutral("Beb\u{00E9}".to_string()),
            toddler: StageLabel::Gendered { m: "Ni\u{00F1}o peque\u{00F1}o".to_string(), f: "Ni\u{00F1}a peque\u{00F1}a".to_string() },
            child: StageLabel::Gendered { m: "Ni\u{00F1}o".to_string(), f: "Ni\u{00F1}a".to_string() },
            teenager: StageLabel::Neutral("Adolescente".to_string()),
            adult: StageLabel::Gendered { m: "Adulto".to_string(), f: "Adulta".to_string() },
        },
        short: None,
        compact: None,
        format_number: None,
        format_unit: None,
    };

    let pt = ParentTime::new(&es, Compactness::Normal);

    assert_age(
        "justBorn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Recién nacido",
    );
    assert_age(
        "singular day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 día",
    );
    assert_age(
        "plural days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 días",
    );
    assert_age(
        "singular week",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1 semana",
    );
    assert_age(
        "weeks+days",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 semana, 1 día",
    );
    assert_age(
        "plural weeks+days",
        pt.format_age("2025-05-26", Some("2025-06-15")),
        "2 semanas, 6 días",
    );
    assert_age(
        "months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 meses",
    );
    assert_age(
        "singular month compound",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 años, 1 mes",
    );
    assert_age(
        "years+months",
        pt.format_age("2023-06-15", Some("2025-12-15")),
        "2 años, 6 meses",
    );
    assert_age(
        "half marker",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3 y medio años",
    );
    assert_age(
        "integer years",
        pt.format_age("2022-06-15", Some("2025-06-15")),
        "3 años",
    );
    assert_age(
        "7+ years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 años",
    );

    assert_age(
        "stage newborn",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Recién nacido",
    );
    assert_age(
        "stage infant",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Bebé",
    );
    assert_age(
        "stage toddler",
        pt.format_stage("2024-06-15", Some("2025-06-15"), None),
        "Niño pequeño",
    );
    assert_age(
        "stage child",
        pt.format_stage("2022-06-15", Some("2025-06-15"), None),
        "Niño",
    );
    assert_age(
        "stage teenager",
        pt.format_stage("2012-06-15", Some("2025-06-15"), None),
        "Adolescente",
    );
    assert_age(
        "stage adult",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adulto",
    );

    assert_nil("null", pt.format_age("", None));
    assert_nil("null stage", pt.format_stage("", None, None));
}

// ================================================================
// Compactness: short
// ================================================================
#[test]
fn test_parent_time_compact_short() {
    let pt = ParentTime::new(&locales::EN, Compactness::Short);

    assert_age(
        "days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 d",
    );
    assert_age(
        "weeks",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1 wk",
    );
    assert_age(
        "weeks+days",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 wk, 1 d",
    );
    assert_age(
        "months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 mo",
    );
    assert_age(
        "years+months",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 yr, 1 mo",
    );
    assert_age(
        "half years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD} yr",
    );
    assert_age(
        "integer years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 yr",
    );
    assert_age(
        "justBorn unchanged",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Newborn",
    );
    assert_age(
        "stages unchanged",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Infant",
    );
}

// ================================================================
// Compactness: compact
// ================================================================
#[test]
fn test_parent_time_compact_compact() {
    let pt = ParentTime::new(&locales::EN, Compactness::Compact);

    assert_age(
        "days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3d",
    );
    assert_age(
        "weeks",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1w",
    );
    assert_age(
        "weeks+days no delimiter",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1w1d",
    );
    assert_age(
        "months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6m",
    );
    assert_age(
        "years+months no delimiter",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2y1m",
    );
    assert_age(
        "half years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD}y",
    );
    assert_age(
        "integer years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7y",
    );
    assert_age(
        "justBorn unchanged",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Newborn",
    );
}

// ================================================================
// Japanese locale test (East Asian half-marker pattern: {0}半)
// ================================================================
#[test]
fn test_parent_time_japanese() {
    let pt = ParentTime::new(&locales::JA, Compactness::Normal);
    assert_age(
        "JA newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "新生児",
    );
    assert_age(
        "JA 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3日",
    );
    assert_age(
        "JA 1 week",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1週",
    );
    assert_age(
        "JA weeks+days",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1週1日",
    );
    assert_age(
        "JA 6 months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6ヶ月",
    );
    assert_age(
        "JA 3\u{00BD} years (3歳半)",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3歳半",
    );
    assert_age(
        "JA 7 years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7歳",
    );
}

// ================================================================
// Chinese locale test (East Asian half-marker pattern: {0}半)
// ================================================================
#[test]
fn test_parent_time_chinese() {
    let pt = ParentTime::new(&locales::ZH, Compactness::Normal);
    assert_age(
        "ZH newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "新生儿",
    );
    assert_age(
        "ZH 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3天",
    );
    assert_age(
        "ZH 3.5 years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3岁半",
    );
}

// ================================================================
// Korean locale test ({0} 반 pattern)
// ================================================================
#[test]
fn test_parent_time_korean() {
    let pt = ParentTime::new(&locales::KO, Compactness::Normal);
    assert_age(
        "KO newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "신생아",
    );
    assert_age(
        "KO 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3일",
    );
    assert_age(
        "KO 3.5 years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3살 반",
    );
}

// ================================================================
// French locale test ({0} et demi pattern)
// ================================================================
#[test]
fn test_parent_time_french() {
    let pt = ParentTime::new(&locales::FR, Compactness::Normal);
    assert_age(
        "FR newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Nouveau-né",
    );
    assert_age(
        "FR 1 day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 jour",
    );
    assert_age(
        "FR 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 jours",
    );
    assert_age(
        "FR 6 months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 mois",
    );
    assert_age(
        "FR 3.5 years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3 ans et demi",
    );
}

// ================================================================
// Russian locale test (complex plural rules)
// ================================================================
#[test]
fn test_parent_time_russian() {
    let pt = ParentTime::new(&locales::RU, Compactness::Normal);
    assert_age(
        "RU 1 day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 день",
    );
    assert_age(
        "RU 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 дня",
    );
    assert_age(
        "RU 5 months",
        pt.format_age("2025-01-15", Some("2025-06-15")),
        "5 месяцев",
    );
    assert_age(
        "RU 3 years",
        pt.format_age("2022-06-15", Some("2025-06-15")),
        "3 года",
    );
    assert_age(
        "RU 3.5 years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3 с половиной года",
    );
    assert_age(
        "RU 7 years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 лет",
    );
}

// ================================================================
// Arabic locale test (6 plural categories)
// ================================================================
#[test]
fn test_parent_time_arabic() {
    let pt = ParentTime::new(&locales::AR, Compactness::Normal);
    assert_age(
        "AR newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "حديث الولادة",
    );
    assert_age(
        "AR 1 day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "يوم",
    );
    assert_age(
        "AR 2 days",
        pt.format_age("2025-06-13", Some("2025-06-15")),
        "يومان",
    );
    assert_age(
        "AR 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 أيام",
    );
}

// ================================================================
// German locale test
// ================================================================
#[test]
fn test_parent_time_german() {
    let pt = ParentTime::new(&locales::DE, Compactness::Normal);
    assert_age(
        "DE newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Neugeboren",
    );
    assert_age(
        "DE 1 day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 Tag",
    );
    assert_age(
        "DE 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 Tage",
    );
    assert_age(
        "DE 3.5 years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD} Jahre",
    );
}

// ================================================================
// Polish locale test (complex plural with Few/Many)
// ================================================================
#[test]
fn test_parent_time_polish() {
    let pt = ParentTime::new(&locales::PL, Compactness::Normal);
    assert_age(
        "PL 1 day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 dzień",
    );
    assert_age(
        "PL 3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 dni",
    );
    assert_age(
        "PL 5 months",
        pt.format_age("2025-01-15", Some("2025-06-15")),
        "5 miesięcy",
    );
    assert_age(
        "PL 3 years",
        pt.format_age("2022-06-15", Some("2025-06-15")),
        "3 lata",
    );
}

// ================================================================
// All locale constructors are valid
// ================================================================
#[test]
fn test_all_locales_construct() {
    // Verify every locale can be constructed and produce valid output
    let locale_refs: Vec<&std::sync::LazyLock<AgeLocale>> = vec![
        &locales::AR, &locales::BG, &locales::BN, &locales::BS,
        &locales::CA, &locales::CS, &locales::DA, &locales::DE,
        &locales::EL, &locales::EN, &locales::ES, &locales::ET,
        &locales::EU, &locales::FA, &locales::FI, &locales::FR,
        &locales::GA, &locales::GU, &locales::HI, &locales::HR,
        &locales::HU, &locales::IT, &locales::JA, &locales::JV,
        &locales::KO, &locales::LT, &locales::LV, &locales::MR,
        &locales::MS, &locales::NB, &locales::NL, &locales::PA,
        &locales::PL, &locales::PT, &locales::RO, &locales::RU,
        &locales::SK, &locales::SL, &locales::SQ, &locales::SR,
        &locales::SV, &locales::TA, &locales::TE, &locales::TH,
        &locales::TR, &locales::UK, &locales::UR, &locales::VI,
        &locales::ZH,
    ];

    for locale in locale_refs {
        let pt = ParentTime::new(locale, Compactness::Normal);

        // newborn
        let result = pt.format_age("2025-06-15", Some("2025-06-15"));
        assert!(
            result.is_some(),
            "Locale {} should return Some for newborn",
            locale.code
        );

        // 3 days
        let result = pt.format_age("2025-06-12", Some("2025-06-15"));
        assert!(
            result.is_some(),
            "Locale {} should return Some for 3 days",
            locale.code
        );

        // 6 months
        let result = pt.format_age("2025-01-15", Some("2025-07-15"));
        assert!(
            result.is_some(),
            "Locale {} should return Some for 6 months",
            locale.code
        );

        // 3 years
        let result = pt.format_age("2022-06-15", Some("2025-06-15"));
        assert!(
            result.is_some(),
            "Locale {} should return Some for 3 years",
            locale.code
        );

        // 3.5 years (half marker)
        let result = pt.format_age("2022-06-15", Some("2025-12-15"));
        assert!(
            result.is_some(),
            "Locale {} should return Some for 3.5 years",
            locale.code
        );

        // stage
        let result = pt.format_stage("2025-06-15", Some("2025-06-15"), None);
        assert!(
            result.is_some(),
            "Locale {} should return Some for stage",
            locale.code
        );
    }
}

// ================================================================
// formatStage -- gender support
// ================================================================
#[test]
fn test_format_stage_gender_neutral_locale() {
    // English has no gendered stages — gender param should be ignored
    let pt = ParentTime::new(&locales::EN, Compactness::Normal);
    assert_age(
        "EN newborn None",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Newborn",
    );
    assert_age(
        "EN newborn M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Newborn",
    );
    assert_age(
        "EN newborn F",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Newborn",
    );
    assert_age(
        "EN adult None",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    );
    assert_age(
        "EN adult M",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Adult",
    );
    assert_age(
        "EN adult F",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Adult",
    );
}

#[test]
fn test_format_stage_gender_spanish() {
    // Spanish has gendered newborn, toddler, child, adult; neutral infant, teenager
    let pt = ParentTime::new(&locales::ES, Compactness::Normal);

    // Gendered: newborn
    assert_age(
        "ES newborn None -> M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Recién nacido",
    );
    assert_age(
        "ES newborn M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Recién nacido",
    );
    assert_age(
        "ES newborn F",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Recién nacida",
    );

    // Neutral: infant
    assert_age(
        "ES infant None",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Bebé",
    );
    assert_age(
        "ES infant F",
        pt.format_stage("2025-01-15", Some("2025-06-15"), Some(Gender::F)),
        "Bebé",
    );

    // Gendered: toddler
    assert_age(
        "ES toddler M",
        pt.format_stage("2024-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Niño pequeño",
    );
    assert_age(
        "ES toddler F",
        pt.format_stage("2024-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Niña pequeña",
    );

    // Gendered: child
    assert_age(
        "ES child M",
        pt.format_stage("2022-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Niño",
    );
    assert_age(
        "ES child F",
        pt.format_stage("2022-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Niña",
    );

    // Neutral: teenager
    assert_age(
        "ES teenager None",
        pt.format_stage("2012-06-15", Some("2025-06-15"), None),
        "Adolescente",
    );
    assert_age(
        "ES teenager F",
        pt.format_stage("2012-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Adolescente",
    );

    // Gendered: adult
    assert_age(
        "ES adult M",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Adulto",
    );
    assert_age(
        "ES adult F",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Adulta",
    );
}

#[test]
fn test_format_stage_gender_arabic() {
    // Arabic has all 6 stages gendered
    let pt = ParentTime::new(&locales::AR, Compactness::Normal);

    assert_age(
        "AR newborn M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::M)),
        "حديث الولادة",
    );
    assert_age(
        "AR newborn F",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)),
        "حديثة الولادة",
    );
    assert_age(
        "AR infant M",
        pt.format_stage("2025-01-15", Some("2025-06-15"), Some(Gender::M)),
        "رضيع",
    );
    assert_age(
        "AR infant F",
        pt.format_stage("2025-01-15", Some("2025-06-15"), Some(Gender::F)),
        "رضيعة",
    );
    assert_age(
        "AR toddler M",
        pt.format_stage("2024-06-15", Some("2025-06-15"), Some(Gender::M)),
        "طفل صغير",
    );
    assert_age(
        "AR toddler F",
        pt.format_stage("2024-06-15", Some("2025-06-15"), Some(Gender::F)),
        "طفلة صغيرة",
    );
    assert_age(
        "AR child M",
        pt.format_stage("2022-06-15", Some("2025-06-15"), Some(Gender::M)),
        "طفل",
    );
    assert_age(
        "AR child F",
        pt.format_stage("2022-06-15", Some("2025-06-15"), Some(Gender::F)),
        "طفلة",
    );
    assert_age(
        "AR teenager M",
        pt.format_stage("2012-06-15", Some("2025-06-15"), Some(Gender::M)),
        "مراهق",
    );
    assert_age(
        "AR teenager F",
        pt.format_stage("2012-06-15", Some("2025-06-15"), Some(Gender::F)),
        "مراهقة",
    );
    assert_age(
        "AR adult M",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::M)),
        "بالغ",
    );
    assert_age(
        "AR adult F",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::F)),
        "بالغة",
    );
}

#[test]
fn test_format_stage_gender_french() {
    let pt = ParentTime::new(&locales::FR, Compactness::Normal);

    // Gendered: newborn
    assert_age(
        "FR newborn M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Nouveau-né",
    );
    assert_age(
        "FR newborn F",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Nouveau-née",
    );

    // Neutral: toddler (changed from Bambin to Tout-petit)
    assert_age(
        "FR toddler None",
        pt.format_stage("2024-06-15", Some("2025-06-15"), None),
        "Tout-petit",
    );

    // Gendered: teenager
    assert_age(
        "FR teenager M",
        pt.format_stage("2012-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Adolescent",
    );
    assert_age(
        "FR teenager F",
        pt.format_stage("2012-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Adolescente",
    );

    // Neutral: adult
    assert_age(
        "FR adult None",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adulte",
    );
}

#[test]
fn test_format_stage_gender_german() {
    let pt = ParentTime::new(&locales::DE, Compactness::Normal);

    // All neutral except adult
    assert_age(
        "DE adult M",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::M)),
        "Erwachsener",
    );
    assert_age(
        "DE adult F",
        pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Erwachsene",
    );
    assert_age(
        "DE newborn (neutral)",
        pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)),
        "Neugeborenes",
    );
}

#[test]
fn test_format_stage_gender_defaults_to_masculine() {
    // When gender is None, gendered labels should default to masculine
    let pt = ParentTime::new(&locales::ES, Compactness::Normal);
    assert_age(
        "ES newborn None defaults to M",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Recién nacido",
    );
    assert_age(
        "ES adult None defaults to M",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adulto",
    );
}
