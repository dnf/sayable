/// Tests for sayable-time D implementation.
/// All tests use explicit inputs for determinism.
module sayabletime.test_format_time;

import std.typecons : Nullable;
import sayabletime.format_time : SayableTime, VERSION;
import sayabletime.locale;
import sayabletime.locales;

/// Helper to assert non-null string equals expected.
private void assertEq(string name, Nullable!string got, string want) {
    assert(!got.isNull, name ~ ": got null, want \"" ~ want ~ "\"");
    assert(got.get == want, name ~ ": got \"" ~ got.get ~ "\", want \"" ~ want ~ "\"");
}

/// Helper to assert null result.
private void assertNull(string name, Nullable!string got) {
    assert(got.isNull, name ~ ": got non-null, want null");
}

/// Create default English SayableTime.
private SayableTime en() {
    return SayableTime(EN);
}

/// Create English SayableTime with specified compactness.
private SayableTime enCompact(Compactness c) {
    return SayableTime(EN, c);
}

// ================================================================
// Section 1: Null / edge cases
// ================================================================
// 1.1
unittest {
    auto st = en();
    assertNull("1.1 null time", st.formatTime(""));
}

// 1.2
unittest {
    auto st = en();
    assertNull("1.2 empty string", st.formatTime(""));
}

// 1.3
unittest {
    auto st = en();
    assertNull("1.3 invalid time", st.formatTime("invalid"));
}

// 1.4
unittest {
    auto st = en();
    assertNull("1.4 invalid hour", st.formatTime("25:00"));
}

// ================================================================
// Section 2: Clock time (normal compactness)
// ================================================================
// 2.1
unittest {
    auto st = en();
    assertEq("2.1 midnight", st.formatTime("00:00"), "midnight");
}

// 2.2
unittest {
    auto st = en();
    assertEq("2.2 noon", st.formatTime("12:00"), "noon");
}

// 2.3
unittest {
    auto st = en();
    assertEq("2.3 three o'clock", st.formatTime("15:00"), "three o'clock");
}

// 2.4
unittest {
    auto st = en();
    assertEq("2.4 quarter past two", st.formatTime("14:15"), "a quarter past two");
}

// 2.5
unittest {
    auto st = en();
    assertEq("2.5 half past nine", st.formatTime("09:30"), "half past nine");
}

// 2.6
unittest {
    auto st = en();
    assertEq("2.6 quarter to eleven", st.formatTime("10:45"), "a quarter to eleven");
}

// 2.7
unittest {
    auto st = en();
    assertEq("2.7 five past eight", st.formatTime("08:05"), "five past eight");
}

// 2.8
unittest {
    auto st = en();
    assertEq("2.8 five to five", st.formatTime("16:55"), "five to five");
}

// 2.9
unittest {
    auto st = en();
    assertEq("2.9 23:58 rounds to midnight", st.formatTime("23:58"), "midnight");
}

// 2.10
unittest {
    auto st = en();
    assertEq("2.10 22 rounds to 20", st.formatTime("07:22"), "twenty past seven");
}

// 2.11
unittest {
    auto st = en();
    assertEq("2.11 ISO datetime input", st.formatTime("2025-01-15T14:15:00"), "a quarter past two");
}

// ================================================================
// Section 3: Clock time (short compactness)
// ================================================================
// 3.1
unittest {
    auto st = enCompact(Compactness.short_);
    assertEq("3.1 short 2:15 PM", st.formatTime("14:15"), "2:15 PM");
}

// 3.2
unittest {
    auto st = enCompact(Compactness.short_);
    assertEq("3.2 short 9:30 AM", st.formatTime("09:30"), "9:30 AM");
}

// 3.3
unittest {
    auto st = enCompact(Compactness.short_);
    assertEq("3.3 short midnight", st.formatTime("00:00"), "12:00 AM");
}

// 3.4
unittest {
    auto st = enCompact(Compactness.short_);
    assertEq("3.4 short noon", st.formatTime("12:00"), "12:00 PM");
}

// ================================================================
// Section 4: Clock time (compact)
// ================================================================
// 4.1
unittest {
    auto st = enCompact(Compactness.compact);
    assertEq("4.1 compact 2:15p", st.formatTime("14:15"), "2:15p");
}

// 4.2
unittest {
    auto st = enCompact(Compactness.compact);
    assertEq("4.2 compact 9:30a", st.formatTime("09:30"), "9:30a");
}

// ================================================================
// Section 5: Locale — German
// ================================================================
// 5.1
unittest {
    auto st = SayableTime(DE);
    assertEq("5.1 German half past three", st.formatTime("15:30"), "halb vier");
}

// ================================================================
// Section 6: Locale — French
// ================================================================
// 6.1
unittest {
    auto st = SayableTime(FR);
    assertEq("6.1 French quarter past three", st.formatTime("15:15"), "trois heures et quart");
}

// ================================================================
// Section 7: Locale — Japanese
// ================================================================
// 7.1
unittest {
    auto st = SayableTime(JA);
    assertEq("7.1 Japanese half past three", st.formatTime("15:30"), "三時半");
}

// ================================================================
// Section 8: Locale — Finnish (dot separator, short)
// ================================================================
// 8.1
unittest {
    auto st = SayableTime(FI, Compactness.short_);
    assertEq("8.1 Finnish dot 14.15", st.formatTime("14:15"), "14.15");
}

// 8.2
unittest {
    auto st = SayableTime(FI, Compactness.short_);
    assertEq("8.2 Finnish midnight dot", st.formatTime("00:00"), "0.00");
}

// ================================================================
// Version test
// ================================================================
unittest {
    assert(VERSION == "0.5.0", "Version mismatch");
}

// ================================================================
// Section 9: Minutes in short and compact modes
// ================================================================
// 9.1
unittest {
    assertEq("9.1 digital modes keep the exact minute", SayableTime(EN, Compactness.short_).formatTime("18:01"), "6:01 PM");
}
// 9.2
unittest {
    assertEq("9.2 digital modes keep the exact minute", SayableTime(EN, Compactness.compact).formatTime("19:05"), "7:05p");
}

// ================================================================
// Section 10: Input validation
// ================================================================
// 10.1
unittest {
    assertEq("10.1 one-digit hour", SayableTime(EN).formatTime("9:30"), "half past nine");
}
// 10.2
unittest {
    assertEq("10.2 two-digit hour", SayableTime(EN).formatTime("09:30"), "half past nine");
}
// 10.3
unittest {
    assertNull("10.3 leading whitespace", SayableTime(EN).formatTime(" 9:30"));
}
// 10.4
unittest {
    assertNull("10.4 trailing whitespace", SayableTime(EN).formatTime("9:30 "));
}
// 10.5
unittest {
    assertNull("10.5 minutes need two digits", SayableTime(EN).formatTime("9:5"));
}
// 10.6
unittest {
    assertNull("10.6 hour out of range", SayableTime(EN).formatTime("24:00"));
}
// 10.7
unittest {
    assertEq("10.7 seconds are allowed and ignored", SayableTime(EN).formatTime("14:15:30"), "a quarter past two");
}
// 10.8
unittest {
    assertEq("10.8 ISO datetime with zone suffix (ignored)", SayableTime(EN).formatTime("2025-01-15T14:15:00Z"), "a quarter past two");
}
// 10.9
unittest {
    assertNull("10.9 ISO datetime with an impossible date", SayableTime(EN).formatTime("2025-02-30T14:15:00"));
}
