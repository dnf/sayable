package sayableduration

import "strings"

// Version is the library version, matching duration/config/version.json.
const Version = "0.5.0"

// SayableDuration is a locale-aware duration and relative time formatter.
type SayableDuration struct {
	locale    *DurationLocale
	second    UnitForms
	minute    UnitForms
	hour      UnitForms
	day       UnitForms
	week      UnitForms
	month     UnitForms
	year      UnitForms
	half      string
	delimiter string
	justNow   string
	ago       string
	inFuture  string
}

// NewSayableDuration creates a new SayableDuration instance with the given locale
// and optional compactness level.
func NewSayableDuration(locale DurationLocale, compactness ...Compactness) *SayableDuration {
	c := Normal
	if len(compactness) > 0 {
		c = compactness[0]
	}

	sd := &SayableDuration{
		locale:    &locale,
		second:    locale.Units.Second,
		minute:    locale.Units.Minute,
		hour:      locale.Units.Hour,
		day:       locale.Units.Day,
		week:      locale.Units.Week,
		month:     locale.Units.Month,
		year:      locale.Units.Year,
		half:      locale.Half,
		delimiter: locale.Delimiter,
		justNow:   locale.JustNow,
		ago:       locale.Ago,
		inFuture:  locale.InFuture,
	}

	var ovr *CompactnessOverride
	switch c {
	case Short:
		ovr = locale.Short
	case Compact:
		ovr = locale.Compact
	}

	if ovr != nil {
		if ovr.Second != nil {
			sd.second = *ovr.Second
		}
		if ovr.Minute != nil {
			sd.minute = *ovr.Minute
		}
		if ovr.Hour != nil {
			sd.hour = *ovr.Hour
		}
		if ovr.Day != nil {
			sd.day = *ovr.Day
		}
		if ovr.Week != nil {
			sd.week = *ovr.Week
		}
		if ovr.Month != nil {
			sd.month = *ovr.Month
		}
		if ovr.Year != nil {
			sd.year = *ovr.Year
		}
		if ovr.Half != nil {
			sd.half = *ovr.Half
		}
		if ovr.Delimiter != nil {
			sd.delimiter = *ovr.Delimiter
		}
		if ovr.Ago != nil {
			sd.ago = *ovr.Ago
		}
		if ovr.InFuture != nil {
			sd.inFuture = *ovr.InFuture
		}
	}

	return sd
}

// FormatDurationSeconds formats an integer number of seconds as a human-friendly
// duration string. Returns nil for negative values.
func (sd *SayableDuration) FormatDurationSeconds(seconds int) *string {
	if seconds < 0 {
		return nil
	}
	s := sd.formatDurationSeconds(seconds)
	return &s
}

// FormatDurationISO formats the duration between two ISO datetime strings.
// Returns nil if either string is empty or cannot be parsed.
func (sd *SayableDuration) FormatDurationISO(start, end string) *string {
	if start == "" || end == "" {
		return nil
	}
	s := parseISOToSeconds(start)
	e := parseISOToSeconds(end)
	if s == nil || e == nil {
		return nil
	}
	total := *e - *s
	if total < 0 {
		total = -total
	}
	result := sd.formatDurationSeconds(total)
	return &result
}

// FormatSince formats elapsed time as "X ago".
// Returns nil if start or asOf are empty, unparseable, or if asOf is before start.
func (sd *SayableDuration) FormatSince(start, asOf string) *string {
	if start == "" || asOf == "" {
		return nil
	}
	s := parseISOToSeconds(start)
	a := parseISOToSeconds(asOf)
	if s == nil || a == nil {
		return nil
	}
	diff := *a - *s
	if diff < 0 {
		return nil
	}
	if diff == 0 {
		return &sd.justNow
	}
	dur := sd.formatDurationSeconds(diff)
	result := strings.Replace(sd.ago, "{0}", dur, 1)
	return &result
}

// FormatUntil formats time until a future event as "in X".
// Returns nil if target or asOf are empty, unparseable, or if target is before asOf.
func (sd *SayableDuration) FormatUntil(target, asOf string) *string {
	if target == "" || asOf == "" {
		return nil
	}
	t := parseISOToSeconds(target)
	a := parseISOToSeconds(asOf)
	if t == nil || a == nil {
		return nil
	}
	diff := *t - *a
	if diff < 0 {
		return nil
	}
	if diff == 0 {
		return &sd.justNow
	}
	dur := sd.formatDurationSeconds(diff)
	result := strings.Replace(sd.inFuture, "{0}", dur, 1)
	return &result
}

// formatDurationSeconds applies duration tiers to total seconds.
func (sd *SayableDuration) formatDurationSeconds(total int) string {
	loc := sd.locale

	// 0 seconds
	if total == 0 {
		return sd.justNow
	}

	// 1-59 seconds
	if total < 60 {
		return ResolveUnit(total, sd.second, loc, "")
	}

	totalMinutes := total / 60
	remainderSeconds := total % 60

	// 1-4 minutes: minutes + seconds
	if totalMinutes < 5 {
		result := ResolveUnit(totalMinutes, sd.minute, loc, "")
		if remainderSeconds > 0 {
			result += sd.delimiter + ResolveUnit(remainderSeconds, sd.second, loc, "")
		}
		return result
	}

	// 5-59 minutes
	if totalMinutes < 60 {
		return ResolveUnit(totalMinutes, sd.minute, loc, "")
	}

	totalHours := total / 3600
	remainderMinutes := (total % 3600) / 60

	// 1-5 hours: hours + minutes (with half marker)
	if totalHours <= 5 {
		if remainderMinutes == 30 {
			return ResolveUnit(totalHours, sd.hour, loc, sd.half)
		}
		result := ResolveUnit(totalHours, sd.hour, loc, "")
		if remainderMinutes > 0 {
			result += sd.delimiter + ResolveUnit(remainderMinutes, sd.minute, loc, "")
		}
		return result
	}

	// 6-23 hours
	if totalHours < 24 {
		return ResolveUnit(totalHours, sd.hour, loc, "")
	}

	totalDays := total / 86400
	remainderHours := (total % 86400) / 3600

	// 1-2 days: days + hours (with half marker)
	if totalDays <= 2 {
		if remainderHours == 12 {
			return ResolveUnit(totalDays, sd.day, loc, sd.half)
		}
		result := ResolveUnit(totalDays, sd.day, loc, "")
		if remainderHours > 0 {
			result += sd.delimiter + ResolveUnit(remainderHours, sd.hour, loc, "")
		}
		return result
	}

	// 3-6 days
	if totalDays < 7 {
		return ResolveUnit(totalDays, sd.day, loc, "")
	}

	totalWeeks := totalDays / 7
	remainderDays := totalDays % 7

	// 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
	if totalDays < 30 {
		result := ResolveUnit(totalWeeks, sd.week, loc, "")
		if remainderDays > 0 {
			result += sd.delimiter + ResolveUnit(remainderDays, sd.day, loc, "")
		}
		return result
	}

	// Approximate months (30.44 days average)
	totalMonths := roundDiv(totalDays)

	// 1-11 months
	if totalMonths < 12 {
		if totalMonths == 0 {
			totalMonths = 1
		}
		return ResolveUnit(totalMonths, sd.month, loc, "")
	}

	// 12+ months: years + months
	totalYears := totalMonths / 12
	remainderMonths := totalMonths % 12
	result := ResolveUnit(totalYears, sd.year, loc, "")
	if remainderMonths > 0 {
		result += sd.delimiter + ResolveUnit(remainderMonths, sd.month, loc, "")
	}
	return result
}

// roundDiv approximates months from days using 30.44 average days per month,
// matching Python's round(total_days / 30.44).
func roundDiv(totalDays int) int {
	// Multiply by 100, divide by 3044, with rounding
	// This avoids floating point: round(totalDays / 30.44)
	// = floor(totalDays * 10000 / 30440 + 0.5)
	// Simpler: use float64 since Go has no banker's rounding concern for these values
	return int(float64(totalDays)/30.44 + 0.5)
}

// parseISOToSeconds parses an ISO datetime string to epoch-relative seconds for diffing.
func parseISOToSeconds(iso string) *int {
	if iso == "" {
		return nil
	}

	tIdx := -1
	for i := 0; i < len(iso); i++ {
		if iso[i] == 'T' {
			tIdx = i
			break
		}
	}
	if tIdx < 0 {
		return nil
	}

	datePart := iso[:tIdx]
	timePart := iso[tIdx+1:]

	// Parse date: YYYY-MM-DD
	dp := splitByByte(datePart, '-')
	if len(dp) < 3 {
		return nil
	}
	year := atoiDuration(dp[0])
	month := atoiDuration(dp[1])
	day := atoiDuration(dp[2])

	// Strip timezone info
	timeStr := timePart
	for i := 0; i < len(timeStr); i++ {
		if timeStr[i] == '+' || timeStr[i] == 'Z' {
			timeStr = timeStr[:i]
			break
		}
	}

	// Parse time: HH:MM:SS
	tp := splitByByte(timeStr, ':')
	hour := atoiDuration(tp[0])
	minute := 0
	if len(tp) > 1 {
		minute = atoiDuration(tp[1])
	}
	second := 0
	if len(tp) > 2 {
		// Strip fractional seconds
		secStr := tp[2]
		for i := 0; i < len(secStr); i++ {
			if secStr[i] == '.' {
				secStr = secStr[:i]
				break
			}
		}
		second = atoiDuration(secStr)
	}

	days := daysSinceEpoch(year, month, day)
	result := days*86400 + hour*3600 + minute*60 + second
	return &result
}

// splitByByte splits a string by a single byte separator.
func splitByByte(s string, sep byte) []string {
	var parts []string
	start := 0
	for i := 0; i < len(s); i++ {
		if s[i] == sep {
			parts = append(parts, s[start:i])
			start = i + 1
		}
	}
	parts = append(parts, s[start:])
	return parts
}

// atoiDuration parses a decimal string to int. Returns 0 on failure.
func atoiDuration(s string) int {
	n := 0
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c < '0' || c > '9' {
			return 0
		}
		n = n*10 + int(c-'0')
	}
	return n
}

// isLeapYear returns whether the given year is a leap year.
func isLeapYear(year int) bool {
	return (year%4 == 0 && year%100 != 0) || (year%400 == 0)
}

// daysInMonth returns the number of days in the given month/year.
func daysInMonth(year, month int) int {
	switch month {
	case 1, 3, 5, 7, 8, 10, 12:
		return 31
	case 4, 6, 9, 11:
		return 30
	case 2:
		if isLeapYear(year) {
			return 29
		}
		return 28
	}
	return 30
}

// daysSinceEpoch calculates days since a reference epoch (2000-01-01).
func daysSinceEpoch(year, month, day int) int {
	days := 0
	if year >= 2000 {
		for y := 2000; y < year; y++ {
			if isLeapYear(y) {
				days += 366
			} else {
				days += 365
			}
		}
	} else {
		for y := year; y < 2000; y++ {
			if isLeapYear(y) {
				days -= 366
			} else {
				days -= 365
			}
		}
	}
	for m := 1; m < month; m++ {
		days += daysInMonth(year, m)
	}
	days += day - 1
	return days
}
