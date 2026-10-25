/* getline and open_memstream are POSIX.1-2008, outside strict C11. */
#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "sayableage/sayableage.h"
#include "sayableage/locales.h"
#include "sayabledate/sayabledate.h"
#include "sayabledate/locales.h"
#include "sayabletime/sayabletime.h"
#include "sayabletime/locales.h"
#include "sayableduration/sayableduration.h"
#include "sayableduration/locales.h"

#define VERSION "0.5.0"
#define BUF_SIZE 512

/* ---- locale list (sorted alphabetically, shared across all components) ---- */

static const SaLocale *all_locales[] = {
    &sa_locale_af, &sa_locale_ak, &sa_locale_am, &sa_locale_ar, &sa_locale_az,
    &sa_locale_bci, &sa_locale_be, &sa_locale_bem, &sa_locale_bg, &sa_locale_bm,
    &sa_locale_bn, &sa_locale_br, &sa_locale_bs, &sa_locale_ca, &sa_locale_ceb,
    &sa_locale_cs, &sa_locale_cy, &sa_locale_da, &sa_locale_de, &sa_locale_din,
    &sa_locale_dje, &sa_locale_dyu, &sa_locale_ee, &sa_locale_el, &sa_locale_en,
    &sa_locale_es, &sa_locale_et, &sa_locale_eu, &sa_locale_fa, &sa_locale_fan,
    &sa_locale_ff, &sa_locale_fi, &sa_locale_fil, &sa_locale_fon, &sa_locale_fr,
    &sa_locale_ga, &sa_locale_gd, &sa_locale_gl, &sa_locale_gn, &sa_locale_gu,
    &sa_locale_gv, &sa_locale_ha, &sa_locale_he, &sa_locale_hi, &sa_locale_hr,
    &sa_locale_ht, &sa_locale_hu, &sa_locale_hy, &sa_locale_id, &sa_locale_ig,
    &sa_locale_is, &sa_locale_it, &sa_locale_ja, &sa_locale_jv, &sa_locale_ka,
    &sa_locale_kbp, &sa_locale_kk, &sa_locale_km, &sa_locale_kn, &sa_locale_ko,
    &sa_locale_kpe, &sa_locale_ktu, &sa_locale_ku, &sa_locale_kw, &sa_locale_ky,
    &sa_locale_lg, &sa_locale_ln, &sa_locale_lo, &sa_locale_lt, &sa_locale_lv,
    &sa_locale_men, &sa_locale_mfe, &sa_locale_mg, &sa_locale_mi, &sa_locale_mk,
    &sa_locale_ml, &sa_locale_mn, &sa_locale_mnk, &sa_locale_mos, &sa_locale_mr,
    &sa_locale_ms, &sa_locale_mt, &sa_locale_my, &sa_locale_nb, &sa_locale_nd,
    &sa_locale_ne, &sa_locale_ng, &sa_locale_nl, &sa_locale_nso, &sa_locale_nus,
    &sa_locale_ny, &sa_locale_om, &sa_locale_or, &sa_locale_pa, &sa_locale_pl,
    &sa_locale_pov, &sa_locale_ps, &sa_locale_pt, &sa_locale_qu, &sa_locale_ro,
    &sa_locale_ru, &sa_locale_rw, &sa_locale_sar, &sa_locale_sd, &sa_locale_sg,
    &sa_locale_shi, &sa_locale_si, &sa_locale_sk, &sa_locale_sl, &sa_locale_sn,
    &sa_locale_snk, &sa_locale_so, &sa_locale_sq, &sa_locale_sr, &sa_locale_ss,
    &sa_locale_st, &sa_locale_su, &sa_locale_suk, &sa_locale_sv, &sa_locale_sw,
    &sa_locale_ta, &sa_locale_te, &sa_locale_tem, &sa_locale_tg, &sa_locale_th,
    &sa_locale_ti, &sa_locale_tig, &sa_locale_tk, &sa_locale_tn, &sa_locale_tr,
    &sa_locale_ts, &sa_locale_tzm, &sa_locale_uk, &sa_locale_umb, &sa_locale_ur,
    &sa_locale_uz, &sa_locale_vi, &sa_locale_vmw, &sa_locale_wo, &sa_locale_xh,
    &sa_locale_yo, &sa_locale_yue, &sa_locale_zdj, &sa_locale_zh, &sa_locale_zu,
};
static const int NUM_LOCALES = (int)(sizeof(all_locales) / sizeof(all_locales[0]));

/* ---- helpers ---- */

static int streq(const char *a, const char *b) { return strcmp(a, b) == 0; }

static int is_null(const char *s) { return streq(s, "null"); }

static void today(char *buf, size_t bufsz)
{
    time_t t = time(NULL);
    struct tm *tm = localtime(&t);
    snprintf(buf, bufsz, "%04d-%02d-%02d",
             tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday);
}

static void error(const char *msg)
{
    fprintf(stderr, "error: %s\n", msg);
    fprintf(stderr, "Run 'sayable help' for usage.\n");
}

static void error_fmt(const char *fmt, const char *arg)
{
    fprintf(stderr, "error: ");
    fprintf(stderr, fmt, arg);
    fprintf(stderr, "\n");
    fprintf(stderr, "Run 'sayable help' for usage.\n");
}

/* Detect whether a string is purely digits (non-negative integer) */
static int is_integer(const char *s)
{
    if (!s || !*s) return 0;
    while (*s) {
        if (*s < '0' || *s > '9') return 0;
        s++;
    }
    return 1;
}

/* Detect whether a string is a negative integer (starts with '-' followed by digits) */
static int is_negative_integer(const char *s)
{
    if (!s || !*s) return 0;
    if (s[0] != '-') return 0;
    s++;
    if (!*s) return 0;
    while (*s) {
        if (*s < '0' || *s > '9') return 0;
        s++;
    }
    return 1;
}

static int parse_int(const char *s)
{
    int neg = 0;
    int val = 0;
    if (*s == '-') { neg = 1; s++; }
    while (*s) {
        val = val * 10 + (*s - '0');
        s++;
    }
    return neg ? -val : val;
}

static void print_help(FILE *out)
{
    fprintf(out,
        "Usage: sayable <command> [arguments] [options]\n"
        "\n"
        "Commands:\n"
        "  age <dob>              Format an age\n"
        "  stage <dob>            Get developmental stage\n"
        "  date <date>            Format a calendar date\n"
        "  relative <date>        Format a relative date\n"
        "  time <time>            Format a clock time\n"
        "  duration <value> [end] Format a duration\n"
        "  since <start>          Format elapsed time\n"
        "  until <target>         Format remaining time\n"
        "  locales                List available locale codes\n"
        "  version                Show version\n"
        "  help                   Show this help\n"
        "\n"
        "Options:\n"
        "  -l, --locale <code>    Locale code (default: en)\n"
        "  -d, --as-of <value>    Reference date/timestamp\n"
        "      --short            Short compactness\n"
        "      --compact          Compact compactness\n"
        "  -g, --gender <m|f>     Gender for stage labels\n"
        "      --with-year        Include year (date only)\n"
        "  -h, --help             Show this help\n"
        "  -v, --version          Show version\n"
    );
}

/* ---- argument parsing ---- */

typedef struct {
    const char *command;
    const char *positionals[8];
    int pos_count;
    const char *locale;
    const char *as_of;
    const char *gender;
    int compactness; /* 0=normal, 1=short, 2=compact */
    int with_year;
} Args;

static int parse_args(int argc, char *argv[], Args *args)
{
    int i;
    int stop_opts = 0;

    args->command = NULL;
    args->pos_count = 0;
    args->locale = "en";
    args->as_of = NULL;
    args->gender = NULL;
    args->compactness = 0;
    args->with_year = 0;

    if (argc < 2) return -1;

    /* Global flags as first argument */
    if (streq(argv[1], "-h") || streq(argv[1], "--help") || streq(argv[1], "help")) {
        args->command = "help";
        return 0;
    }
    if (streq(argv[1], "-v") || streq(argv[1], "--version") || streq(argv[1], "version")) {
        args->command = "version";
        return 0;
    }

    args->command = argv[1];

    for (i = 2; i < argc; i++) {
        const char *arg = argv[i];

        if (streq(arg, "--") && !stop_opts) {
            stop_opts = 1;
            continue;
        }

        if (!stop_opts && arg[0] == '-' && arg[1] != '\0') {
            if (streq(arg, "-l") || streq(arg, "--locale")) {
                if (i + 1 >= argc) {
                    error("'--locale' requires a value");
                    return -2;
                }
                args->locale = argv[++i];
            } else if (streq(arg, "-d") || streq(arg, "--as-of")) {
                if (i + 1 >= argc) {
                    error("'--as-of' requires a value");
                    return -2;
                }
                args->as_of = argv[++i];
            } else if (streq(arg, "-g") || streq(arg, "--gender")) {
                if (i + 1 >= argc) {
                    error("'--gender' requires a value");
                    return -2;
                }
                args->gender = argv[++i];
            } else if (streq(arg, "--short")) {
                args->compactness = 1;
            } else if (streq(arg, "--compact")) {
                args->compactness = 2;
            } else if (streq(arg, "--with-year")) {
                args->with_year = 1;
            } else if (streq(arg, "-h") || streq(arg, "--help")) {
                args->command = "help";
                return 0;
            } else if (streq(arg, "-v") || streq(arg, "--version")) {
                args->command = "version";
                return 0;
            } else {
                error_fmt("unknown option '%s'", arg);
                return -2;
            }
        } else {
            if (args->pos_count < 8) {
                args->positionals[args->pos_count++] = arg;
            }
        }
    }

    return 0;
}

/* ---- command handlers ---- */

static int cmd_age(const Args *args, FILE *out)
{
    const SaLocale *locale;
    char today_buf[11];
    const char *dob;
    const char *as_of;
    SaCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("age requires a date-of-birth argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    dob = args->positionals[0];

    locale = sa_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    as_of = args->as_of;
    if (as_of && is_null(as_of)) return 1;
    if (!as_of) {
        today(today_buf, sizeof(today_buf));
        as_of = today_buf;
    }

    compactness = SA_NORMAL;
    if (args->compactness == 1) compactness = SA_SHORT;
    else if (args->compactness == 2) compactness = SA_COMPACT;

    rc = sa_format_age(buf, sizeof(buf), locale, compactness, dob, as_of);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_stage(const Args *args, FILE *out)
{
    const SaLocale *locale;
    char today_buf[11];
    const char *dob;
    const char *as_of;
    const char *stage;

    if (args->pos_count < 1) {
        error("stage requires a date-of-birth argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    dob = args->positionals[0];

    locale = sa_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    as_of = args->as_of;
    if (as_of && is_null(as_of)) return 1;
    if (!as_of) {
        today(today_buf, sizeof(today_buf));
        as_of = today_buf;
    }

    stage = sa_stage(locale, dob, as_of, args->gender);
    if (!stage) return 1;

    fprintf(out, "%s\n", stage);
    return 0;
}

static int cmd_date(const Args *args, FILE *out)
{
    const SdDateLocale *locale;
    const char *date_str;
    SdCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("date requires a date argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    date_str = args->positionals[0];

    locale = sd_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = SD_NORMAL;
    if (args->compactness == 1) compactness = SD_SHORT;
    else if (args->compactness == 2) compactness = SD_COMPACT;

    rc = sd_format_date(buf, sizeof(buf), locale, compactness, date_str);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_relative(const Args *args, FILE *out)
{
    const SdDateLocale *locale;
    const char *date_str;
    const char *as_of;
    SdCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("relative requires a date argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    date_str = args->positionals[0];

    if (!args->as_of) {
        error("relative requires --as-of / -d option");
        return 2;
    }

    as_of = args->as_of;
    if (is_null(as_of)) return 1;

    locale = sd_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = SD_NORMAL;
    if (args->compactness == 1) compactness = SD_SHORT;
    else if (args->compactness == 2) compactness = SD_COMPACT;

    rc = sd_format_relative(buf, sizeof(buf), locale, compactness, date_str, as_of);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_time(const Args *args, FILE *out)
{
    const StTimeLocale *locale;
    const char *time_str;
    StCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("time requires a time argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    time_str = args->positionals[0];

    locale = st_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = ST_NORMAL;
    if (args->compactness == 1) compactness = ST_SHORT;
    else if (args->compactness == 2) compactness = ST_COMPACT;

    rc = st_format_time(buf, sizeof(buf), locale, compactness, time_str);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_duration(const Args *args, FILE *out)
{
    const SduDurationLocale *locale;
    const char *value;
    SduCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("duration requires a value argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    value = args->positionals[0];

    locale = sdu_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = SDU_NORMAL;
    if (args->compactness == 1) compactness = SDU_SHORT;
    else if (args->compactness == 2) compactness = SDU_COMPACT;

    if (is_integer(value)) {
        /* Seconds mode */
        int seconds = parse_int(value);
        rc = sdu_format_duration_secs(buf, sizeof(buf), locale, compactness, seconds);
    } else if (is_negative_integer(value)) {
        /* Negative integer: pass to format_duration which returns null */
        int seconds = parse_int(value);
        rc = sdu_format_duration_secs(buf, sizeof(buf), locale, compactness, seconds);
    } else {
        /* Timestamp mode: need start and end */
        const char *end;
        if (args->pos_count < 2) {
            error("duration with timestamps requires start and end arguments");
            return 2;
        }
        end = args->positionals[1];
        if (is_null(end)) return 1;
        rc = sdu_format_duration_iso(buf, sizeof(buf), locale, compactness, value, end);
    }

    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_since(const Args *args, FILE *out)
{
    const SduDurationLocale *locale;
    const char *start;
    const char *as_of;
    SduCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("since requires a start timestamp argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    start = args->positionals[0];

    if (!args->as_of) {
        error("since requires --as-of / -d option");
        return 2;
    }

    as_of = args->as_of;
    if (is_null(as_of)) return 1;

    locale = sdu_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = SDU_NORMAL;
    if (args->compactness == 1) compactness = SDU_SHORT;
    else if (args->compactness == 2) compactness = SDU_COMPACT;

    rc = sdu_format_since(buf, sizeof(buf), locale, compactness, start, as_of);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_until(const Args *args, FILE *out)
{
    const SduDurationLocale *locale;
    const char *target;
    const char *as_of;
    SduCompactness compactness;
    char buf[BUF_SIZE];
    int rc;

    if (args->pos_count < 1) {
        error("until requires a target timestamp argument");
        return 2;
    }

    if (is_null(args->positionals[0])) return 1;

    target = args->positionals[0];

    if (!args->as_of) {
        error("until requires --as-of / -d option");
        return 2;
    }

    as_of = args->as_of;
    if (is_null(as_of)) return 1;

    locale = sdu_locale_get(args->locale);
    if (!locale) {
        error_fmt("unknown locale '%s'", args->locale);
        return 2;
    }

    compactness = SDU_NORMAL;
    if (args->compactness == 1) compactness = SDU_SHORT;
    else if (args->compactness == 2) compactness = SDU_COMPACT;

    rc = sdu_format_until(buf, sizeof(buf), locale, compactness, target, as_of);
    if (rc != 0) return 1;

    fprintf(out, "%s\n", buf);
    return 0;
}

static int cmd_locales(FILE *out)
{
    int i;
    for (i = 0; i < NUM_LOCALES; i++)
        fprintf(out, "%s\n", all_locales[i]->code);
    return 0;
}

/* ---- dispatch ---- */

/* Runs one invocation, writing its stdout text to `out`; returns the exit code. */
static int run(int argc, char *argv[], FILE *out)
{
    Args args;
    int parse_rc = parse_args(argc, argv, &args);

    if (parse_rc == -2) return 2;

    if (parse_rc == -1 || !args.command) {
        print_help(out);
        return 2;
    }

    if (streq(args.command, "help")) {
        print_help(out);
        return 0;
    }

    if (streq(args.command, "version")) {
        fprintf(out, "sayable %s\n", VERSION);
        return 0;
    }

    if (streq(args.command, "locales")) return cmd_locales(out);
    if (streq(args.command, "age"))      return cmd_age(&args, out);
    if (streq(args.command, "stage"))    return cmd_stage(&args, out);
    if (streq(args.command, "date"))     return cmd_date(&args, out);
    if (streq(args.command, "relative")) return cmd_relative(&args, out);
    if (streq(args.command, "time"))     return cmd_time(&args, out);
    if (streq(args.command, "duration")) return cmd_duration(&args, out);
    if (streq(args.command, "since"))    return cmd_since(&args, out);
    if (streq(args.command, "until"))    return cmd_until(&args, out);

    error_fmt("unknown command '%s'", args.command);
    return 2;
}

/* ---- REPL mode (see cli/SPEC.md) ---- */

static void strip_line_ending(char *line)
{
    size_t len = strlen(line);
    if (len > 0 && line[len - 1] == '\n') line[--len] = '\0';
    if (len > 0 && line[len - 1] == '\r') line[--len] = '\0';
}

/*
 * Splits `line` in place on tabs into an argv whose argv[0] is the program
 * name, as parse_args expects. Empty fields are kept. Caller frees the array.
 */
static char **split_request(char *line, int *argc_out)
{
    int fields = 1;
    int argc = 0;
    char **argv;
    char *p;

    for (p = line; *p; p++)
        if (*p == '\t') fields++;

    argv = malloc(sizeof(char *) * (size_t)(fields + 2));
    if (!argv) return NULL;

    argv[argc++] = "sayable";
    argv[argc++] = line;
    for (p = line; *p; p++) {
        if (*p == '\t') {
            *p = '\0';
            argv[argc++] = p + 1;
        }
    }
    argv[argc] = NULL;
    *argc_out = argc;
    return argv;
}

/* Trailing newline dropped, inner newlines become tabs: one response line. */
static void flatten_output(char *text, size_t len)
{
    size_t i;
    while (len > 0 && text[len - 1] == '\n') text[--len] = '\0';
    for (i = 0; i < len; i++)
        if (text[i] == '\n') text[i] = '\t';
}

static int answer_request(char *line)
{
    char **argv;
    int argc = 0;
    int code;
    char *text = NULL;
    size_t len = 0;
    FILE *out;

    argv = split_request(line, &argc);
    out = open_memstream(&text, &len);
    if (!argv || !out) {
        fprintf(stderr, "error: out of memory\n");
        if (out) fclose(out);
        free(text);
        free(argv);
        return 1;
    }

    code = run(argc, argv, out);
    fclose(out);
    flatten_output(text, len);
    printf("%d\t%s\n", code, text);
    free(text);
    free(argv);
    return 0;
}

static int repl(void)
{
    char *line = NULL;
    size_t cap = 0;

    while (getline(&line, &cap, stdin) != -1) {
        strip_line_ending(line);
        if (answer_request(line) != 0) printf("1\t\n");
        fflush(stdout);
    }
    free(line);
    return 0;
}

/* ---- main ---- */

int main(int argc, char *argv[])
{
    if (argc == 2 && streq(argv[1], "--repl")) return repl();
    return run(argc, argv, stdout);
}
