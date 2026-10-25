package sayableduration

import "strings"

// Version is the library version, matching duration/config/version.json.
const Version = "0.5.0"

// maxDurationMonths is the 500-year ceiling, the same as sayable-age.
const maxDurationMonths = 6000

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
// duration string. Returns nil for negative values and durations over 500 years.
func (sd *SayableDuration) FormatDurationSeconds(seconds int64) *string {
	if seconds < 0 {
		return nil
	}
	return sd.formatDurationSeconds(seconds)
}

// FormatDurationISO formats the duration between two ISO datetime strings.
// Returns nil if either string is empty or cannot be parsed, or the duration
// is over 500 years.
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
	return sd.formatDurationSeconds(total)
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
	if dur == nil {
		return nil
	}
	result := strings.Replace(sd.ago, "{0}", *dur, 1)
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
	if dur == nil {
		return nil
	}
	result := strings.Replace(sd.inFuture, "{0}", *dur, 1)
	return &result
}

// formatDurationSeconds applies duration tiers to total seconds; nil beyond
// the 500-year ceiling.
func (sd *SayableDuration) formatDurationSeconds(total int64) *string {
	text, ok := sd.formatTiers(total)
	if !ok {
		return nil
	}
	return &text
}

// formatTiers applies the duration tiers; ok is false beyond the 500-year ceiling.
func (sd *SayableDuration) formatTiers(total int64) (text string, ok bool) {
	loc := sd.locale

	// 0 seconds
	if total == 0 {
		return sd.justNow, true
	}

	// 1-59 seconds
	if total < 60 {
		return resolveCount(total, sd.second, loc, ""), true
	}

	totalMinutes := total / 60
	remainderSeconds := total % 60

	// 1-4 minutes: minutes + seconds
	if totalMinutes < 5 {
		result := resolveCount(totalMinutes, sd.minute, loc, "")
		if remainderSeconds > 0 {
			result += sd.delimiter + resolveCount(remainderSeconds, sd.second, loc, "")
		}
		return result, true
	}

	// 5-59 minutes
	if totalMinutes < 60 {
		return resolveCount(totalMinutes, sd.minute, loc, ""), true
	}

	totalHours := total / 3600
	remainderMinutes := (total % 3600) / 60

	// 1-5 hours: hours + minutes (with half marker)
	if totalHours <= 5 {
		if remainderMinutes == 30 {
			return resolveCount(totalHours, sd.hour, loc, sd.half), true
		}
		result := resolveCount(totalHours, sd.hour, loc, "")
		if remainderMinutes > 0 {
			result += sd.delimiter + resolveCount(remainderMinutes, sd.minute, loc, "")
		}
		return result, true
	}

	// 6-23 hours
	if totalHours < 24 {
		return resolveCount(totalHours, sd.hour, loc, ""), true
	}

	totalDays := total / 86400
	remainderHours := (total % 86400) / 3600

	// 1-2 days: days + hours (with half marker)
	if totalDays <= 2 {
		if remainderHours == 12 {
			return resolveCount(totalDays, sd.day, loc, sd.half), true
		}
		result := resolveCount(totalDays, sd.day, loc, "")
		if remainderHours > 0 {
			result += sd.delimiter + resolveCount(remainderHours, sd.hour, loc, "")
		}
		return result, true
	}

	// 3-6 days
	if totalDays < 7 {
		return resolveCount(totalDays, sd.day, loc, ""), true
	}

	totalWeeks := totalDays / 7
	remainderDays := totalDays % 7

	// 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
	if totalDays < 30 {
		result := resolveCount(totalWeeks, sd.week, loc, "")
		if remainderDays > 0 {
			result += sd.delimiter + resolveCount(remainderDays, sd.day, loc, "")
		}
		return result, true
	}

	// Approximate months (30.44 days average)
	totalMonths := roundDiv(totalDays)
	if totalMonths > maxDurationMonths {
		return "", false
	}

	// 1-11 months
	if totalMonths < 12 {
		if totalMonths == 0 {
			totalMonths = 1
		}
		return resolveCount(totalMonths, sd.month, loc, ""), true
	}

	// 12+ months: years + months
	totalYears := totalMonths / 12
	remainderMonths := totalMonths % 12
	result := resolveCount(totalYears, sd.year, loc, "")
	if remainderMonths > 0 {
		result += sd.delimiter + resolveCount(remainderMonths, sd.month, loc, "")
	}
	return result, true
}

// resolveCount resolves a unit for a count that the tiers keep small (at most
// 6000 months).
func resolveCount(count int64, forms UnitForms, loc *DurationLocale, half string) string {
	return ResolveUnit(int(count), forms, loc, half)
}

// roundDiv approximates months from days using 30.44 average days per month,
// matching Python's round(total_days / 30.44).
func roundDiv(totalDays int64) int64 {
	// Multiply by 100, divide by 3044, with rounding
	// This avoids floating point: round(totalDays / 30.44)
	// = floor(totalDays * 10000 / 30440 + 0.5)
	// Simpler: use float64 since Go has no banker's rounding concern for these values
	return int64(float64(totalDays)/30.44 + 0.5)
}

// parseISOToSeconds parses a timestamp (docs/input-formats.md) to
// epoch-relative seconds for diffing: "YYYY-MM-DDTHH:MM", optional ":SS",
// optional "." plus digits after the seconds, and an optional zone suffix
// "Z" or "±HH:MM", which is ignored. Returns nil for anything else.
func parseISOToSeconds(iso string) *int64 {
	if len(iso) < 11 || iso[4] != '-' || iso[7] != '-' || iso[10] != 'T' {
		return nil
	}
	year, month, day := atoiDuration(iso[0:4]), atoiDuration(iso[5:7]), atoiDuration(iso[8:10])
	if year < 0 || month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month) {
		return nil
	}
	hour, minute, second, ok := parseClock(iso[11:])
	if !ok {
		return nil
	}
	result := int64(daysSinceEpoch(year, month, day))*86400 + int64(hour*3600+minute*60+second)
	return &result
}

// parseClock parses "H:MM" or "HH:MM", then optional ":SS", an optional "."
// plus digits (only after seconds), and an optional zone suffix.
func parseClock(clock string) (hour, minute, second int, ok bool) {
	hourLen := digitRun(clock)
	if hourLen < 1 || hourLen > 2 || len(clock) < hourLen+3 || clock[hourLen] != ':' {
		return 0, 0, 0, false
	}
	hour = atoiDuration(clock[:hourLen])
	minute = atoiDuration(clock[hourLen+1 : hourLen+3])
	rest := clock[hourLen+3:]
	if len(rest) > 0 && rest[0] == ':' {
		if len(rest) < 3 {
			return 0, 0, 0, false
		}
		second = atoiDuration(rest[1:3])
		rest = rest[3:]
		if len(rest) > 0 && rest[0] == '.' {
			fractionLen := digitRun(rest[1:])
			if fractionLen == 0 {
				return 0, 0, 0, false
			}
			rest = rest[1+fractionLen:]
		}
	}
	if minute < 0 || second < 0 || hour > 23 || minute > 59 || second > 59 || !isZoneSuffix(rest) {
		return 0, 0, 0, false
	}
	return hour, minute, second, true
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

// atoiDuration parses a run of ASCII digits to int. Returns -1 on failure.
func atoiDuration(s string) int {
	if s == "" {
		return -1
	}
	n := 0
	for i := 0; i < len(s); i++ {
		c := s[i]
		if c < '0' || c > '9' {
			return -1
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
