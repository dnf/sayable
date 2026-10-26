#include "sayabletime/sayabletime.hpp"
#include "sayabletime/locales/locales.hpp"

#include <iostream>
#include <optional>
#include <string>

static int tests_passed = 0;
static int tests_failed = 0;

#define ASSERT_EQ(name, got, expected) do { \
    auto _got = (got); \
    std::string _exp = (expected); \
    if (!_got.has_value()) { \
        std::cerr << "FAIL [" << (name) << "]: got nullopt, expected \"" << _exp << "\"" << std::endl; \
        tests_failed++; \
    } else if (_got.value() != _exp) { \
        std::cerr << "FAIL [" << (name) << "]: got \"" << _got.value() << "\", expected \"" << _exp << "\"" << std::endl; \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

#define ASSERT_NULL(name, got) do { \
    auto _got = (got); \
    if (_got.has_value()) { \
        std::cerr << "FAIL [" << (name) << "]: got \"" << _got.value() << "\", expected nullopt" << std::endl; \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

using namespace sayabletime;

// ================================================================
// 1. Null / edge cases
// ================================================================
void test_null_edge_cases() {
    // 1.1 null input — C++ uses empty string for null
    ASSERT_NULL("1.1 null", format_time(""));
    // 1.2 empty string
    ASSERT_NULL("1.2 empty", format_time(""));
    // 1.3 invalid format
    ASSERT_NULL("1.3 invalid", format_time("invalid"));
    // 1.4 out of range
    ASSERT_NULL("1.4 out of range", format_time("25:00"));
}

// ================================================================
// 2. Clock time (normal compactness)
// ================================================================
void test_normal_clock_time() {
    // 2.1 midnight
    ASSERT_EQ("2.1 midnight", format_time("00:00"), "midnight");
    // 2.2 noon
    ASSERT_EQ("2.2 noon", format_time("12:00"), "noon");
    // 2.3 o'clock
    ASSERT_EQ("2.3 o'clock", format_time("15:00"), "three o'clock");
    // 2.4 quarter past
    ASSERT_EQ("2.4 quarter past", format_time("14:15"), "a quarter past two");
    // 2.5 half past
    ASSERT_EQ("2.5 half past", format_time("09:30"), "half past nine");
    // 2.6 quarter to
    ASSERT_EQ("2.6 quarter to", format_time("10:45"), "a quarter to eleven");
    // 2.7 five past
    ASSERT_EQ("2.7 five past", format_time("08:05"), "five past eight");
    // 2.8 five to
    ASSERT_EQ("2.8 five to", format_time("16:55"), "five to five");
    // 2.9 rounds to midnight (23:58 -> 0:00)
    ASSERT_EQ("2.9 rounds to midnight", format_time("23:58"), "midnight");
    // 2.10 22 rounds to 20
    ASSERT_EQ("2.10 rounding", format_time("07:22"), "twenty past seven");
    // 2.11 ISO datetime input
    ASSERT_EQ("2.11 ISO datetime", format_time("2025-01-15T14:15:00"), "a quarter past two");
}

// ================================================================
// 3. Clock time (short compactness)
// ================================================================
void test_short_compactness() {
    SayableTime st(locales::EN(), Compactness::Short);
    // 3.1
    ASSERT_EQ("3.1 short 14:15", st.format_time("14:15"), "2:15 PM");
    // 3.2
    ASSERT_EQ("3.2 short 09:30", st.format_time("09:30"), "9:30 AM");
    // 3.3
    ASSERT_EQ("3.3 short 00:00", st.format_time("00:00"), "12:00 AM");
    // 3.4
    ASSERT_EQ("3.4 short 12:00", st.format_time("12:00"), "12:00 PM");
}

// ================================================================
// 4. Clock time (compact)
// ================================================================
void test_compact_compactness() {
    SayableTime st(locales::EN(), Compactness::Compact);
    // 4.1
    ASSERT_EQ("4.1 compact 14:15", st.format_time("14:15"), "2:15p");
    // 4.2
    ASSERT_EQ("4.2 compact 09:30", st.format_time("09:30"), "9:30a");
}

// ================================================================
// 5. Locale — German
// ================================================================
void test_german_locale() {
    SayableTime st(locales::DE());
    // 5.1 German half-to pattern
    ASSERT_EQ("5.1 de 15:30", st.format_time("15:30"), "halb vier");
}

// ================================================================
// 6. Locale — French
// ================================================================
void test_french_locale() {
    SayableTime st(locales::FR());
    // 6.1
    ASSERT_EQ("6.1 fr 15:15", st.format_time("15:15"), "trois heures et quart");
    // 6.2
    ASSERT_EQ("6.2 fr 13:00", st.format_time("13:00"), "une heure");
    // 6.3
    ASSERT_EQ("6.3 fr 13:30", st.format_time("13:30"), "une heure et demie");
    // 6.4
    ASSERT_EQ("6.4 fr 14:45", st.format_time("14:45"), "trois heures moins le quart");
    // 6.5
    ASSERT_EQ("6.5 fr 14:50", st.format_time("14:50"), "trois heures moins dix");
}

// ================================================================
// 7. Locale — Japanese
// ================================================================
void test_japanese_locale() {
    SayableTime st(locales::JA());
    // 7.1
    ASSERT_EQ("7.1 ja 15:30", st.format_time("15:30"), "\xe4\xb8\x89\xe6\x99\x82\xe5\x8d\x8a");
}

// ================================================================
// 8. Locale — Finnish (dot separator, short)
// ================================================================
void test_finnish_dot_separator() {
    SayableTime st(locales::FI(), Compactness::Short);
    // 8.1
    ASSERT_EQ("8.1 fi short 14:15", st.format_time("14:15"), "14.15");
    // 8.2
    ASSERT_EQ("8.2 fi short 00:00", st.format_time("00:00"), "0.00");
}

// ================================================================
// Section 9: Minutes in short and compact modes
// ================================================================
void test_section_9_minutes_in_short_and_compact_modes() {
    ASSERT_EQ("9.1 digital modes keep the exact minute", SayableTime(locales::EN(), Compactness::Short).format_time("18:01"), "6:01 PM"); // 9.1
    ASSERT_EQ("9.2 digital modes keep the exact minute", SayableTime(locales::EN(), Compactness::Compact).format_time("19:05"), "7:05p"); // 9.2
}

// ================================================================
// Section 10: Input validation
// ================================================================
void test_section_10_input_validation() {
    ASSERT_EQ("10.1 one-digit hour", SayableTime(locales::EN(), Compactness::Normal).format_time("9:30"), "half past nine"); // 10.1
    ASSERT_EQ("10.2 two-digit hour", SayableTime(locales::EN(), Compactness::Normal).format_time("09:30"), "half past nine"); // 10.2
    ASSERT_NULL("10.3 leading whitespace", SayableTime(locales::EN(), Compactness::Normal).format_time(" 9:30")); // 10.3
    ASSERT_NULL("10.4 trailing whitespace", SayableTime(locales::EN(), Compactness::Normal).format_time("9:30 ")); // 10.4
    ASSERT_NULL("10.5 minutes need two digits", SayableTime(locales::EN(), Compactness::Normal).format_time("9:5")); // 10.5
    ASSERT_NULL("10.6 hour out of range", SayableTime(locales::EN(), Compactness::Normal).format_time("24:00")); // 10.6
    ASSERT_EQ("10.7 seconds are allowed and ignored", SayableTime(locales::EN(), Compactness::Normal).format_time("14:15:30"), "a quarter past two"); // 10.7
    ASSERT_EQ("10.8 ISO datetime with zone suffix (ignored)", SayableTime(locales::EN(), Compactness::Normal).format_time("2025-01-15T14:15:00Z"), "a quarter past two"); // 10.8
    ASSERT_NULL("10.9 ISO datetime with an impossible date", SayableTime(locales::EN(), Compactness::Normal).format_time("2025-02-30T14:15:00")); // 10.9
}

int main() {
    test_null_edge_cases();
    test_normal_clock_time();
    test_short_compactness();
    test_compact_compactness();
    test_german_locale();
    test_french_locale();
    test_japanese_locale();
    test_finnish_dot_separator();

    test_section_9_minutes_in_short_and_compact_modes();
    test_section_10_input_validation();

    std::cout << tests_passed << " passed, " << tests_failed << " failed" << std::endl;
    return tests_failed == 0 ? 0 : 1;
}
