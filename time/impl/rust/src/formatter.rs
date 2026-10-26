use crate::types::{Compactness, ShortClockConfig, TimeLocale};

/// Library version.
pub const VERSION: &str = "0.5.0";

/// Locale-aware clock time formatter.
#[derive(Debug, Clone)]
pub struct SayableTime<'a> {
    locale: &'a TimeLocale,
    compactness: Compactness,
    short_clock: Option<&'a ShortClockConfig>,
}

impl<'a> SayableTime<'a> {
    /// Creates a new `SayableTime` instance with the given locale and compactness.
    pub fn new(locale: &'a TimeLocale, compactness: Compactness) -> Self {
        let ovr = match compactness {
            Compactness::Short => locale.short.as_ref(),
            Compactness::Compact => locale.compact.as_ref(),
            Compactness::Normal => None,
        };

        let short_clock = ovr.and_then(|o| o.clock.as_ref());

        SayableTime {
            locale,
            compactness,
            short_clock,
        }
    }

    /// Formats a time as a natural language clock reading.
    ///
    /// `input` should be "HH:MM" or an ISO datetime string (e.g., "2025-01-15T14:15:00").
    /// Returns `None` for invalid input.
    pub fn format_time(&self, input: &str) -> Option<String> {
        if input.is_empty() {
            return None;
        }
        let (hour, minute) = parse_time(input)?;

        if self.compactness != Compactness::Normal {
            if let Some(sc) = self.short_clock {
                return Some(format_digital(hour, minute, sc));
            }
        }
        Some(self.format_natural(hour, minute))
    }

    /// Produces a natural language clock reading (e.g., "a quarter past two").
    fn format_natural(&self, hour: i32, minute: i32) -> String {
        let clock = &self.locale.clock;
        let mut rounded = round_to_5(minute);
        let mut h = hour;

        if rounded == 60 {
            rounded = 0;
            h = (h + 1) % 24;
        }

        if rounded == 0 {
            if h == 0 {
                return clock.midnight.clone();
            }
            if h == 12 {
                return clock.noon.clone();
            }
        }

        let h12 = h % 12;
        let next_h12 = (h + 1) % 12;
        let h_name = &clock.hours[h12 as usize];
        let next_h_name = &clock.hours[next_h12 as usize];

        let pattern = clock
            .patterns
            .get(&rounded)
            .or_else(|| clock.patterns.get(&0))
            .cloned()
            .unwrap_or_default();

        pattern
            .replace("{h}", h_name)
            .replace("{next_h}", next_h_name)
    }
}

/// Produces a digital clock reading (e.g., "2:15 PM").
fn format_digital(hour: i32, minute: i32, sc: &ShortClockConfig) -> String {
    let fmt = &sc.format;

    if sc.use24h {
        return fmt
            .replace("{h}", &hour.to_string())
            .replace("{mm}", &zero_pad(minute));
    }

    let mut h12 = hour % 12;
    if h12 == 0 {
        h12 = 12;
    }

    let (am, pm) = match &sc.am_pm {
        Some((a, p)) => (a.as_str(), p.as_str()),
        None => ("AM", "PM"),
    };

    let ampm = if hour < 12 { am } else { pm };

    fmt.replace("{h}", &h12.to_string())
        .replace("{mm}", &zero_pad(minute))
        .replace("{ampm}", ampm)
}

/// Parses a clock time, alone or after the "T" of an ISO datetime, into
/// (hour, minute). Returns `None` for anything that doesn't follow
/// docs/input-formats.md.
fn parse_time(input: &str) -> Option<(i32, i32)> {
    let bytes = input.as_bytes();
    let clock = match bytes.iter().position(|&c| c == b'T') {
        Some(t) => {
            if !is_real_date(&bytes[..t]) {
                return None;
            }
            &bytes[t + 1..]
        }
        None => bytes,
    };
    parse_clock(clock)
}

/// True for exactly "YYYY-MM-DD" naming a real Gregorian calendar day.
fn is_real_date(date: &[u8]) -> bool {
    if date.len() != 10 || date[4] != b'-' || date[7] != b'-' {
        return false;
    }
    match (digits(&date[0..4]), digits(&date[5..7]), digits(&date[8..10])) {
        (Some(year), Some(month), Some(day)) => {
            (1..=12).contains(&month) && day >= 1 && day <= days_in_month(year, month)
        }
        _ => false,
    }
}

fn days_in_month(year: i32, month: i32) -> i32 {
    match month {
        2 if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 => 29,
        2 => 28,
        4 | 6 | 9 | 11 => 30,
        _ => 31,
    }
}

/// Parses "H:MM" or "HH:MM", then optional ":SS", optional "." plus digits
/// (only after seconds), and an optional zone suffix "Z" or "±HH:MM", which
/// is validated but ignored.
fn parse_clock(clock: &[u8]) -> Option<(i32, i32)> {
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
    Some((hour, minute))
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

/// Rounds a minute value to the nearest 5.
fn round_to_5(minute: i32) -> i32 {
    ((minute + 2) / 5) * 5
}

/// Returns a two-digit zero-padded string.
fn zero_pad(n: i32) -> String {
    if n < 10 {
        format!("0{n}")
    } else {
        n.to_string()
    }
}

/// Formats clock time using the default English locale (normal compactness).
/// Returns `None` for invalid input.
pub fn format_time(input: &str) -> Option<String> {
    let st = SayableTime::new(&crate::locales::EN, Compactness::Normal);
    st.format_time(input)
}
