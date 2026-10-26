// sayable-date Goose implementation — formatter.

namespace sayabledate;

// ---- Date parsing and arithmetic ----

struct Date { y: i64, m: i64, d: i64 }

fn parse_digits(s: u8[:]) -> i64, bool {
    guard s.len > 0 else { return 0, false; }
    var v = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        v = v * 10 + (c - '0');
    }
    return v, true;
}

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 => if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) { 29 } else { 28 },
        4, 6, 9, 11 => 30,
        _ => 31,
    }
}

// Exactly YYYY-MM-DD naming a real calendar day, optionally followed by
// "T" and the rest of an ISO datetime, which is ignored
// (docs/input-formats.md).
fn parse_date(s: u8[:]) -> Date, bool {
    guard s.len == 10 || (s.len > 10 && s[10] == 'T') else { return Date { 0, 0, 0 }, false; }
    guard s[4] == '-' && s[7] == '-' else { return Date { 0, 0, 0 }, false; }
    let y, oky = parse_digits(s[0..4]);
    let m, okm = parse_digits(s[5..7]);
    let d, okd = parse_digits(s[8..10]);
    guard oky && okm && okd else { return Date { 0, 0, 0 }, false; }
    guard m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m) else { return Date { 0, 0, 0 }, false; }
    return Date { y, m, d }, true;
}

fn julian_day(date: Date) -> i64 {
    let a = (14 - date.m) / 12;
    let y = date.y + 4800 - a;
    let m = date.m + 12 * a - 3;
    return date.d + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

// 0 = Sunday ... 6 = Saturday.
fn weekday_index(date: Date) -> i64 {
    return (julian_day(date) + 1) % 7;
}

// ---- Locale resolution ----

// The locale's fields after the short or compact override is applied.
struct ResolvedLocale {
    months: (const u8[:])[12],
    has_months_in_date: bool,
    months_in_date: (const u8[:])[12],
    weekdays: (const u8[:])[7],
    day_format: const u8[:],
    day_format_exceptions: const DayFormatException[:],
    date_pattern: const u8[:],
    date_pattern_with_year: const u8[:],
    today: const u8[:],
    tomorrow: const u8[:],
    yesterday: const u8[:],
}

fn resolve_locale(locale: const DateLocale&, compactness: Compactness) -> ResolvedLocale {
    var r = ResolvedLocale {
        months: locale.months,
        has_months_in_date: locale.has_months_in_date,
        months_in_date: locale.months_in_date,
        weekdays: locale.weekdays,
        day_format: locale.day_format,
        day_format_exceptions: locale.day_format_exceptions,
        date_pattern: locale.date_pattern,
        date_pattern_with_year: locale.date_pattern_with_year,
        today: locale.today,
        tomorrow: locale.tomorrow,
        yesterday: locale.yesterday,
    };
    if compactness == Compactness.Normal { return r; }

    let o = if compactness == Compactness.Short { locale.short_override } else { locale.compact_override };
    if o.has_months { r.months = o.months; }
    if o.has_months_in_date {
        r.has_months_in_date = true;
        r.months_in_date = o.months_in_date;
    }
    if o.has_weekdays { r.weekdays = o.weekdays; }
    if o.has_day_format {
        r.day_format = o.day_format;
        // A new day format without its own exceptions drops the base
        // locale's ordinal suffixes ("15", not "15th").
        if !o.has_day_format_exceptions { r.day_format_exceptions = NO_DAY_FORMAT_EXCEPTIONS; }
    }
    if o.has_day_format_exceptions { r.day_format_exceptions = o.day_format_exceptions; }
    if o.has_date_pattern { r.date_pattern = o.date_pattern; }
    if o.has_date_pattern_with_year { r.date_pattern_with_year = o.date_pattern_with_year; }
    if o.has_today { r.today = o.today; }
    if o.has_tomorrow { r.tomorrow = o.tomorrow; }
    if o.has_yesterday { r.yesterday = o.yesterday; }
    return r;
}

// ---- Templates ----

fn replace_first(tmpl: u8[:], marker: u8[:], replacement: u8[:]) -> u8[>..] {
    var out: u8[>..] = [];
    let pos = find(tmpl, marker);
    if pos < 0 {
        out.append(tmpl);
        return out;
    }
    out.append(tmpl[..pos]);
    out.append(replacement);
    out.append(tmpl[pos + marker.len..]);
    return out;
}

fn day_format_for(rl: const ResolvedLocale&, day: i64) -> const u8[:] {
    for exception in rl.day_format_exceptions {
        if exception.day == day { return exception.format; }
    }
    return rl.day_format;
}

fn two_digit_year(year: i64) -> u8[>..] {
    var out: u8[>..] = [];
    format_int(out, year % 100, 10, 2, '0');
    return out;
}

fn format_absolute(rl: const ResolvedLocale&, date: Date, include_year: bool) -> u8[>..] {
    let day_str = str(date.d);
    let formatted_day = replace_first(day_format_for(rl, date.d), "{n}", day_str);
    let month_name = if rl.has_months_in_date { rl.months_in_date[date.m - 1] } else { rl.months[date.m - 1] };
    let pattern = if include_year { rl.date_pattern_with_year } else { rl.date_pattern };

    let with_month = replace_first(pattern, "{month}", month_name);
    let with_day = replace_first(with_month, "{day}", formatted_day);
    let with_d = replace_first(with_day, "{d}", day_str);
    let with_m = replace_first(with_d, "{m}", str(date.m));
    guard include_year else { return with_m; }
    let with_year = replace_first(with_m, "{year}", str(date.y));
    return replace_first(with_year, "{yy}", two_digit_year(date.y));
}

fn weekday_phrase(rl: const ResolvedLocale&, phrase: u8[:], date: Date) -> u8[>..] {
    return replace_first(phrase, "{weekday}", rl.weekdays[weekday_index(date)]);
}

// ---- Public API ----

// Format an absolute calendar date ("March 15th"); false for an empty or
// invalid date.
fn format_date(locale: const DateLocale&, compactness: Compactness, date: u8[:]) -> u8[>..], bool {
    let parsed, ok = parse_date(date);
    guard ok else { return [], false; }
    let rl = resolve_locale(locale, compactness);
    return format_absolute(rl, parsed, false), true;
}

// Format an absolute calendar date with its year ("March 15th, 2025").
fn format_date_with_year(locale: const DateLocale&, compactness: Compactness, date: u8[:]) -> u8[>..], bool {
    let parsed, ok = parse_date(date);
    guard ok else { return [], false; }
    let rl = resolve_locale(locale, compactness);
    return format_absolute(rl, parsed, true), true;
}

// Format `date` the way people refer to it on `as_of`: "tomorrow", "next
// Thursday", or a calendar date for anything further away.
fn format_relative(locale: const DateLocale&, compactness: Compactness, date: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let target, ok_target = parse_date(date);
    guard ok_target else { return [], false; }
    let ref_date, ok_ref = parse_date(as_of);
    guard ok_ref else { return [], false; }

    let rl = resolve_locale(locale, compactness);
    let diff = julian_day(target) - julian_day(ref_date);
    let is_compact = compactness == Compactness.Compact;
    let include_year = target.y != ref_date.y;

    if diff == 0 { return str(rl.today), true; }
    if diff == 1 { return str(rl.tomorrow), true; }
    if diff == -1 { return str(rl.yesterday), true; }
    if diff == 2 && locale.day_after_tomorrow.len > 0 && !is_compact {
        return str(locale.day_after_tomorrow), true;
    }
    if diff == -2 && locale.day_before_yesterday.len > 0 && !is_compact {
        return str(locale.day_before_yesterday), true;
    }
    // Compact output skips the weekday tiers and goes straight to the calendar.
    if is_compact { return format_absolute(rl, target, include_year), true; }

    if diff >= 2 && diff <= 6 && locale.this_weekday.len > 0 {
        return weekday_phrase(rl, locale.this_weekday, target), true;
    }
    if diff >= -6 && diff <= -2 && locale.last_weekday.len > 0 {
        return weekday_phrase(rl, locale.last_weekday, target), true;
    }
    if diff >= 7 && diff <= 13 && locale.next_weekday.len > 0 {
        return weekday_phrase(rl, locale.next_weekday, target), true;
    }
    return format_absolute(rl, target, include_year), true;
}
