/// Core formatting logic for parent-time.

import gleam/int
import gleam/string
import parenttime/types.{
  type AgeLocale, type Compactness, type CompactnessOverride, type Gender,
  type PluralCategory, type StageLabel, type UnitForms, Compact, Female,
  GenderedStage, NeutralStage, Normal, PluralUnit, Short, SimpleUnit,
}

const max_age_months = 6000

// --- Public API ---

pub fn format_age(
  locale: AgeLocale,
  compactness: Compactness,
  dob: String,
  as_of: String,
) -> Result(String, Nil) {
  use #(months, diff_days) <- try_compute_age(dob, as_of)
  case months > max_age_months {
    True -> Error(Nil)
    False -> {
      let #(day, week, month, year, half, delim, just_born) =
        resolve_locale(locale, compactness)
      Ok(format_tier(
        locale, day, week, month, year, half, delim, just_born, months,
        diff_days,
      ))
    }
  }
}

pub fn format_stage(
  locale: AgeLocale,
  dob: String,
  as_of: String,
  gender: Result(Gender, Nil),
) -> Result(String, Nil) {
  use #(months, _diff_days) <- try_compute_age(dob, as_of)
  let label = stage_label(months, locale)
  Ok(resolve_stage(label, gender))
}

// --- Locale resolution ---

fn resolve_locale(
  locale: AgeLocale,
  compactness: Compactness,
) -> #(UnitForms, UnitForms, UnitForms, UnitForms, String, String, String) {
  case compactness {
    Normal -> #(
      locale.day,
      locale.week,
      locale.month,
      locale.year,
      locale.half,
      locale.delimiter,
      locale.just_born,
    )
    Short -> apply_override(locale, locale.short)
    Compact -> apply_override(locale, locale.compact)
  }
}

fn apply_override(
  locale: AgeLocale,
  ovr_result: Result(CompactnessOverride, Nil),
) -> #(UnitForms, UnitForms, UnitForms, UnitForms, String, String, String) {
  case ovr_result {
    Error(Nil) -> #(
      locale.day,
      locale.week,
      locale.month,
      locale.year,
      locale.half,
      locale.delimiter,
      locale.just_born,
    )
    Ok(ovr) -> #(
      result_unwrap_unit(ovr.day, locale.day),
      result_unwrap_unit(ovr.week, locale.week),
      result_unwrap_unit(ovr.month, locale.month),
      result_unwrap_unit(ovr.year, locale.year),
      result_unwrap_string(ovr.half, locale.half),
      result_unwrap_string(ovr.delimiter, locale.delimiter),
      result_unwrap_string(ovr.just_born, locale.just_born),
    )
  }
}

fn result_unwrap_unit(r: Result(UnitForms, Nil), default: UnitForms) -> UnitForms {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

fn result_unwrap_string(r: Result(String, Nil), default: String) -> String {
  case r {
    Ok(v) -> v
    Error(Nil) -> default
  }
}

// --- Tier dispatch ---

fn format_tier(
  locale: AgeLocale,
  day: UnitForms,
  week: UnitForms,
  month: UnitForms,
  year: UnitForms,
  half: String,
  delim: String,
  just_born: String,
  months: Int,
  diff_days: Int,
) -> String {
  case diff_days, months {
    0, _ -> just_born
    d, _ if d < 7 -> resolve_unit(d, day, locale.plural, "")
    _, m if m < 3 -> {
      let weeks = diff_days / 7
      let days = diff_days % 7
      let w_str = resolve_unit(weeks, week, locale.plural, "")
      case days > 0 {
        True -> w_str <> delim <> resolve_unit(days, day, locale.plural, "")
        False -> w_str
      }
    }
    _, m if m < 24 -> resolve_unit(m, month, locale.plural, "")
    _, m if m < 36 -> {
      let years = m / 12
      let rem_months = m % 12
      let y_str = resolve_unit(years, year, locale.plural, "")
      case rem_months == 0 {
        True -> y_str
        False ->
          y_str <> delim <> resolve_unit(rem_months, month, locale.plural, "")
      }
    }
    _, m if m < 84 -> {
      let years = m / 12
      let rem_months = m % 12
      case rem_months >= 6 {
        True -> resolve_unit(years, year, locale.plural, half)
        False -> resolve_unit(years, year, locale.plural, "")
      }
    }
    _, m -> {
      let years = m / 12
      resolve_unit(years, year, locale.plural, "")
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
    PluralUnit(forms) -> lookup_form(plural_fn(count), forms)
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
      case find_in_list(forms, types.Other) {
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

// --- Stage label resolution ---

fn resolve_stage(label: StageLabel, gender: Result(Gender, Nil)) -> String {
  case label {
    NeutralStage(s) -> s
    GenderedStage(m, f) ->
      case gender {
        Ok(Female) -> f
        _ -> m
      }
  }
}

fn stage_label(months: Int, locale: AgeLocale) -> StageLabel {
  case months {
    m if m < 2 -> locale.newborn
    m if m < 12 -> locale.infant
    m if m < 36 -> locale.toddler
    m if m < 156 -> locale.child
    m if m < 216 -> locale.teenager
    _ -> locale.adult
  }
}

// --- Date computation ---

fn try_compute_age(
  dob: String,
  as_of: String,
  continuation: fn(#(Int, Int)) -> Result(String, Nil),
) -> Result(String, Nil) {
  case compute_age(dob, as_of) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn compute_age(dob: String, as_of: String) -> Result(#(Int, Int), Nil) {
  use #(dy, dm, dd) <- try_parse(dob)
  use #(ry, rm, rd) <- try_parse(as_of)
  let diff_days = days_between(dy, dm, dd, ry, rm, rd)
  case diff_days < 0 {
    True -> Error(Nil)
    False -> {
      let last_day = days_in_month(ry, rm)
      let clamped_birthday = int.min(dd, last_day)
      let months0 = { ry - dy } * 12 + { rm - dm }
      let months = case rd < clamped_birthday {
        True -> months0 - 1
        False -> months0
      }
      case months > max_age_months {
        True -> Error(Nil)
        False -> Ok(#(months, diff_days))
      }
    }
  }
}

fn try_parse(
  s: String,
  continuation: fn(#(Int, Int, Int)) -> Result(#(Int, Int), Nil),
) -> Result(#(Int, Int), Nil) {
  case parse_date(s) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn parse_date(s: String) -> Result(#(Int, Int, Int), Nil) {
  case string.length(s) >= 10 {
    False -> Error(Nil)
    True -> {
      let year_str = string.slice(s, 0, 4)
      let sep1 = string.slice(s, 4, 1)
      let month_str = string.slice(s, 5, 2)
      let sep2 = string.slice(s, 7, 1)
      let day_str = string.slice(s, 8, 2)
      case sep1 == "-" && sep2 == "-" {
        False -> Error(Nil)
        True ->
          case int.parse(year_str), int.parse(month_str), int.parse(day_str) {
            Ok(y), Ok(m), Ok(d) ->
              case y == 0 && m == 0 && d == 0 {
                True -> Error(Nil)
                False -> Ok(#(y, m, d))
              }
            _, _, _ -> Error(Nil)
          }
      }
    }
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

fn to_jdn(y: Int, m: Int, d: Int) -> Int {
  let a = { 14 - m } / 12
  let yy = y + 4800 - a
  let mm = m + 12 * a - 3
  d + { 153 * mm + 2 } / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32_045
}

fn days_between(y1: Int, m1: Int, d1: Int, y2: Int, m2: Int, d2: Int) -> Int {
  to_jdn(y2, m2, d2) - to_jdn(y1, m1, d1)
}
