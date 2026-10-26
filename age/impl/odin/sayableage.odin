// sayable-age Odin implementation — types and formatter.
package sayableage

import "core:time"
import "core:time/datetime"
import "core:time/timezone"

VERSION :: "0.5.0"

MAX_AGE_MONTHS :: 6000

Plural_Category :: enum {
    Zero,
    One,
    Two,
    Few,
    Many,
    Other,
}

Compactness :: enum {
    Normal,
    Short,
    Compact,
}

Plural_Forms :: struct {
    zero:  Maybe(string),
    one:   Maybe(string),
    two:   Maybe(string),
    few:   Maybe(string),
    many:  Maybe(string),
    other: Maybe(string),
}

Unit_Forms :: struct {
    simple: Maybe(string),
    forms:  Maybe(Plural_Forms),
}

Stage_Label :: struct {
    label: string,
    f:     string,
}

Stages :: struct {
    newborn:  Stage_Label,
    infant:   Stage_Label,
    toddler:  Stage_Label,
    child:    Stage_Label,
    teenager: Stage_Label,
    adult:    Stage_Label,
}

Unit_Set :: struct {
    day:   Unit_Forms,
    week:  Unit_Forms,
    month: Unit_Forms,
    year:  Unit_Forms,
}

Compactness_Override :: struct {
    day:       Maybe(Unit_Forms),
    week:      Maybe(Unit_Forms),
    month:     Maybe(Unit_Forms),
    year:      Maybe(Unit_Forms),
    half:      Maybe(string),
    delimiter: Maybe(string),
    just_born: Maybe(string),
}

Age_Locale :: struct {
    code:              string,
    plural:            proc(n: int) -> Plural_Category,
    units:             Unit_Set,
    half:              string,
    delimiter:         string,
    just_born:         string,
    stages:            Stages,
    short_override:    Maybe(Compactness_Override),
    compact_override:  Maybe(Compactness_Override),
}

// Date parsing

Date :: struct {
    y, m, d: int,
}

// Exactly YYYY-MM-DD naming a real calendar day (docs/input-formats.md).
parse_date :: proc(s: string) -> (Date, bool) {
    if len(s) != 10 do return {}, false
    if s[4] != '-' || s[7] != '-' do return {}, false
    y, y_ok := parse_digits(s[0:4])
    if !y_ok do return {}, false
    m, m_ok := parse_digits(s[5:7])
    if !m_ok do return {}, false
    d, d_ok := parse_digits(s[8:10])
    if !d_ok do return {}, false
    if m < 1 || m > 12 || d < 1 || d > days_in_month(y, m) do return {}, false
    return Date{y, m, d}, true
}

parse_digits :: proc(s: string) -> (int, bool) {
    v := 0
    for c in s {
        if c < '0' || c > '9' do return 0, false
        v = v * 10 + int(c - '0')
    }
    return v, true
}

days_in_month :: proc(year, month: int) -> int {
    if month == 2 {
        is_leap := year %% 4 == 0 && (year %% 100 != 0 || year %% 400 == 0)
        return is_leap ? 29 : 28
    }
    if month == 4 || month == 6 || month == 9 || month == 11 do return 30
    return 31
}

julian_day :: proc(year, month, day: int) -> int {
    a := (14 - month) / 12
    y := year + 4800 - a
    m := month + 12 * a - 3
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

// Integer to string conversion (no allocations, uses caller buffer)

itoa :: proc(buf: []u8, n: int) -> string {
    if n == 0 {
        buf[0] = '0'
        return string(buf[0:1])
    }
    val := n
    i := 0
    if val < 0 {
        buf[0] = '-'
        i = 1
        val = -val
    }
    tmp: [12]u8
    ti := 0
    for val > 0 {
        tmp[ti] = u8(val %% 10) + '0'
        ti += 1
        val /= 10
    }
    for ti > 0 {
        ti -= 1
        buf[i] = tmp[ti]
        i += 1
    }
    return string(buf[0:i])
}

// String helpers

index_of :: proc(haystack, needle: string) -> int {
    if len(needle) == 0 do return 0
    if len(haystack) < len(needle) do return -1
    for i := 0; i <= len(haystack) - len(needle); i += 1 {
        match := true
        for j := 0; j < len(needle); j += 1 {
            if haystack[i + j] != needle[j] {
                match = false
                break
            }
        }
        if match do return i
    }
    return -1
}

// Writer for building strings into a buffer without allocation

Writer :: struct {
    buf:      []u8,
    pos:      int,
    overflow: bool,
}

writer_init :: proc(buf: []u8) -> Writer {
    return Writer{buf = buf, pos = 0, overflow = false}
}

writer_str :: proc(w: ^Writer, s: string) {
    if w.overflow do return
    if w.pos + len(s) > len(w.buf) {
        w.overflow = true
        return
    }
    for i := 0; i < len(s); i += 1 {
        w.buf[w.pos] = s[i]
        w.pos += 1
    }
}

writer_slice :: proc(w: ^Writer) -> string {
    return string(w.buf[0:w.pos])
}

replace_first :: proc(w: ^Writer, tmpl, marker, replacement: string) {
    pos := index_of(tmpl, marker)
    if pos >= 0 {
        writer_str(w, tmpl[0:pos])
        writer_str(w, replacement)
        writer_str(w, tmpl[pos + len(marker):])
    } else {
        writer_str(w, tmpl)
    }
}

resolve_unit_template :: proc(uf: Unit_Forms, cat: Plural_Category) -> (string, bool) {
    if s, ok := uf.simple.?; ok {
        return s, true
    }
    if forms, ok := uf.forms.?; ok {
        result: Maybe(string)
        switch cat {
        case .Zero:  result = forms.zero
        case .One:   result = forms.one
        case .Two:   result = forms.two
        case .Few:   result = forms.few
        case .Many:  result = forms.many
        case .Other: result = forms.other
        }
        if v, vok := result.?; vok {
            return v, true
        }
        if v, vok := forms.other.?; vok do return v, true
    }
    return "", false
}

resolve_unit :: proc(w: ^Writer, count: int, uf: Unit_Forms, locale: ^Age_Locale, half: string) {
    num_buf: [12]u8
    base_n := itoa(num_buf[:], count)

    n_buf: [64]u8
    n_str := base_n
    if len(half) > 0 && index_of(half, "{n}") >= 0 {
        nw := writer_init(n_buf[:])
        replace_first(&nw, half, "{n}", base_n)
        if !nw.overflow {
            n_str = writer_slice(&nw)
        }
    }

    cat := locale.plural(count)
    tmpl, tmpl_ok := resolve_unit_template(uf, cat)
    if !tmpl_ok do return

    result_buf: [128]u8
    rw := writer_init(result_buf[:])
    replace_first(&rw, tmpl, "{n}", n_str)
    if rw.overflow do return

    if len(half) > 0 && index_of(half, "{0}") >= 0 {
        replace_first(w, half, "{0}", writer_slice(&rw))
    } else {
        writer_str(w, writer_slice(&rw))
    }
}

resolve_stage :: proc(sl: Stage_Label, gender: string) -> string {
    if len(sl.f) == 0 {
        return sl.label
    }
    if len(gender) > 0 && gender[0] == 'f' {
        return sl.f
    }
    return sl.label
}

stage_key :: proc(months: int) -> string {
    if months < 2 do return "newborn"
    if months < 12 do return "infant"
    if months < 36 do return "toddler"
    if months < 156 do return "child"
    if months < 216 do return "teenager"
    return "adult"
}

// Today's date as YYYY-MM-DD in the system's local time zone. Falls back to UTC
// when the local zone cannot be loaded.
today_string :: proc(out: []u8) -> string {
    now := time.now()
    y, mon, d := time.date(now)
    if region, ok := timezone.region_load("local"); ok {
        defer timezone.region_destroy(region)
        if local, converted := timezone.datetime_to_tz(time.time_to_datetime(now) or_else datetime.DateTime{}, region); converted {
            y, mon, d = int(local.year), time.Month(local.month), int(local.day)
        }
    }
    digits :: proc(out: []u8, offset, width, value: int) {
        v := value
        for i := width - 1; i >= 0; i -= 1 {
            out[offset + i] = u8('0' + v % 10)
            v /= 10
        }
    }
    digits(out, 0, 4, y)
    out[4] = '-'
    digits(out, 5, 2, int(mon))
    out[7] = '-'
    digits(out, 8, 2, d)
    return string(out[:10])
}

// Compute age components from two dates. An empty as_of means today. Returns (months, diff_days, ok).
compute_age :: proc(dob, given_as_of: string) -> (int, int, bool) {
    today_buf: [10]u8
    as_of := len(given_as_of) == 0 ? today_string(today_buf[:]) : given_as_of
    if len(dob) == 0 do return 0, 0, false
    dob_date, dob_ok := parse_date(dob)
    if !dob_ok do return 0, 0, false
    ref_date, ref_ok := parse_date(as_of)
    if !ref_ok do return 0, 0, false

    diff_days := julian_day(ref_date.y, ref_date.m, ref_date.d) - julian_day(dob_date.y, dob_date.m, dob_date.d)
    if diff_days < 0 do return 0, 0, false

    last_day := days_in_month(ref_date.y, ref_date.m)
    clamped_birthday := dob_date.d < last_day ? dob_date.d : last_day
    months := (ref_date.y - dob_date.y) * 12 + (ref_date.m - dob_date.m)
    if ref_date.d < clamped_birthday do months -= 1
    if months > MAX_AGE_MONTHS do return 0, 0, false

    return months, diff_days, true
}

format_age :: proc(buf: []u8, locale: ^Age_Locale, compactness: Compactness, dob, as_of: string) -> Maybe(string) {
    months, diff_days, ok := compute_age(dob, as_of)
    if !ok do return nil

    day_uf := locale.units.day
    week_uf := locale.units.week
    month_uf := locale.units.month
    year_uf := locale.units.year
    half := locale.half
    delimiter := locale.delimiter
    just_born := locale.just_born

    ovr: Maybe(Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }

    if o, ovr_ok := ovr.?; ovr_ok {
        if v, vok := o.day.?;       vok do day_uf = v
        if v, vok := o.week.?;      vok do week_uf = v
        if v, vok := o.month.?;     vok do month_uf = v
        if v, vok := o.year.?;      vok do year_uf = v
        if v, vok := o.half.?;      vok do half = v
        if v, vok := o.delimiter.?; vok do delimiter = v
        if v, vok := o.just_born.?; vok do just_born = v
    }

    w := writer_init(buf)

    if diff_days == 0 {
        writer_str(&w, just_born)
        return w.overflow ? nil : writer_slice(&w)
    }

    if diff_days < 7 {
        resolve_unit(&w, diff_days, day_uf, locale, "")
        return w.overflow ? nil : writer_slice(&w)
    }

    if months < 3 {
        weeks := diff_days / 7
        days := diff_days %% 7
        resolve_unit(&w, weeks, week_uf, locale, "")
        if days > 0 {
            writer_str(&w, delimiter)
            resolve_unit(&w, days, day_uf, locale, "")
        }
        return w.overflow ? nil : writer_slice(&w)
    }

    if months < 24 {
        resolve_unit(&w, months, month_uf, locale, "")
        return w.overflow ? nil : writer_slice(&w)
    }

    if months < 36 {
        years := months / 12
        rem := months %% 12
        if rem == 0 {
            resolve_unit(&w, years, year_uf, locale, "")
        } else {
            resolve_unit(&w, years, year_uf, locale, "")
            writer_str(&w, delimiter)
            resolve_unit(&w, rem, month_uf, locale, "")
        }
        return w.overflow ? nil : writer_slice(&w)
    }

    if months < 84 {
        years := months / 12
        rem := months %% 12
        if rem >= 6 {
            resolve_unit(&w, years, year_uf, locale, half)
        } else {
            resolve_unit(&w, years, year_uf, locale, "")
        }
        return w.overflow ? nil : writer_slice(&w)
    }

    years := months / 12
    resolve_unit(&w, years, year_uf, locale, "")
    return w.overflow ? nil : writer_slice(&w)
}

format_stage :: proc(locale: ^Age_Locale, dob, as_of, gender: string) -> Maybe(string) {
    months, _, ok := compute_age(dob, as_of)
    if !ok do return nil

    label: Stage_Label
    key := stage_key(months)
    switch key {
    case "newborn":  label = locale.stages.newborn
    case "infant":   label = locale.stages.infant
    case "toddler":  label = locale.stages.toddler
    case "child":    label = locale.stages.child
    case "teenager": label = locale.stages.teenager
    case "adult":    label = locale.stages.adult
    case:            label = locale.stages.adult
    }

    return resolve_stage(label, gender)
}
