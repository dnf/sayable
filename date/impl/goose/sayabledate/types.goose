// sayable-date Goose implementation — types.

namespace sayabledate;

enum Compactness { Normal, Short, Compact }

// An ordinal day format that replaces the locale's default for one day
// of the month ("{n}st" for the 1st in English).
struct DayFormatException {
    day: i64,
    format: const u8[:],
}

// Locales without exceptions point here: a slice field needs static data
// to view, since a function returning a Locale cannot hand out a view of
// a temporary array literal.
let NO_DAY_FORMAT_EXCEPTIONS: DayFormatException[0] = [];

// A short or compact override. Every field is optional; the has_* flags
// keep "absent" distinct from a present value.
struct CompactnessOverride {
    has_months: bool = false,
    months: (const u8[:])[12] = [""; 12],
    has_months_in_date: bool = false,
    months_in_date: (const u8[:])[12] = [""; 12],
    has_weekdays: bool = false,
    weekdays: (const u8[:])[7] = [""; 7],
    has_day_format: bool = false,
    day_format: const u8[:] = "",
    has_day_format_exceptions: bool = false,
    day_format_exceptions: const DayFormatException[:] = NO_DAY_FORMAT_EXCEPTIONS,
    has_date_pattern: bool = false,
    date_pattern: const u8[:] = "",
    has_date_pattern_with_year: bool = false,
    date_pattern_with_year: const u8[:] = "",
    has_today: bool = false,
    today: const u8[:] = "",
    has_tomorrow: bool = false,
    tomorrow: const u8[:] = "",
    has_yesterday: bool = false,
    yesterday: const u8[:] = "",
}

// An empty optional phrase (day_after_tomorrow, this_weekday, ...) means
// the locale has no such tier.
struct DateLocale {
    code: const u8[:],
    months: (const u8[:])[12],
    weekdays: (const u8[:])[7],
    day_format: const u8[:],
    day_format_exceptions: const DayFormatException[:] = NO_DAY_FORMAT_EXCEPTIONS,
    date_pattern: const u8[:],
    date_pattern_with_year: const u8[:],
    today: const u8[:],
    tomorrow: const u8[:],
    yesterday: const u8[:],
    day_after_tomorrow: const u8[:] = "",
    day_before_yesterday: const u8[:] = "",
    this_weekday: const u8[:] = "",
    next_weekday: const u8[:] = "",
    last_weekday: const u8[:] = "",
    has_months_in_date: bool = false,
    months_in_date: (const u8[:])[12] = [""; 12],
    short_override: CompactnessOverride = CompactnessOverride { .. },
    compact_override: CompactnessOverride = CompactnessOverride { .. },
}
