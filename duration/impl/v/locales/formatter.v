module locales

import math

// SayableDuration is a locale-aware duration and relative time formatter.
pub struct SayableDuration {
	locale    &DurationLocale = unsafe { nil }
	second    UnitForms
	minute    UnitForms
	hour      UnitForms
	day       UnitForms
	week      UnitForms
	month     UnitForms
	year      UnitForms
	half      string
	delimiter string
	just_now  string
	ago       string
	in_future string
}

// new_sayable_duration creates a new SayableDuration instance.
pub fn new_sayable_duration(locale &DurationLocale, compactness Compactness) SayableDuration {
	mut second := locale.second
	mut minute := locale.minute
	mut hour := locale.hour
	mut day := locale.day
	mut week := locale.week
	mut month := locale.month
	mut year := locale.year
	mut half := locale.half
	mut delimiter := locale.delimiter
	mut ago := locale.ago
	mut in_future := locale.in_future

	mut has_ovr := false
	mut ovr := DurationCompactnessOverride{}
	if compactness == .short && locale.has_short {
		has_ovr = true
		ovr = locale.short_override
	} else if compactness == .compact && locale.has_compact {
		has_ovr = true
		ovr = locale.compact_override
	}

	if has_ovr {
		if ovr.has_second {
			second = ovr.second
		}
		if ovr.has_minute {
			minute = ovr.minute
		}
		if ovr.has_hour {
			hour = ovr.hour
		}
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
		if ovr.has_ago {
			ago = ovr.ago
		}
		if ovr.has_in_future {
			in_future = ovr.in_future
		}
	}

	return SayableDuration{
		locale: locale
		second: second
		minute: minute
		hour: hour
		day: day
		week: week
		month: month
		year: year
		half: half
		delimiter: delimiter
		just_now: locale.just_now
		ago: ago
		in_future: in_future
	}
}

// format_duration formats a duration given in seconds.
pub fn (sd &SayableDuration) format_duration(total_seconds i64) ?string {
	if total_seconds < 0 {
		return none
	}
	return sd.format_within_ceiling(total_seconds)
}

// format_duration_iso formats a duration between two ISO timestamps.
pub fn (sd &SayableDuration) format_duration_iso(start string, end string) ?string {
	if start.len == 0 || end.len == 0 {
		return none
	}
	s := parse_iso_to_seconds(start) or { return none }
	e := parse_iso_to_seconds(end) or { return none }
	mut diff := e - s
	if diff < 0 {
		diff = -diff
	}
	return sd.format_within_ceiling(diff)
}

// format_since formats elapsed time as 'X ago'.
pub fn (sd &SayableDuration) format_since(start string, as_of string) ?string {
	if start.len == 0 || as_of.len == 0 {
		return none
	}
	s := parse_iso_to_seconds(start) or { return none }
	a := parse_iso_to_seconds(as_of) or { return none }
	diff := a - s
	if diff < 0 {
		return none
	}
	if diff == 0 {
		return sd.just_now
	}
	dur := sd.format_within_ceiling(diff) or { return none }
	return sd.ago.replace('{0}', dur)
}

// format_until formats time until a future event as 'in X'.
pub fn (sd &SayableDuration) format_until(target string, as_of string) ?string {
	if target.len == 0 || as_of.len == 0 {
		return none
	}
	t := parse_iso_to_seconds(target) or { return none }
	a := parse_iso_to_seconds(as_of) or { return none }
	diff := t - a
	if diff < 0 {
		return none
	}
	if diff == 0 {
		return sd.just_now
	}
	dur := sd.format_within_ceiling(diff) or { return none }
	return sd.in_future.replace('{0}', dur)
}

// max_duration_months is the 500-year ceiling, the same as sayable-age.
const max_duration_months = 6000

// approximate_months counts months from whole days, 30.44 days to the month, rounded.
fn approximate_months(total_days i64) i64 {
	return i64(math.round(f64(total_days) / 30.44))
}

// format_within_ceiling applies the duration tiers; none beyond the 500-year ceiling.
fn (sd &SayableDuration) format_within_ceiling(total i64) ?string {
	whole_days := total / 86400
	if whole_days >= 30 && approximate_months(whole_days) > max_duration_months {
		return none
	}
	return sd.format_duration_seconds(total)
}

// format_duration_seconds applies the duration tiers within the ceiling, where
// every count fits an int.
fn (sd &SayableDuration) format_duration_seconds(total i64) string {
	// 0 seconds
	if total == 0 {
		return sd.just_now
	}

	// 1-59 seconds
	if total < 60 {
		return resolve_unit(int(total), sd.second, sd.locale, '')
	}

	total_minutes := int(total / 60)
	remainder_seconds := int(total % 60)

	// 1-4 minutes: minutes + seconds
	if total_minutes < 5 {
		mut result := resolve_unit(total_minutes, sd.minute, sd.locale, '')
		if remainder_seconds > 0 {
			result += sd.delimiter + resolve_unit(remainder_seconds, sd.second, sd.locale, '')
		}
		return result
	}

	// 5-59 minutes
	if total_minutes < 60 {
		return resolve_unit(total_minutes, sd.minute, sd.locale, '')
	}

	total_hours := int(total / 3600)
	remainder_minutes := int((total % 3600) / 60)

	// 1-5 hours: hours + minutes (with half marker)
	if total_hours <= 5 {
		if remainder_minutes == 30 {
			return resolve_unit(total_hours, sd.hour, sd.locale, sd.half)
		}
		mut result := resolve_unit(total_hours, sd.hour, sd.locale, '')
		if remainder_minutes > 0 {
			result += sd.delimiter + resolve_unit(remainder_minutes, sd.minute, sd.locale, '')
		}
		return result
	}

	// 6-23 hours
	if total_hours < 24 {
		return resolve_unit(total_hours, sd.hour, sd.locale, '')
	}

	total_days := int(total / 86400)
	remainder_hours := int((total % 86400) / 3600)

	// 1-2 days: days + hours (with half marker)
	if total_days <= 2 {
		if remainder_hours == 12 {
			return resolve_unit(total_days, sd.day, sd.locale, sd.half)
		}
		mut result := resolve_unit(total_days, sd.day, sd.locale, '')
		if remainder_hours > 0 {
			result += sd.delimiter + resolve_unit(remainder_hours, sd.hour, sd.locale, '')
		}
		return result
	}

	// 3-6 days
	if total_days < 7 {
		return resolve_unit(total_days, sd.day, sd.locale, '')
	}

	total_weeks := total_days / 7
	remainder_days := total_days % 7

	// 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
	if total_days < 30 {
		mut result := resolve_unit(total_weeks, sd.week, sd.locale, '')
		if remainder_days > 0 {
			result += sd.delimiter + resolve_unit(remainder_days, sd.day, sd.locale, '')
		}
		return result
	}

	// Approximate months (30.44 days average)
	mut total_months := int(approximate_months(total_days))

	// 1-11 months
	if total_months < 12 {
		if total_months == 0 {
			total_months = 1
		}
		return resolve_unit(total_months, sd.month, sd.locale, '')
	}

	// 12+ months: years + months
	total_years := total_months / 12
	remainder_months := total_months % 12
	mut result := resolve_unit(total_years, sd.year, sd.locale, '')
	if remainder_months > 0 {
		result += sd.delimiter + resolve_unit(remainder_months, sd.month, sd.locale, '')
	}
	return result
}

fn resolve_unit(count int, uf UnitForms, loc &DurationLocale, half string) string {
	base_n := count.str()

	// Apply {n}-style half marker to the number
	mut n := base_n
	if half.len > 0 && half.contains('{n}') {
		n = half.replace('{n}', base_n)
	}

	// Select template — half forces "other" plural
	mut tmpl := ''
	if uf.simple.len > 0 {
		tmpl = uf.simple
	} else {
		cat := if half.len > 0 { PluralCategory.other } else { loc.plural(count) }
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

// digit_run returns the number of leading ASCII digits in s.
fn digit_run(s string) int {
	mut n := 0
	for n < s.len && s[n] >= `0` && s[n] <= `9` {
		n++
	}
	return n
}

// is_zone_suffix reports whether s is empty, "Z", or "+HH:MM" / "-HH:MM".
fn is_zone_suffix(s string) bool {
	if s.len == 0 {
		return true
	}
	if s.len == 1 {
		return s[0] == `Z`
	}
	return s.len == 6 && (s[0] == `+` || s[0] == `-`) && digit_run(s[1..3]) == 2 && s[3] == `:`
		&& digit_run(s[4..6]) == 2
}

// parse_clock parses H:MM or HH:MM, optional :SS, optional . plus digits after
// the seconds, and an optional zone suffix, which is validated but ignored,
// into (hour, minute, second).
fn parse_clock(clock string) ?(int, int, int) {
	hour_len := digit_run(clock)
	if hour_len < 1 || hour_len > 2 || clock.len < hour_len + 3 || clock[hour_len] != `:`
		|| digit_run(clock[hour_len + 1..hour_len + 3]) != 2 {
		return none
	}
	hour := str_to_int(clock[..hour_len]) or { return none }
	minute := str_to_int(clock[hour_len + 1..hour_len + 3]) or { return none }
	mut second := 0
	mut rest := clock[hour_len + 3..]
	if rest.len > 0 && rest[0] == `:` {
		if rest.len < 3 || digit_run(rest[1..3]) != 2 {
			return none
		}
		second = str_to_int(rest[1..3]) or { return none }
		rest = rest[3..]
		if rest.len > 0 && rest[0] == `.` {
			fraction_len := digit_run(rest[1..])
			if fraction_len == 0 {
				return none
			}
			rest = rest[1 + fraction_len..]
		}
	}
	if !is_zone_suffix(rest) || hour > 23 || minute > 59 || second > 59 {
		return none
	}
	return hour, minute, second
}

// str_to_int converts a non-empty run of ASCII digits; none if any isn't a digit.
fn str_to_int(s string) ?int {
	if s.len == 0 {
		return none
	}
	mut n := 0
	for c in s {
		if c < `0` || c > `9` {
			return none
		}
		n = n * 10 + int(c - `0`)
	}
	return n
}

// parse_iso_to_seconds parses a timestamp YYYY-MM-DDTHH:MM[:SS[.fff]][zone]
// (docs/input-formats.md) to seconds since 2000-01-01 for diffing.
fn parse_iso_to_seconds(iso_str string) ?i64 {
	if iso_str.len < 11 || iso_str[4] != `-` || iso_str[7] != `-` || iso_str[10] != `T` {
		return none
	}
	year := str_to_int(iso_str[0..4]) or { return none }
	month := str_to_int(iso_str[5..7]) or { return none }
	day := str_to_int(iso_str[8..10]) or { return none }
	if month < 1 || month > 12 || day < 1 || day > days_in_month(year, month) {
		return none
	}
	hour, minute, second := parse_clock(iso_str[11..]) or { return none }
	return days_since_epoch(year, month, day) * 86400 + i64(hour) * 3600 + i64(minute) * 60 +
		i64(second)
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

fn days_since_epoch(year int, month int, day int) i64 {
	mut days := i64(0)
	if year >= 2000 {
		for y in 2000 .. year {
			days += if is_leap_year(y) { 366 } else { 365 }
		}
	} else {
		for y in year .. 2000 {
			days -= if is_leap_year(y) { 366 } else { 365 }
		}
	}
	for m in 1 .. month {
		days += days_in_month(year, m)
	}
	days += day - 1
	return days
}
