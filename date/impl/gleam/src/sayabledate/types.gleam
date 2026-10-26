/// Types for the sayable-date locale system.
pub type Compactness {
  Normal
  Short
  Compact
}

pub type CompactnessOverride {
  CompactnessOverride(
    months: Result(List(String), Nil),
    months_in_date: Result(List(String), Nil),
    weekdays: Result(List(String), Nil),
    day_format: Result(String, Nil),
    day_format_exceptions: Result(List(#(String, String)), Nil),
    date_pattern: Result(String, Nil),
    date_pattern_with_year: Result(String, Nil),
    today: Result(String, Nil),
    tomorrow: Result(String, Nil),
    yesterday: Result(String, Nil),
  )
}

pub type DateLocale {
  DateLocale(
    code: String,
    months: List(String),
    weekdays: List(String),
    day_format: String,
    day_format_exceptions: List(#(String, String)),
    date_pattern: String,
    date_pattern_with_year: String,
    today: String,
    tomorrow: String,
    yesterday: String,
    day_after_tomorrow: Result(String, Nil),
    day_before_yesterday: Result(String, Nil),
    this_weekday: Result(String, Nil),
    next_weekday: Result(String, Nil),
    last_weekday: Result(String, Nil),
    months_in_date: Result(List(String), Nil),
    short: Result(CompactnessOverride, Nil),
    compact: Result(CompactnessOverride, Nil),
  )
}
