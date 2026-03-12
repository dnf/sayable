/// Core formatting logic for sayable-duration.

import gleam/int
import gleam/string
import sayableduration/types.{
  type Compactness, type DurationLocale,
  type PluralCategory, type UnitForms, Compact, Normal, Other, PluralUnit,
  Short, SimpleUnit,
}

pub const version = "0.5.0"

// --- Public API ---

pub fn format_duration_seconds(
  locale: DurationLocale,
  compactness: Compactness,
  seconds: Int,
) -> Result(String, Nil) {
  case seconds < 0 {
    True -> Error(Nil)
    False -> {
      let resolved = resolve_locale(locale, compactness)
      Ok(do_format_duration(locale, resolved, seconds))
    }
  }
}

pub fn format_duration_timestamps(
  locale: DurationLocale,
  compactness: Compactness,
  start: String,
  end: String,
) -> Result(String, Nil) {
  case start == "" || end == "" {
    True -> Error(Nil)
    False -> {
      use s <- try_parse_iso(start)
      use e <- try_parse_iso(end)
      let total = abs_int(e - s)
      let resolved = resolve_locale(locale, compactness)
      Ok(do_format_duration(locale, resolved, total))
    }
  }
}

pub fn format_since(
  locale: DurationLocale,
  compactness: Compactness,
  start: String,
  as_of: String,
) -> Result(String, Nil) {
  case start == "" || as_of == "" {
    True -> Error(Nil)
    False -> {
      use s <- try_parse_iso(start)
      use a <- try_parse_iso(as_of)
      let diff = a - s
      case diff < 0 {
        True -> Error(Nil)
        False -> {
          let resolved = resolve_locale(locale, compactness)
          case diff == 0 {
            True -> Ok(resolved.just_now)
            False -> {
              let dur = do_format_duration(locale, resolved, diff)
              Ok(string.replace(resolved.ago, "{0}", dur))
            }
          }
        }
      }
    }
  }
}

pub fn format_until(
  locale: DurationLocale,
  compactness: Compactness,
  target: String,
  as_of: String,
) -> Result(String, Nil) {
  case target == "" || as_of == "" {
    True -> Error(Nil)
    False -> {
      use t <- try_parse_iso(target)
      use a <- try_parse_iso(as_of)
      let diff = t - a
      case diff < 0 {
        True -> Error(Nil)
        False -> {
          let resolved = resolve_locale(locale, compactness)
          case diff == 0 {
            True -> Ok(resolved.just_now)
            False -> {
              let dur = do_format_duration(locale, resolved, diff)
              Ok(string.replace(resolved.in_future, "{0}", dur))
            }
          }
        }
      }
    }
  }
}

// --- Resolved locale ---

type ResolvedLocale {
  ResolvedLocale(
    units: List(#(String, UnitForms)),
    half: String,
    delimiter: String,
    just_now: String,
    ago: String,
    in_future: String,
  )
}

fn resolve_locale(locale: DurationLocale, compactness: Compactness) -> ResolvedLocale {
  let ovr = case compactness {
    Normal -> Error(Nil)
    Short -> locale.short
    Compact -> locale.compact
  }
  case ovr {
    Error(Nil) ->
      ResolvedLocale(
        units: locale.units,
        half: locale.half,
        delimiter: locale.delimiter,
        just_now: locale.just_now,
        ago: locale.ago,
        in_future: locale.in_future,
      )
    Ok(o) ->
      ResolvedLocale(
        units: result_unwrap_units(o.units, locale.units),
        half: result_unwrap_string(o.half, locale.half),
        delimiter: result_unwrap_string(o.delimiter, locale.delimiter),
        just_now: locale.just_now,
        ago: result_unwrap_string(o.ago, locale.ago),
        in_future: result_unwrap_string(o.in_future, locale.in_future),
      )
  }
}

fn result_unwrap_string(r: Result(String, Nil), default: String) -> String {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

fn result_unwrap_units(
  r: Result(List(#(String, UnitForms)), Nil),
  default: List(#(String, UnitForms)),
) -> List(#(String, UnitForms)) {
  case r {
    Ok(ovr_units) -> merge_units(default, ovr_units)
    Error(Nil) -> default
  }
}

fn merge_units(
  base: List(#(String, UnitForms)),
  overrides: List(#(String, UnitForms)),
) -> List(#(String, UnitForms)) {
  case base {
    [] -> []
    [#(name, forms), ..rest] -> {
      let merged_forms = case find_unit(overrides, name) {
        Ok(ovr_forms) -> ovr_forms
        Error(Nil) -> forms
      }
      [#(name, merged_forms), ..merge_units(rest, overrides)]
    }
  }
}

fn find_unit(
  units: List(#(String, UnitForms)),
  name: String,
) -> Result(UnitForms, Nil) {
  case units {
    [] -> Error(Nil)
    [#(n, forms), ..rest] ->
      case n == name {
        True -> Ok(forms)
        False -> find_unit(rest, name)
      }
  }
}

// --- Duration tiers ---

fn do_format_duration(
  locale: DurationLocale,
  resolved: ResolvedLocale,
  total: Int,
) -> String {
  // 0 seconds
  case total == 0 {
    True -> resolved.just_now
    False ->
      // 1-59 seconds
      case total < 60 {
        True -> resolve_unit(total, get_unit(resolved.units, "second"), locale.plural, "")
        False -> {
          let total_minutes = total / 60
          let remainder_seconds = total % 60
          // 1-4 minutes: minutes + seconds
          case total_minutes < 5 {
            True -> {
              let result = resolve_unit(total_minutes, get_unit(resolved.units, "minute"), locale.plural, "")
              case remainder_seconds > 0 {
                True -> result <> resolved.delimiter <> resolve_unit(remainder_seconds, get_unit(resolved.units, "second"), locale.plural, "")
                False -> result
              }
            }
            False ->
              // 5-59 minutes
              case total_minutes < 60 {
                True -> resolve_unit(total_minutes, get_unit(resolved.units, "minute"), locale.plural, "")
                False -> {
                  let total_hours = total / 3600
                  let remainder_minutes = { total % 3600 } / 60
                  // 1-5 hours
                  case total_hours <= 5 {
                    True ->
                      case remainder_minutes == 30 {
                        True -> resolve_unit(total_hours, get_unit(resolved.units, "hour"), locale.plural, resolved.half)
                        False -> {
                          let result = resolve_unit(total_hours, get_unit(resolved.units, "hour"), locale.plural, "")
                          case remainder_minutes > 0 {
                            True -> result <> resolved.delimiter <> resolve_unit(remainder_minutes, get_unit(resolved.units, "minute"), locale.plural, "")
                            False -> result
                          }
                        }
                      }
                    False ->
                      // 6-23 hours
                      case total_hours < 24 {
                        True -> resolve_unit(total_hours, get_unit(resolved.units, "hour"), locale.plural, "")
                        False -> {
                          let total_days = total / 86_400
                          let remainder_hours = { total % 86_400 } / 3600
                          // 1-2 days
                          case total_days <= 2 {
                            True ->
                              case remainder_hours == 12 {
                                True -> resolve_unit(total_days, get_unit(resolved.units, "day"), locale.plural, resolved.half)
                                False -> {
                                  let result = resolve_unit(total_days, get_unit(resolved.units, "day"), locale.plural, "")
                                  case remainder_hours > 0 {
                                    True -> result <> resolved.delimiter <> resolve_unit(remainder_hours, get_unit(resolved.units, "hour"), locale.plural, "")
                                    False -> result
                                  }
                                }
                              }
                            False ->
                              // 3-6 days
                              case total_days < 7 {
                                True -> resolve_unit(total_days, get_unit(resolved.units, "day"), locale.plural, "")
                                False -> {
                                  let total_weeks = total_days / 7
                                  let remainder_days = total_days % 7
                                  // 1-4 weeks (up to 29 days)
                                  case total_days < 30 {
                                    True -> {
                                      let result = resolve_unit(total_weeks, get_unit(resolved.units, "week"), locale.plural, "")
                                      case remainder_days > 0 {
                                        True -> result <> resolved.delimiter <> resolve_unit(remainder_days, get_unit(resolved.units, "day"), locale.plural, "")
                                        False -> result
                                      }
                                    }
                                    False -> {
                                      let total_months = round_div(total_days * 100, 3044)
                                      let clamped_months = case total_months < 1 {
                                        True -> 1
                                        False -> total_months
                                      }
                                      case clamped_months < 12 {
                                        True -> resolve_unit(clamped_months, get_unit(resolved.units, "month"), locale.plural, "")
                                        False -> {
                                          let total_years = clamped_months / 12
                                          let remainder_months = clamped_months % 12
                                          let result = resolve_unit(total_years, get_unit(resolved.units, "year"), locale.plural, "")
                                          case remainder_months > 0 {
                                            True -> result <> resolved.delimiter <> resolve_unit(remainder_months, get_unit(resolved.units, "month"), locale.plural, "")
                                            False -> result
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                          }
                        }
                      }
                  }
                }
              }
          }
        }
      }
  }
}

// --- Unit resolution ---

fn resolve_unit(
  count: Int,
  unit_forms: UnitForms,
  plural_fn: fn(Int) -> PluralCategory,
  half: String,
) -> String {
  let base_n = int.to_string(count)
  let n = case half != "" && string.contains(half, "{n}") {
    True -> string.replace(half, "{n}", base_n)
    False -> base_n
  }
  let template = case unit_forms {
    SimpleUnit(t) -> t
    PluralUnit(forms) -> {
      let category = case half != "" {
        True -> Other
        False -> plural_fn(count)
      }
      lookup_form(category, forms)
    }
  }
  let result = string.replace(template, "{n}", n)
  case half != "" && string.contains(half, "{0}") {
    True -> string.replace(half, "{0}", result)
    False -> result
  }
}

fn lookup_form(
  category: PluralCategory,
  forms: List(#(PluralCategory, String)),
) -> String {
  case find_in_list(forms, category) {
    Ok(val) -> val
    Error(Nil) ->
      case find_in_list(forms, Other) {
        Ok(val) -> val
        Error(Nil) -> ""
      }
  }
}

fn find_in_list(
  forms: List(#(PluralCategory, String)),
  target: PluralCategory,
) -> Result(String, Nil) {
  case forms {
    [] -> Error(Nil)
    [#(cat, val), ..rest] ->
      case cat == target {
        True -> Ok(val)
        False -> find_in_list(rest, target)
      }
  }
}

fn get_unit(units: List(#(String, UnitForms)), name: String) -> UnitForms {
  case units {
    [] -> SimpleUnit("")
    [#(n, forms), ..rest] ->
      case n == name {
        True -> forms
        False -> get_unit(rest, name)
      }
  }
}

// --- ISO timestamp parsing ---

fn try_parse_iso(
  s: String,
  continuation: fn(Int) -> Result(String, Nil),
) -> Result(String, Nil) {
  case parse_iso_to_seconds(s) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn parse_iso_to_seconds(iso_str: String) -> Result(Int, Nil) {
  case string.contains(iso_str, "T") {
    False -> Error(Nil)
    True -> {
      let parts = string.split(iso_str, "T")
      case parts {
        [date_part, time_part] -> {
          use #(year, month, day) <- try_parse_date(date_part)
          use #(hour, minute, second) <- try_parse_time_parts(time_part)
          let days = days_since_epoch(year, month, day)
          Ok(days * 86_400 + hour * 3600 + minute * 60 + second)
        }
        _ -> Error(Nil)
      }
    }
  }
}

fn try_parse_date(
  s: String,
  continuation: fn(#(Int, Int, Int)) -> Result(Int, Nil),
) -> Result(Int, Nil) {
  let parts = string.split(s, "-")
  case parts {
    [y_str, m_str, d_str] ->
      case int.parse(y_str), int.parse(m_str), int.parse(d_str) {
        Ok(y), Ok(m), Ok(d) -> continuation(#(y, m, d))
        _, _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn try_parse_time_parts(
  s: String,
  continuation: fn(#(Int, Int, Int)) -> Result(Int, Nil),
) -> Result(Int, Nil) {
  let t = case string.contains(s, "+") {
    True -> {
      let ps = string.split(s, "+")
      case ps {
        [first, ..] -> first
        _ -> s
      }
    }
    False -> s
  }
  let t2 = case string.contains(t, "Z") {
    True -> {
      let ps = string.split(t, "Z")
      case ps {
        [first, ..] -> first
        _ -> t
      }
    }
    False -> t
  }
  let parts = string.split(t2, ":")
  case parts {
    [h_str, m_str] ->
      case int.parse(h_str), int.parse(m_str) {
        Ok(h), Ok(m) -> continuation(#(h, m, 0))
        _, _ -> Error(Nil)
      }
    [h_str, m_str, s_str] -> {
      let s_clean = case string.contains(s_str, ".") {
        True -> {
          let ps = string.split(s_str, ".")
          case ps {
            [first, ..] -> first
            _ -> s_str
          }
        }
        False -> s_str
      }
      case int.parse(h_str), int.parse(m_str), int.parse(s_clean) {
        Ok(h), Ok(m), Ok(sec) -> continuation(#(h, m, sec))
        _, _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn days_since_epoch(year: Int, month: Int, day: Int) -> Int {
  let year_days = count_year_days(year)
  let month_days = count_month_days(year, month)
  year_days + month_days + day - 1
}

fn count_year_days(year: Int) -> Int {
  case year >= 2000 {
    True -> count_years_forward(2000, year, 0)
    False -> count_years_backward(year, 2000, 0)
  }
}

fn count_years_forward(from: Int, to: Int, acc: Int) -> Int {
  case from >= to {
    True -> acc
    False -> {
      let days = case is_leap_year(from) {
        True -> 366
        False -> 365
      }
      count_years_forward(from + 1, to, acc + days)
    }
  }
}

fn count_years_backward(from: Int, to: Int, acc: Int) -> Int {
  case from >= to {
    True -> acc
    False -> {
      let days = case is_leap_year(from) {
        True -> 366
        False -> 365
      }
      count_years_backward(from + 1, to, acc - days)
    }
  }
}

fn count_month_days(year: Int, month: Int) -> Int {
  count_month_days_loop(year, 1, month, 0)
}

fn count_month_days_loop(year: Int, current: Int, target: Int, acc: Int) -> Int {
  case current >= target {
    True -> acc
    False -> count_month_days_loop(year, current + 1, target, acc + days_in_month(year, current))
  }
}

fn is_leap_year(y: Int) -> Bool {
  { y % 4 == 0 && y % 100 != 0 } || y % 400 == 0
}

fn days_in_month(y: Int, m: Int) -> Int {
  case m {
    1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
    4 | 6 | 9 | 11 -> 30
    2 ->
      case is_leap_year(y) {
        True -> 29
        False -> 28
      }
    _ -> 30
  }
}

fn abs_int(n: Int) -> Int {
  case n < 0 {
    True -> -n
    False -> n
  }
}

fn round_div(numerator: Int, denominator: Int) -> Int {
  { numerator + denominator / 2 } / denominator
}
