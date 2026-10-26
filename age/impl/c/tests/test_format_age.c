/*
 * sayable-age C test suite.
 * Tests are hosted (uses stdio for output) but the library is freestanding.
 */
#include "sayableage/sayableage.h"
#include "sayableage/locales.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

static int tests_passed = 0;
static int tests_failed = 0;

#define ASSERT_EQ(name, rc, buf, expected) do { \
    if ((rc) != 0) { \
        fprintf(stderr, "FAIL [%s]: got rc=%d, expected \"%s\"\n", (name), (rc), (expected)); \
        tests_failed++; \
    } else if (strcmp((buf), (expected)) != 0) { \
        fprintf(stderr, "FAIL [%s]: got \"%s\", expected \"%s\"\n", (name), (buf), (expected)); \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

#define ASSERT_NULL(name, rc) do { \
    if ((rc) != -1) { \
        fprintf(stderr, "FAIL [%s]: expected rc=-1 (null), got %d\n", (name), (rc)); \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

#define ASSERT_TRUE(name, cond) do { \
    if (!(cond)) { \
        fprintf(stderr, "FAIL [%s]: condition was false\n", (name)); \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

#define ASSERT_CONTAINS(name, rc, buf, substr) do { \
    if ((rc) != 0) { \
        fprintf(stderr, "FAIL [%s]: got rc=%d, expected string containing \"%s\"\n", (name), (rc), (substr)); \
        tests_failed++; \
    } else if (strstr((buf), (substr)) == NULL) { \
        fprintf(stderr, "FAIL [%s]: \"%s\" does not contain \"%s\"\n", (name), (buf), (substr)); \
        tests_failed++; \
    } else { tests_passed++; } \
} while(0)

/* Helper: format with default English locale, Normal compactness */
static int fmt(char *buf, size_t sz, const char *dob, const char *as_of) {
    return sa_format_age(buf, sz, &sa_locale_en, SA_NORMAL, dob, as_of);
}

/* ================================================================ */
/* formatAge -- null/edge cases                                     */
/* ================================================================ */
static void test_null_edge_cases(void) {
    char buf[256];
    int rc;
    ASSERT_NULL("empty string", fmt(buf, sizeof(buf), "", "2025-06-15")); // 1.1, 1.3
    ASSERT_NULL("future dob", fmt(buf, sizeof(buf), "2025-07-01", "2025-06-15")); // 1.4
    rc = fmt(buf, sizeof(buf), "1525-06-15", "2025-06-15");
    ASSERT_EQ("exactly 500 years", rc, buf, "500 years"); // 1.5
    ASSERT_NULL("501 years exceeds max", fmt(buf, sizeof(buf), "1524-06-15", "2025-06-15")); // 1.6
    ASSERT_NULL("1000 years exceeds max", fmt(buf, sizeof(buf), "1025-06-15", "2025-06-15")); // 1.7
}

/* ================================================================ */
/* formatAge -- days tier (0-6)                                     */
/* ================================================================ */
static void test_days_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-06-15", "2025-06-15");
    ASSERT_EQ("born today", rc, buf, "Newborn"); // 2.1
    rc = fmt(buf, sizeof(buf), "2025-06-14", "2025-06-15");
    ASSERT_EQ("1 day ago", rc, buf, "1 day"); // 2.2
    rc = fmt(buf, sizeof(buf), "2025-06-12", "2025-06-15");
    ASSERT_EQ("3 days ago", rc, buf, "3 days"); // 2.3
    rc = fmt(buf, sizeof(buf), "2025-06-09", "2025-06-15");
    ASSERT_EQ("6 days ago", rc, buf, "6 days"); // 2.4
    rc = fmt(buf, sizeof(buf), "2025-06-08", "2025-06-15");
    ASSERT_EQ("7 days -> 1 week", rc, buf, "1 week"); // 2.5
}

/* ================================================================ */
/* formatAge -- weeks+days tier                                     */
/* ================================================================ */
static void test_weeks_days_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-06-08", "2025-06-15");
    ASSERT_EQ("7 days", rc, buf, "1 week"); // 3.1
    rc = fmt(buf, sizeof(buf), "2025-06-07", "2025-06-15");
    ASSERT_EQ("8 days", rc, buf, "1 week, 1 day"); // 3.2
    rc = fmt(buf, sizeof(buf), "2025-06-06", "2025-06-15");
    ASSERT_EQ("9 days", rc, buf, "1 week, 2 days"); // 3.3
    rc = fmt(buf, sizeof(buf), "2025-06-02", "2025-06-15");
    ASSERT_EQ("13 days", rc, buf, "1 week, 6 days"); // 3.4
    rc = fmt(buf, sizeof(buf), "2025-06-01", "2025-06-15");
    ASSERT_EQ("14 days", rc, buf, "2 weeks"); // 3.5
    rc = fmt(buf, sizeof(buf), "2025-05-31", "2025-06-15");
    ASSERT_EQ("15 days", rc, buf, "2 weeks, 1 day"); // 3.6
    rc = fmt(buf, sizeof(buf), "2025-05-26", "2025-06-15");
    ASSERT_EQ("20 days", rc, buf, "2 weeks, 6 days"); // 3.7
    rc = fmt(buf, sizeof(buf), "2025-05-25", "2025-06-15");
    ASSERT_EQ("21 days", rc, buf, "3 weeks"); // 3.8
    rc = fmt(buf, sizeof(buf), "2025-05-15", "2025-06-15");
    ASSERT_EQ("at 1 cal month still weeks+days", rc, buf, "4 weeks, 3 days"); // 3.9
    rc = fmt(buf, sizeof(buf), "2025-04-15", "2025-06-15");
    ASSERT_EQ("at 2 cal months still weeks+days", rc, buf, "8 weeks, 5 days"); // 3.10
    rc = fmt(buf, sizeof(buf), "2025-03-15", "2025-06-14");
    ASSERT_EQ("one day before 3mo still weeks", rc, buf, "13 weeks"); // 3.11
    rc = fmt(buf, sizeof(buf), "2025-03-15", "2025-06-15");
    ASSERT_EQ("on 3mo birthday switches", rc, buf, "3 months"); // 3.12
}

/* ================================================================ */
/* formatAge -- month boundaries: standard months                   */
/* ================================================================ */
static void test_month_boundary_standard(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-01-01", "2025-04-01");
    ASSERT_EQ("Jan1->Apr1=3mo", rc, buf, "3 months"); // 4.1
    rc = fmt(buf, sizeof(buf), "2025-01-01", "2025-03-31");
    ASSERT_CONTAINS("Jan1->Mar31 still weeks", rc, buf, "weeks"); // 4.2
    rc = fmt(buf, sizeof(buf), "2025-06-15", "2025-09-15");
    ASSERT_EQ("Jun15->Sep15=3mo", rc, buf, "3 months"); // 4.3
    rc = fmt(buf, sizeof(buf), "2025-06-15", "2025-09-14");
    ASSERT_CONTAINS("Jun15->Sep14 still weeks", rc, buf, "weeks"); // 4.4
    rc = fmt(buf, sizeof(buf), "2025-06-15", "2025-12-15");
    ASSERT_EQ("Jun15->Dec15=6mo", rc, buf, "6 months"); // 4.5
}

/* ================================================================ */
/* formatAge -- month boundaries: February non-leap                 */
/* ================================================================ */
static void test_month_boundary_feb_non_leap(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-02-28");
    ASSERT_EQ("Jan31->Feb28 non-leap", rc, buf, "4 weeks"); // 5.1
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-04-30");
    ASSERT_EQ("Jan31->Apr30=3mo(clamp)", rc, buf, "3 months"); // 5.2
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-04-29");
    ASSERT_CONTAINS("Jan31->Apr29 still weeks", rc, buf, "weeks"); // 5.3
    rc = fmt(buf, sizeof(buf), "2025-02-01", "2025-05-01");
    ASSERT_EQ("Feb1->May1=3mo", rc, buf, "3 months"); // 5.4
    rc = fmt(buf, sizeof(buf), "2025-02-01", "2025-04-30");
    ASSERT_CONTAINS("Feb1->Apr30 still weeks", rc, buf, "weeks"); // 5.5
}

/* ================================================================ */
/* formatAge -- month boundaries: February leap year                */
/* ================================================================ */
static void test_month_boundary_feb_leap(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2024-01-31", "2024-02-29");
    ASSERT_EQ("Jan31->Feb29 leap", rc, buf, "4 weeks, 1 day"); // 6.1
    rc = fmt(buf, sizeof(buf), "2024-01-31", "2024-02-28");
    ASSERT_EQ("Jan31->Feb28 leap", rc, buf, "4 weeks"); // 6.2
    rc = fmt(buf, sizeof(buf), "2024-01-31", "2024-04-30");
    ASSERT_EQ("Jan31->Apr30 leap=3mo", rc, buf, "3 months"); // 6.3
    rc = fmt(buf, sizeof(buf), "2024-01-30", "2024-02-29");
    ASSERT_CONTAINS("Jan30->Feb29 leap still weeks", rc, buf, "weeks"); // 6.4
    rc = fmt(buf, sizeof(buf), "2024-01-30", "2024-02-28");
    ASSERT_CONTAINS("Jan30->Feb28 leap still weeks", rc, buf, "weeks"); // 6.5
}

/* ================================================================ */
/* formatAge -- month boundaries: 30-day months                     */
/* ================================================================ */
static void test_month_boundary_30day(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-03-31", "2025-06-30");
    ASSERT_EQ("Mar31->Jun30=3mo(clamped)", rc, buf, "3 months"); // 7.1
    rc = fmt(buf, sizeof(buf), "2025-03-31", "2025-06-29");
    ASSERT_CONTAINS("Mar31->Jun29 still weeks", rc, buf, "weeks"); // 7.2
    rc = fmt(buf, sizeof(buf), "2025-08-31", "2025-11-30");
    ASSERT_EQ("Aug31->Nov30=3mo", rc, buf, "3 months"); // 7.3
    rc = fmt(buf, sizeof(buf), "2025-08-31", "2025-11-29");
    ASSERT_CONTAINS("Aug31->Nov29 still weeks", rc, buf, "weeks"); // 7.4
}

/* ================================================================ */
/* formatAge -- leap year baby (born Feb 29)                        */
/* ================================================================ */
static void test_leap_year_baby(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2024-02-29", "2024-05-29");
    ASSERT_EQ("Feb29->May29=3mo", rc, buf, "3 months"); // 8.1
    rc = fmt(buf, sizeof(buf), "2024-02-29", "2024-05-28");
    ASSERT_CONTAINS("Feb29->May28 still weeks", rc, buf, "weeks"); // 8.2
    rc = fmt(buf, sizeof(buf), "2024-02-29", "2025-02-28");
    ASSERT_EQ("Feb29 2024->Feb28 2025=12mo", rc, buf, "12 months"); // 8.3
    rc = fmt(buf, sizeof(buf), "2024-02-29", "2025-03-01");
    ASSERT_EQ("Feb29 2024->Mar1 2025=12mo", rc, buf, "12 months"); // 8.4
}

/* ================================================================ */
/* formatAge -- months tier (3-23)                                  */
/* ================================================================ */
static void test_months_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-01-15", "2025-04-15");
    ASSERT_EQ("3 months at transition", rc, buf, "3 months"); // 9.1
    rc = fmt(buf, sizeof(buf), "2025-01-15", "2025-07-15");
    ASSERT_EQ("6 months", rc, buf, "6 months"); // 9.2
    rc = fmt(buf, sizeof(buf), "2024-06-15", "2025-06-15");
    ASSERT_EQ("12 months (not 1 year)", rc, buf, "12 months"); // 9.3
    rc = fmt(buf, sizeof(buf), "2024-01-15", "2025-12-15");
    ASSERT_EQ("23 months at upper", rc, buf, "23 months"); // 9.4
    rc = fmt(buf, sizeof(buf), "2025-01-15", "2025-07-14");
    ASSERT_EQ("one day before boundary", rc, buf, "5 months"); // 9.5
    rc = fmt(buf, sizeof(buf), "2024-11-10", "2025-04-10");
    ASSERT_EQ("crossing year boundary", rc, buf, "5 months"); // 9.6
}

/* ================================================================ */
/* formatAge -- years+months tier (24-35 months)                    */
/* ================================================================ */
static void test_years_months_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2023-06-15", "2025-06-15");
    ASSERT_EQ("2 years at 24mo", rc, buf, "2 years"); // 10.1
    rc = fmt(buf, sizeof(buf), "2023-06-15", "2025-07-15");
    ASSERT_EQ("2 years 1 month", rc, buf, "2 years, 1 month"); // 10.2
    rc = fmt(buf, sizeof(buf), "2023-06-15", "2025-12-15");
    ASSERT_EQ("2 years 6 months", rc, buf, "2 years, 6 months"); // 10.3
    rc = fmt(buf, sizeof(buf), "2023-06-15", "2026-05-15");
    ASSERT_EQ("2 years 11 months", rc, buf, "2 years, 11 months"); // 10.4
    rc = fmt(buf, sizeof(buf), "2023-06-15", "2025-06-14");
    ASSERT_EQ("one day before 24mo", rc, buf, "23 months"); // 10.5
}

/* ================================================================ */
/* formatAge -- half-year tier (3-6 years)                          */
/* ================================================================ */
static void test_half_year_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2022-06-15", "2025-06-15");
    ASSERT_EQ("3 years exactly", rc, buf, "3 years"); // 11.1
    rc = fmt(buf, sizeof(buf), "2022-06-15", "2025-11-15");
    ASSERT_EQ("3 years 5 months", rc, buf, "3 years"); // 11.2
    rc = fmt(buf, sizeof(buf), "2022-06-15", "2025-12-15");
    ASSERT_EQ("3.5 years at 3y6m", rc, buf, "3\xc2\xbd years"); // 11.3
    rc = fmt(buf, sizeof(buf), "2022-06-15", "2026-05-15");
    ASSERT_EQ("3.5 years at 3y11m", rc, buf, "3\xc2\xbd years"); // 11.4
    rc = fmt(buf, sizeof(buf), "2021-06-15", "2025-06-15");
    ASSERT_EQ("4 years exactly", rc, buf, "4 years"); // 11.5
    rc = fmt(buf, sizeof(buf), "2021-06-15", "2025-12-15");
    ASSERT_EQ("4.5 years", rc, buf, "4\xc2\xbd years"); // 11.6
    rc = fmt(buf, sizeof(buf), "2020-06-15", "2025-06-15");
    ASSERT_EQ("5 years", rc, buf, "5 years"); // 11.7
    rc = fmt(buf, sizeof(buf), "2020-06-15", "2026-02-15");
    ASSERT_EQ("5.5 years at 5y8m", rc, buf, "5\xc2\xbd years"); // 11.8
    rc = fmt(buf, sizeof(buf), "2019-06-15", "2025-06-15");
    ASSERT_EQ("6 years", rc, buf, "6 years"); // 11.9
    rc = fmt(buf, sizeof(buf), "2019-06-15", "2025-12-15");
    ASSERT_EQ("6.5 years", rc, buf, "6\xc2\xbd years"); // 11.10
    rc = fmt(buf, sizeof(buf), "2019-06-15", "2026-05-15");
    ASSERT_EQ("6.5 years at 6y11m", rc, buf, "6\xc2\xbd years"); // 11.11
    rc = fmt(buf, sizeof(buf), "2022-06-15", "2025-06-14");
    ASSERT_EQ("one day before 3rd bday", rc, buf, "2 years, 11 months"); // 11.12
}

/* ================================================================ */
/* formatAge -- integer tier (7+ years)                             */
/* ================================================================ */
static void test_integer_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2018-06-15", "2025-06-15");
    ASSERT_EQ("7 years exactly", rc, buf, "7 years"); // 12.1
    rc = fmt(buf, sizeof(buf), "2018-03-20", "2025-06-15");
    ASSERT_EQ("7 years 6 months (no half)", rc, buf, "7 years"); // 12.2
    rc = fmt(buf, sizeof(buf), "1980-01-01", "2025-06-15");
    ASSERT_EQ("45 years", rc, buf, "45 years"); // 12.3
}

/* ================================================================ */
/* formatAge -- cross-year with Feb                                 */
/* ================================================================ */
static void test_cross_year_feb(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2024-12-31", "2025-03-31");
    ASSERT_EQ("Dec31->Mar31=3mo", rc, buf, "3 months"); // 13.1
    rc = fmt(buf, sizeof(buf), "2024-12-31", "2025-03-30");
    ASSERT_CONTAINS("Dec31->Mar30 still weeks", rc, buf, "weeks"); // 13.2
    rc = fmt(buf, sizeof(buf), "2024-11-30", "2025-02-28");
    ASSERT_EQ("Nov30->Feb28=3mo", rc, buf, "3 months"); // 13.3
    rc = fmt(buf, sizeof(buf), "2024-11-30", "2025-02-27");
    ASSERT_CONTAINS("Nov30->Feb27 still weeks", rc, buf, "weeks"); // 13.4
}

/* ================================================================ */
/* formatAge -- born-on-31st progression                            */
/* ================================================================ */
static void test_born_on_31st(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-04-30");
    ASSERT_EQ("Jan31->Apr30=3mo", rc, buf, "3 months"); // 14.1
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-05-31");
    ASSERT_EQ("Jan31->May31=4mo", rc, buf, "4 months"); // 14.2
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-06-30");
    ASSERT_EQ("Jan31->Jun30=5mo(clamped)", rc, buf, "5 months"); // 14.3
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-07-01");
    ASSERT_EQ("Jan31->Jul1=5mo", rc, buf, "5 months"); // 14.4
    rc = fmt(buf, sizeof(buf), "2025-01-31", "2025-07-31");
    ASSERT_EQ("Jan31->Jul31=6mo", rc, buf, "6 months"); // 14.5
}

/* ================================================================ */
/* formatStage                                                      */
/* ================================================================ */
static void test_stage_null_edge_cases(void) {
    ASSERT_TRUE("stage empty", sa_stage(&sa_locale_en, "", "2025-06-15", "") == NULL); // 16.1, 16.3
    ASSERT_TRUE("stage future", sa_stage(&sa_locale_en, "2025-07-01", "2025-06-15", "") == NULL); // 16.4
    ASSERT_TRUE("stage 500 years", strcmp(sa_stage(&sa_locale_en, "1525-06-15", "2025-06-15", ""), "Adult") == 0); // 16.5
    ASSERT_TRUE("stage 501 years exceeds max", sa_stage(&sa_locale_en, "1524-06-15", "2025-06-15", "") == NULL); // 16.6
}

static void test_stage_newborn(void) {
    ASSERT_TRUE("stage born today", strcmp(sa_stage(&sa_locale_en, "2025-06-15", "2025-06-15", ""), "Newborn") == 0); // 17.1
    ASSERT_TRUE("stage 1 day old", strcmp(sa_stage(&sa_locale_en, "2025-06-14", "2025-06-15", ""), "Newborn") == 0); // 17.2
    ASSERT_TRUE("stage 3 weeks old", strcmp(sa_stage(&sa_locale_en, "2025-05-25", "2025-06-15", ""), "Newborn") == 0); // 17.3
    ASSERT_TRUE("stage 1 month old", strcmp(sa_stage(&sa_locale_en, "2025-05-15", "2025-06-15", ""), "Newborn") == 0); // 17.4
    ASSERT_TRUE("stage 1 month 29 days", strcmp(sa_stage(&sa_locale_en, "2025-04-16", "2025-06-15", ""), "Newborn") == 0); // 17.5
    ASSERT_TRUE("stage exactly 2 months -> Infant", strcmp(sa_stage(&sa_locale_en, "2025-04-15", "2025-06-15", ""), "Infant") == 0); // 17.6
}

static void test_stage_infant(void) {
    ASSERT_TRUE("stage 2 months", strcmp(sa_stage(&sa_locale_en, "2025-04-15", "2025-06-15", ""), "Infant") == 0); // 18.1
    ASSERT_TRUE("stage 6 months", strcmp(sa_stage(&sa_locale_en, "2024-12-15", "2025-06-15", ""), "Infant") == 0); // 18.2
    ASSERT_TRUE("stage 11 months", strcmp(sa_stage(&sa_locale_en, "2024-07-15", "2025-06-15", ""), "Infant") == 0); // 18.3
    ASSERT_TRUE("stage exactly 12mo -> Toddler", strcmp(sa_stage(&sa_locale_en, "2024-06-15", "2025-06-15", ""), "Toddler") == 0); // 18.4
}

static void test_stage_toddler(void) {
    ASSERT_TRUE("stage 12 months", strcmp(sa_stage(&sa_locale_en, "2024-06-15", "2025-06-15", ""), "Toddler") == 0); // 19.1
    ASSERT_TRUE("stage 18 months", strcmp(sa_stage(&sa_locale_en, "2024-01-15", "2025-07-15", ""), "Toddler") == 0); // 19.2
    ASSERT_TRUE("stage 24 months", strcmp(sa_stage(&sa_locale_en, "2023-06-15", "2025-06-15", ""), "Toddler") == 0); // 19.3
    ASSERT_TRUE("stage 35 months", strcmp(sa_stage(&sa_locale_en, "2023-06-15", "2026-05-15", ""), "Toddler") == 0); // 19.4
    ASSERT_TRUE("stage exactly 36mo -> Child", strcmp(sa_stage(&sa_locale_en, "2022-06-15", "2025-06-15", ""), "Child") == 0); // 19.5
}

static void test_stage_child(void) {
    ASSERT_TRUE("stage 3 years", strcmp(sa_stage(&sa_locale_en, "2022-06-15", "2025-06-15", ""), "Child") == 0); // 20.1
    ASSERT_TRUE("stage 4 years", strcmp(sa_stage(&sa_locale_en, "2021-06-15", "2025-06-15", ""), "Child") == 0); // 20.2
    ASSERT_TRUE("stage 6 years", strcmp(sa_stage(&sa_locale_en, "2019-06-15", "2025-06-15", ""), "Child") == 0); // 20.3
    ASSERT_TRUE("stage 9 years", strcmp(sa_stage(&sa_locale_en, "2016-06-15", "2025-06-15", ""), "Child") == 0); // 20.4
    ASSERT_TRUE("stage 12y11mo", strcmp(sa_stage(&sa_locale_en, "2013-06-15", "2026-05-15", ""), "Child") == 0); // 20.5
    ASSERT_TRUE("stage exactly 13y -> Teenager", strcmp(sa_stage(&sa_locale_en, "2012-06-15", "2025-06-15", ""), "Teenager") == 0); // 20.6
}

static void test_stage_teenager(void) {
    ASSERT_TRUE("stage 13 years", strcmp(sa_stage(&sa_locale_en, "2012-06-15", "2025-06-15", ""), "Teenager") == 0); // 21.1
    ASSERT_TRUE("stage 15 years", strcmp(sa_stage(&sa_locale_en, "2010-06-15", "2025-06-15", ""), "Teenager") == 0); // 21.2
    ASSERT_TRUE("stage 17y11mo", strcmp(sa_stage(&sa_locale_en, "2008-06-15", "2026-05-15", ""), "Teenager") == 0); // 21.3
    ASSERT_TRUE("stage exactly 18y -> Adult", strcmp(sa_stage(&sa_locale_en, "2007-06-15", "2025-06-15", ""), "Adult") == 0); // 21.4
}

static void test_stage_adult(void) {
    ASSERT_TRUE("stage 18 years", strcmp(sa_stage(&sa_locale_en, "2007-06-15", "2025-06-15", ""), "Adult") == 0); // 22.1
    ASSERT_TRUE("stage 25 years", strcmp(sa_stage(&sa_locale_en, "2000-06-15", "2025-06-15", ""), "Adult") == 0); // 22.2
    ASSERT_TRUE("stage 45 years", strcmp(sa_stage(&sa_locale_en, "1980-01-01", "2025-06-15", ""), "Adult") == 0); // 22.3
}

/* ================================================================ */
/* formatStage -- gender support                                    */
/* ================================================================ */
static void test_stage_gender_spanish(void) {
    // 25.13
    ASSERT_TRUE("ES stage newborn m", strcmp(sa_stage(&sa_locale_es, "2025-06-15", "2025-06-15", ""), "Reci\xc3\xa9n nacido") == 0);
    // 25.15
    ASSERT_TRUE("ES stage toddler m", strcmp(sa_stage(&sa_locale_es, "2024-06-15", "2025-06-15", ""), "Ni\xc3\xb1o peque\xc3\xb1o") == 0);
    // 25.16
    ASSERT_TRUE("ES stage child m", strcmp(sa_stage(&sa_locale_es, "2022-06-15", "2025-06-15", ""), "Ni\xc3\xb1o") == 0);
    // 25.18
    ASSERT_TRUE("ES stage adult m", strcmp(sa_stage(&sa_locale_es, "2007-06-15", "2025-06-15", ""), "Adulto") == 0);

    ASSERT_TRUE("ES stage newborn f", strcmp(sa_stage(&sa_locale_es, "2025-06-15", "2025-06-15", "f"), "Reci\xc3\xa9n nacida") == 0);
    // 25.14
    ASSERT_TRUE("ES stage infant f", strcmp(sa_stage(&sa_locale_es, "2025-01-15", "2025-06-15", "f"), "Beb\xc3\xa9") == 0);
    ASSERT_TRUE("ES stage toddler f", strcmp(sa_stage(&sa_locale_es, "2024-06-15", "2025-06-15", "f"), "Ni\xc3\xb1" "a peque\xc3\xb1" "a") == 0);
    ASSERT_TRUE("ES stage child f", strcmp(sa_stage(&sa_locale_es, "2022-06-15", "2025-06-15", "f"), "Ni\xc3\xb1" "a") == 0);
    // 25.17
    ASSERT_TRUE("ES stage teenager f", strcmp(sa_stage(&sa_locale_es, "2012-06-15", "2025-06-15", "f"), "Adolescente") == 0);
    ASSERT_TRUE("ES stage adult f", strcmp(sa_stage(&sa_locale_es, "2007-06-15", "2025-06-15", "f"), "Adulta") == 0);
}

static void test_stage_gender_italian(void) {
    ASSERT_TRUE("IT stage newborn m", strcmp(sa_stage(&sa_locale_it, "2025-06-15", "2025-06-15", ""), "Neonato") == 0);
    ASSERT_TRUE("IT stage toddler m", strcmp(sa_stage(&sa_locale_it, "2024-06-15", "2025-06-15", ""), "Bimbo") == 0);
    ASSERT_TRUE("IT stage child m", strcmp(sa_stage(&sa_locale_it, "2022-06-15", "2025-06-15", ""), "Bambino") == 0);

    ASSERT_TRUE("IT stage newborn f", strcmp(sa_stage(&sa_locale_it, "2025-06-15", "2025-06-15", "f"), "Neonata") == 0);
    ASSERT_TRUE("IT stage infant f", strcmp(sa_stage(&sa_locale_it, "2025-01-15", "2025-06-15", "f"), "Lattante") == 0);
    ASSERT_TRUE("IT stage toddler f", strcmp(sa_stage(&sa_locale_it, "2024-06-15", "2025-06-15", "f"), "Bimba") == 0);
    ASSERT_TRUE("IT stage child f", strcmp(sa_stage(&sa_locale_it, "2022-06-15", "2025-06-15", "f"), "Bambina") == 0);
    ASSERT_TRUE("IT stage adult f", strcmp(sa_stage(&sa_locale_it, "2007-06-15", "2025-06-15", "f"), "Adulta") == 0);
}

static void test_stage_gender_arabic(void) {
    ASSERT_TRUE("AR stage newborn m", strcmp(sa_stage(&sa_locale_ar, "2025-06-15", "2025-06-15", ""), "\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage infant m", strcmp(sa_stage(&sa_locale_ar, "2025-01-15", "2025-06-15", ""), "\xd8\xb1\xd8\xb6\xd9\x8a\xd8\xb9") == 0);
    ASSERT_TRUE("AR stage teenager m", strcmp(sa_stage(&sa_locale_ar, "2012-06-15", "2025-06-15", ""), "\xd9\x85\xd8\xb1\xd8\xa7\xd9\x87\xd9\x82") == 0);

    ASSERT_TRUE("AR stage newborn f", strcmp(sa_stage(&sa_locale_ar, "2025-06-15", "2025-06-15", "f"), "\xd8\xad\xd8\xaf\xd9\x8a\xd8\xab\xd8\xa9 \xd8\xa7\xd9\x84\xd9\x88\xd9\x84\xd8\xa7\xd8\xaf\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage infant f", strcmp(sa_stage(&sa_locale_ar, "2025-01-15", "2025-06-15", "f"), "\xd8\xb1\xd8\xb6\xd9\x8a\xd8\xb9\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage toddler f", strcmp(sa_stage(&sa_locale_ar, "2024-06-15", "2025-06-15", "f"), "\xd8\xb7\xd9\x81\xd9\x84\xd8\xa9 \xd8\xb5\xd8\xba\xd9\x8a\xd8\xb1\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage child f", strcmp(sa_stage(&sa_locale_ar, "2022-06-15", "2025-06-15", "f"), "\xd8\xb7\xd9\x81\xd9\x84\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage teenager f", strcmp(sa_stage(&sa_locale_ar, "2012-06-15", "2025-06-15", "f"), "\xd9\x85\xd8\xb1\xd8\xa7\xd9\x87\xd9\x82\xd8\xa9") == 0);
    ASSERT_TRUE("AR stage adult f", strcmp(sa_stage(&sa_locale_ar, "2007-06-15", "2025-06-15", "f"), "\xd8\xa8\xd8\xa7\xd9\x84\xd8\xba\xd8\xa9") == 0);
}

static void test_stage_gender_neutral_locale(void) {
    ASSERT_TRUE("EN stage newborn f", strcmp(sa_stage(&sa_locale_en, "2025-06-15", "2025-06-15", "f"), "Newborn") == 0);
    ASSERT_TRUE("EN stage adult f", strcmp(sa_stage(&sa_locale_en, "2007-06-15", "2025-06-15", "f"), "Adult") == 0);
}

static void test_stage_gender_slovenian(void) {
    ASSERT_TRUE("SL stage newborn m", strcmp(sa_stage(&sa_locale_sl, "2025-06-15", "2025-06-15", ""), "Novorojen\xc4\x8d" "ek") == 0);
    ASSERT_TRUE("SL stage newborn f", strcmp(sa_stage(&sa_locale_sl, "2025-06-15", "2025-06-15", "f"), "Novorojen\xc4\x8d" "ica") == 0);
    ASSERT_TRUE("SL stage child m", strcmp(sa_stage(&sa_locale_sl, "2022-06-15", "2025-06-15", ""), "Otrok") == 0);
    ASSERT_TRUE("SL stage child f", strcmp(sa_stage(&sa_locale_sl, "2022-06-15", "2025-06-15", "f"), "Otrok") == 0);
    ASSERT_TRUE("SL stage adult m", strcmp(sa_stage(&sa_locale_sl, "2007-06-15", "2025-06-15", ""), "Odrasel") == 0);
    ASSERT_TRUE("SL stage adult f", strcmp(sa_stage(&sa_locale_sl, "2007-06-15", "2025-06-15", "f"), "Odrasla") == 0);
}

/* ================================================================ */
/* SayableAge with English locale                                   */
/* ================================================================ */
static void test_sayableage_english(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("PT Newborn", rc, buf, "Newborn"); // 24.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("PT 3 days", rc, buf, "3 days"); // 24.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-06-07", "2025-06-15");
    ASSERT_EQ("PT 1w1d", rc, buf, "1 week, 1 day"); // 24.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("PT 6 months", rc, buf, "6 months"); // 24.4
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2023-06-15", "2025-07-15");
    ASSERT_EQ("PT 2y1mo", rc, buf, "2 years, 1 month"); // 24.5
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("PT 3.5 years", rc, buf, "3\xc2\xbd years"); // 24.6
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2018-06-15", "2025-06-15");
    ASSERT_EQ("PT 7 years", rc, buf, "7 years"); // 24.7

    ASSERT_TRUE("PT stage Newborn", strcmp(sa_stage(&sa_locale_en, "2025-06-15", "2025-06-15", ""), "Newborn") == 0); // 24.8
    ASSERT_TRUE("PT stage Infant", strcmp(sa_stage(&sa_locale_en, "2025-01-15", "2025-06-15", ""), "Infant") == 0); // 24.9
    ASSERT_TRUE("PT stage Toddler", strcmp(sa_stage(&sa_locale_en, "2024-06-15", "2025-06-15", ""), "Toddler") == 0); // 24.10
    ASSERT_TRUE("PT stage Child", strcmp(sa_stage(&sa_locale_en, "2022-06-15", "2025-06-15", ""), "Child") == 0); // 24.11
    ASSERT_TRUE("PT stage Teenager", strcmp(sa_stage(&sa_locale_en, "2012-06-15", "2025-06-15", ""), "Teenager") == 0); // 24.12
    ASSERT_TRUE("PT stage Adult", strcmp(sa_stage(&sa_locale_en, "2007-06-15", "2025-06-15", ""), "Adult") == 0); // 24.13

    ASSERT_NULL("PT null age", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "", "2025-06-15")); // 24.14
    ASSERT_TRUE("PT null stage", sa_stage(&sa_locale_en, "", "2025-06-15", "") == NULL); // 24.15
}

/* ================================================================ */
/* SayableAge with Spanish locale                                   */
/* ================================================================ */
static void test_sayableage_spanish(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("ES justBorn", rc, buf, "Reci\xc3\xa9n nacido"); // 25.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("ES singular day", rc, buf, "1 d\xc3\xad" "a"); // 25.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("ES plural days", rc, buf, "3 d\xc3\xad" "as"); // 25.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-06-08", "2025-06-15");
    ASSERT_EQ("ES singular week", rc, buf, "1 semana"); // 25.4
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-06-07", "2025-06-15");
    ASSERT_EQ("ES weeks+days", rc, buf, "1 semana, 1 d\xc3\xad" "a"); // 25.5
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-05-26", "2025-06-15");
    ASSERT_EQ("ES plural weeks+days", rc, buf, "2 semanas, 6 d\xc3\xad" "as"); // 25.6
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("ES months", rc, buf, "6 meses"); // 25.7
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2023-06-15", "2025-07-15");
    ASSERT_EQ("ES singular month compound", rc, buf, "2 a\xc3\xb1os, 1 mes"); // 25.8
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2023-06-15", "2025-12-15");
    ASSERT_EQ("ES years+months", rc, buf, "2 a\xc3\xb1os, 6 meses"); // 25.9
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("ES half marker", rc, buf, "3 a\xc3\xb1os y medio"); // 25.10
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2022-06-15", "2025-06-15");
    ASSERT_EQ("ES integer years", rc, buf, "3 a\xc3\xb1os"); // 25.11
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "2018-06-15", "2025-06-15");
    ASSERT_EQ("ES 7+ years", rc, buf, "7 a\xc3\xb1os"); // 25.12

    ASSERT_NULL("ES null", sa_format_age(buf, sizeof(buf), &sa_locale_es, SA_NORMAL, "", "2025-06-15")); // 25.19
    ASSERT_TRUE("ES null stage", sa_stage(&sa_locale_es, "", "2025-06-15", "") == NULL); // 25.20
}

/* ================================================================ */
/* Compactness: short                                               */
/* ================================================================ */
static void test_compact_short(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2025-06-12", "2025-06-15");
    ASSERT_EQ("short days", rc, buf, "3 d"); // 26.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2025-06-08", "2025-06-15");
    ASSERT_EQ("short weeks", rc, buf, "1 wk"); // 26.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2025-06-07", "2025-06-15");
    ASSERT_EQ("short weeks+days", rc, buf, "1 wk, 1 d"); // 26.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2025-01-15", "2025-07-15");
    ASSERT_EQ("short months", rc, buf, "6 mo"); // 26.4
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2023-06-15", "2025-07-15");
    ASSERT_EQ("short years+months", rc, buf, "2 yr, 1 mo"); // 26.5
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2022-06-15", "2025-12-15");
    ASSERT_EQ("short half years", rc, buf, "3\xc2\xbd yr"); // 26.6
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2018-06-15", "2025-06-15");
    ASSERT_EQ("short integer years", rc, buf, "7 yr"); // 26.7
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_SHORT, "2025-06-15", "2025-06-15");
    ASSERT_EQ("short justBorn unchanged", rc, buf, "Newborn"); // 26.8
    ASSERT_TRUE("short stages unchanged", strcmp(sa_stage(&sa_locale_en, "2025-01-15", "2025-06-15", ""), "Infant") == 0); // 26.9
}

/* ================================================================ */
/* Compactness: compact                                             */
/* ================================================================ */
static void test_compact_compact(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2025-06-12", "2025-06-15");
    ASSERT_EQ("compact days", rc, buf, "3d"); // 27.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2025-06-08", "2025-06-15");
    ASSERT_EQ("compact weeks", rc, buf, "1w"); // 27.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2025-06-07", "2025-06-15");
    ASSERT_EQ("compact weeks+days no delimiter", rc, buf, "1w1d"); // 27.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2025-01-15", "2025-07-15");
    ASSERT_EQ("compact months", rc, buf, "6m"); // 27.4
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2023-06-15", "2025-07-15");
    ASSERT_EQ("compact years+months no delimiter", rc, buf, "2y1m"); // 27.5
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2022-06-15", "2025-12-15");
    ASSERT_EQ("compact half years", rc, buf, "3\xc2\xbd" "y"); // 27.6
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2018-06-15", "2025-06-15");
    ASSERT_EQ("compact integer years", rc, buf, "7y"); // 27.7
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2025-06-15", "2025-06-15");
    ASSERT_EQ("compact justBorn unchanged", rc, buf, "Newborn"); // 27.8
}

/* ================================================================ */
/* Default asOf (15.1, 15.2, 23.1, 23.2, 23.3): dateOfBirth is derived */
/* from the local current date, since the library reads the clock.     */
/* ================================================================ */
static void local_date_offset(char *out, int years_back, int days_back) {
    time_t now = time(NULL);
    struct tm tm = *localtime(&now);
    tm.tm_hour = 12;
    tm.tm_year -= years_back;
    if (tm.tm_mon == 1 && tm.tm_mday == 29 && years_back > 0) tm.tm_mday = 28;
    tm.tm_mday -= days_back;
    tm.tm_isdst = -1;
    mktime(&tm);
    snprintf(out, 11, "%04d-%02d-%02d", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
}

static void test_default_as_of(void) {
    char buf[256];
    char dob[11];
    const char *stage;
    int rc;

    local_date_offset(dob, 5, 0);
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, dob, NULL);
    ASSERT_EQ("default asOf 5 years", rc, buf, "5 years"); // 15.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, dob, "");
    ASSERT_EQ("empty asOf 5 years", rc, buf, "5 years"); // 15.1
    local_date_offset(dob, 0, 5);
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, dob, NULL);
    ASSERT_EQ("default asOf 5 days", rc, buf, "5 days"); // 15.2

    local_date_offset(dob, 0, 0);
    stage = sa_stage(&sa_locale_en, dob, NULL, "");
    ASSERT_TRUE("default stage newborn", stage != NULL && strcmp(stage, "Newborn") == 0); // 23.1
    local_date_offset(dob, 5, 0);
    stage = sa_stage(&sa_locale_en, dob, NULL, "");
    ASSERT_TRUE("default stage child", stage != NULL && strcmp(stage, "Child") == 0); // 23.2
    local_date_offset(dob, 45, 0);
    stage = sa_stage(&sa_locale_en, dob, "", "");
    ASSERT_TRUE("default stage adult", stage != NULL && strcmp(stage, "Adult") == 0); // 23.3
}

/* ================================================================ */
/* Locale-specific edge cases                                       */
/* ================================================================ */
static void test_locale_hebrew(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("he justBorn", rc, buf, "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93"); // 29.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("he 1 day one", rc, buf, "\xd7\x99\xd7\x95\xd7\x9d"); // 29.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("he 3 days other", rc, buf, "3 \xd7\x99\xd7\x9e\xd7\x99\xd7\x9d"); // 29.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-06-01", "2025-06-15");
    ASSERT_EQ("he 2 weeks dual", rc, buf, "\xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x99\xd7\x99\xd7\x9d"); // 29.4
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-05-25", "2025-06-15");
    ASSERT_EQ("he 3 weeks other", rc, buf, "3 \xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x95\xd7\xaa"); // 29.5
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("he 6 months", rc, buf, "6 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d"); // 29.6
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2025-03-15", "2025-06-15");
    ASSERT_EQ("he 3 months", rc, buf, "3 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d"); // 29.7
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2023-06-15", "2025-07-15");
    ASSERT_EQ("he 2y dual 1m one", rc, buf, "\xd7\xa9\xd7\xa0\xd7\xaa\xd7\x99\xd7\x99\xd7\x9d, \xd7\x97\xd7\x95\xd7\x93\xd7\xa9"); // 29.8
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("he 3.5y half", rc, buf, "3 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d \xd7\x95\xd7\x97\xd7\xa6\xd7\x99"); // 29.9
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_he, SA_NORMAL, "2018-06-15", "2025-06-15");
    ASSERT_EQ("he 7y other", rc, buf, "7 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d"); // 29.10

    ASSERT_TRUE("he stage m newborn", strcmp(sa_stage(&sa_locale_he, "2025-06-15", "2025-06-15", "m"), "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93") == 0); // 29.11
    ASSERT_TRUE("he stage f newborn", strcmp(sa_stage(&sa_locale_he, "2025-06-15", "2025-06-15", "f"), "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93\xd7\x94") == 0); // 29.12
    ASSERT_TRUE("he stage m adult", strcmp(sa_stage(&sa_locale_he, "2007-06-15", "2025-06-15", "m"), "\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8") == 0); // 29.13
    ASSERT_TRUE("he stage f adult", strcmp(sa_stage(&sa_locale_he, "2007-06-15", "2025-06-15", "f"), "\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8\xd7\xaa") == 0); // 29.14
}

static void test_locale_macedonian(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("mk justBorn", rc, buf, "\xd0\x9d\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb4\xd0\xb5\xd0\xbd\xd1\x87\xd0\xb5"); // 29.15
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("mk 1 day one", rc, buf, "1 \xd0\xb4\xd0\xb5\xd0\xbd"); // 29.16
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("mk 3 days other", rc, buf, "3 \xd0\xb4\xd0\xb5\xd0\xbd\xd0\xb0"); // 29.17
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("mk 6 months", rc, buf, "6 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86\xd0\xb8"); // 29.18
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2023-06-15", "2025-07-15");
    ASSERT_EQ("mk 2y1m one month", rc, buf, "2 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8, 1 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86"); // 29.19
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("mk 3.5y half", rc, buf, "3 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8 \xd0\xb8 \xd0\xbf\xd0\xbe\xd0\xbb"); // 29.20
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_mk, SA_NORMAL, "2018-06-15", "2025-06-15");
    ASSERT_EQ("mk 7y", rc, buf, "7 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8"); // 29.21
}

static void test_locale_swahili(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("sw justBorn", rc, buf, "Mzaliwa mpya"); // 29.22
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("sw 1 day", rc, buf, "siku 1"); // 29.23
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("sw 3 days", rc, buf, "siku 3"); // 29.24
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("sw 6 months", rc, buf, "miezi 6"); // 29.25
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2023-06-15", "2025-07-15");
    ASSERT_EQ("sw 2y 1m", rc, buf, "miaka 2, mwezi 1"); // 29.26
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_sw, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("sw 3.5y half", rc, buf, "miaka 3 na nusu"); // 29.27
}

static void test_locale_indonesian(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("id justBorn", rc, buf, "Baru lahir"); // 29.28
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("id 1 day", rc, buf, "1 hari"); // 29.29
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("id 3 days", rc, buf, "3 hari"); // 29.30
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("id 6 months", rc, buf, "6 bulan"); // 29.31
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("id 3.5y half", rc, buf, "3 setengah tahun"); // 29.32
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_id, SA_NORMAL, "2018-06-15", "2025-06-15");
    ASSERT_EQ("id 7y", rc, buf, "7 tahun"); // 29.33
}

static void test_locale_amharic(void) {
    char buf[512];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2025-06-15", "2025-06-15");
    ASSERT_EQ("am justBorn", rc, buf, "\xe1\x8a\xa0\xe1\x8b\xb2\xe1\x88\xb5 \xe1\x8b\xa8\xe1\x89\xb0\xe1\x8b\x88\xe1\x88\x88\xe1\x8b\xb0"); // 29.34
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2025-06-14", "2025-06-15");
    ASSERT_EQ("am 1 day", rc, buf, "1 \xe1\x89\x80\xe1\x8a\x95"); // 29.35
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2025-06-12", "2025-06-15");
    ASSERT_EQ("am 3 days", rc, buf, "3 \xe1\x89\x80\xe1\x8a\x93\xe1\x89\xb5"); // 29.36
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2025-06-07", "2025-06-15");
    ASSERT_EQ("am 1w1d ethiopic", rc, buf, "1 \xe1\x88\xb3\xe1\x88\x9d\xe1\x8a\x95\xe1\x89\xb5\xe1\x8d\xa3 1 \xe1\x89\x80\xe1\x8a\x95"); // 29.37
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2025-01-15", "2025-07-15");
    ASSERT_EQ("am 6 months", rc, buf, "6 \xe1\x8b\x88\xe1\x88\xab\xe1\x89\xb5"); // 29.38
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_am, SA_NORMAL, "2022-06-15", "2025-12-15");
    ASSERT_EQ("am 3.5y half", rc, buf, "3 \xe1\x8b\x93\xe1\x88\x98\xe1\x89\xb3\xe1\x89\xb5 \xe1\x89\xb0\xe1\x8a\xa9\xe1\x88\x8d"); // 29.39
}

/* ================================================================ */
/* Locale lookup by code string                                     */
/* ================================================================ */
static void test_locale_lookup(void) {
    const SaLocale *en_loc = sa_locale_get("en");
    ASSERT_TRUE("get(en) not null", en_loc != NULL); // 30.1
    ASSERT_TRUE("get(en) code", strcmp(en_loc->code, "en") == 0); // 30.1

    const SaLocale *fr_loc = sa_locale_get("fr");
    ASSERT_TRUE("get(fr) not null", fr_loc != NULL); // 30.2
    ASSERT_TRUE("get(fr) code", strcmp(fr_loc->code, "fr") == 0); // 30.2

    ASSERT_TRUE("get(xx) null", sa_locale_get("xx") == NULL); // 30.3
    ASSERT_TRUE("get('') null", sa_locale_get("") == NULL); // 30.4
    ASSERT_TRUE("get(EN) null", sa_locale_get("EN") == NULL); // 30.5
}

/* ================================================================ */
/* Section 31: Weeks and days across month ends */
/* ================================================================ */
static void test_section_31_weeks_and_days_across_month_ends(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2016-12-31", "2017-03-29");
    ASSERT_EQ("31.1 88 days across a 28-day February", rc, buf, "12 weeks, 4 days"); // 31.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "1991-11-27", "1992-02-25");
    ASSERT_EQ("31.2 90 days across a year end into a leap year", rc, buf, "12 weeks, 6 days"); // 31.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2020-11-30", "2021-01-02");
    ASSERT_EQ("31.3 33 days across a year end", rc, buf, "4 weeks, 5 days"); // 31.3
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_COMPACT, "2016-12-31", "2017-03-29");
    ASSERT_EQ("31.4 Compact form of 31.1", rc, buf, "12w4d"); // 31.4
}

/* ================================================================ */
/* Section 32: Half years take their plural form from whole years */
/* ================================================================ */
static void test_section_32_half_years_take_their_plural_form_from_whole_years(void) {
    char buf[256];
    int rc;
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_pl, SA_NORMAL, "2021-06-15", "2025-01-15");
    ASSERT_EQ("32.1 Polish 3 is 'few'", rc, buf, "3 i p\303\263\305\202 lata"); // 32.1
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_pl, SA_SHORT, "2020-06-15", "2025-12-15");
    ASSERT_EQ("32.2 Polish 5 is 'many'", rc, buf, "5 i p\303\263\305\202 lat"); // 32.2
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_shi, SA_NORMAL, "2005-06-08", "2012-06-07");
    ASSERT_EQ("32.3 Tachelhit 6 is 'few'", rc, buf, "6 \xe2\xb5\x89\xe2\xb5\x99\xe2\xb4\xb3\xe2\xb4\xb3\xe2\xb5\xaf\xe2\xb4\xb0\xe2\xb5\x99\xe2\xb5\x8f \xe2\xb4\xb7 \xe2\xb5\x93\xe2\xb5\xa3\xe2\xb4\xb3\xe2\xb5\x8f"); // 32.3
}

/* ================================================================ */
/* Section 33: Input validation */
/* ================================================================ */
static void test_section_33_input_validation(void) {
    char buf[256];
    int rc;
    ASSERT_NULL("33.1 February 30 doesn't exist", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-02-30", "2032-06-25")); // 33.1
    ASSERT_NULL("33.2 Month 13", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-13-01", "2027-01-31")); // 33.2
    ASSERT_NULL("33.3 February 29 in a non-leap year", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2023-02-29", "2025-03-01")); // 33.3
    ASSERT_NULL("33.4 Day 00", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-06-00", "2027-02-25")); // 33.4
    ASSERT_NULL("33.5 Unpadded month and day", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-6-1", "2027-02-25")); // 33.5
    ASSERT_NULL("33.6 Surrounding whitespace", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, " 2025-06-01", "2027-02-25")); // 33.6
    ASSERT_NULL("33.7 A datetime is not a date", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2025-06-15T10:00:00", "2027-02-25")); // 33.7
    ASSERT_NULL("33.8 Invalid asOf", sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2020-01-01", "2025-04-31")); // 33.8
    ASSERT_TRUE("33.9 formatStage validates too", sa_stage(&sa_locale_en, "2025-02-30", "2027-09-05", "") == NULL); // 33.9
    rc = sa_format_age(buf, sizeof(buf), &sa_locale_en, SA_NORMAL, "2024-02-29", "2026-03-01");
    ASSERT_EQ("33.10 February 29 in a leap year is valid", rc, buf, "2 years"); // 33.10
}

int main(void) {
    test_default_as_of();
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
    test_locale_hebrew();
    test_locale_macedonian();
    test_locale_swahili();
    test_locale_indonesian();
    test_locale_amharic();
    test_locale_lookup();

    test_section_31_weeks_and_days_across_month_ends();
    test_section_32_half_years_take_their_plural_form_from_whole_years();
    test_section_33_input_validation();

    printf("\n=== Results ===\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    printf("Total:  %d\n", tests_passed + tests_failed);

    return tests_failed > 0 ? 1 : 0;
}
