/// Tests for sayable-date D implementation.
/// All tests use explicit (date, asOf) pairs for determinism.
module sayabledate.test_format_date;

import std.typecons : Nullable;
import sayabledate.format_date : SayableDate, VERSION;
import sayabledate.locale;
import sayabledate.locales;

/// Helper to assert non-null string equals expected.
private void assertEq(string name, Nullable!string got, string want) {
    assert(!got.isNull, name ~ ": got null, want \"" ~ want ~ "\"");
    assert(got.get == want, name ~ ": got \"" ~ got.get ~ "\", want \"" ~ want ~ "\"");
}

/// Helper to assert null result.
private void assertNull(string name, Nullable!string got) {
    assert(got.isNull, name ~ ": got non-null, want null");
}

/// Create default English SayableDate.
private SayableDate en() {
    return SayableDate(EN);
}

/// Create English SayableDate with specified compactness.
private SayableDate enCompact(Compactness c) {
    return SayableDate(EN, c);
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================
// 1.1
unittest {
    auto sd = en();
    assertNull("1.1 null date", sd.formatDate(""));
}

// 1.2
unittest {
    auto sd = en();
    assertNull("1.2 empty string", sd.formatDate(""));
}

// 1.3
unittest {
    auto sd = en();
    assertNull("1.3 invalid date", sd.formatDate("invalid"));
}

// 1.4
unittest {
    auto sd = en();
    assertNull("1.4 null asOf", sd.formatRelative("2025-03-15", ""));
}

// 1.5
unittest {
    auto sd = en();
    assertNull("1.5 null date for relative", sd.formatRelative("", "2025-03-15"));
}

// ================================================================
// Section 2: format_date — normal compactness (English)
// ================================================================
// 2.1
unittest {
    auto sd = en();
    assertEq("2.1 Mar 15", sd.formatDate("2025-03-15"), "March 15th");
}

// 2.2
unittest {
    auto sd = en();
    assertEq("2.2 Jan 1", sd.formatDate("2025-01-01"), "January 1st");
}

// 2.3
unittest {
    auto sd = en();
    assertEq("2.3 May 22", sd.formatDate("2025-05-22"), "May 22nd");
}

// 2.4
unittest {
    auto sd = en();
    assertEq("2.4 Jul 3", sd.formatDate("2025-07-03"), "July 3rd");
}

// 2.5
unittest {
    auto sd = en();
    assertEq("2.5 Dec 31", sd.formatDate("2025-12-31"), "December 31st");
}

// 2.6
unittest {
    auto sd = en();
    assertEq("2.6 Jun 11 (no exception)", sd.formatDate("2025-06-11"), "June 11th");
}

// 2.7
unittest {
    auto sd = en();
    assertEq("2.7 ISO datetime input", sd.formatDate("2025-03-15T14:30:00"), "March 15th");
}

// ================================================================
// Section 3: format_date — short compactness (English)
// ================================================================
// 3.1
unittest {
    auto sd = enCompact(Compactness.short_);
    assertEq("3.1 short Mar 15", sd.formatDate("2025-03-15"), "Mar 15");
}

// 3.2
unittest {
    auto sd = enCompact(Compactness.short_);
    assertEq("3.2 short Jan 1", sd.formatDate("2025-01-01"), "Jan 1");
}

// 3.3
unittest {
    auto sd = enCompact(Compactness.short_);
    assertEq("3.3 short Dec 25", sd.formatDate("2025-12-25"), "Dec 25");
}

// ================================================================
// Section 4: format_date — compact (English)
// ================================================================
// 4.1
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("4.1 compact Mar 15", sd.formatDate("2025-03-15"), "3/15");
}

// 4.2
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("4.2 compact Jan 1", sd.formatDate("2025-01-01"), "1/1");
}

// ================================================================
// Section 5: format_relative — proximity tiers (English)
// ================================================================
// 5.1
unittest {
    auto sd = en();
    assertEq("5.1 today", sd.formatRelative("2025-03-15", "2025-03-15"), "today");
}

// 5.2
unittest {
    auto sd = en();
    assertEq("5.2 tomorrow", sd.formatRelative("2025-03-16", "2025-03-15"), "tomorrow");
}

// 5.3
unittest {
    auto sd = en();
    assertEq("5.3 yesterday", sd.formatRelative("2025-03-14", "2025-03-15"), "yesterday");
}

// 5.4
unittest {
    auto sd = en();
    assertEq("5.4 day after tomorrow", sd.formatRelative("2025-03-17", "2025-03-15"), "the day after tomorrow");
}

// 5.5
unittest {
    auto sd = en();
    assertEq("5.5 day before yesterday", sd.formatRelative("2025-03-13", "2025-03-15"), "the day before yesterday");
}

// 5.6
unittest {
    auto sd = en();
    assertEq("5.6 this Wednesday", sd.formatRelative("2025-03-19", "2025-03-15"), "this Wednesday");
}

// 5.7
unittest {
    auto sd = en();
    assertEq("5.7 this Thursday", sd.formatRelative("2025-03-20", "2025-03-15"), "this Thursday");
}

// 5.8
unittest {
    auto sd = en();
    assertEq("5.8 last Tuesday", sd.formatRelative("2025-03-11", "2025-03-15"), "last Tuesday");
}

// 5.9
unittest {
    auto sd = en();
    assertEq("5.9 next Saturday", sd.formatRelative("2025-03-22", "2025-03-15"), "next Saturday");
}

// 5.10
unittest {
    auto sd = en();
    assertEq("5.10 next Thursday", sd.formatRelative("2025-03-27", "2025-03-15"), "next Thursday");
}

// 5.11
unittest {
    auto sd = en();
    assertEq("5.11 calendar fallback same year", sd.formatRelative("2025-03-01", "2025-03-15"), "March 1st");
}

// 5.12
unittest {
    auto sd = en();
    assertEq("5.12 calendar fallback same year (+26)", sd.formatRelative("2025-04-10", "2025-03-15"), "April 10th");
}

// 5.13
unittest {
    auto sd = en();
    assertEq("5.13 different year", sd.formatRelative("2026-01-05", "2025-03-15"), "January 5th, 2026");
}

// 5.14
unittest {
    auto sd = en();
    assertEq("5.14 past year", sd.formatRelative("2024-12-25", "2025-03-15"), "December 25th, 2024");
}

// ================================================================
// Section 6: format_relative — compact skips weekday tiers
// ================================================================
// 6.1
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("6.1 compact today", sd.formatRelative("2025-03-15", "2025-03-15"), "today");
}

// 6.2
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("6.2 compact tomorrow", sd.formatRelative("2025-03-16", "2025-03-15"), "tomorrow");
}

// 6.3
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("6.3 compact numeric", sd.formatRelative("2025-03-19", "2025-03-15"), "3/19");
}

// 6.4
unittest {
    auto sd = enCompact(Compactness.compact);
    assertEq("6.4 compact different year", sd.formatRelative("2026-01-05", "2025-03-15"), "1/5/26");
}

// ================================================================
// Section 7: Locale — German
// ================================================================
// 7.1
unittest {
    auto sd = SayableDate(DE);
    assertEq("7.1 German date", sd.formatDate("2025-03-15"), "15. März");
}

// 7.2
unittest {
    auto sd = SayableDate(DE);
    assertEq("7.2 German morgen", sd.formatRelative("2025-03-16", "2025-03-15"), "morgen");
}

// 7.3
unittest {
    auto sd = SayableDate(DE);
    assertEq("7.3 German übermorgen", sd.formatRelative("2025-03-17", "2025-03-15"), "übermorgen");
}

// 7.4
unittest {
    auto sd = SayableDate(DE);
    assertEq("7.4 German this Wednesday", sd.formatRelative("2025-03-19", "2025-03-15"), "diesen Mittwoch");
}

// ================================================================
// Section 8: Locale — French
// ================================================================
// 8.1
unittest {
    auto sd = SayableDate(FR);
    assertEq("8.1 French 1er", sd.formatDate("2025-03-01"), "1er mars");
}

// 8.2
unittest {
    auto sd = SayableDate(FR);
    assertEq("8.2 French 15", sd.formatDate("2025-03-15"), "15 mars");
}

// 8.3
unittest {
    auto sd = SayableDate(FR);
    assertEq("8.3 French demain", sd.formatRelative("2025-03-16", "2025-03-15"), "demain");
}

// ================================================================
// Section 9: Locale — Japanese
// ================================================================
// 9.1
unittest {
    auto sd = SayableDate(JA);
    assertEq("9.1 Japanese date", sd.formatDate("2025-03-15"), "3月15日");
}

// 9.2
unittest {
    auto sd = SayableDate(JA);
    assertEq("9.2 Japanese tomorrow", sd.formatRelative("2025-03-16", "2025-03-15"), "明日");
}

// 9.3
unittest {
    auto sd = SayableDate(JA);
    assertEq("9.3 Japanese this Wednesday", sd.formatRelative("2025-03-19", "2025-03-15"), "今度の水曜日");
}

// ================================================================
// Section 10: Locale — Russian (genitive months)
// ================================================================
// 10.1
unittest {
    auto sd = SayableDate(RU);
    assertEq("10.1 Russian genitive", sd.formatDate("2025-03-15"), "15 марта");
}

// 10.2
unittest {
    auto sd = SayableDate(RU);
    assertEq("10.2 Russian tomorrow", sd.formatRelative("2025-03-16", "2025-03-15"), "завтра");
}

// ================================================================
// Section 11: Locale — Arabic
// ================================================================
// 11.1
unittest {
    auto sd = SayableDate(AR);
    assertEq("11.1 Arabic date", sd.formatDate("2025-03-15"), "15 مارس");
}

// 11.2
unittest {
    auto sd = SayableDate(AR);
    assertEq("11.2 Arabic tomorrow", sd.formatRelative("2025-03-16", "2025-03-15"), "غداً");
}

// ================================================================
// Section 12: Locale — Spanish
// ================================================================
// 12.1
unittest {
    auto sd = SayableDate(ES);
    assertEq("12.1 Spanish date", sd.formatDate("2025-03-15"), "15 de marzo");
}

// 12.2
unittest {
    auto sd = SayableDate(ES);
    assertEq("12.2 Spanish pasado mañana", sd.formatRelative("2025-03-17", "2025-03-15"), "pasado mañana");
}

// ================================================================
// Version test
// ================================================================
unittest {
    assert(VERSION == "0.5.0", "Version mismatch");
}
