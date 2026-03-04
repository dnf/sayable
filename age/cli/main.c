#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "sayableage/sayableage.h"

#define VERSION "0.1.0"
#define BUF_SIZE 256

static const char *LOCALES[] = {
    "am", "ar", "az", "bg", "bn", "br", "bs", "ca", "cs", "cy",
    "da", "de", "el", "en", "es", "et", "eu", "fa", "fi", "fil",
    "fr", "ga", "gd", "gu", "gv", "he", "hi", "hr", "hu", "id",
    "it", "ja", "jv", "ka", "kk", "km", "ko", "kw", "lt", "lv",
    "mk", "mr", "ms", "mt", "my", "nb", "ne", "nl", "pa", "pl",
    "pt", "ro", "ru", "shi", "si", "sk", "sl", "sq", "sr", "sv",
    "sw", "ta", "te", "th", "tr", "tzm", "uk", "ur", "uz", "vi",
    "zh",
};
static const int NUM_LOCALES = (int)(sizeof(LOCALES) / sizeof(LOCALES[0]));

static void today(char *buf, size_t bufsz)
{
    time_t t = time(NULL);
    struct tm *tm = localtime(&t);
    snprintf(buf, bufsz, "%04d-%02d-%02d",
             tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday);
}

static void print_help(void)
{
    printf(
        "Usage: sayable-age <command> [options]\n"
        "\n"
        "Commands:\n"
        "  age <dob>        Format an age (e.g. \"3½ years\")\n"
        "  stage <dob>      Get developmental stage (e.g. \"Toddler\")\n"
        "  locales          List available locale codes\n"
        "\n"
        "Options:\n"
        "  -l, --locale <code>   Locale code (default: en)\n"
        "  -d, --as-of <date>    Reference date, YYYY-MM-DD (default: today)\n"
        "      --short           Short format\n"
        "      --compact         Compact format\n"
        "  -g, --gender <m|f>    Gender for stage labels\n"
        "  -h, --help            Show this help\n"
        "  -v, --version         Show version\n"
        "\n"
        "Examples:\n"
        "  sayable-age age 2020-06-15\n"
        "  sayable-age age 2020-06-15 -l fr\n"
        "  sayable-age age 2020-06-15 --compact\n"
        "  sayable-age stage 2024-01-10 -l es -g f\n"
        "  sayable-age locales\n"
    );
}

static int streq(const char *a, const char *b) { return strcmp(a, b) == 0; }

int main(int argc, char *argv[])
{
    if (argc < 2) {
        print_help();
        return 1;
    }

    const char *cmd = argv[1];

    if (streq(cmd, "--help") || streq(cmd, "-h")) {
        print_help();
        return 0;
    }
    if (streq(cmd, "--version") || streq(cmd, "-v")) {
        printf("sayable-age %s\n", VERSION);
        return 0;
    }

    if (streq(cmd, "locales")) {
        for (int i = 0; i < NUM_LOCALES; i++)
            printf("%s\n", LOCALES[i]);
        return 0;
    }

    int is_age = streq(cmd, "age");
    int is_stage = streq(cmd, "stage");

    if (!is_age && !is_stage) {
        fprintf(stderr, "error: unknown command '%s'\n", cmd);
        fprintf(stderr, "Run 'sayable-age --help' for usage.\n");
        return 1;
    }

    if (argc < 3) {
        fprintf(stderr, "error: %s requires a date-of-birth argument\n", cmd);
        return 1;
    }

    const char *dob = argv[2];
    const char *locale_code = "en";
    const char *as_of = NULL;
    const char *gender = NULL;
    PtCompactness compactness = PT_NORMAL;

    for (int i = 3; i < argc; i++) {
        if ((streq(argv[i], "-l") || streq(argv[i], "--locale")) && i + 1 < argc) {
            locale_code = argv[++i];
        } else if ((streq(argv[i], "-d") || streq(argv[i], "--as-of")) && i + 1 < argc) {
            as_of = argv[++i];
        } else if ((streq(argv[i], "-g") || streq(argv[i], "--gender")) && i + 1 < argc) {
            gender = argv[++i];
        } else if (streq(argv[i], "--short")) {
            compactness = PT_SHORT;
        } else if (streq(argv[i], "--compact")) {
            compactness = PT_COMPACT;
        } else {
            fprintf(stderr, "error: unknown option '%s'\n", argv[i]);
            return 1;
        }
    }

    char today_buf[11];
    if (!as_of) {
        today(today_buf, sizeof(today_buf));
        as_of = today_buf;
    }

    const PtLocale *locale = pt_locale_get(locale_code);
    if (!locale) {
        fprintf(stderr, "error: unknown locale '%s'\n", locale_code);
        fprintf(stderr, "Run 'sayable-age locales' to see available codes.\n");
        return 1;
    }

    if (is_age) {
        char buf[BUF_SIZE];
        int rc = pt_format_age(buf, sizeof(buf), locale, compactness, dob, as_of);
        if (rc != 0) {
            fprintf(stderr, "error: could not format age (check date format YYYY-MM-DD)\n");
            return 1;
        }
        printf("%s\n", buf);
    } else {
        const char *stage = pt_stage(locale, dob, as_of, gender);
        if (!stage) {
            fprintf(stderr, "error: could not determine stage (check date format YYYY-MM-DD)\n");
            return 1;
        }
        printf("%s\n", stage);
    }

    return 0;
}
