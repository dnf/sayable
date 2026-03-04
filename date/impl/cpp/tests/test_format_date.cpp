#include "sayabledate/sayabledate.hpp"
#include "sayabledate/locales/locales.hpp"

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

using namespace sayabledate;

// ================================================================
// 1. Null / edge cases
// ================================================================
void test_null_edge_cases() {
    SayableDate sd(locales::EN());

    // 1.1: format_date with null (empty string)
    ASSERT_NULL("1.1 format_date null", sd.format_date(""));

    // 1.2: format_date with empty string
    ASSERT_NULL("1.2 format_date empty", sd.format_date(""));

    // 1.3: format_date with invalid string
    ASSERT_NULL("1.3 format_date invalid", sd.format_date("invalid"));

    // 1.4: format_relative with valid date but null as_of
    ASSERT_NULL("1.4 format_relative null asOf", sd.format_relative("2025-03-15", ""));

    // 1.5: format_relative with null date
    ASSERT_NULL("1.5 format_relative null date", sd.format_relative("", "2025-03-15"));
}

// ================================================================
// 2. format_date -- normal compactness (English)
// ================================================================
void test_format_date_normal() {
    SayableDate sd(locales::EN());

    // 2.1
    ASSERT_EQ("2.1 March 15th", sd.format_date("2025-03-15"), "March 15th");

    // 2.2
    ASSERT_EQ("2.2 January 1st", sd.format_date("2025-01-01"), "January 1st");

    // 2.3
    ASSERT_EQ("2.3 May 22nd", sd.format_date("2025-05-22"), "May 22nd");

    // 2.4
    ASSERT_EQ("2.4 July 3rd", sd.format_date("2025-07-03"), "July 3rd");

    // 2.5
    ASSERT_EQ("2.5 December 31st", sd.format_date("2025-12-31"), "December 31st");

    // 2.6: No exception for 11
    ASSERT_EQ("2.6 June 11th", sd.format_date("2025-06-11"), "June 11th");

    // 2.7: ISO datetime input
    ASSERT_EQ("2.7 ISO datetime", sd.format_date("2025-03-15T14:30:00"), "March 15th");
}

// ================================================================
// 3. format_date -- short compactness (English)
// ================================================================
void test_format_date_short() {
    SayableDate sd(locales::EN(), Compactness::Short);

    // 3.1
    ASSERT_EQ("3.1 short Mar 15", sd.format_date("2025-03-15"), "Mar 15");

    // 3.2
    ASSERT_EQ("3.2 short Jan 1", sd.format_date("2025-01-01"), "Jan 1");

    // 3.3
    ASSERT_EQ("3.3 short Dec 25", sd.format_date("2025-12-25"), "Dec 25");
}

// ================================================================
// 4. format_date -- compact (English)
// ================================================================
void test_format_date_compact() {
    SayableDate sd(locales::EN(), Compactness::Compact);

    // 4.1
    ASSERT_EQ("4.1 compact 3/15", sd.format_date("2025-03-15"), "3/15");

    // 4.2
    ASSERT_EQ("4.2 compact 1/1", sd.format_date("2025-01-01"), "1/1");
}

// ================================================================
// 5. format_relative -- proximity tiers (English)
// ================================================================
void test_format_relative_proximity() {
    SayableDate sd(locales::EN());

    // 5.1: today
    ASSERT_EQ("5.1 today", sd.format_relative("2025-03-15", "2025-03-15"), "today");

    // 5.2: tomorrow
    ASSERT_EQ("5.2 tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), "tomorrow");

    // 5.3: yesterday
    ASSERT_EQ("5.3 yesterday", sd.format_relative("2025-03-14", "2025-03-15"), "yesterday");

    // 5.4: day after tomorrow (+2 special tier)
    ASSERT_EQ("5.4 day after tomorrow", sd.format_relative("2025-03-17", "2025-03-15"), "the day after tomorrow");

    // 5.5: day before yesterday (-2 special tier)
    ASSERT_EQ("5.5 day before yesterday", sd.format_relative("2025-03-13", "2025-03-15"), "the day before yesterday");

    // 5.6: this Wednesday (+4 days)
    ASSERT_EQ("5.6 this Wednesday", sd.format_relative("2025-03-19", "2025-03-15"), "this Wednesday");

    // 5.7: this Thursday (+5 days)
    ASSERT_EQ("5.7 this Thursday", sd.format_relative("2025-03-20", "2025-03-15"), "this Thursday");

    // 5.8: last Tuesday (-4 days)
    ASSERT_EQ("5.8 last Tuesday", sd.format_relative("2025-03-11", "2025-03-15"), "last Tuesday");

    // 5.9: next Saturday (+7 days)
    ASSERT_EQ("5.9 next Saturday", sd.format_relative("2025-03-22", "2025-03-15"), "next Saturday");

    // 5.10: next Thursday (+12 days)
    ASSERT_EQ("5.10 next Thursday", sd.format_relative("2025-03-27", "2025-03-15"), "next Thursday");

    // 5.11: calendar fallback (same year, -14 days)
    ASSERT_EQ("5.11 calendar fallback", sd.format_relative("2025-03-01", "2025-03-15"), "March 1st");

    // 5.12: calendar fallback (same year, +26 days)
    ASSERT_EQ("5.12 calendar fallback", sd.format_relative("2025-04-10", "2025-03-15"), "April 10th");

    // 5.13: different year includes year
    ASSERT_EQ("5.13 future year", sd.format_relative("2026-01-05", "2025-03-15"), "January 5th, 2026");

    // 5.14: past year includes year
    ASSERT_EQ("5.14 past year", sd.format_relative("2024-12-25", "2025-03-15"), "December 25th, 2024");
}

// ================================================================
// 6. format_relative -- compact skips weekday tiers
// ================================================================
void test_format_relative_compact() {
    SayableDate sd(locales::EN(), Compactness::Compact);

    // 6.1: today still works
    ASSERT_EQ("6.1 compact today", sd.format_relative("2025-03-15", "2025-03-15"), "today");

    // 6.2: tomorrow still works
    ASSERT_EQ("6.2 compact tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), "tomorrow");

    // 6.3: compact goes straight to numeric
    ASSERT_EQ("6.3 compact numeric", sd.format_relative("2025-03-19", "2025-03-15"), "3/19");

    // 6.4: compact with different year
    ASSERT_EQ("6.4 compact diff year", sd.format_relative("2026-01-05", "2025-03-15"), "1/5/26");
}

// ================================================================
// 7. Locale -- German
// ================================================================
void test_locale_german() {
    SayableDate sd(locales::DE());

    // 7.1: format_date
    ASSERT_EQ("7.1 de format_date", sd.format_date("2025-03-15"), u8"15. M\u00e4rz");

    // 7.2: tomorrow
    ASSERT_EQ("7.2 de tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), "morgen");

    // 7.3: day after tomorrow
    ASSERT_EQ("7.3 de day after tomorrow", sd.format_relative("2025-03-17", "2025-03-15"), u8"\u00fcbermorgen");

    // 7.4: this weekday
    ASSERT_EQ("7.4 de this Wednesday", sd.format_relative("2025-03-19", "2025-03-15"), "diesen Mittwoch");
}

// ================================================================
// 8. Locale -- French
// ================================================================
void test_locale_french() {
    SayableDate sd(locales::FR());

    // 8.1: 1er mars (ordinal exception for 1)
    ASSERT_EQ("8.1 fr 1er mars", sd.format_date("2025-03-01"), "1er mars");

    // 8.2: 15 mars (no ordinal)
    ASSERT_EQ("8.2 fr 15 mars", sd.format_date("2025-03-15"), "15 mars");

    // 8.3: demain
    ASSERT_EQ("8.3 fr demain", sd.format_relative("2025-03-16", "2025-03-15"), "demain");
}

// ================================================================
// 9. Locale -- Japanese
// ================================================================
void test_locale_japanese() {
    SayableDate sd(locales::JA());

    // 9.1: format_date
    ASSERT_EQ("9.1 ja format_date", sd.format_date("2025-03-15"), u8"3\u670815\u65e5");

    // 9.2: tomorrow
    ASSERT_EQ("9.2 ja tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), u8"\u660e\u65e5");

    // 9.3: this Wednesday
    ASSERT_EQ("9.3 ja this Wednesday", sd.format_relative("2025-03-19", "2025-03-15"), u8"\u4eca\u5ea6\u306e\u6c34\u66dc\u65e5");
}

// ================================================================
// 10. Locale -- Russian (genitive months)
// ================================================================
void test_locale_russian() {
    SayableDate sd(locales::RU());

    // 10.1: uses genitive form
    ASSERT_EQ("10.1 ru genitive", sd.format_date("2025-03-15"), u8"15 \u043c\u0430\u0440\u0442\u0430");

    // 10.2: tomorrow
    ASSERT_EQ("10.2 ru tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), u8"\u0437\u0430\u0432\u0442\u0440\u0430");
}

// ================================================================
// 11. Locale -- Arabic
// ================================================================
void test_locale_arabic() {
    SayableDate sd(locales::AR());

    // 11.1: format_date
    ASSERT_EQ("11.1 ar format_date", sd.format_date("2025-03-15"), u8"15 \u0645\u0627\u0631\u0633");

    // 11.2: tomorrow
    ASSERT_EQ("11.2 ar tomorrow", sd.format_relative("2025-03-16", "2025-03-15"), u8"\u063a\u062f\u0627\u064b");
}

// ================================================================
// 12. Locale -- Spanish
// ================================================================
void test_locale_spanish() {
    SayableDate sd(locales::ES());

    // 12.1: format_date
    ASSERT_EQ("12.1 es format_date", sd.format_date("2025-03-15"), "15 de marzo");

    // 12.2: day after tomorrow
    ASSERT_EQ("12.2 es day after tomorrow", sd.format_relative("2025-03-17", "2025-03-15"), u8"pasado ma\u00f1ana");
}

// ================================================================
// Main
// ================================================================
int main() {
    test_null_edge_cases();
    test_format_date_normal();
    test_format_date_short();
    test_format_date_compact();
    test_format_relative_proximity();
    test_format_relative_compact();
    test_locale_german();
    test_locale_french();
    test_locale_japanese();
    test_locale_russian();
    test_locale_arabic();
    test_locale_spanish();

    std::cout << "\n" << tests_passed << " passed, " << tests_failed << " failed" << std::endl;
    return tests_failed > 0 ? 1 : 0;
}
