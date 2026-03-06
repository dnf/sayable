"""C locale emitter for sayable-time — fully generated freestanding library.

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
    clock = data["clock"]
    var = f"st_locale_{code}"

    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append((HEADER + locale_source_comment(code, line_prefix="/* ", line_suffix=" */")).rstrip())
    lines.append('#include "sayabletime/sayabletime.h"\n')

    lines.append(f"const StTimeLocale {var} = {{")
    lines.append(f"    {_quote(code)},")

    # Clock config
    lines.append("    {")
    # hours[12]
    hours = clock["hours"]
    lines.append("        { " + ", ".join(_quote(h) for h in hours) + " },")
    # midnight, noon
    lines.append(f"        {_quote(clock['midnight'])},")
    lines.append(f"        {_quote(clock['noon'])},")
    # patterns[12]
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    pats = [clock["patterns"][k] for k in pattern_keys]
    lines.append("        { " + ", ".join(_quote(p) for p in pats) + " }")
    lines.append("    },")

    # Short override
    if "short" in data and "clock" in data["short"]:
        sc = data["short"]["clock"]
        lines.append(f"    true, {_emit_short_clock(sc)},")
    else:
        lines.append("    false, { false, { NULL, NULL }, NULL },")

    # Compact override
    if "compact" in data and "clock" in data["compact"]:
        sc = data["compact"]["clock"]
        lines.append(f"    true, {_emit_short_clock(sc)}")
    else:
        lines.append("    false, { false, { NULL, NULL }, NULL }")

    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def _emit_short_clock(sc: dict) -> str:
    use24h = "true" if sc.get("use24h", False) else "false"
    if "amPm" in sc:
        am_pm = "{ " + _quote(sc["amPm"][0]) + ", " + _quote(sc["amPm"][1]) + " }"
    else:
        am_pm = "{ NULL, NULL }"
    fmt = _quote(sc["format"])
    return f"{{ {use24h}, {am_pm}, {fmt} }}"


def emit_locale(data: dict) -> str:
    return _emit_one_locale(data)


def emit_header(all_locales: list[dict]) -> str:
    lines = [HEADER]
    lines.append("#ifndef SAYABLETIME_H")
    lines.append("#define SAYABLETIME_H")
    lines.append("")
    lines.append('#define SAYABLETIME_VERSION "0.5.0"')
    lines.append("")
    lines.append("#include <stddef.h>")
    lines.append("#include <stdbool.h>")
    lines.append("")
    lines.append("typedef enum { ST_NORMAL, ST_SHORT, ST_COMPACT } StCompactness;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *hours[12];")
    lines.append("    const char *midnight;")
    lines.append("    const char *noon;")
    lines.append("    const char *patterns[12];")
    lines.append("} StClockConfig;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    bool use_24h;")
    lines.append("    const char *am_pm[2];")
    lines.append("    const char *format;")
    lines.append("} StShortClockConfig;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *code;")
    lines.append("    StClockConfig clock;")
    lines.append("    bool has_short;  StShortClockConfig short_clock;")
    lines.append("    bool has_compact; StShortClockConfig compact_clock;")
    lines.append("} StTimeLocale;")
    lines.append("")
    lines.append("int st_format_time(char *buf, size_t bufsz, const StTimeLocale *locale,")
    lines.append("                   StCompactness compactness, const char *time_str);")
    lines.append("")
    lines.append("const StTimeLocale *st_locale_get(const char *code);")
    lines.append("")
    lines.append("#endif /* SAYABLETIME_H */")
    lines.append("")
    return "\n".join(lines)


def emit_locales_header(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("#ifndef SAYABLETIME_LOCALES_H")
    lines.append("#define SAYABLETIME_LOCALES_H")
    lines.append("")
    lines.append('#include "sayabletime.h"')
    lines.append("")
    for loc in sorted_locs:
        lines.append(f"extern const StTimeLocale st_locale_{loc['code']};")
    lines.append("")
    lines.append("#endif /* SAYABLETIME_LOCALES_H */")
    lines.append("")
    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("/* -*- coding: utf-8 -*- */")
    lines.append(HEADER.rstrip())
    lines.append('#include "sayabletime/sayabletime.h"')
    lines.append('#include "sayabletime/locales.h"\n')

    lines.append("static int st_reg_strcmp(const char *a, const char *b) {")
    lines.append("    while (*a && *a == *b) { a++; b++; }")
    lines.append("    return (unsigned char)*a - (unsigned char)*b;")
    lines.append("}\n")

    lines.append("const StTimeLocale *st_locale_get(const char *code) {")
    lines.append("    if (!code) return (const StTimeLocale *)0;")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"    if (st_reg_strcmp(code, {_quote(code)}) == 0) return &st_locale_{code};")
    lines.append("    return (const StTimeLocale *)0;")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def emit_formatter() -> str:
    return _FORMATTER_SOURCE


def locale_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "locales", f"{code}.c")


def header_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "include", "sayabletime", "sayabletime.h")


def locales_header_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "include", "sayabletime", "locales.h")


def registry_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "locales_registry.c")


def formatter_path(root: str) -> str:
    return os.path.join(root, "impl", "c", "src", "sayabletime.c")


_FORMATTER_SOURCE = "/* -*- coding: utf-8 -*- */\n" + HEADER.rstrip() + """
#include "sayabletime/sayabletime.h"

/* ---- freestanding string helpers ---- */

static size_t st_strlen(const char *s) {
    size_t len = 0;
    while (s[len]) len++;
    return len;
}

static void st_memcpy(char *dst, const char *src, size_t n) {
    size_t i;
    for (i = 0; i < n; i++) dst[i] = src[i];
}

static const char *st_strstr(const char *haystack, const char *needle) {
    size_t nlen;
    if (!*needle) return haystack;
    nlen = st_strlen(needle);
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
} StWriter;

static void st_wr_init(StWriter *w, char *buf, size_t cap) {
    w->buf = buf;
    w->cap = cap;
    w->pos = 0;
    w->overflow = false;
}

static void st_wr_str(StWriter *w, const char *s) {
    size_t len = st_strlen(s);
    if (w->pos + len < w->cap) {
        st_memcpy(w->buf + w->pos, s, len);
        w->pos += len;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

static void st_wr_char(StWriter *w, char c) {
    if (w->pos + 1 < w->cap) {
        w->buf[w->pos++] = c;
        w->buf[w->pos] = '\\0';
    } else {
        w->overflow = true;
    }
}

static void st_wr_int(StWriter *w, int n) {
    char tmp[12];
    int i = 0;
    if (n == 0) { tmp[i++] = '0'; }
    else { while (n > 0) { tmp[i++] = (char)('0' + n % 10); n /= 10; } }
    while (i > 0) st_wr_char(w, tmp[--i]);
}

/* ---- replace first occurrence of marker in template ---- */

static void st_replace_first(StWriter *w, const char *tmpl, const char *marker, const char *replacement) {
    const char *pos = st_strstr(tmpl, marker);
    if (!pos) {
        st_wr_str(w, tmpl);
        return;
    }
    while (tmpl < pos) { st_wr_char(w, *tmpl); tmpl++; }
    st_wr_str(w, replacement);
    st_wr_str(w, pos + st_strlen(marker));
}

/* ---- time parsing ---- */

static int st_parse_digits(const char *s, int len) {
    int v = 0, i;
    for (i = 0; i < len; i++) {
        char c = s[i];
        if (c < '0' || c > '9') return -1;
        v = v * 10 + (c - '0');
    }
    return v;
}

static bool st_parse_time(const char *input, int *hour, int *minute) {
    const char *t;
    const char *colon;
    int h_len, m_len;
    if (!input || !input[0]) return false;

    /* Find 'T' for ISO datetime */
    t = input;
    {
        const char *p = t;
        while (*p) {
            if (*p == 'T') { t = p + 1; break; }
            p++;
        }
    }

    /* Find colon */
    colon = t;
    while (*colon && *colon != ':') colon++;
    if (!*colon) return false;

    h_len = (int)(colon - t);
    if (h_len < 1 || h_len > 2) return false;

    *hour = st_parse_digits(t, h_len);
    if (*hour < 0 || *hour > 23) return false;

    /* Parse minutes (first 2 digits after colon) */
    {
        const char *m_start = colon + 1;
        const char *m_end = m_start;
        while (*m_end && *m_end != ':' && *m_end != '.' && *m_end != '+' && *m_end != 'Z') m_end++;
        m_len = (int)(m_end - m_start);
        if (m_len < 1 || m_len > 2) return false;
        *minute = st_parse_digits(m_start, m_len);
        if (*minute < 0 || *minute > 59) return false;
    }

    return true;
}

/* ---- rounding ---- */

static int st_round_to_5(int minute) {
    return ((minute + 2) / 5) * 5;
}

/* ---- zero-pad a number (e.g. 5 -> "05") ---- */

static void st_zero_pad(StWriter *w, int n) {
    if (n < 10) st_wr_char(w, '0');
    st_wr_int(w, n);
}

/* ---- format natural spoken time ---- */

static int st_format_natural(char *buf, size_t bufsz, int hour, int minute,
                             const StClockConfig *clock) {
    int rounded = st_round_to_5(minute);
    int h = hour;
    int h12, next_h12, pattern_idx;
    StWriter w;
    char tmp_buf[256];
    StWriter tmp_w;

    if (rounded == 60) {
        rounded = 0;
        h = (h + 1) % 24;
    }

    if (rounded == 0) {
        if (h == 0) {
            st_wr_init(&w, buf, bufsz);
            st_wr_str(&w, clock->midnight);
            return w.overflow ? -1 : 0;
        }
        if (h == 12) {
            st_wr_init(&w, buf, bufsz);
            st_wr_str(&w, clock->noon);
            return w.overflow ? -1 : 0;
        }
    }

    h12 = h % 12;
    next_h12 = (h + 1) % 12;

    pattern_idx = rounded / 5;

    /* Replace {h} in pattern */
    st_wr_init(&tmp_w, tmp_buf, sizeof(tmp_buf));
    st_replace_first(&tmp_w, clock->patterns[pattern_idx], "{h}", clock->hours[h12]);
    if (tmp_w.overflow) return -1;

    /* Replace {next_h} */
    st_wr_init(&w, buf, bufsz);
    st_replace_first(&w, tmp_buf, "{next_h}", clock->hours[next_h12]);
    return w.overflow ? -1 : 0;
}

/* ---- format digital time ---- */

static int st_format_digital(char *buf, size_t bufsz, int hour, int minute,
                             const StShortClockConfig *sc) {
    StWriter w;
    char h_buf[12], mm_buf[4];
    StWriter h_w, mm_w;
    char tmp1[64], tmp2[64];
    StWriter t1, t2;

    st_wr_init(&h_w, h_buf, sizeof(h_buf));
    st_wr_init(&mm_w, mm_buf, sizeof(mm_buf));
    st_zero_pad(&mm_w, minute);

    if (sc->use_24h) {
        st_wr_int(&h_w, hour);

        st_wr_init(&t1, tmp1, sizeof(tmp1));
        st_replace_first(&t1, sc->format, "{h}", h_buf);
        if (t1.overflow) return -1;

        st_wr_init(&w, buf, bufsz);
        st_replace_first(&w, tmp1, "{mm}", mm_buf);
        return w.overflow ? -1 : 0;
    } else {
        int h12 = hour % 12;
        const char *ampm_str;
        if (h12 == 0) h12 = 12;
        st_wr_int(&h_w, h12);

        ampm_str = (hour < 12) ? sc->am_pm[0] : sc->am_pm[1];

        st_wr_init(&t1, tmp1, sizeof(tmp1));
        st_replace_first(&t1, sc->format, "{h}", h_buf);
        if (t1.overflow) return -1;

        st_wr_init(&t2, tmp2, sizeof(tmp2));
        st_replace_first(&t2, tmp1, "{mm}", mm_buf);
        if (t2.overflow) return -1;

        st_wr_init(&w, buf, bufsz);
        st_replace_first(&w, tmp2, "{ampm}", ampm_str);
        return w.overflow ? -1 : 0;
    }
}

/* ---- public API ---- */

int st_format_time(char *buf, size_t bufsz, const StTimeLocale *locale,
                   StCompactness compactness, const char *time_str) {
    int hour, minute;
    const StShortClockConfig *sc;

    if (!buf || bufsz == 0 || !locale) return -1;
    buf[0] = '\\0';

    if (!st_parse_time(time_str, &hour, &minute)) return -1;

    sc = (const StShortClockConfig *)0;
    if (compactness == ST_SHORT && locale->has_short) sc = &locale->short_clock;
    else if (compactness == ST_COMPACT && locale->has_compact) sc = &locale->compact_clock;

    if (sc) return st_format_digital(buf, bufsz, hour, minute, sc);

    return st_format_natural(buf, bufsz, hour, minute, &locale->clock);
}
"""
