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

fn parse_time(input_str string) ?(int, int) {
	if input_str.len == 0 {
		return none
	}
	mut t := input_str

	// Handle ISO datetime
	t_pos := t.index('T') or { -1 }
	if t_pos >= 0 {
		t = t[t_pos + 1..]
	}

	// Strip timezone
	plus_pos := t.index('+') or { -1 }
	if plus_pos >= 0 {
		t = t[..plus_pos]
	}
	z_pos := t.index('Z') or { -1 }
	if z_pos >= 0 {
		t = t[..z_pos]
	}

	parts := t.split(':')
	if parts.len < 2 {
		return none
	}

	hour := str_to_int(parts[0]) or { return none }
	// Handle fractional seconds in minute part
	min_str := parts[1]
	dot_pos := min_str.index('.') or { -1 }
	minute := if dot_pos >= 0 {
		str_to_int(min_str[..dot_pos]) or { return none }
	} else {
		str_to_int(min_str) or { return none }
	}

	if hour < 0 || hour > 23 || minute < 0 || minute > 59 {
		return none
	}
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
