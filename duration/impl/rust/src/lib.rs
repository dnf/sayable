//! # sayable-duration
//!
//! Human-friendly duration and relative time formatting.

/// Duration formatting entry points.
pub mod formatter;
/// Generated locale data, one module per language.
pub mod locales;
/// Locale and unit-form types.
pub mod types;

pub use formatter::{SayableDuration, VERSION};
