// sayable-date Odin implementation — types and formatter.
package sayabledate

VERSION :: "0.5.0"

// Types

Day_Format_Exception :: struct {
    day:    int,
    format: string,
}

Date_Compactness_Override :: struct {
    months:                 Maybe([12]string),
    months_in_date:         Maybe([12]string),
    weekdays:               Maybe([7]string),
    day_format:             Maybe(string),
    day_format_exceptions:  Maybe([]Day_Format_Exception),
    date_pattern:           Maybe(string),
    date_pattern_with_year: Maybe(string),
    today:                  Maybe(string),
    tomorrow:               Maybe(string),
    yesterday:              Maybe(string),
}

Date_Locale :: struct {
    code:                   string,
    months:                 [12]string,
    weekdays:               [7]string,
    day_format:             string,
    day_format_exceptions:  []Day_Format_Exception,
    date_pattern:           string,
    date_pattern_with_year: string,
    today:                  string,
    tomorrow:               string,
    yesterday:              string,
    day_after_tomorrow:     Maybe(string),
    day_before_yesterday:   Maybe(string),
    this_weekday:           Maybe(string),
    next_weekday:           Maybe(string),
    last_weekday:           Maybe(string),
    months_in_date:         Maybe([12]string),
    short_override:         Maybe(Date_Compactness_Override),
    compact_override:       Maybe(Date_Compactness_Override),
}

Compactness :: enum {
    Normal,
    Short,
    Compact,
}

// Date parsing

Date :: struct {
    y, m, d: int,
}

parse_date :: proc(s: string) -> (Date, bool) {
    if len(s) == 0 do return {}, false
    // Handle ISO datetime by stripping time part
    date_str := s
    t_pos := index_of(s, "T")
    if t_pos >= 0 {
        date_str = s[0:t_pos]
    }
    if len(date_str) < 10 do return {}, false
    if date_str[4] != '-' || date_str[7] != '-' do return {}, false
    y, y_ok := parse_digits(date_str[0:4])
    if !y_ok do return {}, false
    m, m_ok := parse_digits(date_str[5:7])
    if !m_ok do return {}, false
    d, d_ok := parse_digits(date_str[8:10])
    if !d_ok do return {}, false
    if m < 1 || m > 12 || d < 1 || d > 31 do return {}, false
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

julian_day :: proc(year, month, day: int) -> int {
    a := (14 - month) / 12
    y := year + 4800 - a
    m := month + 12 * a - 3
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

weekday :: proc(year, month, day: int) -> int {
    // 0=Sunday, 1=Monday, ..., 6=Saturday
    jdn := julian_day(year, month, day)
    return (jdn + 1) %% 7
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

// Formatting

find_day_exception :: proc(exceptions: []Day_Format_Exception, day: int) -> (string, bool) {
    for &exc in exceptions {
        if exc.day == day do return exc.format, true
    }
    return "", false
}

format_absolute :: proc(buf: []u8, locale: ^Date_Locale, compactness: Compactness, year, month, day: int, include_year: bool) -> Maybe(string) {
    ovr: Maybe(Date_Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }

    // Resolve months
    months := locale.months
    months_in_date := locale.months_in_date
    wkdays := locale.weekdays
    day_fmt := locale.day_format
    day_excs := locale.day_format_exceptions
    date_pat := locale.date_pattern
    date_pat_yr := locale.date_pattern_with_year

    if o, ok := ovr.?; ok {
        if v, vok := o.months.?; vok do months = v
        if v, vok := o.months_in_date.?; vok do months_in_date = v
        if v, vok := o.weekdays.?; vok do wkdays = v
        if v, vok := o.day_format.?; vok {
            day_fmt = v
            // If override has day_format but no day_format_exceptions, clear exceptions
            if _, eok := o.day_format_exceptions.?; !eok {
                day_excs = {}
            }
        }
        if v, vok := o.day_format_exceptions.?; vok do day_excs = v
        if v, vok := o.date_pattern.?; vok do date_pat = v
        if v, vok := o.date_pattern_with_year.?; vok do date_pat_yr = v
    }

    // Format day string
    day_buf: [12]u8
    day_str := itoa(day_buf[:], day)
    exc_fmt, has_exc := find_day_exception(day_excs, day)
    fmt := has_exc ? exc_fmt : day_fmt

    formatted_day_buf: [64]u8
    fdw := writer_init(formatted_day_buf[:])
    replace_first(&fdw, fmt, "{n}", day_str)
    if fdw.overflow do return nil
    formatted_day := writer_slice(&fdw)

    // Pick month name (genitive form if available)
    month_name: string
    if mid, mid_ok := months_in_date.?; mid_ok {
        month_name = mid[month - 1]
    } else {
        month_name = months[month - 1]
    }

    pattern := include_year ? date_pat_yr : date_pat

    w := writer_init(buf)

    // Replace {month}
    tmp1_buf: [256]u8
    tw1 := writer_init(tmp1_buf[:])
    replace_first(&tw1, pattern, "{month}", month_name)
    if tw1.overflow do return nil
    result1 := writer_slice(&tw1)

    // Replace {day}
    tmp2_buf: [256]u8
    tw2 := writer_init(tmp2_buf[:])
    replace_first(&tw2, result1, "{day}", formatted_day)
    if tw2.overflow do return nil
    result2 := writer_slice(&tw2)

    // Replace {d} (raw day number)
    tmp3_buf: [256]u8
    tw3 := writer_init(tmp3_buf[:])
    replace_first(&tw3, result2, "{d}", day_str)
    if tw3.overflow do return nil
    result3 := writer_slice(&tw3)

    // Replace {m} (raw month number)
    month_buf: [12]u8
    month_str := itoa(month_buf[:], month)
    tmp4_buf: [256]u8
    tw4 := writer_init(tmp4_buf[:])
    replace_first(&tw4, result3, "{m}", month_str)
    if tw4.overflow do return nil
    result4 := writer_slice(&tw4)

    if include_year {
        // Replace {year}
        year_buf: [12]u8
        year_str := itoa(year_buf[:], year)
        tmp5_buf: [256]u8
        tw5 := writer_init(tmp5_buf[:])
        replace_first(&tw5, result4, "{year}", year_str)
        if tw5.overflow do return nil
        result5 := writer_slice(&tw5)

        // Replace {yy}
        yy := year %% 100
        yy_buf: [4]u8
        yy_str: string
        if yy < 10 {
            yy_buf[0] = '0'
            yy_buf[1] = u8(yy) + '0'
            yy_str = string(yy_buf[0:2])
        } else {
            yy_str = itoa(yy_buf[:], yy)
        }
        tmp6_buf: [256]u8
        tw6 := writer_init(tmp6_buf[:])
        replace_first(&tw6, result5, "{yy}", yy_str)
        if tw6.overflow do return nil
        writer_str(&w, writer_slice(&tw6))
    } else {
        writer_str(&w, result4)
    }

    return w.overflow ? nil : writer_slice(&w)
}

format_date :: proc(buf: []u8, locale: ^Date_Locale, compactness: Compactness, date: string) -> Maybe(string) {
    if len(date) == 0 do return nil
    parsed, ok := parse_date(date)
    if !ok do return nil
    return format_absolute(buf, locale, compactness, parsed.y, parsed.m, parsed.d, false)
}

format_date_with_year :: proc(buf: []u8, locale: ^Date_Locale, compactness: Compactness, date: string) -> Maybe(string) {
    if len(date) == 0 do return nil
    parsed, ok := parse_date(date)
    if !ok do return nil
    return format_absolute(buf, locale, compactness, parsed.y, parsed.m, parsed.d, true)
}

format_relative :: proc(buf: []u8, locale: ^Date_Locale, compactness: Compactness, date, as_of: string) -> Maybe(string) {
    if len(date) == 0 || len(as_of) == 0 do return nil
    parsed_date, d_ok := parse_date(date)
    parsed_asof, a_ok := parse_date(as_of)
    if !d_ok || !a_ok do return nil

    ovr: Maybe(Date_Compactness_Override)
    switch compactness {
    case .Short:   ovr = locale.short_override
    case .Compact: ovr = locale.compact_override
    case .Normal:  ovr = nil
    }

    today_str := locale.today
    tomorrow_str := locale.tomorrow
    yesterday_str := locale.yesterday
    if o, ok := ovr.?; ok {
        if v, vok := o.today.?; vok do today_str = v
        if v, vok := o.tomorrow.?; vok do tomorrow_str = v
        if v, vok := o.yesterday.?; vok do yesterday_str = v
    }

    date_jdn := julian_day(parsed_date.y, parsed_date.m, parsed_date.d)
    asof_jdn := julian_day(parsed_asof.y, parsed_asof.m, parsed_asof.d)
    diff := date_jdn - asof_jdn

    // Today
    if diff == 0 {
        w := writer_init(buf)
        writer_str(&w, today_str)
        return w.overflow ? nil : writer_slice(&w)
    }

    // Tomorrow
    if diff == 1 {
        w := writer_init(buf)
        writer_str(&w, tomorrow_str)
        return w.overflow ? nil : writer_slice(&w)
    }

    // Yesterday
    if diff == -1 {
        w := writer_init(buf)
        writer_str(&w, yesterday_str)
        return w.overflow ? nil : writer_slice(&w)
    }

    is_compact := compactness == .Compact

    // Day after tomorrow (optional)
    if diff == 2 && !is_compact {
        if dat, dat_ok := locale.day_after_tomorrow.?; dat_ok {
            w := writer_init(buf)
            writer_str(&w, dat)
            return w.overflow ? nil : writer_slice(&w)
        }
    }

    // Day before yesterday (optional)
    if diff == -2 && !is_compact {
        if dby, dby_ok := locale.day_before_yesterday.?; dby_ok {
            w := writer_init(buf)
            writer_str(&w, dby)
            return w.overflow ? nil : writer_slice(&w)
        }
    }

    // Compact mode: skip weekday references
    if is_compact {
        inc_year := parsed_date.y != parsed_asof.y
        return format_absolute(buf, locale, compactness, parsed_date.y, parsed_date.m, parsed_date.d, inc_year)
    }

    // Resolve weekdays for this compactness
    wkdays := locale.weekdays
    if o, ok := ovr.?; ok {
        if v, vok := o.weekdays.?; vok do wkdays = v
    }

    // This weekday (+2 to +6)
    if diff >= 2 && diff <= 6 {
        if tw, tw_ok := locale.this_weekday.?; tw_ok {
            dow := weekday(parsed_date.y, parsed_date.m, parsed_date.d)
            wd_name := wkdays[dow]
            w := writer_init(buf)
            replace_first(&w, tw, "{weekday}", wd_name)
            return w.overflow ? nil : writer_slice(&w)
        }
    }

    // Last weekday (-2 to -6)
    if diff >= -6 && diff <= -2 {
        if lw, lw_ok := locale.last_weekday.?; lw_ok {
            dow := weekday(parsed_date.y, parsed_date.m, parsed_date.d)
            wd_name := wkdays[dow]
            w := writer_init(buf)
            replace_first(&w, lw, "{weekday}", wd_name)
            return w.overflow ? nil : writer_slice(&w)
        }
    }

    // Next weekday (+7 to +13)
    if diff >= 7 && diff <= 13 {
        if nw, nw_ok := locale.next_weekday.?; nw_ok {
            dow := weekday(parsed_date.y, parsed_date.m, parsed_date.d)
            wd_name := wkdays[dow]
            w := writer_init(buf)
            replace_first(&w, nw, "{weekday}", wd_name)
            return w.overflow ? nil : writer_slice(&w)
        }
    }

    // Calendar fallback
    inc_year := parsed_date.y != parsed_asof.y
    return format_absolute(buf, locale, compactness, parsed_date.y, parsed_date.m, parsed_date.d, inc_year)
}
