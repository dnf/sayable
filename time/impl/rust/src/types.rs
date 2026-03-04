use std::collections::HashMap;

/// Controls the verbosity of formatted output.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Compactness {
    /// Full natural-language output (e.g., "a quarter past two").
    Normal,
    /// Abbreviated digital format (e.g., "2:15 PM").
    Short,
    /// Minimal digital format (e.g., "2:15p").
    Compact,
}

/// Natural language clock reading configuration.
#[derive(Debug, Clone)]
pub struct ClockConfig {
    /// Hour names: index 0 = "twelve", 1 = "one", ..., 11 = "eleven".
    pub hours: [String; 12],
    /// Word for midnight (e.g., "midnight").
    pub midnight: String,
    /// Word for noon (e.g., "noon").
    pub noon: String,
    /// Minute-rounded patterns keyed by minute value (0, 5, 10, ..., 55).
    /// Patterns may contain `{h}` and `{next_h}` placeholders.
    pub patterns: HashMap<i32, String>,
}

/// Digital clock display configuration for short/compact modes.
#[derive(Debug, Clone)]
pub struct ShortClockConfig {
    /// Whether to use 24-hour format.
    pub use24h: bool,
    /// Optional AM/PM labels as (am, pm) pair.
    pub am_pm: Option<(String, String)>,
    /// Format template with `{h}`, `{mm}`, and optional `{ampm}` placeholders.
    pub format: String,
}

/// Optional overrides for short/compact display modes.
#[derive(Debug, Clone)]
pub struct CompactnessOverride {
    /// Clock display override.
    pub clock: Option<ShortClockConfig>,
}

/// All locale-specific data for clock time formatting.
#[derive(Debug, Clone)]
pub struct TimeLocale {
    /// BCP 47 language code (e.g., "en", "ja").
    pub code: String,
    /// Natural language clock configuration.
    pub clock: ClockConfig,
    /// Overrides applied in `Short` compactness mode.
    pub short: Option<CompactnessOverride>,
    /// Overrides applied in `Compact` compactness mode.
    pub compact: Option<CompactnessOverride>,
}
