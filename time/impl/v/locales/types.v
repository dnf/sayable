module locales

// Version of the sayable-time library.
pub const version = '0.5.0'

// Compactness controls the verbosity of formatted output.
pub enum Compactness {
	normal
	short
	compact
}

// ClockConfig defines natural language clock reading configuration.
pub struct ClockConfig {
pub:
	hours    [12]string
	midnight string
	noon     string
	patterns map[int]string
}

// ShortClockConfig defines digital clock display configuration.
pub struct ShortClockConfig {
pub:
	use24h     bool
	format     string
	am         string
	pm         string
	has_am_pm  bool
}

// TimeCompactnessOverride holds optional overrides for short/compact display modes.
pub struct TimeCompactnessOverride {
pub:
	clock ShortClockConfig
}

// TimeLocale defines all locale-specific data for time formatting.
@[heap]
pub struct TimeLocale {
pub:
	code             string
	clock            ClockConfig
	short_override   TimeCompactnessOverride
	compact_override TimeCompactnessOverride
	has_short        bool
	has_compact      bool
}
