use crate::types::{Compactness, DurationLocale, UnitForms, resolve_unit};

/// Library version, matching duration/config/version.json.
pub const VERSION: &str = "0.1.0";

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
    /// Returns `None` for negative values.
    pub fn format_duration_seconds(&self, seconds: i32) -> Option<String> {
        if seconds < 0 {
            return None;
        }
        Some(self.format_seconds_inner(seconds))
    }

    /// Formats the duration between two ISO datetime strings.
    /// Returns `None` if either string is empty or cannot be parsed.
    pub fn format_duration_iso(&self, start: &str, end: &str) -> Option<String> {
        if start.is_empty() || end.is_empty() {
            return None;
        }
        let s = parse_iso_to_seconds(start)?;
        let e = parse_iso_to_seconds(end)?;
        let total = (e - s).unsigned_abs() as i32;
        Some(self.format_seconds_inner(total))
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
        let dur = self.format_seconds_inner(diff);
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
        let dur = self.format_seconds_inner(diff);
        Some(self.in_future.replace("{0}", &dur))
    }

    /// Applies duration tiers to total seconds.
    fn format_seconds_inner(&self, total: i32) -> String {
        let loc = &self.locale;

        // 0 seconds
        if total == 0 {
            return self.just_now.clone();
        }

        // 1-59 seconds
        if total < 60 {
            return resolve_unit(total, &self.second, loc, "");
        }

        let total_minutes = total / 60;
        let remainder_seconds = total % 60;

        // 1-4 minutes: minutes + seconds
        if total_minutes < 5 {
            let mut result = resolve_unit(total_minutes, &self.minute, loc, "");
            if remainder_seconds > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_unit(remainder_seconds, &self.second, loc, ""));
            }
            return result;
        }

        // 5-59 minutes
        if total_minutes < 60 {
            return resolve_unit(total_minutes, &self.minute, loc, "");
        }

        let total_hours = total / 3600;
        let remainder_minutes = (total % 3600) / 60;

        // 1-5 hours: hours + minutes (with half marker)
        if total_hours <= 5 {
            if remainder_minutes == 30 {
                return resolve_unit(total_hours, &self.hour, loc, &self.half);
            }
            let mut result = resolve_unit(total_hours, &self.hour, loc, "");
            if remainder_minutes > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_unit(remainder_minutes, &self.minute, loc, ""));
            }
            return result;
        }

        // 6-23 hours
        if total_hours < 24 {
            return resolve_unit(total_hours, &self.hour, loc, "");
        }

        let total_days = total / 86400;
        let remainder_hours = (total % 86400) / 3600;

        // 1-2 days: days + hours (with half marker)
        if total_days <= 2 {
            if remainder_hours == 12 {
                return resolve_unit(total_days, &self.day, loc, &self.half);
            }
            let mut result = resolve_unit(total_days, &self.day, loc, "");
            if remainder_hours > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_unit(remainder_hours, &self.hour, loc, ""));
            }
            return result;
        }

        // 3-6 days
        if total_days < 7 {
            return resolve_unit(total_days, &self.day, loc, "");
        }

        let total_weeks = total_days / 7;
        let remainder_days = total_days % 7;

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if total_days < 30 {
            let mut result = resolve_unit(total_weeks, &self.week, loc, "");
            if remainder_days > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_unit(remainder_days, &self.day, loc, ""));
            }
            return result;
        }

        // Approximate months (30.44 days average)
        let mut total_months = round_div(total_days);

        // 1-11 months
        if total_months < 12 {
            if total_months == 0 {
                total_months = 1;
            }
            return resolve_unit(total_months, &self.month, loc, "");
        }

        // 12+ months: years + months
        let total_years = total_months / 12;
        let remainder_months = total_months % 12;
        let mut result = resolve_unit(total_years, &self.year, loc, "");
        if remainder_months > 0 {
            result.push_str(&self.delimiter);
            result.push_str(&resolve_unit(remainder_months, &self.month, loc, ""));
        }
        result
    }
}

/// Approximates months from days using 30.44 average days per month,
/// matching Python's round(total_days / 30.44).
fn round_div(total_days: i32) -> i32 {
    (total_days as f64 / 30.44 + 0.5) as i32
}

/// Parses an ISO datetime string to epoch-relative seconds for diffing.
fn parse_iso_to_seconds(iso: &str) -> Option<i32> {
    if iso.is_empty() {
        return None;
    }

    let t_idx = iso.find('T')?;
    let date_part = &iso[..t_idx];
    let time_part = &iso[t_idx + 1..];

    // Parse date: YYYY-MM-DD
    let dp: Vec<&str> = date_part.split('-').collect();
    if dp.len() < 3 {
        return None;
    }
    let year = atoi(dp[0]);
    let month = atoi(dp[1]);
    let day = atoi(dp[2]);

    // Strip timezone info
    let time_str = if let Some(idx) = time_part.find('+') {
        &time_part[..idx]
    } else if let Some(idx) = time_part.find('Z') {
        &time_part[..idx]
    } else {
        time_part
    };

    // Parse time: HH:MM:SS
    let tp: Vec<&str> = time_str.split(':').collect();
    let hour = atoi(tp[0]);
    let minute = if tp.len() > 1 { atoi(tp[1]) } else { 0 };
    let second = if tp.len() > 2 {
        // Strip fractional seconds
        let sec_str = if let Some(dot_idx) = tp[2].find('.') {
            &tp[2][..dot_idx]
        } else {
            tp[2]
        };
        atoi(sec_str)
    } else {
        0
    };

    let days = days_since_epoch(year, month, day);
    Some(days * 86400 + hour * 3600 + minute * 60 + second)
}

/// Converts a string of digits to an i32. Returns 0 on failure.
fn atoi(s: &str) -> i32 {
    let mut n: i32 = 0;
    for c in s.chars() {
        if !c.is_ascii_digit() {
            return 0;
        }
        n = n * 10 + (c as i32 - '0' as i32);
    }
    n
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
