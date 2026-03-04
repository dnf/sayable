"""C locale emitter — fully generated freestanding library.

Unlike other targets where only locale data is generated, the C target generates
the entire library: types, string utilities, formatter engine, locale data, and
registry. This lets embedded developers run the generator and get a self-contained
set of .c/.h files to drop into their project.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.c.plural_rules import get_c_plural

HEADER = make_header("codegen/targets/c/emitter.py", line_prefix="/* ", line_suffix=" */")

_CAT_MAP = {
    "zero": "PT_ZERO", "one": "PT_ONE", "two": "PT_TWO",
    "few": "PT_FEW", "many": "PT_MANY", "other": "PT_OTHER",
}

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    """Emit a PtUnitForms initializer."""
    if isinstance(unit, str):
        # simple form — no plural variation
        return "{ " + _quote(unit) + ", { NULL, NULL, NULL, NULL, NULL, NULL } }"
    # plural form — fill in category slots
    forms = []
    for cat in _CAT_LIST:
        if cat in unit:
            forms.append(_quote(unit[cat]))
        else:
            forms.append("NULL")
    return "{ NULL, { " + ", ".join(forms) + " } }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return "{ " + _quote(stage) + ', "" }'
    return "{ " + _quote(stage["m"]) + ", " + _quote(stage["f"]) + " }"


def _compactness_override(ovr: dict) -> str:
    """Emit a PtCompactnessOverride initializer."""
    parts = []

    for unit_name in ("day", "week", "month", "year"):
        has_it = "units" in ovr and unit_name in ovr["units"]
        parts.append("true" if has_it else "false")
        if has_it:
            parts.append(_unit_forms(ovr["units"][unit_name]))
        else:
            parts.append("{ NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }")

    has_half = "half" in ovr
    parts.append("true" if has_half else "false")
    parts.append(_quote(ovr["half"]) if has_half else "NULL")

    has_delim = "delimiter" in ovr
    parts.append("true" if has_delim else "false")
    parts.append(_quote(ovr["delimiter"]) if has_delim else "NULL")

    has_jb = "justBorn" in ovr
    parts.append("true" if has_jb else "false")
    parts.append(_quote(ovr["justBorn"]) if has_jb else "NULL")

    return "{ " + ", ".join(parts) + " }"


def _emit_one_locale(data: dict) -> str:
    """Emit a single locale .c file."""
    code = data["code"]
    rule = data["pluralRule"]
    var = f"pt_locale_{code}"

    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append((HEADER + locale_source_comment(code, line_prefix="/* ", line_suffix=" */")).rstrip())
    lines.append('#include "parenttime/parenttime.h"\n')

    # Plural function
    lines.append(f"static PtPluralCategory plural_{code}(int n) {{")
    lines.append(get_c_plural(rule))
    lines.append("}\n")

    # Locale struct
    lines.append(f"const PtLocale {var} = {{")
    lines.append(f"    {_quote(code)},")
    lines.append(f"    plural_{code},")

    # Units
    units = data["units"]
    lines.append("    {")
    for i, unit_name in enumerate(("day", "week", "month", "year")):
        comma = "," if i < 3 else ""
        lines.append(f"        {_unit_forms(units[unit_name])}{comma}")
    lines.append("    },")

    # Half, delimiter, justBorn
    lines.append(f"    {_quote(data['half'])}, {_quote(data['delimiter'])}, {_quote(data['justBorn'])},")

    # Stages
    lines.append("    {")
    stage_names = ("newborn", "infant", "toddler", "child", "teenager", "adult")
    for i, stage in enumerate(stage_names):
        comma = "," if i < 5 else ""
        lines.append(f"        {_stage_label(data['stages'][stage])}{comma}")
    lines.append("    },")

    # Short override
    if "short" in data:
        lines.append(f"    true, {_compactness_override(data['short'])},")
    else:
        lines.append("    false, { false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, NULL, false, NULL, false, NULL },")

    # Compact override
    if "compact" in data:
        lines.append(f"    true, {_compactness_override(data['compact'])}")
    else:
        lines.append("    false, { false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, NULL, false, NULL, false, NULL }")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def _emit_empty_override() -> str:
    """Emit a zeroed PtCompactnessOverride for use in the default case."""
    return "{ false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, { NULL, { NULL, NULL, NULL, NULL, NULL, NULL } }, false, NULL, false, NULL, false, NULL }"


def emit_locale(data: dict) -> str:
    return _emit_one_locale(data)


def emit_header(all_locales: list[dict]) -> str:
    """Emit include/parenttime/parenttime.h — types + public API."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef PARENTTIME_H")
    lines.append("#define PARENTTIME_H")
    lines.append("")
    lines.append('#define PARENTTIME_VERSION "0.5.0"')
    lines.append("")
    lines.append("#include <stddef.h>")
    lines.append("#include <stdint.h>")
    lines.append("#include <stdbool.h>")
    lines.append("")
    lines.append("typedef enum { PT_ZERO, PT_ONE, PT_TWO, PT_FEW, PT_MANY, PT_OTHER } PtPluralCategory;")
    lines.append("typedef enum { PT_NORMAL, PT_SHORT, PT_COMPACT } PtCompactness;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *simple;")
    lines.append("    const char *forms[6];")
    lines.append("} PtUnitForms;")
    lines.append("")
    lines.append("typedef struct { const char *label; const char *f; } PtStageLabel;")
    lines.append("typedef struct { PtUnitForms day, week, month, year; } PtUnitSet;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    bool has_day;    PtUnitForms day;")
    lines.append("    bool has_week;   PtUnitForms week;")
    lines.append("    bool has_month;  PtUnitForms month;")
    lines.append("    bool has_year;   PtUnitForms year;")
    lines.append("    bool has_half;      const char *half;")
    lines.append("    bool has_delimiter; const char *delimiter;")
    lines.append("    bool has_just_born; const char *just_born;")
    lines.append("} PtCompactnessOverride;")
    lines.append("")
    lines.append("typedef PtPluralCategory (*PtPluralFn)(int n);")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *code;")
    lines.append("    PtPluralFn plural;")
    lines.append("    PtUnitSet units;")
    lines.append("    const char *half;")
    lines.append("    const char *delimiter;")
    lines.append("    const char *just_born;")
    lines.append("    struct { PtStageLabel newborn, infant, toddler, child, teenager, adult; } stages;")
    lines.append("    bool has_short;   PtCompactnessOverride short_override;")
    lines.append("    bool has_compact; PtCompactnessOverride compact_override;")
    lines.append("} PtLocale;")
    lines.append("")
    lines.append("int pt_format_age(char *buf, size_t bufsz, const PtLocale *locale,")
    lines.append("                  PtCompactness compactness, const char *dob, const char *as_of);")
    lines.append("")
    lines.append("const char *pt_stage(const PtLocale *locale, const char *dob, const char *as_of,")
    lines.append("                     const char *gender);")
    lines.append("")
    lines.append("const PtLocale *pt_locale_get(const char *code);")
    lines.append("")
    lines.append("#endif /* PARENTTIME_H */")
    lines.append("")
    return "\n".join(lines)


def emit_locales_header(all_locales: list[dict]) -> str:
    """Emit include/parenttime/locales.h — extern declarations."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef PARENTTIME_LOCALES_H")
    lines.append("#define PARENTTIME_LOCALES_H")
    lines.append("")
    lines.append('#include "parenttime.h"')
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"extern const PtLocale pt_locale_{loc['code']};")
    lines.append("")
    lines.append("#endif /* PARENTTIME_LOCALES_H */")
    lines.append("")
    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Emit src/locales_registry.c — locale lookup by code."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append(HEADER.rstrip())
    lines.append('#include "parenttime/parenttime.h"')
    lines.append('#include "parenttime/locales.h"\n')

    # Freestanding strcmp
    lines.append("static int pt_reg_strcmp(const char *a, const char *b) {")
    lines.append("    while (*a && *a == *b) { a++; b++; }")
    lines.append("    return (unsigned char)*a - (unsigned char)*b;")
    lines.append("}\n")

    lines.append("const PtLocale *pt_locale_get(const char *code) {")
    lines.append("    if (!code) return (const PtLocale *)0;")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    if (pt_reg_strcmp(code, {_quote(code)}) == 0) return &pt_locale_{code};")
    lines.append("    return (const PtLocale *)0;")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def emit_formatter() -> str:
    """Emit src/parenttime.c — the full formatter engine."""
    return _FORMATTER_SOURCE


def locale_path(code: str, root: str) -> str:
    return os.path.join(root, "src", "c", "src", "locales", f"{code}.c")


def header_path(root: str) -> str:
    return os.path.join(root, "src", "c", "include", "parenttime", "parenttime.h")


def locales_header_path(root: str) -> str:
    return os.path.join(root, "src", "c", "include", "parenttime", "locales.h")


def registry_path(root: str) -> str:
    return os.path.join(root, "src", "c", "src", "locales_registry.c")


def formatter_path(root: str) -> str:
    return os.path.join(root, "src", "c", "src", "parenttime.c")


_FORMATTER_SOURCE = "/* -*- coding: utf-8 -*- */\n" + HEADER.rstrip() + """
#include "parenttime/parenttime.h"

/* ---- freestanding string helpers ---- */

static size_t pt_strlen(const char *s) {
    size_t len = 0;
    while (s[len]) len++;
    return len;
}

static void pt_memcpy(char *dst, const char *src, size_t n) {
    size_t i;
    for (i = 0; i < n; i++) dst[i] = src[i];
}

static const char *pt_strstr(const char *haystack, const char *needle) {
    size_t nlen;
    if (!*needle) return haystack;
    nlen = pt_strlen(needle);
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

/* ---- buffer writer ---- */

typedef struct {
    char *buf;
    size_t cap;
    size_t pos;
    bool overflow;
} PtWriter;

static void pt_wr_init(PtWriter *w, char *buf, size_t cap) {
    w->buf = buf;
    w->cap = cap;
    w->pos = 0;
    w->overflow = false;
}

static void pt_wr_str(PtWriter *w, const char *s) {
    size_t len = pt_strlen(s);
    if (w->pos + len < w->cap) {
        pt_memcpy(w->buf + w->pos, s, len);
        w->pos += len;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

static void pt_wr_char(PtWriter *w, char c) {
    if (w->pos + 1 < w->cap) {
        w->buf[w->pos++] = c;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

/* ---- itoa into buffer ---- */

static void pt_wr_int(PtWriter *w, int n) {
    char tmp[12];
    int i = 0;
    int neg = 0;
    if (n < 0) { neg = 1; n = -n; }
    if (n == 0) { tmp[i++] = '0'; }
    else { while (n > 0) { tmp[i++] = (char)('0' + n % 10); n /= 10; } }
    if (neg) pt_wr_char(w, '-');
    while (i > 0) pt_wr_char(w, tmp[--i]);
}

/* ---- itoa into a static scratch buffer (for resolve_unit) ---- */

static const char *pt_itoa(int n) {
    static char buf[12];
    PtWriter w;
    pt_wr_init(&w, buf, sizeof(buf));
    pt_wr_int(&w, n);
    return buf;
}

/* ---- date parsing ---- */

static bool pt_parse_date(const char *s, int *y, int *m, int *d) {
    int i;
    if (!s) return false;
    if (pt_strlen(s) < 10 || s[4] != '-' || s[7] != '-') return false;
    *y = 0;
    for (i = 0; i < 4; i++) {
        char c = s[i];
        if (c < '0' || c > '9') return false;
        *y = *y * 10 + (c - '0');
    }
    *m = 0;
    for (i = 5; i < 7; i++) {
        char c = s[i];
        if (c < '0' || c > '9') return false;
        *m = *m * 10 + (c - '0');
    }
    *d = 0;
    for (i = 8; i < 10; i++) {
        char c = s[i];
        if (c < '0' || c > '9') return false;
        *d = *d * 10 + (c - '0');
    }
    return (*y != 0 || *m != 0 || *d != 0);
}

static int pt_days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

static int pt_julian_day(int year, int month, int day) {
    int a = (14 - month) / 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

#define PT_MAX_AGE_MONTHS 6000

/* ---- replace {n} or {0} in template ---- */

static void pt_replace_first(PtWriter *w, const char *tmpl, const char *marker, const char *replacement) {
    const char *pos = pt_strstr(tmpl, marker);
    if (!pos) {
        pt_wr_str(w, tmpl);
        return;
    }
    /* write before marker */
    while (tmpl < pos) { pt_wr_char(w, *tmpl); tmpl++; }
    /* write replacement */
    pt_wr_str(w, replacement);
    /* write after marker */
    pt_wr_str(w, pos + pt_strlen(marker));
}

/* ---- resolve unit with plural + half ---- */

static void pt_resolve_unit(PtWriter *w, int count, const PtUnitForms *uf,
                            const PtLocale *loc, const char *half) {
    const char *base_n = pt_itoa(count);

    /* Apply {n}-style half marker to the number */
    char n_buf[64];
    const char *n_str;
    if (half && half[0] && pt_strstr(half, "{n}")) {
        PtWriter nw;
        pt_wr_init(&nw, n_buf, sizeof(n_buf));
        pt_replace_first(&nw, half, "{n}", base_n);
        n_str = n_buf;
    } else {
        n_str = base_n;
    }

    /* Select template */
    const char *tmpl = (const char *)0;
    if (uf->simple) {
        tmpl = uf->simple;
    } else {
        PtPluralCategory cat = loc->plural(count);
        if (uf->forms[cat]) {
            tmpl = uf->forms[cat];
        } else if (uf->forms[PT_OTHER]) {
            tmpl = uf->forms[PT_OTHER];
        }
    }
    if (!tmpl) return;

    /* Replace {n} with the (possibly half-marked) number */
    char result_buf[128];
    PtWriter rw;
    pt_wr_init(&rw, result_buf, sizeof(result_buf));
    pt_replace_first(&rw, tmpl, "{n}", n_str);

    /* Apply {0}-style half marker (wraps the whole expression) */
    if (half && half[0] && pt_strstr(half, "{0}")) {
        pt_replace_first(w, half, "{0}", result_buf);
    } else {
        pt_wr_str(w, result_buf);
    }
}

/* ---- public API: pt_format_age ---- */

int pt_format_age(char *buf, size_t bufsz, const PtLocale *locale,
                  PtCompactness compactness, const char *dob, const char *as_of) {
    int dob_y, dob_m, dob_d, ref_y, ref_m, ref_d;
    int diff_days, months, last_day, clamped_birthday;
    PtWriter w;

    const PtUnitForms *day_uf, *week_uf, *month_uf, *year_uf;
    const char *half, *delimiter, *just_born;

    if (!buf || bufsz == 0 || !locale || !dob) return -1;
    buf[0] = '\\0';

    if (!pt_parse_date(dob, &dob_y, &dob_m, &dob_d)) return -1;
    if (!as_of || !as_of[0]) return -1;
    if (!pt_parse_date(as_of, &ref_y, &ref_m, &ref_d)) return -1;

    diff_days = pt_julian_day(ref_y, ref_m, ref_d) - pt_julian_day(dob_y, dob_m, dob_d);
    if (diff_days < 0) return -1;

    last_day = pt_days_in_month(ref_y, ref_m);
    clamped_birthday = dob_d < last_day ? dob_d : last_day;
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
    if (ref_d < clamped_birthday) months--;
    if (months > PT_MAX_AGE_MONTHS) return -1;

    /* Resolve compactness overrides */
    day_uf = &locale->units.day;
    week_uf = &locale->units.week;
    month_uf = &locale->units.month;
    year_uf = &locale->units.year;
    half = locale->half;
    delimiter = locale->delimiter;
    just_born = locale->just_born;

    if (compactness == PT_SHORT && locale->has_short) {
        const PtCompactnessOverride *o = &locale->short_override;
        if (o->has_day) day_uf = &o->day;
        if (o->has_week) week_uf = &o->week;
        if (o->has_month) month_uf = &o->month;
        if (o->has_year) year_uf = &o->year;
        if (o->has_half) half = o->half;
        if (o->has_delimiter) delimiter = o->delimiter;
        if (o->has_just_born) just_born = o->just_born;
    } else if (compactness == PT_COMPACT && locale->has_compact) {
        const PtCompactnessOverride *o = &locale->compact_override;
        if (o->has_day) day_uf = &o->day;
        if (o->has_week) week_uf = &o->week;
        if (o->has_month) month_uf = &o->month;
        if (o->has_year) year_uf = &o->year;
        if (o->has_half) half = o->half;
        if (o->has_delimiter) delimiter = o->delimiter;
        if (o->has_just_born) just_born = o->just_born;
    }

    pt_wr_init(&w, buf, bufsz);

    /* Tier 1: 0 days */
    if (diff_days == 0) {
        pt_wr_str(&w, just_born);
        return w.overflow ? -1 : 0;
    }

    /* Tier 1b: 1-6 days */
    if (diff_days < 7) {
        pt_resolve_unit(&w, diff_days, day_uf, locale, "");
        return w.overflow ? -1 : 0;
    }

    /* Tier 2: weeks + days until 3 calendar months */
    if (months < 3) {
        int weeks = diff_days / 7;
        int days = diff_days % 7;
        pt_resolve_unit(&w, weeks, week_uf, locale, "");
        if (days > 0) {
            pt_wr_str(&w, delimiter);
            pt_resolve_unit(&w, days, day_uf, locale, "");
        }
        return w.overflow ? -1 : 0;
    }

    /* Tier 3: 3-23 months */
    if (months < 24) {
        pt_resolve_unit(&w, months, month_uf, locale, "");
        return w.overflow ? -1 : 0;
    }

    /* Tier 4: 24-35 months -> years + months */
    if (months < 36) {
        int years = months / 12;
        int rem = months % 12;
        if (rem == 0) {
            pt_resolve_unit(&w, years, year_uf, locale, "");
        } else {
            pt_resolve_unit(&w, years, year_uf, locale, "");
            pt_wr_str(&w, delimiter);
            pt_resolve_unit(&w, rem, month_uf, locale, "");
        }
        return w.overflow ? -1 : 0;
    }

    /* Tier 5: 3-6 years -> years with half marker */
    if (months < 84) {
        int years = months / 12;
        int rem = months % 12;
        if (rem >= 6) {
            pt_resolve_unit(&w, years, year_uf, locale, half);
        } else {
            pt_resolve_unit(&w, years, year_uf, locale, "");
        }
        return w.overflow ? -1 : 0;
    }

    /* Tier 6: 7+ years */
    {
        int years = months / 12;
        pt_resolve_unit(&w, years, year_uf, locale, "");
        return w.overflow ? -1 : 0;
    }
}

/* ---- public API: pt_stage ---- */

const char *pt_stage(const PtLocale *locale, const char *dob, const char *as_of,
                     const char *gender) {
    int dob_y, dob_m, dob_d, ref_y, ref_m, ref_d;
    int diff_days, months, last_day, clamped_birthday;
    const PtStageLabel *label;

    if (!locale || !dob) return (const char *)0;
    if (!pt_parse_date(dob, &dob_y, &dob_m, &dob_d)) return (const char *)0;
    if (!as_of || !as_of[0]) return (const char *)0;
    if (!pt_parse_date(as_of, &ref_y, &ref_m, &ref_d)) return (const char *)0;

    diff_days = pt_julian_day(ref_y, ref_m, ref_d) - pt_julian_day(dob_y, dob_m, dob_d);
    if (diff_days < 0) return (const char *)0;

    last_day = pt_days_in_month(ref_y, ref_m);
    clamped_birthday = dob_d < last_day ? dob_d : last_day;
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
    if (ref_d < clamped_birthday) months--;
    if (months > PT_MAX_AGE_MONTHS) return (const char *)0;

    if (months < 2)        label = &locale->stages.newborn;
    else if (months < 12)  label = &locale->stages.infant;
    else if (months < 36)  label = &locale->stages.toddler;
    else if (months < 156) label = &locale->stages.child;
    else if (months < 216) label = &locale->stages.teenager;
    else                   label = &locale->stages.adult;

    if (gender && gender[0] == 'f' && label->f[0] != '\\0') return label->f;
    return label->label;
}
"""
