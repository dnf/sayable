// sayable-duration Odin implementation — types and formatter.
package sayableduration

VERSION :: "0.5.0"

// Types

Duration_Plural_Category :: enum {
    Zero,
    One,
    Two,
    Few,
    Many,
    Other,
}

Duration_Plural_Forms :: struct {
    zero:  Maybe(string),
    one:   Maybe(string),
    two:   Maybe(string),
    few:   Maybe(string),
    many:  Maybe(string),
    other: Maybe(string),
}

Duration_Unit_Forms :: struct {
    simple: Maybe(string),
    forms:  Maybe(Duration_Plural_Forms),
}

Duration_Unit_Set :: struct {
    second: Duration_Unit_Forms,
    minute: Duration_Unit_Forms,
    hour:   Duration_Unit_Forms,
    day:    Duration_Unit_Forms,
    week:   Duration_Unit_Forms,
    month:  Duration_Unit_Forms,
    year:   Duration_Unit_Forms,
}

Duration_Compactness_Override :: struct {
    second:    Maybe(Duration_Unit_Forms),
    minute:    Maybe(Duration_Unit_Forms),
    hour:      Maybe(Duration_Unit_Forms),
    day:       Maybe(Duration_Unit_Forms),
    week:      Maybe(Duration_Unit_Forms),
    month:     Maybe(Duration_Unit_Forms),
    year:      Maybe(Duration_Unit_Forms),
    half:      Maybe(string),
    delimiter: Maybe(string),
    ago:       Maybe(string),
    in_future: Maybe(string),
}

Duration_Locale :: struct {
    code:              string,
    plural:            proc(n: int) -> Duration_Plural_Category,
    units:             Duration_Unit_Set,
    half:              string,
    delimiter:         string,
    just_now:          string,
    ago:               string,
    in_future:         string,
    short_override:    Maybe(Duration_Compactness_Override),
    compact_override:  Maybe(Duration_Compactness_Override),
}

Compactness :: enum {
    Normal,
    Short,
    Compact,
}

// ISO datetime parsing

parse_digits :: proc(s: string) -> (int, bool) {
    v := 0
    for c in s {
        if c < '0' || c > '9' do return 0, false
        v = v * 10 + int(c - '0')
    }
    return v, true
}

is_leap_year :: proc(year: int) -> bool {
    return year %% 4 == 0 && (year %% 100 != 0 || year %% 400 == 0)
}

days_in_month :: proc(year, month: int) -> int {
    if month == 2 {
        return is_leap_year(year) ? 29 : 28
    }
    if month == 4 || month == 6 || month == 9 || month == 11 do return 30
    return 31
}

days_since_epoch :: proc(year, month, day: int) -> int {
    days := 0
    if year >= 2000 {
        for y := 2000; y < year; y += 1 {
            days += is_leap_year(y) ? 366 : 365
        }
    } else {
        for y := year; y < 2000; y += 1 {
            days -= is_leap_year(y) ? 366 : 365
        }
    }
    for m := 1; m < month; m += 1 {
        days += days_in_month(year, m)
    }
    days += day - 1
    return days
}

// Number of leading ASCII digits in s.
digit_run :: proc(s: string) -> int {
    n := 0
    for n < len(s) && s[n] >= '0' && s[n] <= '9' do n += 1
    return n
}

// Nothing, "Z", or "+HH:MM" / "-HH:MM".
is_zone_suffix :: proc(s: string) -> bool {
    if len(s) == 0 do return true
    if len(s) == 1 do return s[0] == 'Z'
    return len(s) == 6 && (s[0] == '+' || s[0] == '-') && digit_run(s[1:3]) == 2 && s[3] == ':' && digit_run(s[4:6]) == 2
}

Clock :: struct {
    hour, minute, second: int,
}

// H:MM or HH:MM, optional :SS, optional . plus digits after the seconds, and an
// optional zone suffix, which is validated but ignored.
parse_clock :: proc(clock: string) -> (Clock, bool) {
    hour_len := digit_run(clock)
    if hour_len < 1 || hour_len > 2 || len(clock) < hour_len + 3 || clock[hour_len] != ':' do return {}, false
    if digit_run(clock[hour_len + 1:hour_len + 3]) != 2 do return {}, false
    hour, _ := parse_digits(clock[0:hour_len])
    minute, _ := parse_digits(clock[hour_len + 1:hour_len + 3])
    second := 0
    rest := clock[hour_len + 3:]
    if len(rest) > 0 && rest[0] == ':' {
        if len(rest) < 3 || digit_run(rest[1:3]) != 2 do return {}, false
        second, _ = parse_digits(rest[1:3])
        rest = rest[3:]
        if len(rest) > 0 && rest[0] == '.' {
            fraction_len := digit_run(rest[1:])
            if fraction_len == 0 do return {}, false
            rest = rest[1 + fraction_len:]
        }
    }
    if !is_zone_suffix(rest) || hour > 23 || minute > 59 || second > 59 do return {}, false
    return Clock{hour, minute, second}, true
}

// A timestamp YYYY-MM-DDTHH:MM[:SS[.fff]][zone] (docs/input-formats.md) as
// seconds since 2000-01-01 for diffing.
parse_iso_to_seconds :: proc(s: string) -> (int, bool) {
    if len(s) < 11 || s[4] != '-' || s[7] != '-' || s[10] != 'T' do return 0, false
    y, y_ok := parse_digits(s[0:4])
    mo, mo_ok := parse_digits(s[5:7])
    d, d_ok := parse_digits(s[8:10])
    if !y_ok || !mo_ok || !d_ok || mo < 1 || mo > 12 || d < 1 || d > days_in_month(y, mo) do return 0, false
    c, ok := parse_clock(s[11:])
    if !ok do return 0, false
    return days_since_epoch(y, mo, d) * 86400 + c.hour * 3600 + c.minute * 60 + c.second, true
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

resolve_unit_template :: proc(uf: Duration_Unit_Forms, cat: Duration_Plural_Category) -> (string, bool) {
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

resolve_unit :: proc(w: ^Writer, count: int, uf: Duration_Unit_Forms, locale: ^Duration_Locale, half: string) {
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

    // Half-marked values use "other" plural
    cat: Duration_Plural_Category
    if len(half) > 0 {
        cat = .Other
    } else {
        cat = locale.plural(count)
    }

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

get_unit :: proc(units: ^Duration_Unit_Set, name: string) -> Duration_Unit_Forms {
    switch name {
    case "second": return units.second
    case "minute": return units.minute
    case "hour":   return units.hour
    case "day":    return units.day
    case "week":   return units.week
    case "month":  return units.month
    case "year":   return units.year
    case:          return units.second
    }
}

// Formatting

// Durations over 6000 months (500 years) have no value: the same ceiling as sayable-age.
MAX_DURATION_MONTHS :: 6000

// Months from whole days, 30.44 days to the month, rounded:
// round(total_days / 30.44) = (total_days * 100 + 1522) / 3044
approximate_months :: proc(total_days: int) -> int {
    return (total_days * 100 + 1522) / 3044
}

format_duration_seconds :: proc(buf: []u8, locale: ^Duration_Locale, compactness: Compactness, total: int) -> Maybe(string) {
    if total / 86400 >= 30 && approximate_months(total / 86400) > MAX_DURATION_MONTHS do return nil
    ovr: Maybe(Duration_Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }

    second_uf := locale.units.second
    minute_uf := locale.units.minute
    hour_uf := locale.units.hour
    day_uf := locale.units.day
    week_uf := locale.units.week
    month_uf := locale.units.month
    year_uf := locale.units.year
    half := locale.half
    delimiter := locale.delimiter

    if o, ok := ovr.?; ok {
        if v, vok := o.second.?;   vok do second_uf = v
        if v, vok := o.minute.?;   vok do minute_uf = v
        if v, vok := o.hour.?;     vok do hour_uf = v
        if v, vok := o.day.?;      vok do day_uf = v
        if v, vok := o.week.?;     vok do week_uf = v
        if v, vok := o.month.?;    vok do month_uf = v
        if v, vok := o.year.?;     vok do year_uf = v
        if v, vok := o.half.?;     vok do half = v
        if v, vok := o.delimiter.?; vok do delimiter = v
    }

    w := writer_init(buf)

    // 0 seconds
    if total == 0 {
        writer_str(&w, locale.just_now)
        return writer_slice(&w)
    }

    // 1-59 seconds
    if total < 60 {
        resolve_unit(&w, total, second_uf, locale, "")
        return writer_slice(&w)
    }

    total_minutes := total / 60
    remainder_seconds := total %% 60

    // 1-4 minutes: minutes + seconds
    if total_minutes < 5 {
        resolve_unit(&w, total_minutes, minute_uf, locale, "")
        if remainder_seconds > 0 {
            writer_str(&w, delimiter)
            resolve_unit(&w, remainder_seconds, second_uf, locale, "")
        }
        return writer_slice(&w)
    }

    // 5-59 minutes
    if total_minutes < 60 {
        resolve_unit(&w, total_minutes, minute_uf, locale, "")
        return writer_slice(&w)
    }

    total_hours := total / 3600
    remainder_minutes := (total %% 3600) / 60

    // 1-5 hours: hours + minutes (with half marker)
    if total_hours <= 5 {
        if remainder_minutes == 30 {
            resolve_unit(&w, total_hours, hour_uf, locale, half)
        } else {
            resolve_unit(&w, total_hours, hour_uf, locale, "")
            if remainder_minutes > 0 {
                writer_str(&w, delimiter)
                resolve_unit(&w, remainder_minutes, minute_uf, locale, "")
            }
        }
        return writer_slice(&w)
    }

    // 6-23 hours
    if total_hours < 24 {
        resolve_unit(&w, total_hours, hour_uf, locale, "")
        return writer_slice(&w)
    }

    total_days := total / 86400
    remainder_hours := (total %% 86400) / 3600

    // 1-2 days: days + hours (with half marker)
    if total_days <= 2 {
        if remainder_hours == 12 {
            resolve_unit(&w, total_days, day_uf, locale, half)
        } else {
            resolve_unit(&w, total_days, day_uf, locale, "")
            if remainder_hours > 0 {
                writer_str(&w, delimiter)
                resolve_unit(&w, remainder_hours, hour_uf, locale, "")
            }
        }
        return writer_slice(&w)
    }

    // 3-6 days
    if total_days < 7 {
        resolve_unit(&w, total_days, day_uf, locale, "")
        return writer_slice(&w)
    }

    total_weeks := total_days / 7
    remainder_days := total_days %% 7

    // 1-4 weeks: weeks + days (up to 29 days)
    if total_days < 30 {
        resolve_unit(&w, total_weeks, week_uf, locale, "")
        if remainder_days > 0 {
            writer_str(&w, delimiter)
            resolve_unit(&w, remainder_days, day_uf, locale, "")
        }
        return writer_slice(&w)
    }

    // Approximate months (30.44 days average)
    total_months := approximate_months(total_days)

    // 1-11 months
    if total_months < 12 {
        if total_months == 0 do total_months = 1
        resolve_unit(&w, total_months, month_uf, locale, "")
        return writer_slice(&w)
    }

    // 12+ months: years + months
    total_years := total_months / 12
    remainder_months := total_months %% 12
    resolve_unit(&w, total_years, year_uf, locale, "")
    if remainder_months > 0 {
        writer_str(&w, delimiter)
        resolve_unit(&w, remainder_months, month_uf, locale, "")
    }
    return writer_slice(&w)
}

format_duration_int :: proc(buf: []u8, locale: ^Duration_Locale, compactness: Compactness, seconds: int) -> Maybe(string) {
    if seconds < 0 do return nil
    return format_duration_seconds(buf, locale, compactness, seconds)
}

format_duration_iso :: proc(buf: []u8, locale: ^Duration_Locale, compactness: Compactness, start, end: string) -> Maybe(string) {
    if len(start) == 0 || len(end) == 0 do return nil
    s, s_ok := parse_iso_to_seconds(start)
    if !s_ok do return nil
    e, e_ok := parse_iso_to_seconds(end)
    if !e_ok do return nil
    diff := e - s
    if diff < 0 do diff = -diff
    return format_duration_seconds(buf, locale, compactness, diff)
}

format_since :: proc(buf: []u8, locale: ^Duration_Locale, compactness: Compactness, start, as_of: string) -> Maybe(string) {
    if len(start) == 0 || len(as_of) == 0 do return nil
    s, s_ok := parse_iso_to_seconds(start)
    if !s_ok do return nil
    a, a_ok := parse_iso_to_seconds(as_of)
    if !a_ok do return nil
    diff := a - s
    if diff < 0 do return nil

    if diff == 0 {
        w := writer_init(buf)
        writer_str(&w, locale.just_now)
        return writer_slice(&w)
    }

    ovr: Maybe(Duration_Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }
    ago := locale.ago
    if o, ok := ovr.?; ok {
        if v, vok := o.ago.?; vok do ago = v
    }

    dur_buf: [256]u8
    dur, dur_ok := format_duration_seconds(dur_buf[:], locale, compactness, diff).?
    if !dur_ok do return nil

    w := writer_init(buf)
    replace_first(&w, ago, "{0}", dur)
    return w.overflow ? nil : writer_slice(&w)
}

format_until :: proc(buf: []u8, locale: ^Duration_Locale, compactness: Compactness, target, as_of: string) -> Maybe(string) {
    if len(target) == 0 || len(as_of) == 0 do return nil
    t, t_ok := parse_iso_to_seconds(target)
    if !t_ok do return nil
    a, a_ok := parse_iso_to_seconds(as_of)
    if !a_ok do return nil
    diff := t - a
    if diff < 0 do return nil

    if diff == 0 {
        w := writer_init(buf)
        writer_str(&w, locale.just_now)
        return writer_slice(&w)
    }

    ovr: Maybe(Duration_Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }
    in_future := locale.in_future
    if o, ok := ovr.?; ok {
        if v, vok := o.in_future.?; vok do in_future = v
    }

    dur_buf: [256]u8
    dur, dur_ok := format_duration_seconds(dur_buf[:], locale, compactness, diff).?
    if !dur_ok do return nil

    w := writer_init(buf)
    replace_first(&w, in_future, "{0}", dur)
    return w.overflow ? nil : writer_slice(&w)
}
