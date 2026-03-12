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


fn _parse_int(s: String) -> Int:
    """Parse an integer from a string. Returns -1 on failure."""
    if len(s) == 0:
        return -1
    var result = 0
    for i in range(len(s)):
        var d = _char_to_digit(s[i : i + 1])
        if d < 0:
            return -1
        result = result * 10 + d
    return result


fn _split_at(s: String, delim: String) -> String:
    """Return substring before delimiter, or the whole string if not found."""
    var idx = s.find(delim)
    if idx == -1:
        return s
    return s[:idx]


fn _split_after(s: String, delim: String) -> String:
    """Return substring after delimiter, or empty if not found."""
    var idx = s.find(delim)
    if idx == -1:
        return ""
    return s[idx + len(delim) :]


struct ParsedTime(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Parsed time as (hour, minute)."""

    var hour: Int
    var minute: Int
    var valid: Bool

    fn __init__(out self):
        self.hour = 0
        self.minute = 0
        self.valid = False


fn _parse_time(input_str: String) -> ParsedTime:
    """Parse HH:MM or ISO datetime to (hour, minute)."""
    var result = ParsedTime()
    if len(input_str) == 0:
        return result

    var t = input_str
    # Strip ISO date part
    var t_pos = t.find("T")
    if t_pos != -1:
        t = t[t_pos + 1 :]

    # Strip timezone info
    t = _split_at(t, "+")
    t = _split_at(t, "Z")

    # Find colon separator
    var colon_pos = t.find(":")
    if colon_pos == -1:
        return result

    var hour_str = t[:colon_pos]
    var rest = t[colon_pos + 1 :]
    # Strip fractional seconds
    var min_str = _split_at(rest, ".")
    # Also strip seconds part if present
    var colon2 = min_str.find(":")
    if colon2 != -1:
        min_str = min_str[:colon2]

    var hour = _parse_int(hour_str)
    var minute = _parse_int(min_str)

    if hour < 0 or hour > 23 or minute < 0 or minute > 59:
        return result

    result.hour = hour
    result.minute = minute
    result.valid = True
    return result


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
