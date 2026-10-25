use crate::types::{Compactness, DurationLocale, UnitForms, resolve_unit};

/// Durations over 6000 months (500 years) have no value: the same ceiling as sayable-age.
const MAX_DURATION_MONTHS: i64 = 6000;

/// Library version, matching duration/config/version.json.
pub const VERSION: &str = "0.5.0";

/// Locale-aware duration and relative time formatter.
#[derive(Debug, Clone)]
pub struct SayableDuration {
    locale: DurationLocale,
    second: UnitForms,
    minute: UnitForms,
    hour: UnitForms,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
    half: String,
    delimiter: String,
    just_now: String,
    ago: String,
    in_future: String,
}

impl SayableDuration {
    /// Creates a new `SayableDuration` instance with the given locale and compactness.
    pub fn new(locale: &DurationLocale, compactness: Compactness) -> Self {
        let mut sd = SayableDuration {
            locale: locale.clone(),
            second: locale.units.second.clone(),
            minute: locale.units.minute.clone(),
            hour: locale.units.hour.clone(),
            day: locale.units.day.clone(),
            week: locale.units.week.clone(),
            month: locale.units.month.clone(),
            year: locale.units.year.clone(),
            half: locale.half.clone(),
            delimiter: locale.delimiter.clone(),
            just_now: locale.just_now.clone(),
            ago: locale.ago.clone(),
            in_future: locale.in_future.clone(),
        };

        let ovr = match compactness {
            Compactness::Short => locale.short.as_ref(),
            Compactness::Compact => locale.compact.as_ref(),
            Compactness::Normal => None,
        };

        if let Some(ovr) = ovr {
            if let Some(s) = &ovr.second {
                sd.second.clone_from(s);
            }
            if let Some(m) = &ovr.minute {
                sd.minute.clone_from(m);
            }
            if let Some(h) = &ovr.hour {
                sd.hour.clone_from(h);
            }
            if let Some(d) = &ovr.day {
                sd.day.clone_from(d);
            }
            if let Some(w) = &ovr.week {
                sd.week.clone_from(w);
            }
            if let Some(m) = &ovr.month {
                sd.month.clone_from(m);
            }
            if let Some(y) = &ovr.year {
                sd.year.clone_from(y);
            }
            if let Some(h) = &ovr.half {
                sd.half.clone_from(h);
            }
            if let Some(d) = &ovr.delimiter {
                sd.delimiter.clone_from(d);
            }
            if let Some(a) = &ovr.ago {
                sd.ago.clone_from(a);
            }
            if let Some(f) = &ovr.in_future {
                sd.in_future.clone_from(f);
            }
        }

        sd
    }

    /// Formats a number of seconds as a human-friendly duration string.
    /// Returns `None` for negative values and for durations over 500 years.
    pub fn format_duration_seconds(&self, seconds: i64) -> Option<String> {
        if seconds < 0 {
            return None;
        }
        self.format_seconds_inner(seconds)
    }

    /// Formats the duration between two ISO datetime strings.
    /// Returns `None` if either string is empty or cannot be parsed, or the
    /// duration is over 500 years.
    pub fn format_duration_iso(&self, start: &str, end: &str) -> Option<String> {
        if start.is_empty() || end.is_empty() {
            return None;
        }
        let s = parse_iso_to_seconds(start)?;
        let e = parse_iso_to_seconds(end)?;
        self.format_seconds_inner((e - s).abs())
    }

    /// Formats elapsed time as "X ago".
    /// Returns `None` if start or as_of are empty, unparseable, or if as_of is before start.
    pub fn format_since(&self, start: &str, as_of: &str) -> Option<String> {
        if start.is_empty() || as_of.is_empty() {
            return None;
        }
        let s = parse_iso_to_seconds(start)?;
        let a = parse_iso_to_seconds(as_of)?;
        let diff = a - s;
        if diff < 0 {
            return None;
        }
        if diff == 0 {
            return Some(self.just_now.clone());
        }
        let dur = self.format_seconds_inner(diff)?;
        Some(self.ago.replace("{0}", &dur))
    }

    /// Formats time until a future event as "in X".
    /// Returns `None` if target or as_of are empty, unparseable, or if target is before as_of.
    pub fn format_until(&self, target: &str, as_of: &str) -> Option<String> {
        if target.is_empty() || as_of.is_empty() {
            return None;
        }
        let t = parse_iso_to_seconds(target)?;
        let a = parse_iso_to_seconds(as_of)?;
        let diff = t - a;
        if diff < 0 {
            return None;
        }
        if diff == 0 {
            return Some(self.just_now.clone());
        }
        let dur = self.format_seconds_inner(diff)?;
        Some(self.in_future.replace("{0}", &dur))
    }

    /// Applies duration tiers to total seconds; `None` beyond the 500-year ceiling.
    fn format_seconds_inner(&self, total: i64) -> Option<String> {
        let loc = &self.locale;

        // 0 seconds
        if total == 0 {
            return Some(self.just_now.clone());
        }

        // 1-59 seconds
        if total < 60 {
            return Some(resolve_count(total, &self.second, loc, ""));
        }

        let total_minutes = total / 60;
        let remainder_seconds = total % 60;

        // 1-4 minutes: minutes + seconds
        if total_minutes < 5 {
            let mut result = resolve_count(total_minutes, &self.minute, loc, "");
            if remainder_seconds > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_count(remainder_seconds, &self.second, loc, ""));
            }
            return Some(result);
        }

        // 5-59 minutes
        if total_minutes < 60 {
            return Some(resolve_count(total_minutes, &self.minute, loc, ""));
        }

        let total_hours = total / 3600;
        let remainder_minutes = (total % 3600) / 60;

        // 1-5 hours: hours + minutes (with half marker)
        if total_hours <= 5 {
            if remainder_minutes == 30 {
                return Some(resolve_count(total_hours, &self.hour, loc, &self.half));
            }
            let mut result = resolve_count(total_hours, &self.hour, loc, "");
            if remainder_minutes > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_count(remainder_minutes, &self.minute, loc, ""));
            }
            return Some(result);
        }

        // 6-23 hours
        if total_hours < 24 {
            return Some(resolve_count(total_hours, &self.hour, loc, ""));
        }

        let total_days = total / 86400;
        let remainder_hours = (total % 86400) / 3600;

        // 1-2 days: days + hours (with half marker)
        if total_days <= 2 {
            if remainder_hours == 12 {
                return Some(resolve_count(total_days, &self.day, loc, &self.half));
            }
            let mut result = resolve_count(total_days, &self.day, loc, "");
            if remainder_hours > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_count(remainder_hours, &self.hour, loc, ""));
            }
            return Some(result);
        }

        // 3-6 days
        if total_days < 7 {
            return Some(resolve_count(total_days, &self.day, loc, ""));
        }

        let total_weeks = total_days / 7;
        let remainder_days = total_days % 7;

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if total_days < 30 {
            let mut result = resolve_count(total_weeks, &self.week, loc, "");
            if remainder_days > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_count(remainder_days, &self.day, loc, ""));
            }
            return Some(result);
        }

        // Approximate months (30.44 days average)
        let mut total_months = round_div(total_days);
        if total_months > MAX_DURATION_MONTHS {
            return None;
        }

        // 1-11 months
        if total_months < 12 {
            if total_months == 0 {
                total_months = 1;
            }
            return Some(resolve_count(total_months, &self.month, loc, ""));
        }

        // 12+ months: years + months
        let total_years = total_months / 12;
        let remainder_months = total_months % 12;
        let mut result = resolve_count(total_years, &self.year, loc, "");
        if remainder_months > 0 {
            result.push_str(&self.delimiter);
            result.push_str(&resolve_count(remainder_months, &self.month, loc, ""));
        }
        Some(result)
    }
}

/// Approximates months from days using 30.44 average days per month,
/// matching Python's round(total_days / 30.44).
#[allow(clippy::cast_possible_truncation, clippy::cast_precision_loss)] // days < 2^53, months fit i64
fn round_div(total_days: i64) -> i64 {
    (total_days as f64 / 30.44 + 0.5) as i64
}

/// Resolves a unit for a count that the tiers keep small (at most 6000 months).
fn resolve_count(count: i64, uf: &UnitForms, loc: &DurationLocale, half: &str) -> String {
    resolve_unit(i32::try_from(count).unwrap_or(i32::MAX), uf, loc, half)
}

/// Parses a timestamp (docs/input-formats.md) to epoch-relative seconds for
/// diffing: "YYYY-MM-DDTHH:MM", optional ":SS", optional "." plus digits after
/// the seconds, and an optional zone suffix "Z" or "±HH:MM", which is ignored.
fn parse_iso_to_seconds(iso: &str) -> Option<i64> {
    let bytes = iso.as_bytes();
    if bytes.len() < 11 || bytes[4] != b'-' || bytes[7] != b'-' || bytes[10] != b'T' {
        return None;
    }
    let year = digits(&bytes[0..4])?;
    let month = digits(&bytes[5..7])?;
    let day = digits(&bytes[8..10])?;
    if !(1..=12).contains(&month) || day < 1 || day > days_in_month(year, month) {
        return None;
    }
    let (hour, minute, second) = parse_clock(&bytes[11..])?;
    let days = i64::from(days_since_epoch(year, month, day));
    Some(days * 86400 + i64::from(hour * 3600 + minute * 60 + second))
}

/// Parses "H:MM" or "HH:MM", optional ":SS" and fraction, and an optional
/// zone suffix into (hour, minute, second).
fn parse_clock(clock: &[u8]) -> Option<(i32, i32, i32)> {
    let hour_len = clock.iter().take_while(|c| c.is_ascii_digit()).count();
    if !(1..=2).contains(&hour_len) || clock.get(hour_len) != Some(&b':') {
        return None;
    }
    let hour = digits(&clock[..hour_len])?;
    let minute = digits(clock.get(hour_len + 1..hour_len + 3)?)?;
    let mut rest = &clock[hour_len + 3..];
    let mut second = 0;
    if rest.first() == Some(&b':') {
        second = digits(rest.get(1..3)?)?;
        rest = &rest[3..];
        if rest.first() == Some(&b'.') {
            let fraction_len = rest[1..].iter().take_while(|c| c.is_ascii_digit()).count();
            if fraction_len == 0 {
                return None;
            }
            rest = &rest[1 + fraction_len..];
        }
    }
    if !is_zone_suffix(rest) || hour > 23 || minute > 59 || second > 59 {
        return None;
    }
    Some((hour, minute, second))
}

/// True for nothing at all, "Z", or "+HH:MM" / "-HH:MM".
fn is_zone_suffix(zone: &[u8]) -> bool {
    match zone {
        [] | [b'Z'] => true,
        [b'+' | b'-', h1, h2, b':', m1, m2] => [h1, h2, m1, m2].iter().all(|c| c.is_ascii_digit()),
        _ => false,
    }
}

/// Converts a non-empty run of ASCII digits to an i32; `None` if any byte isn't a digit.
fn digits(run: &[u8]) -> Option<i32> {
    if run.is_empty() {
        return None;
    }
    run.iter().try_fold(0, |n, &c| c.is_ascii_digit().then(|| n * 10 + i32::from(c - b'0')))
}

/// Returns true if the given year is a leap year.
fn is_leap_year(year: i32) -> bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

/// Returns the number of days in a given month of a given year.
fn days_in_month(year: i32, month: i32) -> i32 {
    match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => {
            if is_leap_year(year) {
                29
            } else {
                28
            }
        }
        _ => 30,
    }
}

/// Calculates days since a reference epoch (2000-01-01).
fn days_since_epoch(year: i32, month: i32, day: i32) -> i32 {
    let mut days = 0;
    if year >= 2000 {
        for y in 2000..year {
            days += if is_leap_year(y) { 366 } else { 365 };
        }
    } else {
        for y in year..2000 {
            days -= if is_leap_year(y) { 366 } else { 365 };
        }
    }
    for m in 1..month {
        days += days_in_month(year, m);
    }
    days += day - 1;
    days
}
