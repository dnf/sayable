use std::collections::HashMap;

use crate::types::{Compactness, DateLocale};

/// Library version.
pub const VERSION: &str = "0.5.0";

/// Locale-aware date formatter.
#[derive(Debug, Clone)]
pub struct SayableDate {
    locale: DateLocale,
    compactness: Compactness,
    months: [String; 12],
    months_in_date: Option<[String; 12]>,
    weekdays: [String; 7],
    day_format: String,
    day_format_exceptions: HashMap<String, String>,
    date_pattern: String,
    date_pattern_with_year: String,
    today: String,
    tomorrow: String,
    yesterday: String,
}

impl SayableDate {
    /// Creates a new `SayableDate` instance with the given locale and compactness.
    pub fn new(locale: &DateLocale, compactness: Compactness) -> Self {
        let ovr = match compactness {
            Compactness::Short => locale.short.as_ref(),
            Compactness::Compact => locale.compact.as_ref(),
            Compactness::Normal => None,
        };

        let months = pick_clone(ovr.and_then(|o| o.months.as_ref()), &locale.months);
        let months_in_date = ovr
            .and_then(|o| o.months_in_date.as_ref())
            .cloned()
            .or_else(|| locale.months_in_date.clone());
        let weekdays = pick_clone(ovr.and_then(|o| o.weekdays.as_ref()), &locale.weekdays);
        let day_format = pick_string(ovr.and_then(|o| o.day_format.as_ref()), &locale.day_format);

        // When DayFormat is overridden but DayFormatExceptions is not,
        // clear exceptions (the override replaces the format entirely).
        let day_format_exceptions = if ovr.is_some()
            && ovr.unwrap().day_format.is_some()
            && ovr.unwrap().day_format_exceptions.is_none()
        {
            HashMap::new()
        } else {
            pick_clone(
                ovr.and_then(|o| o.day_format_exceptions.as_ref()),
                &locale.day_format_exceptions,
            )
        };

        let date_pattern = pick_string(
            ovr.and_then(|o| o.date_pattern.as_ref()),
            &locale.date_pattern,
        );
        let date_pattern_with_year = pick_string(
            ovr.and_then(|o| o.date_pattern_with_year.as_ref()),
            &locale.date_pattern_with_year,
        );
        let today = pick_string(ovr.and_then(|o| o.today.as_ref()), &locale.today);
        let tomorrow = pick_string(ovr.and_then(|o| o.tomorrow.as_ref()), &locale.tomorrow);
        let yesterday = pick_string(ovr.and_then(|o| o.yesterday.as_ref()), &locale.yesterday);

        SayableDate {
            locale: locale.clone(),
            compactness,
            months,
            months_in_date,
            weekdays,
            day_format,
            day_format_exceptions,
            date_pattern,
            date_pattern_with_year,
            today,
            tomorrow,
            yesterday,
        }
    }

    /// Format a calendar date in locale-appropriate form (no year).
    /// Returns `None` if the input is empty or unparseable.
    pub fn format_date(&self, date: &str) -> Option<String> {
        if date.is_empty() {
            return None;
        }
        let (y, m, d) = parse_date(date)?;
        Some(self.format_absolute(y, m, d, false))
    }

    /// Format a calendar date with year in locale-appropriate form.
    /// Returns `None` if the input is empty or unparseable.
    pub fn format_date_with_year(&self, date: &str) -> Option<String> {
        if date.is_empty() {
            return None;
        }
        let (y, m, d) = parse_date(date)?;
        Some(self.format_absolute(y, m, d, true))
    }

    /// Format a date relative to `as_of`, picking the most natural reference.
    /// Falls back to absolute date for distant dates.
    /// Returns `None` if either input is empty or unparseable.
    pub fn format_relative(&self, date: &str, as_of: &str) -> Option<String> {
        if date.is_empty() || as_of.is_empty() {
            return None;
        }
        let (dy, dm, dd) = parse_date(date)?;
        let (ay, am, ad) = parse_date(as_of)?;

        let date_jdn = to_jdn(dy, dm, dd);
        let asof_jdn = to_jdn(ay, am, ad);
        let diff = date_jdn - asof_jdn;

        // Today
        if diff == 0 {
            return Some(self.today.clone());
        }

        // Tomorrow
        if diff == 1 {
            return Some(self.tomorrow.clone());
        }

        // Yesterday
        if diff == -1 {
            return Some(self.yesterday.clone());
        }

        let loc = &self.locale;
        let is_compact = self.compactness == Compactness::Compact;

        // Day after tomorrow (optional, skipped in compact mode)
        if diff == 2 && !is_compact {
            if let Some(ref s) = loc.day_after_tomorrow {
                return Some(s.clone());
            }
        }

        // Day before yesterday (optional, skipped in compact mode)
        if diff == -2 && !is_compact {
            if let Some(ref s) = loc.day_before_yesterday {
                return Some(s.clone());
            }
        }

        // Compact mode: skip weekday references, go straight to calendar date
        if is_compact {
            let include_year = dy != ay;
            return Some(self.format_absolute(dy, dm, dd, include_year));
        }

        // This weekday (+2 to +6)
        if (2..=6).contains(&diff) {
            if let Some(ref pattern) = loc.this_weekday {
                let dow = weekday(dy, dm, dd);
                let weekday_name = &self.weekdays[dow as usize];
                return Some(pattern.replace("{weekday}", weekday_name));
            }
        }

        // Last weekday (-6 to -2)
        if (-6..=-2).contains(&diff) {
            if let Some(ref pattern) = loc.last_weekday {
                let dow = weekday(dy, dm, dd);
                let weekday_name = &self.weekdays[dow as usize];
                return Some(pattern.replace("{weekday}", weekday_name));
            }
        }

        // Next weekday (+7 to +13)
        if (7..=13).contains(&diff) {
            if let Some(ref pattern) = loc.next_weekday {
                let dow = weekday(dy, dm, dd);
                let weekday_name = &self.weekdays[dow as usize];
                return Some(pattern.replace("{weekday}", weekday_name));
            }
        }

        // Calendar fallback
        let include_year = dy != ay;
        Some(self.format_absolute(dy, dm, dd, include_year))
    }

    /// Format a date as an absolute calendar reference.
    fn format_absolute(&self, year: i32, month: i32, day: i32, include_year: bool) -> String {
        // Format the day with ordinal
        let day_str = day.to_string();
        let fmt = self
            .day_format_exceptions
            .get(&day_str)
            .unwrap_or(&self.day_format);
        let formatted_day = fmt.replace("{n}", &day_str);

        // Pick month name (genitive form if available)
        let month_name = if let Some(ref mid) = self.months_in_date {
            &mid[(month - 1) as usize]
        } else {
            &self.months[(month - 1) as usize]
        };

        let pattern = if include_year {
            &self.date_pattern_with_year
        } else {
            &self.date_pattern
        };

        let mut result = pattern.replace("{month}", month_name);
        result = result.replace("{day}", &formatted_day);
        result = result.replace("{d}", &day.to_string());
        result = result.replace("{m}", &month.to_string());
        if include_year {
            result = result.replace("{year}", &year.to_string());
            let yy = year % 100;
            let yy_str = format!("{yy:02}");
            result = result.replace("{yy}", &yy_str);
        }

        result
    }
}

/// Parse "YYYY-MM-DD", optionally followed by "T" and anything else, into
/// (year, month, day). The date must name a real calendar day; returns None
/// otherwise (see docs/input-formats.md).
fn parse_date(s: &str) -> Option<(i32, i32, i32)> {
    let bytes = s.as_bytes();
    let is_date_alone = bytes.len() == 10;
    let is_datetime = bytes.len() > 10 && bytes[10] == b'T';
    if !(is_date_alone || is_datetime) || bytes[4] != b'-' || bytes[7] != b'-' {
        return None;
    }
    let year = parse_digits(&bytes[0..4])?;
    let month = parse_digits(&bytes[5..7])?;
    let day = parse_digits(&bytes[8..10])?;
    if !(1..=12).contains(&month) || day < 1 || day > days_in_month(year, month) {
        return None;
    }
    Some((year, month, day))
}

/// Convert a run of ASCII digits to an i32; None if any byte isn't a digit.
fn parse_digits(digits: &[u8]) -> Option<i32> {
    digits.iter().try_fold(0, |n, &c| {
        c.is_ascii_digit().then(|| n * 10 + i32::from(c - b'0'))
    })
}

/// Days in a month of the Gregorian calendar (leap years by the 4/100/400 rule).
fn days_in_month(year: i32, month: i32) -> i32 {
    match month {
        2 if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 => 29,
        2 => 28,
        4 | 6 | 9 | 11 => 30,
        _ => 31,
    }
}

/// Convert a date to Julian Day Number for day-difference arithmetic.
fn to_jdn(year: i32, month: i32, day: i32) -> i32 {
    let a = (14 - month) / 12;
    let y = year + 4800 - a;
    let m = month + 12 * a - 3;
    day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

/// Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.
fn weekday(year: i32, month: i32, day: i32) -> i32 {
    let jdn = to_jdn(year, month, day);
    (jdn + 1) % 7
}

/// Pick override value if set, else clone the default.
fn pick_clone<T: Clone>(ovr: Option<&T>, default: &T) -> T {
    ovr.cloned().unwrap_or_else(|| default.clone())
}

/// Pick override string if set, else clone the default.
fn pick_string(ovr: Option<&String>, default: &str) -> String {
    ovr.cloned().unwrap_or_else(|| default.to_string())
}

/// Format a date using the default English locale (normal compactness).
pub fn format_date(date: &str) -> Option<String> {
    let sd = SayableDate::new(&crate::locales::EN, Compactness::Normal);
    sd.format_date(date)
}

/// Format a relative date using the default English locale (normal compactness).
pub fn format_relative(date: &str, as_of: &str) -> Option<String> {
    let sd = SayableDate::new(&crate::locales::EN, Compactness::Normal);
    sd.format_relative(date, as_of)
}
