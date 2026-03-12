module locales

// SayableDate is a locale-aware date formatter.
pub struct SayableDate {
	locale                 &DateLocale = unsafe { nil }
	months                 [12]string
	months_in_date         [12]string
	weekdays               [7]string
	day_format             string
	day_format_exceptions  map[string]string
	date_pattern           string
	date_pattern_with_year string
	today                  string
	tomorrow               string
	yesterday              string
	compactness            Compactness
	use_months_in_date     bool
}

// new_sayable_date creates a new SayableDate instance with the given locale and compactness.
pub fn new_sayable_date(locale &DateLocale, compactness Compactness) SayableDate {
	mut months := locale.months
	mut months_in_date := locale.months_in_date
	mut use_months_in_date := locale.has_months_in_date
	mut weekdays := locale.weekdays
	mut day_format := locale.day_format
	mut day_format_exceptions := locale.day_format_exceptions.clone()
	mut date_pattern := locale.date_pattern
	mut date_pattern_with_year := locale.date_pattern_with_year
	mut today := locale.today
	mut tomorrow := locale.tomorrow
	mut yesterday := locale.yesterday

	mut has_ovr := false
	mut ovr := DateCompactnessOverride{}
	if compactness == .short && locale.has_short {
		has_ovr = true
		ovr = locale.short_override
	} else if compactness == .compact && locale.has_compact {
		has_ovr = true
		ovr = locale.compact_override
	}

	if has_ovr {
		if ovr.has_months {
			months = ovr.months
		}
		if ovr.has_weekdays {
			weekdays = ovr.weekdays
		}
		if ovr.has_day_format {
			day_format = ovr.day_format
			// When override provides day_format without exceptions, clear exceptions
			day_format_exceptions = map[string]string{}
		}
		if ovr.has_date_pattern {
			date_pattern = ovr.date_pattern
		}
		if ovr.has_date_pattern_with_year {
			date_pattern_with_year = ovr.date_pattern_with_year
		}
	}

	return SayableDate{
		locale: locale
		months: months
		months_in_date: months_in_date
		weekdays: weekdays
		day_format: day_format
		day_format_exceptions: day_format_exceptions
		date_pattern: date_pattern
		date_pattern_with_year: date_pattern_with_year
		today: today
		tomorrow: tomorrow
		yesterday: yesterday
		compactness: compactness
		use_months_in_date: use_months_in_date
	}
}

// format_date formats a calendar date in locale-appropriate form.
// Always absolute -- no proximity logic.
pub fn (sd &SayableDate) format_date(date string) ?string {
	if date.len == 0 {
		return none
	}
	y, m, d := parse_date(date) or { return none }
	return sd.format_absolute(y, m, d, false)
}

// format_date_with_year formats a calendar date with year in locale-appropriate form.
pub fn (sd &SayableDate) format_date_with_year(date string) ?string {
	if date.len == 0 {
		return none
	}
	y, m, d := parse_date(date) or { return none }
	return sd.format_absolute(y, m, d, true)
}

// format_relative formats a date relative to as_of, picking the most natural reference.
pub fn (sd &SayableDate) format_relative(date string, as_of string) ?string {
	if date.len == 0 || as_of.len == 0 {
		return none
	}
	dy, dm, dd := parse_date(date) or { return none }
	ay, am, ad := parse_date(as_of) or { return none }

	date_jdn := to_jdn(dy, dm, dd)
	asof_jdn := to_jdn(ay, am, ad)
	diff := date_jdn - asof_jdn

	// Today
	if diff == 0 {
		return sd.today
	}

	// Tomorrow
	if diff == 1 {
		return sd.tomorrow
	}

	// Yesterday
	if diff == -1 {
		return sd.yesterday
	}

	loc := sd.locale
	is_compact := sd.compactness == .compact

	// Day after tomorrow (optional)
	if diff == 2 && loc.has_day_after_tomorrow && !is_compact {
		return loc.day_after_tomorrow
	}

	// Day before yesterday (optional)
	if diff == -2 && loc.has_day_before_yesterday && !is_compact {
		return loc.day_before_yesterday
	}

	// Compact mode: skip weekday references, go straight to calendar date
	if is_compact {
		include_year := dy != ay
		return sd.format_absolute(dy, dm, dd, include_year)
	}

	// This weekday (+2 to +6)
	if diff >= 2 && diff <= 6 && loc.has_this_weekday {
		dow := weekday(dy, dm, dd)
		weekday_name := sd.weekdays[dow]
		return loc.this_weekday.replace('{weekday}', weekday_name)
	}

	// Last weekday (-2 to -6)
	if diff >= -6 && diff <= -2 && loc.has_last_weekday {
		dow := weekday(dy, dm, dd)
		weekday_name := sd.weekdays[dow]
		return loc.last_weekday.replace('{weekday}', weekday_name)
	}

	// Next weekday (+7 to +13)
	if diff >= 7 && diff <= 13 && loc.has_next_weekday {
		dow := weekday(dy, dm, dd)
		weekday_name := sd.weekdays[dow]
		return loc.next_weekday.replace('{weekday}', weekday_name)
	}

	// Calendar fallback
	include_year := dy != ay
	return sd.format_absolute(dy, dm, dd, include_year)
}

fn (sd &SayableDate) format_absolute(year int, month int, day int, include_year bool) string {
	// Format the day with ordinal
	day_str := day.str()
	fmt := if day_str in sd.day_format_exceptions {
		sd.day_format_exceptions[day_str]
	} else {
		sd.day_format
	}
	formatted_day := fmt.replace('{n}', day_str)

	// Pick month name (genitive form if available)
	month_name := if sd.use_months_in_date {
		sd.months_in_date[month - 1]
	} else {
		sd.months[month - 1]
	}

	pattern := if include_year { sd.date_pattern_with_year } else { sd.date_pattern }
	mut result := pattern.replace('{month}', month_name)
	result = result.replace('{day}', formatted_day)
	result = result.replace('{d}', day.str())
	result = result.replace('{m}', month.str())
	if include_year {
		result = result.replace('{year}', year.str())
		yy := year % 100
		mut yy_str := yy.str()
		if yy < 10 {
			yy_str = '0${yy_str}'
		}
		result = result.replace('{yy}', yy_str)
	}

	return result
}

fn parse_date(s string) ?(int, int, int) {
	// Handle ISO datetime by stripping time part
	mut date_part := s
	t_pos := s.index('T') or { -1 }
	if t_pos >= 0 {
		date_part = s[..t_pos]
	}

	if date_part.len < 10 || date_part[4] != `-` || date_part[7] != `-` {
		return none
	}
	y := str_to_int(date_part[0..4]) or { return none }
	m := str_to_int(date_part[5..7]) or { return none }
	d := str_to_int(date_part[8..10]) or { return none }
	if m < 1 || m > 12 || d < 1 || d > 31 {
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

fn to_jdn(year int, month int, day int) int {
	a := (14 - month) / 12
	y := year + 4800 - a
	m := month + 12 * a - 3
	return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

fn weekday(year int, month int, day int) int {
	// Returns 0=Sunday, 1=Monday, ..., 6=Saturday
	jdn := to_jdn(year, month, day)
	return (jdn + 1) % 7
}
