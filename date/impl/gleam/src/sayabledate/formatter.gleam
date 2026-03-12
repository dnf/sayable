/// Core formatting logic for sayable-date.

import gleam/int
import gleam/string
import sayabledate/types.{
  type Compactness, type DateLocale, Compact, Normal,
  Short,
}

pub const version = "0.5.0"

// --- Public API ---

pub fn format_date(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
) -> Result(String, Nil) {
  case date == "" {
    True -> Error(Nil)
    False -> {
      use #(y, m, d) <- try_parse(date)
      let resolved = resolve_locale(locale, compactness)
      Ok(format_absolute(resolved, y, m, d, False))
    }
  }
}

pub fn format_date_with_year(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
) -> Result(String, Nil) {
  case date == "" {
    True -> Error(Nil)
    False -> {
      use #(y, m, d) <- try_parse(date)
      let resolved = resolve_locale(locale, compactness)
      Ok(format_absolute(resolved, y, m, d, True))
    }
  }
}

pub fn format_relative(
  locale: DateLocale,
  compactness: Compactness,
  date: String,
  as_of: String,
) -> Result(String, Nil) {
  case date == "" || as_of == "" {
    True -> Error(Nil)
    False -> {
      use #(dy, dm, dd) <- try_parse(date)
      use #(ay, am, ad) <- try_parse_ref(as_of)
      let resolved = resolve_locale(locale, compactness)
      let date_jdn = to_jdn(dy, dm, dd)
      let asof_jdn = to_jdn(ay, am, ad)
      let diff = date_jdn - asof_jdn

      // Today
      case diff {
        0 -> Ok(resolved.today)
        1 -> Ok(resolved.tomorrow)
        -1 -> Ok(resolved.yesterday)
        _ -> format_relative_extended(locale, compactness, resolved, diff, dy, dm, dd, ay)
      }
    }
  }
}

// --- Resolved locale ---

type ResolvedLocale {
  ResolvedLocale(
    months: List(String),
    months_in_date: Result(List(String), Nil),
    weekdays: List(String),
    day_format: String,
    day_format_exceptions: List(#(String, String)),
    date_pattern: String,
    date_pattern_with_year: String,
    today: String,
    tomorrow: String,
    yesterday: String,
  )
}

fn resolve_locale(locale: DateLocale, compactness: Compactness) -> ResolvedLocale {
  let ovr = case compactness {
    Normal -> Error(Nil)
    Short -> locale.short
    Compact -> locale.compact
  }
  case ovr {
    Error(Nil) ->
      ResolvedLocale(
        months: locale.months,
        months_in_date: locale.months_in_date,
        weekdays: locale.weekdays,
        day_format: locale.day_format,
        day_format_exceptions: locale.day_format_exceptions,
        date_pattern: locale.date_pattern,
        date_pattern_with_year: locale.date_pattern_with_year,
        today: locale.today,
        tomorrow: locale.tomorrow,
        yesterday: locale.yesterday,
      )
    Ok(o) -> {
      let day_fmt = result_unwrap_string(o.day_format, locale.day_format)
      let exceptions = case o.day_format {
        Ok(_) ->
          case o.day_format_exceptions {
            Ok(e) -> e
            Error(Nil) -> []
          }
        Error(Nil) -> result_unwrap_exceptions(o.day_format_exceptions, locale.day_format_exceptions)
      }
      ResolvedLocale(
        months: result_unwrap_list(o.months, locale.months),
        months_in_date: pick_months_in_date(o.months_in_date, locale.months_in_date),
        weekdays: result_unwrap_list(o.weekdays, locale.weekdays),
        day_format: day_fmt,
        day_format_exceptions: exceptions,
        date_pattern: result_unwrap_string(o.date_pattern, locale.date_pattern),
        date_pattern_with_year: result_unwrap_string(o.date_pattern_with_year, locale.date_pattern_with_year),
        today: result_unwrap_string(o.today, locale.today),
        tomorrow: result_unwrap_string(o.tomorrow, locale.tomorrow),
        yesterday: result_unwrap_string(o.yesterday, locale.yesterday),
      )
    }
  }
}

fn result_unwrap_string(r: Result(String, Nil), default: String) -> String {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

fn result_unwrap_list(r: Result(List(String), Nil), default: List(String)) -> List(String) {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

fn result_unwrap_exceptions(
  r: Result(List(#(String, String)), Nil),
  default: List(#(String, String)),
) -> List(#(String, String)) {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

fn pick_months_in_date(
  ovr: Result(List(String), Nil),
  default: Result(List(String), Nil),
) -> Result(List(String), Nil) {
  case ovr {
    Ok(_) -> ovr
    Error(Nil) -> default
  }
}

// --- Formatting ---

fn format_absolute(
  resolved: ResolvedLocale,
  year: Int,
  month: Int,
  day: Int,
  include_year: Bool,
) -> String {
  let day_str = int.to_string(day)
  let fmt = find_exception(resolved.day_format_exceptions, day_str, resolved.day_format)
  let formatted_day = string.replace(fmt, "{n}", day_str)

  let month_names = case resolved.months_in_date {
    Ok(mid) -> mid
    Error(Nil) -> resolved.months
  }
  let month_name = list_at(month_names, month - 1)

  let pattern = case include_year {
    True -> resolved.date_pattern_with_year
    False -> resolved.date_pattern
  }
  let result =
    pattern
    |> string.replace("{month}", month_name)
    |> string.replace("{day}", formatted_day)
    |> string.replace("{d}", int.to_string(day))
    |> string.replace("{m}", int.to_string(month))
  case include_year {
    True ->
      result
      |> string.replace("{year}", int.to_string(year))
      |> string.replace("{yy}", pad2(year % 100))
    False -> result
  }
}

fn format_relative_extended(
  locale: DateLocale,
  compactness: Compactness,
  resolved: ResolvedLocale,
  diff: Int,
  dy: Int,
  dm: Int,
  dd: Int,
  ay: Int,
) -> Result(String, Nil) {
  let is_compact = compactness == Compact

  // Day after tomorrow (+2, optional)
  case diff == 2 && !is_compact {
    True ->
      case locale.day_after_tomorrow {
        Ok(s) -> Ok(s)
        Error(Nil) -> format_relative_weekday(locale, compactness, resolved, diff, dy, dm, dd, ay)
      }
    False ->
      // Day before yesterday (-2, optional)
      case diff == -2 && !is_compact {
        True ->
          case locale.day_before_yesterday {
            Ok(s) -> Ok(s)
            Error(Nil) -> format_relative_weekday(locale, compactness, resolved, diff, dy, dm, dd, ay)
          }
        False -> format_relative_weekday(locale, compactness, resolved, diff, dy, dm, dd, ay)
      }
  }
}

fn format_relative_weekday(
  locale: DateLocale,
  compactness: Compactness,
  resolved: ResolvedLocale,
  diff: Int,
  dy: Int,
  dm: Int,
  dd: Int,
  ay: Int,
) -> Result(String, Nil) {
  let is_compact = compactness == Compact

  // Compact mode: skip weekday references
  case is_compact {
    True -> {
      let include_year = dy != ay
      Ok(format_absolute(resolved, dy, dm, dd, include_year))
    }
    False -> {
      // This weekday (+2 to +6)
      case diff >= 2 && diff <= 6 {
        True ->
          case locale.this_weekday {
            Ok(pattern) -> {
              let dow = weekday(dy, dm, dd)
              let weekday_name = list_at(resolved.weekdays, dow)
              Ok(string.replace(pattern, "{weekday}", weekday_name))
            }
            Error(Nil) -> format_relative_calendar(resolved, diff, dy, dm, dd, ay)
          }
        False ->
          // Last weekday (-2 to -6)
          case diff >= -6 && diff <= -2 {
            True ->
              case locale.last_weekday {
                Ok(pattern) -> {
                  let dow = weekday(dy, dm, dd)
                  let weekday_name = list_at(resolved.weekdays, dow)
                  Ok(string.replace(pattern, "{weekday}", weekday_name))
                }
                Error(Nil) -> format_relative_calendar(resolved, diff, dy, dm, dd, ay)
              }
            False ->
              // Next weekday (+7 to +13)
              case diff >= 7 && diff <= 13 {
                True ->
                  case locale.next_weekday {
                    Ok(pattern) -> {
                      let dow = weekday(dy, dm, dd)
                      let weekday_name = list_at(resolved.weekdays, dow)
                      Ok(string.replace(pattern, "{weekday}", weekday_name))
                    }
                    Error(Nil) -> format_relative_calendar(resolved, diff, dy, dm, dd, ay)
                  }
                False -> format_relative_calendar(resolved, diff, dy, dm, dd, ay)
              }
          }
      }
    }
  }
}

fn format_relative_calendar(
  resolved: ResolvedLocale,
  _diff: Int,
  dy: Int,
  dm: Int,
  dd: Int,
  ay: Int,
) -> Result(String, Nil) {
  let include_year = dy != ay
  Ok(format_absolute(resolved, dy, dm, dd, include_year))
}

// --- Helpers ---

fn find_exception(
  exceptions: List(#(String, String)),
  key: String,
  default: String,
) -> String {
  case exceptions {
    [] -> default
    [#(k, v), ..rest] ->
      case k == key {
        True -> v
        False -> find_exception(rest, key, default)
      }
  }
}

fn list_at(items: List(String), index: Int) -> String {
  case items, index {
    [first, ..], 0 -> first
    [_, ..rest], n if n > 0 -> list_at(rest, n - 1)
    _, _ -> ""
  }
}

fn pad2(n: Int) -> String {
  case n < 10 {
    True -> "0" <> int.to_string(n)
    False -> int.to_string(n)
  }
}

// --- Date parsing ---

fn try_parse(
  s: String,
  continuation: fn(#(Int, Int, Int)) -> Result(String, Nil),
) -> Result(String, Nil) {
  case parse_date(s) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn try_parse_ref(
  s: String,
  continuation: fn(#(Int, Int, Int)) -> Result(String, Nil),
) -> Result(String, Nil) {
  case parse_date(s) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn parse_date(s: String) -> Result(#(Int, Int, Int), Nil) {
  let date_part = case string.contains(s, "T") {
    True -> {
      let parts = string.split(s, "T")
      case parts {
        [d, ..] -> d
        _ -> s
      }
    }
    False -> s
  }
  let parts = string.split(date_part, "-")
  case parts {
    [year_str, month_str, day_str] ->
      case int.parse(year_str), int.parse(month_str), int.parse(day_str) {
        Ok(y), Ok(m), Ok(d) ->
          case m >= 1 && m <= 12 && d >= 1 && d <= 31 {
            True -> Ok(#(y, m, d))
            False -> Error(Nil)
          }
        _, _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn to_jdn(y: Int, m: Int, d: Int) -> Int {
  let a = { 14 - m } / 12
  let yy = y + 4800 - a
  let mm = m + 12 * a - 3
  d + { 153 * mm + 2 } / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32_045
}

fn weekday(year: Int, month: Int, day: Int) -> Int {
  let jdn = to_jdn(year, month, day)
  { jdn + 1 } % 7
}
