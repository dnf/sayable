package sayabledate

import "strings"

// Version is the library version, matching date/config/version.json.
const Version = "0.1.0"

// SayableDate is a locale-aware date formatter.
type SayableDate struct {
	locale              *DateLocale
	compactness         Compactness
	months              [12]string
	monthsInDate        *[12]string
	weekdays            [7]string
	dayFormat           string
	dayFormatExceptions map[string]string
	datePattern         string
	datePatternWithYear string
	today               string
	tomorrow            string
	yesterday           string
}

// NewSayableDate creates a new SayableDate with the given locale and optional compactness.
func NewSayableDate(locale DateLocale, compactness ...Compactness) *SayableDate {
	c := Normal
	if len(compactness) > 0 {
		c = compactness[0]
	}

	var ovr *CompactnessOverride
	switch c {
	case Short:
		ovr = locale.Short
	case Compact:
		ovr = locale.Compact
	}

	sd := &SayableDate{
		locale:              &locale,
		compactness:         c,
		months:              locale.Months,
		monthsInDate:        locale.MonthsInDate,
		weekdays:            locale.Weekdays,
		dayFormat:           locale.DayFormat,
		dayFormatExceptions: locale.DayFormatExceptions,
		datePattern:         locale.DatePattern,
		datePatternWithYear: locale.DatePatternWithYear,
		today:               locale.Today,
		tomorrow:            locale.Tomorrow,
		yesterday:           locale.Yesterday,
	}

	if ovr != nil {
		if ovr.Months != nil {
			sd.months = *ovr.Months
		}
		if ovr.MonthsInDate != nil {
			sd.monthsInDate = ovr.MonthsInDate
		}
		if ovr.Weekdays != nil {
			sd.weekdays = *ovr.Weekdays
		}
		// When DayFormat is overridden but DayFormatExceptions is not,
		// clear exceptions (the override replaces the format entirely).
		if ovr.DayFormat != nil {
			sd.dayFormat = *ovr.DayFormat
			if ovr.DayFormatExceptions == nil {
				sd.dayFormatExceptions = map[string]string{}
			}
		}
		if ovr.DayFormatExceptions != nil {
			sd.dayFormatExceptions = ovr.DayFormatExceptions
		}
		if ovr.DatePattern != nil {
			sd.datePattern = *ovr.DatePattern
		}
		if ovr.DatePatternWithYear != nil {
			sd.datePatternWithYear = *ovr.DatePatternWithYear
		}
		if ovr.Today != nil {
			sd.today = *ovr.Today
		}
		if ovr.Tomorrow != nil {
			sd.tomorrow = *ovr.Tomorrow
		}
		if ovr.Yesterday != nil {
			sd.yesterday = *ovr.Yesterday
		}
	}

	return sd
}

// FormatDate formats a calendar date in locale-appropriate form (no year).
// Returns nil if the input is empty or unparseable.
func (sd *SayableDate) FormatDate(date string) *string {
	if date == "" {
		return nil
	}
	parsed := parseDate(date)
	if parsed == nil {
		return nil
	}
	s := sd.formatAbsolute(parsed[0], parsed[1], parsed[2], false)
	return &s
}

// FormatDateWithYear formats a calendar date with year in locale-appropriate form.
// Returns nil if the input is empty or unparseable.
func (sd *SayableDate) FormatDateWithYear(date string) *string {
	if date == "" {
		return nil
	}
	parsed := parseDate(date)
	if parsed == nil {
		return nil
	}
	s := sd.formatAbsolute(parsed[0], parsed[1], parsed[2], true)
	return &s
}

// FormatRelative formats a date relative to asOf, picking the most natural reference.
// Falls back to absolute date for distant dates.
// Returns nil if either input is empty or unparseable.
func (sd *SayableDate) FormatRelative(date string, asOf string) *string {
	if date == "" || asOf == "" {
		return nil
	}
	parsedDate := parseDate(date)
	parsedAsOf := parseDate(asOf)
	if parsedDate == nil || parsedAsOf == nil {
		return nil
	}

	dy, dm, dd := parsedDate[0], parsedDate[1], parsedDate[2]
	ay, am, ad := parsedAsOf[0], parsedAsOf[1], parsedAsOf[2]

	dateJDN := toJDN(dy, dm, dd)
	asofJDN := toJDN(ay, am, ad)
	diff := dateJDN - asofJDN

	// Today
	if diff == 0 {
		return &sd.today
	}

	// Tomorrow
	if diff == 1 {
		return &sd.tomorrow
	}

	// Yesterday
	if diff == -1 {
		return &sd.yesterday
	}

	loc := sd.locale
	isCompact := sd.compactness == Compact

	// Day after tomorrow (optional, skipped in compact mode)
	if diff == 2 && loc.DayAfterTomorrow != nil && !isCompact {
		return loc.DayAfterTomorrow
	}

	// Day before yesterday (optional, skipped in compact mode)
	if diff == -2 && loc.DayBeforeYesterday != nil && !isCompact {
		return loc.DayBeforeYesterday
	}

	// Compact mode: skip weekday references, go straight to calendar date
	if isCompact {
		includeYear := dy != ay
		s := sd.formatAbsolute(dy, dm, dd, includeYear)
		return &s
	}

	// This weekday (+2 to +6)
	if diff >= 2 && diff <= 6 && loc.ThisWeekday != nil {
		dow := weekday(dy, dm, dd)
		weekdayName := sd.weekdays[dow]
		s := strings.Replace(*loc.ThisWeekday, "{weekday}", weekdayName, 1)
		return &s
	}

	// Last weekday (-6 to -2)
	if diff >= -6 && diff <= -2 && loc.LastWeekday != nil {
		dow := weekday(dy, dm, dd)
		weekdayName := sd.weekdays[dow]
		s := strings.Replace(*loc.LastWeekday, "{weekday}", weekdayName, 1)
		return &s
	}

	// Next weekday (+7 to +13)
	if diff >= 7 && diff <= 13 && loc.NextWeekday != nil {
		dow := weekday(dy, dm, dd)
		weekdayName := sd.weekdays[dow]
		s := strings.Replace(*loc.NextWeekday, "{weekday}", weekdayName, 1)
		return &s
	}

	// Calendar fallback
	includeYear := dy != ay
	s := sd.formatAbsolute(dy, dm, dd, includeYear)
	return &s
}

// formatAbsolute formats a date as an absolute calendar reference.
func (sd *SayableDate) formatAbsolute(year, month, day int, includeYear bool) string {
	dayStr := itoa(day)
	fmt, ok := sd.dayFormatExceptions[dayStr]
	if !ok {
		fmt = sd.dayFormat
	}
	formattedDay := strings.Replace(fmt, "{n}", dayStr, 1)

	// Pick month name (genitive form if available)
	var monthName string
	if sd.monthsInDate != nil {
		monthName = sd.monthsInDate[month-1]
	} else {
		monthName = sd.months[month-1]
	}

	var pattern string
	if includeYear {
		pattern = sd.datePatternWithYear
	} else {
		pattern = sd.datePattern
	}

	result := strings.Replace(pattern, "{month}", monthName, 1)
	result = strings.Replace(result, "{day}", formattedDay, 1)
	result = strings.Replace(result, "{d}", itoa(day), 1)
	result = strings.Replace(result, "{m}", itoa(month), 1)
	if includeYear {
		result = strings.Replace(result, "{year}", itoa(year), 1)
		yy := year % 100
		yyStr := itoa(yy)
		if yy < 10 {
			yyStr = "0" + yyStr
		}
		result = strings.Replace(result, "{yy}", yyStr, 1)
	}

	return result
}

// parseDate parses "YYYY-MM-DD" or ISO datetime to [year, month, day].
// Returns nil on failure.
func parseDate(s string) *[3]int {
	if s == "" {
		return nil
	}
	// Strip time part from ISO datetime
	datePart := s
	if idx := strings.IndexByte(s, 'T'); idx >= 0 {
		datePart = s[:idx]
	}
	parts := strings.Split(datePart, "-")
	if len(parts) != 3 {
		return nil
	}
	year := atoiDate(parts[0])
	month := atoiDate(parts[1])
	day := atoiDate(parts[2])
	if year < 0 || month < 1 || month > 12 || day < 1 || day > 31 {
		return nil
	}
	return &[3]int{year, month, day}
}

// atoiDate converts a decimal string to int. Returns -1 on failure.
func atoiDate(s string) int {
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

// toJDN converts a date to Julian Day Number for day-difference arithmetic.
func toJDN(year, month, day int) int {
	a := (14 - month) / 12
	y := year + 4800 - a
	m := month + 12*a - 3
	return day + (153*m+2)/5 + 365*y + y/4 - y/100 + y/400 - 32045
}

// weekday returns the day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.
func weekday(year, month, day int) int {
	jdn := toJDN(year, month, day)
	return (jdn + 1) % 7
}

// itoa converts a non-negative int to its decimal string representation.
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
	for i, j := 0, len(digits)-1; i < j; i, j = i+1, j-1 {
		digits[i], digits[j] = digits[j], digits[i]
	}
	return string(digits)
}
