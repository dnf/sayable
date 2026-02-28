use crate::types::{AgeLocale, Compactness, PluralCategory, UnitForms};

/// Parsed age components.
struct AgeComponents {
    months: i32,
    diff_days: i32,
}

/// Parses "YYYY-MM-DD" into (year, month, day). Returns None on failure.
fn parse_date_parts(s: &str) -> Option<(i32, i32, i32)> {
    let bytes = s.as_bytes();
    if bytes.len() < 10 || bytes[4] != b'-' || bytes[7] != b'-' {
        return None;
    }
    let y = atoi(&s[0..4]);
    let m = atoi(&s[5..7]);
    let d = atoi(&s[8..10]);
    if y == 0 && m == 0 && d == 0 {
        return None;
    }
    Some((y, m, d))
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
fn is_leap_year(y: i32) -> bool {
    (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
}

/// Returns the number of days in a given month of a given year.
fn days_in_month(y: i32, m: i32) -> i32 {
    match m {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 => {
            if is_leap_year(y) {
                29
            } else {
                28
            }
        }
        _ => 30,
    }
}

/// Computes total elapsed days between two dates using a Julian Day Number approach.
/// This avoids needing the `time` crate.
fn days_between(y1: i32, m1: i32, d1: i32, y2: i32, m2: i32, d2: i32) -> i32 {
    fn to_jdn(y: i32, m: i32, d: i32) -> i32 {
        let a = (14 - m) / 12;
        let yy = y + 4800 - a;
        let mm = m + 12 * a - 3;
        d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32045
    }
    to_jdn(y2, m2, d2) - to_jdn(y1, m1, d1)
}

/// Returns today's date as (year, month, day) using `SystemTime`.
fn today() -> (i32, i32, i32) {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    // Convert Unix timestamp to date
    let days = (secs / 86400) as i32;
    // Algorithm from http://howardhinnant.github.io/date_algorithms.html
    let z = days + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = if m <= 2 { y + 1 } else { y };
    (y, m, d)
}

/// Parses two date strings into calendar months and elapsed days.
/// Returns None if dob is empty or in the future relative to `as_of`.
fn parse_age(dob: &str, as_of: Option<&str>) -> Option<AgeComponents> {
    if dob.is_empty() {
        return None;
    }

    let (dob_y, dob_m, dob_d) = parse_date_parts(dob)?;

    let (ref_y, ref_m, ref_d) = match as_of {
        Some(s) if !s.is_empty() => parse_date_parts(s)?,
        _ => today(),
    };

    // Total elapsed days
    let diff_days = days_between(dob_y, dob_m, dob_d, ref_y, ref_m, ref_d);
    if diff_days < 0 {
        return None;
    }

    // Calendar months with clamping for short months
    let last_day = days_in_month(ref_y, ref_m);
    let clamped_birthday = if dob_d > last_day { last_day } else { dob_d };
    let mut months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
    if ref_d < clamped_birthday {
        months -= 1;
    }

    Some(AgeComponents { months, diff_days })
}

/// Converts an i32 to its decimal string representation.
fn itoa(n: i32) -> String {
    if n < 0 {
        return format!("-{}", itoa(-n));
    }
    n.to_string()
}

/// Formats a count with the given unit forms, locale, and optional half marker.
fn resolve_unit(count: i32, uf: &UnitForms, loc: &AgeLocale, half: &str) -> String {
    // Formatted number
    let base_n = if let Some(fmt_fn) = loc.format_number {
        fmt_fn(count)
    } else {
        itoa(count)
    };

    // Apply {n}-style half marker to the number
    let n = if !half.is_empty() && half.contains("{n}") {
        half.replace("{n}", &base_n)
    } else {
        base_n.clone()
    };

    // Select template
    let template = match uf {
        UnitForms::Simple(s) => s.clone(),
        UnitForms::Plural(forms) => {
            let cat = (loc.plural)(count);
            if let Some(t) = forms.get(&cat) {
                t.clone()
            } else {
                forms
                    .get(&PluralCategory::Other)
                    .cloned()
                    .unwrap_or_default()
            }
        }
    };

    // Substitute {n} in template
    let mut result = template.replace("{n}", &n);

    // Apply formatUnit callback
    if let Some(fmt_fn) = loc.format_unit {
        result = fmt_fn(count, &result);
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if !half.is_empty() && half.contains("{0}") {
        result = half.replace("{0}", &result);
    }

    result
}

/// Returns the developmental stage key for the given calendar months.
fn stage_key(months: i32) -> &'static str {
    match months {
        m if m < 2 => "newborn",
        m if m < 12 => "infant",
        m if m < 36 => "toddler",
        m if m < 156 => "child",
        m if m < 216 => "teenager",
        _ => "adult",
    }
}

/// Locale-aware age formatter.
#[derive(Debug, Clone)]
pub struct ParentTime {
    locale: AgeLocale,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
    half: String,
    delimiter: String,
    just_born: String,
}

impl ParentTime {
    /// Creates a new `ParentTime` instance with the given locale and optional compactness.
    pub fn new(locale: &AgeLocale, compactness: Compactness) -> Self {
        let mut pt = ParentTime {
            locale: locale.clone(),
            day: locale.units.day.clone(),
            week: locale.units.week.clone(),
            month: locale.units.month.clone(),
            year: locale.units.year.clone(),
            half: locale.half.clone(),
            delimiter: locale.delimiter.clone(),
            just_born: locale.just_born.clone(),
        };

        let ovr = match compactness {
            Compactness::Short => locale.short.as_ref(),
            Compactness::Compact => locale.compact.as_ref(),
            Compactness::Normal => None,
        };

        if let Some(ovr) = ovr {
            if let Some(d) = &ovr.day {
                pt.day.clone_from(d);
            }
            if let Some(w) = &ovr.week {
                pt.week.clone_from(w);
            }
            if let Some(m) = &ovr.month {
                pt.month.clone_from(m);
            }
            if let Some(y) = &ovr.year {
                pt.year.clone_from(y);
            }
            if let Some(h) = &ovr.half {
                pt.half.clone_from(h);
            }
            if let Some(d) = &ovr.delimiter {
                pt.delimiter.clone_from(d);
            }
            if let Some(j) = &ovr.just_born {
                pt.just_born.clone_from(j);
            }
        }

        pt
    }

    /// Returns a human-friendly age string.
    /// `dob` and `as_of` must be in YYYY-MM-DD format.
    /// Returns `None` if `dob` is empty or in the future.
    pub fn format_age(&self, dob: &str, as_of: Option<&str>) -> Option<String> {
        let age = parse_age(dob, as_of)?;
        let months = age.months;
        let diff_days = age.diff_days;

        // Tier 1: 0 days
        if diff_days == 0 {
            return Some(self.just_born.clone());
        }

        // Tier 1b: 1-6 days
        if diff_days < 7 {
            return Some(resolve_unit(diff_days, &self.day, &self.locale, ""));
        }

        // Tier 2: weeks + days until 3 calendar months
        if months < 3 {
            let weeks = diff_days / 7;
            let days = diff_days % 7;
            let mut result = resolve_unit(weeks, &self.week, &self.locale, "");
            if days > 0 {
                result.push_str(&self.delimiter);
                result.push_str(&resolve_unit(days, &self.day, &self.locale, ""));
            }
            return Some(result);
        }

        // Tier 3: 3-23 months
        if months < 24 {
            return Some(resolve_unit(months, &self.month, &self.locale, ""));
        }

        // Tier 4: 24-35 months -> years + months
        if months < 36 {
            let years = months / 12;
            let rem = months % 12;
            if rem == 0 {
                return Some(resolve_unit(years, &self.year, &self.locale, ""));
            }
            let mut s = resolve_unit(years, &self.year, &self.locale, "");
            s.push_str(&self.delimiter);
            s.push_str(&resolve_unit(rem, &self.month, &self.locale, ""));
            return Some(s);
        }

        // Tier 5: 3-6 years -> years with half marker
        if months < 84 {
            let years = months / 12;
            let rem = months % 12;
            if rem >= 6 {
                return Some(resolve_unit(years, &self.year, &self.locale, &self.half));
            }
            return Some(resolve_unit(years, &self.year, &self.locale, ""));
        }

        // Tier 6: 7+ years
        let years = months / 12;
        Some(resolve_unit(years, &self.year, &self.locale, ""))
    }

    /// Returns the developmental stage label based on age.
    /// Returns `None` if `dob` is empty or in the future.
    pub fn format_stage(&self, dob: &str, as_of: Option<&str>) -> Option<String> {
        let age = parse_age(dob, as_of)?;
        let key = stage_key(age.months);
        let s = match key {
            "newborn" => &self.locale.stages.newborn,
            "infant" => &self.locale.stages.infant,
            "toddler" => &self.locale.stages.toddler,
            "child" => &self.locale.stages.child,
            "teenager" => &self.locale.stages.teenager,
            "adult" => &self.locale.stages.adult,
            _ => return None,
        };
        Some(s.clone())
    }
}

/// Formats an age using the default English locale (normal compactness).
pub fn format_age(dob: &str, as_of: Option<&str>) -> Option<String> {
    let pt = ParentTime::new(&crate::locales::EN, Compactness::Normal);
    pt.format_age(dob, as_of)
}

/// Returns the developmental stage using the default English locale.
pub fn format_stage(dob: &str, as_of: Option<&str>) -> Option<String> {
    let pt = ParentTime::new(&crate::locales::EN, Compactness::Normal);
    pt.format_stage(dob, as_of)
}
