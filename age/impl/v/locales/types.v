module locales

// Version of the sayable-age library.
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

// StageLabel represents a stage label that may be gender-neutral or gendered.
pub struct StageLabel {
pub:
	label string
	m     string
	f     string
}

// stage_neutral creates a gender-neutral StageLabel.
pub fn stage_neutral(s string) StageLabel {
	return StageLabel{
		label: s
	}
}

// stage_gendered creates a gendered StageLabel with masculine and feminine forms.
pub fn stage_gendered(m_form string, f_form string) StageLabel {
	return StageLabel{
		m: m_form
		f: f_form
	}
}

// resolve_stage returns the appropriate string for the given gender.
pub fn resolve_stage(sl StageLabel, gender string) string {
	if sl.m == '' {
		return sl.label
	}
	if gender == 'f' {
		return sl.f
	}
	return sl.m
}

// CompactnessOverride holds optional overrides for short/compact display modes.
// has_* fields indicate which overrides are active.
pub struct CompactnessOverride {
pub:
	day           UnitForms
	week          UnitForms
	month         UnitForms
	year          UnitForms
	half          string
	delimiter     string
	just_born     string
	has_day       bool
	has_week      bool
	has_month     bool
	has_year      bool
	has_half      bool
	has_delimiter bool
	has_just_born bool
}

// AgeLocale defines all locale-specific data for age formatting.
@[heap]
pub struct AgeLocale {
pub:
	code             string
	plural           fn (int) PluralCategory = unsafe { nil }
	day              UnitForms
	week             UnitForms
	month            UnitForms
	year             UnitForms
	half             string
	delimiter        string
	just_born        string
	newborn          StageLabel
	infant           StageLabel
	toddler          StageLabel
	child            StageLabel
	teenager         StageLabel
	adult            StageLabel
	short_override   CompactnessOverride
	compact_override CompactnessOverride
	has_short        bool
	has_compact      bool
}
