"""Human-friendly duration and relative time formatting."""

from .locale import (
    DurationLocale,
    CompactnessOverride,
    UnitForms,
    resolve_unit,
    _str_replace,
    _str_contains,
)
from .locales.en import build_en

alias VERSION = "0.5.0"

# 500 years, the same ceiling as sayable-age
alias MAX_DURATION_MONTHS = 6000


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


fn _is_leap_year(year: Int) -> Bool:
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)


fn _days_in_month(year: Int, month: Int) -> Int:
    if month == 2:
        if _is_leap_year(year):
            return 29
        return 28
    if month == 4 or month == 6 or month == 9 or month == 11:
        return 30
    return 31


fn _days_since_epoch(year: Int, month: Int, day: Int) -> Int:
    """Calculate days since reference epoch (2000-01-01)."""
    var days = 0
    if year >= 2000:
        var y = 2000
        while y < year:
            if _is_leap_year(y):
                days += 366
            else:
                days += 365
            y += 1
    else:
        var y = year
        while y < 2000:
            if _is_leap_year(y):
                days -= 366
            else:
                days -= 365
            y += 1
    var m = 1
    while m < month:
        days += _days_in_month(year, m)
        m += 1
    days += day - 1
    return days


struct ParsedISO(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Parsed ISO datetime as epoch seconds."""

    var seconds: Int
    var valid: Bool

    fn __init__(out self):
        self.seconds = 0
        self.valid = False


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


fn _parse_iso_to_seconds(iso_str: String) -> ParsedISO:
    """Parse YYYY-MM-DDTHH:MM[:SS[.fff]][zone] to epoch-ish seconds for diffing.

    The zone suffix is validated but not applied. Returns invalid if malformed.
    """
    var result = ParsedISO()
    if len(iso_str) < 11 or _char_at(iso_str, 10) != "T":
        return result
    if _char_at(iso_str, 4) != "-" or _char_at(iso_str, 7) != "-":
        return result
    var year = _number_at(iso_str, 0, 4)
    var month = _number_at(iso_str, 5, 2)
    var day = _number_at(iso_str, 8, 2)
    if year < 0 or month < 1 or month > 12 or day < 1 or day > _days_in_month(year, month):
        return result

    var hour_start = 11
    if _char_to_digit(_char_at(iso_str, hour_start)) < 0:
        return result
    var hour_len = 1
    if _char_to_digit(_char_at(iso_str, hour_start + 1)) >= 0:
        hour_len = 2
    var hour = _number_at(iso_str, hour_start, hour_len)
    var pos = hour_start + hour_len
    if _char_at(iso_str, pos) != ":":
        return result
    var minute = _number_at(iso_str, pos + 1, 2)
    if minute < 0:
        return result
    pos += 3
    var second = 0
    if _char_at(iso_str, pos) == ":":
        second = _number_at(iso_str, pos + 1, 2)
        if second < 0:
            return result
        pos += 3
        if _char_at(iso_str, pos) == ".":
            pos += 1
            var fraction_start = pos
            while _char_to_digit(_char_at(iso_str, pos)) >= 0:
                pos += 1
            if pos == fraction_start:
                return result
    if _zone_end(iso_str, pos) != len(iso_str):
        return result
    if hour > 23 or minute > 59 or second > 59:
        return result

    var days = _days_since_epoch(year, month, day)
    result.seconds = days * 86400 + hour * 3600 + minute * 60 + second
    result.valid = True
    return result


fn _pick_str(
    override: CompactnessOverride,
    has_override: Bool,
    field: String,
    default: String,
) -> String:
    """Pick override value if set, else default."""
    if not has_override:
        return default
    if field == "half" and override.has_half:
        return override.half
    if field == "delimiter" and override.has_delimiter:
        return override.delimiter
    if field == "ago" and override.has_ago:
        return override.ago
    if field == "in_future" and override.has_in_future:
        return override.in_future
    return default


struct SayableDuration(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale-aware duration and relative time formatter."""

    var locale: DurationLocale
    var second: UnitForms
    var minute: UnitForms
    var hour: UnitForms
    var day: UnitForms
    var week: UnitForms
    var month: UnitForms
    var year: UnitForms
    var half: String
    var delimiter: String
    var just_now: String
    var ago: String
    var in_future: String

    fn __init__(
        out self,
        locale: DurationLocale,
        compactness: String = "normal",
    ):
        var use_override = False
        var ovr = CompactnessOverride()

        if compactness == "short" and locale.has_short:
            ovr = locale.short_override
            use_override = True
        elif compactness == "compact" and locale.has_compact:
            ovr = locale.compact_override
            use_override = True

        if use_override:
            self.second = ovr.get_unit("second", locale.second)
            self.minute = ovr.get_unit("minute", locale.minute)
            self.hour = ovr.get_unit("hour", locale.hour)
            self.day = ovr.get_unit("day", locale.day)
            self.week = ovr.get_unit("week", locale.week)
            self.month = ovr.get_unit("month", locale.month)
            self.year = ovr.get_unit("year", locale.year)
        else:
            self.second = locale.second
            self.minute = locale.minute
            self.hour = locale.hour
            self.day = locale.day
            self.week = locale.week
            self.month = locale.month
            self.year = locale.year

        self.half = _pick_str(ovr, use_override, "half", locale.half)
        self.delimiter = _pick_str(ovr, use_override, "delimiter", locale.delimiter)
        self.just_now = locale.just_now
        self.ago = _pick_str(ovr, use_override, "ago", locale.ago)
        self.in_future = _pick_str(ovr, use_override, "in_future", locale.in_future)
        self.locale = locale

    fn format_duration_seconds(self, total_seconds: Int) -> String:
        """Format a duration from seconds."""
        if total_seconds < 0:
            return ""

        return self._format_duration_seconds(total_seconds)

    fn format_duration_iso(self, start: String, end: String) -> String:
        """Format a duration between two ISO timestamps."""
        if len(start) == 0 or len(end) == 0:
            return ""

        var s = _parse_iso_to_seconds(start)
        var e = _parse_iso_to_seconds(end)
        if not s.valid or not e.valid:
            return ""

        var diff = e.seconds - s.seconds
        if diff < 0:
            diff = -diff

        return self._format_duration_seconds(diff)

    fn format_since(self, start: String, as_of: String) -> String:
        """Format elapsed time as 'X ago'."""
        if len(start) == 0 or len(as_of) == 0:
            return ""

        var s = _parse_iso_to_seconds(start)
        var a = _parse_iso_to_seconds(as_of)
        if not s.valid or not a.valid:
            return ""

        var diff = a.seconds - s.seconds
        if diff < 0:
            return ""
        if diff == 0:
            return self.just_now

        var dur = self._format_duration_seconds(diff)
        if len(dur) == 0:
            return ""
        return _str_replace(self.ago, "{0}", dur)

    fn format_until(self, target: String, as_of: String) -> String:
        """Format time until a future event as 'in X'."""
        if len(target) == 0 or len(as_of) == 0:
            return ""

        var t = _parse_iso_to_seconds(target)
        var a = _parse_iso_to_seconds(as_of)
        if not t.valid or not a.valid:
            return ""

        var diff = t.seconds - a.seconds
        if diff < 0:
            return ""
        if diff == 0:
            return self.just_now

        var dur = self._format_duration_seconds(diff)
        if len(dur) == 0:
            return ""
        return _str_replace(self.in_future, "{0}", dur)

    fn _format_duration_seconds(self, total: Int) -> String:
        """Apply duration tiers to total seconds.

        Returns empty string past the 500-year ceiling.
        """
        # 0 seconds
        if total == 0:
            return self.just_now

        # 1-59 seconds
        if total < 60:
            return resolve_unit(total, self.second, self.locale)

        var total_minutes = total // 60
        var remainder_seconds = total % 60

        # 1-4 minutes: minutes + seconds
        if total_minutes < 5:
            var result = resolve_unit(total_minutes, self.minute, self.locale)
            if remainder_seconds > 0:
                result = result + self.delimiter + resolve_unit(remainder_seconds, self.second, self.locale)
            return result

        # 5-59 minutes
        if total_minutes < 60:
            return resolve_unit(total_minutes, self.minute, self.locale)

        var total_hours = total // 3600
        var remainder_minutes = (total % 3600) // 60

        # 1-5 hours: hours + minutes (with half marker)
        if total_hours <= 5:
            if remainder_minutes == 30:
                return resolve_unit(total_hours, self.hour, self.locale, self.half)
            var result = resolve_unit(total_hours, self.hour, self.locale)
            if remainder_minutes > 0:
                result = result + self.delimiter + resolve_unit(remainder_minutes, self.minute, self.locale)
            return result

        # 6-23 hours
        if total_hours < 24:
            return resolve_unit(total_hours, self.hour, self.locale)

        var total_days = total // 86400
        var remainder_hours = (total % 86400) // 3600

        # 1-2 days: days + hours (with half marker)
        if total_days <= 2:
            if remainder_hours == 12:
                return resolve_unit(total_days, self.day, self.locale, self.half)
            var result = resolve_unit(total_days, self.day, self.locale)
            if remainder_hours > 0:
                result = result + self.delimiter + resolve_unit(remainder_hours, self.hour, self.locale)
            return result

        # 3-6 days
        if total_days < 7:
            return resolve_unit(total_days, self.day, self.locale)

        var total_weeks = total_days // 7
        var remainder_days = total_days % 7

        # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if total_days < 30:
            var result = resolve_unit(total_weeks, self.week, self.locale)
            if remainder_days > 0:
                result = result + self.delimiter + resolve_unit(remainder_days, self.day, self.locale)
            return result

        # Approximate months (30.44 days average)
        # Use integer rounding: (total_days * 100 + 1522) // 3044
        var total_months = (total_days * 100 + 1522) // 3044
        if total_months > MAX_DURATION_MONTHS:
            return ""

        # 1-11 months
        if total_months < 12:
            if total_months == 0:
                total_months = 1
            return resolve_unit(total_months, self.month, self.locale)

        # 12+ months: years + months
        var total_years = total_months // 12
        var remainder_months = total_months % 12
        var result = resolve_unit(total_years, self.year, self.locale)
        if remainder_months > 0:
            result = result + self.delimiter + resolve_unit(remainder_months, self.month, self.locale)
        return result


fn format_duration(seconds: Int) -> String:
    """Format duration using the default English locale."""
    var sd = SayableDuration(build_en())
    return sd.format_duration_seconds(seconds)


fn format_since(start: String, as_of: String) -> String:
    """Format elapsed time using the default English locale."""
    var sd = SayableDuration(build_en())
    return sd.format_since(start, as_of)


fn format_until(target: String, as_of: String) -> String:
    """Format time until event using the default English locale."""
    var sd = SayableDuration(build_en())
    return sd.format_until(target, as_of)
