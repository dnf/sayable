/*
 * sayable-time C test suite.
 * Tests are hosted (uses stdio for output) but the library is freestanding.
 */
#include "sayabletime/sayabletime.h"
#include "sayabletime/locales.h"

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
static int fmt(char *buf, size_t sz, const char *time_str) {
    return st_format_time(buf, sz, &st_locale_en, ST_NORMAL, time_str);
}

/* ================================================================ */
/* Null / edge cases (section 1)                                    */
/* ================================================================ */
static void test_null_edge_cases(void) {
    char buf[256];
    ASSERT_NULL("1.1 null", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, (const char *)0));
    ASSERT_NULL("1.2 empty", fmt(buf, sizeof(buf), ""));
    ASSERT_NULL("1.3 invalid", fmt(buf, sizeof(buf), "invalid"));
    ASSERT_NULL("1.4 out of range", fmt(buf, sizeof(buf), "25:00"));
}

/* ================================================================ */
/* Clock time — normal compactness (section 2)                      */
/* ================================================================ */
static void test_clock_normal(void) {
    char buf[256];
    int rc;
    rc = fmt(buf, sizeof(buf), "00:00");
    ASSERT_EQ("2.1 midnight", rc, buf, "midnight");
    rc = fmt(buf, sizeof(buf), "12:00");
    ASSERT_EQ("2.2 noon", rc, buf, "noon");
    rc = fmt(buf, sizeof(buf), "15:00");
    ASSERT_EQ("2.3 three o'clock", rc, buf, "three o'clock");
    rc = fmt(buf, sizeof(buf), "14:15");
    ASSERT_EQ("2.4 quarter past two", rc, buf, "a quarter past two");
    rc = fmt(buf, sizeof(buf), "09:30");
    ASSERT_EQ("2.5 half past nine", rc, buf, "half past nine");
    rc = fmt(buf, sizeof(buf), "10:45");
    ASSERT_EQ("2.6 quarter to eleven", rc, buf, "a quarter to eleven");
    rc = fmt(buf, sizeof(buf), "08:05");
    ASSERT_EQ("2.7 five past eight", rc, buf, "five past eight");
    rc = fmt(buf, sizeof(buf), "16:55");
    ASSERT_EQ("2.8 five to five", rc, buf, "five to five");
    rc = fmt(buf, sizeof(buf), "23:58");
    ASSERT_EQ("2.9 rounds to midnight", rc, buf, "midnight");
    rc = fmt(buf, sizeof(buf), "07:22");
    ASSERT_EQ("2.10 rounds to 20", rc, buf, "twenty past seven");
    rc = fmt(buf, sizeof(buf), "2025-01-15T14:15:00");
    ASSERT_EQ("2.11 ISO datetime", rc, buf, "a quarter past two");
}

/* ================================================================ */
/* Clock time — short compactness (section 3)                       */
/* ================================================================ */
static void test_clock_short(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_SHORT, "14:15");
    ASSERT_EQ("3.1 short 14:15", rc, buf, "2:15 PM");
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_SHORT, "09:30");
    ASSERT_EQ("3.2 short 09:30", rc, buf, "9:30 AM");
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_SHORT, "00:00");
    ASSERT_EQ("3.3 short 00:00", rc, buf, "12:00 AM");
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_SHORT, "12:00");
    ASSERT_EQ("3.4 short 12:00", rc, buf, "12:00 PM");
}

/* ================================================================ */
/* Clock time — compact (section 4)                                 */
/* ================================================================ */
static void test_clock_compact(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_COMPACT, "14:15");
    ASSERT_EQ("4.1 compact 14:15", rc, buf, "2:15p");
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_COMPACT, "09:30");
    ASSERT_EQ("4.2 compact 09:30", rc, buf, "9:30a");
}

/* ================================================================ */
/* Locale — German (section 5)                                      */
/* ================================================================ */
static void test_locale_german(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_de, ST_NORMAL, "15:30");
    ASSERT_EQ("5.1 German halb vier", rc, buf, "halb vier");
}

/* ================================================================ */
/* Locale — French (section 6)                                      */
/* ================================================================ */
static void test_locale_french(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_fr, ST_NORMAL, "15:15");
    ASSERT_EQ("6.1 French trois heures et quart", rc, buf, "trois heures et quart");
    rc = st_format_time(buf, sizeof(buf), &st_locale_fr, ST_NORMAL, "13:00");
    ASSERT_EQ("6.2 French one o'clock", rc, buf, "une heure");
    rc = st_format_time(buf, sizeof(buf), &st_locale_fr, ST_NORMAL, "13:30");
    ASSERT_EQ("6.3 French half past one", rc, buf, "une heure et demie");
    rc = st_format_time(buf, sizeof(buf), &st_locale_fr, ST_NORMAL, "14:45");
    ASSERT_EQ("6.4 French quarter to three", rc, buf, "trois heures moins le quart");
    rc = st_format_time(buf, sizeof(buf), &st_locale_fr, ST_NORMAL, "14:50");
    ASSERT_EQ("6.5 French ten to three", rc, buf, "trois heures moins dix");
}

/* ================================================================ */
/* Locale — Japanese (section 7)                                    */
/* ================================================================ */
static void test_locale_japanese(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_ja, ST_NORMAL, "15:30");
    ASSERT_EQ("7.1 Japanese", rc, buf, "\xe4\xb8\x89\xe6\x99\x82\xe5\x8d\x8a");
}

/* ================================================================ */
/* Section 8: Locale — Finnish (dot separator, short)               */
/* ================================================================ */
static void test_finnish_dot_separator(void) {
    char buf[256];
    int rc;
    /* 8.1 */
    rc = st_format_time(buf, sizeof(buf), &st_locale_fi, ST_SHORT, "14:15");
    ASSERT_EQ("8.1 fi short 14:15", rc, buf, "14.15");
    /* 8.2 */
    rc = st_format_time(buf, sizeof(buf), &st_locale_fi, ST_SHORT, "00:00");
    ASSERT_EQ("8.2 fi short 00:00", rc, buf, "0.00");
}

/* ================================================================ */
/* Locale lookup                                                    */
/* ================================================================ */
static void test_locale_lookup(void) {
    const StTimeLocale *en_loc = st_locale_get("en");
    ASSERT_TRUE("get(en) not null", en_loc != NULL);
    ASSERT_TRUE("get(en) code", strcmp(en_loc->code, "en") == 0);

    const StTimeLocale *fr_loc = st_locale_get("fr");
    ASSERT_TRUE("get(fr) not null", fr_loc != NULL);
    ASSERT_TRUE("get(fr) code", strcmp(fr_loc->code, "fr") == 0);

    ASSERT_TRUE("get(xx) null", st_locale_get("xx") == NULL);
    ASSERT_TRUE("get('') null", st_locale_get("") == NULL);
    ASSERT_TRUE("get(EN) null", st_locale_get("EN") == NULL);
}

/* ================================================================ */
/* Section 9: Minutes in short and compact modes */
/* ================================================================ */
static void test_section_9_minutes_in_short_and_compact_modes(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_SHORT, "18:01");
    ASSERT_EQ("9.1 digital modes keep the exact minute", rc, buf, "6:01 PM"); // 9.1
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_COMPACT, "19:05");
    ASSERT_EQ("9.2 digital modes keep the exact minute", rc, buf, "7:05p"); // 9.2
}

/* ================================================================ */
/* Section 10: Input validation */
/* ================================================================ */
static void test_section_10_input_validation(void) {
    char buf[256];
    int rc;
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "9:30");
    ASSERT_EQ("10.1 one-digit hour", rc, buf, "half past nine"); // 10.1
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "09:30");
    ASSERT_EQ("10.2 two-digit hour", rc, buf, "half past nine"); // 10.2
    ASSERT_NULL("10.3 leading whitespace", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, " 9:30")); // 10.3
    ASSERT_NULL("10.4 trailing whitespace", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "9:30 ")); // 10.4
    ASSERT_NULL("10.5 minutes need two digits", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "9:5")); // 10.5
    ASSERT_NULL("10.6 hour out of range", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "24:00")); // 10.6
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "14:15:30");
    ASSERT_EQ("10.7 seconds are allowed and ignored", rc, buf, "a quarter past two"); // 10.7
    rc = st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "2025-01-15T14:15:00Z");
    ASSERT_EQ("10.8 ISO datetime with zone suffix (ignored)", rc, buf, "a quarter past two"); // 10.8
    ASSERT_NULL("10.9 ISO datetime with an impossible date", st_format_time(buf, sizeof(buf), &st_locale_en, ST_NORMAL, "2025-02-30T14:15:00")); // 10.9
}

int main(void) {
    test_null_edge_cases();
    test_clock_normal();
    test_clock_short();
    test_clock_compact();
    test_locale_german();
    test_locale_french();
    test_locale_japanese();
    test_finnish_dot_separator();
    test_locale_lookup();

    test_section_9_minutes_in_short_and_compact_modes();
    test_section_10_input_validation();

    printf("\n=== Results ===\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    printf("Total:  %d\n", tests_passed + tests_failed);

    return tests_failed > 0 ? 1 : 0;
}
