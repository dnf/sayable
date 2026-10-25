"""Human-friendly clock time formatting."""

from .locale import (
    TimeLocale,
    ClockConfig,
    ShortClockConfig,
    CompactnessOverride,
    _str_replace,
)
from .locales.en import build_en

alias VERSION = "0.5.0"


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


fn _char_at(s: String, i: Int) -> String:
    """Return the one-character string at byte i, or empty past the end."""
    if i < 0 or i >= len(s):
        return ""
    return String(s[i : i + 1])


fn _number_at(s: String, start: Int, count: Int) -> Int:
    """Parse count ASCII digits starting at start. Returns -1 on failure."""
    if start + count > len(s):
        return -1
    var result = 0
    for i in range(start, start + count):
        var d = _char_to_digit(_char_at(s, i))
        if d < 0:
            return -1
        result = result * 10 + d
    return result


fn _days_in_month(year: Int, month: Int) -> Int:
    if month == 2:
        if (year % 4 == 0 and year % 100 != 0) or year % 400 == 0:
            return 29
        return 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31


fn _is_real_date(s: String) -> Bool:
    """Return True if s is exactly YYYY-MM-DD naming a real calendar day."""
    if len(s) != 10 or _char_at(s, 4) != "-" or _char_at(s, 7) != "-":
        return False
    var year = _number_at(s, 0, 4)
    var month = _number_at(s, 5, 2)
    var day = _number_at(s, 8, 2)
    if year < 0 or month < 1 or month > 12:
        return False
    return day >= 1 and day <= _days_in_month(year, month)


fn _zone_end(s: String, start: Int) -> Int:
    """Return the index after an optional Z or +HH:MM/-HH:MM zone at start, or -1."""
    if start == len(s):
        return start
    var c = _char_at(s, start)
    if c == "Z":
        return start + 1
    if c != "+" and c != "-":
        return -1
    if _number_at(s, start + 1, 2) < 0 or _char_at(s, start + 3) != ":":
        return -1
    if _number_at(s, start + 4, 2) < 0:
        return -1
    return start + 6


struct ParsedTime(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Parsed time as (hour, minute)."""

    var hour: Int
    var minute: Int
    var valid: Bool

    fn __init__(out self):
        self.hour = 0
        self.minute = 0
        self.valid = False


fn _parse_clock(clock: String) -> ParsedTime:
    """Parse H:MM or HH:MM, optional :SS and fraction, optional zone (ignored)."""
    var result = ParsedTime()
    if _char_to_digit(_char_at(clock, 0)) < 0:
        return result
    var hour_len = 1
    if _char_to_digit(_char_at(clock, 1)) >= 0:
        hour_len = 2
    var hour = _number_at(clock, 0, hour_len)
    if _char_at(clock, hour_len) != ":":
        return result
    var minute = _number_at(clock, hour_len + 1, 2)
    if minute < 0:
        return result
    var pos = hour_len + 3
    var second = 0
    if _char_at(clock, pos) == ":":
        second = _number_at(clock, pos + 1, 2)
        if second < 0:
            return result
        pos += 3
        if _char_at(clock, pos) == ".":
            pos += 1
            var fraction_start = pos
            while _char_to_digit(_char_at(clock, pos)) >= 0:
                pos += 1
            if pos == fraction_start:
                return result
    if _zone_end(clock, pos) != len(clock):
        return result
    if hour > 23 or minute > 59 or second > 59:
        return result

    result.hour = hour
    result.minute = minute
    result.valid = True
    return result


fn _parse_time(input_str: String) -> ParsedTime:
    """Parse a clock time or ISO datetime to (hour, minute)."""
    var t_pos = input_str.find("T")
    if t_pos == -1:
        return _parse_clock(input_str)
    if not _is_real_date(String(input_str[:t_pos])):
        return ParsedTime()
    return _parse_clock(String(input_str[t_pos + 1 :]))


fn _round_to_5(minute: Int) -> Int:
    """Round minute to nearest 5."""
    return ((minute + 2) // 5) * 5


fn _zfill2(n: Int) -> String:
    """Zero-pad an integer to 2 digits."""
    if n < 10:
        return "0" + String(n)
    return String(n)


struct SayableTime(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale-aware clock time formatter."""

    var locale: TimeLocale
    var compactness: String
    var short_clock: ShortClockConfig
    var has_short_clock: Bool

    fn __init__(
        out self,
        locale: TimeLocale,
        compactness: String = "normal",
    ):
        self.locale = locale
        self.compactness = compactness
        self.short_clock = ShortClockConfig()
        self.has_short_clock = False

        if compactness == "short" and locale.has_short:
            if locale.short_override.has_clock:
                self.short_clock = locale.short_override.clock
                self.has_short_clock = True
        elif compactness == "compact" and locale.has_compact:
            if locale.compact_override.has_clock:
                self.short_clock = locale.compact_override.clock
                self.has_short_clock = True

    fn format_time(self, input_str: String) -> String:
        """Format a time as natural language clock reading.

        Returns empty string on invalid input.
        """
        if len(input_str) == 0:
            return ""

        var parsed = _parse_time(input_str)
        if not parsed.valid:
            return ""

        if self.compactness != "normal" and self.has_short_clock:
            return self._format_digital(parsed.hour, parsed.minute)
        return self._format_natural(parsed.hour, parsed.minute)

    fn _format_natural(self, hour: Int, minute: Int) -> String:
        var clock = self.locale.clock
        var rounded = _round_to_5(minute)
        var h = hour
        if rounded == 60:
            rounded = 0
            h = (h + 1) % 24

        if rounded == 0:
            if h == 0:
                return clock.midnight
            if h == 12:
                return clock.noon

        var h12 = h % 12
        var next_h12 = (h + 1) % 12
        var h_name = clock.get_hour(h12)
        var next_h_name = clock.get_hour(next_h12)

        var pattern = clock.get_pattern(rounded)
        if len(pattern) == 0:
            pattern = clock.get_pattern(0)

        var result = _str_replace(pattern, "{h}", h_name)
        result = _str_replace(result, "{next_h}", next_h_name)
        return result

    fn _format_digital(self, hour: Int, minute: Int) -> String:
        var sc = self.short_clock
        var fmt = sc.format

        if sc.use24h:
            var result = _str_replace(fmt, "{h}", String(hour))
            result = _str_replace(result, "{mm}", _zfill2(minute))
            return result

        var h12 = hour % 12
        if h12 == 0:
            h12 = 12

        var ampm_str: String
        if sc.has_am_pm:
            if hour < 12:
                ampm_str = sc.am
            else:
                ampm_str = sc.pm
        else:
            if hour < 12:
                ampm_str = "AM"
            else:
                ampm_str = "PM"

        var result = _str_replace(fmt, "{h}", String(h12))
        result = _str_replace(result, "{mm}", _zfill2(minute))
        result = _str_replace(result, "{ampm}", ampm_str)
        return result


fn format_time(input_str: String) -> String:
    """Format clock time using the default English locale."""
    var st = SayableTime(build_en())
    return st.format_time(input_str)
