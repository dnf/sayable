package parenttime

import "time"

// timeNow is a package-level variable for testable "today" default.
var timeNow = time.Now

const maxAgeMonths = 6000

// ageComponents holds parsed date components.
type ageComponents struct {
	months   int
	diffDays int
}

// parseAge parses two YYYY-MM-DD strings into calendar months and elapsed days.
// Returns nil if dateOfBirth is empty or in the future relative to asOf.
func parseAge(dateOfBirth string, asOf ...string) *ageComponents {
	if dateOfBirth == "" {
		return nil
	}

	dobY, dobM, dobD := parseDateParts(dateOfBirth)
	if dobY == 0 && dobM == 0 && dobD == 0 {
		return nil
	}

	var refY, refM, refD int
	if len(asOf) > 0 && asOf[0] != "" {
		refY, refM, refD = parseDateParts(asOf[0])
	} else {
		now := timeNow()
		refY = now.Year()
		refM = int(now.Month())
		refD = now.Day()
	}

	dobTime := time.Date(dobY, time.Month(dobM), dobD, 0, 0, 0, 0, time.UTC)
	refTime := time.Date(refY, time.Month(refM), refD, 0, 0, 0, 0, time.UTC)
	diffDays := int(refTime.Sub(dobTime).Hours() / 24)
	if diffDays < 0 {
		return nil
	}

	// Calendar months: clamp birthday to last day of reference month so that
	// e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
	lastDay := time.Date(refY, time.Month(refM)+1, 0, 0, 0, 0, 0, time.UTC).Day()
	clampedBirthday := dobD
	if clampedBirthday > lastDay {
		clampedBirthday = lastDay
	}
	months := (refY-dobY)*12 + (refM - dobM)
	if refD < clampedBirthday {
		months--
	}
	if months > maxAgeMonths {
		return nil
	}

	return &ageComponents{months: months, diffDays: diffDays}
}

// parseDateParts parses "YYYY-MM-DD" into integers. Returns (0,0,0) on failure.
func parseDateParts(s string) (int, int, int) {
	if len(s) < 10 || s[4] != '-' || s[7] != '-' {
		return 0, 0, 0
	}
	y := atoi(s[0:4])
	m := atoi(s[5:7])
	d := atoi(s[8:10])
	return y, m, d
}

func atoi(s string) int {
	n := 0
	for _, c := range s {
		if c < '0' || c > '9' {
			return 0
		}
		n = n*10 + int(c-'0')
	}
	return n
}

// stageKey returns the developmental stage for the given calendar months.
func stageKey(months int) string {
	switch {
	case months < 2:
		return "newborn"
	case months < 12:
		return "infant"
	case months < 36:
		return "toddler"
	case months < 156:
		return "child"
	case months < 216:
		return "teenager"
	default:
		return "adult"
	}
}

// ParentTime is a locale-aware age formatter.
type ParentTime struct {
	locale    *AgeLocale
	day       UnitForms
	week      UnitForms
	month     UnitForms
	year      UnitForms
	half      string
	delimiter string
	justBorn  string
}

// NewParentTime creates a new ParentTime instance with the given locale and optional compactness.
func NewParentTime(locale AgeLocale, compactness ...Compactness) *ParentTime {
	c := Normal
	if len(compactness) > 0 {
		c = compactness[0]
	}

	pt := &ParentTime{
		locale:    &locale,
		day:       locale.Units.Day,
		week:      locale.Units.Week,
		month:     locale.Units.Month,
		year:      locale.Units.Year,
		half:      locale.Half,
		delimiter: locale.Delimiter,
		justBorn:  locale.JustBorn,
	}

	var ovr *CompactnessOverride
	switch c {
	case Short:
		ovr = locale.Short
	case Compact:
		ovr = locale.Compact
	}

	if ovr != nil {
		if ovr.Day != nil {
			pt.day = *ovr.Day
		}
		if ovr.Week != nil {
			pt.week = *ovr.Week
		}
		if ovr.Month != nil {
			pt.month = *ovr.Month
		}
		if ovr.Year != nil {
			pt.year = *ovr.Year
		}
		if ovr.Half != nil {
			pt.half = *ovr.Half
		}
		if ovr.Delimiter != nil {
			pt.delimiter = *ovr.Delimiter
		}
		if ovr.JustBorn != nil {
			pt.justBorn = *ovr.JustBorn
		}
	}

	return pt
}

// FormatAge returns a human-friendly age string.
// dateOfBirth and asOf must be in YYYY-MM-DD format.
// Returns nil if dateOfBirth is empty or in the future.
func (pt *ParentTime) FormatAge(dateOfBirth string, asOf ...string) *string {
	age := parseAge(dateOfBirth, asOf...)
	if age == nil {
		return nil
	}

	months := age.months
	diffDays := age.diffDays

	// Tier 1: 0 days
	if diffDays == 0 {
		return &pt.justBorn
	}

	// Tier 1b: 1–6 days
	if diffDays < 7 {
		s := resolveUnit(diffDays, pt.day, pt.locale, "")
		return &s
	}

	// Tier 2: weeks + days until 3 calendar months
	if months < 3 {
		weeks := diffDays / 7
		days := diffDays % 7
		result := resolveUnit(weeks, pt.week, pt.locale, "")
		if days > 0 {
			result += pt.delimiter + resolveUnit(days, pt.day, pt.locale, "")
		}
		return &result
	}

	// Tier 3: 3–23 months
	if months < 24 {
		s := resolveUnit(months, pt.month, pt.locale, "")
		return &s
	}

	// Tier 4: 24–35 months → years + months
	if months < 36 {
		years := months / 12
		rem := months % 12
		if rem == 0 {
			s := resolveUnit(years, pt.year, pt.locale, "")
			return &s
		}
		s := resolveUnit(years, pt.year, pt.locale, "") + pt.delimiter + resolveUnit(rem, pt.month, pt.locale, "")
		return &s
	}

	// Tier 5: 3–6 years → years with half marker
	if months < 84 {
		years := months / 12
		rem := months % 12
		if rem >= 6 {
			s := resolveUnit(years, pt.year, pt.locale, pt.half)
			return &s
		}
		s := resolveUnit(years, pt.year, pt.locale, "")
		return &s
	}

	// Tier 6: 7+ years
	years := months / 12
	s := resolveUnit(years, pt.year, pt.locale, "")
	return &s
}

// FormatStage returns the developmental stage label based on age.
// opts may contain: asOf (YYYY-MM-DD string), gender ("m" or "f").
// Returns nil if dateOfBirth is empty or in the future.
func (pt *ParentTime) FormatStage(dateOfBirth string, opts ...string) *string {
	var asOfStr string
	var gender string
	if len(opts) > 0 {
		asOfStr = opts[0]
	}
	if len(opts) > 1 {
		gender = opts[1]
	}

	var asOfArgs []string
	if asOfStr != "" {
		asOfArgs = []string{asOfStr}
	}
	age := parseAge(dateOfBirth, asOfArgs...)
	if age == nil {
		return nil
	}
	key := stageKey(age.months)
	var sl StageLabel
	switch key {
	case "newborn":
		sl = pt.locale.Stages.Newborn
	case "infant":
		sl = pt.locale.Stages.Infant
	case "toddler":
		sl = pt.locale.Stages.Toddler
	case "child":
		sl = pt.locale.Stages.Child
	case "teenager":
		sl = pt.locale.Stages.Teenager
	case "adult":
		sl = pt.locale.Stages.Adult
	}
	s := ResolveStage(sl, gender)
	return &s
}
