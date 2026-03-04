//! # sayable-age
//!
//! Human-friendly age formatting the way parents actually talk.
//!
//! This library formats a child's age from their date of birth, producing
//! natural-language strings like "3 weeks, 2 days", "6 months", "2 years, 1 month",
//! or "3½ years" — matching how parents actually describe their child's age.
//!
//! ## Quick Start
//!
//! ```rust
//! use sayable_age::{format_age, format_stage};
//!
//! // Using the default English locale
//! assert_eq!(format_age("2025-06-15", Some("2025-06-15")), Some("Newborn".to_string()));
//! assert_eq!(format_age("2025-06-12", Some("2025-06-15")), Some("3 days".to_string()));
//! assert_eq!(format_stage("2020-01-01", Some("2025-06-15"), None), Some("Child".to_string()));
//! ```
//!
//! ## Custom Locale
//!
//! ```rust
//! use sayable_age::{SayableAge, Compactness, locales};
//!
//! let pt = SayableAge::new(&locales::JA, Compactness::Normal);
//! assert_eq!(pt.format_age("2022-06-15", Some("2025-12-15")), Some("3歳半".to_string()));
//! ```

/// Core formatting logic.
pub mod formatter;
/// Built-in locale definitions.
pub mod locales;
/// Type definitions for locales, compactness, and plural categories.
pub mod types;

// Re-export the main public API
pub use formatter::{format_age, format_stage, SayableAge, VERSION, _set_now_for_testing};
pub use types::{AgeLocale, Compactness, CompactnessOverride, Gender, PluralCategory, StageLabel, Stages, UnitForms, Units};
