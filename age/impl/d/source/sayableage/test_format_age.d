/// Tests for sayable-age D implementation.
/// All tests use explicit (dob, asOf) pairs for determinism.
module sayableage.test_format_age;

import std.typecons : Nullable;
import std.algorithm : canFind;
import sayableage.format_age : SayableAge, VERSION;
import sayableage.locale;
import sayableage.locales;

/// Helper to assert non-null string equals expected.
private void assertAge(string name, Nullable!string got, string want) {
    assert(!got.isNull, name ~ ": got null, want \"" ~ want ~ "\"");
    assert(got.get == want, name ~ ": got \"" ~ got.get ~ "\", want \"" ~ want ~ "\"");
}

/// Helper to assert null result.
private void assertNull(string name, Nullable!string got) {
    assert(got.isNull, name ~ ": got non-null, want null");
}

/// Helper to assert result contains substring.
private void assertContains(string name, Nullable!string got, string substr) {
    assert(!got.isNull, name ~ ": got null, want string containing \"" ~ substr ~ "\"");
    assert(canFind(got.get, substr), name ~ ": got \"" ~ got.get ~ "\", want string containing \"" ~ substr ~ "\"");
}

/// A date `years` and `days` before today, as YYYY-MM-DD. SayableAge reads the
/// real clock when asOf is omitted and has no override, so the default-date
/// tests derive their input from today to keep the canonical expected output.
private string dateAgo(int years, int days = 0) {
    import std.datetime.date : Date;
    import std.datetime.systime : Clock;
    import std.datetime : AllowDayOverflow;
    import core.time : dur;
    auto date = cast(Date) Clock.currTime();
    date.add!"years"(-years, AllowDayOverflow.no);
    date -= dur!"days"(days);
    return date.toISOExtString();
}

/// Create default English SayableAge.
private SayableAge en() {
    return SayableAge(EN);
}

// ================================================================
// Section 1: formatAge -- null/edge cases
// ================================================================
// 1.1, 1.3
unittest {
    auto pt = en();
    assertNull("1.1 empty string", pt.formatAge("", "2025-06-15"));
}

// 1.4
unittest {
    auto pt = en();
    assertNull("1.4 future dob", pt.formatAge("2025-07-01", "2025-06-15"));
}

// 1.5
unittest {
    auto pt = en();
    assertAge("1.5 exactly 500 years", pt.formatAge("1525-06-15", "2025-06-15"), "500 years");
}

// 1.6
unittest {
    auto pt = en();
    assertNull("1.6 501 years exceeds max", pt.formatAge("1524-06-15", "2025-06-15"));
}

// 1.7
unittest {
    auto pt = en();
    assertNull("1.7 1000 years exceeds max", pt.formatAge("1025-06-15", "2025-06-15"));
}

// ================================================================
// Section 2: formatAge -- days tier (0-6)
// ================================================================
// 2.1
unittest {
    auto pt = en();
    assertAge("2.1 born today", pt.formatAge("2025-06-15", "2025-06-15"), "Newborn");
}

// 2.2
unittest {
    auto pt = en();
    assertAge("2.2 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "1 day");
}

// 2.3
unittest {
    auto pt = en();
    assertAge("2.3 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 days");
}

// 2.4
unittest {
    auto pt = en();
    assertAge("2.4 6 days", pt.formatAge("2025-06-09", "2025-06-15"), "6 days");
}

// 2.5
unittest {
    auto pt = en();
    assertAge("2.5 7 days = 1 week", pt.formatAge("2025-06-08", "2025-06-15"), "1 week");
}

// ================================================================
// Section 3: formatAge -- weeks+days tier
// ================================================================
// 3.1
unittest {
    auto pt = en();
    assertAge("3.1 1 week", pt.formatAge("2025-06-08", "2025-06-15"), "1 week");
}

// 3.2
unittest {
    auto pt = en();
    assertAge("3.2 1 week 1 day", pt.formatAge("2025-06-07", "2025-06-15"), "1 week, 1 day");
}

// 3.3
unittest {
    auto pt = en();
    assertAge("3.3 1 week 2 days", pt.formatAge("2025-06-06", "2025-06-15"), "1 week, 2 days");
}

// 3.4
unittest {
    auto pt = en();
    assertAge("3.4 1 week 6 days", pt.formatAge("2025-06-02", "2025-06-15"), "1 week, 6 days");
}

// 3.5
unittest {
    auto pt = en();
    assertAge("3.5 2 weeks", pt.formatAge("2025-06-01", "2025-06-15"), "2 weeks");
}

// 3.6
unittest {
    auto pt = en();
    assertAge("3.6 2 weeks 1 day", pt.formatAge("2025-05-31", "2025-06-15"), "2 weeks, 1 day");
}

// 3.7
unittest {
    auto pt = en();
    assertAge("3.7 2 weeks 6 days", pt.formatAge("2025-05-26", "2025-06-15"), "2 weeks, 6 days");
}

// 3.8
unittest {
    auto pt = en();
    assertAge("3.8 3 weeks", pt.formatAge("2025-05-25", "2025-06-15"), "3 weeks");
}

// 3.9
unittest {
    auto pt = en();
    assertAge("3.9 1 cal month still weeks", pt.formatAge("2025-05-15", "2025-06-15"), "4 weeks, 3 days");
}

// 3.10
unittest {
    auto pt = en();
    assertAge("3.10 2 cal months still weeks", pt.formatAge("2025-04-15", "2025-06-15"), "8 weeks, 5 days");
}

// 3.11
unittest {
    auto pt = en();
    assertAge("3.11 day before 3mo", pt.formatAge("2025-03-15", "2025-06-14"), "13 weeks");
}

// 3.12
unittest {
    auto pt = en();
    assertAge("3.12 on 3mo birthday", pt.formatAge("2025-03-15", "2025-06-15"), "3 months");
}

// ================================================================
// Section 4: Month boundaries -- standard months
// ================================================================
// 4.1
unittest {
    auto pt = en();
    assertAge("4.1 Jan1-Apr1", pt.formatAge("2025-01-01", "2025-04-01"), "3 months");
}

// 4.2
unittest {
    auto pt = en();
    assertContains("4.2 Jan1-Mar31 still weeks", pt.formatAge("2025-01-01", "2025-03-31"), "weeks");
}

// 4.3
unittest {
    auto pt = en();
    assertAge("4.3 Jun15-Sep15", pt.formatAge("2025-06-15", "2025-09-15"), "3 months");
}

// 4.4
unittest {
    auto pt = en();
    assertContains("4.4 Jun15-Sep14 still weeks", pt.formatAge("2025-06-15", "2025-09-14"), "weeks");
}

// 4.5
unittest {
    auto pt = en();
    assertAge("4.5 6 months", pt.formatAge("2025-06-15", "2025-12-15"), "6 months");
}

// ================================================================
// Section 5: Month boundaries -- February non-leap
// ================================================================
// 5.1
unittest {
    auto pt = en();
    assertAge("5.1 Jan31-Feb28 non-leap", pt.formatAge("2025-01-31", "2025-02-28"), "4 weeks");
}

// 5.2
unittest {
    auto pt = en();
    assertAge("5.2 Jan31-Apr30 = 3mo", pt.formatAge("2025-01-31", "2025-04-30"), "3 months");
}

// 5.3
unittest {
    auto pt = en();
    assertContains("5.3 Jan31-Apr29 still weeks", pt.formatAge("2025-01-31", "2025-04-29"), "weeks");
}

// 5.4
unittest {
    auto pt = en();
    assertAge("5.4 Feb1-May1 = 3mo", pt.formatAge("2025-02-01", "2025-05-01"), "3 months");
}

// 5.5
unittest {
    auto pt = en();
    assertContains("5.5 Feb1-Apr30 still weeks", pt.formatAge("2025-02-01", "2025-04-30"), "weeks");
}

// ================================================================
// Section 6: Month boundaries -- February leap year
// ================================================================
// 6.1
unittest {
    auto pt = en();
    assertAge("6.1 Jan31-Feb29 leap", pt.formatAge("2024-01-31", "2024-02-29"), "4 weeks, 1 day");
}

// 6.2
unittest {
    auto pt = en();
    assertAge("6.2 Jan31-Feb28 leap", pt.formatAge("2024-01-31", "2024-02-28"), "4 weeks");
}

// 6.3
unittest {
    auto pt = en();
    assertAge("6.3 Jan31-Apr30 leap = 3mo", pt.formatAge("2024-01-31", "2024-04-30"), "3 months");
}

// 6.4
unittest {
    auto pt = en();
    assertContains("6.4 Jan30-Feb29 leap still weeks", pt.formatAge("2024-01-30", "2024-02-29"), "weeks");
}

// 6.5
unittest {
    auto pt = en();
    assertContains("6.5 Jan30-Feb28 leap still weeks", pt.formatAge("2024-01-30", "2024-02-28"), "weeks");
}

// ================================================================
// Section 7: Month boundaries -- 30-day months
// ================================================================
// 7.1
unittest {
    auto pt = en();
    assertAge("7.1 Mar31-Jun30 = 3mo", pt.formatAge("2025-03-31", "2025-06-30"), "3 months");
}

// 7.2
unittest {
    auto pt = en();
    assertContains("7.2 Mar31-Jun29 still weeks", pt.formatAge("2025-03-31", "2025-06-29"), "weeks");
}

// 7.3
unittest {
    auto pt = en();
    assertAge("7.3 Aug31-Nov30 = 3mo", pt.formatAge("2025-08-31", "2025-11-30"), "3 months");
}

// 7.4
unittest {
    auto pt = en();
    assertContains("7.4 Aug31-Nov29 still weeks", pt.formatAge("2025-08-31", "2025-11-29"), "weeks");
}

// ================================================================
// Section 8: Month boundaries -- leap year baby (born Feb 29)
// ================================================================
// 8.1
unittest {
    auto pt = en();
    assertAge("8.1 Feb29-May29 = 3mo", pt.formatAge("2024-02-29", "2024-05-29"), "3 months");
}

// 8.2
unittest {
    auto pt = en();
    assertContains("8.2 Feb29-May28 still weeks", pt.formatAge("2024-02-29", "2024-05-28"), "weeks");
}

// 8.3
unittest {
    auto pt = en();
    assertAge("8.3 Feb29 2024-Feb28 2025 = 12mo", pt.formatAge("2024-02-29", "2025-02-28"), "12 months");
}

// 8.4
unittest {
    auto pt = en();
    assertAge("8.4 Feb29 2024-Mar1 2025 = 12mo", pt.formatAge("2024-02-29", "2025-03-01"), "12 months");
}

// ================================================================
// Section 9: Months tier (3-23)
// ================================================================
// 9.1
unittest {
    auto pt = en();
    assertAge("9.1 3 months", pt.formatAge("2025-01-15", "2025-04-15"), "3 months");
}

// 9.2
unittest {
    auto pt = en();
    assertAge("9.2 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 months");
}

// 9.3
unittest {
    auto pt = en();
    assertAge("9.3 12 months not 1 year", pt.formatAge("2024-06-15", "2025-06-15"), "12 months");
}

// 9.4
unittest {
    auto pt = en();
    assertAge("9.4 23 months", pt.formatAge("2024-01-15", "2025-12-15"), "23 months");
}

// 9.5
unittest {
    auto pt = en();
    assertAge("9.5 day before boundary", pt.formatAge("2025-01-15", "2025-07-14"), "5 months");
}

// 9.6
unittest {
    auto pt = en();
    assertAge("9.6 cross-year boundary", pt.formatAge("2024-11-10", "2025-04-10"), "5 months");
}

// ================================================================
// Section 10: Years+months tier (24-35 months)
// ================================================================
// 10.1
unittest {
    auto pt = en();
    assertAge("10.1 2 years at 24mo", pt.formatAge("2023-06-15", "2025-06-15"), "2 years");
}

// 10.2
unittest {
    auto pt = en();
    assertAge("10.2 2y 1m", pt.formatAge("2023-06-15", "2025-07-15"), "2 years, 1 month");
}

// 10.3
unittest {
    auto pt = en();
    assertAge("10.3 2y 6m", pt.formatAge("2023-06-15", "2025-12-15"), "2 years, 6 months");
}

// 10.4
unittest {
    auto pt = en();
    assertAge("10.4 2y 11m", pt.formatAge("2023-06-15", "2026-05-15"), "2 years, 11 months");
}

// 10.5
unittest {
    auto pt = en();
    assertAge("10.5 day before 24mo", pt.formatAge("2023-06-15", "2025-06-14"), "23 months");
}

// ================================================================
// Section 11: Half-year tier (3-6 years)
// ================================================================
// 11.1
unittest {
    auto pt = en();
    assertAge("11.1 3 years", pt.formatAge("2022-06-15", "2025-06-15"), "3 years");
}

// 11.2
unittest {
    auto pt = en();
    assertAge("11.2 3y5m", pt.formatAge("2022-06-15", "2025-11-15"), "3 years");
}

// 11.3
unittest {
    auto pt = en();
    assertAge("11.3 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3\u00BD years");
}

// 11.4
unittest {
    auto pt = en();
    assertAge("11.4 3.5y at 3y11m", pt.formatAge("2022-06-15", "2026-05-15"), "3\u00BD years");
}

// 11.5
unittest {
    auto pt = en();
    assertAge("11.5 4 years", pt.formatAge("2021-06-15", "2025-06-15"), "4 years");
}

// 11.6
unittest {
    auto pt = en();
    assertAge("11.6 4.5y", pt.formatAge("2021-06-15", "2025-12-15"), "4\u00BD years");
}

// 11.7
unittest {
    auto pt = en();
    assertAge("11.7 5 years", pt.formatAge("2020-06-15", "2025-06-15"), "5 years");
}

// 11.8
unittest {
    auto pt = en();
    assertAge("11.8 5.5y", pt.formatAge("2020-06-15", "2026-02-15"), "5\u00BD years");
}

// 11.9
unittest {
    auto pt = en();
    assertAge("11.9 6 years", pt.formatAge("2019-06-15", "2025-06-15"), "6 years");
}

// 11.10
unittest {
    auto pt = en();
    assertAge("11.10 6.5y", pt.formatAge("2019-06-15", "2025-12-15"), "6\u00BD years");
}

// 11.11
unittest {
    auto pt = en();
    assertAge("11.11 6.5y at 6y11m", pt.formatAge("2019-06-15", "2026-05-15"), "6\u00BD years");
}

// 11.12
unittest {
    auto pt = en();
    assertAge("11.12 day before 3rd bday", pt.formatAge("2022-06-15", "2025-06-14"), "2 years, 11 months");
}

// ================================================================
// Section 12: Integer tier (7+ years)
// ================================================================
// 12.1
unittest {
    auto pt = en();
    assertAge("12.1 7 years", pt.formatAge("2018-06-15", "2025-06-15"), "7 years");
}

// 12.2
unittest {
    auto pt = en();
    assertAge("12.2 7y6m no half", pt.formatAge("2018-03-20", "2025-06-15"), "7 years");
}

// 12.3
unittest {
    auto pt = en();
    assertAge("12.3 45 years", pt.formatAge("1980-01-01", "2025-06-15"), "45 years");
}

// ================================================================
// Section 13: Cross-year transitions with February
// ================================================================
// 13.1
unittest {
    auto pt = en();
    assertAge("13.1 Dec31-Mar31 = 3mo", pt.formatAge("2024-12-31", "2025-03-31"), "3 months");
}

// 13.2
unittest {
    auto pt = en();
    assertContains("13.2 Dec31-Mar30 still weeks", pt.formatAge("2024-12-31", "2025-03-30"), "weeks");
}

// 13.3
unittest {
    auto pt = en();
    assertAge("13.3 Nov30-Feb28 = 3mo", pt.formatAge("2024-11-30", "2025-02-28"), "3 months");
}

// 13.4
unittest {
    auto pt = en();
    assertContains("13.4 Nov30-Feb27 still weeks", pt.formatAge("2024-11-30", "2025-02-27"), "weeks");
}

// ================================================================
// Section 14: Born-on-31st progression
// ================================================================
// 14.1
unittest {
    auto pt = en();
    assertAge("14.1 Jan31-Apr30 = 3mo", pt.formatAge("2025-01-31", "2025-04-30"), "3 months");
}

// 14.2
unittest {
    auto pt = en();
    assertAge("14.2 Jan31-May31 = 4mo", pt.formatAge("2025-01-31", "2025-05-31"), "4 months");
}

// 14.3
unittest {
    auto pt = en();
    assertAge("14.3 Jan31-Jun30 = 5mo", pt.formatAge("2025-01-31", "2025-06-30"), "5 months");
}

// 14.4
unittest {
    auto pt = en();
    assertAge("14.4 Jan31-Jul1 = 5mo", pt.formatAge("2025-01-31", "2025-07-01"), "5 months");
}

// 14.5
unittest {
    auto pt = en();
    assertAge("14.5 Jan31-Jul31 = 6mo", pt.formatAge("2025-01-31", "2025-07-31"), "6 months");
}

// ================================================================
// Section 15: Default asOf (current date)
// ================================================================
// 15.1
unittest {
    auto pt = en();
    assertAge("15.1 default asOf 5 years", pt.formatAge(dateAgo(5)), "5 years");
}

// 15.2
unittest {
    auto pt = en();
    assertAge("15.2 default asOf 5 days", pt.formatAge(dateAgo(0, 5)), "5 days");
}

// ================================================================
// Section 16: formatStage -- null/edge cases
// ================================================================
// 16.1, 16.3
unittest {
    auto pt = en();
    assertNull("16.1 empty string", pt.formatStage("", "2025-06-15"));
}

// 16.4
unittest {
    auto pt = en();
    assertNull("16.4 future dob", pt.formatStage("2025-07-01", "2025-06-15"));
}

// 16.5
unittest {
    auto pt = en();
    assertAge("16.5 stage 500 years", pt.formatStage("1525-06-15", "2025-06-15"), "Adult");
}

// 16.6
unittest {
    auto pt = en();
    assertNull("16.6 stage 501 years", pt.formatStage("1524-06-15", "2025-06-15"));
}

// ================================================================
// Section 17: formatStage -- Newborn
// ================================================================
// 17.1
unittest {
    auto pt = en();
    assertAge("17.1 born today", pt.formatStage("2025-06-15", "2025-06-15"), "Newborn");
}

// 17.2
unittest {
    auto pt = en();
    assertAge("17.2 1 day", pt.formatStage("2025-06-14", "2025-06-15"), "Newborn");
}

// 17.3
unittest {
    auto pt = en();
    assertAge("17.3 3 weeks", pt.formatStage("2025-05-25", "2025-06-15"), "Newborn");
}

// 17.4
unittest {
    auto pt = en();
    assertAge("17.4 1 month", pt.formatStage("2025-05-15", "2025-06-15"), "Newborn");
}

// 17.5
unittest {
    auto pt = en();
    assertAge("17.5 1mo 29d", pt.formatStage("2025-04-16", "2025-06-15"), "Newborn");
}

// 17.6
unittest {
    auto pt = en();
    assertAge("17.6 exactly 2mo -> Infant", pt.formatStage("2025-04-15", "2025-06-15"), "Infant");
}

// ================================================================
// Section 18: formatStage -- Infant
// ================================================================
// 18.1
unittest {
    auto pt = en();
    assertAge("18.1 2 months", pt.formatStage("2025-04-15", "2025-06-15"), "Infant");
}

// 18.2
unittest {
    auto pt = en();
    assertAge("18.2 6 months", pt.formatStage("2024-12-15", "2025-06-15"), "Infant");
}

// 18.3
unittest {
    auto pt = en();
    assertAge("18.3 11 months", pt.formatStage("2024-07-15", "2025-06-15"), "Infant");
}

// 18.4
unittest {
    auto pt = en();
    assertAge("18.4 12mo -> Toddler", pt.formatStage("2024-06-15", "2025-06-15"), "Toddler");
}

// ================================================================
// Section 19: formatStage -- Toddler
// ================================================================
// 19.1
unittest {
    auto pt = en();
    assertAge("19.1 12 months", pt.formatStage("2024-06-15", "2025-06-15"), "Toddler");
}

// 19.2
unittest {
    auto pt = en();
    assertAge("19.2 18 months", pt.formatStage("2024-01-15", "2025-07-15"), "Toddler");
}

// 19.3
unittest {
    auto pt = en();
    assertAge("19.3 24 months", pt.formatStage("2023-06-15", "2025-06-15"), "Toddler");
}

// 19.4
unittest {
    auto pt = en();
    assertAge("19.4 35 months", pt.formatStage("2023-06-15", "2026-05-15"), "Toddler");
}

// 19.5
unittest {
    auto pt = en();
    assertAge("19.5 36mo -> Child", pt.formatStage("2022-06-15", "2025-06-15"), "Child");
}

// ================================================================
// Section 20: formatStage -- Child
// ================================================================
// 20.1
unittest {
    auto pt = en();
    assertAge("20.1 3 years", pt.formatStage("2022-06-15", "2025-06-15"), "Child");
}

// 20.2
unittest {
    auto pt = en();
    assertAge("20.2 4 years", pt.formatStage("2021-06-15", "2025-06-15"), "Child");
}

// 20.3
unittest {
    auto pt = en();
    assertAge("20.3 6 years", pt.formatStage("2019-06-15", "2025-06-15"), "Child");
}

// 20.4
unittest {
    auto pt = en();
    assertAge("20.4 9 years", pt.formatStage("2016-06-15", "2025-06-15"), "Child");
}

// 20.5
unittest {
    auto pt = en();
    assertAge("20.5 12y11m", pt.formatStage("2013-06-15", "2026-05-15"), "Child");
}

// 20.6
unittest {
    auto pt = en();
    assertAge("20.6 13y -> Teenager", pt.formatStage("2012-06-15", "2025-06-15"), "Teenager");
}

// ================================================================
// Section 21: formatStage -- Teenager
// ================================================================
// 21.1
unittest {
    auto pt = en();
    assertAge("21.1 13 years", pt.formatStage("2012-06-15", "2025-06-15"), "Teenager");
}

// 21.2
unittest {
    auto pt = en();
    assertAge("21.2 15 years", pt.formatStage("2010-06-15", "2025-06-15"), "Teenager");
}

// 21.3
unittest {
    auto pt = en();
    assertAge("21.3 17y11m", pt.formatStage("2008-06-15", "2026-05-15"), "Teenager");
}

// 21.4
unittest {
    auto pt = en();
    assertAge("21.4 18y -> Adult", pt.formatStage("2007-06-15", "2025-06-15"), "Adult");
}

// ================================================================
// Section 22: formatStage -- Adult
// ================================================================
// 22.1
unittest {
    auto pt = en();
    assertAge("22.1 18 years", pt.formatStage("2007-06-15", "2025-06-15"), "Adult");
}

// 22.2
unittest {
    auto pt = en();
    assertAge("22.2 25 years", pt.formatStage("2000-06-15", "2025-06-15"), "Adult");
}

// 22.3
unittest {
    auto pt = en();
    assertAge("22.3 45 years", pt.formatStage("1980-01-01", "2025-06-15"), "Adult");
}

// ================================================================
// Section 23: formatStage -- default asOf (inputs derived from today)
// ================================================================
// 23.1
unittest {
    auto pt = en();
    assertAge("23.1 default asOf born today", pt.formatStage(dateAgo(0)), "Newborn");
}

// 23.2
unittest {
    auto pt = en();
    assertAge("23.2 default asOf 5 years", pt.formatStage(dateAgo(5)), "Child");
}

// 23.3
unittest {
    auto pt = en();
    assertAge("23.3 default asOf 45 years", pt.formatStage(dateAgo(45)), "Adult");
}

// ================================================================
// Section 24: SayableAge class -- English locale delegation
// ================================================================
// 24.1-24.7 (formatAge)
unittest {
    auto pt = SayableAge(EN);
    assertAge("24.1 Newborn", pt.formatAge("2025-06-15", "2025-06-15"), "Newborn");
    assertAge("24.2 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 days");
    assertAge("24.3 1w 1d", pt.formatAge("2025-06-07", "2025-06-15"), "1 week, 1 day");
    assertAge("24.4 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 months");
    assertAge("24.5 2y 1mo", pt.formatAge("2023-06-15", "2025-07-15"), "2 years, 1 month");
    assertAge("24.6 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3\u00BD years");
    assertAge("24.7 7 years", pt.formatAge("2018-06-15", "2025-06-15"), "7 years");
}

// 24.8-24.13 (formatStage)
unittest {
    auto pt = SayableAge(EN);
    assertAge("24.8 stage Newborn", pt.formatStage("2025-06-15", "2025-06-15"), "Newborn");
    assertAge("24.9 stage Infant", pt.formatStage("2025-01-15", "2025-06-15"), "Infant");
    assertAge("24.10 stage Toddler", pt.formatStage("2024-06-15", "2025-06-15"), "Toddler");
    assertAge("24.11 stage Child", pt.formatStage("2022-06-15", "2025-06-15"), "Child");
    assertAge("24.12 stage Teenager", pt.formatStage("2012-06-15", "2025-06-15"), "Teenager");
    assertAge("24.13 stage Adult", pt.formatStage("2007-06-15", "2025-06-15"), "Adult");
}

// 24.14-24.15 (null handling)
unittest {
    auto pt = SayableAge(EN);
    assertNull("24.14 null age", pt.formatAge(""));
    assertNull("24.15 null stage", pt.formatStage(""));
}

// ================================================================
// Section 25: i18n -- locale with all plural features (Spanish)
// ================================================================
// 25.1-25.12 (formatAge)
unittest {
    auto pt = SayableAge(ES);
    assertAge("25.1 justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "Reci\u00e9n nacido");
    assertAge("25.2 singular day", pt.formatAge("2025-06-14", "2025-06-15"), "1 d\u00eda");
    assertAge("25.3 plural days", pt.formatAge("2025-06-12", "2025-06-15"), "3 d\u00edas");
    assertAge("25.4 singular week", pt.formatAge("2025-06-08", "2025-06-15"), "1 semana");
    assertAge("25.5 compound", pt.formatAge("2025-06-07", "2025-06-15"), "1 semana, 1 d\u00eda");
    assertAge("25.6 plural compound", pt.formatAge("2025-05-26", "2025-06-15"), "2 semanas, 6 d\u00edas");
    assertAge("25.7 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 meses");
    assertAge("25.8 singular month", pt.formatAge("2023-06-15", "2025-07-15"), "2 a\u00f1os, 1 mes");
    assertAge("25.9 years+months", pt.formatAge("2023-06-15", "2025-12-15"), "2 a\u00f1os, 6 meses");
    assertAge("25.10 half marker", pt.formatAge("2022-06-15", "2025-12-15"), "3 a\u00f1os y medio");
    assertAge("25.11 no half", pt.formatAge("2022-06-15", "2025-06-15"), "3 a\u00f1os");
    assertAge("25.12 7+ years", pt.formatAge("2018-06-15", "2025-06-15"), "7 a\u00f1os");
}

// 25.13-25.18 (formatStage)
unittest {
    auto pt = SayableAge(ES);
    assertAge("25.13 stage newborn", pt.formatStage("2025-06-15", "2025-06-15"), "Reci\u00e9n nacido");
    assertAge("25.14 stage infant", pt.formatStage("2025-01-15", "2025-06-15"), "Beb\u00e9");
    assertAge("25.15 stage toddler", pt.formatStage("2024-06-15", "2025-06-15"), "Ni\u00f1o peque\u00f1o");
    assertAge("25.16 stage child", pt.formatStage("2022-06-15", "2025-06-15"), "Ni\u00f1o");
    assertAge("25.17 stage teenager", pt.formatStage("2012-06-15", "2025-06-15"), "Adolescente");
    assertAge("25.18 stage adult", pt.formatStage("2007-06-15", "2025-06-15"), "Adulto");
}

// 25.19-25.20 (null handling)
unittest {
    auto pt = SayableAge(ES);
    assertNull("25.19 null", pt.formatAge(""));
    assertNull("25.20 null stage", pt.formatStage(""));
}

// ================================================================
// Section 26: Compactness -- short
// ================================================================
unittest {
    auto pt = SayableAge(EN, Compactness.short_);
    assertAge("26.1 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 d");
    assertAge("26.2 weeks", pt.formatAge("2025-06-08", "2025-06-15"), "1 wk");
    assertAge("26.3 weeks+days", pt.formatAge("2025-06-07", "2025-06-15"), "1 wk, 1 d");
    assertAge("26.4 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 mo");
    assertAge("26.5 years+months", pt.formatAge("2023-06-15", "2025-07-15"), "2 yr, 1 mo");
    assertAge("26.6 half years", pt.formatAge("2022-06-15", "2025-12-15"), "3\u00BD yr");
    assertAge("26.7 integer years", pt.formatAge("2018-06-15", "2025-06-15"), "7 yr");
    assertAge("26.8 justBorn unchanged", pt.formatAge("2025-06-15", "2025-06-15"), "Newborn");
    assertAge("26.9 stages unchanged", pt.formatStage("2025-01-15", "2025-06-15"), "Infant");
}

// ================================================================
// Section 27: Compactness -- compact
// ================================================================
unittest {
    auto pt = SayableAge(EN, Compactness.compact);
    assertAge("27.1 days", pt.formatAge("2025-06-12", "2025-06-15"), "3d");
    assertAge("27.2 weeks", pt.formatAge("2025-06-08", "2025-06-15"), "1w");
    assertAge("27.3 weeks+days no delimiter", pt.formatAge("2025-06-07", "2025-06-15"), "1w1d");
    assertAge("27.4 months", pt.formatAge("2025-01-15", "2025-07-15"), "6m");
    assertAge("27.5 years+months no delimiter", pt.formatAge("2023-06-15", "2025-07-15"), "2y1m");
    assertAge("27.6 half years", pt.formatAge("2022-06-15", "2025-12-15"), "3\u00BDy");
    assertAge("27.7 integer years", pt.formatAge("2018-06-15", "2025-06-15"), "7y");
    assertAge("27.8 justBorn unchanged", pt.formatAge("2025-06-15", "2025-06-15"), "Newborn");
}

// ================================================================
// Section 28: formatStage -- gender support
// ================================================================
// Gender-neutral locale (English)
unittest {
    auto pt = SayableAge(EN);
    // EN has all neutral labels -- gender param should have no effect
    assertAge("28 en no gender", pt.formatStage("2025-06-15", "2025-06-15"), "Newborn");
    assertAge("28 en masculine", pt.formatStage("2025-06-15", "2025-06-15", "m"), "Newborn");
    assertAge("28 en feminine", pt.formatStage("2025-06-15", "2025-06-15", "f"), "Newborn");
    assertAge("28 en adult no gender", pt.formatStage("2007-06-15", "2025-06-15"), "Adult");
    assertAge("28 en adult m", pt.formatStage("2007-06-15", "2025-06-15", "m"), "Adult");
    assertAge("28 en adult f", pt.formatStage("2007-06-15", "2025-06-15", "f"), "Adult");
}

// Gendered locale (Spanish)
unittest {
    auto pt = SayableAge(ES);
    // Default (no gender) returns masculine for gendered labels
    assertAge("28 es newborn default", pt.formatStage("2025-06-15", "2025-06-15"), "Reci\u00e9n nacido");
    assertAge("28 es toddler default", pt.formatStage("2024-06-15", "2025-06-15"), "Ni\u00f1o peque\u00f1o");
    assertAge("28 es child default", pt.formatStage("2022-06-15", "2025-06-15"), "Ni\u00f1o");
    assertAge("28 es adult default", pt.formatStage("2007-06-15", "2025-06-15"), "Adulto");
    // Masculine
    assertAge("28 es newborn m", pt.formatStage("2025-06-15", "2025-06-15", "m"), "Reci\u00e9n nacido");
    assertAge("28 es toddler m", pt.formatStage("2024-06-15", "2025-06-15", "m"), "Ni\u00f1o peque\u00f1o");
    assertAge("28 es child m", pt.formatStage("2022-06-15", "2025-06-15", "m"), "Ni\u00f1o");
    assertAge("28 es adult m", pt.formatStage("2007-06-15", "2025-06-15", "m"), "Adulto");
    // Feminine
    assertAge("28 es newborn f", pt.formatStage("2025-06-15", "2025-06-15", "f"), "Reci\u00e9n nacida");
    assertAge("28 es toddler f", pt.formatStage("2024-06-15", "2025-06-15", "f"), "Ni\u00f1a peque\u00f1a");
    assertAge("28 es child f", pt.formatStage("2022-06-15", "2025-06-15", "f"), "Ni\u00f1a");
    assertAge("28 es adult f", pt.formatStage("2007-06-15", "2025-06-15", "f"), "Adulta");
    // Gender-neutral labels (S()) ignore gender
    assertAge("28 es infant neutral", pt.formatStage("2025-01-15", "2025-06-15"), "Beb\u00e9");
    assertAge("28 es infant m", pt.formatStage("2025-01-15", "2025-06-15", "m"), "Beb\u00e9");
    assertAge("28 es infant f", pt.formatStage("2025-01-15", "2025-06-15", "f"), "Beb\u00e9");
    assertAge("28 es teenager neutral", pt.formatStage("2012-06-15", "2025-06-15"), "Adolescente");
    assertAge("28 es teenager m", pt.formatStage("2012-06-15", "2025-06-15", "m"), "Adolescente");
    assertAge("28 es teenager f", pt.formatStage("2012-06-15", "2025-06-15", "f"), "Adolescente");
}

// Gendered locale (Arabic)
unittest {
    auto pt = SayableAge(AR);
    // All stages are gendered in Arabic
    assertAge("28 ar newborn m", pt.formatStage("2025-06-15", "2025-06-15", "m"), "\u062d\u062f\u064a\u062b \u0627\u0644\u0648\u0644\u0627\u062f\u0629");
    assertAge("28 ar newborn f", pt.formatStage("2025-06-15", "2025-06-15", "f"), "\u062d\u062f\u064a\u062b\u0629 \u0627\u0644\u0648\u0644\u0627\u062f\u0629");
    assertAge("28 ar infant m", pt.formatStage("2025-01-15", "2025-06-15", "m"), "\u0631\u0636\u064a\u0639");
    assertAge("28 ar infant f", pt.formatStage("2025-01-15", "2025-06-15", "f"), "\u0631\u0636\u064a\u0639\u0629");
    assertAge("28 ar toddler m", pt.formatStage("2024-06-15", "2025-06-15", "m"), "\u0637\u0641\u0644 \u0635\u063a\u064a\u0631");
    assertAge("28 ar toddler f", pt.formatStage("2024-06-15", "2025-06-15", "f"), "\u0637\u0641\u0644\u0629 \u0635\u063a\u064a\u0631\u0629");
    assertAge("28 ar child m", pt.formatStage("2022-06-15", "2025-06-15", "m"), "\u0637\u0641\u0644");
    assertAge("28 ar child f", pt.formatStage("2022-06-15", "2025-06-15", "f"), "\u0637\u0641\u0644\u0629");
    assertAge("28 ar teenager m", pt.formatStage("2012-06-15", "2025-06-15", "m"), "\u0645\u0631\u0627\u0647\u0642");
    assertAge("28 ar teenager f", pt.formatStage("2012-06-15", "2025-06-15", "f"), "\u0645\u0631\u0627\u0647\u0642\u0629");
    assertAge("28 ar adult m", pt.formatStage("2007-06-15", "2025-06-15", "m"), "\u0628\u0627\u0644\u063a");
    assertAge("28 ar adult f", pt.formatStage("2007-06-15", "2025-06-15", "f"), "\u0628\u0627\u0644\u063a\u0629");
}

// Gender edge cases
unittest {
    auto pt = SayableAge(ES);
    assertNull("28 empty dob", pt.formatStage(""));
    assertNull("28 empty dob with gender", pt.formatStage("", "", "f"));
    assertNull("28 future dob with gender", pt.formatStage("2025-07-01", "2025-06-15", "f"));
}

// ================================================================
// Section 29: Locale-specific edge cases -- plural rules
// ================================================================
// Hebrew
unittest {
    auto pt = SayableAge(HE);
    assertAge("29.1 he justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3");
    assertAge("29.2 he 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "\u05d9\u05d5\u05dd");
    assertAge("29.3 he 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 \u05d9\u05de\u05d9\u05dd");
    assertAge("29.4 he 2 weeks dual", pt.formatAge("2025-06-01", "2025-06-15"), "\u05e9\u05d1\u05d5\u05e2\u05d9\u05d9\u05dd");
    assertAge("29.5 he 3 weeks", pt.formatAge("2025-05-25", "2025-06-15"), "3 \u05e9\u05d1\u05d5\u05e2\u05d5\u05ea");
    assertAge("29.6 he 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 \u05d7\u05d5\u05d3\u05e9\u05d9\u05dd");
    assertAge("29.7 he 3 months", pt.formatAge("2025-03-15", "2025-06-15"), "3 \u05d7\u05d5\u05d3\u05e9\u05d9\u05dd");
    assertAge("29.8 he 2y1m", pt.formatAge("2023-06-15", "2025-07-15"), "\u05e9\u05e0\u05ea\u05d9\u05d9\u05dd, \u05d7\u05d5\u05d3\u05e9");
    assertAge("29.9 he 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3 \u05e9\u05e0\u05d9\u05dd \u05d5\u05d7\u05e6\u05d9");
    assertAge("29.10 he 7y", pt.formatAge("2018-06-15", "2025-06-15"), "7 \u05e9\u05e0\u05d9\u05dd");
    assertAge("29.11 he stage m newborn", pt.formatStage("2025-06-15", "2025-06-15", "m"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3");
    assertAge("29.12 he stage f newborn", pt.formatStage("2025-06-15", "2025-06-15", "f"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3\u05d4");
    assertAge("29.13 he stage m adult", pt.formatStage("2007-06-15", "2025-06-15", "m"), "\u05de\u05d1\u05d5\u05d2\u05e8");
    assertAge("29.14 he stage f adult", pt.formatStage("2007-06-15", "2025-06-15", "f"), "\u05de\u05d1\u05d5\u05d2\u05e8\u05ea");
}

// Macedonian
unittest {
    auto pt = SayableAge(MK);
    assertAge("29.15 mk justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "\u041d\u043e\u0432\u043e\u0440\u043e\u0434\u0435\u043d\u0447\u0435");
    assertAge("29.16 mk 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "1 \u0434\u0435\u043d");
    assertAge("29.17 mk 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 \u0434\u0435\u043d\u0430");
    assertAge("29.18 mk 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 \u043c\u0435\u0441\u0435\u0446\u0438");
    assertAge("29.19 mk 2y1m", pt.formatAge("2023-06-15", "2025-07-15"), "2 \u0433\u043e\u0434\u0438\u043d\u0438, 1 \u043c\u0435\u0441\u0435\u0446");
    assertAge("29.20 mk 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3 \u0433\u043e\u0434\u0438\u043d\u0438 \u0438 \u043f\u043e\u043b");
    assertAge("29.21 mk 7y", pt.formatAge("2018-06-15", "2025-06-15"), "7 \u0433\u043e\u0434\u0438\u043d\u0438");
}

// Swahili
unittest {
    auto pt = SayableAge(SW);
    assertAge("29.22 sw justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "Mzaliwa mpya");
    assertAge("29.23 sw 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "siku 1");
    assertAge("29.24 sw 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "siku 3");
    assertAge("29.25 sw 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "miezi 6");
    assertAge("29.26 sw 2y 1m", pt.formatAge("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1");
    assertAge("29.27 sw 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "miaka 3 na nusu");
}

// Indonesian
unittest {
    auto pt = SayableAge(ID);
    assertAge("29.28 id justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "Baru lahir");
    assertAge("29.29 id 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "1 hari");
    assertAge("29.30 id 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 hari");
    assertAge("29.31 id 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 bulan");
    assertAge("29.32 id 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3 setengah tahun");
    assertAge("29.33 id 7y", pt.formatAge("2018-06-15", "2025-06-15"), "7 tahun");
}

// Amharic
unittest {
    auto pt = SayableAge(AM);
    assertAge("29.34 am justBorn", pt.formatAge("2025-06-15", "2025-06-15"), "\u12a0\u12f2\u1235 \u12e8\u1270\u12c8\u1208\u12f0");
    assertAge("29.35 am 1 day", pt.formatAge("2025-06-14", "2025-06-15"), "1 \u1240\u1295");
    assertAge("29.36 am 3 days", pt.formatAge("2025-06-12", "2025-06-15"), "3 \u1240\u1293\u1275");
    assertAge("29.37 am 1w1d", pt.formatAge("2025-06-07", "2025-06-15"), "1 \u1233\u121d\u1295\u1275\u1363 1 \u1240\u1295");
    assertAge("29.38 am 6 months", pt.formatAge("2025-01-15", "2025-07-15"), "6 \u12c8\u122b\u1275");
    assertAge("29.39 am 3.5y", pt.formatAge("2022-06-15", "2025-12-15"), "3 \u12d3\u1218\u1273\u1275 \u1270\u12a9\u120d");
}

// ================================================================
// Section 30: Locale lookup by code string
// ================================================================
// 30.1
unittest {
    auto loc = getLocale("en");
    assert(loc !is null, "30.1 GetLocale(\"en\") returned null");
    assert(loc.code == "en", "30.1 GetLocale(\"en\").code != \"en\"");
}

// 30.2
unittest {
    auto loc = getLocale("fr");
    assert(loc !is null, "30.2 GetLocale(\"fr\") returned null");
    assert(loc.code == "fr", "30.2 GetLocale(\"fr\").code != \"fr\"");
}

// 30.3
unittest {
    assert(getLocale("xx") is null, "30.3 GetLocale(\"xx\") should be null");
}

// 30.4
unittest {
    assert(getLocale("") is null, "30.4 GetLocale(\"\") should be null");
}

// 30.5
unittest {
    assert(getLocale("EN") is null, "30.5 GetLocale(\"EN\") should be null (case-sensitive)");
}

// ================================================================
// Version constant
// ================================================================
unittest {
    assert(VERSION == "0.5.0", "Version should be 0.5.0");
}

// ================================================================
// ResolveStage direct tests
// ================================================================
unittest {
    auto neutral = stageNeutral("Newborn");
    assert(resolveStage(neutral, "") == "Newborn");
    assert(resolveStage(neutral, "m") == "Newborn");
    assert(resolveStage(neutral, "f") == "Newborn");

    auto gendered = stageGendered("Adulto", "Adulta");
    assert(resolveStage(gendered, "") == "Adulto");
    assert(resolveStage(gendered, "m") == "Adulto");
    assert(resolveStage(gendered, "f") == "Adulta");
}

// ================================================================
// Section 31: Weeks and days across month ends
// ================================================================
// 31.1
unittest {
    assertAge("31.1 88 days across a 28-day February", SayableAge(EN).formatAge("2016-12-31", "2017-03-29"), "12 weeks, 4 days");
}
// 31.2
unittest {
    assertAge("31.2 90 days across a year end into a leap year", SayableAge(EN).formatAge("1991-11-27", "1992-02-25"), "12 weeks, 6 days");
}
// 31.3
unittest {
    assertAge("31.3 33 days across a year end", SayableAge(EN).formatAge("2020-11-30", "2021-01-02"), "4 weeks, 5 days");
}
// 31.4
unittest {
    assertAge("31.4 Compact form of 31.1", SayableAge(EN, Compactness.compact).formatAge("2016-12-31", "2017-03-29"), "12w4d");
}

// ================================================================
// Section 32: Half years take their plural form from whole years
// ================================================================
// 32.1
unittest {
    assertAge("32.1 Polish 3 is 'few'", SayableAge(PL).formatAge("2021-06-15", "2025-01-15"), "3 i pół lata");
}
// 32.2
unittest {
    assertAge("32.2 Polish 5 is 'many'", SayableAge(PL, Compactness.short_).formatAge("2020-06-15", "2025-12-15"), "5 i pół lat");
}
// 32.3
unittest {
    assertAge("32.3 Tachelhit 6 is 'few'", SayableAge(SHI).formatAge("2005-06-08", "2012-06-07"), "6 \u2d49\u2d59\u2d33\u2d33\u2d6f\u2d30\u2d59\u2d4f \u2d37 \u2d53\u2d63\u2d33\u2d4f");
}

// ================================================================
// Section 33: Input validation
// ================================================================
// 33.1
unittest {
    assertNull("33.1 February 30 doesn't exist", SayableAge(EN).formatAge("2025-02-30", "2032-06-25"));
}
// 33.2
unittest {
    assertNull("33.2 Month 13", SayableAge(EN).formatAge("2025-13-01", "2027-01-31"));
}
// 33.3
unittest {
    assertNull("33.3 February 29 in a non-leap year", SayableAge(EN).formatAge("2023-02-29", "2025-03-01"));
}
// 33.4
unittest {
    assertNull("33.4 Day 00", SayableAge(EN).formatAge("2025-06-00", "2027-02-25"));
}
// 33.5
unittest {
    assertNull("33.5 Unpadded month and day", SayableAge(EN).formatAge("2025-6-1", "2027-02-25"));
}
// 33.6
unittest {
    assertNull("33.6 Surrounding whitespace", SayableAge(EN).formatAge(" 2025-06-01", "2027-02-25"));
}
// 33.7
unittest {
    assertNull("33.7 A datetime is not a date", SayableAge(EN).formatAge("2025-06-15T10:00:00", "2027-02-25"));
}
// 33.8
unittest {
    assertNull("33.8 Invalid asOf", SayableAge(EN).formatAge("2020-01-01", "2025-04-31"));
}
// 33.9
unittest {
    assertNull("33.9 formatStage validates too", SayableAge(EN).formatStage("2025-02-30", "2027-09-05"));
}
// 33.10
unittest {
    assertAge("33.10 February 29 in a leap year is valid", SayableAge(EN).formatAge("2024-02-29", "2026-03-01"), "2 years");
}
