use crate::types::{Compactness, ShortClockConfig, TimeLocale};

/// Library version.
pub const VERSION: &str = "0.1.0";

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

/// Parses "HH:MM" or an ISO datetime string into (hour, minute).
/// Returns `None` on failure.
fn parse_time(input: &str) -> Option<(i32, i32)> {
    if input.is_empty() {
        return None;
    }

    let mut t = input;

    // Strip date portion from ISO datetime
    if let Some(pos) = t.find('T') {
        t = &t[pos + 1..];
    }

    // Strip timezone offset
    if let Some(pos) = t.find('+') {
        t = &t[..pos];
    }
    if let Some(pos) = t.find('Z') {
        t = &t[..pos];
    }

    let parts: Vec<&str> = t.split(':').collect();
    if parts.len() < 2 {
        return None;
    }

    let hour_str = parts[0];
    let mut minute_str = parts[1];

    // Strip fractional seconds from minute part (e.g., "15.123")
    if let Some(dot_pos) = minute_str.find('.') {
        minute_str = &minute_str[..dot_pos];
    }

    let hour = parse_int(hour_str)?;
    let minute = parse_int(minute_str)?;

    if hour > 23 || minute > 59 {
        return None;
    }

    Some((hour, minute))
}

/// Rounds a minute value to the nearest 5.
fn round_to_5(minute: i32) -> i32 {
    ((minute + 2) / 5) * 5
}

/// Parses a non-negative integer from a string. Returns `None` on failure.
fn parse_int(s: &str) -> Option<i32> {
    if s.is_empty() {
        return None;
    }
    let mut n: i32 = 0;
    for c in s.chars() {
        if !c.is_ascii_digit() {
            return None;
        }
        n = n * 10 + (c as i32 - '0' as i32);
    }
    Some(n)
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
