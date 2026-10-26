#include "sayableage/sayableage.hpp"
#include "sayableage/locales/locales.hpp"
#include "sayableage/testing.hpp"

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

#define ASSERT_TRUE(name, cond) do { \
    if (!(cond)) { \
        std::cerr << "FAIL [" << (name) << "]: condition was false" << std::endl; \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

#define ASSERT_CONTAINS(name, got, substr) do { \
    auto _got = (got); \
    std::string _sub = (substr); \
    if (!_got.has_value()) { \
        std::cerr << "FAIL [" << (name) << "]: got nullopt, expected string containing \"" << _sub << "\"" << std::endl; \
        tests_failed++; \
    } else if (_got.value().find(_sub) == std::string::npos) { \
        std::cerr << "FAIL [" << (name) << "]: \"" << _got.value() << "\" does not contain \"" << _sub << "\"" << std::endl; \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

using namespace sayableage;

// ================================================================
// formatAge -- null/edge cases
// ================================================================
void test_null_edge_cases() {
    ASSERT_NULL("empty string", format_age("", "2025-06-15")); // 1.1, 1.3
    ASSERT_NULL("future dob", format_age("2025-07-01", "2025-06-15")); // 1.4
    ASSERT_EQ("exactly 500 years", format_age("1525-06-15", "2025-06-15"), "500 years"); // 1.5
    ASSERT_NULL("501 years exceeds max", format_age("1524-06-15", "2025-06-15")); // 1.6
    ASSERT_NULL("1000 years exceeds max", format_age("1025-06-15", "2025-06-15")); // 1.7
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
void test_days_tier() {
    ASSERT_EQ("born today", format_age("2025-06-15", "2025-06-15"), "Newborn"); // 2.1
    ASSERT_EQ("1 day ago", format_age("2025-06-14", "2025-06-15"), "1 day"); // 2.2
    ASSERT_EQ("3 days ago", format_age("2025-06-12", "2025-06-15"), "3 days"); // 2.3
    ASSERT_EQ("6 days ago", format_age("2025-06-09", "2025-06-15"), "6 days"); // 2.4
    ASSERT_EQ("7 days -> 1 week", format_age("2025-06-08", "2025-06-15"), "1 week"); // 2.5
}

// ================================================================
// formatAge -- weeks+days tier
// ================================================================
void test_weeks_days_tier() {
    ASSERT_EQ("7 days", format_age("2025-06-08", "2025-06-15"), "1 week"); // 3.1
    ASSERT_EQ("8 days", format_age("2025-06-07", "2025-06-15"), "1 week, 1 day"); // 3.2
    ASSERT_EQ("9 days", format_age("2025-06-06", "2025-06-15"), "1 week, 2 days"); // 3.3
    ASSERT_EQ("13 days", format_age("2025-06-02", "2025-06-15"), "1 week, 6 days"); // 3.4
    ASSERT_EQ("14 days", format_age("2025-06-01", "2025-06-15"), "2 weeks"); // 3.5
    ASSERT_EQ("15 days", format_age("2025-05-31", "2025-06-15"), "2 weeks, 1 day"); // 3.6
    ASSERT_EQ("20 days", format_age("2025-05-26", "2025-06-15"), "2 weeks, 6 days"); // 3.7
    ASSERT_EQ("21 days", format_age("2025-05-25", "2025-06-15"), "3 weeks"); // 3.8
    ASSERT_EQ("at 1 cal month still weeks+days", format_age("2025-05-15", "2025-06-15"), "4 weeks, 3 days"); // 3.9
    ASSERT_EQ("at 2 cal months still weeks+days", format_age("2025-04-15", "2025-06-15"), "8 weeks, 5 days"); // 3.10
    ASSERT_EQ("one day before 3mo still weeks", format_age("2025-03-15", "2025-06-14"), "13 weeks"); // 3.11
    ASSERT_EQ("on 3mo birthday switches", format_age("2025-03-15", "2025-06-15"), "3 months"); // 3.12
}

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================
void test_month_boundary_standard() {
    ASSERT_EQ("Jan1->Apr1=3mo", format_age("2025-01-01", "2025-04-01"), "3 months"); // 4.1
    ASSERT_CONTAINS("Jan1->Mar31 still weeks", format_age("2025-01-01", "2025-03-31"), "weeks"); // 4.2
    ASSERT_EQ("Jun15->Sep15=3mo", format_age("2025-06-15", "2025-09-15"), "3 months"); // 4.3
    ASSERT_CONTAINS("Jun15->Sep14 still weeks", format_age("2025-06-15", "2025-09-14"), "weeks"); // 4.4
    ASSERT_EQ("Jun15->Dec15=6mo", format_age("2025-06-15", "2025-12-15"), "6 months"); // 4.5
}

// ================================================================
// formatAge -- month boundaries: February non-leap
// ================================================================
void test_month_boundary_feb_non_leap() {
    ASSERT_EQ("Jan31->Feb28 non-leap", format_age("2025-01-31", "2025-02-28"), "4 weeks"); // 5.1
    ASSERT_EQ("Jan31->Apr30=3mo(clamp)", format_age("2025-01-31", "2025-04-30"), "3 months"); // 5.2
    ASSERT_CONTAINS("Jan31->Apr29 still weeks", format_age("2025-01-31", "2025-04-29"), "weeks"); // 5.3
    ASSERT_EQ("Feb1->May1=3mo", format_age("2025-02-01", "2025-05-01"), "3 months"); // 5.4
    ASSERT_CONTAINS("Feb1->Apr30 still weeks", format_age("2025-02-01", "2025-04-30"), "weeks"); // 5.5
}

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================
void test_month_boundary_feb_leap() {
    ASSERT_EQ("Jan31->Feb29 leap", format_age("2024-01-31", "2024-02-29"), "4 weeks, 1 day"); // 6.1
    ASSERT_EQ("Jan31->Feb28 leap", format_age("2024-01-31", "2024-02-28"), "4 weeks"); // 6.2
    ASSERT_EQ("Jan31->Apr30 leap=3mo", format_age("2024-01-31", "2024-04-30"), "3 months"); // 6.3
    ASSERT_CONTAINS("Jan30->Feb29 leap still weeks", format_age("2024-01-30", "2024-02-29"), "weeks"); // 6.4
    ASSERT_CONTAINS("Jan30->Feb28 leap still weeks", format_age("2024-01-30", "2024-02-28"), "weeks"); // 6.5
}

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================
void test_month_boundary_30day() {
    ASSERT_EQ("Mar31->Jun30=3mo(clamped)", format_age("2025-03-31", "2025-06-30"), "3 months"); // 7.1
    ASSERT_CONTAINS("Mar31->Jun29 still weeks", format_age("2025-03-31", "2025-06-29"), "weeks"); // 7.2
    ASSERT_EQ("Aug31->Nov30=3mo", format_age("2025-08-31", "2025-11-30"), "3 months"); // 7.3
    ASSERT_CONTAINS("Aug31->Nov29 still weeks", format_age("2025-08-31", "2025-11-29"), "weeks"); // 7.4
}

// ================================================================
// formatAge -- leap year baby (born Feb 29)
// ================================================================
void test_leap_year_baby() {
    ASSERT_EQ("Feb29->May29=3mo", format_age("2024-02-29", "2024-05-29"), "3 months"); // 8.1
    ASSERT_CONTAINS("Feb29->May28 still weeks", format_age("2024-02-29", "2024-05-28"), "weeks"); // 8.2
    ASSERT_EQ("Feb29 2024->Feb28 2025=12mo", format_age("2024-02-29", "2025-02-28"), "12 months"); // 8.3
    ASSERT_EQ("Feb29 2024->Mar1 2025=12mo", format_age("2024-02-29", "2025-03-01"), "12 months"); // 8.4
}

// ================================================================
// formatAge -- months tier (3-23)
// ================================================================
void test_months_tier() {
    ASSERT_EQ("3 months at transition", format_age("2025-01-15", "2025-04-15"), "3 months"); // 9.1
    ASSERT_EQ("6 months", format_age("2025-01-15", "2025-07-15"), "6 months"); // 9.2
    ASSERT_EQ("12 months (not 1 year)", format_age("2024-06-15", "2025-06-15"), "12 months"); // 9.3
    ASSERT_EQ("23 months at upper", format_age("2024-01-15", "2025-12-15"), "23 months"); // 9.4
    ASSERT_EQ("one day before boundary", format_age("2025-01-15", "2025-07-14"), "5 months"); // 9.5
    ASSERT_EQ("crossing year boundary", format_age("2024-11-10", "2025-04-10"), "5 months"); // 9.6
}

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================
void test_years_months_tier() {
    ASSERT_EQ("2 years at 24mo", format_age("2023-06-15", "2025-06-15"), "2 years"); // 10.1
    ASSERT_EQ("2 years 1 month", format_age("2023-06-15", "2025-07-15"), "2 years, 1 month"); // 10.2
    ASSERT_EQ("2 years 6 months", format_age("2023-06-15", "2025-12-15"), "2 years, 6 months"); // 10.3
    ASSERT_EQ("2 years 11 months", format_age("2023-06-15", "2026-05-15"), "2 years, 11 months"); // 10.4
    ASSERT_EQ("one day before 24mo", format_age("2023-06-15", "2025-06-14"), "23 months"); // 10.5
}

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================
void test_half_year_tier() {
    ASSERT_EQ("3 years exactly", format_age("2022-06-15", "2025-06-15"), "3 years"); // 11.1
    ASSERT_EQ("3 years 5 months", format_age("2022-06-15", "2025-11-15"), "3 years"); // 11.2
    ASSERT_EQ("3.5 years at 3y6m", format_age("2022-06-15", "2025-12-15"), "3½ years"); // 11.3
    ASSERT_EQ("3.5 years at 3y11m", format_age("2022-06-15", "2026-05-15"), "3½ years"); // 11.4
    ASSERT_EQ("4 years exactly", format_age("2021-06-15", "2025-06-15"), "4 years"); // 11.5
    ASSERT_EQ("4.5 years", format_age("2021-06-15", "2025-12-15"), "4½ years"); // 11.6
    ASSERT_EQ("5 years", format_age("2020-06-15", "2025-06-15"), "5 years"); // 11.7
    ASSERT_EQ("5.5 years at 5y8m", format_age("2020-06-15", "2026-02-15"), "5½ years"); // 11.8
    ASSERT_EQ("6 years", format_age("2019-06-15", "2025-06-15"), "6 years"); // 11.9
    ASSERT_EQ("6.5 years", format_age("2019-06-15", "2025-12-15"), "6½ years"); // 11.10
    ASSERT_EQ("6.5 years at 6y11m", format_age("2019-06-15", "2026-05-15"), "6½ years"); // 11.11
    ASSERT_EQ("one day before 3rd bday", format_age("2022-06-15", "2025-06-14"), "2 years, 11 months"); // 11.12
}

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================
void test_integer_tier() {
    ASSERT_EQ("7 years exactly", format_age("2018-06-15", "2025-06-15"), "7 years"); // 12.1
    ASSERT_EQ("7 years 6 months (no half)", format_age("2018-03-20", "2025-06-15"), "7 years"); // 12.2
    ASSERT_EQ("45 years", format_age("1980-01-01", "2025-06-15"), "45 years"); // 12.3
}

// ================================================================
// formatAge -- cross-year with Feb
// ================================================================
void test_cross_year_feb() {
    ASSERT_EQ("Dec31->Mar31=3mo", format_age("2024-12-31", "2025-03-31"), "3 months"); // 13.1
    ASSERT_CONTAINS("Dec31->Mar30 still weeks", format_age("2024-12-31", "2025-03-30"), "weeks"); // 13.2
    ASSERT_EQ("Nov30->Feb28=3mo", format_age("2024-11-30", "2025-02-28"), "3 months"); // 13.3
    ASSERT_CONTAINS("Nov30->Feb27 still weeks", format_age("2024-11-30", "2025-02-27"), "weeks"); // 13.4
}

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================
void test_born_on_31st() {
    ASSERT_EQ("Jan31->Apr30=3mo", format_age("2025-01-31", "2025-04-30"), "3 months"); // 14.1
    ASSERT_EQ("Jan31->May31=4mo", format_age("2025-01-31", "2025-05-31"), "4 months"); // 14.2
    ASSERT_EQ("Jan31->Jun30=5mo(clamped)", format_age("2025-01-31", "2025-06-30"), "5 months"); // 14.3
    ASSERT_EQ("Jan31->Jul1=5mo", format_age("2025-01-31", "2025-07-01"), "5 months"); // 14.4
    ASSERT_EQ("Jan31->Jul31=6mo", format_age("2025-01-31", "2025-07-31"), "6 months"); // 14.5
}

// ================================================================
// formatStage
// ================================================================
void test_stage_null_edge_cases() {
    ASSERT_NULL("stage empty", format_stage("", "2025-06-15")); // 16.1, 16.3
    ASSERT_NULL("stage future", format_stage("2025-07-01", "2025-06-15")); // 16.4
    ASSERT_EQ("stage 500 years", format_stage("1525-06-15", "2025-06-15"), "Adult"); // 16.5
    ASSERT_NULL("stage 501 years exceeds max", format_stage("1524-06-15", "2025-06-15")); // 16.6
}

void test_stage_newborn() {
    ASSERT_EQ("stage born today", format_stage("2025-06-15", "2025-06-15"), "Newborn"); // 17.1
    ASSERT_EQ("stage 1 day old", format_stage("2025-06-14", "2025-06-15"), "Newborn"); // 17.2
    ASSERT_EQ("stage 3 weeks old", format_stage("2025-05-25", "2025-06-15"), "Newborn"); // 17.3
    ASSERT_EQ("stage 1 month old", format_stage("2025-05-15", "2025-06-15"), "Newborn"); // 17.4
    ASSERT_EQ("stage 1 month 29 days", format_stage("2025-04-16", "2025-06-15"), "Newborn"); // 17.5
    ASSERT_EQ("stage exactly 2 months -> Infant", format_stage("2025-04-15", "2025-06-15"), "Infant"); // 17.6
}

void test_stage_infant() {
    ASSERT_EQ("stage 2 months", format_stage("2025-04-15", "2025-06-15"), "Infant"); // 18.1
    ASSERT_EQ("stage 6 months", format_stage("2024-12-15", "2025-06-15"), "Infant"); // 18.2
    ASSERT_EQ("stage 11 months", format_stage("2024-07-15", "2025-06-15"), "Infant"); // 18.3
    ASSERT_EQ("stage exactly 12mo -> Toddler", format_stage("2024-06-15", "2025-06-15"), "Toddler"); // 18.4
}

void test_stage_toddler() {
    ASSERT_EQ("stage 12 months", format_stage("2024-06-15", "2025-06-15"), "Toddler"); // 19.1
    ASSERT_EQ("stage 18 months", format_stage("2024-01-15", "2025-07-15"), "Toddler"); // 19.2
    ASSERT_EQ("stage 24 months", format_stage("2023-06-15", "2025-06-15"), "Toddler"); // 19.3
    ASSERT_EQ("stage 35 months", format_stage("2023-06-15", "2026-05-15"), "Toddler"); // 19.4
    ASSERT_EQ("stage exactly 36mo -> Child", format_stage("2022-06-15", "2025-06-15"), "Child"); // 19.5
}

void test_stage_child() {
    ASSERT_EQ("stage 3 years", format_stage("2022-06-15", "2025-06-15"), "Child"); // 20.1
    ASSERT_EQ("stage 4 years", format_stage("2021-06-15", "2025-06-15"), "Child"); // 20.2
    ASSERT_EQ("stage 6 years", format_stage("2019-06-15", "2025-06-15"), "Child"); // 20.3
    ASSERT_EQ("stage 9 years", format_stage("2016-06-15", "2025-06-15"), "Child"); // 20.4
    ASSERT_EQ("stage 12y11mo", format_stage("2013-06-15", "2026-05-15"), "Child"); // 20.5
    ASSERT_EQ("stage exactly 13y -> Teenager", format_stage("2012-06-15", "2025-06-15"), "Teenager"); // 20.6
}

void test_stage_teenager() {
    ASSERT_EQ("stage 13 years", format_stage("2012-06-15", "2025-06-15"), "Teenager"); // 21.1
    ASSERT_EQ("stage 15 years", format_stage("2010-06-15", "2025-06-15"), "Teenager"); // 21.2
    ASSERT_EQ("stage 17y11mo", format_stage("2008-06-15", "2026-05-15"), "Teenager"); // 21.3
    ASSERT_EQ("stage exactly 18y -> Adult", format_stage("2007-06-15", "2025-06-15"), "Adult"); // 21.4
}

void test_stage_adult() {
    ASSERT_EQ("stage 18 years", format_stage("2007-06-15", "2025-06-15"), "Adult"); // 22.1
    ASSERT_EQ("stage 25 years", format_stage("2000-06-15", "2025-06-15"), "Adult"); // 22.2
    ASSERT_EQ("stage 45 years", format_stage("1980-01-01", "2025-06-15"), "Adult"); // 22.3
}

// ================================================================
// formatStage -- gender support
// ================================================================
void test_stage_gender_spanish() {
    SayableAge pt(locales::ES());

    // Default (masculine/neutral)
    ASSERT_EQ("ES stage newborn m", pt.format_stage("2025-06-15", "2025-06-15"), "Recién nacido");
    ASSERT_EQ("ES stage toddler m", pt.format_stage("2024-06-15", "2025-06-15"), "Niño pequeño");
    ASSERT_EQ("ES stage child m", pt.format_stage("2022-06-15", "2025-06-15"), "Niño");
    ASSERT_EQ("ES stage adult m", pt.format_stage("2007-06-15", "2025-06-15"), "Adulto");

    // Feminine
    ASSERT_EQ("ES stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Recién nacida");
    ASSERT_EQ("ES stage infant f", pt.format_stage("2025-01-15", "2025-06-15", "f"), "Bebé");
    ASSERT_EQ("ES stage toddler f", pt.format_stage("2024-06-15", "2025-06-15", "f"), "Niña pequeña");
    ASSERT_EQ("ES stage child f", pt.format_stage("2022-06-15", "2025-06-15", "f"), "Niña");
    ASSERT_EQ("ES stage teenager f", pt.format_stage("2012-06-15", "2025-06-15", "f"), "Adolescente");
    ASSERT_EQ("ES stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Adulta");
}

void test_stage_gender_italian() {
    SayableAge pt(locales::IT());

    // Default (masculine)
    ASSERT_EQ("IT stage newborn m", pt.format_stage("2025-06-15", "2025-06-15"), "Neonato");
    ASSERT_EQ("IT stage toddler m", pt.format_stage("2024-06-15", "2025-06-15"), "Bimbo");
    ASSERT_EQ("IT stage child m", pt.format_stage("2022-06-15", "2025-06-15"), "Bambino");

    // Feminine
    ASSERT_EQ("IT stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Neonata");
    ASSERT_EQ("IT stage infant f", pt.format_stage("2025-01-15", "2025-06-15", "f"), "Lattante");
    ASSERT_EQ("IT stage toddler f", pt.format_stage("2024-06-15", "2025-06-15", "f"), "Bimba");
    ASSERT_EQ("IT stage child f", pt.format_stage("2022-06-15", "2025-06-15", "f"), "Bambina");
    ASSERT_EQ("IT stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Adulta");
}

void test_stage_gender_arabic() {
    SayableAge pt(locales::AR());

    // Default (masculine)
    ASSERT_EQ("AR stage newborn m", pt.format_stage("2025-06-15", "2025-06-15"), "حديث الولادة");
    ASSERT_EQ("AR stage infant m", pt.format_stage("2025-01-15", "2025-06-15"), "رضيع");
    ASSERT_EQ("AR stage teenager m", pt.format_stage("2012-06-15", "2025-06-15"), "مراهق");

    // Feminine
    ASSERT_EQ("AR stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "حديثة الولادة");
    ASSERT_EQ("AR stage infant f", pt.format_stage("2025-01-15", "2025-06-15", "f"), "رضيعة");
    ASSERT_EQ("AR stage toddler f", pt.format_stage("2024-06-15", "2025-06-15", "f"), "طفلة صغيرة");
    ASSERT_EQ("AR stage child f", pt.format_stage("2022-06-15", "2025-06-15", "f"), "طفلة");
    ASSERT_EQ("AR stage teenager f", pt.format_stage("2012-06-15", "2025-06-15", "f"), "مراهقة");
    ASSERT_EQ("AR stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "بالغة");
}

void test_stage_gender_neutral_locale() {
    // English has no gendered forms - "f" should still return default
    SayableAge pt(locales::EN());
    ASSERT_EQ("EN stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Newborn");
    ASSERT_EQ("EN stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Adult");
}

void test_stage_gender_slovenian() {
    SayableAge pt(locales::SL());

    ASSERT_EQ("SL stage newborn m", pt.format_stage("2025-06-15", "2025-06-15"), "Novorojenček");
    ASSERT_EQ("SL stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Novorojenčica");
    ASSERT_EQ("SL stage child m", pt.format_stage("2022-06-15", "2025-06-15"), "Otrok");
    ASSERT_EQ("SL stage child f", pt.format_stage("2022-06-15", "2025-06-15", "f"), "Otrok");
    ASSERT_EQ("SL stage adult m", pt.format_stage("2007-06-15", "2025-06-15"), "Odrasel");
    ASSERT_EQ("SL stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Odrasla");
}

// ================================================================
// SayableAge class with English locale
// ================================================================
void test_sayableage_english() {
    SayableAge pt(locales::EN());
    ASSERT_EQ("PT Newborn", pt.format_age("2025-06-15", "2025-06-15"), "Newborn"); // 24.1
    ASSERT_EQ("PT 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 days"); // 24.2
    ASSERT_EQ("PT 1w1d", pt.format_age("2025-06-07", "2025-06-15"), "1 week, 1 day"); // 24.3
    ASSERT_EQ("PT 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 months"); // 24.4
    ASSERT_EQ("PT 2y1mo", pt.format_age("2023-06-15", "2025-07-15"), "2 years, 1 month"); // 24.5
    ASSERT_EQ("PT 3.5 years", pt.format_age("2022-06-15", "2025-12-15"), "3½ years"); // 24.6
    ASSERT_EQ("PT 7 years", pt.format_age("2018-06-15", "2025-06-15"), "7 years"); // 24.7

    ASSERT_EQ("PT stage Newborn", pt.format_stage("2025-06-15", "2025-06-15"), "Newborn"); // 24.8
    ASSERT_EQ("PT stage Infant", pt.format_stage("2025-01-15", "2025-06-15"), "Infant"); // 24.9
    ASSERT_EQ("PT stage Toddler", pt.format_stage("2024-06-15", "2025-06-15"), "Toddler"); // 24.10
    ASSERT_EQ("PT stage Child", pt.format_stage("2022-06-15", "2025-06-15"), "Child"); // 24.11
    ASSERT_EQ("PT stage Teenager", pt.format_stage("2012-06-15", "2025-06-15"), "Teenager"); // 24.12
    ASSERT_EQ("PT stage Adult", pt.format_stage("2007-06-15", "2025-06-15"), "Adult"); // 24.13

    ASSERT_NULL("PT null age", pt.format_age("")); // 24.14
    ASSERT_NULL("PT null stage", pt.format_stage("")); // 24.15
}

// ================================================================
// SayableAge with Spanish locale
// ================================================================
void test_sayableage_spanish() {
    SayableAge pt(locales::ES());

    ASSERT_EQ("ES justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Recién nacido"); // 25.1
    ASSERT_EQ("ES singular day", pt.format_age("2025-06-14", "2025-06-15"), "1 día"); // 25.2
    ASSERT_EQ("ES plural days", pt.format_age("2025-06-12", "2025-06-15"), "3 días"); // 25.3
    ASSERT_EQ("ES singular week", pt.format_age("2025-06-08", "2025-06-15"), "1 semana"); // 25.4
    ASSERT_EQ("ES weeks+days", pt.format_age("2025-06-07", "2025-06-15"), "1 semana, 1 día"); // 25.5
    ASSERT_EQ("ES plural weeks+days", pt.format_age("2025-05-26", "2025-06-15"), "2 semanas, 6 días"); // 25.6
    ASSERT_EQ("ES months", pt.format_age("2025-01-15", "2025-07-15"), "6 meses"); // 25.7
    ASSERT_EQ("ES singular month compound", pt.format_age("2023-06-15", "2025-07-15"), "2 años, 1 mes"); // 25.8
    ASSERT_EQ("ES years+months", pt.format_age("2023-06-15", "2025-12-15"), "2 años, 6 meses"); // 25.9
    ASSERT_EQ("ES half marker", pt.format_age("2022-06-15", "2025-12-15"), "3 y medio años"); // 25.10
    ASSERT_EQ("ES integer years", pt.format_age("2022-06-15", "2025-06-15"), "3 años"); // 25.11
    ASSERT_EQ("ES 7+ years", pt.format_age("2018-06-15", "2025-06-15"), "7 años"); // 25.12

    ASSERT_EQ("ES stage newborn", pt.format_stage("2025-06-15", "2025-06-15"), "Recién nacido"); // 25.13
    ASSERT_EQ("ES stage infant", pt.format_stage("2025-01-15", "2025-06-15"), "Bebé"); // 25.14
    ASSERT_EQ("ES stage toddler", pt.format_stage("2024-06-15", "2025-06-15"), "Niño pequeño"); // 25.15
    ASSERT_EQ("ES stage child", pt.format_stage("2022-06-15", "2025-06-15"), "Niño"); // 25.16
    ASSERT_EQ("ES stage teenager", pt.format_stage("2012-06-15", "2025-06-15"), "Adolescente"); // 25.17
    ASSERT_EQ("ES stage adult", pt.format_stage("2007-06-15", "2025-06-15"), "Adulto"); // 25.18

    ASSERT_NULL("ES null", pt.format_age("")); // 25.19
    ASSERT_NULL("ES null stage", pt.format_stage("")); // 25.20
}

// ================================================================
// Compactness: short
// ================================================================
void test_compact_short() {
    SayableAge pt(locales::EN(), Compactness::Short);

    ASSERT_EQ("short days", pt.format_age("2025-06-12", "2025-06-15"), "3 d"); // 26.1
    ASSERT_EQ("short weeks", pt.format_age("2025-06-08", "2025-06-15"), "1 wk"); // 26.2
    ASSERT_EQ("short weeks+days", pt.format_age("2025-06-07", "2025-06-15"), "1 wk, 1 d"); // 26.3
    ASSERT_EQ("short months", pt.format_age("2025-01-15", "2025-07-15"), "6 mo"); // 26.4
    ASSERT_EQ("short years+months", pt.format_age("2023-06-15", "2025-07-15"), "2 yr, 1 mo"); // 26.5
    ASSERT_EQ("short half years", pt.format_age("2022-06-15", "2025-12-15"), "3½ yr"); // 26.6
    ASSERT_EQ("short integer years", pt.format_age("2018-06-15", "2025-06-15"), "7 yr"); // 26.7
    ASSERT_EQ("short justBorn unchanged", pt.format_age("2025-06-15", "2025-06-15"), "Newborn"); // 26.8
    ASSERT_EQ("short stages unchanged", pt.format_stage("2025-01-15", "2025-06-15"), "Infant"); // 26.9
}

// ================================================================
// Compactness: compact
// ================================================================
void test_compact_compact() {
    SayableAge pt(locales::EN(), Compactness::Compact);

    ASSERT_EQ("compact days", pt.format_age("2025-06-12", "2025-06-15"), "3d"); // 27.1
    ASSERT_EQ("compact weeks", pt.format_age("2025-06-08", "2025-06-15"), "1w"); // 27.2
    ASSERT_EQ("compact weeks+days no delimiter", pt.format_age("2025-06-07", "2025-06-15"), "1w1d"); // 27.3
    ASSERT_EQ("compact months", pt.format_age("2025-01-15", "2025-07-15"), "6m"); // 27.4
    ASSERT_EQ("compact years+months no delimiter", pt.format_age("2023-06-15", "2025-07-15"), "2y1m"); // 27.5
    ASSERT_EQ("compact half years", pt.format_age("2022-06-15", "2025-12-15"), "3½y"); // 27.6
    ASSERT_EQ("compact integer years", pt.format_age("2018-06-15", "2025-06-15"), "7y"); // 27.7
    ASSERT_EQ("compact justBorn unchanged", pt.format_age("2025-06-15", "2025-06-15"), "Newborn"); // 27.8
}

// ================================================================
// formatAge -- default asOf (uses current date)
// ================================================================
void test_default_as_of() {
    sayableage::testing::set_today(2025, 6, 15);
    ASSERT_EQ("default asOf 5 years", format_age("2020-01-01"), "5 years"); // 15.1
    ASSERT_EQ("default asOf 5 days", format_age("2025-06-10"), "5 days"); // 15.2
    sayableage::testing::clear_today();
}

// ================================================================
// formatStage -- default asOf (uses current date)
// ================================================================
void test_stage_default_as_of() {
    sayableage::testing::set_today(2025, 6, 15);
    ASSERT_EQ("stage default Newborn", format_stage("2025-06-15"), "Newborn"); // 23.1
    ASSERT_EQ("stage default Child", format_stage("2020-01-01"), "Child"); // 23.2
    ASSERT_EQ("stage default Adult", format_stage("1980-01-01"), "Adult"); // 23.3
    sayableage::testing::clear_today();
}

// ================================================================
// Section 29: Locale-specific edge cases — new plural rules
// ================================================================

void test_locale_hebrew() {
    SayableAge pt(locales::HE());

    ASSERT_EQ("he justBorn", pt.format_age("2025-06-15", "2025-06-15"), "רק נולד"); // 29.1
    ASSERT_EQ("he 1 day one", pt.format_age("2025-06-14", "2025-06-15"), "יום 1"); // 29.2
    ASSERT_EQ("he 3 days other", pt.format_age("2025-06-12", "2025-06-15"), "3 ימים"); // 29.3
    ASSERT_EQ("he 2 weeks dual", pt.format_age("2025-06-01", "2025-06-15"), "שבועיים"); // 29.4
    ASSERT_EQ("he 3 weeks other", pt.format_age("2025-05-25", "2025-06-15"), "3 שבועות"); // 29.5
    ASSERT_EQ("he 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 חודשים"); // 29.6
    ASSERT_EQ("he 3 months", pt.format_age("2025-03-15", "2025-06-15"), "3 חודשים"); // 29.7
    ASSERT_EQ("he 2y dual 1m one", pt.format_age("2023-06-15", "2025-07-15"), "שנתיים, חודש 1"); // 29.8
    ASSERT_EQ("he 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 שנים וחצי"); // 29.9
    ASSERT_EQ("he 7y other", pt.format_age("2018-06-15", "2025-06-15"), "7 שנים"); // 29.10
    ASSERT_EQ("he stage m newborn", pt.format_stage("2025-06-15", "2025-06-15", "m"), "רק נולד"); // 29.11
    ASSERT_EQ("he stage f newborn", pt.format_stage("2025-06-15", "2025-06-15", "f"), "רק נולדה"); // 29.12
    ASSERT_EQ("he stage m adult", pt.format_stage("2007-06-15", "2025-06-15", "m"), "מבוגר"); // 29.13
    ASSERT_EQ("he stage f adult", pt.format_stage("2007-06-15", "2025-06-15", "f"), "מבוגרת"); // 29.14
}

void test_locale_macedonian() {
    SayableAge pt(locales::MK());

    ASSERT_EQ("mk justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Новороденче"); // 29.15
    ASSERT_EQ("mk 1 day one", pt.format_age("2025-06-14", "2025-06-15"), "1 ден"); // 29.16
    ASSERT_EQ("mk 3 days other", pt.format_age("2025-06-12", "2025-06-15"), "3 дена"); // 29.17
    ASSERT_EQ("mk 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 месеци"); // 29.18
    ASSERT_EQ("mk 2y1m one month", pt.format_age("2023-06-15", "2025-07-15"), "2 години, 1 месец"); // 29.19
    ASSERT_EQ("mk 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 години и пол"); // 29.20
    ASSERT_EQ("mk 7y", pt.format_age("2018-06-15", "2025-06-15"), "7 години"); // 29.21
}

void test_locale_swahili() {
    SayableAge pt(locales::SW());

    ASSERT_EQ("sw justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Mzaliwa mpya"); // 29.22
    ASSERT_EQ("sw 1 day", pt.format_age("2025-06-14", "2025-06-15"), "siku 1"); // 29.23
    ASSERT_EQ("sw 3 days", pt.format_age("2025-06-12", "2025-06-15"), "siku 3"); // 29.24
    ASSERT_EQ("sw 6 months", pt.format_age("2025-01-15", "2025-07-15"), "miezi 6"); // 29.25
    ASSERT_EQ("sw 2y 1m", pt.format_age("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1"); // 29.26
    ASSERT_EQ("sw 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "miaka 3 na nusu"); // 29.27
}

void test_locale_indonesian() {
    SayableAge pt(locales::ID());

    ASSERT_EQ("id justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Baru lahir"); // 29.28
    ASSERT_EQ("id 1 day", pt.format_age("2025-06-14", "2025-06-15"), "1 hari"); // 29.29
    ASSERT_EQ("id 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 hari"); // 29.30
    ASSERT_EQ("id 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 bulan"); // 29.31
    ASSERT_EQ("id 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 tahun setengah"); // 29.32
    ASSERT_EQ("id 7y", pt.format_age("2018-06-15", "2025-06-15"), "7 tahun"); // 29.33
}

void test_locale_amharic() {
    SayableAge pt(locales::AM());

    ASSERT_EQ("am justBorn", pt.format_age("2025-06-15", "2025-06-15"), "አዲስ የተወለደ"); // 29.34
    ASSERT_EQ("am 1 day", pt.format_age("2025-06-14", "2025-06-15"), "1 ቀን"); // 29.35
    ASSERT_EQ("am 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 ቀናት"); // 29.36
    ASSERT_EQ("am 1w1d ethiopic", pt.format_age("2025-06-07", "2025-06-15"), "1 ሳምንት፣ 1 ቀን"); // 29.37
    ASSERT_EQ("am 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 ወራት"); // 29.38
    ASSERT_EQ("am 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 ዓመታት ተኩል"); // 29.39
}

// ================================================================
// Section 30: Locale lookup by code string
// ================================================================
void test_locale_lookup() {
    // 30.1 Known locale
    const auto* en_loc = locales::get("en");
    ASSERT_TRUE("get(en) not null", en_loc != nullptr);
    ASSERT_TRUE("get(en) code", en_loc->code == "en");

    // 30.2 Another known locale
    const auto* fr_loc = locales::get("fr");
    ASSERT_TRUE("get(fr) not null", fr_loc != nullptr);
    ASSERT_TRUE("get(fr) code", fr_loc->code == "fr");

    // 30.3 Unknown code
    ASSERT_TRUE("get(xx) null", locales::get("xx") == nullptr);

    // 30.4 Empty string
    ASSERT_TRUE("get('') null", locales::get("") == nullptr);

    // 30.5 Case-sensitive
    ASSERT_TRUE("get(EN) null", locales::get("EN") == nullptr);
}

// ================================================================
// Section 31: Weeks and days across month ends
// ================================================================
void test_section_31_weeks_and_days_across_month_ends() {
    ASSERT_EQ("31.1 88 days across a 28-day February", SayableAge(locales::EN(), Compactness::Normal).format_age("2016-12-31", "2017-03-29"), "12 weeks, 4 days"); // 31.1
    ASSERT_EQ("31.2 90 days across a year end into a leap year", SayableAge(locales::EN(), Compactness::Normal).format_age("1991-11-27", "1992-02-25"), "12 weeks, 6 days"); // 31.2
    ASSERT_EQ("31.3 33 days across a year end", SayableAge(locales::EN(), Compactness::Normal).format_age("2020-11-30", "2021-01-02"), "4 weeks, 5 days"); // 31.3
    ASSERT_EQ("31.4 Compact form of 31.1", SayableAge(locales::EN(), Compactness::Compact).format_age("2016-12-31", "2017-03-29"), "12w4d"); // 31.4
}

// ================================================================
// Section 32: Half years take their plural form from whole years
// ================================================================
void test_section_32_half_years_take_their_plural_form_from_whole_years() {
    ASSERT_EQ("32.1 Polish 3 is 'few'", SayableAge(locales::PL(), Compactness::Normal).format_age("2021-06-15", "2025-01-15"), "3 i p\303\263\305\202 lata"); // 32.1
    ASSERT_EQ("32.2 Polish 5 is 'many'", SayableAge(locales::PL(), Compactness::Short).format_age("2020-06-15", "2025-12-15"), "5 i p\303\263\305\202 lat"); // 32.2
    ASSERT_EQ("32.3 Tachelhit 6 is 'few'", SayableAge(locales::SHI(), Compactness::Normal).format_age("2005-06-08", "2012-06-07"), "6 iseggasen d uzgen"); // 32.3
}

// ================================================================
// Section 33: Input validation
// ================================================================
void test_section_33_input_validation() {
    ASSERT_NULL("33.1 February 30 doesn't exist", SayableAge(locales::EN(), Compactness::Normal).format_age("2025-02-30", "2032-06-25")); // 33.1
    ASSERT_NULL("33.2 Month 13", SayableAge(locales::EN(), Compactness::Normal).format_age("2025-13-01", "2027-01-31")); // 33.2
    ASSERT_NULL("33.3 February 29 in a non-leap year", SayableAge(locales::EN(), Compactness::Normal).format_age("2023-02-29", "2025-03-01")); // 33.3
    ASSERT_NULL("33.4 Day 00", SayableAge(locales::EN(), Compactness::Normal).format_age("2025-06-00", "2027-02-25")); // 33.4
    ASSERT_NULL("33.5 Unpadded month and day", SayableAge(locales::EN(), Compactness::Normal).format_age("2025-6-1", "2027-02-25")); // 33.5
    ASSERT_NULL("33.6 Surrounding whitespace", SayableAge(locales::EN(), Compactness::Normal).format_age(" 2025-06-01", "2027-02-25")); // 33.6
    ASSERT_NULL("33.7 A datetime is not a date", SayableAge(locales::EN(), Compactness::Normal).format_age("2025-06-15T10:00:00", "2027-02-25")); // 33.7
    ASSERT_NULL("33.8 Invalid asOf", SayableAge(locales::EN(), Compactness::Normal).format_age("2020-01-01", "2025-04-31")); // 33.8
    ASSERT_NULL("33.9 formatStage validates too", SayableAge(locales::EN(), Compactness::Normal).format_stage("2025-02-30", "2027-09-05")); // 33.9
    ASSERT_EQ("33.10 February 29 in a leap year is valid", SayableAge(locales::EN(), Compactness::Normal).format_age("2024-02-29", "2026-03-01"), "2 years"); // 33.10
}

int main() {
    test_null_edge_cases();
    test_days_tier();
    test_weeks_days_tier();
    test_month_boundary_standard();
    test_month_boundary_feb_non_leap();
    test_month_boundary_feb_leap();
    test_month_boundary_30day();
    test_leap_year_baby();
    test_months_tier();
    test_years_months_tier();
    test_half_year_tier();
    test_integer_tier();
    test_cross_year_feb();
    test_born_on_31st();
    test_stage_null_edge_cases();
    test_stage_newborn();
    test_stage_infant();
    test_stage_toddler();
    test_stage_child();
    test_stage_teenager();
    test_stage_adult();
    test_stage_gender_spanish();
    test_stage_gender_italian();
    test_stage_gender_arabic();
    test_stage_gender_neutral_locale();
    test_stage_gender_slovenian();
    test_sayableage_english();
    test_sayableage_spanish();
    test_compact_short();
    test_compact_compact();
    test_default_as_of();
    test_stage_default_as_of();
    test_locale_hebrew();
    test_locale_macedonian();
    test_locale_swahili();
    test_locale_indonesian();
    test_locale_amharic();
    test_locale_lookup();

    test_section_31_weeks_and_days_across_month_ends();
    test_section_32_half_years_take_their_plural_form_from_whole_years();
    test_section_33_input_validation();

    std::cout << "\n=== Results ===" << std::endl;
    std::cout << "Passed: " << tests_passed << std::endl;
    std::cout << "Failed: " << tests_failed << std::endl;
    std::cout << "Total:  " << (tests_passed + tests_failed) << std::endl;

    return tests_failed > 0 ? 1 : 0;
}
