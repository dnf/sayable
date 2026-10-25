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

// Everything before the first byte of `stops`, or all of `s`.
fn before_any(s: u8[:], stops: u8[:]) -> u8[:] {
    for c, i in s {
        for stop in stops {
            if c == stop { return s[..i]; }
        }
    }
    return s;
}

// Seconds since 2000-01-01T00:00 for "YYYY-MM-DDTHH:MM[:SS[.fff]]",
// ignoring any "Z" or "+hh:mm" suffix; false when malformed.
fn parse_iso_seconds(iso: u8[:]) -> i64, bool {
    let t_idx = find(iso, "T");
    guard t_idx >= 0 else { return 0, false; }
    let date_part = iso[..t_idx];
    let time_part = before_any(iso[t_idx + 1..], "+Z");

    guard date_part.len >= 10 && date_part[4] == '-' && date_part[7] == '-' else { return 0, false; }
    let year, oky = parse_digits(date_part[0..4]);
    let month, okm = parse_digits(date_part[5..7]);
    let day, okd = parse_digits(date_part[8..10]);
    guard oky && okm && okd else { return 0, false; }

    let c1 = find(time_part, ":");
    guard c1 >= 0 else { return 0, false; }
    let hour, okh = parse_digits(time_part[..c1]);
    guard okh else { return 0, false; }
    let rest = time_part[c1 + 1..];

    var minute = 0;
    var second = 0;
    let c2 = find(rest, ":");
    if c2 >= 0 {
        let mi, okmi = parse_digits(rest[..c2]);
        let se, okse = parse_digits(before_any(rest[c2 + 1..], "."));
        guard okmi && okse else { return 0, false; }
        minute = mi;
        second = se;
    } else {
        let mi, okmi = parse_digits(rest);
        guard okmi else { return 0, false; }
        minute = mi;
    }

    let days = days_since_epoch(year, month, day);
    return days * 86400 + hour * 3600 + minute * 60 + second, true;
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

// round(days / 30.44) in integer arithmetic.
fn approximate_months(total_days: i64) -> i64 {
    return (total_days * 200 + 3044) / 6088;
}

// ---- Duration tiers ----

fn format_seconds(r: const Resolved&, total: i64) -> u8[>..] {
    var out: u8[>..] = [];
    let u = r.units;

    if total == 0 {
        out.append(r.just_now);
        return out;
    }
    if total < 60 {
        append_unit(out, total, u.second, r.rule, "");
        return out;
    }

    let total_minutes = total / 60;
    if total_minutes < 5 {
        append_pair(out, r, total_minutes, u.minute, total % 60, u.second);
        return out;
    }
    if total_minutes < 60 {
        append_unit(out, total_minutes, u.minute, r.rule, "");
        return out;
    }

    let total_hours = total / 3600;
    let remainder_minutes = (total % 3600) / 60;
    if total_hours <= 5 {
        if remainder_minutes == 30 {
            append_unit(out, total_hours, u.hour, r.rule, r.half);
        } else {
            append_pair(out, r, total_hours, u.hour, remainder_minutes, u.minute);
        }
        return out;
    }
    if total_hours < 24 {
        append_unit(out, total_hours, u.hour, r.rule, "");
        return out;
    }

    let total_days = total / 86400;
    let remainder_hours = (total % 86400) / 3600;
    if total_days <= 2 {
        if remainder_hours == 12 {
            append_unit(out, total_days, u.day, r.rule, r.half);
        } else {
            append_pair(out, r, total_days, u.day, remainder_hours, u.hour);
        }
        return out;
    }
    if total_days < 7 {
        append_unit(out, total_days, u.day, r.rule, "");
        return out;
    }
    if total_days < 30 {
        append_pair(out, r, total_days / 7, u.week, total_days % 7, u.day);
        return out;
    }

    let total_months = max(approximate_months(total_days), 1);
    if total_months < 12 {
        append_unit(out, total_months, u.month, r.rule, "");
        return out;
    }
    append_pair(out, r, total_months / 12, u.year, total_months % 12, u.month);
    return out;
}

// "just now" at zero, otherwise the duration wrapped in `tmpl` ("{0} ago").
fn format_relative(r: const Resolved&, diff: i64, tmpl: u8[:]) -> u8[>..] {
    var out: u8[>..] = [];
    if diff == 0 {
        out.append(r.just_now);
    } else {
        append_replacing_first(out, tmpl, "{0}", format_seconds(r, diff));
    }
    return out;
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

// A duration of `seconds`; false when negative.
fn format_duration(locale: const Locale&, compactness: Compactness, seconds: i64) -> u8[>..], bool {
    guard seconds >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_seconds(r, seconds), true;
}

// The duration between two ISO timestamps, in either order.
fn format_duration_iso(locale: const Locale&, compactness: Compactness, start: u8[:], end: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(start, end);
    guard ok else { return [], false; }
    let r = resolve(locale, compactness);
    return format_seconds(r, abs(diff)), true;
}

// Time elapsed since `start` ("5 minutes ago"); false when `as_of` is earlier.
fn format_since(locale: const Locale&, compactness: Compactness, start: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(start, as_of);
    guard ok && diff >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_relative(r, diff, r.ago), true;
}

// Time remaining until `target` ("in 20 minutes"); false when it has passed.
fn format_until(locale: const Locale&, compactness: Compactness, target: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let diff, ok = seconds_between(as_of, target);
    guard ok && diff >= 0 else { return [], false; }
    let r = resolve(locale, compactness);
    return format_relative(r, diff, r.in_future), true;
}
