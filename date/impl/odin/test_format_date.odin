package sayabledate

import "core:testing"
import "core:fmt"

expect_str :: proc(t: ^testing.T, expected: string, actual: Maybe(string), loc := #caller_location) {
    if v, ok := actual.?; ok {
        testing.expect_value(t, v, expected, loc = loc)
    } else {
        fmt.printf("Expected %q but got nil at %v\n", expected, loc)
        testing.expect(t, false, loc = loc)
    }
}

expect_nil :: proc(t: ^testing.T, actual: Maybe(string), loc := #caller_location) {
    if v, ok := actual.?; ok {
        fmt.printf("Expected nil but got %q at %v\n", v, loc)
        testing.expect(t, false, loc = loc)
    }
}

fmt_date :: proc(buf: []u8, date: string) -> Maybe(string) {
    return format_date(buf, &locale_en, .Normal, date)
}

fmt_date_yr :: proc(buf: []u8, date: string) -> Maybe(string) {
    return format_date_with_year(buf, &locale_en, .Normal, date)
}

fmt_rel :: proc(buf: []u8, date, as_of: string) -> Maybe(string) {
    return format_relative(buf, &locale_en, .Normal, date, as_of)
}

// ================================================================
// Null / edge cases (1.1 - 1.5)
// ================================================================

// 1.1
@(test)
test_null_date :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_date(buf[:], ""))
}

// 1.2
@(test)
test_empty_date :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_date(buf[:], ""))
}

// 1.3
@(test)
test_invalid_date :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_date(buf[:], "invalid"))
}

// 1.4
@(test)
test_relative_null_asof :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_relative(buf[:], &locale_en, .Normal, "2025-03-15", ""))
}

// 1.5
@(test)
test_relative_null_date :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_relative(buf[:], &locale_en, .Normal, "", "2025-03-15"))
}

// ================================================================
// format_date — normal compactness (2.1 - 2.7)
// ================================================================

// 2.1
@(test)
test_date_mar15 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "March 15th", fmt_date(buf[:], "2025-03-15")) }

// 2.2
@(test)
test_date_jan1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "January 1st", fmt_date(buf[:], "2025-01-01")) }

// 2.3
@(test)
test_date_may22 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "May 22nd", fmt_date(buf[:], "2025-05-22")) }

// 2.4
@(test)
test_date_jul3 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "July 3rd", fmt_date(buf[:], "2025-07-03")) }

// 2.5
@(test)
test_date_dec31 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "December 31st", fmt_date(buf[:], "2025-12-31")) }

// 2.6
@(test)
test_date_jun11 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "June 11th", fmt_date(buf[:], "2025-06-11")) }

// 2.7
@(test)
test_date_iso_datetime :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "March 15th", fmt_date(buf[:], "2025-03-15T14:30:00")) }

// ================================================================
// format_date — short compactness (3.1 - 3.3)
// ================================================================

// 3.1
@(test)
test_short_mar15 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Mar 15", format_date(buf[:], &locale_en, .Short, "2025-03-15")) }

// 3.2
@(test)
test_short_jan1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Jan 1", format_date(buf[:], &locale_en, .Short, "2025-01-01")) }

// 3.3
@(test)
test_short_dec25 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Dec 25", format_date(buf[:], &locale_en, .Short, "2025-12-25")) }

// ================================================================
// format_date — compact (4.1 - 4.2)
// ================================================================

// 4.1
@(test)
test_compact_mar15 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3/15", format_date(buf[:], &locale_en, .Compact, "2025-03-15")) }

// 4.2
@(test)
test_compact_jan1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1/1", format_date(buf[:], &locale_en, .Compact, "2025-01-01")) }

// ================================================================
// format_relative — proximity tiers (5.1 - 5.14)
// ================================================================

// 5.1
@(test)
test_rel_today :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "today", fmt_rel(buf[:], "2025-03-15", "2025-03-15")) }

// 5.2
@(test)
test_rel_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "tomorrow", fmt_rel(buf[:], "2025-03-16", "2025-03-15")) }

// 5.3
@(test)
test_rel_yesterday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "yesterday", fmt_rel(buf[:], "2025-03-14", "2025-03-15")) }

// 5.4
@(test)
test_rel_day_after_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "the day after tomorrow", fmt_rel(buf[:], "2025-03-17", "2025-03-15")) }

// 5.5
@(test)
test_rel_day_before_yesterday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "the day before yesterday", fmt_rel(buf[:], "2025-03-13", "2025-03-15")) }

// 5.6
@(test)
test_rel_this_wed :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "this Wednesday", fmt_rel(buf[:], "2025-03-19", "2025-03-15")) }

// 5.7
@(test)
test_rel_this_thu :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "this Thursday", fmt_rel(buf[:], "2025-03-20", "2025-03-15")) }

// 5.8
@(test)
test_rel_last_tue :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "last Tuesday", fmt_rel(buf[:], "2025-03-11", "2025-03-15")) }

// 5.9
@(test)
test_rel_next_sat :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "next Saturday", fmt_rel(buf[:], "2025-03-22", "2025-03-15")) }

// 5.10
@(test)
test_rel_next_thu :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "next Thursday", fmt_rel(buf[:], "2025-03-27", "2025-03-15")) }

// 5.11
@(test)
test_rel_calendar_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "March 1st", fmt_rel(buf[:], "2025-03-01", "2025-03-15")) }

// 5.12
@(test)
test_rel_calendar_future :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "April 10th", fmt_rel(buf[:], "2025-04-10", "2025-03-15")) }

// 5.13
@(test)
test_rel_diff_year_future :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "January 5th, 2026", fmt_rel(buf[:], "2026-01-05", "2025-03-15")) }

// 5.14
@(test)
test_rel_diff_year_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "December 25th, 2024", fmt_rel(buf[:], "2024-12-25", "2025-03-15")) }

// ================================================================
// format_relative — compact skips weekday tiers (6.1 - 6.4)
// ================================================================

// 6.1
@(test)
test_compact_rel_today :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "today", format_relative(buf[:], &locale_en, .Compact, "2025-03-15", "2025-03-15")) }

// 6.2
@(test)
test_compact_rel_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "tomorrow", format_relative(buf[:], &locale_en, .Compact, "2025-03-16", "2025-03-15")) }

// 6.3
@(test)
test_compact_rel_numeric :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3/19", format_relative(buf[:], &locale_en, .Compact, "2025-03-19", "2025-03-15")) }

// 6.4
@(test)
test_compact_rel_diff_year :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1/5/26", format_relative(buf[:], &locale_en, .Compact, "2026-01-05", "2025-03-15")) }

// ================================================================
// Locale — German (7.1 - 7.4)
// ================================================================

// 7.1
@(test)
test_de_date :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "15. M\u00e4rz", format_date(buf[:], &locale_de, .Normal, "2025-03-15")) }

// 7.2
@(test)
test_de_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "morgen", format_relative(buf[:], &locale_de, .Normal, "2025-03-16", "2025-03-15")) }

// 7.3
@(test)
test_de_day_after_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u00fcbermorgen", format_relative(buf[:], &locale_de, .Normal, "2025-03-17", "2025-03-15")) }

// 7.4
@(test)
test_de_this_weekday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "diesen Mittwoch", format_relative(buf[:], &locale_de, .Normal, "2025-03-19", "2025-03-15")) }

// ================================================================
// Locale — French (8.1 - 8.3)
// ================================================================

// 8.1
@(test)
test_fr_1er :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1er mars", format_date(buf[:], &locale_fr, .Normal, "2025-03-01")) }

// 8.2
@(test)
test_fr_15 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "15 mars", format_date(buf[:], &locale_fr, .Normal, "2025-03-15")) }

// 8.3
@(test)
test_fr_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "demain", format_relative(buf[:], &locale_fr, .Normal, "2025-03-16", "2025-03-15")) }

// ================================================================
// Locale — Japanese (9.1 - 9.3)
// ================================================================

// 9.1
@(test)
test_ja_date :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u670815\u65e5", format_date(buf[:], &locale_ja, .Normal, "2025-03-15")) }

// 9.2
@(test)
test_ja_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u660e\u65e5", format_relative(buf[:], &locale_ja, .Normal, "2025-03-16", "2025-03-15")) }

// 9.3
@(test)
test_ja_this_weekday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u4eca\u5ea6\u306e\u6c34\u66dc\u65e5", format_relative(buf[:], &locale_ja, .Normal, "2025-03-19", "2025-03-15")) }

// ================================================================
// Locale — Russian (10.1 - 10.2)
// ================================================================

// 10.1
@(test)
test_ru_date :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "15 \u043c\u0430\u0440\u0442\u0430", format_date(buf[:], &locale_ru, .Normal, "2025-03-15")) }

// 10.2
@(test)
test_ru_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u0437\u0430\u0432\u0442\u0440\u0430", format_relative(buf[:], &locale_ru, .Normal, "2025-03-16", "2025-03-15")) }

// ================================================================
// Locale — Arabic (11.1 - 11.2)
// ================================================================

// 11.1
@(test)
test_ar_date :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "15 \u0645\u0627\u0631\u0633", format_date(buf[:], &locale_ar, .Normal, "2025-03-15")) }

// 11.2
@(test)
test_ar_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u063a\u062f\u0627\u064b", format_relative(buf[:], &locale_ar, .Normal, "2025-03-16", "2025-03-15")) }

// ================================================================
// Locale — Spanish (12.1 - 12.2)
// ================================================================

// 12.1
@(test)
test_es_date :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "15 de marzo", format_date(buf[:], &locale_es, .Normal, "2025-03-15")) }

// 12.2
@(test)
test_es_day_after_tomorrow :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "pasado ma\u00f1ana", format_relative(buf[:], &locale_es, .Normal, "2025-03-17", "2025-03-15")) }

// ================================================================
// Locale lookup
// ================================================================
@(test) test_get_locale_en :: proc(t: ^testing.T) { loc := get_locale("en"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "en") }
@(test) test_get_locale_fr :: proc(t: ^testing.T) { loc := get_locale("fr"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "fr") }
@(test) test_get_locale_unknown :: proc(t: ^testing.T) { testing.expect(t, get_locale("xx") == nil) }
@(test) test_get_locale_empty :: proc(t: ^testing.T) { testing.expect(t, get_locale("") == nil) }
