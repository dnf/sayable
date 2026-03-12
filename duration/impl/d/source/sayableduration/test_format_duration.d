/// Tests for sayable-duration D implementation.
/// All tests use explicit inputs for determinism.
module sayableduration.test_format_duration;

import std.typecons : Nullable;
import sayableduration.format_duration : SayableDuration, VERSION;
import sayableduration.locale;
import sayableduration.locales;

/// Helper to assert non-null string equals expected.
private void assertEq(string name, Nullable!string got, string want) {
    assert(!got.isNull, name ~ ": got null, want \"" ~ want ~ "\"");
    assert(got.get == want, name ~ ": got \"" ~ got.get ~ "\", want \"" ~ want ~ "\"");
}

/// Helper to assert null result.
private void assertNull(string name, Nullable!string got) {
    assert(got.isNull, name ~ ": got non-null, want null");
}

/// Create default English SayableDuration.
private SayableDuration en() {
    return SayableDuration(EN);
}

/// Create English SayableDuration with specified compactness.
private SayableDuration enCompact(Compactness c) {
    return SayableDuration(EN, c);
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================
// 1.1
unittest {
    auto sd = en();
    // null seconds — pass negative as proxy for null
    assertNull("1.1 null seconds", sd.formatDuration(-999));
}

// 1.2
unittest {
    auto sd = en();
    assertNull("1.2 negative seconds", sd.formatDuration(-1));
}

// 1.3
unittest {
    auto sd = en();
    assertNull("1.3 null start", sd.formatSince("", "2025-01-15T10:00:00"));
}

// 1.4
unittest {
    auto sd = en();
    assertNull("1.4 null target", sd.formatUntil("", "2025-01-15T10:00:00"));
}

// 1.5
unittest {
    auto sd = en();
    assertNull("1.5 asOf before start", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"));
}

// 1.6
unittest {
    auto sd = en();
    assertNull("1.6 target in past", sd.formatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"));
}

// ================================================================
// Section 2: Duration — seconds tier (0-59s)
// ================================================================
// 2.1
unittest {
    auto sd = en();
    assertEq("2.1 zero seconds", sd.formatDuration(0), "just now");
}

// 2.2
unittest {
    auto sd = en();
    assertEq("2.2 one second", sd.formatDuration(1), "1 second");
}

// 2.3
unittest {
    auto sd = en();
    assertEq("2.3 45 seconds", sd.formatDuration(45), "45 seconds");
}

// 2.4
unittest {
    auto sd = en();
    assertEq("2.4 59 seconds", sd.formatDuration(59), "59 seconds");
}

// ================================================================
// Section 3: Duration — minutes + seconds tier (1-4 min)
// ================================================================
// 3.1
unittest {
    auto sd = en();
    assertEq("3.1 1 minute", sd.formatDuration(60), "1 minute");
}

// 3.2
unittest {
    auto sd = en();
    assertEq("3.2 1 min 30 sec", sd.formatDuration(90), "1 minute, 30 seconds");
}

// 3.3
unittest {
    auto sd = en();
    assertEq("3.3 4 minutes", sd.formatDuration(240), "4 minutes");
}

// 3.4
unittest {
    auto sd = en();
    assertEq("3.4 4 min 30 sec", sd.formatDuration(270), "4 minutes, 30 seconds");
}

// ================================================================
// Section 4: Duration — minutes tier (5-59 min)
// ================================================================
// 4.1
unittest {
    auto sd = en();
    assertEq("4.1 5 minutes", sd.formatDuration(300), "5 minutes");
}

// 4.2
unittest {
    auto sd = en();
    assertEq("4.2 25 minutes", sd.formatDuration(1500), "25 minutes");
}

// 4.3
unittest {
    auto sd = en();
    assertEq("4.3 59 minutes", sd.formatDuration(3540), "59 minutes");
}

// ================================================================
// Section 5: Duration — hours + minutes tier (1-5 hr)
// ================================================================
// 5.1
unittest {
    auto sd = en();
    assertEq("5.1 1 hour", sd.formatDuration(3600), "1 hour");
}

// 5.2
unittest {
    auto sd = en();
    assertEq("5.2 1.5 hours (half)", sd.formatDuration(5400), "1½ hours");
}

// 5.3
unittest {
    auto sd = en();
    assertEq("5.3 2 hr 15 min", sd.formatDuration(8100), "2 hours, 15 minutes");
}

// 5.4
unittest {
    auto sd = en();
    assertEq("5.4 5 hours", sd.formatDuration(18000), "5 hours");
}

// ================================================================
// Section 6: Duration — hours tier (6-23 hr)
// ================================================================
// 6.1
unittest {
    auto sd = en();
    assertEq("6.1 8 hours", sd.formatDuration(28800), "8 hours");
}

// 6.2
unittest {
    auto sd = en();
    assertEq("6.2 23 hours", sd.formatDuration(82800), "23 hours");
}

// ================================================================
// Section 7: Duration — days tier
// ================================================================
// 7.1
unittest {
    auto sd = en();
    assertEq("7.1 1 day", sd.formatDuration(86400), "1 day");
}

// 7.2
unittest {
    auto sd = en();
    assertEq("7.2 1 day 3 hours", sd.formatDuration(97200), "1 day, 3 hours");
}

// 7.3
unittest {
    auto sd = en();
    assertEq("7.3 1.5 days (half)", sd.formatDuration(129600), "1½ days");
}

// 7.4
unittest {
    auto sd = en();
    assertEq("7.4 5 days", sd.formatDuration(432000), "5 days");
}

// 7.5
unittest {
    auto sd = en();
    assertEq("7.5 2 days", sd.formatDuration(172800), "2 days");
}

// ================================================================
// Section 8: Duration — weeks tier
// ================================================================
// 8.1
unittest {
    auto sd = en();
    assertEq("8.1 1 week", sd.formatDuration(604800), "1 week");
}

// 8.2
unittest {
    auto sd = en();
    assertEq("8.2 2 weeks 1 day", sd.formatDuration(1296000), "2 weeks, 1 day");
}

// 8.3
unittest {
    auto sd = en();
    assertEq("8.3 4 weeks", sd.formatDuration(2419200), "4 weeks");
}

// ================================================================
// Section 9: Duration — months and years tier
// ================================================================
// 9.1
unittest {
    auto sd = en();
    assertEq("9.1 1 month", sd.formatDuration(2678400), "1 month");
}

// 9.2
unittest {
    auto sd = en();
    assertEq("9.2 3 months", sd.formatDuration(7884000), "3 months");
}

// 9.3
unittest {
    auto sd = en();
    assertEq("9.3 1 year", sd.formatDuration(31536000), "1 year");
}

// 9.4
unittest {
    auto sd = en();
    assertEq("9.4 1 year 3 months", sd.formatDuration(39420000), "1 year, 3 months");
}

// ================================================================
// Section 10: Duration from ISO timestamps
// ================================================================
// 10.1
unittest {
    auto sd = en();
    assertEq("10.1 ISO 1.5h", sd.formatDurationISO("2025-01-15T10:00:00", "2025-01-15T11:30:00"), "1½ hours");
}

// 10.2
unittest {
    auto sd = en();
    assertEq("10.2 ISO 45min", sd.formatDurationISO("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes");
}

// ================================================================
// Section 11: Relative time — since
// ================================================================
// 11.1
unittest {
    auto sd = en();
    assertEq("11.1 since just now", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now");
}

// 11.2
unittest {
    auto sd = en();
    assertEq("11.2 since 30s ago", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30"), "30 seconds ago");
}

// 11.3
unittest {
    auto sd = en();
    assertEq("11.3 since 45min ago", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes ago");
}

// 11.4
unittest {
    auto sd = en();
    assertEq("11.4 since 3h ago", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00"), "3 hours ago");
}

// ================================================================
// Section 12: Relative time — until
// ================================================================
// 12.1
unittest {
    auto sd = en();
    assertEq("12.1 until just now", sd.formatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now");
}

// 12.2
unittest {
    auto sd = en();
    assertEq("12.2 in 20 minutes", sd.formatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00"), "in 20 minutes");
}

// 12.3
unittest {
    auto sd = en();
    assertEq("12.3 in 3 hours", sd.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00"), "in 3 hours");
}

// ================================================================
// Section 13: Locale — German
// ================================================================
// 13.1
unittest {
    auto sd = SayableDuration(DE);
    assertEq("13.1 German 1 hour", sd.formatDuration(3600), "1 Stunde");
}

// 13.2
unittest {
    auto sd = SayableDuration(DE);
    assertEq("13.2 German ago", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00"), "vor 5 Minuten");
}

// ================================================================
// Section 14: Locale — French
// ================================================================
// 14.1
unittest {
    auto sd = SayableDuration(FR);
    assertEq("14.1 French 2 hours", sd.formatDuration(7200), "2 heures");
}

// ================================================================
// Section 15: Locale — Japanese
// ================================================================
// 15.1
unittest {
    auto sd = SayableDuration(JA);
    assertEq("15.1 Japanese 2min", sd.formatDuration(120), "2分");
}

// 15.2
unittest {
    auto sd = SayableDuration(JA);
    assertEq("15.2 Japanese 1h ago", sd.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00"), "1時間前");
}

// ================================================================
// Section 16: Short compactness — duration
// ================================================================
// 16.1
unittest {
    auto sd = enCompact(Compactness.short_);
    assertEq("16.1 short 1h", sd.formatDuration(3600), "1h");
}

// 16.2
unittest {
    auto sd = enCompact(Compactness.short_);
    assertEq("16.2 short 1m 30s", sd.formatDuration(90), "1m, 30s");
}

// ================================================================
// Section 17: Compact compactness — duration
// ================================================================
// 17.1
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("17.1 compact 1h", sd.formatDuration(3600), "1h");
}

// 17.2
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("17.2 compact 1m30s", sd.formatDuration(90), "1m30s");
}

// ================================================================
// Version test
// ================================================================
unittest {
    assert(VERSION == "0.5.0", "Version mismatch");
}
