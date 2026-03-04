//! # sayable-date
//!
//! Human-friendly date formatting with locale awareness.
//!
//! This library formats dates the way humans actually talk about them,
//! with support for relative references ("today", "tomorrow", "next Thursday"),
//! calendar formatting ("March 15th"), and multiple compactness levels.
//!
//! ## Quick Start
//!
//! ```rust
//! use sayable_date::{format_date, format_relative};
//!
//! // Using the default English locale
//! assert_eq!(format_date("2025-03-15"), Some("March 15th".to_string()));
//! assert_eq!(format_relative("2025-03-16", "2025-03-15"), Some("tomorrow".to_string()));
//! ```
//!
//! ## Custom Locale
//!
//! ```rust
//! use sayable_date::{SayableDate, Compactness, locales};
//!
//! let sd = SayableDate::new(&locales::JA, Compactness::Normal);
//! assert_eq!(sd.format_date("2025-03-15"), Some("3\u{6708}15\u{65e5}".to_string()));
//! ```

/// Core formatting logic.
pub mod formatter;
/// Built-in locale definitions.
pub mod locales;
/// Type definitions for locales, compactness, and date structures.
pub mod types;

// Re-export the main public API
pub use formatter::{format_date, format_relative, SayableDate, VERSION};
pub use types::{Compactness, CompactnessOverride, DateLocale};
