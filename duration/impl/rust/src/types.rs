use std::collections::HashMap;

/// CLDR-inspired plural categories.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum PluralCategory {
    /// Exact zero (e.g., Arabic "0 items").
    Zero,
    /// Singular (e.g., English "1 day").
    One,
    /// Dual (e.g., Arabic "2 items").
    Two,
    /// Small plural (e.g., Polish 2-4).
    Few,
    /// Large plural (e.g., Polish 5-21).
    Many,
    /// Default / all other counts.
    Other,
}

/// Unit display template(s).
/// Use `simple()` for languages with no plural forms, `plural()` for plural-aware forms.
#[derive(Debug, Clone)]
pub enum UnitForms {
    /// A single template for all counts (e.g., Japanese, Chinese).
    Simple(String),
    /// Per-category templates. Must include at least `Other`.
    Plural(HashMap<PluralCategory, String>),
}

impl UnitForms {
    /// Creates a `UnitForms` with a single template for all counts.
    pub fn simple(s: &str) -> Self {
        UnitForms::Simple(s.to_string())
    }

    /// Creates a `UnitForms` with per-category templates.
    pub fn plural(forms: &[(PluralCategory, &str)]) -> Self {
        let map: HashMap<PluralCategory, String> = forms
            .iter()
            .map(|(cat, s)| (*cat, (*s).to_string()))
            .collect();
        UnitForms::Plural(map)
    }
}

/// Controls the verbosity of formatted output.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Compactness {
    /// Full output (e.g., "3 hours, 15 minutes").
    Normal,
    /// Abbreviated units (e.g., "3h, 15m").
    Short,
    /// Minimal output (e.g., "3h15m").
    Compact,
}

/// Unit forms for all seven time units.
#[derive(Debug, Clone)]
pub struct Units {
    /// Second unit templates.
    pub second: UnitForms,
    /// Minute unit templates.
    pub minute: UnitForms,
    /// Hour unit templates.
    pub hour: UnitForms,
    /// Day unit templates.
    pub day: UnitForms,
    /// Week unit templates.
    pub week: UnitForms,
    /// Month unit templates.
    pub month: UnitForms,
    /// Year unit templates.
    pub year: UnitForms,
}

/// Optional overrides for short/compact display modes.
/// `None` fields mean "use the base locale value."
#[derive(Debug, Clone)]
pub struct CompactnessOverride {
    /// Second unit override.
    pub second: Option<UnitForms>,
    /// Minute unit override.
    pub minute: Option<UnitForms>,
    /// Hour unit override.
    pub hour: Option<UnitForms>,
    /// Day unit override.
    pub day: Option<UnitForms>,
    /// Week unit override.
    pub week: Option<UnitForms>,
    /// Month unit override.
    pub month: Option<UnitForms>,
    /// Year unit override.
    pub year: Option<UnitForms>,
    /// Half marker override (e.g., "½").
    pub half: Option<String>,
    /// Delimiter override (e.g., ", ").
    pub delimiter: Option<String>,
    /// Ago template override (e.g., "{0} ago").
    pub ago: Option<String>,
    /// Future template override (e.g., "in {0}").
    pub in_future: Option<String>,
}

/// All locale-specific data for duration formatting.
#[derive(Clone)]
pub struct DurationLocale {
    /// BCP 47 language code (e.g., "en", "ja").
    pub code: String,
    /// CLDR plural-category selector for a given count.
    pub plural: fn(i32) -> PluralCategory,
    /// Unit display templates for second/minute/hour/day/week/month/year.
    pub units: Units,
    /// Half marker template (e.g., "{n}½", "{0}半").
    pub half: String,
    /// Delimiter between components (e.g., ", ").
    pub delimiter: String,
    /// Label for zero-second duration (e.g., "just now").
    pub just_now: String,
    /// Ago template (e.g., "{0} ago").
    pub ago: String,
    /// Future template (e.g., "in {0}").
    pub in_future: String,
    /// Overrides applied in `Short` compactness mode.
    pub short: Option<CompactnessOverride>,
    /// Overrides applied in `Compact` compactness mode.
    pub compact: Option<CompactnessOverride>,
    /// Optional custom number formatter (e.g., for Arabic numerals).
    pub format_number: Option<fn(i32) -> String>,
    /// Optional post-processor for resolved unit strings.
    pub format_unit: Option<fn(i32, &str) -> String>,
}

impl std::fmt::Debug for DurationLocale {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("DurationLocale")
            .field("code", &self.code)
            .finish()
    }
}

/// Formats a count with the given unit forms, locale, and optional half marker.
///
/// The half template supports two placeholder styles:
/// - `{n}` modifies the formatted number before unit substitution (e.g. "1½ hours")
/// - `{0}` wraps the fully resolved expression after unit substitution (e.g. "1時間半")
///
/// When a half marker is applied, the plural category is forced to Other
/// (e.g. "1½ hours" not "1½ hour").
pub fn resolve_unit(count: i32, uf: &UnitForms, locale: &DurationLocale, half: &str) -> String {
    let base_n = if let Some(fmt_fn) = locale.format_number {
        fmt_fn(count)
    } else {
        itoa(count)
    };

    // Apply {n}-style half marker to the number
    let n = if !half.is_empty() && half.contains("{n}") {
        half.replace("{n}", &base_n)
    } else {
        base_n
    };

    // Select template
    let template = match uf {
        UnitForms::Simple(s) => s.clone(),
        UnitForms::Plural(forms) => {
            // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
            let cat = if half.is_empty() {
                (locale.plural)(count)
            } else {
                PluralCategory::Other
            };
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

    let mut result = template.replace("{n}", &n);

    if let Some(fmt_fn) = locale.format_unit {
        result = fmt_fn(count, &result);
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if !half.is_empty() && half.contains("{0}") {
        result = half.replace("{0}", &result);
    }

    result
}

/// Converts an i32 to its decimal string representation.
fn itoa(n: i32) -> String {
    if n < 0 {
        return format!("-{}", itoa(-n));
    }
    n.to_string()
}
