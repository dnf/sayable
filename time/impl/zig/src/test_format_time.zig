const std = @import("std");
const st = @import("sayabletime");

fn fmt(buf: []u8, time: []const u8) ?[]const u8 {
    return st.formatTime(buf, &st.locales.en, .normal, time);
}

fn fmtWith(buf: []u8, locale: *const st.TimeLocale, compactness: st.Compactness, time: []const u8) ?[]const u8 {
    return st.formatTime(buf, locale, compactness, time);
}

fn expectStr(expected: []const u8, actual: ?[]const u8) !void {
    try std.testing.expect(actual != null);
    try std.testing.expectEqualStrings(expected, actual.?);
}

fn expectNull(actual: ?[]const u8) !void {
    try std.testing.expect(actual == null);
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================

// 1.1
test "null input" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, ""));
}

// 1.2
test "invalid input" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "invalid"));
}

// 1.3
test "invalid hour" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "25:00"));
}

// 1.4
test "invalid minute" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "10:60"));
}

// ================================================================
// Section 2: Normal compactness — clock time
// ================================================================

// 2.1
test "midnight" {
    var buf: [256]u8 = undefined;
    try expectStr("midnight", fmt(&buf, "00:00"));
}

// 2.2
test "noon" {
    var buf: [256]u8 = undefined;
    try expectStr("noon", fmt(&buf, "12:00"));
}

// 2.3
test "o'clock" {
    var buf: [256]u8 = undefined;
    try expectStr("three o'clock", fmt(&buf, "15:00"));
}

// 2.4
test "quarter past" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", fmt(&buf, "14:15"));
}

// 2.5
test "half past" {
    var buf: [256]u8 = undefined;
    try expectStr("half past seven", fmt(&buf, "07:30"));
}

// 2.6
test "quarter to" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter to eleven", fmt(&buf, "10:45"));
}

// 2.7
test "five past" {
    var buf: [256]u8 = undefined;
    try expectStr("five past nine", fmt(&buf, "09:05"));
}

// 2.8
test "ten to" {
    var buf: [256]u8 = undefined;
    try expectStr("ten to six", fmt(&buf, "05:50"));
}

// 2.9
test "rounds to twenty" {
    var buf: [256]u8 = undefined;
    try expectStr("twenty past seven", fmt(&buf, "07:22"));
}

// 2.10
test "ISO datetime input" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", fmt(&buf, "2025-01-15T14:15:00"));
}

// ================================================================
// Section 3: Short compactness — digital clock
// ================================================================

// 3.1
test "short 2:15 PM" {
    var buf: [256]u8 = undefined;
    try expectStr("2:15 PM", fmtWith(&buf, &st.locales.en, .short_mode, "14:15"));
}

// 3.2
test "short 12:00 AM" {
    var buf: [256]u8 = undefined;
    try expectStr("12:00 AM", fmtWith(&buf, &st.locales.en, .short_mode, "00:00"));
}

// 3.3
test "short 9:05 AM" {
    var buf: [256]u8 = undefined;
    try expectStr("9:05 AM", fmtWith(&buf, &st.locales.en, .short_mode, "09:05"));
}

// ================================================================
// Section 4: Compact compactness
// ================================================================

// 4.1
test "compact 2:15p" {
    var buf: [256]u8 = undefined;
    try expectStr("2:15p", fmtWith(&buf, &st.locales.en, .compact, "14:15"));
}

// 4.2
test "compact 12:00a" {
    var buf: [256]u8 = undefined;
    try expectStr("12:00a", fmtWith(&buf, &st.locales.en, .compact, "00:00"));
}

// ================================================================
// Section 5: Locale — German
// ================================================================

// 5.1
test "German quarter past" {
    var buf: [256]u8 = undefined;
    try expectStr("Viertel nach drei", fmtWith(&buf, &st.locales.de, .normal, "15:15"));
}

// 5.2
test "German half past" {
    var buf: [256]u8 = undefined;
    try expectStr("halb acht", fmtWith(&buf, &st.locales.de, .normal, "07:30"));
}

// ================================================================
// Section 6: Locale — French
// ================================================================

// 6.1
test "French quarter past" {
    var buf: [256]u8 = undefined;
    try expectStr("trois heures et quart", fmtWith(&buf, &st.locales.fr, .normal, "15:15"));
}

// 6.2
test "French noon" {
    var buf: [256]u8 = undefined;
    try expectStr("midi", fmtWith(&buf, &st.locales.fr, .normal, "12:00"));
}

// ================================================================
// Section 7: Locale — Japanese
// ================================================================

// 7.1
test "Japanese half past" {
    var buf: [256]u8 = undefined;
    try expectStr("\xe4\xb8\x89\xe6\x99\x82\xe5\x8d\x8a", fmtWith(&buf, &st.locales.ja, .normal, "15:30"));
}

// ================================================================
// Section 8: Locale — Finnish (dot separator, short)
// ================================================================

// 8.1
test "Finnish dot separator" {
    var buf: [256]u8 = undefined;
    try expectStr("14.15", fmtWith(&buf, &st.locales.fi, .short_mode, "14:15"));
}

// 8.2
test "Finnish midnight dot" {
    var buf: [256]u8 = undefined;
    try expectStr("0.00", fmtWith(&buf, &st.locales.fi, .short_mode, "00:00"));
}

// ================================================================
// Section 9: Minutes in short and compact modes
// ================================================================
// 9.1
test "9.1 digital modes keep the exact minute" {
    var buf: [256]u8 = undefined;
    try expectStr("6:01 PM", st.formatTime(&buf, &st.locales.en, .short_mode, "18:01"));
}

// 9.2
test "9.2 digital modes keep the exact minute" {
    var buf: [256]u8 = undefined;
    try expectStr("7:05p", st.formatTime(&buf, &st.locales.en, .compact, "19:05"));
}

// ================================================================
// Section 10: Input validation
// ================================================================
// 10.1
test "10.1 one-digit hour" {
    var buf: [256]u8 = undefined;
    try expectStr("half past nine", st.formatTime(&buf, &st.locales.en, .normal, "9:30"));
}

// 10.2
test "10.2 two-digit hour" {
    var buf: [256]u8 = undefined;
    try expectStr("half past nine", st.formatTime(&buf, &st.locales.en, .normal, "09:30"));
}

// 10.3
test "10.3 leading whitespace" {
    var buf: [256]u8 = undefined;
    try expectNull(st.formatTime(&buf, &st.locales.en, .normal, " 9:30"));
}

// 10.4
test "10.4 trailing whitespace" {
    var buf: [256]u8 = undefined;
    try expectNull(st.formatTime(&buf, &st.locales.en, .normal, "9:30 "));
}

// 10.5
test "10.5 minutes need two digits" {
    var buf: [256]u8 = undefined;
    try expectNull(st.formatTime(&buf, &st.locales.en, .normal, "9:5"));
}

// 10.6
test "10.6 hour out of range" {
    var buf: [256]u8 = undefined;
    try expectNull(st.formatTime(&buf, &st.locales.en, .normal, "24:00"));
}

// 10.7
test "10.7 seconds are allowed and ignored" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", st.formatTime(&buf, &st.locales.en, .normal, "14:15:30"));
}

// 10.8
test "10.8 ISO datetime with zone suffix (ignored)" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", st.formatTime(&buf, &st.locales.en, .normal, "2025-01-15T14:15:00Z"));
}

// 10.9
test "10.9 ISO datetime with an impossible date" {
    var buf: [256]u8 = undefined;
    try expectNull(st.formatTime(&buf, &st.locales.en, .normal, "2025-02-30T14:15:00"));
}
