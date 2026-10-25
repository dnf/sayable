// sayable-time Goose implementation — formatter.

namespace sayabletime;

// ---- Time parsing ----

fn parse_digits(s: u8[:]) -> i64, bool {
    guard s.len > 0 else { return 0, false; }
    var v = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        v = v * 10 + (c - '0');
    }
    return v, true;
}

fn is_digit(c: u8) -> bool { c >= '0' && c <= '9' }

// Number of consecutive ASCII digits in `s` starting at `from`.
fn digit_run(s: u8[:], from: i64) -> i64 {
    var i = from;
    while i < s.len && is_digit(s[i]) { i += 1; }
    return i - from;
}

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 => if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) { 29 } else { 28 },
        4, 6, 9, 11 => 30,
        _ => 31,
    }
}

// Exactly YYYY-MM-DD naming a real calendar day.
fn is_real_date(s: u8[:]) -> bool {
    guard s.len == 10 && s[4] == '-' && s[7] == '-' else { return false; }
    let y, oky = parse_digits(s[0..4]);
    let m, okm = parse_digits(s[5..7]);
    let d, okd = parse_digits(s[8..10]);
    guard oky && okm && okd else { return false; }
    return m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m);
}

// Value of the two ASCII digits at `at` (already checked to be digits).
fn two_digit_value(s: u8[:], at: i64) -> i64 { (s[at] - '0') * 10 + (s[at + 1] - '0') }

// Index just past an optional zone suffix ("Z" or "+HH:MM"/"-HH:MM") at
// `from`, or -1 when a suffix starts but is malformed.
fn skip_zone(s: u8[:], from: i64) -> i64 {
    guard from < s.len else { return from; }
    if s[from] == 'Z' { return from + 1; }
    guard s[from] == '+' || s[from] == '-' else { return from; }
    guard from + 6 <= s.len && digit_run(s, from + 1) >= 2 && s[from + 3] == ':' && digit_run(s, from + 4) >= 2 else { return -1; }
    return from + 6;
}

// Hour and minute of a clock time: H:MM or HH:MM, then optional :SS, an
// optional fraction after the seconds and an optional zone suffix, which
// is validated but not applied (docs/input-formats.md).
fn parse_clock(s: u8[:]) -> i64, i64, bool {
    let hour_digits = digit_run(s, 0);
    guard hour_digits == 1 || hour_digits == 2 else { return 0, 0, false; }
    var i = hour_digits;
    guard i < s.len && s[i] == ':' && digit_run(s, i + 1) >= 2 else { return 0, 0, false; }
    let hour = if hour_digits == 1 { s[0] - '0' } else { two_digit_value(s, 0) };
    let minute = two_digit_value(s, i + 1);
    i += 3;
    var second = 0;
    if i < s.len && s[i] == ':' {
        guard digit_run(s, i + 1) >= 2 else { return 0, 0, false; }
        second = two_digit_value(s, i + 1);
        i += 3;
        if i < s.len && s[i] == '.' && digit_run(s, i + 1) > 0 { i += 1 + digit_run(s, i + 1); }
    }
    let end = skip_zone(s, i);
    guard end == s.len && hour <= 23 && minute <= 59 && second <= 59 else { return 0, 0, false; }
    return hour, minute, true;
}

// Hour and minute of a clock time, alone or after the "T" of an ISO
// datetime whose date is real; false for anything else.
fn parse_time(input: u8[:]) -> i64, i64, bool {
    let t_pos = find(input, "T");
    guard t_pos >= 0 else { return parse_clock(input); }
    guard is_real_date(input[..t_pos]) else { return 0, 0, false; }
    return parse_clock(input[t_pos + 1..]);
}

// ---- Templates ----

fn append_replacing_first(out: u8[>..]&, tmpl: u8[:], marker: u8[:], replacement: u8[:]) {
    let pos = find(tmpl, marker);
    if pos < 0 {
        out.append(tmpl);
        return;
    }
    out.append(tmpl[..pos]);
    out.append(replacement);
    out.append(tmpl[pos + marker.len..]);
}

fn round_to_5(minute: i64) -> i64 { (minute + 2) / 5 * 5 }

fn two_digits(n: i64) -> u8[>..] {
    if n < 10 { str("0", n) } else { str(n) }
}

// ---- Formatting ----

fn format_natural(clock: const ClockConfig&, hour: i64, minute: i64) -> u8[>..] {
    var rounded = round_to_5(minute);
    var h = hour;
    if rounded == 60 {
        rounded = 0;
        h = (h + 1) % 24;
    }
    if rounded == 0 && h == 0 { return str(clock.midnight); }
    if rounded == 0 && h == 12 { return str(clock.noon); }

    let pattern = clock.patterns[rounded / 5];
    var with_hour: u8[>..] = [];
    append_replacing_first(with_hour, pattern, "{h}", clock.hours[h % 12]);
    var out: u8[>..] = [];
    append_replacing_first(out, with_hour, "{next_h}", clock.hours[(h + 1) % 12]);
    return out;
}

fn format_digital(sc: const ShortClockConfig&, hour: i64, minute: i64) -> u8[>..] {
    let twelve_hour = if hour % 12 == 0 { 12 } else { hour % 12 };
    let shown_hour = if sc.use_24h { hour } else { twelve_hour };

    var with_hour: u8[>..] = [];
    append_replacing_first(with_hour, sc.format, "{h}", str(shown_hour));
    var with_minute: u8[>..] = [];
    append_replacing_first(with_minute, with_hour, "{mm}", two_digits(minute));

    var out: u8[>..] = [];
    if sc.use_24h {
        out.append(with_minute);
    } else {
        append_replacing_first(out, with_minute, "{ampm}", if hour < 12 { sc.am_pm[0] } else { sc.am_pm[1] });
    }
    return out;
}

// ---- Public API ----

// Format "HH:MM" (or an ISO datetime) as spoken or digital clock time.
// False for empty or invalid input. A mode without a digital clock
// override falls back to the spoken clock.
fn format_time(locale: const TimeLocale&, compactness: Compactness, input: u8[:]) -> u8[>..], bool {
    let hour, minute, ok = parse_time(input);
    guard ok else { return [], false; }

    let o = match compactness {
        Normal => CompactnessOverride { .. },
        Short => locale.short_override,
        Compact => locale.compact_override,
    };
    if o.has_clock { return format_digital(o.clock, hour, minute), true; }
    return format_natural(locale.clock, hour, minute), true;
}
