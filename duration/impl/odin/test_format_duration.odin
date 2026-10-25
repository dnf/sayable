package sayableduration

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

fmt_dur :: proc(buf: []u8, seconds: int) -> Maybe(string) {
    return format_duration_int(buf, &locale_en, .Normal, seconds)
}

// ================================================================
// Null / edge cases (1.1 - 1.6)
// ================================================================

// 1.1
@(test)
test_null_seconds :: proc(t: ^testing.T) {
    buf: [256]u8
    // Odin has no null int; -1 is closest to invalid
    expect_nil(t, format_duration_int(buf[:], &locale_en, .Normal, -1))
}

// 1.2
@(test)
test_negative_seconds :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_duration_int(buf[:], &locale_en, .Normal, -1))
}

// 1.3
@(test)
test_since_null_start :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_since(buf[:], &locale_en, .Normal, "", "2025-01-15T10:00:00"))
}

// 1.4
@(test)
test_until_null_target :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_until(buf[:], &locale_en, .Normal, "", "2025-01-15T10:00:00"))
}

// 1.5
@(test)
test_since_asof_before_start :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T09:00:00"))
}

// 1.6
@(test)
test_until_target_in_past :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, format_until(buf[:], &locale_en, .Normal, "2025-01-15T09:00:00", "2025-01-15T10:00:00"))
}

// ================================================================
// Duration — seconds tier (2.1 - 2.4)
// ================================================================

// 2.1
@(test)
test_0s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "just now", fmt_dur(buf[:], 0)) }

// 2.2
@(test)
test_1s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 second", fmt_dur(buf[:], 1)) }

// 2.3
@(test)
test_45s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "45 seconds", fmt_dur(buf[:], 45)) }

// 2.4
@(test)
test_59s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "59 seconds", fmt_dur(buf[:], 59)) }

// ================================================================
// Duration — minutes + seconds tier (3.1 - 3.4)
// ================================================================

// 3.1
@(test)
test_60s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 minute", fmt_dur(buf[:], 60)) }

// 3.2
@(test)
test_90s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 minute, 30 seconds", fmt_dur(buf[:], 90)) }

// 3.3
@(test)
test_240s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 minutes", fmt_dur(buf[:], 240)) }

// 3.4
@(test)
test_270s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 minutes, 30 seconds", fmt_dur(buf[:], 270)) }

// ================================================================
// Duration — minutes tier (4.1 - 4.3)
// ================================================================

// 4.1
@(test)
test_5m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 minutes", fmt_dur(buf[:], 300)) }

// 4.2
@(test)
test_25m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "25 minutes", fmt_dur(buf[:], 1500)) }

// 4.3
@(test)
test_59m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "59 minutes", fmt_dur(buf[:], 3540)) }

// ================================================================
// Duration — hours + minutes tier (5.1 - 5.4)
// ================================================================

// 5.1
@(test)
test_1h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 hour", fmt_dur(buf[:], 3600)) }

// 5.2
@(test)
test_1_5h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1\u00BD hours", fmt_dur(buf[:], 5400)) }

// 5.3
@(test)
test_2h15m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 hours, 15 minutes", fmt_dur(buf[:], 8100)) }

// 5.4
@(test)
test_5h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 hours", fmt_dur(buf[:], 18000)) }

// ================================================================
// Duration — hours tier (6.1 - 6.2)
// ================================================================

// 6.1
@(test)
test_8h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "8 hours", fmt_dur(buf[:], 28800)) }

// 6.2
@(test)
test_23h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "23 hours", fmt_dur(buf[:], 82800)) }

// ================================================================
// Duration — days tier (7.1 - 7.5)
// ================================================================

// 7.1
@(test)
test_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 day", fmt_dur(buf[:], 86400)) }

// 7.2
@(test)
test_1d3h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 day, 3 hours", fmt_dur(buf[:], 97200)) }

// 7.3
@(test)
test_1_5d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1\u00BD days", fmt_dur(buf[:], 129600)) }

// 7.4
@(test)
test_5d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 days", fmt_dur(buf[:], 432000)) }

// 7.5
@(test)
test_2d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 days", fmt_dur(buf[:], 172800)) }

// ================================================================
// Duration — weeks tier (8.1 - 8.3)
// ================================================================

// 8.1
@(test)
test_1w :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week", fmt_dur(buf[:], 604800)) }

// 8.2
@(test)
test_2w1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 weeks, 1 day", fmt_dur(buf[:], 1296000)) }

// 8.3
@(test)
test_4w :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 weeks", fmt_dur(buf[:], 2419200)) }

// ================================================================
// Duration — months and years tier (9.1 - 9.4)
// ================================================================

// 9.1
@(test)
test_1mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 month", fmt_dur(buf[:], 2678400)) }

// 9.2
@(test)
test_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_dur(buf[:], 7884000)) }

// 9.3
@(test)
test_1y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 year", fmt_dur(buf[:], 31536000)) }

// 9.4
@(test)
test_1y3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 year, 3 months", fmt_dur(buf[:], 39420000)) }

// ================================================================
// Duration from ISO timestamps (10.1 - 10.2)
// ================================================================

// 10.1
@(test)
test_iso_1_5h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1\u00BD hours", format_duration_iso(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T11:30:00")) }

// 10.2
@(test)
test_iso_45m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "45 minutes", format_duration_iso(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:45:00")) }

// ================================================================
// Relative time — since (11.1 - 11.4)
// ================================================================

// 11.1
@(test)
test_since_now :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "just now", format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:00:00")) }

// 11.2
@(test)
test_since_30s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "30 seconds ago", format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:00:30")) }

// 11.3
@(test)
test_since_45m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "45 minutes ago", format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:45:00")) }

// 11.4
@(test)
test_since_3h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 hours ago", format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T13:00:00")) }

// ================================================================
// Relative time — until (12.1 - 12.3)
// ================================================================

// 12.1
@(test)
test_until_now :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "just now", format_until(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:00:00")) }

// 12.2
@(test)
test_until_20m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "in 20 minutes", format_until(buf[:], &locale_en, .Normal, "2025-01-15T10:20:00", "2025-01-15T10:00:00")) }

// 12.3
@(test)
test_until_3h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "in 3 hours", format_until(buf[:], &locale_en, .Normal, "2025-01-15T13:00:00", "2025-01-15T10:00:00")) }

// ================================================================
// Locale — German (13.1 - 13.2)
// ================================================================

// 13.1
@(test)
test_de_1h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 Stunde", format_duration_int(buf[:], &locale_de, .Normal, 3600)) }

// 13.2
@(test)
test_de_since_5m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "vor 5 Minuten", format_since(buf[:], &locale_de, .Normal, "2025-01-15T10:00:00", "2025-01-15T10:05:00")) }

// ================================================================
// Locale — French (14.1)
// ================================================================

// 14.1
@(test)
test_fr_2h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 heures", format_duration_int(buf[:], &locale_fr, .Normal, 7200)) }

// ================================================================
// Locale — Japanese (15.1 - 15.2)
// ================================================================

// 15.1
@(test)
test_ja_2m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2\u5206", format_duration_int(buf[:], &locale_ja, .Normal, 120)) }

// 15.2
@(test)
test_ja_since_1h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1\u6642\u9593\u524d", format_since(buf[:], &locale_ja, .Normal, "2025-01-15T10:00:00", "2025-01-15T11:00:00")) }

// ================================================================
// Short compactness (16.1 - 16.2)
// ================================================================

// 16.1
@(test)
test_short_1h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1h", format_duration_int(buf[:], &locale_en, .Short, 3600)) }

// 16.2
@(test)
test_short_1m30s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1m, 30s", format_duration_int(buf[:], &locale_en, .Short, 90)) }

// ================================================================
// Compact compactness (17.1 - 17.2)
// ================================================================

// 17.1
@(test)
test_compact_1h :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1h", format_duration_int(buf[:], &locale_en, .Compact, 3600)) }

// 17.2
@(test)
test_compact_1m30s :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1m30s", format_duration_int(buf[:], &locale_en, .Compact, 90)) }

// ================================================================
// Locale lookup
// ================================================================
@(test) test_get_locale_en :: proc(t: ^testing.T) { loc := get_locale("en"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "en") }
@(test) test_get_locale_fr :: proc(t: ^testing.T) { loc := get_locale("fr"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "fr") }
@(test) test_get_locale_unknown :: proc(t: ^testing.T) { testing.expect(t, get_locale("xx") == nil) }
@(test) test_get_locale_empty :: proc(t: ^testing.T) { testing.expect(t, get_locale("") == nil) }

// ================================================================
// Section 18: Short compactness — relative time
// ================================================================
// 18.1
@(test) test_18_1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "lɔhɔnga 2, awa 14 taa gbɔyɔ", format_since(buf[:], &locale_men, .Normal, "2025-01-20T01:32:11", "2025-01-22T15:39:16")) }

// ================================================================
// Section 19: Range (500-year ceiling)
// ================================================================
// 19.1
@(test) test_19_1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "500 years", format_duration_int(buf[:], &locale_en, .Normal, 15778800000)) }
// 19.2
@(test) test_19_2 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_duration_int(buf[:], &locale_en, .Normal, 15800000000)) }
// 19.3
@(test) test_19_3 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_duration_int(buf[:], &locale_en, .Normal, 99999999999)) }
// 19.4
@(test) test_19_4 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_since(buf[:], &locale_en, .Normal, "1500-01-01T00:00:00", "2025-01-01T00:00:00")) }
// 19.5
@(test) test_19_5 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_until(buf[:], &locale_en, .Normal, "2600-01-01T00:00:00", "2025-01-01T00:00:00")) }

// ================================================================
// Section 20: Timestamp validation
// ================================================================
// 20.1
@(test) test_20_1 :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1½ hours", format_duration_iso(buf[:], &locale_en, .Normal, "2025-01-15T10:00", "2025-01-15T11:30:00")) }
// 20.2
@(test) test_20_2 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_duration_iso(buf[:], &locale_en, .Normal, "2025-01-15T10", "2025-01-15T11:30:00")) }
// 20.3
@(test) test_20_3 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_duration_iso(buf[:], &locale_en, .Normal, "2025-1-5T10:00:00", "2025-01-15T11:30:00")) }
// 20.4
@(test) test_20_4 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_duration_iso(buf[:], &locale_en, .Normal, "2025-02-30T10:00:00", "2025-03-15T11:30:00")) }
// 20.5
@(test) test_20_5 :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_since(buf[:], &locale_en, .Normal, "2025-01-15T10:00:00", "2025-01-15T25:00:00")) }
