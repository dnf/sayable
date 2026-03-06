/*
 * sayable-duration C test suite.
 * Tests are hosted (uses stdio for output) but the library is freestanding.
 */
#include "sayableduration/sayableduration.h"
#include "sayableduration/locales.h"

#include <stdio.h>
#include <string.h>

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

/* Helper: format with default English locale, Normal compactness */
static int fmt(char *buf, size_t sz, int seconds) {
    return sdu_format_duration_secs(buf, sz, &sdu_locale_en, SDU_NORMAL, seconds);
}

/* ================================================================ */
/* Null / edge cases (section 1)                                    */
/* ================================================================ */
static void test_null_edge_cases(void) {
    char buf[256];
    ASSERT_NULL("1.1 null (negative as proxy)", sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL, -999)); // 1.1
    ASSERT_NULL("1.2 negative", fmt(buf, sizeof(buf), -1)); // 1.2
    ASSERT_NULL("1.3 since null start", sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL, (const char *)0, "2025-01-15T10:00:00")); // 1.3
    ASSERT_NULL("1.4 until null target", sdu_format_until(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL, (const char *)0, "2025-01-15T10:00:00")); // 1.4
    ASSERT_NULL("1.5 since asOf before start", sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL, "2025-01-15T10:00:00", "2025-01-15T09:00:00")); // 1.5
    ASSERT_NULL("1.6 until target in past", sdu_format_until(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL, "2025-01-15T09:00:00", "2025-01-15T10:00:00")); // 1.6
}

/* ================================================================ */
/* Duration — seconds tier (section 2)                              */
/* ================================================================ */
static void test_seconds_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 0);
    ASSERT_EQ("2.1 just now", rc, buf, "just now"); // 2.1
    rc = fmt(buf, sizeof(buf), 1);
    ASSERT_EQ("2.2 1 second", rc, buf, "1 second"); // 2.2
    rc = fmt(buf, sizeof(buf), 45);
    ASSERT_EQ("2.3 45 seconds", rc, buf, "45 seconds"); // 2.3
    rc = fmt(buf, sizeof(buf), 59);
    ASSERT_EQ("2.4 59 seconds", rc, buf, "59 seconds"); // 2.4
}

/* ================================================================ */
/* Duration — minutes + seconds tier (section 3)                    */
/* ================================================================ */
static void test_minutes_seconds_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 60);
    ASSERT_EQ("3.1 1 minute", rc, buf, "1 minute"); // 3.1
    rc = fmt(buf, sizeof(buf), 90);
    ASSERT_EQ("3.2 1 min 30 sec", rc, buf, "1 minute, 30 seconds"); // 3.2
    rc = fmt(buf, sizeof(buf), 240);
    ASSERT_EQ("3.3 4 minutes", rc, buf, "4 minutes"); // 3.3
    rc = fmt(buf, sizeof(buf), 270);
    ASSERT_EQ("3.4 4 min 30 sec", rc, buf, "4 minutes, 30 seconds"); // 3.4
}

/* ================================================================ */
/* Duration — minutes tier (section 4)                              */
/* ================================================================ */
static void test_minutes_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 300);
    ASSERT_EQ("4.1 5 minutes", rc, buf, "5 minutes"); // 4.1
    rc = fmt(buf, sizeof(buf), 1500);
    ASSERT_EQ("4.2 25 minutes", rc, buf, "25 minutes"); // 4.2
    rc = fmt(buf, sizeof(buf), 3540);
    ASSERT_EQ("4.3 59 minutes", rc, buf, "59 minutes"); // 4.3
}

/* ================================================================ */
/* Duration — hours + minutes tier (section 5)                      */
/* ================================================================ */
static void test_hours_minutes_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 3600);
    ASSERT_EQ("5.1 1 hour", rc, buf, "1 hour"); // 5.1
    rc = fmt(buf, sizeof(buf), 5400);
    ASSERT_EQ("5.2 1.5 hours", rc, buf, "1\xc2\xbd hours"); // 5.2
    rc = fmt(buf, sizeof(buf), 8100);
    ASSERT_EQ("5.3 2h 15m", rc, buf, "2 hours, 15 minutes"); // 5.3
    rc = fmt(buf, sizeof(buf), 18000);
    ASSERT_EQ("5.4 5 hours", rc, buf, "5 hours"); // 5.4
}

/* ================================================================ */
/* Duration — hours tier (section 6)                                */
/* ================================================================ */
static void test_hours_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 28800);
    ASSERT_EQ("6.1 8 hours", rc, buf, "8 hours"); // 6.1
    rc = fmt(buf, sizeof(buf), 82800);
    ASSERT_EQ("6.2 23 hours", rc, buf, "23 hours"); // 6.2
}

/* ================================================================ */
/* Duration — days tier (section 7)                                 */
/* ================================================================ */
static void test_days_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 86400);
    ASSERT_EQ("7.1 1 day", rc, buf, "1 day"); // 7.1
    rc = fmt(buf, sizeof(buf), 97200);
    ASSERT_EQ("7.2 1 day 3 hours", rc, buf, "1 day, 3 hours"); // 7.2
    rc = fmt(buf, sizeof(buf), 129600);
    ASSERT_EQ("7.3 1.5 days", rc, buf, "1\xc2\xbd days"); // 7.3
    rc = fmt(buf, sizeof(buf), 432000);
    ASSERT_EQ("7.4 5 days", rc, buf, "5 days"); // 7.4
    rc = fmt(buf, sizeof(buf), 172800);
    ASSERT_EQ("7.5 2 days", rc, buf, "2 days"); // 7.5
}

/* ================================================================ */
/* Duration — weeks tier (section 8)                                */
/* ================================================================ */
static void test_weeks_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 604800);
    ASSERT_EQ("8.1 1 week", rc, buf, "1 week"); // 8.1
    rc = fmt(buf, sizeof(buf), 1296000);
    ASSERT_EQ("8.2 2 weeks 1 day", rc, buf, "2 weeks, 1 day"); // 8.2
    rc = fmt(buf, sizeof(buf), 2419200);
    ASSERT_EQ("8.3 4 weeks", rc, buf, "4 weeks"); // 8.3
}

/* ================================================================ */
/* Duration — months and years tier (section 9)                     */
/* ================================================================ */
static void test_months_years_tier(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), 2678400);
    ASSERT_EQ("9.1 1 month", rc, buf, "1 month"); // 9.1
    rc = fmt(buf, sizeof(buf), 7884000);
    ASSERT_EQ("9.2 3 months", rc, buf, "3 months"); // 9.2
    rc = fmt(buf, sizeof(buf), 31536000);
    ASSERT_EQ("9.3 1 year", rc, buf, "1 year"); // 9.3
    rc = fmt(buf, sizeof(buf), 39420000);
    ASSERT_EQ("9.4 1 year 3 months", rc, buf, "1 year, 3 months"); // 9.4
}

/* ================================================================ */
/* Duration from ISO timestamps (section 10)                        */
/* ================================================================ */
static void test_iso_timestamps(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_iso(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                                 "2025-01-15T10:00:00", "2025-01-15T11:30:00");
    ASSERT_EQ("10.1 ISO 1.5h", rc, buf, "1\xc2\xbd hours"); // 10.1
    rc = sdu_format_duration_iso(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                                 "2025-01-15T10:00:00", "2025-01-15T10:45:00");
    ASSERT_EQ("10.2 ISO 45m", rc, buf, "45 minutes"); // 10.2
}

/* ================================================================ */
/* Relative time — since (section 11)                               */
/* ================================================================ */
static void test_format_since(void) {
    char buf[256];
    int rc;
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T10:00:00");
    ASSERT_EQ("11.1 since just now", rc, buf, "just now"); // 11.1
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T10:00:30");
    ASSERT_EQ("11.2 30 seconds ago", rc, buf, "30 seconds ago"); // 11.2
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T10:45:00");
    ASSERT_EQ("11.3 45 minutes ago", rc, buf, "45 minutes ago"); // 11.3
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T13:00:00");
    ASSERT_EQ("11.4 3 hours ago", rc, buf, "3 hours ago"); // 11.4
}

/* ================================================================ */
/* Relative time — until (section 12)                               */
/* ================================================================ */
static void test_format_until(void) {
    char buf[256];
    int rc;
    rc = sdu_format_until(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T10:00:00");
    ASSERT_EQ("12.1 until just now", rc, buf, "just now"); // 12.1
    rc = sdu_format_until(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T10:20:00", "2025-01-15T10:00:00");
    ASSERT_EQ("12.2 in 20 minutes", rc, buf, "in 20 minutes"); // 12.2
    rc = sdu_format_until(buf, sizeof(buf), &sdu_locale_en, SDU_NORMAL,
                          "2025-01-15T13:00:00", "2025-01-15T10:00:00");
    ASSERT_EQ("12.3 in 3 hours", rc, buf, "in 3 hours"); // 12.3
}

/* ================================================================ */
/* Locale — German (section 13)                                     */
/* ================================================================ */
static void test_locale_german(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_de, SDU_NORMAL, 3600);
    ASSERT_EQ("13.1 German 1 hour", rc, buf, "1 Stunde"); // 13.1
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_de, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T10:05:00");
    ASSERT_EQ("13.2 German ago", rc, buf, "vor 5 Minuten"); // 13.2
}

/* ================================================================ */
/* Locale — French (section 14)                                     */
/* ================================================================ */
static void test_locale_french(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_fr, SDU_NORMAL, 7200);
    ASSERT_EQ("14.1 French 2 hours", rc, buf, "2 heures"); // 14.1
}

/* ================================================================ */
/* Locale — Japanese (section 15)                                   */
/* ================================================================ */
static void test_locale_japanese(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_ja, SDU_NORMAL, 120);
    ASSERT_EQ("15.1 Japanese 2 min", rc, buf, "2\xe5\x88\x86"); // 15.1
    rc = sdu_format_since(buf, sizeof(buf), &sdu_locale_ja, SDU_NORMAL,
                          "2025-01-15T10:00:00", "2025-01-15T11:00:00");
    ASSERT_EQ("15.2 Japanese 1h ago", rc, buf, "1\xe6\x99\x82\xe9\x96\x93\xe5\x89\x8d"); // 15.2
}

/* ================================================================ */
/* Short compactness (section 16)                                   */
/* ================================================================ */
static void test_short_compactness(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_en, SDU_SHORT, 3600);
    ASSERT_EQ("16.1 short 1h", rc, buf, "1h"); // 16.1
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_en, SDU_SHORT, 90);
    ASSERT_EQ("16.2 short 1m 30s", rc, buf, "1m, 30s"); // 16.2
}

/* ================================================================ */
/* Compact compactness (section 17)                                 */
/* ================================================================ */
static void test_compact_compactness(void) {
    char buf[256];
    int rc;
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_en, SDU_COMPACT, 3600);
    ASSERT_EQ("17.1 compact 1h", rc, buf, "1h"); // 17.1
    rc = sdu_format_duration_secs(buf, sizeof(buf), &sdu_locale_en, SDU_COMPACT, 90);
    ASSERT_EQ("17.2 compact 1m30s", rc, buf, "1m30s"); // 17.2
}

/* ================================================================ */
/* Locale lookup                                                    */
/* ================================================================ */
static void test_locale_lookup(void) {
    const SduDurationLocale *en_loc = sdu_locale_get("en");
    ASSERT_TRUE("get(en) not null", en_loc != NULL);
    ASSERT_TRUE("get(en) code", strcmp(en_loc->code, "en") == 0);

    ASSERT_TRUE("get(xx) null", sdu_locale_get("xx") == NULL);
    ASSERT_TRUE("get('') null", sdu_locale_get("") == NULL);
}

int main(void) {
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
    test_locale_lookup();

    printf("\n=== Results ===\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    printf("Total:  %d\n", tests_passed + tests_failed);

    return tests_failed > 0 ? 1 : 0;
}
