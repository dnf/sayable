const std = @import("std");
const sd = @import("sayabledate");

fn fmtDate(buf: []u8, date: []const u8) ?[]const u8 {
    return sd.formatDate(buf, &sd.locales.en, .normal, date);
}

fn fmtDateWith(buf: []u8, locale: *const sd.DateLocale, compactness: sd.Compactness, date: []const u8) ?[]const u8 {
    return sd.formatDate(buf, locale, compactness, date);
}

fn fmtRel(buf: []u8, date: []const u8, as_of: []const u8) ?[]const u8 {
    return sd.formatRelative(buf, &sd.locales.en, .normal, date, as_of);
}

fn fmtRelWith(buf: []u8, locale: *const sd.DateLocale, compactness: sd.Compactness, date: []const u8, as_of: []const u8) ?[]const u8 {
    return sd.formatRelative(buf, locale, compactness, date, as_of);
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
test "format_date null" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtDate(&buf, ""));
}

// 1.2
test "format_date empty" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtDate(&buf, ""));
}

// 1.3
test "format_date invalid" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtDate(&buf, "invalid"));
}

// 1.4
test "format_relative null asOf" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtRel(&buf, "2025-03-15", ""));
}

// 1.5
test "format_relative null date" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtRel(&buf, "", "2025-03-15"));
}

// ================================================================
// Section 2: format_date — normal compactness (English)
// ================================================================

// 2.1
test "March 15th" {
    var buf: [256]u8 = undefined;
    try expectStr("March 15th", fmtDate(&buf, "2025-03-15"));
}

// 2.2
test "January 1st" {
    var buf: [256]u8 = undefined;
    try expectStr("January 1st", fmtDate(&buf, "2025-01-01"));
}

// 2.3
test "May 22nd" {
    var buf: [256]u8 = undefined;
    try expectStr("May 22nd", fmtDate(&buf, "2025-05-22"));
}

// 2.4
test "July 3rd" {
    var buf: [256]u8 = undefined;
    try expectStr("July 3rd", fmtDate(&buf, "2025-07-03"));
}

// 2.5
test "December 31st" {
    var buf: [256]u8 = undefined;
    try expectStr("December 31st", fmtDate(&buf, "2025-12-31"));
}

// 2.6
test "June 11th" {
    var buf: [256]u8 = undefined;
    try expectStr("June 11th", fmtDate(&buf, "2025-06-11"));
}

// 2.7
test "ISO datetime input" {
    var buf: [256]u8 = undefined;
    try expectStr("March 15th", fmtDate(&buf, "2025-03-15T14:30:00"));
}

// ================================================================
// Section 3: format_date — short compactness (English)
// ================================================================

// 3.1
test "short Mar 15" {
    var buf: [256]u8 = undefined;
    try expectStr("Mar 15", fmtDateWith(&buf, &sd.locales.en, .short_mode, "2025-03-15"));
}

// 3.2
test "short Jan 1" {
    var buf: [256]u8 = undefined;
    try expectStr("Jan 1", fmtDateWith(&buf, &sd.locales.en, .short_mode, "2025-01-01"));
}

// 3.3
test "short Dec 25" {
    var buf: [256]u8 = undefined;
    try expectStr("Dec 25", fmtDateWith(&buf, &sd.locales.en, .short_mode, "2025-12-25"));
}

// ================================================================
// Section 4: format_date — compact (English)
// ================================================================

// 4.1
test "compact 3/15" {
    var buf: [256]u8 = undefined;
    try expectStr("3/15", fmtDateWith(&buf, &sd.locales.en, .compact, "2025-03-15"));
}

// 4.2
test "compact 1/1" {
    var buf: [256]u8 = undefined;
    try expectStr("1/1", fmtDateWith(&buf, &sd.locales.en, .compact, "2025-01-01"));
}

// ================================================================
// Section 5: format_relative — proximity tiers (English)
// ================================================================

// 5.1
test "today" {
    var buf: [256]u8 = undefined;
    try expectStr("today", fmtRel(&buf, "2025-03-15", "2025-03-15"));
}

// 5.2
test "tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("tomorrow", fmtRel(&buf, "2025-03-16", "2025-03-15"));
}

// 5.3
test "yesterday" {
    var buf: [256]u8 = undefined;
    try expectStr("yesterday", fmtRel(&buf, "2025-03-14", "2025-03-15"));
}

// 5.4
test "day after tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("the day after tomorrow", fmtRel(&buf, "2025-03-17", "2025-03-15"));
}

// 5.5
test "day before yesterday" {
    var buf: [256]u8 = undefined;
    try expectStr("the day before yesterday", fmtRel(&buf, "2025-03-13", "2025-03-15"));
}

// 5.6
test "this Wednesday" {
    var buf: [256]u8 = undefined;
    try expectStr("this Wednesday", fmtRel(&buf, "2025-03-19", "2025-03-15"));
}

// 5.7
test "this Thursday" {
    var buf: [256]u8 = undefined;
    try expectStr("this Thursday", fmtRel(&buf, "2025-03-20", "2025-03-15"));
}

// 5.8
test "last Tuesday" {
    var buf: [256]u8 = undefined;
    try expectStr("last Tuesday", fmtRel(&buf, "2025-03-11", "2025-03-15"));
}

// 5.9
test "next Saturday" {
    var buf: [256]u8 = undefined;
    try expectStr("next Saturday", fmtRel(&buf, "2025-03-22", "2025-03-15"));
}

// 5.10
test "next Thursday" {
    var buf: [256]u8 = undefined;
    try expectStr("next Thursday", fmtRel(&buf, "2025-03-27", "2025-03-15"));
}

// 5.11
test "calendar same year past" {
    var buf: [256]u8 = undefined;
    try expectStr("March 1st", fmtRel(&buf, "2025-03-01", "2025-03-15"));
}

// 5.12
test "calendar same year future" {
    var buf: [256]u8 = undefined;
    try expectStr("April 10th", fmtRel(&buf, "2025-04-10", "2025-03-15"));
}

// 5.13
test "different year future" {
    var buf: [256]u8 = undefined;
    try expectStr("January 5th, 2026", fmtRel(&buf, "2026-01-05", "2025-03-15"));
}

// 5.14
test "different year past" {
    var buf: [256]u8 = undefined;
    try expectStr("December 25th, 2024", fmtRel(&buf, "2024-12-25", "2025-03-15"));
}

// ================================================================
// Section 6: format_relative — compact skips weekday tiers
// ================================================================

// 6.1
test "compact today" {
    var buf: [256]u8 = undefined;
    try expectStr("today", fmtRelWith(&buf, &sd.locales.en, .compact, "2025-03-15", "2025-03-15"));
}

// 6.2
test "compact tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("tomorrow", fmtRelWith(&buf, &sd.locales.en, .compact, "2025-03-16", "2025-03-15"));
}

// 6.3
test "compact numeric" {
    var buf: [256]u8 = undefined;
    try expectStr("3/19", fmtRelWith(&buf, &sd.locales.en, .compact, "2025-03-19", "2025-03-15"));
}

// 6.4
test "compact different year" {
    var buf: [256]u8 = undefined;
    try expectStr("1/5/26", fmtRelWith(&buf, &sd.locales.en, .compact, "2026-01-05", "2025-03-15"));
}

// ================================================================
// Section 7: Locale — German
// ================================================================

// 7.1
test "German format_date" {
    var buf: [256]u8 = undefined;
    try expectStr("15. M\xc3\xa4rz", fmtDateWith(&buf, &sd.locales.de, .normal, "2025-03-15"));
}

// 7.2
test "German tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("morgen", fmtRelWith(&buf, &sd.locales.de, .normal, "2025-03-16", "2025-03-15"));
}

// 7.3
test "German day after tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("\xc3\xbcbermorgen", fmtRelWith(&buf, &sd.locales.de, .normal, "2025-03-17", "2025-03-15"));
}

// 7.4
test "German this Wednesday" {
    var buf: [256]u8 = undefined;
    try expectStr("diesen Mittwoch", fmtRelWith(&buf, &sd.locales.de, .normal, "2025-03-19", "2025-03-15"));
}

// ================================================================
// Section 8: Locale — French
// ================================================================

// 8.1
test "French 1er mars" {
    var buf: [256]u8 = undefined;
    try expectStr("1er mars", fmtDateWith(&buf, &sd.locales.fr, .normal, "2025-03-01"));
}

// 8.2
test "French 15 mars" {
    var buf: [256]u8 = undefined;
    try expectStr("15 mars", fmtDateWith(&buf, &sd.locales.fr, .normal, "2025-03-15"));
}

// 8.3
test "French tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("demain", fmtRelWith(&buf, &sd.locales.fr, .normal, "2025-03-16", "2025-03-15"));
}

// ================================================================
// Section 9: Locale — Japanese
// ================================================================

// 9.1
test "Japanese format_date" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xe6\x9c\x8815\xe6\x97\xa5", fmtDateWith(&buf, &sd.locales.ja, .normal, "2025-03-15"));
}

// 9.2
test "Japanese tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("\xe6\x98\x8e\xe6\x97\xa5", fmtRelWith(&buf, &sd.locales.ja, .normal, "2025-03-16", "2025-03-15"));
}

// 9.3
test "Japanese this Wednesday" {
    var buf: [256]u8 = undefined;
    try expectStr("\xe4\xbb\x8a\xe5\xba\xa6\xe3\x81\xae\xe6\xb0\xb4\xe6\x9b\x9c\xe6\x97\xa5", fmtRelWith(&buf, &sd.locales.ja, .normal, "2025-03-19", "2025-03-15"));
}

// ================================================================
// Section 10: Locale — Russian (genitive months)
// ================================================================

// 10.1
test "Russian genitive month" {
    var buf: [256]u8 = undefined;
    try expectStr("15 \xd0\xbc\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0", fmtDateWith(&buf, &sd.locales.ru, .normal, "2025-03-15"));
}

// 10.2
test "Russian tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd0\xb7\xd0\xb0\xd0\xb2\xd1\x82\xd1\x80\xd0\xb0", fmtRelWith(&buf, &sd.locales.ru, .normal, "2025-03-16", "2025-03-15"));
}

// ================================================================
// Section 11: Locale — Arabic
// ================================================================

// 11.1
test "Arabic format_date" {
    var buf: [256]u8 = undefined;
    try expectStr("15 \xd9\x85\xd8\xa7\xd8\xb1\xd8\xb3", fmtDateWith(&buf, &sd.locales.ar, .normal, "2025-03-15"));
}

// 11.2
test "Arabic tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd8\xba\xd8\xaf\xd8\xa7\xd9\x8b", fmtRelWith(&buf, &sd.locales.ar, .normal, "2025-03-16", "2025-03-15"));
}

// ================================================================
// Section 12: Locale — Spanish
// ================================================================

// 12.1
test "Spanish format_date" {
    var buf: [256]u8 = undefined;
    try expectStr("15 de marzo", fmtDateWith(&buf, &sd.locales.es, .normal, "2025-03-15"));
}

// 12.2
test "Spanish day after tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("pasado ma\xc3\xb1ana", fmtRelWith(&buf, &sd.locales.es, .normal, "2025-03-17", "2025-03-15"));
}

// ================================================================
// Section 13: format_date_with_year
// ================================================================
// 13.1
test "13.1" {
    var buf: [256]u8 = undefined;
    try expectStr("February 4th, 2018", sd.formatDateWithYear(&buf, &sd.locales.en, .normal, "2018-02-04"));
}

// 13.2
test "13.2" {
    var buf: [256]u8 = undefined;
    try expectStr("Mar 15, 2025", sd.formatDateWithYear(&buf, &sd.locales.en, .short_mode, "2025-03-15"));
}

// 13.3
test "13.3" {
    var buf: [256]u8 = undefined;
    try expectStr("1/21/97", sd.formatDateWithYear(&buf, &sd.locales.en, .compact, "1997-01-21"));
}

// 13.4
test "13.4 two-digit year keeps its leading zero" {
    var buf: [256]u8 = undefined;
    try expectStr("20/5/07", sd.formatDateWithYear(&buf, &sd.locales.tg, .compact, "2007-05-20"));
}

// 13.5
test "13.5" {
    var buf: [256]u8 = undefined;
    try expectStr("21. kesäkuuta 1996", sd.formatDateWithYear(&buf, &sd.locales.fi, .short_mode, "1996-06-21"));
}

// ================================================================
// Section 14: Short month names
// ================================================================
// 14.1
test "14.1" {
    var buf: [256]u8 = undefined;
    try expectStr("15. februára", sd.formatDate(&buf, &sd.locales.sk, .short_mode, "2031-02-15"));
}

// 14.2
test "14.2" {
    var buf: [256]u8 = undefined;
    try expectStr("10. prosince", sd.formatDate(&buf, &sd.locales.cs, .short_mode, "2025-12-10"));
}

// 14.3
test "14.3" {
    var buf: [256]u8 = undefined;
    try expectStr("5 листопада", sd.formatDate(&buf, &sd.locales.uk, .short_mode, "2025-11-05"));
}

// 14.4
test "14.4" {
    var buf: [256]u8 = undefined;
    try expectStr("8. elokuuta", sd.formatRelative(&buf, &sd.locales.fi, .short_mode, "1998-08-08", "1998-08-15"));
}

// ================================================================
// Section 15: format_relative — short phrases
// ================================================================
// 15.1
test "15.1 day after tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("an Mth ma", sd.formatRelative(&buf, &sd.locales.kw, .short_mode, "2035-12-04", "2035-12-02"));
}

// 15.2
test "15.2 day before yesterday" {
    var buf: [256]u8 = undefined;
    try expectStr("Dom nchi'j", sd.formatRelative(&buf, &sd.locales.mam, .short_mode, "2000-01-23", "2000-01-25"));
}

// 15.3
test "15.3 day after tomorrow" {
    var buf: [256]u8 = undefined;
    try expectStr("a'in Vie", sd.formatRelative(&buf, &sd.locales.kek, .short_mode, "2014-10-24", "2014-10-22"));
}

// ================================================================
// Section 16: Input validation
// ================================================================
// 16.1
test "16.1 February 30 doesn't exist" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatDate(&buf, &sd.locales.en, .normal, "2025-02-30"));
}

// 16.2
test "16.2 Month 13" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatDate(&buf, &sd.locales.en, .normal, "2025-13-01"));
}

// 16.3
test "16.3 Unpadded month and day" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatDate(&buf, &sd.locales.en, .normal, "2025-6-1"));
}

// 16.4
test "16.4 Surrounding whitespace" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatDate(&buf, &sd.locales.en, .normal, " 2025-06-01"));
}

// 16.5
test "16.5 An ISO datetime: only the date part is used" {
    var buf: [256]u8 = undefined;
    try expectStr("June 1st", sd.formatDate(&buf, &sd.locales.en, .normal, "2025-06-01T10:00:00"));
}

// 16.6
test "16.6 February 29 in a non-leap year" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatDateWithYear(&buf, &sd.locales.en, .normal, "2023-02-29"));
}

// 16.7
test "16.7 Invalid asOf" {
    var buf: [256]u8 = undefined;
    try expectNull(sd.formatRelative(&buf, &sd.locales.en, .normal, "2025-03-16", "2025-04-31"));
}
