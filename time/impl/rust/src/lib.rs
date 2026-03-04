//! # sayable-time
//!
//! Human-friendly clock time formatting the way people actually speak.
//!
//! This library formats clock times as natural-language readings like
//! "a quarter past two", "half past nine", or "midnight" — matching how
//! people actually describe times in conversation.
//!
//! ## Quick Start
//!
//! ```rust
//! use sayable_time::{format_time, SayableTime, Compactness, locales};
//!
//! // Using the default English locale
//! assert_eq!(format_time("14:15"), Some("a quarter past two".to_string()));
//! assert_eq!(format_time("00:00"), Some("midnight".to_string()));
//!
//! // Short compactness
//! let st = SayableTime::new(&locales::EN, Compactness::Short);
//! assert_eq!(st.format_time("14:15"), Some("2:15 PM".to_string()));
//! ```
//!
//! ## Custom Locale
//!
//! ```rust
//! use sayable_time::{SayableTime, Compactness, locales};
//!
//! let st = SayableTime::new(&locales::JA, Compactness::Normal);
//! assert_eq!(st.format_time("15:30"), Some("\u{4e09}\u{6642}\u{534a}".to_string()));
//! ```

/// Core formatting logic.
pub mod formatter;
/// Built-in locale definitions.
pub mod locales;
/// Type definitions for locales, compactness, and clock configuration.
pub mod types;

// Re-export the main public API
pub use formatter::{format_time, SayableTime, VERSION};
pub use types::{ClockConfig, Compactness, CompactnessOverride, ShortClockConfig, TimeLocale};
