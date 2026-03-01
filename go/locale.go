// Package parenttime provides human-friendly age formatting the way parents actually talk.
package parenttime

import "strings"

// PluralCategory represents CLDR-inspired plural categories.
type PluralCategory int

const (
	Zero PluralCategory = iota
	One
	Two
	Few
	Many
	Other
)

// UnitForms holds a unit's display template(s).
// Use SimpleUnit for languages with no plural forms, PluralUnit for plural-aware forms.
type UnitForms struct {
	Simple string
	Forms  map[PluralCategory]string
}

// SimpleUnit creates a UnitForms with a single template for all counts.
func SimpleUnit(s string) UnitForms {
	return UnitForms{Simple: s}
}

// PluralUnit creates a UnitForms with per-category templates.
// The map must include at least the Other key.
func PluralUnit(forms map[PluralCategory]string) UnitForms {
	return UnitForms{Forms: forms}
}

// Compactness controls the verbosity of formatted output.
type Compactness int

const (
	Normal Compactness = iota
	Short
	Compact
)

// CompactnessOverride holds optional overrides for short/compact display modes.
// Nil fields mean "use the base locale value."
type CompactnessOverride struct {
	Day       *UnitForms
	Week      *UnitForms
	Month     *UnitForms
	Year      *UnitForms
	Half      *string
	Delimiter *string
	JustBorn  *string
}

// AgeLocale defines all locale-specific data for age formatting.
type AgeLocale struct {
	Code         string
	Plural       func(n int) PluralCategory
	Units        struct{ Day, Week, Month, Year UnitForms }
	Half         string
	Delimiter    string
	JustBorn     string
	Stages       struct{ Newborn, Infant, Toddler, Child, Teenager, Adult StageLabel }
	Short        *CompactnessOverride
	Compact      *CompactnessOverride
	FormatNumber func(n int) string
	FormatUnit   func(count int, label string) string
}

// StageLabel represents a stage label that may be gender-neutral or gendered.
type StageLabel struct {
	Label string // gender-neutral form (used directly if M is empty)
	M     string // masculine form
	F     string // feminine form
}

// ResolveStage returns the appropriate string for the given gender.
func ResolveStage(sl StageLabel, gender string) string {
	if sl.M == "" {
		return sl.Label
	}
	if gender == "f" {
		return sl.F
	}
	return sl.M
}

// S creates a gender-neutral StageLabel from a plain string.
func S(s string) StageLabel {
	return StageLabel{Label: s}
}

// G creates a gendered StageLabel with masculine and feminine forms.
func G(m, f string) StageLabel {
	return StageLabel{M: m, F: f}
}

// strPtr returns a pointer to the given string.
func strPtr(s string) *string { return &s }

// resolveUnit formats a count with the given unit forms, locale, and optional half marker.
func resolveUnit(count int, uf UnitForms, loc *AgeLocale, half string) string {
	// Formatted number
	baseN := ""
	if loc.FormatNumber != nil {
		baseN = loc.FormatNumber(count)
	} else {
		baseN = itoa(count)
	}

	// Apply {n}-style half marker to the number
	n := baseN
	if half != "" && strings.Contains(half, "{n}") {
		n = strings.Replace(half, "{n}", baseN, 1)
	}

	// Select template
	var template string
	if uf.Simple != "" {
		template = uf.Simple
	} else {
		cat := loc.Plural(count)
		if t, ok := uf.Forms[cat]; ok {
			template = t
		} else {
			template = uf.Forms[Other]
		}
	}

	// Substitute {n} in template
	result := strings.Replace(template, "{n}", n, 1)

	// Apply formatUnit callback
	if loc.FormatUnit != nil {
		result = loc.FormatUnit(count, result)
	}

	// Apply {0}-style half marker (wraps the whole expression)
	if half != "" && strings.Contains(half, "{0}") {
		result = strings.Replace(half, "{0}", result, 1)
	}

	return result
}

// itoa converts an int to its decimal string representation.
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	if n < 0 {
		return "-" + itoa(-n)
	}
	digits := make([]byte, 0, 10)
	for n > 0 {
		digits = append(digits, byte('0'+n%10))
		n /= 10
	}
	// reverse
	for i, j := 0, len(digits)-1; i < j; i, j = i+1, j-1 {
		digits[i], digits[j] = digits[j], digits[i]
	}
	return string(digits)
}
