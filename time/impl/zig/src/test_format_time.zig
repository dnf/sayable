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
test "1.1 input null" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &st.locales.en, .normal, ""));
}

// 1.2
test "1.2 input ''" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &st.locales.en, .normal, ""));
}

// 1.3
test "1.3 input 'invalid'" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &st.locales.en, .normal, "invalid"));
}

// 1.4
test "1.4 input '25:00'" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &st.locales.en, .normal, "25:00"));
}

// ================================================================
// Section 2: Normal compactness — clock time
// ================================================================

// 2.1
test "2.1 input '00:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("midnight", fmtWith(&buf, &st.locales.en, .normal, "00:00"));
}

// 2.2
test "2.2 input '12:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("noon", fmtWith(&buf, &st.locales.en, .normal, "12:00"));
}

// 2.3
test "2.3 input '15:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("three o'clock", fmtWith(&buf, &st.locales.en, .normal, "15:00"));
}

// 2.4
test "2.4 input '14:15'" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", fmtWith(&buf, &st.locales.en, .normal, "14:15"));
}

// 2.5
test "2.5 input '09:30'" {
    var buf: [256]u8 = undefined;
    try expectStr("half past nine", fmtWith(&buf, &st.locales.en, .normal, "09:30"));
}

// 2.6
test "2.6 input '10:45'" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter to eleven", fmtWith(&buf, &st.locales.en, .normal, "10:45"));
}

// 2.7
test "2.7 input '08:05'" {
    var buf: [256]u8 = undefined;
    try expectStr("five past eight", fmtWith(&buf, &st.locales.en, .normal, "08:05"));
}

// 2.8
test "2.8 input '16:55'" {
    var buf: [256]u8 = undefined;
    try expectStr("five to five", fmtWith(&buf, &st.locales.en, .normal, "16:55"));
}

// 2.9
test "2.9 input '23:58'" {
    var buf: [256]u8 = undefined;
    try expectStr("midnight", fmtWith(&buf, &st.locales.en, .normal, "23:58"));
}

// 2.10
test "2.10 input '07:22'" {
    var buf: [256]u8 = undefined;
    try expectStr("twenty past seven", fmtWith(&buf, &st.locales.en, .normal, "07:22"));
}

// 2.11
test "2.11 input '2025-01-15T14:15:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("a quarter past two", fmtWith(&buf, &st.locales.en, .normal, "2025-01-15T14:15:00"));
}

// ================================================================
// Section 3: Short compactness — digital clock
// ================================================================

// 3.1
test "3.1 input '14:15'" {
    var buf: [256]u8 = undefined;
    try expectStr("2:15 PM", fmtWith(&buf, &st.locales.en, .short_mode, "14:15"));
}

// 3.2
test "3.2 input '09:30'" {
    var buf: [256]u8 = undefined;
    try expectStr("9:30 AM", fmtWith(&buf, &st.locales.en, .short_mode, "09:30"));
}

// 3.3
test "3.3 input '00:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("12:00 AM", fmtWith(&buf, &st.locales.en, .short_mode, "00:00"));
}

// 3.4
test "3.4 input '12:00'" {
    var buf: [256]u8 = undefined;
    try expectStr("12:00 PM", fmtWith(&buf, &st.locales.en, .short_mode, "12:00"));
}

// ================================================================
// Section 4: Compact compactness
// ================================================================

// 4.1
test "4.1 input '14:15'" {
    var buf: [256]u8 = undefined;
    try expectStr("2:15p", fmtWith(&buf, &st.locales.en, .compact, "14:15"));
}

// 4.2
test "4.2 input '09:30'" {
    var buf: [256]u8 = undefined;
    try expectStr("9:30a", fmtWith(&buf, &st.locales.en, .compact, "09:30"));
}

// ================================================================
// Section 5: Locale — German
// ================================================================

// 5.1
test "5.1 input '15:30'" {
    var buf: [256]u8 = undefined;
    try expectStr("halb vier", fmtWith(&buf, &st.locales.de, .normal, "15:30"));
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
test "French singular hour" {
    var buf: [256]u8 = undefined;
    try expectStr("une heure", fmtWith(&buf, &st.locales.fr, .normal, "13:00"));
}

// 6.3
test "French half past singular hour" {
    var buf: [256]u8 = undefined;
    try expectStr("une heure et demie", fmtWith(&buf, &st.locales.fr, .normal, "13:30"));
}

// 6.4
test "French quarter to" {
    var buf: [256]u8 = undefined;
    try expectStr("trois heures moins le quart", fmtWith(&buf, &st.locales.fr, .normal, "14:45"));
}

// 6.5
test "French ten to" {
    var buf: [256]u8 = undefined;
    try expectStr("trois heures moins dix", fmtWith(&buf, &st.locales.fr, .normal, "14:50"));
}

// (extra, not in tests.json)
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
