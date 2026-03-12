module locales

const max_age_months = 6000

struct AgeComponents {
	months    int
	diff_days int
}

// SayableAge is a locale-aware age formatter.
pub struct SayableAge {
	locale    &AgeLocale = unsafe { nil }
	day       UnitForms
	week      UnitForms
	month     UnitForms
	year      UnitForms
	half      string
	delimiter string
	just_born string
}

// new_sayable_age creates a new SayableAge instance with the given locale and compactness.
pub fn new_sayable_age(locale &AgeLocale, compactness Compactness) SayableAge {
	mut day := locale.day
	mut week := locale.week
	mut month := locale.month
	mut year := locale.year
	mut half := locale.half
	mut delimiter := locale.delimiter
	mut just_born := locale.just_born

	mut has_ovr := false
	mut ovr := CompactnessOverride{}
	if compactness == .short && locale.has_short {
		has_ovr = true
		ovr = locale.short_override
	} else if compactness == .compact && locale.has_compact {
		has_ovr = true
		ovr = locale.compact_override
	}

	if has_ovr {
		if ovr.has_day {
			day = ovr.day
		}
		if ovr.has_week {
			week = ovr.week
		}
		if ovr.has_month {
			month = ovr.month
		}
		if ovr.has_year {
			year = ovr.year
		}
		if ovr.has_half {
			half = ovr.half
		}
		if ovr.has_delimiter {
			delimiter = ovr.delimiter
		}
		if ovr.has_just_born {
			just_born = ovr.just_born
		}
	}

	return SayableAge{
		locale: locale
		day: day
		week: week
		month: month
		year: year
		half: half
		delimiter: delimiter
		just_born: just_born
	}
}

// format_age returns a human-friendly age string.
// date_of_birth and as_of must be in YYYY-MM-DD format.
// Returns none if date_of_birth is empty or in the future.
pub fn (sa &SayableAge) format_age(date_of_birth string, as_of string) ?string {
	age := parse_age(date_of_birth, as_of) or { return none }

	months := age.months
	diff_days := age.diff_days

	// Tier 1: 0 days
	if diff_days == 0 {
		return sa.just_born
	}

	// Tier 1b: 1-6 days
	if diff_days < 7 {
		return resolve_unit(diff_days, sa.day, sa.locale, '')
	}

	// Tier 2: weeks + days until 3 calendar months
	if months < 3 {
		weeks := diff_days / 7
		days := diff_days % 7
		mut result := resolve_unit(weeks, sa.week, sa.locale, '')
		if days > 0 {
			result += sa.delimiter + resolve_unit(days, sa.day, sa.locale, '')
		}
		return result
	}

	// Tier 3: 3-23 months
	if months < 24 {
		return resolve_unit(months, sa.month, sa.locale, '')
	}

	// Tier 4: 24-35 months -> years + months
	if months < 36 {
		years := months / 12
		rem := months % 12
		if rem == 0 {
			return resolve_unit(years, sa.year, sa.locale, '')
		}
		return resolve_unit(years, sa.year, sa.locale, '') + sa.delimiter +
			resolve_unit(rem, sa.month, sa.locale, '')
	}

	// Tier 5: 3-6 years -> years with half marker
	if months < 84 {
		years := months / 12
		rem := months % 12
		if rem >= 6 {
			return resolve_unit(years, sa.year, sa.locale, sa.half)
		}
		return resolve_unit(years, sa.year, sa.locale, '')
	}

	// Tier 6: 7+ years
	years := months / 12
	return resolve_unit(years, sa.year, sa.locale, '')
}

// format_stage returns the developmental stage label based on age.
// Returns none if date_of_birth is empty or in the future.
pub fn (sa &SayableAge) format_stage(date_of_birth string, as_of string, gender string) ?string {
	age := parse_age(date_of_birth, as_of) or { return none }
	key := stage_key(age.months)
	sl := match key {
		'newborn' { sa.locale.newborn }
		'infant' { sa.locale.infant }
		'toddler' { sa.locale.toddler }
		'child' { sa.locale.child }
		'teenager' { sa.locale.teenager }
		else { sa.locale.adult }
	}
	return resolve_stage(sl, gender)
}

fn stage_key(months int) string {
	if months < 2 {
		return 'newborn'
	}
	if months < 12 {
		return 'infant'
	}
	if months < 36 {
		return 'toddler'
	}
	if months < 156 {
		return 'child'
	}
	if months < 216 {
		return 'teenager'
	}
	return 'adult'
}

fn parse_age(date_of_birth string, as_of string) ?AgeComponents {
	if date_of_birth.len == 0 {
		return none
	}

	dob_y, dob_m, dob_d := parse_date_parts(date_of_birth) or { return none }

	mut ref_y := 0
	mut ref_m := 0
	mut ref_d := 0
	if as_of.len > 0 {
		ref_y, ref_m, ref_d = parse_date_parts(as_of) or { return none }
	} else {
		return none
	}

	diff_days := days_between(dob_y, dob_m, dob_d, ref_y, ref_m, ref_d)
	if diff_days < 0 {
		return none
	}

	// Calendar months with clamping
	last_day := days_in_month(ref_y, ref_m)
	mut clamped_birthday := dob_d
	if clamped_birthday > last_day {
		clamped_birthday = last_day
	}
	mut months := (ref_y - dob_y) * 12 + (ref_m - dob_m)
	if ref_d < clamped_birthday {
		months--
	}
	if months > max_age_months {
		return none
	}

	return AgeComponents{
		months: months
		diff_days: diff_days
	}
}

fn parse_date_parts(s string) ?(int, int, int) {
	if s.len < 10 || s[4] != `-` || s[7] != `-` {
		return none
	}
	y := str_to_int(s[0..4]) or { return none }
	m := str_to_int(s[5..7]) or { return none }
	d := str_to_int(s[8..10]) or { return none }
	if y == 0 && m == 0 && d == 0 {
		return none
	}
	return y, m, d
}

fn str_to_int(s string) ?int {
	mut n := 0
	for c in s {
		if c < `0` || c > `9` {
			return none
		}
		n = n * 10 + int(c - `0`)
	}
	return n
}

fn is_leap_year(y int) bool {
	return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
}

fn days_in_month(y int, m int) int {
	return match m {
		1, 3, 5, 7, 8, 10, 12 { 31 }
		4, 6, 9, 11 { 30 }
		2 { if is_leap_year(y) { 29 } else { 28 } }
		else { 30 }
	}
}

fn days_from_epoch(y int, m int, d int) int {
	mut yy := y
	mut mm := m
	if mm <= 2 {
		yy--
		mm += 12
	}
	return 365 * yy + yy / 4 - yy / 100 + yy / 400 + (153 * (mm - 3) + 2) / 5 + d - 307
}

fn days_between(y1 int, m1 int, d1 int, y2 int, m2 int, d2 int) int {
	return days_from_epoch(y2, m2, d2) - days_from_epoch(y1, m1, d1)
}

fn resolve_unit(count int, uf UnitForms, loc &AgeLocale, half string) string {
	base_n := count.str()

	// Apply {n}-style half marker to the number
	mut n := base_n
	if half.len > 0 && half.contains('{n}') {
		n = half.replace('{n}', base_n)
	}

	// Select template
	mut tmpl := ''
	if uf.simple.len > 0 {
		tmpl = uf.simple
	} else {
		cat := loc.plural(count)
		if cat in uf.forms {
			tmpl = uf.forms[cat]
		} else {
			tmpl = uf.forms[PluralCategory.other]
		}
	}

	mut result := tmpl.replace('{n}', n)

	// Apply {0}-style half marker (wraps the whole expression)
	if half.len > 0 && half.contains('{0}') {
		result = half.replace('{0}', result)
	}

	return result
}
