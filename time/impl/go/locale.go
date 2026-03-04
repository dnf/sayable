// Package sayabletime provides human-friendly clock time formatting.
package sayabletime

// Compactness controls the verbosity of formatted output.
type Compactness int

const (
	Normal Compactness = iota
	Short
	Compact
)

// ClockConfig holds natural language clock reading configuration.
type ClockConfig struct {
	Hours    [12]string
	Midnight string
	Noon     string
	Patterns map[int]string
}

// ShortClockConfig holds digital clock display configuration for short/compact modes.
type ShortClockConfig struct {
	Use24h bool
	AmPm   *[2]string
	Format string
}

// CompactnessOverride holds optional overrides for short/compact display modes.
type CompactnessOverride struct {
	Clock *ShortClockConfig
}

// TimeLocale defines all locale-specific data for clock time formatting.
type TimeLocale struct {
	Code    string
	Clock   ClockConfig
	Short   *CompactnessOverride
	Compact *CompactnessOverride
}
