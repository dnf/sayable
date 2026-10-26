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

// parseTime parses a clock time, alone or after the "T" of an ISO datetime,
// into [hour, minute]. Returns nil for anything that doesn't follow
// docs/input-formats.md.
func parseTime(input string) *[2]int {
	clock := input
	if idx := strings.IndexByte(input, 'T'); idx >= 0 {
		if !isRealDate(input[:idx]) {
			return nil
		}
		clock = input[idx+1:]
	}
	hour, minute, ok := parseClock(clock)
	if !ok {
		return nil
	}
	return &[2]int{hour, minute}
}

// isRealDate reports whether s is exactly "YYYY-MM-DD" naming a real Gregorian day.
func isRealDate(s string) bool {
	if len(s) != 10 || s[4] != '-' || s[7] != '-' {
		return false
	}
	year, month, day := parseInt(s[0:4]), parseInt(s[5:7]), parseInt(s[8:10])
	return year >= 0 && month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month)
}

// daysInMonth returns the days in a Gregorian month (leap years by the 4/100/400 rule).
func daysInMonth(year, month int) int {
	switch month {
	case 2:
		if (year%4 == 0 && year%100 != 0) || year%400 == 0 {
			return 29
		}
		return 28
	case 4, 6, 9, 11:
		return 30
	default:
		return 31
	}
}

// parseClock parses "H:MM" or "HH:MM", then optional ":SS", an optional "."
// plus digits (only after seconds), and an optional zone suffix "Z" or
// "±HH:MM", which is validated but ignored.
func parseClock(clock string) (hour, minute int, ok bool) {
	hourLen := digitRun(clock)
	if hourLen < 1 || hourLen > 2 || len(clock) < hourLen+3 || clock[hourLen] != ':' {
		return 0, 0, false
	}
	hour = parseInt(clock[:hourLen])
	minute = parseInt(clock[hourLen+1 : hourLen+3])
	rest := clock[hourLen+3:]
	second := 0
	if len(rest) > 0 && rest[0] == ':' {
		if len(rest) < 3 {
			return 0, 0, false
		}
		second = parseInt(rest[1:3])
		rest = rest[3:]
		if len(rest) > 0 && rest[0] == '.' {
			fractionLen := digitRun(rest[1:])
			if fractionLen == 0 {
				return 0, 0, false
			}
			rest = rest[1+fractionLen:]
		}
	}
	if minute < 0 || second < 0 || hour > 23 || minute > 59 || second > 59 || !isZoneSuffix(rest) {
		return 0, 0, false
	}
	return hour, minute, true
}

// digitRun returns the number of leading ASCII digits in s.
func digitRun(s string) int {
	n := 0
	for n < len(s) && s[n] >= '0' && s[n] <= '9' {
		n++
	}
	return n
}

// isZoneSuffix reports whether s is empty, "Z", or "+HH:MM" / "-HH:MM".
func isZoneSuffix(s string) bool {
	if s == "" || s == "Z" {
		return true
	}
	return len(s) == 6 && (s[0] == '+' || s[0] == '-') && s[3] == ':' &&
		digitRun(s[1:3]) == 2 && digitRun(s[4:6]) == 2
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
