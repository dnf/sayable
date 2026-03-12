"""Locale definitions for date formatting."""


struct DayFormatException(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """A single day format exception mapping day string to format."""

    var key: String
    var fmt: String

    fn __init__(out self):
        self.key = ""
        self.fmt = ""


fn build_day_exception(key: String, fmt: String) -> DayFormatException:
    """Create a day format exception."""
    var exc = DayFormatException()
    exc.key = key
    exc.fmt = fmt
    return exc


struct CompactnessOverride(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Optional overrides for short/compact display modes."""

    var month0: String
    var month1: String
    var month2: String
    var month3: String
    var month4: String
    var month5: String
    var month6: String
    var month7: String
    var month8: String
    var month9: String
    var month10: String
    var month11: String
    var has_months: Bool
    var weekday0: String
    var weekday1: String
    var weekday2: String
    var weekday3: String
    var weekday4: String
    var weekday5: String
    var weekday6: String
    var has_weekdays: Bool
    var day_format: String
    var has_day_format: Bool
    var exc0: DayFormatException
    var exc1: DayFormatException
    var exc2: DayFormatException
    var exc3: DayFormatException
    var exc4: DayFormatException
    var exc5: DayFormatException
    var exc6: DayFormatException
    var exc7: DayFormatException
    var exc8: DayFormatException
    var exc9: DayFormatException
    var num_exceptions: Int
    var has_exceptions: Bool
    var date_pattern: String
    var has_date_pattern: Bool
    var date_pattern_with_year: String
    var has_date_pattern_with_year: Bool
    var today: String
    var has_today: Bool
    var tomorrow: String
    var has_tomorrow: Bool
    var yesterday: String
    var has_yesterday: Bool
    var month_in_date0: String
    var month_in_date1: String
    var month_in_date2: String
    var month_in_date3: String
    var month_in_date4: String
    var month_in_date5: String
    var month_in_date6: String
    var month_in_date7: String
    var month_in_date8: String
    var month_in_date9: String
    var month_in_date10: String
    var month_in_date11: String
    var has_months_in_date: Bool

    fn __init__(out self):
        self.month0 = ""
        self.month1 = ""
        self.month2 = ""
        self.month3 = ""
        self.month4 = ""
        self.month5 = ""
        self.month6 = ""
        self.month7 = ""
        self.month8 = ""
        self.month9 = ""
        self.month10 = ""
        self.month11 = ""
        self.has_months = False
        self.weekday0 = ""
        self.weekday1 = ""
        self.weekday2 = ""
        self.weekday3 = ""
        self.weekday4 = ""
        self.weekday5 = ""
        self.weekday6 = ""
        self.has_weekdays = False
        self.day_format = ""
        self.has_day_format = False
        self.exc0 = DayFormatException()
        self.exc1 = DayFormatException()
        self.exc2 = DayFormatException()
        self.exc3 = DayFormatException()
        self.exc4 = DayFormatException()
        self.exc5 = DayFormatException()
        self.exc6 = DayFormatException()
        self.exc7 = DayFormatException()
        self.exc8 = DayFormatException()
        self.exc9 = DayFormatException()
        self.num_exceptions = 0
        self.has_exceptions = False
        self.date_pattern = ""
        self.has_date_pattern = False
        self.date_pattern_with_year = ""
        self.has_date_pattern_with_year = False
        self.today = ""
        self.has_today = False
        self.tomorrow = ""
        self.has_tomorrow = False
        self.yesterday = ""
        self.has_yesterday = False
        self.month_in_date0 = ""
        self.month_in_date1 = ""
        self.month_in_date2 = ""
        self.month_in_date3 = ""
        self.month_in_date4 = ""
        self.month_in_date5 = ""
        self.month_in_date6 = ""
        self.month_in_date7 = ""
        self.month_in_date8 = ""
        self.month_in_date9 = ""
        self.month_in_date10 = ""
        self.month_in_date11 = ""
        self.has_months_in_date = False

    fn get_month(self, idx: Int) -> String:
        if idx == 0: return self.month0
        if idx == 1: return self.month1
        if idx == 2: return self.month2
        if idx == 3: return self.month3
        if idx == 4: return self.month4
        if idx == 5: return self.month5
        if idx == 6: return self.month6
        if idx == 7: return self.month7
        if idx == 8: return self.month8
        if idx == 9: return self.month9
        if idx == 10: return self.month10
        return self.month11

    fn get_weekday(self, idx: Int) -> String:
        if idx == 0: return self.weekday0
        if idx == 1: return self.weekday1
        if idx == 2: return self.weekday2
        if idx == 3: return self.weekday3
        if idx == 4: return self.weekday4
        if idx == 5: return self.weekday5
        return self.weekday6

    fn get_month_in_date(self, idx: Int) -> String:
        if idx == 0: return self.month_in_date0
        if idx == 1: return self.month_in_date1
        if idx == 2: return self.month_in_date2
        if idx == 3: return self.month_in_date3
        if idx == 4: return self.month_in_date4
        if idx == 5: return self.month_in_date5
        if idx == 6: return self.month_in_date6
        if idx == 7: return self.month_in_date7
        if idx == 8: return self.month_in_date8
        if idx == 9: return self.month_in_date9
        if idx == 10: return self.month_in_date10
        return self.month_in_date11

    fn get_exception(self, idx: Int) -> DayFormatException:
        if idx == 0: return self.exc0
        if idx == 1: return self.exc1
        if idx == 2: return self.exc2
        if idx == 3: return self.exc3
        if idx == 4: return self.exc4
        if idx == 5: return self.exc5
        if idx == 6: return self.exc6
        if idx == 7: return self.exc7
        if idx == 8: return self.exc8
        return self.exc9


fn build_compactness_override() -> CompactnessOverride:
    """Create a default compactness override."""
    return CompactnessOverride()


struct DateLocale(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale definition for date formatting."""

    var code: String
    var month0: String
    var month1: String
    var month2: String
    var month3: String
    var month4: String
    var month5: String
    var month6: String
    var month7: String
    var month8: String
    var month9: String
    var month10: String
    var month11: String
    var weekday0: String
    var weekday1: String
    var weekday2: String
    var weekday3: String
    var weekday4: String
    var weekday5: String
    var weekday6: String
    var day_format: String
    var exc0: DayFormatException
    var exc1: DayFormatException
    var exc2: DayFormatException
    var exc3: DayFormatException
    var exc4: DayFormatException
    var exc5: DayFormatException
    var exc6: DayFormatException
    var exc7: DayFormatException
    var exc8: DayFormatException
    var exc9: DayFormatException
    var num_exceptions: Int
    var date_pattern: String
    var date_pattern_with_year: String
    var today: String
    var tomorrow: String
    var yesterday: String
    var day_after_tomorrow: String
    var day_before_yesterday: String
    var this_weekday: String
    var next_weekday: String
    var last_weekday: String
    var month_in_date0: String
    var month_in_date1: String
    var month_in_date2: String
    var month_in_date3: String
    var month_in_date4: String
    var month_in_date5: String
    var month_in_date6: String
    var month_in_date7: String
    var month_in_date8: String
    var month_in_date9: String
    var month_in_date10: String
    var month_in_date11: String
    var has_months_in_date: Bool
    var short_override: CompactnessOverride
    var has_short: Bool
    var compact_override: CompactnessOverride
    var has_compact: Bool

    fn __init__(out self):
        self.code = ""
        self.month0 = ""
        self.month1 = ""
        self.month2 = ""
        self.month3 = ""
        self.month4 = ""
        self.month5 = ""
        self.month6 = ""
        self.month7 = ""
        self.month8 = ""
        self.month9 = ""
        self.month10 = ""
        self.month11 = ""
        self.weekday0 = ""
        self.weekday1 = ""
        self.weekday2 = ""
        self.weekday3 = ""
        self.weekday4 = ""
        self.weekday5 = ""
        self.weekday6 = ""
        self.day_format = ""
        self.exc0 = DayFormatException()
        self.exc1 = DayFormatException()
        self.exc2 = DayFormatException()
        self.exc3 = DayFormatException()
        self.exc4 = DayFormatException()
        self.exc5 = DayFormatException()
        self.exc6 = DayFormatException()
        self.exc7 = DayFormatException()
        self.exc8 = DayFormatException()
        self.exc9 = DayFormatException()
        self.num_exceptions = 0
        self.date_pattern = ""
        self.date_pattern_with_year = ""
        self.today = ""
        self.tomorrow = ""
        self.yesterday = ""
        self.day_after_tomorrow = ""
        self.day_before_yesterday = ""
        self.this_weekday = ""
        self.next_weekday = ""
        self.last_weekday = ""
        self.month_in_date0 = ""
        self.month_in_date1 = ""
        self.month_in_date2 = ""
        self.month_in_date3 = ""
        self.month_in_date4 = ""
        self.month_in_date5 = ""
        self.month_in_date6 = ""
        self.month_in_date7 = ""
        self.month_in_date8 = ""
        self.month_in_date9 = ""
        self.month_in_date10 = ""
        self.month_in_date11 = ""
        self.has_months_in_date = False
        self.short_override = CompactnessOverride()
        self.has_short = False
        self.compact_override = CompactnessOverride()
        self.has_compact = False

    fn get_month(self, idx: Int) -> String:
        if idx == 0: return self.month0
        if idx == 1: return self.month1
        if idx == 2: return self.month2
        if idx == 3: return self.month3
        if idx == 4: return self.month4
        if idx == 5: return self.month5
        if idx == 6: return self.month6
        if idx == 7: return self.month7
        if idx == 8: return self.month8
        if idx == 9: return self.month9
        if idx == 10: return self.month10
        return self.month11

    fn get_weekday(self, idx: Int) -> String:
        if idx == 0: return self.weekday0
        if idx == 1: return self.weekday1
        if idx == 2: return self.weekday2
        if idx == 3: return self.weekday3
        if idx == 4: return self.weekday4
        if idx == 5: return self.weekday5
        return self.weekday6

    fn get_month_in_date(self, idx: Int) -> String:
        if idx == 0: return self.month_in_date0
        if idx == 1: return self.month_in_date1
        if idx == 2: return self.month_in_date2
        if idx == 3: return self.month_in_date3
        if idx == 4: return self.month_in_date4
        if idx == 5: return self.month_in_date5
        if idx == 6: return self.month_in_date6
        if idx == 7: return self.month_in_date7
        if idx == 8: return self.month_in_date8
        if idx == 9: return self.month_in_date9
        if idx == 10: return self.month_in_date10
        return self.month_in_date11

    fn get_exception_format(self, day_str: String) -> String:
        """Look up day format exception. Returns empty string if not found."""
        for i in range(self.num_exceptions):
            if i == 0 and self.exc0.key == day_str: return self.exc0.fmt
            if i == 1 and self.exc1.key == day_str: return self.exc1.fmt
            if i == 2 and self.exc2.key == day_str: return self.exc2.fmt
            if i == 3 and self.exc3.key == day_str: return self.exc3.fmt
            if i == 4 and self.exc4.key == day_str: return self.exc4.fmt
            if i == 5 and self.exc5.key == day_str: return self.exc5.fmt
            if i == 6 and self.exc6.key == day_str: return self.exc6.fmt
            if i == 7 and self.exc7.key == day_str: return self.exc7.fmt
            if i == 8 and self.exc8.key == day_str: return self.exc8.fmt
            if i == 9 and self.exc9.key == day_str: return self.exc9.fmt
        return ""


fn build_date_locale(
    code: String,
    month0: String, month1: String, month2: String, month3: String,
    month4: String, month5: String, month6: String, month7: String,
    month8: String, month9: String, month10: String, month11: String,
    weekday0: String, weekday1: String, weekday2: String, weekday3: String,
    weekday4: String, weekday5: String, weekday6: String,
    day_format: String,
    num_exceptions: Int,
    date_pattern: String,
    date_pattern_with_year: String,
    today: String,
    tomorrow: String,
    yesterday: String,
    day_after_tomorrow: String = "",
    day_before_yesterday: String = "",
    this_weekday: String = "",
    next_weekday: String = "",
    last_weekday: String = "",
    has_months_in_date: Bool = False,
    month_in_date0: String = "",
    month_in_date1: String = "",
    month_in_date2: String = "",
    month_in_date3: String = "",
    month_in_date4: String = "",
    month_in_date5: String = "",
    month_in_date6: String = "",
    month_in_date7: String = "",
    month_in_date8: String = "",
    month_in_date9: String = "",
    month_in_date10: String = "",
    month_in_date11: String = "",
    exc0: DayFormatException = DayFormatException(),
    exc1: DayFormatException = DayFormatException(),
    exc2: DayFormatException = DayFormatException(),
    exc3: DayFormatException = DayFormatException(),
    exc4: DayFormatException = DayFormatException(),
    exc5: DayFormatException = DayFormatException(),
    exc6: DayFormatException = DayFormatException(),
    exc7: DayFormatException = DayFormatException(),
    exc8: DayFormatException = DayFormatException(),
    exc9: DayFormatException = DayFormatException(),
    short_override: CompactnessOverride = CompactnessOverride(),
    has_short: Bool = False,
    compact_override: CompactnessOverride = CompactnessOverride(),
    has_compact: Bool = False,
) -> DateLocale:
    """Build a DateLocale with all fields."""
    var loc = DateLocale()
    loc.code = code
    loc.month0 = month0
    loc.month1 = month1
    loc.month2 = month2
    loc.month3 = month3
    loc.month4 = month4
    loc.month5 = month5
    loc.month6 = month6
    loc.month7 = month7
    loc.month8 = month8
    loc.month9 = month9
    loc.month10 = month10
    loc.month11 = month11
    loc.weekday0 = weekday0
    loc.weekday1 = weekday1
    loc.weekday2 = weekday2
    loc.weekday3 = weekday3
    loc.weekday4 = weekday4
    loc.weekday5 = weekday5
    loc.weekday6 = weekday6
    loc.day_format = day_format
    loc.exc0 = exc0
    loc.exc1 = exc1
    loc.exc2 = exc2
    loc.exc3 = exc3
    loc.exc4 = exc4
    loc.exc5 = exc5
    loc.exc6 = exc6
    loc.exc7 = exc7
    loc.exc8 = exc8
    loc.exc9 = exc9
    loc.num_exceptions = num_exceptions
    loc.date_pattern = date_pattern
    loc.date_pattern_with_year = date_pattern_with_year
    loc.today = today
    loc.tomorrow = tomorrow
    loc.yesterday = yesterday
    loc.day_after_tomorrow = day_after_tomorrow
    loc.day_before_yesterday = day_before_yesterday
    loc.this_weekday = this_weekday
    loc.next_weekday = next_weekday
    loc.last_weekday = last_weekday
    loc.month_in_date0 = month_in_date0
    loc.month_in_date1 = month_in_date1
    loc.month_in_date2 = month_in_date2
    loc.month_in_date3 = month_in_date3
    loc.month_in_date4 = month_in_date4
    loc.month_in_date5 = month_in_date5
    loc.month_in_date6 = month_in_date6
    loc.month_in_date7 = month_in_date7
    loc.month_in_date8 = month_in_date8
    loc.month_in_date9 = month_in_date9
    loc.month_in_date10 = month_in_date10
    loc.month_in_date11 = month_in_date11
    loc.has_months_in_date = has_months_in_date
    loc.short_override = short_override
    loc.has_short = has_short
    loc.compact_override = compact_override
    loc.has_compact = has_compact
    return loc
