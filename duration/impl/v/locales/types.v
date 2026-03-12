module locales

// Version of the sayable-duration library.
pub const version = '0.5.0'

// PluralCategory represents CLDR-inspired plural categories.
pub enum PluralCategory {
	zero
	one
	two
	few
	many
	other
}

// Compactness controls the verbosity of formatted output.
pub enum Compactness {
	normal
	short
	compact
}

// UnitForms holds a unit's display template(s).
pub struct UnitForms {
pub:
	simple string
	forms  map[PluralCategory]string
}

// simple_unit creates a UnitForms with a single template for all counts.
pub fn simple_unit(s string) UnitForms {
	return UnitForms{
		simple: s
	}
}

// plural_unit creates a UnitForms with per-category templates.
pub fn plural_unit(forms map[PluralCategory]string) UnitForms {
	return UnitForms{
		forms: forms
	}
}

// DurationCompactnessOverride holds optional overrides for short/compact display modes.
pub struct DurationCompactnessOverride {
pub:
	second       UnitForms
	minute       UnitForms
	hour         UnitForms
	day          UnitForms
	week         UnitForms
	month        UnitForms
	year         UnitForms
	half         string
	delimiter    string
	ago          string
	in_future    string
	has_second   bool
	has_minute   bool
	has_hour     bool
	has_day      bool
	has_week     bool
	has_month    bool
	has_year     bool
	has_half     bool
	has_delimiter bool
	has_ago      bool
	has_in_future bool
}

// DurationLocale defines all locale-specific data for duration formatting.
@[heap]
pub struct DurationLocale {
pub:
	code             string
	plural           fn (int) PluralCategory = unsafe { nil }
	second           UnitForms
	minute           UnitForms
	hour             UnitForms
	day              UnitForms
	week             UnitForms
	month            UnitForms
	year             UnitForms
	half             string
	delimiter        string
	just_now         string
	ago              string
	in_future        string
	short_override   DurationCompactnessOverride
	compact_override DurationCompactnessOverride
	has_short        bool
	has_compact      bool
}
