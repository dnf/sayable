#include "sayableduration/sayableduration.hpp"
#include "sayableduration/locales/locales.hpp"

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

using namespace sayableduration;

// ================================================================
// Section 1: Null / edge cases
// ================================================================
void test_null_edge_cases() {
    // 1.1: format_duration(null) -> null
    ASSERT_NULL("1.1 null seconds", format_duration(-2));
    // 1.2: format_duration(-1) -> null
    ASSERT_NULL("1.2 negative seconds", format_duration(-1));
    // 1.3: format_since(null, asOf) -> null
    ASSERT_NULL("1.3 null start", format_since("", "2025-01-15T10:00:00"));
    // 1.4: format_until(null, asOf) -> null
    ASSERT_NULL("1.4 null target", format_until("", "2025-01-15T10:00:00"));
    // 1.5: format_since where asOf before start -> null
    ASSERT_NULL("1.5 asOf before start", format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00"));
    // 1.6: format_until where target in the past -> null
    ASSERT_NULL("1.6 target in past", format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00"));
}

// ================================================================
// Section 2: Seconds tier (0-59s)
// ================================================================
void test_seconds_tier() {
    // 2.1: 0 seconds -> "just now"
    ASSERT_EQ("2.1 zero seconds", format_duration(0), "just now");
    // 2.2: 1 second
    ASSERT_EQ("2.2 one second", format_duration(1), "1 second");
    // 2.3: 45 seconds
    ASSERT_EQ("2.3 45 seconds", format_duration(45), "45 seconds");
    // 2.4: 59 seconds
    ASSERT_EQ("2.4 59 seconds", format_duration(59), "59 seconds");
}

// ================================================================
// Section 3: Minutes + seconds tier (1-4 min)
// ================================================================
void test_minutes_seconds_tier() {
    // 3.1: 60s = 1 minute
    ASSERT_EQ("3.1 60 seconds", format_duration(60), "1 minute");
    // 3.2: 90s = 1 minute, 30 seconds
    ASSERT_EQ("3.2 90 seconds", format_duration(90), "1 minute, 30 seconds");
    // 3.3: 240s = 4 minutes
    ASSERT_EQ("3.3 240 seconds", format_duration(240), "4 minutes");
    // 3.4: 270s = 4 minutes, 30 seconds
    ASSERT_EQ("3.4 270 seconds", format_duration(270), "4 minutes, 30 seconds");
}

// ================================================================
// Section 4: Minutes tier (5-59 min)
// ================================================================
void test_minutes_tier() {
    // 4.1: 300s = 5 minutes
    ASSERT_EQ("4.1 300 seconds", format_duration(300), "5 minutes");
    // 4.2: 1500s = 25 minutes
    ASSERT_EQ("4.2 1500 seconds", format_duration(1500), "25 minutes");
    // 4.3: 3540s = 59 minutes
    ASSERT_EQ("4.3 3540 seconds", format_duration(3540), "59 minutes");
}

// ================================================================
// Section 5: Hours + minutes tier (1-5 hr)
// ================================================================
void test_hours_minutes_tier() {
    // 5.1: 3600s = 1 hour
    ASSERT_EQ("5.1 3600 seconds", format_duration(3600), "1 hour");
    // 5.2: 5400s = 1.5 hours (half marker)
    ASSERT_EQ("5.2 5400 seconds", format_duration(5400), "1\xC2\xBD hours");
    // 5.3: 8100s = 2 hours, 15 minutes
    ASSERT_EQ("5.3 8100 seconds", format_duration(8100), "2 hours, 15 minutes");
    // 5.4: 18000s = 5 hours
    ASSERT_EQ("5.4 18000 seconds", format_duration(18000), "5 hours");
}

// ================================================================
// Section 6: Hours tier (6-23 hr)
// ================================================================
void test_hours_tier() {
    // 6.1: 28800s = 8 hours
    ASSERT_EQ("6.1 28800 seconds", format_duration(28800), "8 hours");
    // 6.2: 82800s = 23 hours
    ASSERT_EQ("6.2 82800 seconds", format_duration(82800), "23 hours");
}

// ================================================================
// Section 7: Days tier
// ================================================================
void test_days_tier() {
    // 7.1: 86400s = 1 day
    ASSERT_EQ("7.1 86400 seconds", format_duration(86400), "1 day");
    // 7.2: 97200s = 1 day, 3 hours
    ASSERT_EQ("7.2 97200 seconds", format_duration(97200), "1 day, 3 hours");
    // 7.3: 129600s = 1.5 days (half marker)
    ASSERT_EQ("7.3 129600 seconds", format_duration(129600), "1\xC2\xBD days");
    // 7.4: 432000s = 5 days
    ASSERT_EQ("7.4 432000 seconds", format_duration(432000), "5 days");
    // 7.5: 172800s = 2 days
    ASSERT_EQ("7.5 172800 seconds", format_duration(172800), "2 days");
}

// ================================================================
// Section 8: Weeks tier
// ================================================================
void test_weeks_tier() {
    // 8.1: 604800s = 1 week
    ASSERT_EQ("8.1 604800 seconds", format_duration(604800), "1 week");
    // 8.2: 1296000s = 2 weeks, 1 day
    ASSERT_EQ("8.2 1296000 seconds", format_duration(1296000), "2 weeks, 1 day");
    // 8.3: 2419200s = 4 weeks
    ASSERT_EQ("8.3 2419200 seconds", format_duration(2419200), "4 weeks");
}

// ================================================================
// Section 9: Months and years tier
// ================================================================
void test_months_years_tier() {
    // 9.1: ~31 days = 1 month
    ASSERT_EQ("9.1 2678400 seconds", format_duration(2678400), "1 month");
    // 9.2: ~91 days = 3 months
    ASSERT_EQ("9.2 7884000 seconds", format_duration(7884000), "3 months");
    // 9.3: 365 days = 1 year
    ASSERT_EQ("9.3 31536000 seconds", format_duration(31536000), "1 year");
    // 9.4: ~456 days = 1 year, 3 months
    ASSERT_EQ("9.4 39420000 seconds", format_duration(39420000), "1 year, 3 months");
}

// ================================================================
// Section 10: Duration from ISO timestamps
// ================================================================
void test_iso_timestamps() {
    // 10.1: 1.5 hours
    ASSERT_EQ("10.1 ISO 1.5 hours", format_duration("2025-01-15T10:00:00", "2025-01-15T11:30:00"), "1\xC2\xBD hours");
    // 10.2: 45 minutes
    ASSERT_EQ("10.2 ISO 45 minutes", format_duration("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes");
}

// ================================================================
// Section 11: Relative time -- since
// ================================================================
void test_format_since() {
    // 11.1: 0 diff = just now
    ASSERT_EQ("11.1 since just now", format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now");
    // 11.2: 30 seconds ago
    ASSERT_EQ("11.2 since 30 seconds", format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30"), "30 seconds ago");
    // 11.3: 45 minutes ago
    ASSERT_EQ("11.3 since 45 minutes", format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes ago");
    // 11.4: 3 hours ago
    ASSERT_EQ("11.4 since 3 hours", format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00"), "3 hours ago");
}

// ================================================================
// Section 12: Relative time -- until
// ================================================================
void test_format_until() {
    // 12.1: 0 diff = just now
    ASSERT_EQ("12.1 until just now", format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now");
    // 12.2: in 20 minutes
    ASSERT_EQ("12.2 until 20 minutes", format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00"), "in 20 minutes");
    // 12.3: in 3 hours
    ASSERT_EQ("12.3 until 3 hours", format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00"), "in 3 hours");
}

// ================================================================
// Section 13: Locale -- German
// ================================================================
void test_locale_german() {
    SayableDuration sd(locales::DE());
    // 13.1: 1 hour in German
    ASSERT_EQ("13.1 DE 1 hour", sd.format_duration(3600), "1 Stunde");
    // 13.2: format_since with German ago template
    ASSERT_EQ("13.2 DE 5 min ago", sd.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00"), "vor 5 Minuten");
}

// ================================================================
// Section 14: Locale -- French
// ================================================================
void test_locale_french() {
    SayableDuration sd(locales::FR());
    // 14.1: 2 hours in French
    ASSERT_EQ("14.1 FR 2 hours", sd.format_duration(7200), "2 heures");
}

// ================================================================
// Section 15: Locale -- Japanese
// ================================================================
void test_locale_japanese() {
    SayableDuration sd(locales::JA());
    // 15.1: 2 minutes in Japanese
    ASSERT_EQ("15.1 JA 2 minutes", sd.format_duration(120), "2\xE5\x88\x86");
    // 15.2: 1 hour ago in Japanese
    ASSERT_EQ("15.2 JA 1 hour ago", sd.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00"), "1\xE6\x99\x82\xE9\x96\x93\xE5\x89\x8D");
}

// ================================================================
// Section 16: Short compactness
// ================================================================
void test_short_compactness() {
    SayableDuration sd(locales::EN(), Compactness::Short);
    // 16.1: 1 hour -> "1h"
    ASSERT_EQ("16.1 short 1 hour", sd.format_duration(3600), "1h");
    // 16.2: 90 seconds -> "1m, 30s"
    ASSERT_EQ("16.2 short 90 seconds", sd.format_duration(90), "1m, 30s");
}

// ================================================================
// Section 17: Compact compactness
// ================================================================
void test_compact_compactness() {
    SayableDuration sd(locales::EN(), Compactness::Compact);
    // 17.1: 1 hour -> "1h"
    ASSERT_EQ("17.1 compact 1 hour", sd.format_duration(3600), "1h");
    // 17.2: 90 seconds -> "1m30s" (no delimiter)
    ASSERT_EQ("17.2 compact 90 seconds", sd.format_duration(90), "1m30s");
}

int main() {
    test_null_edge_cases();
    test_seconds_tier();
    test_minutes_seconds_tier();
    test_minutes_tier();
    test_hours_minutes_tier();
    test_hours_tier();
    test_days_tier();
    test_weeks_tier();
    test_months_years_tier();
    test_iso_timestamps();
    test_format_since();
    test_format_until();
    test_locale_german();
    test_locale_french();
    test_locale_japanese();
    test_short_compactness();
    test_compact_compactness();

    std::cout << "\n=== Results ===" << std::endl;
    std::cout << "Passed: " << tests_passed << std::endl;
    std::cout << "Failed: " << tests_failed << std::endl;
    std::cout << "Total:  " << (tests_passed + tests_failed) << std::endl;

    return tests_failed > 0 ? 1 : 0;
}
