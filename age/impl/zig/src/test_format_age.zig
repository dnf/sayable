const std = @import("std");
const pt = @import("sayableage");

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
// Default asOf (15.1, 15.2, 23.1, 23.2, 23.3): dateOfBirth is derived from
// today's UTC date (the library defaults to UTC; std has no local timezone).
// ================================================================
fn todayMinus(buf: *[10]u8, years: u32, days: u32) []const u8 {
    const io = std.Io.Threaded.global_single_threaded.io();
    const secs = std.Io.Clock.real.now(io).toSeconds();
    const epoch_secs = std.time.epoch.EpochSeconds{ .secs = @intCast(secs - @as(i64, days) * 86400) };
    const year_day = epoch_secs.getEpochDay().calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const month: u32 = @backingInt(month_day.month);
    var day: u32 = month_day.day_index + 1;
    if (month == 2 and day == 29 and years > 0) day = 28;
    return std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}", .{ @as(u32, @intCast(year_day.year)) - years, month, day }) catch unreachable;
}

// 15.1, 15.2
test "default asOf age" {
    var buf: [256]u8 = undefined;
    var dob_buf: [10]u8 = undefined;
    try expectStr("5 years", pt.formatAge(&buf, &pt.locales.en, .normal, todayMinus(&dob_buf, 5, 0), null));
    try expectStr("5 years", pt.formatAge(&buf, &pt.locales.en, .normal, todayMinus(&dob_buf, 5, 0), ""));
    try expectStr("5 days", pt.formatAge(&buf, &pt.locales.en, .normal, todayMinus(&dob_buf, 0, 5), null));
}

// 23.1, 23.2, 23.3
test "default asOf stage" {
    var dob_buf: [10]u8 = undefined;
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, todayMinus(&dob_buf, 0, 0), null, null));
    try expectStr("Child", pt.formatStage(&pt.locales.en, todayMinus(&dob_buf, 5, 0), null, null));
    try expectStr("Adult", pt.formatStage(&pt.locales.en, todayMinus(&dob_buf, 45, 0), "", null));
}

// ================================================================
// formatAge -- null/edge cases
// ================================================================
// 1.1, 1.3
test "empty string" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "", "2025-06-15"));
}

// 1.4
test "future dob" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "2025-07-01", "2025-06-15"));
}

// 1.5
test "exactly 500 years" {
    var buf: [256]u8 = undefined;
    try expectStr("500 years", fmt(&buf, "1525-06-15", "2025-06-15"));
}

// 1.6
test "501 years exceeds max" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "1524-06-15", "2025-06-15"));
}

// 1.7
test "1000 years exceeds max" {
    var buf: [256]u8 = undefined;
    try expectNull(fmt(&buf, "1025-06-15", "2025-06-15"));
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
// 2.1
test "born today" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmt(&buf, "2025-06-15", "2025-06-15"));
}

// 2.2
test "1 day ago" {
    var buf: [256]u8 = undefined;
    try expectStr("1 day", fmt(&buf, "2025-06-14", "2025-06-15"));
}

// 2.3
test "3 days ago" {
    var buf: [256]u8 = undefined;
    try expectStr("3 days", fmt(&buf, "2025-06-12", "2025-06-15"));
}

// 2.4
test "6 days ago" {
    var buf: [256]u8 = undefined;
    try expectStr("6 days", fmt(&buf, "2025-06-09", "2025-06-15"));
}

// 2.5
test "7 days -> 1 week" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week", fmt(&buf, "2025-06-08", "2025-06-15"));
}

// ================================================================
// formatAge -- weeks+days tier
// ================================================================
// 3.1
test "7 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week", fmt(&buf, "2025-06-08", "2025-06-15"));
}

// 3.2
test "8 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 1 day", fmt(&buf, "2025-06-07", "2025-06-15"));
}

// 3.3
test "9 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 2 days", fmt(&buf, "2025-06-06", "2025-06-15"));
}

// 3.4
test "13 days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 6 days", fmt(&buf, "2025-06-02", "2025-06-15"));
}

// 3.5
test "14 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks", fmt(&buf, "2025-06-01", "2025-06-15"));
}

// 3.6
test "15 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks, 1 day", fmt(&buf, "2025-05-31", "2025-06-15"));
}

// 3.7
test "20 days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 weeks, 6 days", fmt(&buf, "2025-05-26", "2025-06-15"));
}

// 3.8
test "21 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 weeks", fmt(&buf, "2025-05-25", "2025-06-15"));
}

// 3.9
test "at 1 cal month still weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks, 3 days", fmt(&buf, "2025-05-15", "2025-06-15"));
}

// 3.10
test "at 2 cal months still weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("8 weeks, 5 days", fmt(&buf, "2025-04-15", "2025-06-15"));
}

// 3.11
test "one day before 3mo still weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("13 weeks", fmt(&buf, "2025-03-15", "2025-06-14"));
}

// 3.12
test "on 3mo birthday switches" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-03-15", "2025-06-15"));
}

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================
// 4.1
test "Jan1->Apr1=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-01", "2025-04-01"));
}

// 4.2
test "Jan1->Mar31 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-01-01", "2025-03-31"), "weeks");
}

// 4.3
test "Jun15->Sep15=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-06-15", "2025-09-15"));
}

// 4.4
test "Jun15->Sep14 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-06-15", "2025-09-14"), "weeks");
}

// 4.5
test "Jun15->Dec15=6mo" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-06-15", "2025-12-15"));
}

// ================================================================
// formatAge -- month boundaries: February non-leap
// ================================================================
// 5.1
test "Jan31->Feb28 non-leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks", fmt(&buf, "2025-01-31", "2025-02-28"));
}

// 5.2
test "Jan31->Apr30=3mo(clamp)" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-31", "2025-04-30"));
}

// 5.3
test "Jan31->Apr29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-01-31", "2025-04-29"), "weeks");
}

// 5.4
test "Feb1->May1=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-02-01", "2025-05-01"));
}

// 5.5
test "Feb1->Apr30 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-02-01", "2025-04-30"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================
// 6.1
test "Jan31->Feb29 leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks, 1 day", fmt(&buf, "2024-01-31", "2024-02-29"));
}

// 6.2
test "Jan31->Feb28 leap" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks", fmt(&buf, "2024-01-31", "2024-02-28"));
}

// 6.3
test "Jan31->Apr30 leap=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-01-31", "2024-04-30"));
}

// 6.4
test "Jan30->Feb29 leap still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-01-30", "2024-02-29"), "weeks");
}

// 6.5
test "Jan30->Feb28 leap still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-01-30", "2024-02-28"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================
// 7.1
test "Mar31->Jun30=3mo(clamped)" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-03-31", "2025-06-30"));
}

// 7.2
test "Mar31->Jun29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-03-31", "2025-06-29"), "weeks");
}

// 7.3
test "Aug31->Nov30=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-08-31", "2025-11-30"));
}

// 7.4
test "Aug31->Nov29 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2025-08-31", "2025-11-29"), "weeks");
}

// ================================================================
// formatAge -- leap year baby (born Feb 29)
// ================================================================
// 8.1
test "Feb29->May29=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-02-29", "2024-05-29"));
}

// 8.2
test "Feb29->May28 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-02-29", "2024-05-28"), "weeks");
}

// 8.3
test "Feb29 2024->Feb28 2025=12mo" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-02-29", "2025-02-28"));
}

// 8.4
test "Feb29 2024->Mar1 2025=12mo" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-02-29", "2025-03-01"));
}

// ================================================================
// formatAge -- months tier (3-23)
// ================================================================
// 9.1
test "3 months at transition" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-15", "2025-04-15"));
}

// 9.2
test "6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-01-15", "2025-07-15"));
}

// 9.3
test "12 months (not 1 year)" {
    var buf: [256]u8 = undefined;
    try expectStr("12 months", fmt(&buf, "2024-06-15", "2025-06-15"));
}

// 9.4
test "23 months at upper" {
    var buf: [256]u8 = undefined;
    try expectStr("23 months", fmt(&buf, "2024-01-15", "2025-12-15"));
}

// 9.5
test "one day before boundary" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-15", "2025-07-14"));
}

// 9.6
test "crossing year boundary" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2024-11-10", "2025-04-10"));
}

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================
// 10.1
test "2 years at 24mo" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years", fmt(&buf, "2023-06-15", "2025-06-15"));
}

// 10.2
test "2 years 1 month" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 1 month", fmt(&buf, "2023-06-15", "2025-07-15"));
}

// 10.3
test "2 years 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 6 months", fmt(&buf, "2023-06-15", "2025-12-15"));
}

// 10.4
test "2 years 11 months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 11 months", fmt(&buf, "2023-06-15", "2026-05-15"));
}

// 10.5
test "one day before 24mo" {
    var buf: [256]u8 = undefined;
    try expectStr("23 months", fmt(&buf, "2023-06-15", "2025-06-14"));
}

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================
// 11.1
test "3 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("3 years", fmt(&buf, "2022-06-15", "2025-06-15"));
}

// 11.2
test "3 years 5 months" {
    var buf: [256]u8 = undefined;
    try expectStr("3 years", fmt(&buf, "2022-06-15", "2025-11-15"));
}

// 11.3
test "3.5 years at 3y6m" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmt(&buf, "2022-06-15", "2025-12-15"));
}

// 11.4
test "3.5 years at 3y11m" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmt(&buf, "2022-06-15", "2026-05-15"));
}

// 11.5
test "4 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("4 years", fmt(&buf, "2021-06-15", "2025-06-15"));
}

// 11.6
test "4.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("4\xc2\xbd years", fmt(&buf, "2021-06-15", "2025-12-15"));
}

// 11.7
test "5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("5 years", fmt(&buf, "2020-06-15", "2025-06-15"));
}

// 11.8
test "5.5 years at 5y8m" {
    var buf: [256]u8 = undefined;
    try expectStr("5\xc2\xbd years", fmt(&buf, "2020-06-15", "2026-02-15"));
}

// 11.9
test "6 years" {
    var buf: [256]u8 = undefined;
    try expectStr("6 years", fmt(&buf, "2019-06-15", "2025-06-15"));
}

// 11.10
test "6.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("6\xc2\xbd years", fmt(&buf, "2019-06-15", "2025-12-15"));
}

// 11.11
test "6.5 years at 6y11m" {
    var buf: [256]u8 = undefined;
    try expectStr("6\xc2\xbd years", fmt(&buf, "2019-06-15", "2026-05-15"));
}

// 11.12
test "one day before 3rd bday" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 11 months", fmt(&buf, "2022-06-15", "2025-06-14"));
}

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================
// 12.1
test "7 years exactly" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmt(&buf, "2018-06-15", "2025-06-15"));
}

// 12.2
test "7 years 6 months (no half)" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmt(&buf, "2018-03-20", "2025-06-15"));
}

// 12.3
test "45 years" {
    var buf: [256]u8 = undefined;
    try expectStr("45 years", fmt(&buf, "1980-01-01", "2025-06-15"));
}

// ================================================================
// formatAge -- cross-year with Feb
// ================================================================
// 13.1
test "Dec31->Mar31=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-12-31", "2025-03-31"));
}

// 13.2
test "Dec31->Mar30 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-12-31", "2025-03-30"), "weeks");
}

// 13.3
test "Nov30->Feb28=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2024-11-30", "2025-02-28"));
}

// 13.4
test "Nov30->Feb27 still weeks" {
    var buf: [256]u8 = undefined;
    try expectContains(fmt(&buf, "2024-11-30", "2025-02-27"), "weeks");
}

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================
// 14.1
test "Jan31->Apr30=3mo" {
    var buf: [256]u8 = undefined;
    try expectStr("3 months", fmt(&buf, "2025-01-31", "2025-04-30"));
}

// 14.2
test "Jan31->May31=4mo" {
    var buf: [256]u8 = undefined;
    try expectStr("4 months", fmt(&buf, "2025-01-31", "2025-05-31"));
}

// 14.3
test "Jan31->Jun30=5mo(clamped)" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-31", "2025-06-30"));
}

// 14.4
test "Jan31->Jul1=5mo" {
    var buf: [256]u8 = undefined;
    try expectStr("5 months", fmt(&buf, "2025-01-31", "2025-07-01"));
}

// 14.5
test "Jan31->Jul31=6mo" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmt(&buf, "2025-01-31", "2025-07-31"));
}

// ================================================================
// formatStage -- null/edge cases
// ================================================================
// 16.1, 16.3
test "stage empty" {
    try expectNull(pt.formatStage(&pt.locales.en, "", "2025-06-15", ""));
}

// 16.4
test "stage future" {
    try expectNull(pt.formatStage(&pt.locales.en, "2025-07-01", "2025-06-15", ""));
}

// 16.5
test "stage 500 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "1525-06-15", "2025-06-15", ""));
}

// 16.6
test "stage 501 years exceeds max" {
    try expectNull(pt.formatStage(&pt.locales.en, "1524-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- newborn
// ================================================================
// 17.1
test "stage born today" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-15", "2025-06-15", ""));
}

// 17.2
test "stage 1 day old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-14", "2025-06-15", ""));
}

// 17.3
test "stage 3 weeks old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-05-25", "2025-06-15", ""));
}

// 17.4
test "stage 1 month old" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-05-15", "2025-06-15", ""));
}

// 17.5
test "stage 1 month 29 days" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-04-16", "2025-06-15", ""));
}

// 17.6
test "stage exactly 2 months -> Infant" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-04-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- infant
// ================================================================
// 18.1
test "stage 2 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-04-15", "2025-06-15", ""));
}

// 18.2
test "stage 6 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2024-12-15", "2025-06-15", ""));
}

// 18.3
test "stage 11 months" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2024-07-15", "2025-06-15", ""));
}

// 18.4
test "stage exactly 12mo -> Toddler" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- toddler
// ================================================================
// 19.1
test "stage 12 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

// 19.2
test "stage 18 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-01-15", "2025-07-15", ""));
}

// 19.3
test "stage 24 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2023-06-15", "2025-06-15", ""));
}

// 19.4
test "stage 35 months" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2023-06-15", "2026-05-15", ""));
}

// 19.5
test "stage exactly 36mo -> Child" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- child
// ================================================================
// 20.1
test "stage 3 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

// 20.2
test "stage 4 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2021-06-15", "2025-06-15", ""));
}

// 20.3
test "stage 6 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2019-06-15", "2025-06-15", ""));
}

// 20.4
test "stage 9 years" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2016-06-15", "2025-06-15", ""));
}

// 20.5
test "stage 12y11mo" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2013-06-15", "2026-05-15", ""));
}

// 20.6
test "stage exactly 13y -> Teenager" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- teenager
// ================================================================
// 21.1
test "stage 13 years" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

// 21.2
test "stage 15 years" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2010-06-15", "2025-06-15", ""));
}

// 21.3
test "stage 17y11mo" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2008-06-15", "2026-05-15", ""));
}

// 21.4
test "stage exactly 18y -> Adult" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

// ================================================================
// formatStage -- adult
// ================================================================
// 22.1
test "stage 18 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

// 22.2
test "stage 25 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2000-06-15", "2025-06-15", ""));
}

// 22.3
test "stage 45 years" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "1980-01-01", "2025-06-15", ""));
}

// ================================================================
// formatStage -- gender: Spanish
// ================================================================
// 25.13
test "ES stage newborn m" {
    try expectStr("Reci\xc3\xa9n nacido", pt.formatStage(&pt.locales.es, "2025-06-15", "2025-06-15", ""));
}

// 25.15
test "ES stage toddler m" {
    try expectStr("Ni\xc3\xb1o peque\xc3\xb1o", pt.formatStage(&pt.locales.es, "2024-06-15", "2025-06-15", ""));
}

// 25.16
test "ES stage child m" {
    try expectStr("Ni\xc3\xb1o", pt.formatStage(&pt.locales.es, "2022-06-15", "2025-06-15", ""));
}

// 25.18
test "ES stage adult m" {
    try expectStr("Adulto", pt.formatStage(&pt.locales.es, "2007-06-15", "2025-06-15", ""));
}

// 25.14
test "ES stage infant m" {
    try expectStr("Beb\xc3\xa9", pt.formatStage(&pt.locales.es, "2025-01-15", "2025-06-15", ""));
}

// 25.17
test "ES stage teenager m" {
    try expectStr("Adolescente", pt.formatStage(&pt.locales.es, "2012-06-15", "2025-06-15", ""));
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
// SayableAge with English locale
// ================================================================
// 24.1
test "PT Newborn" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-15", "2025-06-15"));
}

// 24.2
test "PT 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 days", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-12", "2025-06-15"));
}

// 24.3
test "PT 1w1d" {
    var buf: [256]u8 = undefined;
    try expectStr("1 week, 1 day", fmtWith(&buf, &pt.locales.en, .normal, "2025-06-07", "2025-06-15"));
}

// 24.4
test "PT 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 months", fmtWith(&buf, &pt.locales.en, .normal, "2025-01-15", "2025-07-15"));
}

// 24.5
test "PT 2y1mo" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years, 1 month", fmtWith(&buf, &pt.locales.en, .normal, "2023-06-15", "2025-07-15"));
}

// 24.6
test "PT 3.5 years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd years", fmtWith(&buf, &pt.locales.en, .normal, "2022-06-15", "2025-12-15"));
}

// 24.7
test "PT 7 years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 years", fmtWith(&buf, &pt.locales.en, .normal, "2018-06-15", "2025-06-15"));
}

// 24.8
test "PT stage Newborn" {
    try expectStr("Newborn", pt.formatStage(&pt.locales.en, "2025-06-15", "2025-06-15", ""));
}

// 24.9
test "PT stage Infant" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", ""));
}

// 24.10
test "PT stage Toddler" {
    try expectStr("Toddler", pt.formatStage(&pt.locales.en, "2024-06-15", "2025-06-15", ""));
}

// 24.11
test "PT stage Child" {
    try expectStr("Child", pt.formatStage(&pt.locales.en, "2022-06-15", "2025-06-15", ""));
}

// 24.12
test "PT stage Teenager" {
    try expectStr("Teenager", pt.formatStage(&pt.locales.en, "2012-06-15", "2025-06-15", ""));
}

// 24.13
test "PT stage Adult" {
    try expectStr("Adult", pt.formatStage(&pt.locales.en, "2007-06-15", "2025-06-15", ""));
}

// 24.14
test "PT null age" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &pt.locales.en, .normal, "", "2025-06-15"));
}

// 24.15
test "PT null stage" {
    try expectNull(pt.formatStage(&pt.locales.en, "", "2025-06-15", ""));
}

// ================================================================
// SayableAge with Spanish locale
// ================================================================
// 25.1
test "ES justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Reci\xc3\xa9n nacido", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-15", "2025-06-15"));
}

// 25.2
test "ES singular day" {
    var buf: [256]u8 = undefined;
    try expectStr("1 d\xc3\xada", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-14", "2025-06-15"));
}

// 25.3
test "ES plural days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 d\xc3\xadas", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-12", "2025-06-15"));
}

// 25.4
test "ES singular week" {
    var buf: [256]u8 = undefined;
    try expectStr("1 semana", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-08", "2025-06-15"));
}

// 25.5
test "ES weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 semana, 1 d\xc3\xada", fmtWith(&buf, &pt.locales.es, .normal, "2025-06-07", "2025-06-15"));
}

// 25.6
test "ES plural weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("2 semanas, 6 d\xc3\xadas", fmtWith(&buf, &pt.locales.es, .normal, "2025-05-26", "2025-06-15"));
}

// 25.7
test "ES months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 meses", fmtWith(&buf, &pt.locales.es, .normal, "2025-01-15", "2025-07-15"));
}

// 25.8
test "ES singular month compound" {
    var buf: [256]u8 = undefined;
    try expectStr("2 a\xc3\xb1os, 1 mes", fmtWith(&buf, &pt.locales.es, .normal, "2023-06-15", "2025-07-15"));
}

// 25.9
test "ES years+months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 a\xc3\xb1os, 6 meses", fmtWith(&buf, &pt.locales.es, .normal, "2023-06-15", "2025-12-15"));
}

// 25.10
test "ES half marker" {
    var buf: [256]u8 = undefined;
    try expectStr("3 a\xc3\xb1os y medio", fmtWith(&buf, &pt.locales.es, .normal, "2022-06-15", "2025-12-15"));
}

// 25.11
test "ES integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("3 a\xc3\xb1os", fmtWith(&buf, &pt.locales.es, .normal, "2022-06-15", "2025-06-15"));
}

// 25.12
test "ES 7+ years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 a\xc3\xb1os", fmtWith(&buf, &pt.locales.es, .normal, "2018-06-15", "2025-06-15"));
}

// 25.19
test "ES null" {
    var buf: [256]u8 = undefined;
    try expectNull(fmtWith(&buf, &pt.locales.es, .normal, "", "2025-06-15"));
}

// 25.20
test "ES null stage" {
    try expectNull(pt.formatStage(&pt.locales.es, "", "2025-06-15", ""));
}

// ================================================================
// Compactness: short
// ================================================================
// 26.1
test "short days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 d", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-12", "2025-06-15"));
}

// 26.2
test "short weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("1 wk", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-08", "2025-06-15"));
}

// 26.3
test "short weeks+days" {
    var buf: [256]u8 = undefined;
    try expectStr("1 wk, 1 d", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-07", "2025-06-15"));
}

// 26.4
test "short months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 mo", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-01-15", "2025-07-15"));
}

// 26.5
test "short years+months" {
    var buf: [256]u8 = undefined;
    try expectStr("2 yr, 1 mo", fmtWith(&buf, &pt.locales.en, .short_mode, "2023-06-15", "2025-07-15"));
}

// 26.6
test "short half years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbd yr", fmtWith(&buf, &pt.locales.en, .short_mode, "2022-06-15", "2025-12-15"));
}

// 26.7
test "short integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("7 yr", fmtWith(&buf, &pt.locales.en, .short_mode, "2018-06-15", "2025-06-15"));
}

// 26.8
test "short justBorn unchanged" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .short_mode, "2025-06-15", "2025-06-15"));
}

// 26.9
test "short stages unchanged" {
    try expectStr("Infant", pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", ""));
}

// ================================================================
// Compactness: compact
// ================================================================
// 27.1
test "compact days" {
    var buf: [256]u8 = undefined;
    try expectStr("3d", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-12", "2025-06-15"));
}

// 27.2
test "compact weeks" {
    var buf: [256]u8 = undefined;
    try expectStr("1w", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-08", "2025-06-15"));
}

// 27.3
test "compact weeks+days no delimiter" {
    var buf: [256]u8 = undefined;
    try expectStr("1w1d", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-07", "2025-06-15"));
}

// 27.4
test "compact months" {
    var buf: [256]u8 = undefined;
    try expectStr("6m", fmtWith(&buf, &pt.locales.en, .compact, "2025-01-15", "2025-07-15"));
}

// 27.5
test "compact years+months no delimiter" {
    var buf: [256]u8 = undefined;
    try expectStr("2y1m", fmtWith(&buf, &pt.locales.en, .compact, "2023-06-15", "2025-07-15"));
}

// 27.6
test "compact half years" {
    var buf: [256]u8 = undefined;
    try expectStr("3\xc2\xbdy", fmtWith(&buf, &pt.locales.en, .compact, "2022-06-15", "2025-12-15"));
}

// 27.7
test "compact integer years" {
    var buf: [256]u8 = undefined;
    try expectStr("7y", fmtWith(&buf, &pt.locales.en, .compact, "2018-06-15", "2025-06-15"));
}

// 27.8
test "compact justBorn unchanged" {
    var buf: [256]u8 = undefined;
    try expectStr("Newborn", fmtWith(&buf, &pt.locales.en, .compact, "2025-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Hebrew
// ================================================================
// 29.1
test "he justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-15", "2025-06-15"));
}

// 29.2
test "he 1 day one" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\x99\xd7\x95\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-14", "2025-06-15"));
}

// 29.3
test "he 3 days other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\x99\xd7\x9e\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-12", "2025-06-15"));
}

// 29.4
test "he 2 weeks dual" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x99\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-06-01", "2025-06-15"));
}

// 29.5
test "he 3 weeks other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x95\xd7\xaa", fmtWith(&buf, &pt.locales.he, .normal, "2025-05-25", "2025-06-15"));
}

// 29.6
test "he 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-01-15", "2025-07-15"));
}

// 29.7
test "he 3 months" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2025-03-15", "2025-06-15"));
}

// 29.8
test "he 2y dual 1m one" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd7\xa9\xd7\xa0\xd7\xaa\xd7\x99\xd7\x99\xd7\x9d, \xd7\x97\xd7\x95\xd7\x93\xd7\xa9", fmtWith(&buf, &pt.locales.he, .normal, "2023-06-15", "2025-07-15"));
}

// 29.9
test "he 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d \xd7\x95\xd7\x97\xd7\xa6\xd7\x99", fmtWith(&buf, &pt.locales.he, .normal, "2022-06-15", "2025-12-15"));
}

// 29.10
test "he 7y other" {
    var buf: [256]u8 = undefined;
    try expectStr("7 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d", fmtWith(&buf, &pt.locales.he, .normal, "2018-06-15", "2025-06-15"));
}

// 29.11
test "he stage m newborn" {
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93", pt.formatStage(&pt.locales.he, "2025-06-15", "2025-06-15", "m"));
}

// 29.12
test "he stage f newborn" {
    try expectStr("\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93\xd7\x94", pt.formatStage(&pt.locales.he, "2025-06-15", "2025-06-15", "f"));
}

// 29.13
test "he stage m adult" {
    try expectStr("\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8", pt.formatStage(&pt.locales.he, "2007-06-15", "2025-06-15", "m"));
}

// 29.14
test "he stage f adult" {
    try expectStr("\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8\xd7\xaa", pt.formatStage(&pt.locales.he, "2007-06-15", "2025-06-15", "f"));
}

// ================================================================
// Locale-specific edge cases: Macedonian
// ================================================================
// 29.15
test "mk justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("\xd0\x9d\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb4\xd0\xb5\xd0\xbd\xd1\x87\xd0\xb5", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-15", "2025-06-15"));
}

// 29.16
test "mk 1 day one" {
    var buf: [256]u8 = undefined;
    try expectStr("1 \xd0\xb4\xd0\xb5\xd0\xbd", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-14", "2025-06-15"));
}

// 29.17
test "mk 3 days other" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd0\xb4\xd0\xb5\xd0\xbd\xd0\xb0", fmtWith(&buf, &pt.locales.mk, .normal, "2025-06-12", "2025-06-15"));
}

// 29.18
test "mk 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86\xd0\xb8", fmtWith(&buf, &pt.locales.mk, .normal, "2025-01-15", "2025-07-15"));
}

// 29.19
test "mk 2y1m one month" {
    var buf: [256]u8 = undefined;
    try expectStr("2 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8, 1 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86", fmtWith(&buf, &pt.locales.mk, .normal, "2023-06-15", "2025-07-15"));
}

// 29.20
test "mk 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8 \xd0\xb8 \xd0\xbf\xd0\xbe\xd0\xbb", fmtWith(&buf, &pt.locales.mk, .normal, "2022-06-15", "2025-12-15"));
}

// 29.21
test "mk 7y" {
    var buf: [256]u8 = undefined;
    try expectStr("7 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8", fmtWith(&buf, &pt.locales.mk, .normal, "2018-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Swahili
// ================================================================
// 29.22
test "sw justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Mzaliwa mpya", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-15", "2025-06-15"));
}

// 29.23
test "sw 1 day" {
    var buf: [256]u8 = undefined;
    try expectStr("siku 1", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-14", "2025-06-15"));
}

// 29.24
test "sw 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("siku 3", fmtWith(&buf, &pt.locales.sw, .normal, "2025-06-12", "2025-06-15"));
}

// 29.25
test "sw 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("miezi 6", fmtWith(&buf, &pt.locales.sw, .normal, "2025-01-15", "2025-07-15"));
}

// 29.26
test "sw 2y 1m" {
    var buf: [256]u8 = undefined;
    try expectStr("miaka 2, mwezi 1", fmtWith(&buf, &pt.locales.sw, .normal, "2023-06-15", "2025-07-15"));
}

// 29.27
test "sw 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("miaka 3 na nusu", fmtWith(&buf, &pt.locales.sw, .normal, "2022-06-15", "2025-12-15"));
}

// ================================================================
// Locale-specific edge cases: Indonesian
// ================================================================
// 29.28
test "id justBorn" {
    var buf: [256]u8 = undefined;
    try expectStr("Baru lahir", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-15", "2025-06-15"));
}

// 29.29
test "id 1 day" {
    var buf: [256]u8 = undefined;
    try expectStr("1 hari", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-14", "2025-06-15"));
}

// 29.30
test "id 3 days" {
    var buf: [256]u8 = undefined;
    try expectStr("3 hari", fmtWith(&buf, &pt.locales.id, .normal, "2025-06-12", "2025-06-15"));
}

// 29.31
test "id 6 months" {
    var buf: [256]u8 = undefined;
    try expectStr("6 bulan", fmtWith(&buf, &pt.locales.id, .normal, "2025-01-15", "2025-07-15"));
}

// 29.32
test "id 3.5y half" {
    var buf: [256]u8 = undefined;
    try expectStr("3 setengah tahun", fmtWith(&buf, &pt.locales.id, .normal, "2022-06-15", "2025-12-15"));
}

// 29.33
test "id 7y" {
    var buf: [256]u8 = undefined;
    try expectStr("7 tahun", fmtWith(&buf, &pt.locales.id, .normal, "2018-06-15", "2025-06-15"));
}

// ================================================================
// Locale-specific edge cases: Amharic
// ================================================================
// 29.34
test "am justBorn" {
    var buf: [512]u8 = undefined;
    try expectStr("\xe1\x8a\xa0\xe1\x8b\xb2\xe1\x88\xb5 \xe1\x8b\xa8\xe1\x89\xb0\xe1\x8b\x88\xe1\x88\x88\xe1\x8b\xb0", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-15", "2025-06-15"));
}

// 29.35
test "am 1 day" {
    var buf: [512]u8 = undefined;
    try expectStr("1 \xe1\x89\x80\xe1\x8a\x95", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-14", "2025-06-15"));
}

// 29.36
test "am 3 days" {
    var buf: [512]u8 = undefined;
    try expectStr("3 \xe1\x89\x80\xe1\x8a\x93\xe1\x89\xb5", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-12", "2025-06-15"));
}

// 29.37
test "am 1w1d ethiopic" {
    var buf: [512]u8 = undefined;
    try expectStr("1 \xe1\x88\xb3\xe1\x88\x9d\xe1\x8a\x95\xe1\x89\xb5\xe1\x8d\xa3 1 \xe1\x89\x80\xe1\x8a\x95", fmtWith(&buf, &pt.locales.am, .normal, "2025-06-07", "2025-06-15"));
}

// 29.38
test "am 6 months" {
    var buf: [512]u8 = undefined;
    try expectStr("6 \xe1\x8b\x88\xe1\x88\xab\xe1\x89\xb5", fmtWith(&buf, &pt.locales.am, .normal, "2025-01-15", "2025-07-15"));
}

// 29.39
test "am 3.5y half" {
    var buf: [512]u8 = undefined;
    try expectStr("3 \xe1\x8b\x93\xe1\x88\x98\xe1\x89\xb3\xe1\x89\xb5 \xe1\x89\xb0\xe1\x8a\xa9\xe1\x88\x8d", fmtWith(&buf, &pt.locales.am, .normal, "2022-06-15", "2025-12-15"));
}

// ================================================================
// Locale lookup by code string
// ================================================================
// 30.1
test "get(en) not null" {
    const en_loc = pt.locales.get("en");
    try std.testing.expect(en_loc != null);
    try std.testing.expectEqualStrings("en", en_loc.?.code);
}

// 30.2
test "get(fr) not null" {
    const fr_loc = pt.locales.get("fr");
    try std.testing.expect(fr_loc != null);
    try std.testing.expectEqualStrings("fr", fr_loc.?.code);
}

// 30.3
test "get(xx) null" {
    try std.testing.expect(pt.locales.get("xx") == null);
}

// 30.4
test "get empty null" {
    try std.testing.expect(pt.locales.get("") == null);
}

// 30.5
test "get(EN) null" {
    try std.testing.expect(pt.locales.get("EN") == null);
}

// ================================================================
// Section 31: Weeks and days across month ends
// ================================================================
// 31.1
test "31.1 88 days across a 28-day February" {
    var buf: [256]u8 = undefined;
    try expectStr("12 weeks, 4 days", pt.formatAge(&buf, &pt.locales.en, .normal, "2016-12-31", "2017-03-29"));
}

// 31.2
test "31.2 90 days across a year end into a leap year" {
    var buf: [256]u8 = undefined;
    try expectStr("12 weeks, 6 days", pt.formatAge(&buf, &pt.locales.en, .normal, "1991-11-27", "1992-02-25"));
}

// 31.3
test "31.3 33 days across a year end" {
    var buf: [256]u8 = undefined;
    try expectStr("4 weeks, 5 days", pt.formatAge(&buf, &pt.locales.en, .normal, "2020-11-30", "2021-01-02"));
}

// 31.4
test "31.4 Compact form of 31.1" {
    var buf: [256]u8 = undefined;
    try expectStr("12w4d", pt.formatAge(&buf, &pt.locales.en, .compact, "2016-12-31", "2017-03-29"));
}

// ================================================================
// Section 32: Half years take their plural form from whole years
// ================================================================
// 32.1
test "32.1 Polish 3 is 'few'" {
    var buf: [256]u8 = undefined;
    try expectStr("3 i pół lata", pt.formatAge(&buf, &pt.locales.pl, .normal, "2021-06-15", "2025-01-15"));
}

// 32.2
test "32.2 Polish 5 is 'many'" {
    var buf: [256]u8 = undefined;
    try expectStr("5 i pół lat", pt.formatAge(&buf, &pt.locales.pl, .short_mode, "2020-06-15", "2025-12-15"));
}

// 32.3
test "32.3 Tachelhit 6 is 'few'" {
    var buf: [256]u8 = undefined;
    try expectStr("6 \xe2\xb5\x89\xe2\xb5\x99\xe2\xb4\xb3\xe2\xb4\xb3\xe2\xb5\xaf\xe2\xb4\xb0\xe2\xb5\x99\xe2\xb5\x8f \xe2\xb4\xb7 \xe2\xb5\x93\xe2\xb5\xa3\xe2\xb4\xb3\xe2\xb5\x8f", pt.formatAge(&buf, &pt.locales.shi, .normal, "2005-06-08", "2012-06-07"));
}

// ================================================================
// Section 33: Input validation
// ================================================================
// 33.1
test "33.1 February 30 doesn't exist" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2025-02-30", "2032-06-25"));
}

// 33.2
test "33.2 Month 13" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2025-13-01", "2027-01-31"));
}

// 33.3
test "33.3 February 29 in a non-leap year" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2023-02-29", "2025-03-01"));
}

// 33.4
test "33.4 Day 00" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2025-06-00", "2027-02-25"));
}

// 33.5
test "33.5 Unpadded month and day" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2025-6-1", "2027-02-25"));
}

// 33.6
test "33.6 Surrounding whitespace" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, " 2025-06-01", "2027-02-25"));
}

// 33.7
test "33.7 A datetime is not a date" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2025-06-15T10:00:00", "2027-02-25"));
}

// 33.8
test "33.8 Invalid asOf" {
    var buf: [256]u8 = undefined;
    try expectNull(pt.formatAge(&buf, &pt.locales.en, .normal, "2020-01-01", "2025-04-31"));
}

// 33.9
test "33.9 formatStage validates too" {
    try expectNull(pt.formatStage(&pt.locales.en, "2025-02-30", "2027-09-05", ""));
}

// 33.10
test "33.10 February 29 in a leap year is valid" {
    var buf: [256]u8 = undefined;
    try expectStr("2 years", pt.formatAge(&buf, &pt.locales.en, .normal, "2024-02-29", "2026-03-01"));
}
