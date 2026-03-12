module locales

// Version of the sayable-date library.
pub const version = '0.5.0'

// Compactness controls the verbosity of formatted output.
pub enum Compactness {
	normal
	short
	compact
}

// DateCompactnessOverride holds optional overrides for short/compact display modes.
pub struct DateCompactnessOverride {
pub:
	months                     [12]string
	weekdays                   [7]string
	day_format                 string
	date_pattern               string
	date_pattern_with_year     string
	has_months                 bool
	has_weekdays               bool
	has_day_format             bool
	has_date_pattern           bool
	has_date_pattern_with_year bool
}

// DateLocale defines all locale-specific data for date formatting.
@[heap]
pub struct DateLocale {
pub:
	code                       string
	months                     [12]string
	weekdays                   [7]string
	day_format                 string
	day_format_exceptions      map[string]string
	date_pattern               string
	date_pattern_with_year     string
	today                      string
	tomorrow                   string
	yesterday                  string
	day_after_tomorrow         string
	day_before_yesterday       string
	this_weekday               string
	next_weekday               string
	last_weekday               string
	months_in_date             [12]string
	has_day_after_tomorrow     bool
	has_day_before_yesterday   bool
	has_this_weekday           bool
	has_next_weekday           bool
	has_last_weekday           bool
	has_months_in_date         bool
	short_override             DateCompactnessOverride
	compact_override           DateCompactnessOverride
	has_short                  bool
	has_compact                bool
}
