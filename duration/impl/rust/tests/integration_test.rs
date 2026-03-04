use sayable_duration::formatter::SayableDuration;
use sayable_duration::types::Compactness;

// ================================================================
// Section 1: Null / edge cases
// ================================================================

// 1.1
#[test]
fn test_format_duration_none() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(-999), None);
}

// 1.2
#[test]
fn test_format_duration_negative() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(-1), None);
}

// 1.3
#[test]
fn test_format_since_none_start() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_since("", "2025-01-15T10:00:00"), None);
}

// 1.4
#[test]
fn test_format_until_none_target() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_until("", "2025-01-15T10:00:00"), None);
}

// 1.5
#[test]
fn test_format_since_future_start() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00"), None);
}

// 1.6
#[test]
fn test_format_until_past_target() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00"), None);
}

// ================================================================
// Section 2: Duration -- seconds tier (0-59s)
// ================================================================

// 2.1
#[test]
fn test_zero() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(0), Some("just now".to_string()));
}

// 2.2
#[test]
fn test_one_second() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(1), Some("1 second".to_string()));
}

// 2.3
#[test]
fn test_45_seconds() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(45), Some("45 seconds".to_string()));
}

// 2.4
#[test]
fn test_59_seconds() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(59), Some("59 seconds".to_string()));
}

// ================================================================
// Section 3: Duration -- minutes + seconds tier (1-4 min)
// ================================================================

// 3.1
#[test]
fn test_one_minute() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(60), Some("1 minute".to_string()));
}

// 3.2
#[test]
fn test_one_minute_thirty() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(90), Some("1 minute, 30 seconds".to_string()));
}

// 3.3
#[test]
fn test_four_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(240), Some("4 minutes".to_string()));
}

// 3.4
#[test]
fn test_four_minutes_thirty() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(270), Some("4 minutes, 30 seconds".to_string()));
}

// ================================================================
// Section 4: Duration -- minutes tier (5-59 min)
// ================================================================

// 4.1
#[test]
fn test_five_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(300), Some("5 minutes".to_string()));
}

// 4.2
#[test]
fn test_25_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(1500), Some("25 minutes".to_string()));
}

// 4.3
#[test]
fn test_59_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(3540), Some("59 minutes".to_string()));
}

// ================================================================
// Section 5: Duration -- hours + minutes tier (1-5 hr)
// ================================================================

// 5.1
#[test]
fn test_one_hour() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(3600), Some("1 hour".to_string()));
}

// 5.2
#[test]
fn test_one_and_half_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(5400), Some("1\u{00BD} hours".to_string()));
}

// 5.3
#[test]
fn test_two_hours_15_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(8100), Some("2 hours, 15 minutes".to_string()));
}

// 5.4
#[test]
fn test_five_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(18000), Some("5 hours".to_string()));
}

// ================================================================
// Section 6: Duration -- hours tier (6-23 hr)
// ================================================================

// 6.1
#[test]
fn test_eight_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(28800), Some("8 hours".to_string()));
}

// 6.2
#[test]
fn test_23_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(82800), Some("23 hours".to_string()));
}

// ================================================================
// Section 7: Duration -- days tier
// ================================================================

// 7.1
#[test]
fn test_one_day() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(86400), Some("1 day".to_string()));
}

// 7.2
#[test]
fn test_one_day_three_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(97200), Some("1 day, 3 hours".to_string()));
}

// 7.3
#[test]
fn test_one_and_half_days() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(129600), Some("1\u{00BD} days".to_string()));
}

// 7.4
#[test]
fn test_five_days() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(432000), Some("5 days".to_string()));
}

// 7.5
#[test]
fn test_two_days() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(172800), Some("2 days".to_string()));
}

// ================================================================
// Section 8: Duration -- weeks tier
// ================================================================

// 8.1
#[test]
fn test_one_week() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(604800), Some("1 week".to_string()));
}

// 8.2
#[test]
fn test_two_weeks_one_day() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(1296000), Some("2 weeks, 1 day".to_string()));
}

// 8.3
#[test]
fn test_four_weeks() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(2419200), Some("4 weeks".to_string()));
}

// ================================================================
// Section 9: Duration -- months and years tier
// ================================================================

// 9.1
#[test]
fn test_one_month() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(2678400), Some("1 month".to_string()));
}

// 9.2
#[test]
fn test_three_months() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(7884000), Some("3 months".to_string()));
}

// 9.3
#[test]
fn test_one_year() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(31536000), Some("1 year".to_string()));
}

// 9.4
#[test]
fn test_one_year_three_months() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(39420000), Some("1 year, 3 months".to_string()));
}

// ================================================================
// Section 10: Duration from ISO timestamps
// ================================================================

// 10.1
#[test]
fn test_iso_one_and_half_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T11:30:00"),
        Some("1\u{00BD} hours".to_string())
    );
}

// 10.2
#[test]
fn test_iso_45_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
        Some("45 minutes".to_string())
    );
}

// ================================================================
// Section 11: Relative time -- since
// ================================================================

// 11.1
#[test]
fn test_since_just_now() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00"),
        Some("just now".to_string())
    );
}

// 11.2
#[test]
fn test_since_30_seconds_ago() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30"),
        Some("30 seconds ago".to_string())
    );
}

// 11.3
#[test]
fn test_since_45_minutes_ago() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
        Some("45 minutes ago".to_string())
    );
}

// 11.4
#[test]
fn test_since_three_hours_ago() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00"),
        Some("3 hours ago".to_string())
    );
}

// ================================================================
// Section 12: Relative time -- until
// ================================================================

// 12.1
#[test]
fn test_until_just_now() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00"),
        Some("just now".to_string())
    );
}

// 12.2
#[test]
fn test_until_in_20_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00"),
        Some("in 20 minutes".to_string())
    );
}

// 12.3
#[test]
fn test_until_in_3_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Normal);
    assert_eq!(
        sd.format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00"),
        Some("in 3 hours".to_string())
    );
}

// ================================================================
// Section 13: Locale -- German
// ================================================================

// 13.1
#[test]
fn test_german_one_hour() {
    let sd = SayableDuration::new(&sayable_duration::locales::DE, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(3600), Some("1 Stunde".to_string()));
}

// 13.2
#[test]
fn test_german_since_five_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::DE, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00"),
        Some("vor 5 Minuten".to_string())
    );
}

// ================================================================
// Section 14: Locale -- French
// ================================================================

// 14.1
#[test]
fn test_french_two_hours() {
    let sd = SayableDuration::new(&sayable_duration::locales::FR, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(7200), Some("2 heures".to_string()));
}

// ================================================================
// Section 15: Locale -- Japanese
// ================================================================

// 15.1
#[test]
fn test_japanese_two_minutes() {
    let sd = SayableDuration::new(&sayable_duration::locales::JA, Compactness::Normal);
    assert_eq!(sd.format_duration_seconds(120), Some("2\u{5206}".to_string()));
}

// 15.2
#[test]
fn test_japanese_since_one_hour() {
    let sd = SayableDuration::new(&sayable_duration::locales::JA, Compactness::Normal);
    assert_eq!(
        sd.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00"),
        Some("1\u{6642}\u{9593}\u{524D}".to_string())
    );
}

// ================================================================
// Section 16: Short compactness -- duration
// ================================================================

// 16.1
#[test]
fn test_short_one_hour() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Short);
    assert_eq!(sd.format_duration_seconds(3600), Some("1h".to_string()));
}

// 16.2
#[test]
fn test_short_one_minute_thirty_seconds() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Short);
    assert_eq!(sd.format_duration_seconds(90), Some("1m, 30s".to_string()));
}

// ================================================================
// Section 17: Compact compactness -- duration
// ================================================================

// 17.1
#[test]
fn test_compact_one_hour() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Compact);
    assert_eq!(sd.format_duration_seconds(3600), Some("1h".to_string()));
}

// 17.2
#[test]
fn test_compact_one_minute_thirty_seconds() {
    let sd = SayableDuration::new(&sayable_duration::locales::EN, Compactness::Compact);
    assert_eq!(sd.format_duration_seconds(90), Some("1m30s".to_string()));
}
