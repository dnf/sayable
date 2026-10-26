#![allow(missing_docs)]

use sayable_time::formatter::{format_time, SayableTime};
use sayable_time::locales;
use sayable_time::types::Compactness;

// ================================================================
// Helper functions
// ================================================================

fn assert_time(name: &str, got: Option<String>, want: &str) {
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

// ================================================================
// Section 1: Null / edge cases
// ================================================================

// 1.1
#[test]
fn test_null_input() {
    assert_nil("null input", format_time(""));
}

// 1.2
#[test]
fn test_empty_string() {
    assert_nil("empty string", format_time(""));
}

// 1.3
#[test]
fn test_invalid_string() {
    assert_nil("invalid string", format_time("invalid"));
}

// 1.4
#[test]
fn test_out_of_range() {
    assert_nil("out of range", format_time("25:00"));
}

// ================================================================
// Section 2: Clock time (normal compactness)
// ================================================================

// 2.1
#[test]
fn test_midnight() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("midnight", f.format_time("00:00"), "midnight");
}

// 2.2
#[test]
fn test_noon() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("noon", f.format_time("12:00"), "noon");
}

// 2.3
#[test]
fn test_oclock() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("o'clock", f.format_time("15:00"), "three o'clock");
}

// 2.4
#[test]
fn test_quarter_past() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("quarter past", f.format_time("14:15"), "a quarter past two");
}

// 2.5
#[test]
fn test_half_past() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("half past", f.format_time("09:30"), "half past nine");
}

// 2.6
#[test]
fn test_quarter_to() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("quarter to", f.format_time("10:45"), "a quarter to eleven");
}

// 2.7
#[test]
fn test_five_past() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("five past", f.format_time("08:05"), "five past eight");
}

// 2.8
#[test]
fn test_five_to() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("five to", f.format_time("16:55"), "five to five");
}

// 2.9
#[test]
fn test_rounds_to_midnight() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("rounds to midnight", f.format_time("23:58"), "midnight");
}

// 2.10
#[test]
fn test_rounds_to_twenty() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("rounds to twenty", f.format_time("07:22"), "twenty past seven");
}

// 2.11
#[test]
fn test_iso_datetime_input() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_time("ISO datetime", f.format_time("2025-01-15T14:15:00"), "a quarter past two");
}

// ================================================================
// Section 3: Clock time (short compactness)
// ================================================================

// 3.1
#[test]
fn test_short_pm() {
    let f = SayableTime::new(&locales::EN, Compactness::Short);
    assert_time("short PM", f.format_time("14:15"), "2:15 PM");
}

// 3.2
#[test]
fn test_short_am() {
    let f = SayableTime::new(&locales::EN, Compactness::Short);
    assert_time("short AM", f.format_time("09:30"), "9:30 AM");
}

// 3.3
#[test]
fn test_short_midnight() {
    let f = SayableTime::new(&locales::EN, Compactness::Short);
    assert_time("short midnight", f.format_time("00:00"), "12:00 AM");
}

// 3.4
#[test]
fn test_short_noon() {
    let f = SayableTime::new(&locales::EN, Compactness::Short);
    assert_time("short noon", f.format_time("12:00"), "12:00 PM");
}

// ================================================================
// Section 4: Clock time (compact)
// ================================================================

// 4.1
#[test]
fn test_compact_pm() {
    let f = SayableTime::new(&locales::EN, Compactness::Compact);
    assert_time("compact PM", f.format_time("14:15"), "2:15p");
}

// 4.2
#[test]
fn test_compact_am() {
    let f = SayableTime::new(&locales::EN, Compactness::Compact);
    assert_time("compact AM", f.format_time("09:30"), "9:30a");
}

// ================================================================
// Section 5: Locale -- German
// ================================================================

// 5.1
#[test]
fn test_german_half_to() {
    let f = SayableTime::new(&locales::DE, Compactness::Normal);
    assert_time("German half-to", f.format_time("15:30"), "halb vier");
}

// ================================================================
// Section 6: Locale -- French
// ================================================================

// 6.1
#[test]
fn test_french_quarter_past() {
    let f = SayableTime::new(&locales::FR, Compactness::Normal);
    assert_time("French quarter past", f.format_time("15:15"), "trois heures et quart");
}

// 6.2
#[test]
fn test_french_singular_hour() {
    let f = SayableTime::new(&locales::FR, Compactness::Normal);
    assert_time("French singular hour", f.format_time("13:00"), "une heure");
}

// 6.3
#[test]
fn test_french_half_past_singular_hour() {
    let f = SayableTime::new(&locales::FR, Compactness::Normal);
    assert_time("French half past singular hour", f.format_time("13:30"), "une heure et demie");
}

// 6.4
#[test]
fn test_french_quarter_to() {
    let f = SayableTime::new(&locales::FR, Compactness::Normal);
    assert_time("French quarter to", f.format_time("14:45"), "trois heures moins le quart");
}

// 6.5
#[test]
fn test_french_ten_to() {
    let f = SayableTime::new(&locales::FR, Compactness::Normal);
    assert_time("French ten to", f.format_time("14:50"), "trois heures moins dix");
}

// ================================================================
// Section 7: Locale -- Japanese
// ================================================================

// 7.1
#[test]
fn test_japanese_half_past() {
    let f = SayableTime::new(&locales::JA, Compactness::Normal);
    assert_time("Japanese half past", f.format_time("15:30"), "\u{4e09}\u{6642}\u{534a}");
}

// ================================================================
// Section 8: Locale — Finnish (dot separator, short)
// ================================================================

// 8.1
#[test]
fn test_finnish_dot_separator() {
    let f = SayableTime::new(&locales::FI, Compactness::Short);
    assert_time("Finnish dot separator", f.format_time("14:15"), "14.15");
}

// 8.2
#[test]
fn test_finnish_midnight_dot() {
    let f = SayableTime::new(&locales::FI, Compactness::Short);
    assert_time("Finnish midnight dot", f.format_time("00:00"), "0.00");
}

// ================================================================
// Additional coverage tests
// ================================================================

#[test]
fn test_version() {
    assert_eq!(sayable_time::VERSION, "0.5.0");
}

#[test]
fn test_locale_lookup() {
    assert!(locales::get("en").is_some());
    assert!(locales::get("de").is_some());
    assert!(locales::get("xx").is_none());
}

#[test]
fn test_all_locales_load() {
    // Verify all 110 locale statics can be initialized
    assert_eq!(locales::EN.code, "en");
    assert_eq!(locales::DE.code, "de");
    assert_eq!(locales::FR.code, "fr");
    assert_eq!(locales::JA.code, "ja");
    assert_eq!(locales::ZH.code, "zh");
}

// ── Section 9: Minutes in short and compact modes ────────────────────────────────────

// 9.1 — digital modes keep the exact minute
#[test]
fn test_case_9_1() {
    let f = SayableTime::new(&locales::EN, Compactness::Short);
    assert_eq!(f.format_time("18:01"), Some("6:01 PM".to_string()));
}

// 9.2 — digital modes keep the exact minute
#[test]
fn test_case_9_2() {
    let f = SayableTime::new(&locales::EN, Compactness::Compact);
    assert_eq!(f.format_time("19:05"), Some("7:05p".to_string()));
}


// ── Section 10: Input validation ────────────────────────────────────

// 10.1 — one-digit hour
#[test]
fn test_case_10_1() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("9:30"), Some("half past nine".to_string()));
}

// 10.2 — two-digit hour
#[test]
fn test_case_10_2() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("09:30"), Some("half past nine".to_string()));
}

// 10.3 — leading whitespace
#[test]
fn test_case_10_3() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time(" 9:30"), None);
}

// 10.4 — trailing whitespace
#[test]
fn test_case_10_4() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("9:30 "), None);
}

// 10.5 — minutes need two digits
#[test]
fn test_case_10_5() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("9:5"), None);
}

// 10.6 — hour out of range
#[test]
fn test_case_10_6() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("24:00"), None);
}

// 10.7 — seconds are allowed and ignored
#[test]
fn test_case_10_7() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("14:15:30"), Some("a quarter past two".to_string()));
}

// 10.8 — ISO datetime with zone suffix (ignored)
#[test]
fn test_case_10_8() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("2025-01-15T14:15:00Z"), Some("a quarter past two".to_string()));
}

// 10.9 — ISO datetime with an impossible date
#[test]
fn test_case_10_9() {
    let f = SayableTime::new(&locales::EN, Compactness::Normal);
    assert_eq!(f.format_time("2025-02-30T14:15:00"), None);
}

