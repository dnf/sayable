module locales

// SayableTime is a locale-aware clock time formatter.
pub struct SayableTime {
	locale      &TimeLocale = unsafe { nil }
	compactness Compactness
	short_clock ShortClockConfig
	has_short   bool
}

// new_sayable_time creates a new SayableTime instance.
pub fn new_sayable_time(locale &TimeLocale, compactness Compactness) SayableTime {
	mut short_clock := ShortClockConfig{}
	mut has_short := false

	if compactness == .short && locale.has_short {
		short_clock = locale.short_override.clock
		has_short = true
	} else if compactness == .compact && locale.has_compact {
		short_clock = locale.compact_override.clock
		has_short = true
	}

	return SayableTime{
		locale: locale
		compactness: compactness
		short_clock: short_clock
		has_short: has_short
	}
}

// format_time formats a time string as natural language clock reading.
pub fn (st &SayableTime) format_time(input_str string) ?string {
	if input_str.len == 0 {
		return none
	}
	hour, minute := parse_time(input_str) or { return none }

	if st.compactness != .normal && st.has_short {
		return st.format_digital(hour, minute)
	}
	return st.format_natural(hour, minute)
}

fn (st &SayableTime) format_natural(hour int, minute int) string {
	clock := st.locale.clock
	rounded := round_to_5(minute)
	mut h := hour
	mut r := rounded
	if r == 60 {
		r = 0
		h = (h + 1) % 24
	}
	if r == 0 {
		if h == 0 {
			return clock.midnight
		}
		if h == 12 {
			return clock.noon
		}
	}
	h12 := h % 12
	next_h12 := (h + 1) % 12
	h_name := clock.hours[h12]
	next_h_name := clock.hours[next_h12]
	pattern := if r in clock.patterns {
		clock.patterns[r]
	} else if 0 in clock.patterns {
		clock.patterns[0]
	} else {
		'{h}'
	}
	return pattern.replace('{h}', h_name).replace('{next_h}', next_h_name)
}

fn (st &SayableTime) format_digital(hour int, minute int) string {
	sc := st.short_clock
	if sc.use24h {
		mut mm := minute.str()
		if minute < 10 {
			mm = '0${mm}'
		}
		return sc.format.replace('{h}', hour.str()).replace('{mm}', mm)
	}
	mut h12 := hour % 12
	if h12 == 0 {
		h12 = 12
	}
	mut am_str := 'AM'
	mut pm_str := 'PM'
	if sc.has_am_pm {
		am_str = sc.am
		pm_str = sc.pm
	}
	ampm_str := if hour < 12 { am_str } else { pm_str }
	mut mm := minute.str()
	if minute < 10 {
		mm = '0${mm}'
	}
	return sc.format.replace('{h}', h12.str()).replace('{mm}', mm).replace('{ampm}', ampm_str)
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

// days_in_month returns the days in a Gregorian month (leap years by the 4/100/400 rule).
fn days_in_month(y int, m int) int {
	return match m {
		2 { if (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 { 29 } else { 28 } }
		4, 6, 9, 11 { 30 }
		else { 31 }
	}
}

// is_real_date reports whether s is exactly YYYY-MM-DD naming a real calendar day.
fn is_real_date(s string) bool {
	if s.len != 10 || s[4] != `-` || s[7] != `-` {
		return false
	}
	y := str_to_int(s[0..4]) or { return false }
	m := str_to_int(s[5..7]) or { return false }
	d := str_to_int(s[8..10]) or { return false }
	return m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m)
}

// parse_time parses a clock time, alone or after the T of an ISO datetime whose
// date is valid, into (hour, minute) (docs/input-formats.md).
fn parse_time(input_str string) ?(int, int) {
	mut clock := input_str
	t_pos := input_str.index('T') or { -1 }
	if t_pos >= 0 {
		if !is_real_date(input_str[..t_pos]) {
			return none
		}
		clock = input_str[t_pos + 1..]
	}
	hour, minute, _ := parse_clock(clock) or { return none }
	return hour, minute
}

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

fn round_to_5(minute int) int {
	return ((minute + 2) / 5) * 5
}
