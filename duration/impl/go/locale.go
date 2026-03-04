// Package sayableduration provides human-friendly duration and relative time formatting.
package sayableduration

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
	Second    *UnitForms
	Minute    *UnitForms
	Hour      *UnitForms
	Day       *UnitForms
	Week      *UnitForms
	Month     *UnitForms
	Year      *UnitForms
	Half      *string
	Delimiter *string
	Ago       *string
	InFuture  *string
}

// DurationLocale defines all locale-specific data for duration formatting.
type DurationLocale struct {
	Code         string
	Plural       func(n int) PluralCategory
	Units        struct{ Second, Minute, Hour, Day, Week, Month, Year UnitForms }
	Half         string
	Delimiter    string
	JustNow      string
	Ago          string
	InFuture     string
	Short        *CompactnessOverride
	Compact      *CompactnessOverride
	FormatNumber func(n int) string
	FormatUnit   func(count int, label string) string
}

// ResolveUnit formats a count with the given unit forms, locale, and optional half marker.
//
// The half template supports two placeholder styles:
//   - {n} modifies the formatted number before unit substitution (e.g. "1½ hours")
//   - {0} wraps the fully resolved expression after unit substitution (e.g. "1時間半")
//
// When a half marker is applied, the plural category is forced to Other
// (e.g. "1½ hours" not "1½ hour").
func ResolveUnit(count int, uf UnitForms, loc *DurationLocale, half string) string {
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
		// Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
		var cat PluralCategory
		if half != "" {
			cat = Other
		} else {
			cat = loc.Plural(count)
		}
		if t, ok := uf.Forms[cat]; ok {
			template = t
		} else {
			template = uf.Forms[Other]
		}
	}

	result := strings.Replace(template, "{n}", n, 1)

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
