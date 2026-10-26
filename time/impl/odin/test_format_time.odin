package sayabletime

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

fmt_time :: proc(buf: []u8, input: string) -> Maybe(string) {
    return format_time(buf, &locale_en, .Normal, input)
}

// ================================================================
// Null / edge cases (1.1 - 1.4)
// ================================================================

// 1.1
@(test)
test_null_time :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_time(buf[:], ""))
}

// 1.2
@(test)
test_empty_time :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_time(buf[:], ""))
}

// 1.3
@(test)
test_invalid_time :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_time(buf[:], "invalid"))
}

// 1.4
@(test)
test_invalid_hour :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_time(buf[:], "25:00"))
}

// ================================================================
// Clock time — normal compactness (2.1 - 2.11)
// ================================================================

// 2.1
@(test)
test_midnight :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "midnight", fmt_time(buf[:], "00:00")) }

// 2.2
@(test)
test_noon :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "noon", fmt_time(buf[:], "12:00")) }

// 2.3
@(test)
test_3_oclock :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "three o'clock", fmt_time(buf[:], "15:00")) }

// 2.4
@(test)
test_quarter_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "a quarter past two", fmt_time(buf[:], "14:15")) }

// 2.5
@(test)
test_half_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "half past nine", fmt_time(buf[:], "09:30")) }

// 2.6
@(test)
test_quarter_to :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "a quarter to eleven", fmt_time(buf[:], "10:45")) }

// 2.7
@(test)
test_five_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "five past eight", fmt_time(buf[:], "08:05")) }

// 2.8
@(test)
test_five_to :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "five to five", fmt_time(buf[:], "16:55")) }

// 2.9
@(test)
test_rounds_to_midnight :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "midnight", fmt_time(buf[:], "23:58")) }

// 2.10
@(test)
test_rounds_to_20 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "twenty past seven", fmt_time(buf[:], "07:22")) }

// 2.11
@(test)
test_iso_datetime :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "a quarter past two", fmt_time(buf[:], "2025-01-15T14:15:00")) }

// ================================================================
// Clock time — short compactness (3.1 - 3.4)
// ================================================================

// 3.1
@(test)
test_short_pm :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2:15 PM", format_time(buf[:], &locale_en, .Short, "14:15")) }

// 3.2
@(test)
test_short_am :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "9:30 AM", format_time(buf[:], &locale_en, .Short, "09:30")) }

// 3.3
@(test)
test_short_midnight :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "12:00 AM", format_time(buf[:], &locale_en, .Short, "00:00")) }

// 3.4
@(test)
test_short_noon :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "12:00 PM", format_time(buf[:], &locale_en, .Short, "12:00")) }

// ================================================================
// Clock time — compact (4.1 - 4.2)
// ================================================================

// 4.1
@(test)
test_compact_pm :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2:15p", format_time(buf[:], &locale_en, .Compact, "14:15")) }

// 4.2
@(test)
test_compact_am :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "9:30a", format_time(buf[:], &locale_en, .Compact, "09:30")) }

// ================================================================
// Locale — German (5.1)
// ================================================================

// 5.1
@(test)
test_de_half_four :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "halb vier", format_time(buf[:], &locale_de, .Normal, "15:30")) }

// ================================================================
// Locale — French (6.1)
// ================================================================

// 6.1
@(test)
test_fr_quarter_past :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "trois heures et quart", format_time(buf[:], &locale_fr, .Normal, "15:15")) }

// 6.2
@(test)
test_fr_one_oclock :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "une heure", format_time(buf[:], &locale_fr, .Normal, "13:00")) }

// 6.3
@(test)
test_fr_half_past_one :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "une heure et demie", format_time(buf[:], &locale_fr, .Normal, "13:30")) }

// 6.4
@(test)
test_fr_quarter_to_three :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "trois heures moins le quart", format_time(buf[:], &locale_fr, .Normal, "14:45")) }

// 6.5
@(test)
test_fr_ten_to_three :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "trois heures moins dix", format_time(buf[:], &locale_fr, .Normal, "14:50")) }

// ================================================================
// Locale — Japanese (7.1)
// ================================================================

// 7.1
@(test)
test_ja_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "\u4e09\u6642\u534a", format_time(buf[:], &locale_ja, .Normal, "15:30")) }

// ================================================================
// Locale — Finnish dot separator (8.1 - 8.2)
// ================================================================

// 8.1
@(test)
test_fi_short :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "14.15", format_time(buf[:], &locale_fi, .Short, "14:15")) }

// 8.2
@(test)
test_fi_midnight :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "0.00", format_time(buf[:], &locale_fi, .Short, "00:00")) }

// ================================================================
// Locale lookup
// ================================================================
@(test) test_get_locale_en :: proc(t: ^testing.T) { loc := get_locale("en"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "en") }
@(test) test_get_locale_fr :: proc(t: ^testing.T) { loc := get_locale("fr"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "fr") }
@(test) test_get_locale_unknown :: proc(t: ^testing.T) { testing.expect(t, get_locale("xx") == nil) }
@(test) test_get_locale_empty :: proc(t: ^testing.T) { testing.expect(t, get_locale("") == nil) }

// ================================================================
// Section 9: Minutes in short and compact modes
// ================================================================
// 9.1
@(test) test_9_1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6:01 PM", format_time(buf[:], &locale_en, .Short, "18:01")) }
// 9.2
@(test) test_9_2 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7:05p", format_time(buf[:], &locale_en, .Compact, "19:05")) }

// ================================================================
// Section 10: Input validation
// ================================================================
// 10.1
@(test) test_10_1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "half past nine", format_time(buf[:], &locale_en, .Normal, "9:30")) }
// 10.2
@(test) test_10_2 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "half past nine", format_time(buf[:], &locale_en, .Normal, "09:30")) }
// 10.3
@(test) test_10_3 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_time(buf[:], &locale_en, .Normal, " 9:30")) }
// 10.4
@(test) test_10_4 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_time(buf[:], &locale_en, .Normal, "9:30 ")) }
// 10.5
@(test) test_10_5 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_time(buf[:], &locale_en, .Normal, "9:5")) }
// 10.6
@(test) test_10_6 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_time(buf[:], &locale_en, .Normal, "24:00")) }
// 10.7
@(test) test_10_7 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "a quarter past two", format_time(buf[:], &locale_en, .Normal, "14:15:30")) }
// 10.8
@(test) test_10_8 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "a quarter past two", format_time(buf[:], &locale_en, .Normal, "2025-01-15T14:15:00Z")) }
// 10.9
@(test) test_10_9 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_time(buf[:], &locale_en, .Normal, "2025-02-30T14:15:00")) }
