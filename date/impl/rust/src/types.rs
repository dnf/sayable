use std::collections::HashMap;

/// Controls the verbosity of formatted output.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Compactness {
    /// Full output (e.g., "March 15th").
    Normal,
    /// Abbreviated output (e.g., "Mar 15").
    Short,
    /// Minimal output (e.g., "3/15").
    Compact,
}

/// Optional overrides for short/compact display modes.
/// `None` fields mean "use the base locale value."
#[derive(Debug, Clone)]
pub struct CompactnessOverride {
    /// Month names override.
    pub months: Option<[String; 12]>,
    /// Month names used in date patterns (e.g., genitive forms) override.
    pub months_in_date: Option<[String; 12]>,
    /// Weekday names override.
    pub weekdays: Option<[String; 7]>,
    /// Day format override (e.g., "{n}" instead of "{n}th").
    pub day_format: Option<String>,
    /// Day format exceptions override.
    pub day_format_exceptions: Option<HashMap<String, String>>,
    /// Date pattern override (e.g., "{month} {day}").
    pub date_pattern: Option<String>,
    /// Date pattern with year override (e.g., "{month} {day}, {year}").
    pub date_pattern_with_year: Option<String>,
    /// "Today" override.
    pub today: Option<String>,
    /// "Tomorrow" override.
    pub tomorrow: Option<String>,
    /// "Yesterday" override.
    pub yesterday: Option<String>,
}

/// All locale-specific data for date formatting.
#[derive(Clone)]
pub struct DateLocale {
    /// BCP 47 language code (e.g., "en", "ja").
    pub code: String,
    /// Month names (January=0 through December=11).
    pub months: [String; 12],
    /// Weekday names (Sunday=0 through Saturday=6).
    pub weekdays: [String; 7],
    /// Day format template (e.g., "{n}th").
    pub day_format: String,
    /// Day format exceptions by day number string (e.g., "1" -> "{n}st").
    pub day_format_exceptions: HashMap<String, String>,
    /// Date pattern without year (e.g., "{month} {day}").
    pub date_pattern: String,
    /// Date pattern with year (e.g., "{month} {day}, {year}").
    pub date_pattern_with_year: String,
    /// "Today" label.
    pub today: String,
    /// "Tomorrow" label.
    pub tomorrow: String,
    /// "Yesterday" label.
    pub yesterday: String,
    /// "Day after tomorrow" label (optional).
    pub day_after_tomorrow: Option<String>,
    /// "Day before yesterday" label (optional).
    pub day_before_yesterday: Option<String>,
    /// "This {weekday}" pattern (optional).
    pub this_weekday: Option<String>,
    /// "Next {weekday}" pattern (optional).
    pub next_weekday: Option<String>,
    /// "Last {weekday}" pattern (optional).
    pub last_weekday: Option<String>,
    /// Alternative month names for use in date patterns (e.g., genitive forms in Russian).
    pub months_in_date: Option<[String; 12]>,
    /// Overrides applied in `Short` compactness mode.
    pub short: Option<CompactnessOverride>,
    /// Overrides applied in `Compact` compactness mode.
    pub compact: Option<CompactnessOverride>,
}

impl std::fmt::Debug for DateLocale {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DateLocale")
            .field("code", &self.code)
            .finish()
    }
}
