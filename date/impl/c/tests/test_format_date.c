/*
 * sayable-date C test suite.
 * Tests are hosted (uses stdio for output) but the library is freestanding.
 */
#include "sayabledate/sayabledate.h"
#include "sayabledate/locales.h"

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

/* ================================================================ */
/* Null / edge cases (section 1)                                    */
/* ================================================================ */
static void test_null_edge_cases(void) {
    char buf[256];
    ASSERT_NULL("1.1 null", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, (const char *)0)); // 1.1
    ASSERT_NULL("1.2 empty", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "")); // 1.2
    ASSERT_NULL("1.3 invalid", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "invalid")); // 1.3
    ASSERT_NULL("1.4 relative null asOf", sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-15", (const char *)0)); // 1.4
    ASSERT_NULL("1.5 relative null date", sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, (const char *)0, "2025-03-15")); // 1.5
}

/* ================================================================ */
/* format_date — normal compactness (section 2)                     */
/* ================================================================ */
static void test_format_date_normal(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("2.1 March 15th", rc, buf, "March 15th"); // 2.1
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-01-01");
    ASSERT_EQ("2.2 January 1st", rc, buf, "January 1st"); // 2.2
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-05-22");
    ASSERT_EQ("2.3 May 22nd", rc, buf, "May 22nd"); // 2.3
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-07-03");
    ASSERT_EQ("2.4 July 3rd", rc, buf, "July 3rd"); // 2.4
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-12-31");
    ASSERT_EQ("2.5 December 31st", rc, buf, "December 31st"); // 2.5
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-06-11");
    ASSERT_EQ("2.6 June 11th", rc, buf, "June 11th"); // 2.6
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-15T14:30:00");
    ASSERT_EQ("2.7 ISO datetime", rc, buf, "March 15th"); // 2.7
}

/* ================================================================ */
/* format_date — short compactness (section 3)                      */
/* ================================================================ */
static void test_format_date_short(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_SHORT, "2025-03-15");
    ASSERT_EQ("3.1 short Mar 15", rc, buf, "Mar 15"); // 3.1
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_SHORT, "2025-01-01");
    ASSERT_EQ("3.2 short Jan 1", rc, buf, "Jan 1"); // 3.2
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_SHORT, "2025-12-25");
    ASSERT_EQ("3.3 short Dec 25", rc, buf, "Dec 25"); // 3.3
}

/* ================================================================ */
/* format_date — compact (section 4)                                */
/* ================================================================ */
static void test_format_date_compact(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2025-03-15");
    ASSERT_EQ("4.1 compact 3/15", rc, buf, "3/15"); // 4.1
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2025-01-01");
    ASSERT_EQ("4.2 compact 1/1", rc, buf, "1/1"); // 4.2
}

/* ================================================================ */
/* format_relative — proximity tiers (section 5)                    */
/* ================================================================ */
static void test_format_relative(void) {
    char buf[256];
    int rc;
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-15", "2025-03-15");
    ASSERT_EQ("5.1 today", rc, buf, "today"); // 5.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("5.2 tomorrow", rc, buf, "tomorrow"); // 5.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-14", "2025-03-15");
    ASSERT_EQ("5.3 yesterday", rc, buf, "yesterday"); // 5.3
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-17", "2025-03-15");
    ASSERT_EQ("5.4 day after tomorrow", rc, buf, "the day after tomorrow"); // 5.4
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-13", "2025-03-15");
    ASSERT_EQ("5.5 day before yesterday", rc, buf, "the day before yesterday"); // 5.5
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-19", "2025-03-15");
    ASSERT_EQ("5.6 this Wednesday", rc, buf, "this Wednesday"); // 5.6
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-20", "2025-03-15");
    ASSERT_EQ("5.7 this Thursday", rc, buf, "this Thursday"); // 5.7
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-11", "2025-03-15");
    ASSERT_EQ("5.8 last Tuesday", rc, buf, "last Tuesday"); // 5.8
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-22", "2025-03-15");
    ASSERT_EQ("5.9 next Saturday", rc, buf, "next Saturday"); // 5.9
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-27", "2025-03-15");
    ASSERT_EQ("5.10 next Thursday", rc, buf, "next Thursday"); // 5.10
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-01", "2025-03-15");
    ASSERT_EQ("5.11 calendar fallback", rc, buf, "March 1st"); // 5.11
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-04-10", "2025-03-15");
    ASSERT_EQ("5.12 calendar fallback", rc, buf, "April 10th"); // 5.12
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2026-01-05", "2025-03-15");
    ASSERT_EQ("5.13 different year", rc, buf, "January 5th, 2026"); // 5.13
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2024-12-25", "2025-03-15");
    ASSERT_EQ("5.14 past year", rc, buf, "December 25th, 2024"); // 5.14
}

/* ================================================================ */
/* format_relative — compact skips weekday tiers (section 6)        */
/* ================================================================ */
static void test_format_relative_compact(void) {
    char buf[256];
    int rc;
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2025-03-15", "2025-03-15");
    ASSERT_EQ("6.1 compact today", rc, buf, "today"); // 6.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2025-03-16", "2025-03-15");
    ASSERT_EQ("6.2 compact tomorrow", rc, buf, "tomorrow"); // 6.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2025-03-19", "2025-03-15");
    ASSERT_EQ("6.3 compact numeric", rc, buf, "3/19"); // 6.3
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "2026-01-05", "2025-03-15");
    ASSERT_EQ("6.4 compact diff year", rc, buf, "1/5/26"); // 6.4
}

/* ================================================================ */
/* Locale — German (section 7)                                      */
/* ================================================================ */
static void test_locale_german(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_de, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("7.1 German date", rc, buf, "15. M\xc3\xa4rz"); // 7.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_de, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("7.2 German morgen", rc, buf, "morgen"); // 7.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_de, SD_NORMAL, "2025-03-17", "2025-03-15");
    ASSERT_EQ("7.3 German uebermorgen", rc, buf, "\xc3\xbc" "bermorgen"); // 7.3
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_de, SD_NORMAL, "2025-03-19", "2025-03-15");
    ASSERT_EQ("7.4 German this Wednesday", rc, buf, "diesen Mittwoch"); // 7.4
}

/* ================================================================ */
/* Locale — French (section 8)                                      */
/* ================================================================ */
static void test_locale_french(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_fr, SD_NORMAL, "2025-03-01");
    ASSERT_EQ("8.1 French 1er mars", rc, buf, "1er mars"); // 8.1
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_fr, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("8.2 French 15 mars", rc, buf, "15 mars"); // 8.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_fr, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("8.3 French demain", rc, buf, "demain"); // 8.3
}

/* ================================================================ */
/* Locale — Japanese (section 9)                                    */
/* ================================================================ */
static void test_locale_japanese(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_ja, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("9.1 Japanese date", rc, buf, "3\xe6\x9c\x88" "15\xe6\x97\xa5"); // 9.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_ja, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("9.2 Japanese ashita", rc, buf, "\xe6\x98\x8e\xe6\x97\xa5"); // 9.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_ja, SD_NORMAL, "2025-03-19", "2025-03-15");
    ASSERT_EQ("9.3 Japanese this Wednesday", rc, buf, "\xe4\xbb\x8a\xe5\xba\xa6\xe3\x81\xae\xe6\xb0\xb4\xe6\x9b\x9c\xe6\x97\xa5"); // 9.3
}

/* ================================================================ */
/* Locale — Russian genitive months (section 10)                    */
/* ================================================================ */
static void test_locale_russian(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_ru, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("10.1 Russian genitive", rc, buf, "15 \xd0\xbc\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0"); // 10.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_ru, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("10.2 Russian tomorrow", rc, buf, "\xd0\xb7\xd0\xb0\xd0\xb2\xd1\x82\xd1\x80\xd0\xb0"); // 10.2
}

/* ================================================================ */
/* Locale — Arabic (section 11)                                     */
/* ================================================================ */
static void test_locale_arabic(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_ar, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("11.1 Arabic date", rc, buf, "15 \xd9\x85\xd8\xa7\xd8\xb1\xd8\xb3"); // 11.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_ar, SD_NORMAL, "2025-03-16", "2025-03-15");
    ASSERT_EQ("11.2 Arabic tomorrow", rc, buf, "\xd8\xba\xd8\xaf\xd8\xa7\xd9\x8b"); // 11.2
}

/* ================================================================ */
/* Locale — Spanish (section 12)                                    */
/* ================================================================ */
static void test_locale_spanish(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_es, SD_NORMAL, "2025-03-15");
    ASSERT_EQ("12.1 Spanish date", rc, buf, "15 de marzo"); // 12.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_es, SD_NORMAL, "2025-03-17", "2025-03-15");
    ASSERT_EQ("12.2 Spanish pasado manana", rc, buf, "pasado ma\xc3\xb1" "ana"); // 12.2
}

/* ================================================================ */
/* Locale lookup                                                    */
/* ================================================================ */
static void test_locale_lookup(void) {
    const SdDateLocale *en_loc = sd_locale_get("en");
    ASSERT_TRUE("get(en) not null", en_loc != NULL);
    ASSERT_TRUE("get(en) code", strcmp(en_loc->code, "en") == 0);

    ASSERT_TRUE("get(xx) null", sd_locale_get("xx") == NULL);
    ASSERT_TRUE("get('') null", sd_locale_get("") == NULL);
}

/* ================================================================ */
/* Section 13: format_date_with_year */
/* ================================================================ */
static void test_section_13_format_date_with_year(void) {
    char buf[256];
    int rc;
    rc = sd_format_date_with_year(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2018-02-04");
    ASSERT_EQ("13.1", rc, buf, "February 4th, 2018"); // 13.1
    rc = sd_format_date_with_year(buf, sizeof(buf), &sd_locale_en, SD_SHORT, "2025-03-15");
    ASSERT_EQ("13.2", rc, buf, "Mar 15, 2025"); // 13.2
    rc = sd_format_date_with_year(buf, sizeof(buf), &sd_locale_en, SD_COMPACT, "1997-01-21");
    ASSERT_EQ("13.3", rc, buf, "1/21/97"); // 13.3
    rc = sd_format_date_with_year(buf, sizeof(buf), &sd_locale_tg, SD_COMPACT, "2007-05-20");
    ASSERT_EQ("13.4 two-digit year keeps its leading zero", rc, buf, "20/5/07"); // 13.4
    rc = sd_format_date_with_year(buf, sizeof(buf), &sd_locale_fi, SD_SHORT, "1996-06-21");
    ASSERT_EQ("13.5", rc, buf, "21. kes\303\244kuuta 1996"); // 13.5
}

/* ================================================================ */
/* Section 14: Short month names */
/* ================================================================ */
static void test_section_14_short_month_names(void) {
    char buf[256];
    int rc;
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_sk, SD_SHORT, "2031-02-15");
    ASSERT_EQ("14.1", rc, buf, "15. febru\303\241ra"); // 14.1
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_cs, SD_SHORT, "2025-12-10");
    ASSERT_EQ("14.2", rc, buf, "10. prosince"); // 14.2
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_uk, SD_SHORT, "2025-11-05");
    ASSERT_EQ("14.3", rc, buf, "5 \320\273\320\270\321\201\321\202\320\276\320\277\320\260\320\264\320\260"); // 14.3
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_fi, SD_SHORT, "1998-08-08", "1998-08-15");
    ASSERT_EQ("14.4", rc, buf, "8. elokuuta"); // 14.4
}

/* ================================================================ */
/* Section 15: format_relative — short phrases */
/* ================================================================ */
static void test_section_15_format_relative_short_phrases(void) {
    char buf[256];
    int rc;
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_kw, SD_SHORT, "2035-12-04", "2035-12-02");
    ASSERT_EQ("15.1 day after tomorrow", rc, buf, "an Mth ma"); // 15.1
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_mam, SD_SHORT, "2000-01-23", "2000-01-25");
    ASSERT_EQ("15.2 day before yesterday", rc, buf, "Dom nchi'j"); // 15.2
    rc = sd_format_relative(buf, sizeof(buf), &sd_locale_kek, SD_SHORT, "2014-10-24", "2014-10-22");
    ASSERT_EQ("15.3 day after tomorrow", rc, buf, "a'in Vie"); // 15.3
}

/* ================================================================ */
/* Section 16: Input validation */
/* ================================================================ */
static void test_section_16_input_validation(void) {
    char buf[256];
    int rc;
    ASSERT_NULL("16.1 February 30 doesn't exist", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-02-30")); // 16.1
    ASSERT_NULL("16.2 Month 13", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-13-01")); // 16.2
    ASSERT_NULL("16.3 Unpadded month and day", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-6-1")); // 16.3
    ASSERT_NULL("16.4 Surrounding whitespace", sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, " 2025-06-01")); // 16.4
    rc = sd_format_date(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-06-01T10:00:00");
    ASSERT_EQ("16.5 An ISO datetime: only the date part is used", rc, buf, "June 1st"); // 16.5
    ASSERT_NULL("16.6 February 29 in a non-leap year", sd_format_date_with_year(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2023-02-29")); // 16.6
    ASSERT_NULL("16.7 Invalid asOf", sd_format_relative(buf, sizeof(buf), &sd_locale_en, SD_NORMAL, "2025-03-16", "2025-04-31")); // 16.7
}

int main(void) {
    test_null_edge_cases();
    test_format_date_normal();
    test_format_date_short();
    test_format_date_compact();
    test_format_relative();
    test_format_relative_compact();
    test_locale_german();
    test_locale_french();
    test_locale_japanese();
    test_locale_russian();
    test_locale_arabic();
    test_locale_spanish();
    test_locale_lookup();

    test_section_13_format_date_with_year();
    test_section_14_short_month_names();
    test_section_15_format_relative_short_phrases();
    test_section_16_input_validation();

    printf("\n=== Results ===\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    printf("Total:  %d\n", tests_passed + tests_failed);

    return tests_failed > 0 ? 1 : 0;
}
