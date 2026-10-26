// sayable-age Goose implementation — formatter.

namespace sayableage;

import os;

let MAX_AGE_MONTHS = 6000;

// ---- Date parsing and arithmetic ----

struct Date { y: i64, m: i64, d: i64 }

fn parse_digits(s: u8[:]) -> i64, bool {
    var v = 0;
    for c in s {
        if c < '0' || c > '9' { return 0, false; }
        v = v * 10 + (c - '0');
    }
    return v, true;
}

// Exactly YYYY-MM-DD naming a real calendar day (docs/input-formats.md).
fn parse_date(s: u8[:]) -> Date, bool {
    guard s.len == 10 && s[4] == '-' && s[7] == '-' else { return Date { 0, 0, 0 }, false; }
    let y, oky = parse_digits(s[0..4]);
    let m, okm = parse_digits(s[5..7]);
    let d, okd = parse_digits(s[8..10]);
    guard oky && okm && okd else { return Date { 0, 0, 0 }, false; }
    guard m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m) else { return Date { 0, 0, 0 }, false; }
    return Date { y, m, d }, true;
}

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 => if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) { 29 } else { 28 },
        4, 6, 9, 11 => 30,
        _ => 31,
    }
}

fn julian_day(date: Date) -> i64 {
    let a = (14 - date.m) / 12;
    let y = date.y + 4800 - a;
    let m = date.m + 12 * a - 3;
    return date.d + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

// Whole calendar months from dob to ref, counting a birthday on the 31st
// as reached on the last day of a shorter month.
fn months_between(dob: Date, ref: Date) -> i64 {
    let clamped_birthday = min(dob.d, days_in_month(ref.y, ref.m));
    var months = (ref.y - dob.y) * 12 + (ref.m - dob.m);
    if ref.d < clamped_birthday { months -= 1; }
    return months;
}

// Today's date. Goose's only clock is UTC, so this is the UTC date, not the
// local one the other implementations use.
fn today() -> Date {
    var days = (time() / 86400.0) as i64;
    var year = 1970;
    loop {
        let year_days = if days_in_month(year, 2) == 29 { 366 } else { 365 };
        if days < year_days { break; }
        days -= year_days;
        year += 1;
    }
    var month = 1;
    while days >= days_in_month(year, month) {
        days -= days_in_month(year, month);
        month += 1;
    }
    return Date { year, month, days + 1 };
}

// Days and months elapsed from dob to as_of (today when empty); false when either date is
// invalid, as_of precedes dob, or the age exceeds MAX_AGE_MONTHS.
fn elapsed(dob: u8[:], as_of: u8[:]) -> i64, i64, bool {
    let dob_date, ok_dob = parse_date(dob);
    guard ok_dob else { return 0, 0, false; }
    var ref_date = today();
    var ok_ref = true;
    if as_of.len > 0 { ref_date, ok_ref = parse_date(as_of); }
    guard ok_ref else { return 0, 0, false; }
    let diff_days = julian_day(ref_date) - julian_day(dob_date);
    guard diff_days >= 0 else { return 0, 0, false; }
    let months = months_between(dob_date, ref_date);
    guard months <= MAX_AGE_MONTHS else { return 0, 0, false; }
    return diff_days, months, true;
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

// Append `count` in the unit's plural form. A "{n}"-style half marker
// decorates the number ("3½"); a "{0}"-style one wraps the whole unit
// ("3 ans et demi").
fn append_unit(out: u8[>..]&, count: i64, uf: const UnitForms&, rule: PluralRule, half: u8[:]) {
    let base_n = str(count);
    var n_str: u8[>..] = [];
    if half.len > 0 && find(half, "{n}") >= 0 {
        append_replacing_first(n_str, half, "{n}", base_n);
    } else {
        n_str.append(base_n);
    }

    let tmpl = resolve_forms(uf, plural_category(rule, count));
    var unit: u8[>..] = [];
    append_replacing_first(unit, tmpl, "{n}", n_str);

    if half.len > 0 && find(half, "{0}") >= 0 {
        append_replacing_first(out, half, "{0}", unit);
    } else {
        out.append(unit);
    }
}

// ---- Public API ----

fn format_age(locale: const Locale&, compactness: Compactness, dob: u8[:], as_of: u8[:]) -> u8[>..], bool {
    let diff_days, months, ok = elapsed(dob, as_of);
    guard ok else { return [], false; }

    var day_uf = locale.units.day;
    var week_uf = locale.units.week;
    var month_uf = locale.units.month;
    var year_uf = locale.units.year;
    var half = locale.half;
    var delimiter = locale.delimiter;
    var just_born = locale.just_born;

    if compactness != Compactness.Normal {
        let o = if compactness == Compactness.Short { locale.short_override } else { locale.compact_override };
        if o.has_day { day_uf = o.day; }
        if o.has_week { week_uf = o.week; }
        if o.has_month { month_uf = o.month; }
        if o.has_year { year_uf = o.year; }
        if o.has_half { half = o.half; }
        if o.has_delimiter { delimiter = o.delimiter; }
        if o.has_just_born { just_born = o.just_born; }
    }

    let rule = locale.plural;
    var out: u8[>..] = [];

    if diff_days == 0 {
        out.append(just_born);
    } else if diff_days < 7 {
        append_unit(out, diff_days, day_uf, rule, "");
    } else if months < 3 {
        append_unit(out, diff_days / 7, week_uf, rule, "");
        let days = diff_days % 7;
        if days > 0 {
            out.append(delimiter);
            append_unit(out, days, day_uf, rule, "");
        }
    } else if months < 24 {
        append_unit(out, months, month_uf, rule, "");
    } else if months < 36 {
        append_unit(out, months / 12, year_uf, rule, "");
        let rem_months = months % 12;
        if rem_months > 0 {
            out.append(delimiter);
            append_unit(out, rem_months, month_uf, rule, "");
        }
    } else if months < 84 {
        let past_half = months % 12 >= 6;
        append_unit(out, months / 12, year_uf, rule, if past_half { half } else { "" });
    } else {
        append_unit(out, months / 12, year_uf, rule, "");
    }
    return out, true;
}

// `gender` selects the feminine form when it starts with 'f' and the
// stage has one; pass "" for no gender.
fn format_stage(locale: const Locale&, dob: u8[:], as_of: u8[:], gender: u8[:]) -> const u8[:], bool {
    let diff_days, months, ok = elapsed(dob, as_of);
    guard ok else { return "", false; }

    let label = if months < 2 { locale.stages.newborn }
        else if months < 12 { locale.stages.infant }
        else if months < 36 { locale.stages.toddler }
        else if months < 156 { locale.stages.child }
        else if months < 216 { locale.stages.teenager }
        else { locale.stages.adult };

    if gender.len > 0 && gender[0] == 'f' && label.f.len > 0 { return label.f, true; }
    return label.label, true;
}
