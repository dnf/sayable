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

// Index of the first byte of `s` that is one of `stops`, or s.len.
fn end_before_any(s: u8[:], stops: u8[:]) -> i64 {
    for c, i in s {
        if contains(stops, c) { return i; }
    }
    return s.len;
}

// Hour and minute of "HH:MM", "HH:MM:SS(.fff)" or an ISO datetime
// ("2025-01-15T14:15:00Z"); false for anything else or out of range.
fn parse_time(input: u8[:]) -> i64, i64, bool {
    let t_pos = find(input, "T");
    let after_date = if t_pos >= 0 { input[t_pos + 1..] } else { input[..] };
    let clock_part = after_date[..end_before_any(after_date, "+Z")];

    let colon = find(clock_part, ":");
    guard colon >= 0 else { return 0, 0, false; }
    let minute_part = clock_part[colon + 1..];

    let hour, ok_hour = parse_digits(clock_part[..colon]);
    let minute, ok_minute = parse_digits(minute_part[..end_before_any(minute_part, ".:")]);
    guard ok_hour && ok_minute && hour <= 23 && minute <= 59 else { return 0, 0, false; }
    return hour, minute, true;
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
