#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "sayableage/sayableage.h"
#include "sayableage/locales.h"

#define VERSION "0.5.0"
#define BUF_SIZE 256

static const SaLocale *all_locales[] = {
    &sa_locale_af, &sa_locale_ak, &sa_locale_am, &sa_locale_ar, &sa_locale_az,
    &sa_locale_be, &sa_locale_bg, &sa_locale_bn, &sa_locale_br, &sa_locale_bs,
    &sa_locale_ca, &sa_locale_ceb, &sa_locale_cs, &sa_locale_cy, &sa_locale_da,
    &sa_locale_de, &sa_locale_el, &sa_locale_en, &sa_locale_es, &sa_locale_et,
    &sa_locale_eu, &sa_locale_fa, &sa_locale_ff, &sa_locale_fi, &sa_locale_fil,
    &sa_locale_fr, &sa_locale_ga, &sa_locale_gd, &sa_locale_gl, &sa_locale_gn,
    &sa_locale_gu, &sa_locale_gv, &sa_locale_ha, &sa_locale_he, &sa_locale_hi,
    &sa_locale_hr, &sa_locale_ht, &sa_locale_hu, &sa_locale_hy, &sa_locale_id,
    &sa_locale_ig, &sa_locale_is, &sa_locale_it, &sa_locale_ja, &sa_locale_jv,
    &sa_locale_ka, &sa_locale_kk, &sa_locale_km, &sa_locale_kn, &sa_locale_ko,
    &sa_locale_ku, &sa_locale_kw, &sa_locale_ky, &sa_locale_lg, &sa_locale_ln,
    &sa_locale_lo, &sa_locale_lt, &sa_locale_lv, &sa_locale_mg, &sa_locale_mi,
    &sa_locale_mk, &sa_locale_ml, &sa_locale_mn, &sa_locale_mr, &sa_locale_ms,
    &sa_locale_mt, &sa_locale_my, &sa_locale_nb, &sa_locale_ne, &sa_locale_nl,
    &sa_locale_ny, &sa_locale_om, &sa_locale_or, &sa_locale_pa, &sa_locale_pl,
    &sa_locale_ps, &sa_locale_pt, &sa_locale_qu, &sa_locale_ro, &sa_locale_ru,
    &sa_locale_rw, &sa_locale_sd, &sa_locale_shi, &sa_locale_si, &sa_locale_sk,
    &sa_locale_sl, &sa_locale_sn, &sa_locale_so, &sa_locale_sq, &sa_locale_sr,
    &sa_locale_su, &sa_locale_sv, &sa_locale_sw, &sa_locale_ta, &sa_locale_te,
    &sa_locale_tg, &sa_locale_th, &sa_locale_ti, &sa_locale_tk, &sa_locale_tr,
    &sa_locale_tzm, &sa_locale_uk, &sa_locale_ur, &sa_locale_uz, &sa_locale_vi,
    &sa_locale_xh, &sa_locale_yo, &sa_locale_yue, &sa_locale_zh, &sa_locale_zu,
};
static const int NUM_LOCALES = (int)(sizeof(all_locales) / sizeof(all_locales[0]));

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
            printf("%s\n", all_locales[i]->code);
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
    SaCompactness compactness = SA_NORMAL;

    for (int i = 3; i < argc; i++) {
        if ((streq(argv[i], "-l") || streq(argv[i], "--locale")) && i + 1 < argc) {
            locale_code = argv[++i];
        } else if ((streq(argv[i], "-d") || streq(argv[i], "--as-of")) && i + 1 < argc) {
            as_of = argv[++i];
        } else if ((streq(argv[i], "-g") || streq(argv[i], "--gender")) && i + 1 < argc) {
            gender = argv[++i];
        } else if (streq(argv[i], "--short")) {
            compactness = SA_SHORT;
        } else if (streq(argv[i], "--compact")) {
            compactness = SA_COMPACT;
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

    const SaLocale *locale = sa_locale_get(locale_code);
    if (!locale) {
        fprintf(stderr, "error: unknown locale '%s'\n", locale_code);
        fprintf(stderr, "Run 'sayable-age locales' to see available codes.\n");
        return 1;
    }

    if (is_age) {
        char buf[BUF_SIZE];
        int rc = sa_format_age(buf, sizeof(buf), locale, compactness, dob, as_of);
        if (rc != 0) {
            fprintf(stderr, "error: could not format age (check date format YYYY-MM-DD)\n");
            return 1;
        }
        printf("%s\n", buf);
    } else {
        const char *stage = sa_stage(locale, dob, as_of, gender);
        if (!stage) {
            fprintf(stderr, "error: could not determine stage (check date format YYYY-MM-DD)\n");
            return 1;
        }
        printf("%s\n", stage);
    }

    return 0;
}
