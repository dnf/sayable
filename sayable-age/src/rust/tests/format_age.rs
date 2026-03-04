#![allow(missing_docs)]

use sayable_age::formatter::{format_age, format_stage, SayableAge};
use sayable_age::locales;
use sayable_age::types::*;
use sayable_age::Gender;

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
    assert_nil("empty string", format_age("", Some("2025-06-15"))); // 1.1, 1.3
    assert_nil("future dob", format_age("2025-07-01", Some("2025-06-15"))); // 1.4
    assert_age("exactly 500 years", format_age("1525-06-15", Some("2025-06-15")), "500 years"); // 1.5
    assert_nil("501 years exceeds max", format_age("1524-06-15", Some("2025-06-15"))); // 1.6
    assert_nil("1000 years exceeds max", format_age("1025-06-15", Some("2025-06-15"))); // 1.7
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
#[test]
fn test_format_age_days_tier() {
    let tests = vec![
        ("born today", "2025-06-15", "2025-06-15", "Newborn"), // 2.1
        ("1 day ago (singular)", "2025-06-14", "2025-06-15", "1 day"), // 2.2
        ("3 days ago", "2025-06-12", "2025-06-15", "3 days"), // 2.3
        ("6 days ago", "2025-06-09", "2025-06-15", "6 days"), // 2.4
        ("7 days -> 1 week", "2025-06-08", "2025-06-15", "1 week"), // 2.5
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
        ("7 days", "2025-06-08", "2025-06-15", "1 week"), // 3.1
        ("8 days", "2025-06-07", "2025-06-15", "1 week, 1 day"), // 3.2
        ("9 days", "2025-06-06", "2025-06-15", "1 week, 2 days"), // 3.3
        ("13 days", "2025-06-02", "2025-06-15", "1 week, 6 days"), // 3.4
        ("14 days", "2025-06-01", "2025-06-15", "2 weeks"), // 3.5
        ("15 days", "2025-05-31", "2025-06-15", "2 weeks, 1 day"), // 3.6
        ("20 days", "2025-05-26", "2025-06-15", "2 weeks, 6 days"), // 3.7
        ("21 days", "2025-05-25", "2025-06-15", "3 weeks"), // 3.8
        (
            "at 1 cal month still weeks+days",
            "2025-05-15",
            "2025-06-15",
            "4 weeks, 3 days",
        ), // 3.9
        (
            "at 2 cal months still weeks+days",
            "2025-04-15",
            "2025-06-15",
            "8 weeks, 5 days",
        ), // 3.10
        (
            "one day before 3mo still weeks",
            "2025-03-15",
            "2025-06-14",
            "13 weeks",
        ), // 3.11
        (
            "on 3mo birthday switches",
            "2025-03-15",
            "2025-06-15",
            "3 months",
        ), // 3.12
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
    ); // 4.1
    assert_contains(
        "Jan1 -> Mar31 still weeks",
        format_age("2025-01-01", Some("2025-03-31")),
        "weeks",
    ); // 4.2
    assert_age(
        "Jun15 -> Sep15 = 3mo",
        format_age("2025-06-15", Some("2025-09-15")),
        "3 months",
    ); // 4.3
    assert_contains(
        "Jun15 -> Sep14 still weeks",
        format_age("2025-06-15", Some("2025-09-14")),
        "weeks",
    ); // 4.4
    assert_age(
        "Jun15 -> Dec15 = 6mo",
        format_age("2025-06-15", Some("2025-12-15")),
        "6 months",
    ); // 4.5
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
    ); // 5.1
    assert_age(
        "Jan31 -> Apr30 = 3mo (clamp)",
        format_age("2025-01-31", Some("2025-04-30")),
        "3 months",
    ); // 5.2
    assert_contains(
        "Jan31 -> Apr29 still weeks",
        format_age("2025-01-31", Some("2025-04-29")),
        "weeks",
    ); // 5.3
    assert_age(
        "Feb1 -> May1 = 3mo",
        format_age("2025-02-01", Some("2025-05-01")),
        "3 months",
    ); // 5.4
    assert_contains(
        "Feb1 -> Apr30 still weeks",
        format_age("2025-02-01", Some("2025-04-30")),
        "weeks",
    ); // 5.5
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
    ); // 6.1
    assert_age(
        "Jan31 -> Feb28 leap",
        format_age("2024-01-31", Some("2024-02-28")),
        "4 weeks",
    ); // 6.2
    assert_age(
        "Jan31 -> Apr30 leap = 3mo",
        format_age("2024-01-31", Some("2024-04-30")),
        "3 months",
    ); // 6.3
    assert_contains(
        "Jan30 -> Feb29 leap still weeks",
        format_age("2024-01-30", Some("2024-02-29")),
        "weeks",
    ); // 6.4
    assert_contains(
        "Jan30 -> Feb28 leap still weeks",
        format_age("2024-01-30", Some("2024-02-28")),
        "weeks",
    ); // 6.5
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
    ); // 7.1
    assert_contains(
        "Mar31 -> Jun29 still weeks",
        format_age("2025-03-31", Some("2025-06-29")),
        "weeks",
    ); // 7.2
    assert_age(
        "Aug31 -> Nov30 = 3mo",
        format_age("2025-08-31", Some("2025-11-30")),
        "3 months",
    ); // 7.3
    assert_contains(
        "Aug31 -> Nov29 still weeks",
        format_age("2025-08-31", Some("2025-11-29")),
        "weeks",
    ); // 7.4
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
    ); // 8.1
    assert_contains(
        "Feb29 -> May28 still weeks",
        format_age("2024-02-29", Some("2024-05-28")),
        "weeks",
    ); // 8.2
    assert_age(
        "Feb29 2024 -> Feb28 2025 = 12mo",
        format_age("2024-02-29", Some("2025-02-28")),
        "12 months",
    ); // 8.3
    assert_age(
        "Feb29 2024 -> Mar1 2025 = 12mo",
        format_age("2024-02-29", Some("2025-03-01")),
        "12 months",
    ); // 8.4
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
        ), // 9.1
        ("6 months", "2025-01-15", "2025-07-15", "6 months"), // 9.2
        (
            "12 months (not 1 year)",
            "2024-06-15",
            "2025-06-15",
            "12 months",
        ), // 9.3
        (
            "23 months at upper",
            "2024-01-15",
            "2025-12-15",
            "23 months",
        ), // 9.4
        (
            "one day before boundary",
            "2025-01-15",
            "2025-07-14",
            "5 months",
        ), // 9.5
        (
            "crossing year boundary",
            "2024-11-10",
            "2025-04-10",
            "5 months",
        ), // 9.6
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
        ("2 years at 24mo", "2023-06-15", "2025-06-15", "2 years"), // 10.1
        (
            "2 years 1 month",
            "2023-06-15",
            "2025-07-15",
            "2 years, 1 month",
        ), // 10.2
        (
            "2 years 6 months",
            "2023-06-15",
            "2025-12-15",
            "2 years, 6 months",
        ), // 10.3
        (
            "2 years 11 months",
            "2023-06-15",
            "2026-05-15",
            "2 years, 11 months",
        ), // 10.4
        (
            "one day before 24mo",
            "2023-06-15",
            "2025-06-14",
            "23 months",
        ), // 10.5
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
        ("3 years exactly", "2022-06-15", "2025-06-15", "3 years"), // 11.1
        ("3 years 5 months", "2022-06-15", "2025-11-15", "3 years"), // 11.2
        (
            "3\u{00BD} years at 3y6m",
            "2022-06-15",
            "2025-12-15",
            "3\u{00BD} years",
        ), // 11.3
        (
            "3\u{00BD} years at 3y11m",
            "2022-06-15",
            "2026-05-15",
            "3\u{00BD} years",
        ), // 11.4
        ("4 years exactly", "2021-06-15", "2025-06-15", "4 years"), // 11.5
        (
            "4\u{00BD} years",
            "2021-06-15",
            "2025-12-15",
            "4\u{00BD} years",
        ), // 11.6
        ("5 years", "2020-06-15", "2025-06-15", "5 years"), // 11.7
        (
            "5\u{00BD} years at 5y8m",
            "2020-06-15",
            "2026-02-15",
            "5\u{00BD} years",
        ), // 11.8
        ("6 years", "2019-06-15", "2025-06-15", "6 years"), // 11.9
        (
            "6\u{00BD} years",
            "2019-06-15",
            "2025-12-15",
            "6\u{00BD} years",
        ), // 11.10
        (
            "6\u{00BD} years at 6y11m",
            "2019-06-15",
            "2026-05-15",
            "6\u{00BD} years",
        ), // 11.11
        (
            "one day before 3rd bday",
            "2022-06-15",
            "2025-06-14",
            "2 years, 11 months",
        ), // 11.12
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
    ); // 12.1
    assert_age(
        "7 years 6 months (no half)",
        format_age("2018-03-20", Some("2025-06-15")),
        "7 years",
    ); // 12.2
    assert_age(
        "45 years",
        format_age("1980-01-01", Some("2025-06-15")),
        "45 years",
    ); // 12.3
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
    ); // 13.1
    assert_contains(
        "Dec31 -> Mar30 still weeks",
        format_age("2024-12-31", Some("2025-03-30")),
        "weeks",
    ); // 13.2
    assert_age(
        "Nov30 -> Feb28 = 3mo",
        format_age("2024-11-30", Some("2025-02-28")),
        "3 months",
    ); // 13.3
    assert_contains(
        "Nov30 -> Feb27 still weeks",
        format_age("2024-11-30", Some("2025-02-27")),
        "weeks",
    ); // 13.4
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
        ), // 14.1
        (
            "Jan31 -> May31 = 4mo",
            "2025-01-31",
            "2025-05-31",
            "4 months",
        ), // 14.2
        (
            "Jan31 -> Jun30 = 5mo (clamped)",
            "2025-01-31",
            "2025-06-30",
            "5 months",
        ), // 14.3
        (
            "Jan31 -> Jul1 = 5mo",
            "2025-01-31",
            "2025-07-01",
            "5 months",
        ), // 14.4
        (
            "Jan31 -> Jul31 = 6mo",
            "2025-01-31",
            "2025-07-31",
            "6 months",
        ), // 14.5
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
    sayable_age::_set_now_for_testing(Some((2025, 6, 15)));
    assert_age("5 years from today", format_age("2020-01-01", None), "5 years"); // 15.1
    assert_age("5 days from today", format_age("2025-06-10", None), "5 days"); // 15.2
    sayable_age::_set_now_for_testing(None);
}

// ================================================================
// formatStage -- null/edge cases
// ================================================================
#[test]
fn test_format_stage_null_edge_cases() {
    assert_nil("empty string", format_stage("", Some("2025-06-15"), None)); // 16.1, 16.3
    assert_nil(
        "future dob",
        format_stage("2025-07-01", Some("2025-06-15"), None),
    ); // 16.4
    assert_age("stage 500 years", format_stage("1525-06-15", Some("2025-06-15"), None), "Adult"); // 16.5
    assert_nil("stage 501 years exceeds max", format_stage("1524-06-15", Some("2025-06-15"), None)); // 16.6
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
    ); // 17.1
    assert_age(
        "1 day old",
        format_stage("2025-06-14", Some("2025-06-15"), None),
        "Newborn",
    ); // 17.2
    assert_age(
        "3 weeks old",
        format_stage("2025-05-25", Some("2025-06-15"), None),
        "Newborn",
    ); // 17.3
    assert_age(
        "1 month old",
        format_stage("2025-05-15", Some("2025-06-15"), None),
        "Newborn",
    ); // 17.4
    assert_age(
        "1 month 29 days",
        format_stage("2025-04-16", Some("2025-06-15"), None),
        "Newborn",
    ); // 17.5
    assert_age(
        "exactly 2 months -> Infant",
        format_stage("2025-04-15", Some("2025-06-15"), None),
        "Infant",
    ); // 17.6
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
    ); // 18.1
    assert_age(
        "6 months",
        format_stage("2024-12-15", Some("2025-06-15"), None),
        "Infant",
    ); // 18.2
    assert_age(
        "11 months",
        format_stage("2024-07-15", Some("2025-06-15"), None),
        "Infant",
    ); // 18.3
    assert_age(
        "exactly 12mo -> Toddler",
        format_stage("2024-06-15", Some("2025-06-15"), None),
        "Toddler",
    ); // 18.4
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
    ); // 19.1
    assert_age(
        "18 months",
        format_stage("2024-01-15", Some("2025-07-15"), None),
        "Toddler",
    ); // 19.2
    assert_age(
        "24 months",
        format_stage("2023-06-15", Some("2025-06-15"), None),
        "Toddler",
    ); // 19.3
    assert_age(
        "35 months",
        format_stage("2023-06-15", Some("2026-05-15"), None),
        "Toddler",
    ); // 19.4
    assert_age(
        "exactly 36mo -> Child",
        format_stage("2022-06-15", Some("2025-06-15"), None),
        "Child",
    ); // 19.5
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
    ); // 20.1
    assert_age(
        "4 years",
        format_stage("2021-06-15", Some("2025-06-15"), None),
        "Child",
    ); // 20.2
    assert_age(
        "6 years",
        format_stage("2019-06-15", Some("2025-06-15"), None),
        "Child",
    ); // 20.3
    assert_age(
        "9 years",
        format_stage("2016-06-15", Some("2025-06-15"), None),
        "Child",
    ); // 20.4
    assert_age(
        "12y 11mo",
        format_stage("2013-06-15", Some("2026-05-15"), None),
        "Child",
    ); // 20.5
    assert_age(
        "exactly 13y -> Teenager",
        format_stage("2012-06-15", Some("2025-06-15"), None),
        "Teenager",
    ); // 20.6
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
    ); // 21.1
    assert_age(
        "15 years",
        format_stage("2010-06-15", Some("2025-06-15"), None),
        "Teenager",
    ); // 21.2
    assert_age(
        "17y 11mo",
        format_stage("2008-06-15", Some("2026-05-15"), None),
        "Teenager",
    ); // 21.3
    assert_age(
        "exactly 18y -> Adult",
        format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    ); // 21.4
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
    ); // 22.1
    assert_age(
        "25 years",
        format_stage("2000-06-15", Some("2025-06-15"), None),
        "Adult",
    ); // 22.2
    assert_age(
        "45 years",
        format_stage("1980-01-01", Some("2025-06-15"), None),
        "Adult",
    ); // 22.3
}

// ================================================================
// formatStage -- default asOf
// ================================================================
#[test]
fn test_format_stage_default_as_of() {
    sayable_age::_set_now_for_testing(Some((2025, 6, 15)));
    assert_age("Newborn", format_stage("2025-06-15", None, None), "Newborn"); // 23.1
    assert_age("Child", format_stage("2020-01-01", None, None), "Child"); // 23.2
    assert_age("Adult", format_stage("1980-01-01", None, None), "Adult"); // 23.3
    sayable_age::_set_now_for_testing(None);
}

// ================================================================
// SayableAge class with English locale
// ================================================================
#[test]
fn test_sayable_age_english() {
    let pt = SayableAge::new(&locales::EN, Compactness::Normal);
    assert_age(
        "Newborn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Newborn",
    ); // 24.1
    assert_age(
        "3 days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 days",
    ); // 24.2
    assert_age(
        "1 week 1 day",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 week, 1 day",
    ); // 24.3
    assert_age(
        "6 months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 months",
    ); // 24.4
    assert_age(
        "2y 1mo",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 years, 1 month",
    ); // 24.5
    assert_age(
        "3\u{00BD} years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD} years",
    ); // 24.6
    assert_age(
        "7 years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 years",
    ); // 24.7

    assert_age(
        "stage Newborn",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Newborn",
    ); // 24.8
    assert_age(
        "stage Infant",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Infant",
    ); // 24.9
    assert_age(
        "stage Toddler",
        pt.format_stage("2024-06-15", Some("2025-06-15"), None),
        "Toddler",
    ); // 24.10
    assert_age(
        "stage Child",
        pt.format_stage("2022-06-15", Some("2025-06-15"), None),
        "Child",
    ); // 24.11
    assert_age(
        "stage Teenager",
        pt.format_stage("2012-06-15", Some("2025-06-15"), None),
        "Teenager",
    ); // 24.12
    assert_age(
        "stage Adult",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adult",
    ); // 24.13

    assert_nil("null age", pt.format_age("", None)); // 24.14
    assert_nil("null stage", pt.format_stage("", None, None)); // 24.15
}

// ================================================================
// SayableAge with Spanish locale
// ================================================================
#[test]
fn test_sayable_age_spanish() {
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

    let pt = SayableAge::new(&es, Compactness::Normal);

    assert_age(
        "justBorn",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Recién nacido",
    ); // 25.1
    assert_age(
        "singular day",
        pt.format_age("2025-06-14", Some("2025-06-15")),
        "1 día",
    ); // 25.2
    assert_age(
        "plural days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 días",
    ); // 25.3
    assert_age(
        "singular week",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1 semana",
    ); // 25.4
    assert_age(
        "weeks+days",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 semana, 1 día",
    ); // 25.5
    assert_age(
        "plural weeks+days",
        pt.format_age("2025-05-26", Some("2025-06-15")),
        "2 semanas, 6 días",
    ); // 25.6
    assert_age(
        "months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 meses",
    ); // 25.7
    assert_age(
        "singular month compound",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 años, 1 mes",
    ); // 25.8
    assert_age(
        "years+months",
        pt.format_age("2023-06-15", Some("2025-12-15")),
        "2 años, 6 meses",
    ); // 25.9
    assert_age(
        "half marker",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3 y medio años",
    ); // 25.10
    assert_age(
        "integer years",
        pt.format_age("2022-06-15", Some("2025-06-15")),
        "3 años",
    ); // 25.11
    assert_age(
        "7+ years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 años",
    ); // 25.12

    assert_age(
        "stage newborn",
        pt.format_stage("2025-06-15", Some("2025-06-15"), None),
        "Recién nacido",
    ); // 25.13
    assert_age(
        "stage infant",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Bebé",
    ); // 25.14
    assert_age(
        "stage toddler",
        pt.format_stage("2024-06-15", Some("2025-06-15"), None),
        "Niño pequeño",
    ); // 25.15
    assert_age(
        "stage child",
        pt.format_stage("2022-06-15", Some("2025-06-15"), None),
        "Niño",
    ); // 25.16
    assert_age(
        "stage teenager",
        pt.format_stage("2012-06-15", Some("2025-06-15"), None),
        "Adolescente",
    ); // 25.17
    assert_age(
        "stage adult",
        pt.format_stage("2007-06-15", Some("2025-06-15"), None),
        "Adulto",
    ); // 25.18

    assert_nil("null", pt.format_age("", None)); // 25.19
    assert_nil("null stage", pt.format_stage("", None, None)); // 25.20
}

// ================================================================
// Compactness: short
// ================================================================
#[test]
fn test_sayable_age_compact_short() {
    let pt = SayableAge::new(&locales::EN, Compactness::Short);

    assert_age(
        "days",
        pt.format_age("2025-06-12", Some("2025-06-15")),
        "3 d",
    ); // 26.1
    assert_age(
        "weeks",
        pt.format_age("2025-06-08", Some("2025-06-15")),
        "1 wk",
    ); // 26.2
    assert_age(
        "weeks+days",
        pt.format_age("2025-06-07", Some("2025-06-15")),
        "1 wk, 1 d",
    ); // 26.3
    assert_age(
        "months",
        pt.format_age("2025-01-15", Some("2025-07-15")),
        "6 mo",
    ); // 26.4
    assert_age(
        "years+months",
        pt.format_age("2023-06-15", Some("2025-07-15")),
        "2 yr, 1 mo",
    ); // 26.5
    assert_age(
        "half years",
        pt.format_age("2022-06-15", Some("2025-12-15")),
        "3\u{00BD} yr",
    ); // 26.6
    assert_age(
        "integer years",
        pt.format_age("2018-06-15", Some("2025-06-15")),
        "7 yr",
    ); // 26.7
    assert_age(
        "justBorn unchanged",
        pt.format_age("2025-06-15", Some("2025-06-15")),
        "Newborn",
    ); // 26.8
    assert_age(
        "stages unchanged",
        pt.format_stage("2025-01-15", Some("2025-06-15"), None),
        "Infant",
    ); // 26.9
}

// ================================================================
// Compactness: compact
// ================================================================
#[test]
fn test_sayable_age_compact_compact() {
    let pt = SayableAge::new(&locales::EN, Compactness::Compact);

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
fn test_sayable_age_japanese() {
    let pt = SayableAge::new(&locales::JA, Compactness::Normal);
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
fn test_sayable_age_chinese() {
    let pt = SayableAge::new(&locales::ZH, Compactness::Normal);
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
fn test_sayable_age_korean() {
    let pt = SayableAge::new(&locales::KO, Compactness::Normal);
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
fn test_sayable_age_french() {
    let pt = SayableAge::new(&locales::FR, Compactness::Normal);
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
fn test_sayable_age_russian() {
    let pt = SayableAge::new(&locales::RU, Compactness::Normal);
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
fn test_sayable_age_arabic() {
    let pt = SayableAge::new(&locales::AR, Compactness::Normal);
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
fn test_sayable_age_german() {
    let pt = SayableAge::new(&locales::DE, Compactness::Normal);
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
fn test_sayable_age_polish() {
    let pt = SayableAge::new(&locales::PL, Compactness::Normal);
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
        let pt = SayableAge::new(locale, Compactness::Normal);

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
    let pt = SayableAge::new(&locales::EN, Compactness::Normal);
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
    let pt = SayableAge::new(&locales::ES, Compactness::Normal);

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
    let pt = SayableAge::new(&locales::AR, Compactness::Normal);

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
    let pt = SayableAge::new(&locales::FR, Compactness::Normal);

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
    let pt = SayableAge::new(&locales::DE, Compactness::Normal);

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
    let pt = SayableAge::new(&locales::ES, Compactness::Normal);
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

// ================================================================
// Section 29: Locale-specific edge cases — new plural rules
// ================================================================

#[test]
fn test_locale_hebrew() {
    let pt = SayableAge::new(&locales::HE, Compactness::Normal);

    assert_age("he justBorn", pt.format_age("2025-06-15", Some("2025-06-15")), "רק נולד");
    assert_age("he 1 day one", pt.format_age("2025-06-14", Some("2025-06-15")), "יום 1");
    assert_age("he 3 days other", pt.format_age("2025-06-12", Some("2025-06-15")), "3 ימים");
    assert_age("he 2 weeks dual", pt.format_age("2025-06-01", Some("2025-06-15")), "שבועיים");
    assert_age("he 3 weeks other", pt.format_age("2025-05-25", Some("2025-06-15")), "3 שבועות");
    assert_age("he 6 months", pt.format_age("2025-01-15", Some("2025-07-15")), "6 חודשים");
    assert_age("he 3 months", pt.format_age("2025-03-15", Some("2025-06-15")), "3 חודשים");
    assert_age("he 2y dual 1m one", pt.format_age("2023-06-15", Some("2025-07-15")), "שנתיים, חודש 1");
    assert_age("he 3.5y half", pt.format_age("2022-06-15", Some("2025-12-15")), "3 שנים וחצי");
    assert_age("he 7y other", pt.format_age("2018-06-15", Some("2025-06-15")), "7 שנים");
    assert_age("he stage m newborn", pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::M)), "רק נולד");
    assert_age("he stage f newborn", pt.format_stage("2025-06-15", Some("2025-06-15"), Some(Gender::F)), "רק נולדה");
    assert_age("he stage m adult", pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::M)), "מבוגר");
    assert_age("he stage f adult", pt.format_stage("2007-06-15", Some("2025-06-15"), Some(Gender::F)), "מבוגרת");
}

#[test]
fn test_locale_macedonian() {
    let pt = SayableAge::new(&locales::MK, Compactness::Normal);

    assert_age("mk justBorn", pt.format_age("2025-06-15", Some("2025-06-15")), "Новороденче");
    assert_age("mk 1 day one", pt.format_age("2025-06-14", Some("2025-06-15")), "1 ден");
    assert_age("mk 3 days other", pt.format_age("2025-06-12", Some("2025-06-15")), "3 дена");
    assert_age("mk 6 months", pt.format_age("2025-01-15", Some("2025-07-15")), "6 месеци");
    assert_age("mk 2y1m one month", pt.format_age("2023-06-15", Some("2025-07-15")), "2 години, 1 месец");
    assert_age("mk 3.5y half", pt.format_age("2022-06-15", Some("2025-12-15")), "3 години и пол");
    assert_age("mk 7y", pt.format_age("2018-06-15", Some("2025-06-15")), "7 години");
}

#[test]
fn test_locale_swahili() {
    let pt = SayableAge::new(&locales::SW, Compactness::Normal);

    assert_age("sw justBorn", pt.format_age("2025-06-15", Some("2025-06-15")), "Mzaliwa mpya");
    assert_age("sw 1 day", pt.format_age("2025-06-14", Some("2025-06-15")), "siku 1");
    assert_age("sw 3 days", pt.format_age("2025-06-12", Some("2025-06-15")), "siku 3");
    assert_age("sw 6 months", pt.format_age("2025-01-15", Some("2025-07-15")), "miezi 6");
    assert_age("sw 2y 1m", pt.format_age("2023-06-15", Some("2025-07-15")), "miaka 2, mwezi 1");
    assert_age("sw 3.5y half", pt.format_age("2022-06-15", Some("2025-12-15")), "miaka 3 na nusu");
}

#[test]
fn test_locale_indonesian() {
    let pt = SayableAge::new(&locales::ID, Compactness::Normal);

    assert_age("id justBorn", pt.format_age("2025-06-15", Some("2025-06-15")), "Baru lahir");
    assert_age("id 1 day", pt.format_age("2025-06-14", Some("2025-06-15")), "1 hari");
    assert_age("id 3 days", pt.format_age("2025-06-12", Some("2025-06-15")), "3 hari");
    assert_age("id 6 months", pt.format_age("2025-01-15", Some("2025-07-15")), "6 bulan");
    assert_age("id 3.5y half", pt.format_age("2022-06-15", Some("2025-12-15")), "3 tahun setengah");
    assert_age("id 7y", pt.format_age("2018-06-15", Some("2025-06-15")), "7 tahun");
}

#[test]
fn test_locale_amharic() {
    let pt = SayableAge::new(&locales::AM, Compactness::Normal);

    assert_age("am justBorn", pt.format_age("2025-06-15", Some("2025-06-15")), "አዲስ የተወለደ");
    assert_age("am 1 day", pt.format_age("2025-06-14", Some("2025-06-15")), "1 ቀን");
    assert_age("am 3 days", pt.format_age("2025-06-12", Some("2025-06-15")), "3 ቀናት");
    assert_age("am 1w1d ethiopic", pt.format_age("2025-06-07", Some("2025-06-15")), "1 ሳምንት፣ 1 ቀን");
    assert_age("am 6 months", pt.format_age("2025-01-15", Some("2025-07-15")), "6 ወራት");
    assert_age("am 3.5y half", pt.format_age("2022-06-15", Some("2025-12-15")), "3 ዓመታት ተኩል");
}

// ================================================================
// Section 30: Locale lookup by code string
// ================================================================

#[test]
fn test_locale_lookup() {
    // 30.1 Known locale
    let loc = locales::get("en");
    assert!(loc.is_some(), "get(\"en\") should return Some");
    assert_eq!(loc.unwrap().code, "en");

    // 30.2 Another known locale
    let loc = locales::get("fr");
    assert!(loc.is_some(), "get(\"fr\") should return Some");
    assert_eq!(loc.unwrap().code, "fr");

    // 30.3 Unknown code
    assert!(locales::get("xx").is_none(), "get(\"xx\") should be None");

    // 30.4 Empty string
    assert!(locales::get("").is_none(), "get(\"\") should be None");

    // 30.5 Case-sensitive
    assert!(locales::get("EN").is_none(), "get(\"EN\") should be None (case-sensitive)");
}
