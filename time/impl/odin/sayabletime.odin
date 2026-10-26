// sayable-time Odin implementation — types and formatter.
package sayabletime

VERSION :: "0.5.0"

// Types

Clock_Pattern :: struct {
    minute:  int,
    pattern: string,
}

Clock_Config :: struct {
    hours:    [12]string,
    midnight: string,
    noon:     string,
    patterns: []Clock_Pattern,
}

Short_Clock_Config :: struct {
    use_24h: bool,
    format:  string,
    am_pm:   Maybe([2]string),
}

Time_Compactness_Override :: struct {
    clock: Short_Clock_Config,
}

Time_Locale :: struct {
    code:             string,
    clock:            Clock_Config,
    short_override:   Maybe(Time_Compactness_Override),
    compact_override: Maybe(Time_Compactness_Override),
}

Compactness :: enum {
    Normal,
    Short,
    Compact,
}

// Time parsing

parse_digits :: proc(s: string) -> (int, bool) {
    v := 0
    for c in s {
        if c < '0' || c > '9' do return 0, false
        v = v * 10 + int(c - '0')
    }
    return v, true
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

days_in_month :: proc(year, month: int) -> int {
    if month == 2 {
        is_leap := year %% 4 == 0 && (year %% 100 != 0 || year %% 400 == 0)
        return is_leap ? 29 : 28
    }
    if month == 4 || month == 6 || month == 9 || month == 11 do return 30
    return 31
}

// Exactly YYYY-MM-DD naming a real Gregorian calendar day.
is_real_date :: proc(s: string) -> bool {
    if len(s) != 10 || s[4] != '-' || s[7] != '-' do return false
    year, y_ok := parse_digits(s[0:4])
    month, m_ok := parse_digits(s[5:7])
    day, d_ok := parse_digits(s[8:10])
    return y_ok && m_ok && d_ok && month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month)
}

// A clock time, alone or after the T of an ISO datetime whose date is valid
// (docs/input-formats.md).
parse_time :: proc(s: string) -> (int, int, bool) {
    clock := s
    for i := 0; i < len(s); i += 1 {
        if s[i] == 'T' {
            if !is_real_date(s[0:i]) do return 0, 0, false
            clock = s[i + 1:]
            break
        }
    }
    c, ok := parse_clock(clock)
    return c.hour, c.minute, ok
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

// Zero-padded two-digit integer
itoa_pad2 :: proc(buf: []u8, n: int) -> string {
    if n < 10 {
        buf[0] = '0'
        buf[1] = u8(n) + '0'
        return string(buf[0:2])
    }
    return itoa(buf, n)
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

replace_all_in :: proc(w: ^Writer, tmpl: string, marker1, repl1, marker2, repl2: string) {
    // Replace marker1 first, then marker2
    tmp_buf: [256]u8
    tw := writer_init(tmp_buf[:])
    replace_first(&tw, tmpl, marker1, repl1)
    if tw.overflow {
        writer_str(w, tmpl)
        return
    }
    intermediate := writer_slice(&tw)
    replace_first(w, intermediate, marker2, repl2)
}

// Round to nearest 5
round_to_5 :: proc(minute: int) -> int {
    return ((minute + 2) / 5) * 5
}

// Find pattern for a given rounded minute value
find_pattern :: proc(patterns: []Clock_Pattern, rounded: int) -> (string, bool) {
    for &p in patterns {
        if p.minute == rounded do return p.pattern, true
    }
    // Fallback to 0 pattern
    for &p in patterns {
        if p.minute == 0 do return p.pattern, true
    }
    return "", false
}

// Formatting

format_natural :: proc(buf: []u8, locale: ^Time_Locale, hour, minute: int) -> string {
    clock := &locale.clock
    rounded := round_to_5(minute)
    h := hour
    if rounded == 60 {
        rounded = 0
        h = (h + 1) %% 24
    }

    if rounded == 0 {
        if h == 0 {
            w := writer_init(buf)
            writer_str(&w, clock.midnight)
            return writer_slice(&w)
        }
        if h == 12 {
            w := writer_init(buf)
            writer_str(&w, clock.noon)
            return writer_slice(&w)
        }
    }

    h12 := h %% 12
    next_h12 := (h + 1) %% 12
    h_name := clock.hours[h12]
    next_h_name := clock.hours[next_h12]

    pattern, _ := find_pattern(clock.patterns, rounded)

    w := writer_init(buf)
    replace_all_in(&w, pattern, "{h}", h_name, "{next_h}", next_h_name)
    return writer_slice(&w)
}

format_digital :: proc(buf: []u8, sc: ^Short_Clock_Config, hour, minute: int) -> string {
    w := writer_init(buf)

    h_buf: [4]u8
    mm_buf: [4]u8
    mm_str := itoa_pad2(mm_buf[:], minute)

    if sc.use_24h {
        h_str := itoa(h_buf[:], hour)
        tmp_buf: [64]u8
        tw := writer_init(tmp_buf[:])
        replace_first(&tw, sc.format, "{h}", h_str)
        if !tw.overflow {
            replace_first(&w, writer_slice(&tw), "{mm}", mm_str)
        }
        return writer_slice(&w)
    }

    h12 := hour %% 12
    if h12 == 0 do h12 = 12
    h_str := itoa(h_buf[:], h12)

    am_str := "AM"
    pm_str := "PM"
    if ap, ap_ok := sc.am_pm.?; ap_ok {
        am_str = ap[0]
        pm_str = ap[1]
    }
    ampm := hour < 12 ? am_str : pm_str

    // Replace {h}
    tmp1_buf: [64]u8
    tw1 := writer_init(tmp1_buf[:])
    replace_first(&tw1, sc.format, "{h}", h_str)
    if tw1.overflow do return ""

    // Replace {mm}
    tmp2_buf: [64]u8
    tw2 := writer_init(tmp2_buf[:])
    replace_first(&tw2, writer_slice(&tw1), "{mm}", mm_str)
    if tw2.overflow do return ""

    // Replace {ampm}
    replace_first(&w, writer_slice(&tw2), "{ampm}", ampm)
    return writer_slice(&w)
}

format_time :: proc(buf: []u8, locale: ^Time_Locale, compactness: Compactness, input: string) -> Maybe(string) {
    if len(input) == 0 do return nil
    hour, minute, ok := parse_time(input)
    if !ok do return nil

    if compactness != .Normal {
        ovr: Maybe(Time_Compactness_Override)
        switch compactness {
        case .Short:   ovr = locale.short_override
        case .Compact: ovr = locale.compact_override
        case .Normal:  ovr = nil
        }
        if o, ovr_ok := ovr.?; ovr_ok {
            sc := o.clock
            return format_digital(buf, &sc, hour, minute)
        }
    }

    return format_natural(buf, locale, hour, minute)
}
