const std = @import("std");
const sd = @import("sayableduration");

fn fmtSecs(buf: []u8, seconds: i32) ?[]const u8 {
    return sd.formatDurationSecs(buf, &sd.locales.en, .normal, seconds);
}

fn fmtSecsWith(buf: []u8, locale: *const sd.DurationLocale, compactness: sd.Compactness, seconds: i32) ?[]const u8 {
    return sd.formatDurationSecs(buf, locale, compactness, seconds);
}

fn fmtISO(buf: []u8, start: []const u8, end: []const u8) ?[]const u8 {
    return sd.formatDurationISO(buf, &sd.locales.en, .normal, start, end);
}

fn fmtSince(buf: []u8, start: []const u8, as_of: []const u8) ?[]const u8 {
    return sd.formatSince(buf, &sd.locales.en, .normal, start, as_of);
}

fn fmtSinceWith(buf: []u8, locale: *const sd.DurationLocale, start: []const u8, as_of: []const u8) ?[]const u8 {
    return sd.formatSince(buf, locale, .normal, start, as_of);
}

fn fmtUntil(buf: []u8, target: []const u8, as_of: []const u8) ?[]const u8 {
    return sd.formatUntil(buf, &sd.locales.en, .normal, target, as_of);
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
test "format_duration null" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtSecs(&buf, -999));
}

// 1.2
test "format_duration negative" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtSecs(&buf, -1));
}

// 1.3
test "format_since null start" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtSince(&buf, "", "2025-01-15T10:00:00"));
}

// 1.4
test "format_until null target" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtUntil(&buf, "", "2025-01-15T10:00:00"));
}

// 1.5
test "format_since future start" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtSince(&buf, "2025-01-15T10:00:00", "2025-01-15T09:00:00"));
}

// 1.6
test "format_until past target" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtUntil(&buf, "2025-01-15T09:00:00", "2025-01-15T10:00:00"));
}

// ================================================================
// Section 2: Duration — seconds tier (0-59s)
// ================================================================

// 2.1
test "zero seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("just now", fmtSecs(&buf, 0));
}

// 2.2
test "one second" {
    var buf: [256]u8 = undefined;
    try expectStr("1 second", fmtSecs(&buf, 1));
}

// 2.3
test "45 seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("45 seconds", fmtSecs(&buf, 45));
}

// 2.4
test "59 seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("59 seconds", fmtSecs(&buf, 59));
}

// ================================================================
// Section 3: Duration — minutes + seconds tier (1-4 min)
// ================================================================

// 3.1
test "one minute" {
    var buf: [256]u8 = undefined;
    try expectStr("1 minute", fmtSecs(&buf, 60));
}

// 3.2
test "one minute thirty seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("1 minute, 30 seconds", fmtSecs(&buf, 90));
}

// 3.3
test "four minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("4 minutes", fmtSecs(&buf, 240));
}

// 3.4
test "four minutes thirty seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("4 minutes, 30 seconds", fmtSecs(&buf, 270));
}

// ================================================================
// Section 4: Duration — minutes tier (5-59 min)
// ================================================================

// 4.1
test "five minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("5 minutes", fmtSecs(&buf, 300));
}

// 4.2
test "25 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("25 minutes", fmtSecs(&buf, 1500));
}

// 4.3
test "59 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("59 minutes", fmtSecs(&buf, 3540));
}

// ================================================================
// Section 5: Duration — hours + minutes tier (1-5 hr)
// ================================================================

// 5.1
test "one hour" {
    var buf: [256]u8 = undefined;
    try expectStr("1 hour", fmtSecs(&buf, 3600));
}

// 5.2
test "one and half hours" {
    var buf: [256]u8 = undefined;
    try expectStr("1\xc2\xbd hours", fmtSecs(&buf, 5400));
}

// 5.3
test "two hours 15 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("2 hours, 15 minutes", fmtSecs(&buf, 8100));
}

// 5.4
test "five hours" {
    var buf: [256]u8 = undefined;
    try expectStr("5 hours", fmtSecs(&buf, 18000));
}

// ================================================================
// Section 6: Duration — hours tier (6-23 hr)
// ================================================================

// 6.1
test "eight hours" {
    var buf: [256]u8 = undefined;
    try expectStr("8 hours", fmtSecs(&buf, 28800));
}

// 6.2
test "23 hours" {
    var buf: [256]u8 = undefined;
    try expectStr("23 hours", fmtSecs(&buf, 82800));
}

// ================================================================
// Section 7: Duration — days tier
// ================================================================

// 7.1
test "one day" {
    var buf: [256]u8 = undefined;
    try expectStr("1 day", fmtSecs(&buf, 86400));
}

// 7.2
test "one day three hours" {
    var buf: [256]u8 = undefined;
    try expectStr("1 day, 3 hours", fmtSecs(&buf, 97200));
}

// 7.3
test "one and half days" {
    var buf: [256]u8 = undefined;
    try expectStr("1\xc2\xbd days", fmtSecs(&buf, 129600));
}

// 7.4
test "five days" {
    var buf: [256]u8 = undefined;
    try expectStr("5 days", fmtSecs(&buf, 432000));
}

// 7.5
test "two days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 days", fmtSecs(&buf, 172800));
}

// ================================================================
// Section 8: Duration — weeks tier
// ================================================================

// 8.1
test "one week" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week", fmtSecs(&buf, 604800));
}

// 8.2
test "two weeks one day" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks, 1 day", fmtSecs(&buf, 1296000));
}

// 8.3
test "four weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks", fmtSecs(&buf, 2419200));
}

// ================================================================
// Section 9: Duration — months and years tier
// ================================================================

// 9.1
test "one month" {
    var buf: [256]u8 = undefined;
    try expectStr("1 month", fmtSecs(&buf, 2678400));
}

// 9.2
test "three months" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmtSecs(&buf, 7884000));
}

// 9.3
test "one year" {
    var buf: [256]u8 = undefined;
    try expectStr("1 year", fmtSecs(&buf, 31536000));
}

// 9.4
test "one year three months" {
    var buf: [256]u8 = undefined;
    try expectStr("1 year, 3 months", fmtSecs(&buf, 39420000));
}

// ================================================================
// Section 10: Duration from ISO timestamps
// ================================================================

// 10.1
test "ISO one and half hours" {
    var buf: [256]u8 = undefined;
    try expectStr("1\xc2\xbd hours", fmtISO(&buf, "2025-01-15T10:00:00", "2025-01-15T11:30:00"));
}

// 10.2
test "ISO 45 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("45 minutes", fmtISO(&buf, "2025-01-15T10:00:00", "2025-01-15T10:45:00"));
}

// ================================================================
// Section 11: Relative time — since
// ================================================================

// 11.1
test "since just now" {
    var buf: [256]u8 = undefined;
    try expectStr("just now", fmtSince(&buf, "2025-01-15T10:00:00", "2025-01-15T10:00:00"));
}

// 11.2
test "30 seconds ago" {
    var buf: [256]u8 = undefined;
    try expectStr("30 seconds ago", fmtSince(&buf, "2025-01-15T10:00:00", "2025-01-15T10:00:30"));
}

// 11.3
test "45 minutes ago" {
    var buf: [256]u8 = undefined;
    try expectStr("45 minutes ago", fmtSince(&buf, "2025-01-15T10:00:00", "2025-01-15T10:45:00"));
}

// 11.4
test "3 hours ago" {
    var buf: [256]u8 = undefined;
    try expectStr("3 hours ago", fmtSince(&buf, "2025-01-15T10:00:00", "2025-01-15T13:00:00"));
}

// ================================================================
// Section 12: Relative time — until
// ================================================================

// 12.1
test "until just now" {
    var buf: [256]u8 = undefined;
    try expectStr("just now", fmtUntil(&buf, "2025-01-15T10:00:00", "2025-01-15T10:00:00"));
}

// 12.2
test "in 20 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("in 20 minutes", fmtUntil(&buf, "2025-01-15T10:20:00", "2025-01-15T10:00:00"));
}

// 12.3
test "in 3 hours" {
    var buf: [256]u8 = undefined;
    try expectStr("in 3 hours", fmtUntil(&buf, "2025-01-15T13:00:00", "2025-01-15T10:00:00"));
}

// ================================================================
// Section 13: Locale — German
// ================================================================

// 13.1
test "German one hour" {
    var buf: [256]u8 = undefined;
    try expectStr("1 Stunde", fmtSecsWith(&buf, &sd.locales.de, .normal, 3600));
}

// 13.2
test "German since 5 minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("vor 5 Minuten", fmtSinceWith(&buf, &sd.locales.de, "2025-01-15T10:00:00", "2025-01-15T10:05:00"));
}

// ================================================================
// Section 14: Locale — French
// ================================================================

// 14.1
test "French two hours" {
    var buf: [256]u8 = undefined;
    try expectStr("2 heures", fmtSecsWith(&buf, &sd.locales.fr, .normal, 7200));
}

// ================================================================
// Section 15: Locale — Japanese
// ================================================================

// 15.1
test "Japanese two minutes" {
    var buf: [256]u8 = undefined;
    try expectStr("2\xe5\x88\x86", fmtSecsWith(&buf, &sd.locales.ja, .normal, 120));
}

// 15.2
test "Japanese since one hour" {
    var buf: [256]u8 = undefined;
    try expectStr("1\xe6\x99\x82\xe9\x96\x93\xe5\x89\x8d", fmtSinceWith(&buf, &sd.locales.ja, "2025-01-15T10:00:00", "2025-01-15T11:00:00"));
}

// ================================================================
// Section 16: Short compactness — duration
// ================================================================

// 16.1
test "short one hour" {
    var buf: [256]u8 = undefined;
    try expectStr("1h", fmtSecsWith(&buf, &sd.locales.en, .short_mode, 3600));
}

// 16.2
test "short one minute thirty seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("1m, 30s", fmtSecsWith(&buf, &sd.locales.en, .short_mode, 90));
}

// ================================================================
// Section 17: Compact compactness — duration
// ================================================================

// 17.1
test "compact one hour" {
    var buf: [256]u8 = undefined;
    try expectStr("1h", fmtSecsWith(&buf, &sd.locales.en, .compact, 3600));
}

// 17.2
test "compact one minute thirty seconds" {
    var buf: [256]u8 = undefined;
    try expectStr("1m30s", fmtSecsWith(&buf, &sd.locales.en, .compact, 90));
}
