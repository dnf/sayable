// sayable-duration Goose implementation — formatter.

namespace sayableduration;

// ---- ISO datetime parsing ----

fn parse_digits(s: u8[:]) -> i64, bool {
    guard s.len > 0 else { return 0, false; }
    var v = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        v = v * 10 + (c - '0');
    }
    return v, true;
}

fn is_leap_year(year: i64) -> bool {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 => if is_leap_year(year) { 29 } else { 28 },
        4, 6, 9, 11 => 30,
        _ => 31,
    }
}

fn days_in_year(year: i64) -> i64 {
    if is_leap_year(year) { 366 } else { 365 }
}

// Days from 2000-01-01; only differences between two results matter.
fn days_since_epoch(year: i64, month: i64, day: i64) -> i64 {
    var days = 0;
    if year >= 2000 {
        for y in 2000..year { days += days_in_year(y); }
    } else {
        for y in year..2000 { days -= days_in_year(y); }
    }
    for m in 1..month { days += days_in_month(year, m); }
    return days + day - 1;
}

fn is_digit(c: u8) -> bool { c >= '0' && c <= '9' }

// Number of consecutive ASCII digits in `s` starting at `from`.
fn digit_run(s: u8[:], from: i64) -> i64 {
    var i = from;
    while i < s.len && is_digit(s[i]) { i += 1; }
    return i - from;
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

// Seconds into the day of a clock time: H:MM or HH:MM, then optional :SS,
// an optional fraction after the seconds and an optional zone suffix,
// which is validated but not applied; false when malformed.
fn parse_clock_seconds(s: u8[:]) -> i64, bool {
    let hour_digits = digit_run(s, 0);
    guard hour_digits == 1 || hour_digits == 2 else { return 0, false; }
    var i = hour_digits;
    guard i < s.len && s[i] == ':' && digit_run(s, i + 1) >= 2 else { return 0, false; }
    let hour = if hour_digits == 1 { s[0] - '0' } else { two_digit_value(s, 0) };
    let minute = two_digit_value(s, i + 1);
    i += 3;
    var second = 0;
    if i < s.len && s[i] == ':' {
        guard digit_run(s, i + 1) >= 2 else { return 0, false; }
        second = two_digit_value(s, i + 1);
        i += 3;
        if i < s.len && s[i] == '.' && digit_run(s, i + 1) > 0 { i += 1 + digit_run(s, i + 1); }
    }
    let end = skip_zone(s, i);
    guard end == s.len && hour <= 23 && minute <= 59 && second <= 59 else { return 0, false; }
    return hour * 3600 + minute * 60 + second, true;
}

// Seconds since 2000-01-01T00:00 for a timestamp "YYYY-MM-DDTHH:MM" with
// optional seconds, fraction and zone suffix (docs/input-formats.md);
// false when malformed or not a real calendar day.
fn parse_iso_seconds(iso: u8[:]) -> i64, bool {
    guard iso.len > 11 && iso[4] == '-' && iso[7] == '-' && iso[10] == 'T' else { return 0, false; }
    let year, oky = parse_digits(iso[0..4]);
    let month, okm = parse_digits(iso[5..7]);
    let day, okd = parse_digits(iso[8..10]);
    guard oky && okm && okd else { return 0, false; }
    guard month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month) else { return 0, false; }
    let clock, okc = parse_clock_seconds(iso[11..]);
    guard okc else { return 0, false; }
    return days_since_epoch(year, month, day) * 86400 + clock, true;
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

// The locale's strings with the short or compact override applied.
struct Resolved {
    rule: PluralRule,
    units: UnitSet,
    half: const u8[:],
    delimiter: const u8[:],
    just_now: const u8[:],
    ago: const u8[:],
    in_future: const u8[:],
}

fn override_unit(base: UnitForms, over: UnitForms) -> UnitForms {
    if over.other.len > 0 { over } else { base }
}

fn resolve(locale: const Locale&, compactness: Compactness) -> Resolved {
    var r = Resolved {
        rule: locale.plural,
        units: locale.units,
        half: locale.half,
        delimiter: locale.delimiter,
        just_now: locale.just_now,
        ago: locale.ago,
        in_future: locale.in_future,
    };
    if compactness == Compactness.Normal { return r; }

    let o = if compactness == Compactness.Short { locale.short_override } else { locale.compact_override };
    r.units.second = override_unit(r.units.second, o.units.second);
    r.units.minute = override_unit(r.units.minute, o.units.minute);
    r.units.hour = override_unit(r.units.hour, o.units.hour);
    r.units.day = override_unit(r.units.day, o.units.day);
    r.units.week = override_unit(r.units.week, o.units.week);
    r.units.month = override_unit(r.units.month, o.units.month);
    r.units.year = override_unit(r.units.year, o.units.year);
    if o.has_half { r.half = o.half; }
    if o.has_delimiter { r.delimiter = o.delimiter; }
    if o.has_ago { r.ago = o.ago; }
    if o.has_in_future { r.in_future = o.in_future; }
    return r;
}

// Append `count` in the unit's plural form. A "{n}"-style half marker
// decorates the number ("1½ hours"); a "{0}"-style one wraps the whole
// unit ("1時間半"). Half-marked counts always take the "other" form.
fn append_unit(out: u8[>..]&, count: i64, uf: const UnitForms&, rule: PluralRule, half: u8[:]) {
    let base_n = str(count);
    var n_str: u8[>..] = [];
    if half.len > 0 && find(half, "{n}") >= 0 {
        append_replacing_first(n_str, half, "{n}", base_n);
    } else {
        n_str.append(base_n);
    }

    let cat = if half.len > 0 { PluralCategory.Other } else { plural_category(rule, count) };
    var unit: u8[>..] = [];
    append_replacing_first(unit, resolve_forms(uf, cat), "{n}", n_str);

    if half.len > 0 && find(half, "{0}") >= 0 {
        append_replacing_first(out, half, "{0}", unit);
    } else {
        out.append(unit);
    }
}

// Append `major` and, when non-zero, the delimiter and `minor`.
fn append_pair(out: u8[>..]&, r: const Resolved&, major: i64, major_uf: const UnitForms&, minor: i64, minor_uf: const UnitForms&) {
    append_unit(out, major, major_uf, r.rule, "");
    if minor > 0 {
        out.append(r.delimiter);
        append_unit(out, minor, minor_uf, r.rule, "");
    }
}

// 500 years, the same ceiling as sayable-age.
let MAX_DURATION_MONTHS = 6000;

// round(days / 30.44) in integer arithmetic.
fn approximate_months(total_days: i64) -> i64 {
    return (total_days * 200 + 3044) / 6088;
}

// ---- Duration tiers ----

// The duration of `total` seconds; false beyond MAX_DURATION_MONTHS.
fn format_seconds(r: const Resolved&, total: i64) -> u8[>..], bool {
    var out: u8[>..] = [];
    let u = r.units;

    if total == 0 {
        out.append(r.just_now);
        return out, true;
    }
    if total < 60 {
        append_unit(out, total, u.second, r.rule, "");
        return out, true;
    }

    let total_minutes = total / 60;
    if total_minutes < 5 {
        append_pair(out, r, total_minutes, u.minute, total % 60, u.second);
        return out, true;
    }
    if total_minutes < 60 {
        append_unit(out, total_minutes, u.minute, r.rule, "");
        return out, true;
    }

    let total_hours = total / 3600;
    let remainder_minutes = (total % 3600) / 60;
    if total_hours <= 5 {
        if remainder_minutes == 30 {
            append_unit(out, total_hours, u.hour, r.rule, r.half);
        } else {
            append_pair(out, r, total_hours, u.hour, remainder_minutes, u.minute);
        }
        return out, true;
    }
    if total_hours < 24 {
        append_unit(out, total_hours, u.hour, r.rule, "");
        return out, true;
    }

    let total_days = total / 86400;
    let remainder_hours = (total % 86400) / 3600;
    if total_days <= 2 {
        if remainder_hours == 12 {
            append_unit(out, total_days, u.day, r.rule, r.half);
        } else {
            append_pair(out, r, total_days, u.day, remainder_hours, u.hour);
        }
        return out, true;
    }
    if total_days < 7 {
        append_unit(out, total_days, u.day, r.rule, "");
        return out, true;
    }
    if total_days < 30 {
        append_pair(out, r, total_days / 7, u.week, total_days % 7, u.day);
        return out, true;
    }

    let total_months = max(approximate_months(total_days), 1);
    guard total_months <= MAX_DURATION_MONTHS else { return [], false; }
    if total_months < 12 {
        append_unit(out, total_months, u.month, r.rule, "");
        return out, true;
    }
    append_pair(out, r, total_months / 12, u.year, total_months % 12, u.month);
    return out, true;
}

// "just now" at zero, otherwise the duration wrapped in `tmpl` ("{0} ago");
// false beyond MAX_DURATION_MONTHS.
fn format_relative(r: const Resolved&, diff: i64, tmpl: u8[:]) -> u8[>..], bool {
    var out: u8[>..] = [];
    if diff == 0 {
        out.append(r.just_now);
        return out, true;
    }
    let duration, ok = format_seconds(r, diff);
    guard ok else { return [], false; }
    append_replacing_first(out, tmpl, "{0}", duration);
    return out, true;
}

// The seconds from `from` to `to`; false when either is empty or malformed.
fn seconds_between(from: u8[:], to: u8[:]) -> i64, bool {
    guard from.len > 0 && to.len > 0 else { return 0, false; }
    let f, okf = parse_iso_seconds(from);
    guard okf else { return 0, false; }
    let t, okt = parse_iso_seconds(to);
    guard okt else { return 0, false; }
    return t - f, true;
}

// ---- Public API ----

// A duration of `seconds`; false when negative or beyond 500 years.
fn format_duration(locale: const Locale&, compactness: Compactness, seconds: i64) -> u8[>..], bool {
    guard seconds >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_seconds(r, seconds);
}

// The duration between two ISO timestamps, in either order.
fn format_duration_iso(locale: const Locale&, compactness: Compactness, start: u8[:], end: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(start, end);
    guard ok else { return [], false; }
    let r = resolve(locale, compactness);
    return format_seconds(r, abs(diff));
}

// Time elapsed since `start` ("5 minutes ago"); false when `as_of` is earlier.
fn format_since(locale: const Locale&, compactness: Compactness, start: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(start, as_of);
    guard ok && diff >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_relative(r, diff, r.ago);
}

// Time remaining until `target` ("in 20 minutes"); false when it has passed.
fn format_until(locale: const Locale&, compactness: Compactness, target: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(as_of, target);
    guard ok && diff >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_relative(r, diff, r.in_future);
}
