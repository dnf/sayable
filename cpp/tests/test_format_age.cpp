#include "parenttime/parenttime.hpp"
#include "parenttime/locales.hpp"
#include "parenttime/testing.hpp"

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

using namespace parenttime;

// ================================================================
// formatAge -- null/edge cases
// ================================================================
void test_null_edge_cases() {
    ASSERT_NULL("empty string", format_age("", "2025-06-15"));
    ASSERT_NULL("future dob", format_age("2025-07-01", "2025-06-15"));
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================
void test_days_tier() {
    ASSERT_EQ("born today", format_age("2025-06-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("1 day ago", format_age("2025-06-14", "2025-06-15"), "1 day");
    ASSERT_EQ("3 days ago", format_age("2025-06-12", "2025-06-15"), "3 days");
    ASSERT_EQ("6 days ago", format_age("2025-06-09", "2025-06-15"), "6 days");
    ASSERT_EQ("7 days -> 1 week", format_age("2025-06-08", "2025-06-15"), "1 week");
}

// ================================================================
// formatAge -- weeks+days tier
// ================================================================
void test_weeks_days_tier() {
    ASSERT_EQ("7 days", format_age("2025-06-08", "2025-06-15"), "1 week");
    ASSERT_EQ("8 days", format_age("2025-06-07", "2025-06-15"), "1 week, 1 day");
    ASSERT_EQ("9 days", format_age("2025-06-06", "2025-06-15"), "1 week, 2 days");
    ASSERT_EQ("13 days", format_age("2025-06-02", "2025-06-15"), "1 week, 6 days");
    ASSERT_EQ("14 days", format_age("2025-06-01", "2025-06-15"), "2 weeks");
    ASSERT_EQ("15 days", format_age("2025-05-31", "2025-06-15"), "2 weeks, 1 day");
    ASSERT_EQ("20 days", format_age("2025-05-26", "2025-06-15"), "2 weeks, 6 days");
    ASSERT_EQ("21 days", format_age("2025-05-25", "2025-06-15"), "3 weeks");
    ASSERT_EQ("at 1 cal month still weeks+days", format_age("2025-05-15", "2025-06-15"), "4 weeks, 3 days");
    ASSERT_EQ("at 2 cal months still weeks+days", format_age("2025-04-15", "2025-06-15"), "8 weeks, 5 days");
    ASSERT_EQ("one day before 3mo still weeks", format_age("2025-03-15", "2025-06-14"), "13 weeks");
    ASSERT_EQ("on 3mo birthday switches", format_age("2025-03-15", "2025-06-15"), "3 months");
}

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================
void test_month_boundary_standard() {
    ASSERT_EQ("Jan1->Apr1=3mo", format_age("2025-01-01", "2025-04-01"), "3 months");
    ASSERT_CONTAINS("Jan1->Mar31 still weeks", format_age("2025-01-01", "2025-03-31"), "weeks");
    ASSERT_EQ("Jun15->Sep15=3mo", format_age("2025-06-15", "2025-09-15"), "3 months");
    ASSERT_CONTAINS("Jun15->Sep14 still weeks", format_age("2025-06-15", "2025-09-14"), "weeks");
    ASSERT_EQ("Jun15->Dec15=6mo", format_age("2025-06-15", "2025-12-15"), "6 months");
}

// ================================================================
// formatAge -- month boundaries: February non-leap
// ================================================================
void test_month_boundary_feb_non_leap() {
    ASSERT_EQ("Jan31->Feb28 non-leap", format_age("2025-01-31", "2025-02-28"), "4 weeks");
    ASSERT_EQ("Jan31->Apr30=3mo(clamp)", format_age("2025-01-31", "2025-04-30"), "3 months");
    ASSERT_CONTAINS("Jan31->Apr29 still weeks", format_age("2025-01-31", "2025-04-29"), "weeks");
    ASSERT_EQ("Feb1->May1=3mo", format_age("2025-02-01", "2025-05-01"), "3 months");
    ASSERT_CONTAINS("Feb1->Apr30 still weeks", format_age("2025-02-01", "2025-04-30"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================
void test_month_boundary_feb_leap() {
    ASSERT_EQ("Jan31->Feb29 leap", format_age("2024-01-31", "2024-02-29"), "4 weeks, 1 day");
    ASSERT_EQ("Jan31->Feb28 leap", format_age("2024-01-31", "2024-02-28"), "4 weeks");
    ASSERT_EQ("Jan31->Apr30 leap=3mo", format_age("2024-01-31", "2024-04-30"), "3 months");
    ASSERT_CONTAINS("Jan30->Feb29 leap still weeks", format_age("2024-01-30", "2024-02-29"), "weeks");
    ASSERT_CONTAINS("Jan30->Feb28 leap still weeks", format_age("2024-01-30", "2024-02-28"), "weeks");
}

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================
void test_month_boundary_30day() {
    ASSERT_EQ("Mar31->Jun30=3mo(clamped)", format_age("2025-03-31", "2025-06-30"), "3 months");
    ASSERT_CONTAINS("Mar31->Jun29 still weeks", format_age("2025-03-31", "2025-06-29"), "weeks");
    ASSERT_EQ("Aug31->Nov30=3mo", format_age("2025-08-31", "2025-11-30"), "3 months");
    ASSERT_CONTAINS("Aug31->Nov29 still weeks", format_age("2025-08-31", "2025-11-29"), "weeks");
}

// ================================================================
// formatAge -- leap year baby (born Feb 29)
// ================================================================
void test_leap_year_baby() {
    ASSERT_EQ("Feb29->May29=3mo", format_age("2024-02-29", "2024-05-29"), "3 months");
    ASSERT_CONTAINS("Feb29->May28 still weeks", format_age("2024-02-29", "2024-05-28"), "weeks");
    ASSERT_EQ("Feb29 2024->Feb28 2025=12mo", format_age("2024-02-29", "2025-02-28"), "12 months");
    ASSERT_EQ("Feb29 2024->Mar1 2025=12mo", format_age("2024-02-29", "2025-03-01"), "12 months");
}

// ================================================================
// formatAge -- months tier (3-23)
// ================================================================
void test_months_tier() {
    ASSERT_EQ("3 months at transition", format_age("2025-01-15", "2025-04-15"), "3 months");
    ASSERT_EQ("6 months", format_age("2025-01-15", "2025-07-15"), "6 months");
    ASSERT_EQ("12 months (not 1 year)", format_age("2024-06-15", "2025-06-15"), "12 months");
    ASSERT_EQ("23 months at upper", format_age("2024-01-15", "2025-12-15"), "23 months");
    ASSERT_EQ("one day before boundary", format_age("2025-01-15", "2025-07-14"), "5 months");
    ASSERT_EQ("crossing year boundary", format_age("2024-11-10", "2025-04-10"), "5 months");
}

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================
void test_years_months_tier() {
    ASSERT_EQ("2 years at 24mo", format_age("2023-06-15", "2025-06-15"), "2 years");
    ASSERT_EQ("2 years 1 month", format_age("2023-06-15", "2025-07-15"), "2 years, 1 month");
    ASSERT_EQ("2 years 6 months", format_age("2023-06-15", "2025-12-15"), "2 years, 6 months");
    ASSERT_EQ("2 years 11 months", format_age("2023-06-15", "2026-05-15"), "2 years, 11 months");
    ASSERT_EQ("one day before 24mo", format_age("2023-06-15", "2025-06-14"), "23 months");
}

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================
void test_half_year_tier() {
    ASSERT_EQ("3 years exactly", format_age("2022-06-15", "2025-06-15"), "3 years");
    ASSERT_EQ("3 years 5 months", format_age("2022-06-15", "2025-11-15"), "3 years");
    ASSERT_EQ("3.5 years at 3y6m", format_age("2022-06-15", "2025-12-15"), "3½ years");
    ASSERT_EQ("3.5 years at 3y11m", format_age("2022-06-15", "2026-05-15"), "3½ years");
    ASSERT_EQ("4 years exactly", format_age("2021-06-15", "2025-06-15"), "4 years");
    ASSERT_EQ("4.5 years", format_age("2021-06-15", "2025-12-15"), "4½ years");
    ASSERT_EQ("5 years", format_age("2020-06-15", "2025-06-15"), "5 years");
    ASSERT_EQ("5.5 years at 5y8m", format_age("2020-06-15", "2026-02-15"), "5½ years");
    ASSERT_EQ("6 years", format_age("2019-06-15", "2025-06-15"), "6 years");
    ASSERT_EQ("6.5 years", format_age("2019-06-15", "2025-12-15"), "6½ years");
    ASSERT_EQ("6.5 years at 6y11m", format_age("2019-06-15", "2026-05-15"), "6½ years");
    ASSERT_EQ("one day before 3rd bday", format_age("2022-06-15", "2025-06-14"), "2 years, 11 months");
}

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================
void test_integer_tier() {
    ASSERT_EQ("7 years exactly", format_age("2018-06-15", "2025-06-15"), "7 years");
    ASSERT_EQ("7 years 6 months (no half)", format_age("2018-03-20", "2025-06-15"), "7 years");
    ASSERT_EQ("45 years", format_age("1980-01-01", "2025-06-15"), "45 years");
}

// ================================================================
// formatAge -- cross-year with Feb
// ================================================================
void test_cross_year_feb() {
    ASSERT_EQ("Dec31->Mar31=3mo", format_age("2024-12-31", "2025-03-31"), "3 months");
    ASSERT_CONTAINS("Dec31->Mar30 still weeks", format_age("2024-12-31", "2025-03-30"), "weeks");
    ASSERT_EQ("Nov30->Feb28=3mo", format_age("2024-11-30", "2025-02-28"), "3 months");
    ASSERT_CONTAINS("Nov30->Feb27 still weeks", format_age("2024-11-30", "2025-02-27"), "weeks");
}

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================
void test_born_on_31st() {
    ASSERT_EQ("Jan31->Apr30=3mo", format_age("2025-01-31", "2025-04-30"), "3 months");
    ASSERT_EQ("Jan31->May31=4mo", format_age("2025-01-31", "2025-05-31"), "4 months");
    ASSERT_EQ("Jan31->Jun30=5mo(clamped)", format_age("2025-01-31", "2025-06-30"), "5 months");
    ASSERT_EQ("Jan31->Jul1=5mo", format_age("2025-01-31", "2025-07-01"), "5 months");
    ASSERT_EQ("Jan31->Jul31=6mo", format_age("2025-01-31", "2025-07-31"), "6 months");
}

// ================================================================
// formatStage
// ================================================================
void test_stage_null_edge_cases() {
    ASSERT_NULL("stage empty", format_stage("", "2025-06-15"));
    ASSERT_NULL("stage future", format_stage("2025-07-01", "2025-06-15"));
}

void test_stage_newborn() {
    ASSERT_EQ("stage born today", format_stage("2025-06-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("stage 1 day old", format_stage("2025-06-14", "2025-06-15"), "Newborn");
    ASSERT_EQ("stage 3 weeks old", format_stage("2025-05-25", "2025-06-15"), "Newborn");
    ASSERT_EQ("stage 1 month old", format_stage("2025-05-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("stage 1 month 29 days", format_stage("2025-04-16", "2025-06-15"), "Newborn");
    ASSERT_EQ("stage exactly 2 months -> Infant", format_stage("2025-04-15", "2025-06-15"), "Infant");
}

void test_stage_infant() {
    ASSERT_EQ("stage 2 months", format_stage("2025-04-15", "2025-06-15"), "Infant");
    ASSERT_EQ("stage 6 months", format_stage("2024-12-15", "2025-06-15"), "Infant");
    ASSERT_EQ("stage 11 months", format_stage("2024-07-15", "2025-06-15"), "Infant");
    ASSERT_EQ("stage exactly 12mo -> Toddler", format_stage("2024-06-15", "2025-06-15"), "Toddler");
}

void test_stage_toddler() {
    ASSERT_EQ("stage 12 months", format_stage("2024-06-15", "2025-06-15"), "Toddler");
    ASSERT_EQ("stage 18 months", format_stage("2024-01-15", "2025-07-15"), "Toddler");
    ASSERT_EQ("stage 24 months", format_stage("2023-06-15", "2025-06-15"), "Toddler");
    ASSERT_EQ("stage 35 months", format_stage("2023-06-15", "2026-05-15"), "Toddler");
    ASSERT_EQ("stage exactly 36mo -> Child", format_stage("2022-06-15", "2025-06-15"), "Child");
}

void test_stage_child() {
    ASSERT_EQ("stage 3 years", format_stage("2022-06-15", "2025-06-15"), "Child");
    ASSERT_EQ("stage 4 years", format_stage("2021-06-15", "2025-06-15"), "Child");
    ASSERT_EQ("stage 6 years", format_stage("2019-06-15", "2025-06-15"), "Child");
    ASSERT_EQ("stage 9 years", format_stage("2016-06-15", "2025-06-15"), "Child");
    ASSERT_EQ("stage 12y11mo", format_stage("2013-06-15", "2026-05-15"), "Child");
    ASSERT_EQ("stage exactly 13y -> Teenager", format_stage("2012-06-15", "2025-06-15"), "Teenager");
}

void test_stage_teenager() {
    ASSERT_EQ("stage 13 years", format_stage("2012-06-15", "2025-06-15"), "Teenager");
    ASSERT_EQ("stage 15 years", format_stage("2010-06-15", "2025-06-15"), "Teenager");
    ASSERT_EQ("stage 17y11mo", format_stage("2008-06-15", "2026-05-15"), "Teenager");
    ASSERT_EQ("stage exactly 18y -> Adult", format_stage("2007-06-15", "2025-06-15"), "Adult");
}

void test_stage_adult() {
    ASSERT_EQ("stage 18 years", format_stage("2007-06-15", "2025-06-15"), "Adult");
    ASSERT_EQ("stage 25 years", format_stage("2000-06-15", "2025-06-15"), "Adult");
    ASSERT_EQ("stage 45 years", format_stage("1980-01-01", "2025-06-15"), "Adult");
}

// ================================================================
// formatStage -- gender support
// ================================================================
void test_stage_gender_spanish() {
    ParentTime pt(locales::ES());

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
    ParentTime pt(locales::IT());

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
    ParentTime pt(locales::AR());

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
    ParentTime pt(locales::EN());
    ASSERT_EQ("EN stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Newborn");
    ASSERT_EQ("EN stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Adult");
}

void test_stage_gender_slovenian() {
    ParentTime pt(locales::SL());

    ASSERT_EQ("SL stage newborn m", pt.format_stage("2025-06-15", "2025-06-15"), "Novorojenček");
    ASSERT_EQ("SL stage newborn f", pt.format_stage("2025-06-15", "2025-06-15", "f"), "Novorojenčica");
    ASSERT_EQ("SL stage child m", pt.format_stage("2022-06-15", "2025-06-15"), "Otrok");
    ASSERT_EQ("SL stage child f", pt.format_stage("2022-06-15", "2025-06-15", "f"), "Otrok");
    ASSERT_EQ("SL stage adult m", pt.format_stage("2007-06-15", "2025-06-15"), "Odrasel");
    ASSERT_EQ("SL stage adult f", pt.format_stage("2007-06-15", "2025-06-15", "f"), "Odrasla");
}

// ================================================================
// ParentTime class with English locale
// ================================================================
void test_parenttime_english() {
    ParentTime pt(locales::EN());
    ASSERT_EQ("PT Newborn", pt.format_age("2025-06-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("PT 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 days");
    ASSERT_EQ("PT 1w1d", pt.format_age("2025-06-07", "2025-06-15"), "1 week, 1 day");
    ASSERT_EQ("PT 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 months");
    ASSERT_EQ("PT 2y1mo", pt.format_age("2023-06-15", "2025-07-15"), "2 years, 1 month");
    ASSERT_EQ("PT 3.5 years", pt.format_age("2022-06-15", "2025-12-15"), "3½ years");
    ASSERT_EQ("PT 7 years", pt.format_age("2018-06-15", "2025-06-15"), "7 years");

    ASSERT_EQ("PT stage Newborn", pt.format_stage("2025-06-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("PT stage Infant", pt.format_stage("2025-01-15", "2025-06-15"), "Infant");
    ASSERT_EQ("PT stage Toddler", pt.format_stage("2024-06-15", "2025-06-15"), "Toddler");
    ASSERT_EQ("PT stage Child", pt.format_stage("2022-06-15", "2025-06-15"), "Child");
    ASSERT_EQ("PT stage Teenager", pt.format_stage("2012-06-15", "2025-06-15"), "Teenager");
    ASSERT_EQ("PT stage Adult", pt.format_stage("2007-06-15", "2025-06-15"), "Adult");

    ASSERT_NULL("PT null age", pt.format_age(""));
    ASSERT_NULL("PT null stage", pt.format_stage(""));
}

// ================================================================
// ParentTime with Spanish locale
// ================================================================
void test_parenttime_spanish() {
    ParentTime pt(locales::ES());

    ASSERT_EQ("ES justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Recién nacido");
    ASSERT_EQ("ES singular day", pt.format_age("2025-06-14", "2025-06-15"), "1 día");
    ASSERT_EQ("ES plural days", pt.format_age("2025-06-12", "2025-06-15"), "3 días");
    ASSERT_EQ("ES singular week", pt.format_age("2025-06-08", "2025-06-15"), "1 semana");
    ASSERT_EQ("ES weeks+days", pt.format_age("2025-06-07", "2025-06-15"), "1 semana, 1 día");
    ASSERT_EQ("ES plural weeks+days", pt.format_age("2025-05-26", "2025-06-15"), "2 semanas, 6 días");
    ASSERT_EQ("ES months", pt.format_age("2025-01-15", "2025-07-15"), "6 meses");
    ASSERT_EQ("ES singular month compound", pt.format_age("2023-06-15", "2025-07-15"), "2 años, 1 mes");
    ASSERT_EQ("ES years+months", pt.format_age("2023-06-15", "2025-12-15"), "2 años, 6 meses");
    ASSERT_EQ("ES half marker", pt.format_age("2022-06-15", "2025-12-15"), "3 y medio años");
    ASSERT_EQ("ES integer years", pt.format_age("2022-06-15", "2025-06-15"), "3 años");
    ASSERT_EQ("ES 7+ years", pt.format_age("2018-06-15", "2025-06-15"), "7 años");

    ASSERT_EQ("ES stage newborn", pt.format_stage("2025-06-15", "2025-06-15"), "Recién nacido");
    ASSERT_EQ("ES stage infant", pt.format_stage("2025-01-15", "2025-06-15"), "Bebé");
    ASSERT_EQ("ES stage toddler", pt.format_stage("2024-06-15", "2025-06-15"), "Niño pequeño");
    ASSERT_EQ("ES stage child", pt.format_stage("2022-06-15", "2025-06-15"), "Niño");
    ASSERT_EQ("ES stage teenager", pt.format_stage("2012-06-15", "2025-06-15"), "Adolescente");
    ASSERT_EQ("ES stage adult", pt.format_stage("2007-06-15", "2025-06-15"), "Adulto");

    ASSERT_NULL("ES null", pt.format_age(""));
    ASSERT_NULL("ES null stage", pt.format_stage(""));
}

// ================================================================
// Compactness: short
// ================================================================
void test_compact_short() {
    ParentTime pt(locales::EN(), Compactness::Short);

    ASSERT_EQ("short days", pt.format_age("2025-06-12", "2025-06-15"), "3 d");
    ASSERT_EQ("short weeks", pt.format_age("2025-06-08", "2025-06-15"), "1 wk");
    ASSERT_EQ("short weeks+days", pt.format_age("2025-06-07", "2025-06-15"), "1 wk, 1 d");
    ASSERT_EQ("short months", pt.format_age("2025-01-15", "2025-07-15"), "6 mo");
    ASSERT_EQ("short years+months", pt.format_age("2023-06-15", "2025-07-15"), "2 yr, 1 mo");
    ASSERT_EQ("short half years", pt.format_age("2022-06-15", "2025-12-15"), "3½ yr");
    ASSERT_EQ("short integer years", pt.format_age("2018-06-15", "2025-06-15"), "7 yr");
    ASSERT_EQ("short justBorn unchanged", pt.format_age("2025-06-15", "2025-06-15"), "Newborn");
    ASSERT_EQ("short stages unchanged", pt.format_stage("2025-01-15", "2025-06-15"), "Infant");
}

// ================================================================
// Compactness: compact
// ================================================================
void test_compact_compact() {
    ParentTime pt(locales::EN(), Compactness::Compact);

    ASSERT_EQ("compact days", pt.format_age("2025-06-12", "2025-06-15"), "3d");
    ASSERT_EQ("compact weeks", pt.format_age("2025-06-08", "2025-06-15"), "1w");
    ASSERT_EQ("compact weeks+days no delimiter", pt.format_age("2025-06-07", "2025-06-15"), "1w1d");
    ASSERT_EQ("compact months", pt.format_age("2025-01-15", "2025-07-15"), "6m");
    ASSERT_EQ("compact years+months no delimiter", pt.format_age("2023-06-15", "2025-07-15"), "2y1m");
    ASSERT_EQ("compact half years", pt.format_age("2022-06-15", "2025-12-15"), "3½y");
    ASSERT_EQ("compact integer years", pt.format_age("2018-06-15", "2025-06-15"), "7y");
    ASSERT_EQ("compact justBorn unchanged", pt.format_age("2025-06-15", "2025-06-15"), "Newborn");
}

// ================================================================
// formatAge -- default asOf (uses current date)
// ================================================================
void test_default_as_of() {
    parenttime::testing::set_today(2025, 6, 15);
    ASSERT_EQ("default asOf 5 years", format_age("2020-01-01"), "5 years");
    ASSERT_EQ("default asOf 5 days", format_age("2025-06-10"), "5 days");
    parenttime::testing::clear_today();
}

// ================================================================
// formatStage -- default asOf (uses current date)
// ================================================================
void test_stage_default_as_of() {
    parenttime::testing::set_today(2025, 6, 15);
    ASSERT_EQ("stage default Newborn", format_stage("2025-06-15"), "Newborn");
    ASSERT_EQ("stage default Child", format_stage("2020-01-01"), "Child");
    ASSERT_EQ("stage default Adult", format_stage("1980-01-01"), "Adult");
    parenttime::testing::clear_today();
}

// ================================================================
// Section 29: Locale-specific edge cases — new plural rules
// ================================================================

void test_locale_hebrew() {
    ParentTime pt(locales::HE());

    ASSERT_EQ("he justBorn", pt.format_age("2025-06-15", "2025-06-15"), "רק נולד");
    ASSERT_EQ("he 1 day one", pt.format_age("2025-06-14", "2025-06-15"), "יום 1");
    ASSERT_EQ("he 3 days other", pt.format_age("2025-06-12", "2025-06-15"), "3 ימים");
    ASSERT_EQ("he 2 weeks dual", pt.format_age("2025-06-01", "2025-06-15"), "שבועיים");
    ASSERT_EQ("he 3 weeks other", pt.format_age("2025-05-25", "2025-06-15"), "3 שבועות");
    ASSERT_EQ("he 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 חודשים");
    ASSERT_EQ("he 3 months", pt.format_age("2025-03-15", "2025-06-15"), "3 חודשים");
    ASSERT_EQ("he 2y dual 1m one", pt.format_age("2023-06-15", "2025-07-15"), "שנתיים, חודש 1");
    ASSERT_EQ("he 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 שנים וחצי");
    ASSERT_EQ("he 7y other", pt.format_age("2018-06-15", "2025-06-15"), "7 שנים");
    ASSERT_EQ("he stage m newborn", pt.format_stage("2025-06-15", "2025-06-15", "m"), "רק נולד");
    ASSERT_EQ("he stage f newborn", pt.format_stage("2025-06-15", "2025-06-15", "f"), "רק נולדה");
    ASSERT_EQ("he stage m adult", pt.format_stage("2007-06-15", "2025-06-15", "m"), "מבוגר");
    ASSERT_EQ("he stage f adult", pt.format_stage("2007-06-15", "2025-06-15", "f"), "מבוגרת");
}

void test_locale_macedonian() {
    ParentTime pt(locales::MK());

    ASSERT_EQ("mk justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Новороденче");
    ASSERT_EQ("mk 1 day one", pt.format_age("2025-06-14", "2025-06-15"), "1 ден");
    ASSERT_EQ("mk 3 days other", pt.format_age("2025-06-12", "2025-06-15"), "3 дена");
    ASSERT_EQ("mk 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 месеци");
    ASSERT_EQ("mk 2y1m one month", pt.format_age("2023-06-15", "2025-07-15"), "2 години, 1 месец");
    ASSERT_EQ("mk 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 години и пол");
    ASSERT_EQ("mk 7y", pt.format_age("2018-06-15", "2025-06-15"), "7 години");
}

void test_locale_swahili() {
    ParentTime pt(locales::SW());

    ASSERT_EQ("sw justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Mzaliwa mpya");
    ASSERT_EQ("sw 1 day", pt.format_age("2025-06-14", "2025-06-15"), "siku 1");
    ASSERT_EQ("sw 3 days", pt.format_age("2025-06-12", "2025-06-15"), "siku 3");
    ASSERT_EQ("sw 6 months", pt.format_age("2025-01-15", "2025-07-15"), "miezi 6");
    ASSERT_EQ("sw 2y 1m", pt.format_age("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1");
    ASSERT_EQ("sw 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "miaka 3 na nusu");
}

void test_locale_indonesian() {
    ParentTime pt(locales::ID());

    ASSERT_EQ("id justBorn", pt.format_age("2025-06-15", "2025-06-15"), "Baru lahir");
    ASSERT_EQ("id 1 day", pt.format_age("2025-06-14", "2025-06-15"), "1 hari");
    ASSERT_EQ("id 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 hari");
    ASSERT_EQ("id 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 bulan");
    ASSERT_EQ("id 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 tahun setengah");
    ASSERT_EQ("id 7y", pt.format_age("2018-06-15", "2025-06-15"), "7 tahun");
}

void test_locale_amharic() {
    ParentTime pt(locales::AM());

    ASSERT_EQ("am justBorn", pt.format_age("2025-06-15", "2025-06-15"), "አዲስ የተወለደ");
    ASSERT_EQ("am 1 day", pt.format_age("2025-06-14", "2025-06-15"), "1 ቀን");
    ASSERT_EQ("am 3 days", pt.format_age("2025-06-12", "2025-06-15"), "3 ቀናት");
    ASSERT_EQ("am 1w1d ethiopic", pt.format_age("2025-06-07", "2025-06-15"), "1 ሳምንት፣ 1 ቀን");
    ASSERT_EQ("am 6 months", pt.format_age("2025-01-15", "2025-07-15"), "6 ወራት");
    ASSERT_EQ("am 3.5y half", pt.format_age("2022-06-15", "2025-12-15"), "3 ዓመታት ተኩል");
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
    test_parenttime_english();
    test_parenttime_spanish();
    test_compact_short();
    test_compact_compact();
    test_default_as_of();
    test_stage_default_as_of();
    test_locale_hebrew();
    test_locale_macedonian();
    test_locale_swahili();
    test_locale_indonesian();
    test_locale_amharic();

    std::cout << "\n=== Results ===" << std::endl;
    std::cout << "Passed: " << tests_passed << std::endl;
    std::cout << "Failed: " << tests_failed << std::endl;
    std::cout << "Total:  " << (tests_passed + tests_failed) << std::endl;

    return tests_failed > 0 ? 1 : 0;
}
