const std = @import("std");
const pt = @import("parenttime");

fn fmt(buf: []u8, dob: []const u8, as_of: []const u8) ?[]const u8 {
    return pt.formatAge(buf, &pt.locales.en, .normal, dob, as_of);
}

fn fmtWith(buf: []u8, locale: *const pt.Locale, compactness: pt.Compactness, dob: []const u8, as_of: []const u8) ?[]const u8 {
    return pt.formatAge(buf, locale, compactness, dob, as_of);
}

fn expectStr(expected: []const u8, actual: ?[]const u8) !void {
    try std.testing.expect(actual != null);
    try std.testing.expectEqualStrings(expected, actual.?);
}

fn expectNull(actual: ?[]const u8) !void {
    try std.testing.expect(actual == null);
}

fn expectContains(actual: ?[]const u8, substr: []const u8) !void {
    try std.testing.expect(actual != null);
    const s = actual.?;
    if (std.mem.indexOf(u8, s, substr) == null) {
        std.debug.print("Expected \"{s}\" to contain \"{s}\"\n", .{ s, substr });
        return error.TestExpectedEqual;
    }
}

// ================================================================
// formatAge -- null/edge cases
// ================================================================
test "empty string" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "", "2025-06-15"));
}

test "future dob" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "2025-07-01", "2025-06-15"));
}

test "exactly 500 years" {
    var buf: [256]u8 = undefined;
    try expectStr("500 years", fmt(&buf, "1525-06-15", "2025-06-15"));
}

test "501 years exceeds max" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "1524-06-15", "2025-06-15"));
}

test "1000 years exceeds max" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "1025-06-15", "2025-06-15"));
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
test "born today" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmt(&buf, "2025-06-15", "2025-06-15"));
}

test "1 day ago" {
    var buf: [256]u8 = undefined;
    try expectStr("1 day", fmt(&buf, "2025-06-14", "2025-06-15"));
}

test "3 days ago" {
    var buf: [256]u8 = undefined;
    try expectStr("3 days", fmt(&buf, "2025-06-12", "2025-06-15"));
}

test "6 days ago" {
    var buf: [256]u8 = undefined;
    try expectStr("6 days", fmt(&buf, "2025-06-09", "2025-06-15"));
}

test "7 days -> 1 week" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week", fmt(&buf, "2025-06-08", "2025-06-15"));
}

// ================================================================
// formatAge -- weeks+days tier
// ================================================================
test "7 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week", fmt(&buf, "2025-06-08", "2025-06-15"));
}

test "8 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 1 day", fmt(&buf, "2025-06-07", "2025-06-15"));
}

test "9 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 2 days", fmt(&buf, "2025-06-06", "2025-06-15"));
}

test "13 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 6 days", fmt(&buf, "2025-06-02", "2025-06-15"));
}

test "14 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks", fmt(&buf, "2025-06-01", "2025-06-15"));
}

test "15 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks, 1 day", fmt(&buf, "2025-05-31", "2025-06-15"));
}

test "20 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks, 6 days", fmt(&buf, "2025-05-26", "2025-06-15"));
}

test "21 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 weeks", fmt(&buf, "2025-05-25", "2025-06-15"));
}

test "at 1 cal month still weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks, 3 days", fmt(&buf, "2025-05-15", "2025-06-15"));
}

test "at 2 cal months still weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("8 weeks, 5 days", fmt(&buf, "2025-04-15", "2025-06-15"));
}

test "one day before 3mo still weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("13 weeks", fmt(&buf, "2025-03-15", "2025-06-14"));
}

test "on 3mo birthday switches" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-03-15", "2025-06-15"));
}

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================
test "Jan1->Apr1=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-01", "2025-04-01"));
}

test "Jan1->Mar31 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-01-01", "2025-03-31"), "weeks");
}

test "Jun15->Sep15=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-06-15", "2025-09-15"));
}

test "Jun15->Sep14 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-06-15", "2025-09-14"), "weeks");
}

test "Jun15->Dec15=6mo" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-06-15", "2025-12-15"));
}

// ================================================================
// formatAge -- month boundaries: February non-leap
// ================================================================
test "Jan31->Feb28 non-leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks", fmt(&buf, "2025-01-31", "2025-02-28"));
}

test "Jan31->Apr30=3mo(clamp)" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-31", "2025-04-30"));
}

test "Jan31->Apr29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-01-31", "2025-04-29"), "weeks");
}

test "Feb1->May1=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-02-01", "2025-05-01"));
}

test "Feb1->Apr30 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-02-01", "2025-04-30"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================
test "Jan31->Feb29 leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks, 1 day", fmt(&buf, "2024-01-31", "2024-02-29"));
}

test "Jan31->Feb28 leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks", fmt(&buf, "2024-01-31", "2024-02-28"));
}

test "Jan31->Apr30 leap=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-01-31", "2024-04-30"));
}

test "Jan30->Feb29 leap still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-01-30", "2024-02-29"), "weeks");
}

test "Jan30->Feb28 leap still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-01-30", "2024-02-28"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================
test "Mar31->Jun30=3mo(clamped)" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-03-31", "2025-06-30"));
}

test "Mar31->Jun29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-03-31", "2025-06-29"), "weeks");
}

test "Aug31->Nov30=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-08-31", "2025-11-30"));
}

test "Aug31->Nov29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-08-31", "2025-11-29"), "weeks");
}

// ================================================================
// formatAge -- leap year baby (born Feb 29)
// ================================================================
test "Feb29->May29=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-02-29", "2024-05-29"));
}

test "Feb29->May28 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-02-29", "2024-05-28"), "weeks");
}

test "Feb29 2024->Feb28 2025=12mo" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-02-29", "2025-02-28"));
}

test "Feb29 2024->Mar1 2025=12mo" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-02-29", "2025-03-01"));
}

// ================================================================
// formatAge -- months tier (3-23)
// ================================================================
test "3 months at transition" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-15", "2025-04-15"));
}

test "6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-01-15", "2025-07-15"));
}

test "12 months (not 1 year)" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-06-15", "2025-06-15"));
}

test "23 months at upper" {
    var buf: [256]u8 = undefined;
    try expectStr("23 months", fmt(&buf, "2024-01-15", "2025-12-15"));
}

test "one day before boundary" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-15", "2025-07-14"));
}

test "crossing year boundary" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2024-11-10", "2025-04-10"));
}

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================
test "2 years at 24mo" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years", fmt(&buf, "2023-06-15", "2025-06-15"));
}

test "2 years 1 month" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 1 month", fmt(&buf, "2023-06-15", "2025-07-15"));
}

test "2 years 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 6 months", fmt(&buf, "2023-06-15", "2025-12-15"));
}

test "2 years 11 months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 11 months", fmt(&buf, "2023-06-15", "2026-05-15"));
}

test "one day before 24mo" {
    var buf: [256]u8 = undefined;
    try expectStr("23 months", fmt(&buf, "2023-06-15", "2025-06-14"));
}

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================
test "3 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("3 years", fmt(&buf, "2022-06-15", "2025-06-15"));
}

test "3 years 5 months" {
    var buf: [256]u8 = undefined;
    try expectStr("3 years", fmt(&buf, "2022-06-15", "2025-11-15"));
}

test "3.5 years at 3y6m" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmt(&buf, "2022-06-15", "2025-12-15"));
}

test "3.5 years at 3y11m" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmt(&buf, "2022-06-15", "2026-05-15"));
}

test "4 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("4 years", fmt(&buf, "2021-06-15", "2025-06-15"));
}

test "4.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("4\xc2\xbd years", fmt(&buf, "2021-06-15", "2025-12-15"));
}

test "5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("5 years", fmt(&buf, "2020-06-15", "2025-06-15"));
}

test "5.5 years at 5y8m" {
    var buf: [256]u8 = undefined;
    try expectStr("5\xc2\xbd years", fmt(&buf, "2020-06-15", "2026-02-15"));
}

test "6 years" {
    var buf: [256]u8 = undefined;
    try expectStr("6 years", fmt(&buf, "2019-06-15", "2025-06-15"));
}

test "6.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("6\xc2\xbd years", fmt(&buf, "2019-06-15", "2025-12-15"));
}

test "6.5 years at 6y11m" {
    var buf: [256]u8 = undefined;
    try expectStr("6\xc2\xbd years", fmt(&buf, "2019-06-15", "2026-05-15"));
}

test "one day before 3rd bday" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 11 months", fmt(&buf, "2022-06-15", "2025-06-14"));
}

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================
test "7 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmt(&buf, "2018-06-15", "2025-06-15"));
}

test "7 years 6 months (no half)" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmt(&buf, "2018-03-20", "2025-06-15"));
}

test "45 years" {
    var buf: [256]u8 = undefined;
    try expectStr("45 years", fmt(&buf, "1980-01-01", "2025-06-15"));
}

// ================================================================
// formatAge -- cross-year with Feb
// ================================================================
test "Dec31->Mar31=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-12-31", "2025-03-31"));
}

test "Dec31->Mar30 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-12-31", "2025-03-30"), "weeks");
}

test "Nov30->Feb28=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-11-30", "2025-02-28"));
}

test "Nov30->Feb27 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-11-30", "2025-02-27"), "weeks");
}

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================
test "Jan31->Apr30=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-31", "2025-04-30"));
}

test "Jan31->May31=4mo" {
    var buf: [256]u8 = undefined;
    try expectStr("4 months", fmt(&buf, "2025-01-31", "2025-05-31"));
}

test "Jan31->Jun30=5mo(clamped)" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-31", "2025-06-30"));
}

test "Jan31->Jul1=5mo" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-31", "2025-07-01"));
}

test "Jan31->Jul31=6mo" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-01-31", "2025-07-31"));
}

// ================================================================
// formatStage -- null/edge cases
// ================================================================
test "stage empty" {
    try expectNull(pt.formatStage(&pt.locales.en, "", "2025-06-15", ""));
}

test "stage future" {
    try expectNull(pt.formatStage(&pt.locales.en, "2025-07-01", "2025-06-15", ""));
}

test "stage 500 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "1525-06-15", "2025-06-15", ""));
}

test "stage 501 years exceeds max" {
    try expectNull(pt.formatStage(&pt.locales.en, "1524-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- newborn
// ================================================================
test "stage born today" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-15", "2025-06-15", ""));
}

test "stage 1 day old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-14", "2025-06-15", ""));
}

test "stage 3 weeks old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-05-25", "2025-06-15", ""));
}

test "stage 1 month old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-05-15", "2025-06-15", ""));
}

test "stage 1 month 29 days" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-04-16", "2025-06-15", ""));
}

test "stage exactly 2 months -> Infant" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-04-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- infant
// ================================================================
test "stage 2 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-04-15", "2025-06-15", ""));
}

test "stage 6 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2024-12-15", "2025-06-15", ""));
}

test "stage 11 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2024-07-15", "2025-06-15", ""));
}

test "stage exactly 12mo -> Toddler" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- toddler
// ================================================================
test "stage 12 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

test "stage 18 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-01-15", "2025-07-15", ""));
}

test "stage 24 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2023-06-15", "2025-06-15", ""));
}

test "stage 35 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2023-06-15", "2026-05-15", ""));
}

test "stage exactly 36mo -> Child" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- child
// ================================================================
test "stage 3 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

test "stage 4 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2021-06-15", "2025-06-15", ""));
}

test "stage 6 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2019-06-15", "2025-06-15", ""));
}

test "stage 9 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2016-06-15", "2025-06-15", ""));
}

test "stage 12y11mo" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2013-06-15", "2026-05-15", ""));
}

test "stage exactly 13y -> Teenager" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- teenager
// ================================================================
test "stage 13 years" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

test "stage 15 years" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2010-06-15", "2025-06-15", ""));
}

test "stage 17y11mo" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2008-06-15", "2026-05-15", ""));
}

test "stage exactly 18y -> Adult" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- adult
// ================================================================
test "stage 18 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

test "stage 25 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2000-06-15", "2025-06-15", ""));
}

test "stage 45 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "1980-01-01", "2025-06-15", ""));
}

// ================================================================
// formatStage -- gender: Spanish
// ================================================================
test "ES stage newborn m" {
    try expectStr("Reci\xc3\xa9n nacido", pt.formatStage(&pt.locales.es, "2025-06-15", "2025-06-15", ""));
}

test "ES stage toddler m" {
    try expectStr("Ni\xc3\xb1o peque\xc3\xb1o", pt.formatStage(&pt.locales.es, "2024-06-15", "2025-06-15", ""));
}

test "ES stage child m" {
    try expectStr("Ni\xc3\xb1o", pt.formatStage(&pt.locales.es, "2022-06-15", "2025-06-15", ""));
}

test "ES stage adult m" {
    try expectStr("Adulto", pt.formatStage(&pt.locales.es, "2007-06-15", "2025-06-15", ""));
}

test "ES stage newborn f" {
    try expectStr("Reci\xc3\xa9n nacida", pt.formatStage(&pt.locales.es, "2025-06-15", "2025-06-15", "f"));
}

test "ES stage infant f" {
    try expectStr("Beb\xc3\xa9", pt.formatStage(&pt.locales.es, "2025-01-15", "2025-06-15", "f"));
}

test "ES stage toddler f" {
    try expectStr("Ni\xc3\xb1a peque\xc3\xb1a", pt.formatStage(&pt.locales.es, "2024-06-15", "2025-06-15", "f"));
}

test "ES stage child f" {
    try expectStr("Ni\xc3\xb1a", pt.formatStage(&pt.locales.es, "2022-06-15", "2025-06-15", "f"));
}

test "ES stage teenager f" {
    try expectStr("Adolescente", pt.formatStage(&pt.locales.es, "2012-06-15", "2025-06-15", "f"));
}

test "ES stage adult f" {
    try expectStr("Adulta", pt.formatStage(&pt.locales.es, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// formatStage -- gender: Italian
// ================================================================
test "IT stage newborn m" {
    try expectStr("Neonato", pt.formatStage(&pt.locales.it, "2025-06-15", "2025-06-15", ""));
}

test "IT stage toddler m" {
    try expectStr("Bimbo", pt.formatStage(&pt.locales.it, "2024-06-15", "2025-06-15", ""));
}

test "IT stage child m" {
    try expectStr("Bambino", pt.formatStage(&pt.locales.it, "2022-06-15", "2025-06-15", ""));
}

test "IT stage newborn f" {
    try expectStr("Neonata", pt.formatStage(&pt.locales.it, "2025-06-15", "2025-06-15", "f"));
}

test "IT stage infant f" {
    try expectStr("Lattante", pt.formatStage(&pt.locales.it, "2025-01-15", "2025-06-15", "f"));
}

test "IT stage toddler f" {
    try expectStr("Bimba", pt.formatStage(&pt.locales.it, "2024-06-15", "2025-06-15", "f"));
}

test "IT stage child f" {
    try expectStr("Bambina", pt.formatStage(&pt.locales.it, "2022-06-15", "2025-06-15", "f"));
}

test "IT stage adult f" {
    try expectStr("Adulta", pt.formatStage(&pt.locales.it, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// formatStage -- gender: Arabic
// ================================================================
test "AR stage newborn m" {
    try expectStr("\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9", pt.formatStage(&pt.locales.ar, "2025-06-15", "2025-06-15", ""));
}

test "AR stage infant m" {
    try expectStr("\xd8\xb1\xd8\xb6\xd9\x8a\xd8\xb9", pt.formatStage(&pt.locales.ar, "2025-01-15", "2025-06-15", ""));
}

test "AR stage teenager m" {
    try expectStr("\xd9\x85\xd8\xb1\xd8\xa7\xd9\x87\xd9\x82", pt.formatStage(&pt.locales.ar, "2012-06-15", "2025-06-15", ""));
}

test "AR stage newborn f" {
    try expectStr("\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab\xd8\xa9 \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9", pt.formatStage(&pt.locales.ar, "2025-06-15", "2025-06-15", "f"));
}

test "AR stage infant f" {
    try expectStr("\xd8\xb1\xd8\xb6\xd9\x8a\xd8\xb9\xd8\xa9", pt.formatStage(&pt.locales.ar, "2025-01-15", "2025-06-15", "f"));
}

test "AR stage toddler f" {
    try expectStr("\xd8\xb7\xd9\x81\xd9\x84\xd8\xa9 \xd8\xb5\xd8\xba\xd9\x8a\xd8\xb1\xd8\xa9", pt.formatStage(&pt.locales.ar, "2024-06-15", "2025-06-15", "f"));
}

test "AR stage child f" {
    try expectStr("\xd8\xb7\xd9\x81\xd9\x84\xd8\xa9", pt.formatStage(&pt.locales.ar, "2022-06-15", "2025-06-15", "f"));
}

test "AR stage teenager f" {
    try expectStr("\xd9\x85\xd8\xb1\xd8\xa7\xd9\x87\xd9\x82\xd8\xa9", pt.formatStage(&pt.locales.ar, "2012-06-15", "2025-06-15", "f"));
}

test "AR stage adult f" {
    try expectStr("\xd8\xa8\xd8\xa7\xd9\x84\xd8\xba\xd8\xa9", pt.formatStage(&pt.locales.ar, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// formatStage -- gender-neutral locale
// ================================================================
test "EN stage newborn f" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-15", "2025-06-15", "f"));
}

test "EN stage adult f" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// formatStage -- gender: Slovenian
// ================================================================
test "SL stage newborn m" {
    try expectStr("Novorojen\xc4\x8dek", pt.formatStage(&pt.locales.sl, "2025-06-15", "2025-06-15", ""));
}

test "SL stage newborn f" {
    try expectStr("Novorojen\xc4\x8dica", pt.formatStage(&pt.locales.sl, "2025-06-15", "2025-06-15", "f"));
}

test "SL stage child m" {
    try expectStr("Otrok", pt.formatStage(&pt.locales.sl, "2022-06-15", "2025-06-15", ""));
}

test "SL stage child f" {
    try expectStr("Otrok", pt.formatStage(&pt.locales.sl, "2022-06-15", "2025-06-15", "f"));
}

test "SL stage adult m" {
    try expectStr("Odrasel", pt.formatStage(&pt.locales.sl, "2007-06-15", "2025-06-15", ""));
}

test "SL stage adult f" {
    try expectStr("Odrasla", pt.formatStage(&pt.locales.sl, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// ParentTime with English locale
// ================================================================
test "PT Newborn" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-15", "2025-06-15"));
}

test "PT 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 days", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-12", "2025-06-15"));
}

test "PT 1w1d" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 1 day", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-07", "2025-06-15"));
}

test "PT 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmtWith(&buf, &pt.locales.en, .normal, "2025-01-15", "2025-07-15"));
}

test "PT 2y1mo" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 1 month", fmtWith(&buf, &pt.locales.en, .normal, "2023-06-15", "2025-07-15"));
}

test "PT 3.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmtWith(&buf, &pt.locales.en, .normal, "2022-06-15", "2025-12-15"));
}

test "PT 7 years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmtWith(&buf, &pt.locales.en, .normal, "2018-06-15", "2025-06-15"));
}

test "PT stage Newborn" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-15", "2025-06-15", ""));
}

test "PT stage Infant" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", ""));
}

test "PT stage Toddler" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

test "PT stage Child" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

test "PT stage Teenager" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

test "PT stage Adult" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

test "PT null age" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &pt.locales.en, .normal, "", "2025-06-15"));
}

test "PT null stage" {
    try expectNull(pt.formatStage(&pt.locales.en, "", "2025-06-15", ""));
}

// ================================================================
// ParentTime with Spanish locale
// ================================================================
test "ES justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Reci\xc3\xa9n nacido", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-15", "2025-06-15"));
}

test "ES singular day" {
    var buf: [256]u8 = undefined;
    try expectStr("1 d\xc3\xada", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-14", "2025-06-15"));
}

test "ES plural days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 d\xc3\xadas", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-12", "2025-06-15"));
}

test "ES singular week" {
    var buf: [256]u8 = undefined;
    try expectStr("1 semana", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-08", "2025-06-15"));
}

test "ES weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 semana, 1 d\xc3\xada", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-07", "2025-06-15"));
}

test "ES plural weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 semanas, 6 d\xc3\xadas", fmtWith(&buf, &pt.locales.es, .normal, "2025-05-26", "2025-06-15"));
}

test "ES months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 meses", fmtWith(&buf, &pt.locales.es, .normal, "2025-01-15", "2025-07-15"));
}

test "ES singular month compound" {
    var buf: [256]u8 = undefined;
    try expectStr("2 a\xc3\xb1os, 1 mes", fmtWith(&buf, &pt.locales.es, .normal, "2023-06-15", "2025-07-15"));
}

test "ES years+months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 a\xc3\xb1os, 6 meses", fmtWith(&buf, &pt.locales.es, .normal, "2023-06-15", "2025-12-15"));
}

test "ES half marker" {
    var buf: [256]u8 = undefined;
    try expectStr("3 y medio a\xc3\xb1os", fmtWith(&buf, &pt.locales.es, .normal, "2022-06-15", "2025-12-15"));
}

test "ES integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("3 a\xc3\xb1os", fmtWith(&buf, &pt.locales.es, .normal, "2022-06-15", "2025-06-15"));
}

test "ES 7+ years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 a\xc3\xb1os", fmtWith(&buf, &pt.locales.es, .normal, "2018-06-15", "2025-06-15"));
}

test "ES null" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &pt.locales.es, .normal, "", "2025-06-15"));
}

test "ES null stage" {
    try expectNull(pt.formatStage(&pt.locales.es, "", "2025-06-15", ""));
}

// ================================================================
// Compactness: short
// ================================================================
test "short days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 d", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-12", "2025-06-15"));
}

test "short weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("1 wk", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-08", "2025-06-15"));
}

test "short weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 wk, 1 d", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-07", "2025-06-15"));
}

test "short months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 mo", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-01-15", "2025-07-15"));
}

test "short years+months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 yr, 1 mo", fmtWith(&buf, &pt.locales.en, .short_mode, "2023-06-15", "2025-07-15"));
}

test "short half years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd yr", fmtWith(&buf, &pt.locales.en, .short_mode, "2022-06-15", "2025-12-15"));
}

test "short integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 yr", fmtWith(&buf, &pt.locales.en, .short_mode, "2018-06-15", "2025-06-15"));
}

test "short justBorn unchanged" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-15", "2025-06-15"));
}

test "short stages unchanged" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", ""));
}

// ================================================================
// Compactness: compact
// ================================================================
test "compact days" {
    var buf: [256]u8 = undefined;
    try expectStr("3d", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-12", "2025-06-15"));
}

test "compact weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("1w", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-08", "2025-06-15"));
}

test "compact weeks+days no delimiter" {
    var buf: [256]u8 = undefined;
    try expectStr("1w1d", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-07", "2025-06-15"));
}

test "compact months" {
    var buf: [256]u8 = undefined;
    try expectStr("6m", fmtWith(&buf, &pt.locales.en, .compact, "2025-01-15", "2025-07-15"));
}

test "compact years+months no delimiter" {
    var buf: [256]u8 = undefined;
    try expectStr("2y1m", fmtWith(&buf, &pt.locales.en, .compact, "2023-06-15", "2025-07-15"));
}

test "compact half years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbdy", fmtWith(&buf, &pt.locales.en, .compact, "2022-06-15", "2025-12-15"));
}

test "compact integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("7y", fmtWith(&buf, &pt.locales.en, .compact, "2018-06-15", "2025-06-15"));
}

test "compact justBorn unchanged" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Hebrew
// ================================================================
test "he justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-15", "2025-06-15"));
}

test "he 1 day one" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\x99\xd7\x95\xd7\x9d 1", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-14", "2025-06-15"));
}

test "he 3 days other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\x99\xd7\x9e\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-12", "2025-06-15"));
}

test "he 2 weeks dual" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x99\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-01", "2025-06-15"));
}

test "he 3 weeks other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x95\xd7\xaa", fmtWith(&buf, &pt.locales.he, .normal, "2025-05-25", "2025-06-15"));
}

test "he 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-01-15", "2025-07-15"));
}

test "he 3 months" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-03-15", "2025-06-15"));
}

test "he 2y dual 1m one" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa9\xd7\xa0\xd7\xaa\xd7\x99\xd7\x99\xd7\x9d, \xd7\x97\xd7\x95\xd7\x93\xd7\xa9 1", fmtWith(&buf, &pt.locales.he, .normal, "2023-06-15", "2025-07-15"));
}

test "he 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d \xd7\x95\xd7\x97\xd7\xa6\xd7\x99", fmtWith(&buf, &pt.locales.he, .normal, "2022-06-15", "2025-12-15"));
}

test "he 7y other" {
    var buf: [256]u8 = undefined;
    try expectStr("7 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2018-06-15", "2025-06-15"));
}

test "he stage m newborn" {
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93", pt.formatStage(&pt.locales.he, "2025-06-15", "2025-06-15", "m"));
}

test "he stage f newborn" {
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93\xd7\x94", pt.formatStage(&pt.locales.he, "2025-06-15", "2025-06-15", "f"));
}

test "he stage m adult" {
    try expectStr("\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8", pt.formatStage(&pt.locales.he, "2007-06-15", "2025-06-15", "m"));
}

test "he stage f adult" {
    try expectStr("\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8\xd7\xaa", pt.formatStage(&pt.locales.he, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// Locale-specific edge cases: Macedonian
// ================================================================
test "mk justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd0\x9d\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb4\xd0\xb5\xd0\xbd\xd1\x87\xd0\xb5", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-15", "2025-06-15"));
}

test "mk 1 day one" {
    var buf: [256]u8 = undefined;
    try expectStr("1 \xd0\xb4\xd0\xb5\xd0\xbd", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-14", "2025-06-15"));
}

test "mk 3 days other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd0\xb4\xd0\xb5\xd0\xbd\xd0\xb0", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-12", "2025-06-15"));
}

test "mk 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86\xd0\xb8", fmtWith(&buf, &pt.locales.mk, .normal, "2025-01-15", "2025-07-15"));
}

test "mk 2y1m one month" {
    var buf: [256]u8 = undefined;
    try expectStr("2 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8, 1 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86", fmtWith(&buf, &pt.locales.mk, .normal, "2023-06-15", "2025-07-15"));
}

test "mk 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8 \xd0\xb8 \xd0\xbf\xd0\xbe\xd0\xbb", fmtWith(&buf, &pt.locales.mk, .normal, "2022-06-15", "2025-12-15"));
}

test "mk 7y" {
    var buf: [256]u8 = undefined;
    try expectStr("7 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8", fmtWith(&buf, &pt.locales.mk, .normal, "2018-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Swahili
// ================================================================
test "sw justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Mzaliwa mpya", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-15", "2025-06-15"));
}

test "sw 1 day" {
    var buf: [256]u8 = undefined;
    try expectStr("siku 1", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-14", "2025-06-15"));
}

test "sw 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("siku 3", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-12", "2025-06-15"));
}

test "sw 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("miezi 6", fmtWith(&buf, &pt.locales.sw, .normal, "2025-01-15", "2025-07-15"));
}

test "sw 2y 1m" {
    var buf: [256]u8 = undefined;
    try expectStr("miaka 2, mwezi 1", fmtWith(&buf, &pt.locales.sw, .normal, "2023-06-15", "2025-07-15"));
}

test "sw 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("miaka 3 na nusu", fmtWith(&buf, &pt.locales.sw, .normal, "2022-06-15", "2025-12-15"));
}

// ================================================================
// Locale-specific edge cases: Indonesian
// ================================================================
test "id justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Baru lahir", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-15", "2025-06-15"));
}

test "id 1 day" {
    var buf: [256]u8 = undefined;
    try expectStr("1 hari", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-14", "2025-06-15"));
}

test "id 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 hari", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-12", "2025-06-15"));
}

test "id 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 bulan", fmtWith(&buf, &pt.locales.id, .normal, "2025-01-15", "2025-07-15"));
}

test "id 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 tahun setengah", fmtWith(&buf, &pt.locales.id, .normal, "2022-06-15", "2025-12-15"));
}

test "id 7y" {
    var buf: [256]u8 = undefined;
    try expectStr("7 tahun", fmtWith(&buf, &pt.locales.id, .normal, "2018-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Amharic
// ================================================================
test "am justBorn" {
    var buf: [512]u8 = undefined;
    try expectStr("\xe1\x8a\xa0\xe1\x8b\xb2\xe1\x88\xb5 \xe1\x8b\xa8\xe1\x89\xb0\xe1\x8b\x88\xe1\x88\x88\xe1\x8b\xb0", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-15", "2025-06-15"));
}

test "am 1 day" {
    var buf: [512]u8 = undefined;
    try expectStr("1 \xe1\x89\x80\xe1\x8a\x95", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-14", "2025-06-15"));
}

test "am 3 days" {
    var buf: [512]u8 = undefined;
    try expectStr("3 \xe1\x89\x80\xe1\x8a\x93\xe1\x89\xb5", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-12", "2025-06-15"));
}

test "am 1w1d ethiopic" {
    var buf: [512]u8 = undefined;
    try expectStr("1 \xe1\x88\xb3\xe1\x88\x9d\xe1\x8a\x95\xe1\x89\xb5\xe1\x8d\xa3 1 \xe1\x89\x80\xe1\x8a\x95", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-07", "2025-06-15"));
}

test "am 6 months" {
    var buf: [512]u8 = undefined;
    try expectStr("6 \xe1\x8b\x88\xe1\x88\xab\xe1\x89\xb5", fmtWith(&buf, &pt.locales.am, .normal, "2025-01-15", "2025-07-15"));
}

test "am 3.5y half" {
    var buf: [512]u8 = undefined;
    try expectStr("3 \xe1\x8b\x93\xe1\x88\x98\xe1\x89\xb3\xe1\x89\xb5 \xe1\x89\xb0\xe1\x8a\xa9\xe1\x88\x8d", fmtWith(&buf, &pt.locales.am, .normal, "2022-06-15", "2025-12-15"));
}

// ================================================================
// Locale lookup by code string
// ================================================================
test "get(en) not null" {
    const en_loc = pt.locales.get("en");
    try std.testing.expect(en_loc != null);
    try std.testing.expectEqualStrings("en", en_loc.?.code);
}

test "get(fr) not null" {
    const fr_loc = pt.locales.get("fr");
    try std.testing.expect(fr_loc != null);
    try std.testing.expectEqualStrings("fr", fr_loc.?.code);
}

test "get(xx) null" {
    try std.testing.expect(pt.locales.get("xx") == null);
}

test "get empty null" {
    try std.testing.expect(pt.locales.get("") == null);
}

test "get(EN) null" {
    try std.testing.expect(pt.locales.get("EN") == null);
}
