"""C locale emitter for sayable-date — fully generated freestanding library.

The entire library is generated: types, string utilities, formatter engine,
locale data, and registry. No libc, no malloc.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/c/emitter.py", line_prefix="/* ", line_suffix=" */")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _emit_one_locale(data: dict) -> str:
    code = data["code"]
    var = f"sd_locale_{code}"

    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append((HEADER + locale_source_comment(code, line_prefix="/* ", line_suffix=" */")).rstrip())
    lines.append('#include "sayabledate/sayabledate.h"\n')

    # Day format exceptions as static array
    exceptions = data.get("dayFormatExceptions", {})
    if exceptions:
        lines.append(f"static const SdDayFormatException sd_exc_{code}[] = {{")
        for day_str, fmt in sorted(exceptions.items(), key=lambda kv: int(kv[0])):
            lines.append(f"    {{ {_quote(day_str)}, {_quote(fmt)} }},")
        lines.append("};")
        lines.append("")

    # monthsInDate as static array
    months_in_date = data.get("monthsInDate")
    if months_in_date:
        lines.append(f"static const char *sd_months_in_date_{code}[12] = {{")
        lines.append("    " + ", ".join(_quote(m) for m in months_in_date))
        lines.append("};")
        lines.append("")

    # Short override exceptions
    short_exc = data.get("short", {}).get("dayFormatExceptions", {})
    if short_exc:
        lines.append(f"static const SdDayFormatException sd_short_exc_{code}[] = {{")
        for day_str, fmt in sorted(short_exc.items(), key=lambda kv: int(kv[0])):
            lines.append(f"    {{ {_quote(day_str)}, {_quote(fmt)} }},")
        lines.append("};")
        lines.append("")

    # Short override months
    short_months = data.get("short", {}).get("months")
    if short_months:
        lines.append(f"static const char *sd_short_months_{code}[12] = {{")
        lines.append("    " + ", ".join(_quote(m) for m in short_months))
        lines.append("};")
        lines.append("")

    # Short override monthsInDate
    short_months_in_date = data.get("short", {}).get("monthsInDate")
    if short_months_in_date:
        lines.append(f"static const char *sd_short_months_in_date_{code}[12] = {{")
        lines.append("    " + ", ".join(_quote(m) for m in short_months_in_date))
        lines.append("};")
        lines.append("")

    # Short override weekdays
    short_weekdays = data.get("short", {}).get("weekdays")
    if short_weekdays:
        lines.append(f"static const char *sd_short_weekdays_{code}[7] = {{")
        lines.append("    " + ", ".join(_quote(w) for w in short_weekdays))
        lines.append("};")
        lines.append("")

    lines.append(f"const SdDateLocale {var} = {{")
    lines.append(f"    {_quote(code)},")

    # months[12]
    lines.append("    { " + ", ".join(_quote(m) for m in data["months"]) + " },")

    # weekdays[7]
    lines.append("    { " + ", ".join(_quote(w) for w in data["weekdays"]) + " },")

    # dayFormat
    lines.append(f"    {_quote(data['dayFormat'])},")

    # dayFormatExceptions
    if exceptions:
        lines.append(f"    sd_exc_{code}, {len(exceptions)},")
    else:
        lines.append("    (const SdDayFormatException *)0, 0,")

    # datePattern, datePatternWithYear
    lines.append(f"    {_quote(data['datePattern'])},")
    lines.append(f"    {_quote(data['datePatternWithYear'])},")

    # today, tomorrow, yesterday
    lines.append(f"    {_quote(data['today'])},")
    lines.append(f"    {_quote(data['tomorrow'])},")
    lines.append(f"    {_quote(data['yesterday'])},")

    # dayAfterTomorrow (optional)
    dat = data.get("dayAfterTomorrow")
    lines.append(f"    {_quote(dat) if dat else 'NULL'},")

    # dayBeforeYesterday (optional)
    dby = data.get("dayBeforeYesterday")
    lines.append(f"    {_quote(dby) if dby else 'NULL'},")

    # thisWeekday, nextWeekday, lastWeekday (optional)
    tw = data.get("thisWeekday")
    nw = data.get("nextWeekday")
    lw = data.get("lastWeekday")
    lines.append(f"    {_quote(tw) if tw else 'NULL'},")
    lines.append(f"    {_quote(nw) if nw else 'NULL'},")
    lines.append(f"    {_quote(lw) if lw else 'NULL'},")

    # monthsInDate (optional)
    if months_in_date:
        lines.append(f"    sd_months_in_date_{code},")
    else:
        lines.append("    (const char **)0,")

    # Short override
    if "short" in data:
        lines.append(f"    true, {_emit_compactness_override(data['short'], code, 'short')},")
    else:
        lines.append(f"    false, {_empty_override()},")

    # Compact override
    if "compact" in data:
        lines.append(f"    true, {_emit_compactness_override(data['compact'], code, 'compact')}")
    else:
        lines.append(f"    false, {_empty_override()}")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(ovr: dict, code: str, prefix: str) -> str:
    parts = []

    # months
    if "months" in ovr:
        parts.append(f"sd_{prefix}_months_{code}")
    else:
        parts.append("(const char **)0")

    # monthsInDate
    if "monthsInDate" in ovr:
        parts.append(f"sd_{prefix}_months_in_date_{code}")
    else:
        parts.append("(const char **)0")

    # weekdays
    if "weekdays" in ovr:
        parts.append(f"sd_{prefix}_weekdays_{code}")
    else:
        parts.append("(const char **)0")

    # dayFormat
    if "dayFormat" in ovr:
        parts.append(_quote(ovr["dayFormat"]))
    else:
        parts.append("NULL")

    # dayFormatExceptions
    if "dayFormatExceptions" in ovr:
        exc = ovr["dayFormatExceptions"]
        parts.append(f"sd_{prefix}_exc_{code}")
        parts.append(str(len(exc)))
    else:
        parts.append("(const SdDayFormatException *)0")
        parts.append("0")

    # clear_exceptions: true when dayFormat is overridden but exceptions are not
    clear = "dayFormat" in ovr and "dayFormatExceptions" not in ovr
    parts.append("true" if clear else "false")

    # datePattern
    parts.append(_quote(ovr["datePattern"]) if "datePattern" in ovr else "NULL")

    # datePatternWithYear
    parts.append(_quote(ovr["datePatternWithYear"]) if "datePatternWithYear" in ovr else "NULL")

    # today
    parts.append(_quote(ovr["today"]) if "today" in ovr else "NULL")

    # tomorrow
    parts.append(_quote(ovr["tomorrow"]) if "tomorrow" in ovr else "NULL")

    # yesterday
    parts.append(_quote(ovr["yesterday"]) if "yesterday" in ovr else "NULL")

    return "{ " + ", ".join(parts) + " }"


def _empty_override() -> str:
    return "{ (const char **)0, (const char **)0, (const char **)0, NULL, (const SdDayFormatException *)0, 0, false, NULL, NULL, NULL, NULL, NULL }"


def emit_locale(data: dict) -> str:
    return _emit_one_locale(data)


def emit_header(all_locales: list[dict]) -> str:
    lines = [HEADER]
    lines.append("#ifndef SAYABLEDATE_H")
    lines.append("#define SAYABLEDATE_H")
    lines.append("")
    lines.append('#define SAYABLEDATE_VERSION "0.5.0"')
    lines.append("")
    lines.append("#include <stddef.h>")
    lines.append("#include <stdbool.h>")
    lines.append("")
    lines.append("typedef enum { SD_NORMAL, SD_SHORT, SD_COMPACT } SdCompactness;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *day;")
    lines.append("    const char *format;")
    lines.append("} SdDayFormatException;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char **months;")
    lines.append("    const char **months_in_date;")
    lines.append("    const char **weekdays;")
    lines.append("    const char *day_format;")
    lines.append("    const SdDayFormatException *day_format_exceptions;")
    lines.append("    int day_format_exceptions_count;")
    lines.append("    bool clear_exceptions;")
    lines.append("    const char *date_pattern;")
    lines.append("    const char *date_pattern_with_year;")
    lines.append("    const char *today;")
    lines.append("    const char *tomorrow;")
    lines.append("    const char *yesterday;")
    lines.append("} SdCompactnessOverride;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *code;")
    lines.append("    const char *months[12];")
    lines.append("    const char *weekdays[7];")
    lines.append("    const char *day_format;")
    lines.append("    const SdDayFormatException *day_format_exceptions;")
    lines.append("    int day_format_exceptions_count;")
    lines.append("    const char *date_pattern;")
    lines.append("    const char *date_pattern_with_year;")
    lines.append("    const char *today;")
    lines.append("    const char *tomorrow;")
    lines.append("    const char *yesterday;")
    lines.append("    const char *day_after_tomorrow;")
    lines.append("    const char *day_before_yesterday;")
    lines.append("    const char *this_weekday;")
    lines.append("    const char *next_weekday;")
    lines.append("    const char *last_weekday;")
    lines.append("    const char **months_in_date;")
    lines.append("    bool has_short;  SdCompactnessOverride short_override;")
    lines.append("    bool has_compact; SdCompactnessOverride compact_override;")
    lines.append("} SdDateLocale;")
    lines.append("")
    lines.append("int sd_format_date(char *buf, size_t bufsz, const SdDateLocale *locale,")
    lines.append("                   SdCompactness compactness, const char *date_str);")
    lines.append("")
    lines.append("int sd_format_date_with_year(char *buf, size_t bufsz, const SdDateLocale *locale,")
    lines.append("                             SdCompactness compactness, const char *date_str);")
    lines.append("")
    lines.append("int sd_format_relative(char *buf, size_t bufsz, const SdDateLocale *locale,")
    lines.append("                       SdCompactness compactness, const char *date_str,")
    lines.append("                       const char *as_of_str);")
    lines.append("")
    lines.append("const SdDateLocale *sd_locale_get(const char *code);")
    lines.append("")
    lines.append("#endif /* SAYABLEDATE_H */")
    lines.append("")
    return "\n".join(lines)


def emit_locales_header(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef SAYABLEDATE_LOCALES_H")
    lines.append("#define SAYABLEDATE_LOCALES_H")
    lines.append("")
    lines.append('#include "sayabledate.h"')
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"extern const SdDateLocale sd_locale_{loc['code']};")
    lines.append("")
    lines.append("#endif /* SAYABLEDATE_LOCALES_H */")
    lines.append("")
    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append(HEADER.rstrip())
    lines.append('#include "sayabledate/sayabledate.h"')
    lines.append('#include "sayabledate/locales.h"\n')

    lines.append("static int sd_reg_strcmp(const char *a, const char *b) {")
    lines.append("    while (*a && *a == *b) { a++; b++; }")
    lines.append("    return (unsigned char)*a - (unsigned char)*b;")
    lines.append("}\n")

    lines.append("const SdDateLocale *sd_locale_get(const char *code) {")
    lines.append("    if (!code) return (const SdDateLocale *)0;")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    if (sd_reg_strcmp(code, {_quote(code)}) == 0) return &sd_locale_{code};")
    lines.append("    return (const SdDateLocale *)0;")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def emit_formatter() -> str:
    return _FORMATTER_SOURCE


def locale_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "locales", f"{code}.c")


def header_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "include", "sayabledate", "sayabledate.h")


def locales_header_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "include", "sayabledate", "locales.h")


def registry_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "locales_registry.c")


def formatter_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "sayabledate.c")


_FORMATTER_SOURCE = "/* -*- coding: utf-8 -*- */\n" + HEADER.rstrip() + """
#include "sayabledate/sayabledate.h"

/* ---- freestanding string helpers ---- */

static size_t sd_strlen(const char *s) {
    size_t len = 0;
    while (s[len]) len++;
    return len;
}

static void sd_memcpy(char *dst, const char *src, size_t n) {
    size_t i;
    for (i = 0; i < n; i++) dst[i] = src[i];
}

static const char *sd_strstr(const char *haystack, const char *needle) {
    size_t nlen;
    if (!*needle) return haystack;
    nlen = sd_strlen(needle);
    while (*haystack) {
        size_t i;
        bool match = true;
        for (i = 0; i < nlen; i++) {
            if (haystack[i] != needle[i]) { match = false; break; }
        }
        if (match) return haystack;
        haystack++;
    }
    return (const char *)0;
}

static bool sd_streq(const char *a, const char *b) {
    while (*a && *b) {
        if (*a != *b) return false;
        a++; b++;
    }
    return *a == *b;
}

/* ---- buffer writer ---- */

typedef struct {
    char *buf;
    size_t cap;
    size_t pos;
    bool overflow;
} SdWriter;

static void sd_wr_init(SdWriter *w, char *buf, size_t cap) {
    w->buf = buf;
    w->cap = cap;
    w->pos = 0;
    w->overflow = false;
}

static void sd_wr_str(SdWriter *w, const char *s) {
    size_t len = sd_strlen(s);
    if (w->pos + len < w->cap) {
        sd_memcpy(w->buf + w->pos, s, len);
        w->pos += len;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

static void sd_wr_char(SdWriter *w, char c) {
    if (w->pos + 1 < w->cap) {
        w->buf[w->pos++] = c;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

static void sd_wr_int(SdWriter *w, int n) {
    char tmp[12];
    int i = 0;
    if (n == 0) { tmp[i++] = '0'; }
    else { while (n > 0) { tmp[i++] = (char)('0' + n % 10); n /= 10; } }
    while (i > 0) sd_wr_char(w, tmp[--i]);
}

static const char *sd_itoa(int n) {
    static char buf[12];
    SdWriter w;
    sd_wr_init(&w, buf, sizeof(buf));
    sd_wr_int(&w, n);
    return buf;
}

/* ---- replace first occurrence ---- */

static void sd_replace_first(SdWriter *w, const char *tmpl, const char *marker, const char *replacement) {
    const char *pos = sd_strstr(tmpl, marker);
    if (!pos) {
        sd_wr_str(w, tmpl);
        return;
    }
    while (tmpl < pos) { sd_wr_char(w, *tmpl); tmpl++; }
    sd_wr_str(w, replacement);
    sd_wr_str(w, pos + sd_strlen(marker));
}

/* ---- date parsing ---- */

static int sd_days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

static bool sd_parse_digits(const char *s, int count, int *out) {
    int i;
    *out = 0;
    for (i = 0; i < count; i++) {
        if (s[i] < '0' || s[i] > '9') return false;
        *out = *out * 10 + (s[i] - '0');
    }
    return true;
}

/* YYYY-MM-DD naming a real calendar day, optionally followed by T and
 * anything else (docs/input-formats.md). */
static bool sd_parse_date(const char *s, int *y, int *m, int *d) {
    size_t len;
    if (!s) return false;
    len = sd_strlen(s);
    if (len < 10 || (len > 10 && s[10] != 'T') || s[4] != '-' || s[7] != '-') return false;
    if (!sd_parse_digits(s, 4, y) || !sd_parse_digits(s + 5, 2, m) || !sd_parse_digits(s + 8, 2, d)) {
        return false;
    }
    return *m >= 1 && *m <= 12 && *d >= 1 && *d <= sd_days_in_month(*y, *m);
}

/* ---- julian day for weekday calc ---- */

static int sd_julian_day(int year, int month, int day) {
    int a = (14 - month) / 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

static int sd_weekday(int year, int month, int day) {
    int jdn = sd_julian_day(year, month, day);
    return ((jdn + 1) % 7 + 7) % 7;  /* 0=Sunday */
}

/* ---- resolved locale after compactness override ---- */

typedef struct {
    const char **months;
    const char *months_buf[12]; /* backing storage when using base months */
    const char **months_in_date;
    const char *months_in_date_buf[12]; /* backing storage */
    const char **weekdays;
    const char *weekdays_buf[7]; /* backing storage */
    const char *day_format;
    const SdDayFormatException *day_format_exceptions;
    int day_format_exceptions_count;
    const char *date_pattern;
    const char *date_pattern_with_year;
    const char *today;
    const char *tomorrow;
    const char *yesterday;
} SdResolved;

static void sd_resolve(SdResolved *r, const SdDateLocale *locale, SdCompactness compactness) {
    int i;
    const SdCompactnessOverride *ovr;

    /* Copy base months into buffer so we have a pointer to an array */
    for (i = 0; i < 12; i++) r->months_buf[i] = locale->months[i];
    r->months = r->months_buf;

    for (i = 0; i < 7; i++) r->weekdays_buf[i] = locale->weekdays[i];
    r->weekdays = r->weekdays_buf;

    if (locale->months_in_date) {
        for (i = 0; i < 12; i++) r->months_in_date_buf[i] = locale->months_in_date[i];
        r->months_in_date = r->months_in_date_buf;
    } else {
        r->months_in_date = (const char **)0;
    }

    r->day_format = locale->day_format;
    r->day_format_exceptions = locale->day_format_exceptions;
    r->day_format_exceptions_count = locale->day_format_exceptions_count;
    r->date_pattern = locale->date_pattern;
    r->date_pattern_with_year = locale->date_pattern_with_year;
    r->today = locale->today;
    r->tomorrow = locale->tomorrow;
    r->yesterday = locale->yesterday;

    ovr = (const SdCompactnessOverride *)0;
    if (compactness == SD_SHORT && locale->has_short) ovr = &locale->short_override;
    else if (compactness == SD_COMPACT && locale->has_compact) ovr = &locale->compact_override;

    if (ovr) {
        if (ovr->months) {
            for (i = 0; i < 12; i++) r->months_buf[i] = ovr->months[i];
        }
        if (ovr->months_in_date) {
            for (i = 0; i < 12; i++) r->months_in_date_buf[i] = ovr->months_in_date[i];
            r->months_in_date = r->months_in_date_buf;
        }
        if (ovr->weekdays) {
            for (i = 0; i < 7; i++) r->weekdays_buf[i] = ovr->weekdays[i];
        }
        if (ovr->day_format) {
            r->day_format = ovr->day_format;
            if (ovr->clear_exceptions && !ovr->day_format_exceptions) {
                r->day_format_exceptions = (const SdDayFormatException *)0;
                r->day_format_exceptions_count = 0;
            }
        }
        if (ovr->day_format_exceptions) {
            r->day_format_exceptions = ovr->day_format_exceptions;
            r->day_format_exceptions_count = ovr->day_format_exceptions_count;
        }
        if (ovr->date_pattern) r->date_pattern = ovr->date_pattern;
        if (ovr->date_pattern_with_year) r->date_pattern_with_year = ovr->date_pattern_with_year;
        if (ovr->today) r->today = ovr->today;
        if (ovr->tomorrow) r->tomorrow = ovr->tomorrow;
        if (ovr->yesterday) r->yesterday = ovr->yesterday;
    }
}

/* ---- format absolute date ---- */

static int sd_format_absolute(char *buf, size_t bufsz, const SdResolved *rl,
                              int year, int month, int day, bool include_year) {
    const char *day_str = sd_itoa(day);
    const char *day_fmt = rl->day_format;
    const char *month_name;
    const char *pattern;
    int i;
    char day_buf[64], t1[256], t2[256], t3[256], t4[256], t5[256];
    SdWriter dw, w1, w2, w3, w4, w5;
    SdWriter w;

    /* Find exception for this day */
    for (i = 0; i < rl->day_format_exceptions_count; i++) {
        if (sd_streq(rl->day_format_exceptions[i].day, day_str)) {
            day_fmt = rl->day_format_exceptions[i].format;
            break;
        }
    }

    /* Format the day */
    sd_wr_init(&dw, day_buf, sizeof(day_buf));
    sd_replace_first(&dw, day_fmt, "{n}", day_str);
    if (dw.overflow) return -1;

    /* Pick month name (genitive if available) */
    month_name = rl->months_in_date ? rl->months_in_date[month - 1] : rl->months[month - 1];

    pattern = include_year ? rl->date_pattern_with_year : rl->date_pattern;

    /* Replace {month} */
    sd_wr_init(&w1, t1, sizeof(t1));
    sd_replace_first(&w1, pattern, "{month}", month_name);
    if (w1.overflow) return -1;

    /* Replace {day} */
    sd_wr_init(&w2, t2, sizeof(t2));
    sd_replace_first(&w2, t1, "{day}", day_buf);
    if (w2.overflow) return -1;

    /* Replace {d} (numeric day) */
    sd_wr_init(&w3, t3, sizeof(t3));
    sd_replace_first(&w3, t2, "{d}", day_str);
    if (w3.overflow) return -1;

    /* Replace {m} (numeric month) */
    sd_wr_init(&w4, t4, sizeof(t4));
    sd_replace_first(&w4, t3, "{m}", sd_itoa(month));
    if (w4.overflow) return -1;

    if (include_year) {
        /* Replace {year} */
        sd_wr_init(&w5, t5, sizeof(t5));
        sd_replace_first(&w5, t4, "{year}", sd_itoa(year));
        if (w5.overflow) return -1;

        /* Replace {yy} */
        {
            int yy = ((year % 100) + 100) % 100;
            char yy_buf[4];
            SdWriter yw;
            sd_wr_init(&yw, yy_buf, sizeof(yy_buf));
            if (yy < 10) sd_wr_char(&yw, '0');
            sd_wr_int(&yw, yy);

            sd_wr_init(&w, buf, bufsz);
            sd_replace_first(&w, t5, "{yy}", yy_buf);
        }
    } else {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, t4);
    }

    return w.overflow ? -1 : 0;
}

/* ---- public API: sd_format_date ---- */

int sd_format_date(char *buf, size_t bufsz, const SdDateLocale *locale,
                   SdCompactness compactness, const char *date_str) {
    int y, m, d;
    SdResolved rl;

    if (!buf || bufsz == 0 || !locale) return -1;
    buf[0] = '\\0';

    if (!sd_parse_date(date_str, &y, &m, &d)) return -1;

    sd_resolve(&rl, locale, compactness);
    return sd_format_absolute(buf, bufsz, &rl, y, m, d, false);
}

/* ---- public API: sd_format_date_with_year ---- */

int sd_format_date_with_year(char *buf, size_t bufsz, const SdDateLocale *locale,
                             SdCompactness compactness, const char *date_str) {
    int y, m, d;
    SdResolved rl;

    if (!buf || bufsz == 0 || !locale) return -1;
    buf[0] = '\\0';

    if (!sd_parse_date(date_str, &y, &m, &d)) return -1;

    sd_resolve(&rl, locale, compactness);
    return sd_format_absolute(buf, bufsz, &rl, y, m, d, true);
}

/* ---- public API: sd_format_relative ---- */

int sd_format_relative(char *buf, size_t bufsz, const SdDateLocale *locale,
                       SdCompactness compactness, const char *date_str,
                       const char *as_of_str) {
    int dy, dm, dd, ay, am, ad;
    int date_jdn, asof_jdn, diff;
    SdResolved rl;
    SdWriter w;

    if (!buf || bufsz == 0 || !locale) return -1;
    buf[0] = '\\0';

    if (!sd_parse_date(date_str, &dy, &dm, &dd)) return -1;
    if (!sd_parse_date(as_of_str, &ay, &am, &ad)) return -1;

    sd_resolve(&rl, locale, compactness);

    date_jdn = sd_julian_day(dy, dm, dd);
    asof_jdn = sd_julian_day(ay, am, ad);
    diff = date_jdn - asof_jdn;

    /* Today */
    if (diff == 0) {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, rl.today);
        return w.overflow ? -1 : 0;
    }

    /* Tomorrow */
    if (diff == 1) {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, rl.tomorrow);
        return w.overflow ? -1 : 0;
    }

    /* Yesterday */
    if (diff == -1) {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, rl.yesterday);
        return w.overflow ? -1 : 0;
    }

    /* Day after tomorrow (optional, skipped in compact mode) */
    if (diff == 2 && locale->day_after_tomorrow && compactness != SD_COMPACT) {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, locale->day_after_tomorrow);
        return w.overflow ? -1 : 0;
    }

    /* Day before yesterday (optional, skipped in compact mode) */
    if (diff == -2 && locale->day_before_yesterday && compactness != SD_COMPACT) {
        sd_wr_init(&w, buf, bufsz);
        sd_wr_str(&w, locale->day_before_yesterday);
        return w.overflow ? -1 : 0;
    }

    /* Compact mode: skip weekday references */
    if (compactness == SD_COMPACT) {
        bool include_year = (dy != ay);
        return sd_format_absolute(buf, bufsz, &rl, dy, dm, dd, include_year);
    }

    /* This weekday (+2 to +6) */
    if (diff >= 2 && diff <= 6 && locale->this_weekday) {
        int dow = sd_weekday(dy, dm, dd);
        sd_wr_init(&w, buf, bufsz);
        sd_replace_first(&w, locale->this_weekday, "{weekday}", rl.weekdays[dow]);
        return w.overflow ? -1 : 0;
    }

    /* Last weekday (-6 to -2) */
    if (diff >= -6 && diff <= -2 && locale->last_weekday) {
        int dow = sd_weekday(dy, dm, dd);
        sd_wr_init(&w, buf, bufsz);
        sd_replace_first(&w, locale->last_weekday, "{weekday}", rl.weekdays[dow]);
        return w.overflow ? -1 : 0;
    }

    /* Next weekday (+7 to +13) */
    if (diff >= 7 && diff <= 13 && locale->next_weekday) {
        int dow = sd_weekday(dy, dm, dd);
        sd_wr_init(&w, buf, bufsz);
        sd_replace_first(&w, locale->next_weekday, "{weekday}", rl.weekdays[dow]);
        return w.overflow ? -1 : 0;
    }

    /* Calendar fallback */
    {
        bool include_year = (dy != ay);
        return sd_format_absolute(buf, bufsz, &rl, dy, dm, dd, include_year);
    }
}
"""
