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
    /// Small plural (e.g., Polish 2–4).
    Few,
    /// Large plural (e.g., Polish 5–21).
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
    /// Full output (e.g., "3 weeks, 2 days").
    Normal,
    /// Abbreviated units (e.g., "3 wks, 2 days").
    Short,
    /// Minimal output (e.g., "3w2d").
    Compact,
}

/// Optional overrides for short/compact display modes.
/// `None` fields mean "use the base locale value."
#[derive(Debug, Clone)]
pub struct CompactnessOverride {
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
    /// "Just born" label override (e.g., "Newborn").
    pub just_born: Option<String>,
}

/// Grammatical gender for stage labels.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Gender {
    /// Masculine.
    M,
    /// Feminine.
    F,
}

/// A stage label: either gender-neutral or a gendered pair.
#[derive(Debug, Clone)]
pub enum StageLabel {
    /// A single label used regardless of gender.
    Neutral(String),
    /// A pair of labels: masculine and feminine.
    Gendered {
        /// Masculine form.
        m: String,
        /// Feminine form.
        f: String,
    },
}

impl StageLabel {
    /// Resolve to a string given an optional gender.
    pub fn resolve(&self, gender: Option<Gender>) -> &str {
        match self {
            StageLabel::Neutral(s) => s,
            StageLabel::Gendered { m, f } => {
                if gender == Some(Gender::F) {
                    f
                } else {
                    m
                }
            }
        }
    }
}

/// Stage labels for developmental stages.
#[derive(Debug, Clone)]
pub struct Stages {
    /// Label for age 0–1 months.
    pub newborn: StageLabel,
    /// Label for age 2–11 months.
    pub infant: StageLabel,
    /// Label for age 12–35 months.
    pub toddler: StageLabel,
    /// Label for age 36–155 months (3–12 years).
    pub child: StageLabel,
    /// Label for age 156–215 months (13–17 years).
    pub teenager: StageLabel,
    /// Label for age 216+ months (18+ years).
    pub adult: StageLabel,
}

/// Unit forms for all four time units.
#[derive(Debug, Clone)]
pub struct Units {
    /// Day unit templates.
    pub day: UnitForms,
    /// Week unit templates.
    pub week: UnitForms,
    /// Month unit templates.
    pub month: UnitForms,
    /// Year unit templates.
    pub year: UnitForms,
}

/// All locale-specific data for age formatting.
#[derive(Clone)]
pub struct AgeLocale {
    /// BCP 47 language code (e.g., "en", "ja").
    pub code: String,
    /// CLDR plural-category selector for a given count.
    pub plural: fn(i32) -> PluralCategory,
    /// Unit display templates for day/week/month/year.
    pub units: Units,
    /// Half marker template (e.g., "½", "半").
    pub half: String,
    /// Delimiter between components (e.g., ", ").
    pub delimiter: String,
    /// Label for zero-day age (e.g., "Newborn").
    pub just_born: String,
    /// Developmental stage labels.
    pub stages: Stages,
    /// Overrides applied in `Short` compactness mode.
    pub short: Option<CompactnessOverride>,
    /// Overrides applied in `Compact` compactness mode.
    pub compact: Option<CompactnessOverride>,
    /// Optional custom number formatter (e.g., for Arabic numerals).
    pub format_number: Option<fn(i32) -> String>,
    /// Optional post-processor for resolved unit strings.
    pub format_unit: Option<fn(i32, &str) -> String>,
}

impl std::fmt::Debug for AgeLocale {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AgeLocale")
            .field("code", &self.code)
            .finish()
    }
}
