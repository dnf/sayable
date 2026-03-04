// Package sayabledate provides human-friendly date formatting.
package sayabledate

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
	Months              *[12]string
	MonthsInDate        *[12]string
	Weekdays            *[7]string
	DayFormat           *string
	DayFormatExceptions map[string]string
	DatePattern         *string
	DatePatternWithYear *string
	Today               *string
	Tomorrow            *string
	Yesterday           *string
}

// DateLocale defines all locale-specific data for date formatting.
type DateLocale struct {
	Code                string
	Months              [12]string
	Weekdays            [7]string
	DayFormat           string
	DayFormatExceptions map[string]string
	DatePattern         string
	DatePatternWithYear string
	Today               string
	Tomorrow            string
	Yesterday           string
	DayAfterTomorrow    *string
	DayBeforeYesterday  *string
	ThisWeekday         *string
	NextWeekday         *string
	LastWeekday         *string
	MonthsInDate        *[12]string
	Short               *CompactnessOverride
	Compact             *CompactnessOverride
}
