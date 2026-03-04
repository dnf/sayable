//! Integration tests for sayable-date, matching canonical test spec date/config/tests.json.

use sayable_date::locales;
use sayable_date::{Compactness, SayableDate};

// ── Section 1: Null / edge cases ────────────────────────────────────

// 1.1
#[test]
fn test_format_date_null() {
    // Rust has no null strings; empty string is the equivalent
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date(""), None);
}

// 1.2
#[test]
fn test_format_date_empty() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date(""), None);
}

// 1.3
#[test]
fn test_format_date_invalid() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("invalid"), None);
}

// 1.4
#[test]
fn test_format_relative_null_as_of() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-15", ""), None);
}

// 1.5
#[test]
fn test_format_relative_null_date() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("", "2025-03-15"), None);
}

// ── Section 2: format_date — normal compactness (English) ───────────

// 2.1
#[test]
fn test_format_date_march_15() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("March 15th".to_string()));
}

// 2.2
#[test]
fn test_format_date_january_1() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-01-01"), Some("January 1st".to_string()));
}

// 2.3
#[test]
fn test_format_date_may_22() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-05-22"), Some("May 22nd".to_string()));
}

// 2.4
#[test]
fn test_format_date_july_3() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-07-03"), Some("July 3rd".to_string()));
}

// 2.5
#[test]
fn test_format_date_december_31() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-12-31"), Some("December 31st".to_string()));
}

// 2.6 — No exception for 11
#[test]
fn test_format_date_june_11() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-06-11"), Some("June 11th".to_string()));
}

// 2.7 — ISO datetime input
#[test]
fn test_format_date_iso_datetime() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15T14:30:00"), Some("March 15th".to_string()));
}

// ── Section 3: format_date — short compactness (English) ────────────

// 3.1
#[test]
fn test_format_date_short_march_15() {
    let sd = SayableDate::new(&locales::EN, Compactness::Short);
    assert_eq!(sd.format_date("2025-03-15"), Some("Mar 15".to_string()));
}

// 3.2
#[test]
fn test_format_date_short_january_1() {
    let sd = SayableDate::new(&locales::EN, Compactness::Short);
    assert_eq!(sd.format_date("2025-01-01"), Some("Jan 1".to_string()));
}

// 3.3
#[test]
fn test_format_date_short_december_25() {
    let sd = SayableDate::new(&locales::EN, Compactness::Short);
    assert_eq!(sd.format_date("2025-12-25"), Some("Dec 25".to_string()));
}

// ── Section 4: format_date — compact (English) ──────────────────────

// 4.1
#[test]
fn test_format_date_compact_march_15() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_date("2025-03-15"), Some("3/15".to_string()));
}

// 4.2
#[test]
fn test_format_date_compact_january_1() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_date("2025-01-01"), Some("1/1".to_string()));
}

// ── Section 5: format_relative — proximity tiers (English) ──────────

// 5.1
#[test]
fn test_format_relative_today() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-15", "2025-03-15"), Some("today".to_string()));
}

// 5.2
#[test]
fn test_format_relative_tomorrow() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("tomorrow".to_string()));
}

// 5.3
#[test]
fn test_format_relative_yesterday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-14", "2025-03-15"), Some("yesterday".to_string()));
}

// 5.4 — +2 special tier
#[test]
fn test_format_relative_day_after_tomorrow() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-17", "2025-03-15"), Some("the day after tomorrow".to_string()));
}

// 5.5 — -2 special tier
#[test]
fn test_format_relative_day_before_yesterday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-13", "2025-03-15"), Some("the day before yesterday".to_string()));
}

// 5.6 — +4 days, this weekday tier
#[test]
fn test_format_relative_this_wednesday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-19", "2025-03-15"), Some("this Wednesday".to_string()));
}

// 5.7 — +5 days, this weekday tier
#[test]
fn test_format_relative_this_thursday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-20", "2025-03-15"), Some("this Thursday".to_string()));
}

// 5.8 — -4 days, last weekday tier
#[test]
fn test_format_relative_last_tuesday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-11", "2025-03-15"), Some("last Tuesday".to_string()));
}

// 5.9 — +7 days, next weekday tier
#[test]
fn test_format_relative_next_saturday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-22", "2025-03-15"), Some("next Saturday".to_string()));
}

// 5.10 — +12 days, next weekday tier
#[test]
fn test_format_relative_next_thursday() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-27", "2025-03-15"), Some("next Thursday".to_string()));
}

// 5.11 — -14 days, calendar fallback (same year)
#[test]
fn test_format_relative_calendar_same_year_past() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-01", "2025-03-15"), Some("March 1st".to_string()));
}

// 5.12 — +26 days, calendar fallback (same year)
#[test]
fn test_format_relative_calendar_same_year_future() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-04-10", "2025-03-15"), Some("April 10th".to_string()));
}

// 5.13 — Different year includes year
#[test]
fn test_format_relative_different_year_future() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2026-01-05", "2025-03-15"), Some("January 5th, 2026".to_string()));
}

// 5.14 — Past year includes year
#[test]
fn test_format_relative_different_year_past() {
    let sd = SayableDate::new(&locales::EN, Compactness::Normal);
    assert_eq!(sd.format_relative("2024-12-25", "2025-03-15"), Some("December 25th, 2024".to_string()));
}

// ── Section 6: format_relative — compact skips weekday tiers ────────

// 6.1
#[test]
fn test_format_relative_compact_today() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_relative("2025-03-15", "2025-03-15"), Some("today".to_string()));
}

// 6.2
#[test]
fn test_format_relative_compact_tomorrow() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("tomorrow".to_string()));
}

// 6.3 — Compact goes straight to numeric
#[test]
fn test_format_relative_compact_numeric() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_relative("2025-03-19", "2025-03-15"), Some("3/19".to_string()));
}

// 6.4
#[test]
fn test_format_relative_compact_different_year() {
    let sd = SayableDate::new(&locales::EN, Compactness::Compact);
    assert_eq!(sd.format_relative("2026-01-05", "2025-03-15"), Some("1/5/26".to_string()));
}

// ── Section 7: Locale — German ──────────────────────────────────────

// 7.1
#[test]
fn test_german_format_date() {
    let sd = SayableDate::new(&locales::DE, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("15. M\u{00e4}rz".to_string()));
}

// 7.2
#[test]
fn test_german_tomorrow() {
    let sd = SayableDate::new(&locales::DE, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("morgen".to_string()));
}

// 7.3
#[test]
fn test_german_day_after_tomorrow() {
    let sd = SayableDate::new(&locales::DE, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-17", "2025-03-15"), Some("\u{00fc}bermorgen".to_string()));
}

// 7.4
#[test]
fn test_german_this_wednesday() {
    let sd = SayableDate::new(&locales::DE, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-19", "2025-03-15"), Some("diesen Mittwoch".to_string()));
}

// ── Section 8: Locale — French ──────────────────────────────────────

// 8.1
#[test]
fn test_french_format_date_first() {
    let sd = SayableDate::new(&locales::FR, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-01"), Some("1er mars".to_string()));
}

// 8.2
#[test]
fn test_french_format_date() {
    let sd = SayableDate::new(&locales::FR, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("15 mars".to_string()));
}

// 8.3
#[test]
fn test_french_tomorrow() {
    let sd = SayableDate::new(&locales::FR, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("demain".to_string()));
}

// ── Section 9: Locale — Japanese ────────────────────────────────────

// 9.1
#[test]
fn test_japanese_format_date() {
    let sd = SayableDate::new(&locales::JA, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("3\u{6708}15\u{65e5}".to_string()));
}

// 9.2
#[test]
fn test_japanese_tomorrow() {
    let sd = SayableDate::new(&locales::JA, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("\u{660e}\u{65e5}".to_string()));
}

// 9.3
#[test]
fn test_japanese_this_wednesday() {
    let sd = SayableDate::new(&locales::JA, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-19", "2025-03-15"), Some("\u{4eca}\u{5ea6}\u{306e}\u{6c34}\u{66dc}\u{65e5}".to_string()));
}

// ── Section 10: Locale — Russian (genitive months) ──────────────────

// 10.1 — Uses genitive form
#[test]
fn test_russian_format_date_genitive() {
    let sd = SayableDate::new(&locales::RU, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("15 \u{043c}\u{0430}\u{0440}\u{0442}\u{0430}".to_string()));
}

// 10.2
#[test]
fn test_russian_tomorrow() {
    let sd = SayableDate::new(&locales::RU, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("\u{0437}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}".to_string()));
}

// ── Section 11: Locale — Arabic ─────────────────────────────────────

// 11.1
#[test]
fn test_arabic_format_date() {
    let sd = SayableDate::new(&locales::AR, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("15 \u{0645}\u{0627}\u{0631}\u{0633}".to_string()));
}

// 11.2
#[test]
fn test_arabic_tomorrow() {
    let sd = SayableDate::new(&locales::AR, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-16", "2025-03-15"), Some("\u{063a}\u{062f}\u{0627}\u{064b}".to_string()));
}

// ── Section 12: Locale — Spanish ────────────────────────────────────

// 12.1
#[test]
fn test_spanish_format_date() {
    let sd = SayableDate::new(&locales::ES, Compactness::Normal);
    assert_eq!(sd.format_date("2025-03-15"), Some("15 de marzo".to_string()));
}

// 12.2
#[test]
fn test_spanish_day_after_tomorrow() {
    let sd = SayableDate::new(&locales::ES, Compactness::Normal);
    assert_eq!(sd.format_relative("2025-03-17", "2025-03-15"), Some("pasado ma\u{00f1}ana".to_string()));
}
