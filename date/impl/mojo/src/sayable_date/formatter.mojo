"""Human-friendly date formatting."""

from .locale import DateLocale, CompactnessOverride
from .locales.en import build_en

alias VERSION = "0.5.0"


fn _str_replace(s: String, old: String, new: String) -> String:
    """Replace first occurrence of old with new in s."""
    var idx = s.find(old)
    if idx == -1:
        return s
    return s[:idx] + new + s[idx + len(old) :]


fn _char_to_digit(c: String) -> Int:
    """Convert a single character to its digit value, or -1 if not a digit."""
    if c == "0": return 0
    if c == "1": return 1
    if c == "2": return 2
    if c == "3": return 3
    if c == "4": return 4
    if c == "5": return 5
    if c == "6": return 6
    if c == "7": return 7
    if c == "8": return 8
    if c == "9": return 9
    return -1


struct ParsedDate(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Parsed date components."""

    var year: Int
    var month: Int
    var day: Int
    var valid: Bool

    fn __init__(out self):
        self.year = 0
        self.month = 0
        self.day = 0
        self.valid = False


fn _parse_date(s: String) -> ParsedDate:
    """Parse YYYY-MM-DD or ISO datetime to components. Returns invalid on failure."""
    var result = ParsedDate()
    if len(s) == 0:
        return result

    # Strip time part if ISO datetime
    var date_part = s
    var t_pos = s.find("T")
    if t_pos != -1:
        date_part = s[:t_pos]

    if len(date_part) < 10:
        return result
    if date_part[4:5] != "-" or date_part[7:8] != "-":
        return result

    var year = 0
    for i in range(4):
        var d = _char_to_digit(date_part[i : i + 1])
        if d < 0:
            return result
        year = year * 10 + d

    var month = 0
    for i in range(5, 7):
        var d = _char_to_digit(date_part[i : i + 1])
        if d < 0:
            return result
        month = month * 10 + d

    var day = 0
    for i in range(8, 10):
        var d = _char_to_digit(date_part[i : i + 1])
        if d < 0:
            return result
        day = day * 10 + d

    if month < 1 or month > 12 or day < 1 or day > 31:
        return result

    result.year = year
    result.month = month
    result.day = day
    result.valid = True
    return result


fn _to_jdn(year: Int, month: Int, day: Int) -> Int:
    """Convert a date to Julian Day Number for day-difference arithmetic."""
    var a = (14 - month) // 12
    var y = year + 4800 - a
    var m = month + 12 * a - 3
    return day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045


fn _weekday(year: Int, month: Int, day: Int) -> Int:
    """Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday."""
    var jdn = _to_jdn(year, month, day)
    return (jdn + 1) % 7


fn _zfill2(n: Int) -> String:
    """Zero-pad a number to 2 digits."""
    if n < 10:
        return "0" + String(n)
    return String(n)


struct SayableDate(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale-aware date formatter."""

    var locale: DateLocale
    var compactness: String
    # Effective fields (resolved from override)
    var eff_day_format: String
    var eff_date_pattern: String
    var eff_date_pattern_with_year: String
    var eff_today: String
    var eff_tomorrow: String
    var eff_yesterday: String
    var use_ovr_months: Bool
    var use_ovr_weekdays: Bool
    var use_ovr_exceptions: Bool
    var use_ovr_months_in_date: Bool
    var ovr: CompactnessOverride

    fn __init__(
        out self,
        locale: DateLocale,
        compactness: String = "normal",
    ):
        self.locale = locale
        self.compactness = compactness
        self.ovr = CompactnessOverride()
        self.use_ovr_months = False
        self.use_ovr_weekdays = False
        self.use_ovr_exceptions = False
        self.use_ovr_months_in_date = False

        var use_override = False
        if compactness == "short" and locale.has_short:
            self.ovr = locale.short_override
            use_override = True
        elif compactness == "compact" and locale.has_compact:
            self.ovr = locale.compact_override
            use_override = True

        if use_override and self.ovr.has_months:
            self.use_ovr_months = True
        if use_override and self.ovr.has_weekdays:
            self.use_ovr_weekdays = True
        if use_override and self.ovr.has_exceptions:
            self.use_ovr_exceptions = True
        if use_override and self.ovr.has_months_in_date:
            self.use_ovr_months_in_date = True

        if use_override and self.ovr.has_day_format:
            self.eff_day_format = self.ovr.day_format
            # When override sets day_format but not exceptions, clear exceptions
            if not self.ovr.has_exceptions:
                self.use_ovr_exceptions = True
                self.ovr.num_exceptions = 0
        else:
            self.eff_day_format = locale.day_format

        if use_override and self.ovr.has_date_pattern:
            self.eff_date_pattern = self.ovr.date_pattern
        else:
            self.eff_date_pattern = locale.date_pattern

        if use_override and self.ovr.has_date_pattern_with_year:
            self.eff_date_pattern_with_year = self.ovr.date_pattern_with_year
        else:
            self.eff_date_pattern_with_year = locale.date_pattern_with_year

        if use_override and self.ovr.has_today:
            self.eff_today = self.ovr.today
        else:
            self.eff_today = locale.today

        if use_override and self.ovr.has_tomorrow:
            self.eff_tomorrow = self.ovr.tomorrow
        else:
            self.eff_tomorrow = locale.tomorrow

        if use_override and self.ovr.has_yesterday:
            self.eff_yesterday = self.ovr.yesterday
        else:
            self.eff_yesterday = locale.yesterday

    fn _get_month(self, idx: Int) -> String:
        if self.use_ovr_months:
            return self.ovr.get_month(idx)
        return self.locale.get_month(idx)

    fn _get_weekday(self, idx: Int) -> String:
        if self.use_ovr_weekdays:
            return self.ovr.get_weekday(idx)
        return self.locale.get_weekday(idx)

    fn _get_month_in_date(self, idx: Int) -> String:
        if self.use_ovr_months_in_date:
            return self.ovr.get_month_in_date(idx)
        if self.locale.has_months_in_date:
            return self.locale.get_month_in_date(idx)
        return self._get_month(idx)

    fn _get_day_format(self, day_str: String) -> String:
        """Get day format, checking exceptions first."""
        if self.use_ovr_exceptions:
            # Use override exceptions (may be empty = no exceptions)
            for i in range(self.ovr.num_exceptions):
                var exc = self.ovr.get_exception(i)
                if exc.key == day_str:
                    return exc.fmt
            return self.eff_day_format
        # Use locale exceptions
        var exc_fmt = self.locale.get_exception_format(day_str)
        if len(exc_fmt) > 0:
            return exc_fmt
        return self.eff_day_format

    fn format_date(self, date: String) -> String:
        """Format a calendar date in locale-appropriate form.

        Returns empty string if input is invalid.
        """
        if len(date) == 0:
            return ""
        var parsed = _parse_date(date)
        if not parsed.valid:
            return ""
        return self._format_absolute(parsed.year, parsed.month, parsed.day, False)

    fn format_date_with_year(self, date: String) -> String:
        """Format a calendar date with year in locale-appropriate form."""
        if len(date) == 0:
            return ""
        var parsed = _parse_date(date)
        if not parsed.valid:
            return ""
        return self._format_absolute(parsed.year, parsed.month, parsed.day, True)

    fn format_relative(self, date: String, as_of: String) -> String:
        """Format a date relative to as_of.

        Returns empty string if either input is invalid.
        """
        if len(date) == 0 or len(as_of) == 0:
            return ""
        var parsed_date = _parse_date(date)
        var parsed_as_of = _parse_date(as_of)
        if not parsed_date.valid or not parsed_as_of.valid:
            return ""

        var date_jdn = _to_jdn(parsed_date.year, parsed_date.month, parsed_date.day)
        var asof_jdn = _to_jdn(parsed_as_of.year, parsed_as_of.month, parsed_as_of.day)
        var diff = date_jdn - asof_jdn

        # Today
        if diff == 0:
            return self.eff_today

        # Tomorrow
        if diff == 1:
            return self.eff_tomorrow

        # Yesterday
        if diff == -1:
            return self.eff_yesterday

        var is_compact = self.compactness == "compact"

        # Day after tomorrow (optional)
        if diff == 2 and len(self.locale.day_after_tomorrow) > 0 and not is_compact:
            return self.locale.day_after_tomorrow

        # Day before yesterday (optional)
        if diff == -2 and len(self.locale.day_before_yesterday) > 0 and not is_compact:
            return self.locale.day_before_yesterday

        # Compact mode: skip weekday references
        if is_compact:
            var include_year = parsed_date.year != parsed_as_of.year
            return self._format_absolute(parsed_date.year, parsed_date.month, parsed_date.day, include_year)

        # This weekday (+2 to +6)
        if 2 <= diff <= 6 and len(self.locale.this_weekday) > 0:
            var dow = _weekday(parsed_date.year, parsed_date.month, parsed_date.day)
            var weekday_name = self._get_weekday(dow)
            return _str_replace(self.locale.this_weekday, "{weekday}", weekday_name)

        # Last weekday (-2 to -6)
        if -6 <= diff <= -2 and len(self.locale.last_weekday) > 0:
            var dow = _weekday(parsed_date.year, parsed_date.month, parsed_date.day)
            var weekday_name = self._get_weekday(dow)
            return _str_replace(self.locale.last_weekday, "{weekday}", weekday_name)

        # Next weekday (+7 to +13)
        if 7 <= diff <= 13 and len(self.locale.next_weekday) > 0:
            var dow = _weekday(parsed_date.year, parsed_date.month, parsed_date.day)
            var weekday_name = self._get_weekday(dow)
            return _str_replace(self.locale.next_weekday, "{weekday}", weekday_name)

        # Calendar fallback
        var include_year = parsed_date.year != parsed_as_of.year
        return self._format_absolute(parsed_date.year, parsed_date.month, parsed_date.day, include_year)

    fn _format_absolute(self, year: Int, month: Int, day: Int, include_year: Bool) -> String:
        """Format a date as an absolute calendar reference."""
        var day_str = String(day)
        var fmt = self._get_day_format(day_str)
        var formatted_day = _str_replace(fmt, "{n}", day_str)

        var month_name = self._get_month_in_date(month - 1)

        var pattern: String
        if include_year:
            pattern = self.eff_date_pattern_with_year
        else:
            pattern = self.eff_date_pattern

        var result = _str_replace(pattern, "{month}", month_name)
        result = _str_replace(result, "{day}", formatted_day)
        result = _str_replace(result, "{d}", String(day))
        result = _str_replace(result, "{m}", String(month))
        if include_year:
            result = _str_replace(result, "{year}", String(year))
            var yy = year % 100
            result = _str_replace(result, "{yy}", _zfill2(yy))

        return result


fn format_date(date: String) -> String:
    """Format date using the default English locale."""
    var sd = SayableDate(build_en())
    return sd.format_date(date)


fn format_relative(date: String, as_of: String) -> String:
    """Format relative date using the default English locale."""
    var sd = SayableDate(build_en())
    return sd.format_relative(date, as_of)
