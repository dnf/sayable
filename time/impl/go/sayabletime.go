package sayabletime

import "strings"

// Version is the library version.
const Version = "0.5.0"

// SayableTime is a locale-aware clock time formatter.
type SayableTime struct {
	locale      *TimeLocale
	compactness Compactness
	shortClock  *ShortClockConfig
}

// NewSayableTime creates a new SayableTime instance with the given locale and optional compactness.
func NewSayableTime(locale TimeLocale, compactness ...Compactness) *SayableTime {
	c := Normal
	if len(compactness) > 0 {
		c = compactness[0]
	}

	st := &SayableTime{
		locale:      &locale,
		compactness: c,
	}

	var ovr *CompactnessOverride
	switch c {
	case Short:
		ovr = locale.Short
	case Compact:
		ovr = locale.Compact
	}

	if ovr != nil {
		st.shortClock = ovr.Clock
	}

	return st
}

// FormatTime formats a time as a natural language clock reading.
// input should be "HH:MM" or an ISO datetime string.
// Returns nil for invalid input.
func (st *SayableTime) FormatTime(input string) *string {
	if input == "" {
		return nil
	}
	parsed := parseTime(input)
	if parsed == nil {
		return nil
	}
	hour, minute := parsed[0], parsed[1]

	if st.compactness != Normal && st.shortClock != nil {
		s := st.formatDigital(hour, minute)
		return &s
	}
	s := st.formatNatural(hour, minute)
	return &s
}

// formatNatural produces a natural language clock reading (e.g. "a quarter past two").
func (st *SayableTime) formatNatural(hour, minute int) string {
	clock := st.locale.Clock
	rounded := roundTo5(minute)
	h := hour
	if rounded == 60 {
		rounded = 0
		h = (h + 1) % 24
	}
	if rounded == 0 {
		if h == 0 {
			return clock.Midnight
		}
		if h == 12 {
			return clock.Noon
		}
	}
	h12 := h % 12
	nextH12 := (h + 1) % 12
	hName := clock.Hours[h12]
	nextHName := clock.Hours[nextH12]
	pattern, ok := clock.Patterns[rounded]
	if !ok {
		pattern = clock.Patterns[0]
	}
	result := strings.Replace(pattern, "{h}", hName, 1)
	result = strings.Replace(result, "{next_h}", nextHName, 1)
	return result
}

// formatDigital produces a digital clock reading (e.g. "2:15 PM").
func (st *SayableTime) formatDigital(hour, minute int) string {
	sc := st.shortClock
	fmt := sc.Format
	if sc.Use24h {
		return strings.Replace(
			strings.Replace(fmt, "{h}", itoa(hour), 1),
			"{mm}", zeroPad(minute), 1,
		)
	}
	h12 := hour % 12
	if h12 == 0 {
		h12 = 12
	}
	amPm := sc.AmPm
	var am, pm string
	if amPm != nil {
		am = amPm[0]
		pm = amPm[1]
	} else {
		am = "AM"
		pm = "PM"
	}
	var ampmStr string
	if hour < 12 {
		ampmStr = am
	} else {
		ampmStr = pm
	}
	result := strings.Replace(fmt, "{h}", itoa(h12), 1)
	result = strings.Replace(result, "{mm}", zeroPad(minute), 1)
	result = strings.Replace(result, "{ampm}", ampmStr, 1)
	return result
}

// parseTime parses "HH:MM" or an ISO datetime string into [hour, minute].
// Returns nil on failure.
func parseTime(input string) *[2]int {
	if input == "" {
		return nil
	}
	t := input
	if strings.Contains(t, "T") {
		parts := strings.SplitN(t, "T", 2)
		t = parts[1]
	}
	if idx := strings.Index(t, "+"); idx >= 0 {
		t = t[:idx]
	}
	if idx := strings.Index(t, "Z"); idx >= 0 {
		t = t[:idx]
	}
	colonParts := strings.Split(t, ":")
	if len(colonParts) < 2 {
		return nil
	}
	hourStr := colonParts[0]
	minuteStr := colonParts[1]
	// Strip fractional seconds from minute part (e.g. "15.123")
	if dotIdx := strings.Index(minuteStr, "."); dotIdx >= 0 {
		minuteStr = minuteStr[:dotIdx]
	}
	hour := parseInt(hourStr)
	minute := parseInt(minuteStr)
	if hour < 0 || minute < 0 {
		return nil
	}
	if hour > 23 || minute > 59 {
		return nil
	}
	return &[2]int{hour, minute}
}

// roundTo5 rounds a minute value to the nearest 5.
func roundTo5(minute int) int {
	return ((minute + 2) / 5) * 5
}

// parseInt parses a non-negative integer from a string. Returns -1 on failure.
func parseInt(s string) int {
	if len(s) == 0 {
		return -1
	}
	n := 0
	for _, c := range s {
		if c < '0' || c > '9' {
			return -1
		}
		n = n*10 + int(c-'0')
	}
	return n
}

// itoa converts a non-negative integer to its decimal string representation.
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	digits := make([]byte, 0, 4)
	for n > 0 {
		digits = append(digits, byte('0'+n%10))
		n /= 10
	}
	for i, j := 0, len(digits)-1; i < j; i, j = i+1, j-1 {
		digits[i], digits[j] = digits[j], digits[i]
	}
	return string(digits)
}

// zeroPad returns a two-digit zero-padded string.
func zeroPad(n int) string {
	if n < 10 {
		return "0" + itoa(n)
	}
	return itoa(n)
}

// defaultST is a module-level default formatter using the English locale.
// It is initialized lazily to avoid import cycles with the locales package.
var defaultST *SayableTime

// SetDefault sets the module-level default SayableTime instance.
// Called from the locales package init or manually.
func SetDefault(st *SayableTime) {
	defaultST = st
}

// FormatTime formats clock time using the default English locale.
// Returns nil if no default has been set or for invalid input.
func FormatTime(input string) *string {
	if defaultST == nil {
		return nil
	}
	return defaultST.FormatTime(input)
}
