/// Core formatting logic for sayable-time.

import gleam/int
import gleam/string
import sayabletime/types.{
  type Compactness, type ShortClockConfig,
  type TimeLocale, Compact, Normal, Short,
}

pub const version = "0.5.0"

// --- Public API ---

pub fn format_time(
  locale: TimeLocale,
  compactness: Compactness,
  input: String,
) -> Result(String, Nil) {
  case input == "" {
    True -> Error(Nil)
    False -> {
      use #(hour, minute) <- try_parse(input)
      let short_clock = resolve_short_clock(locale, compactness)
      case compactness != Normal {
        True ->
          case short_clock {
            Ok(sc) -> Ok(format_digital(sc, hour, minute))
            Error(Nil) -> Ok(format_natural(locale, hour, minute))
          }
        False -> Ok(format_natural(locale, hour, minute))
      }
    }
  }
}

// --- Locale resolution ---

fn resolve_short_clock(
  locale: TimeLocale,
  compactness: Compactness,
) -> Result(ShortClockConfig, Nil) {
  let ovr = case compactness {
    Normal -> Error(Nil)
    Short -> locale.short
    Compact -> locale.compact
  }
  case ovr {
    Ok(o) -> o.clock
    Error(Nil) -> Error(Nil)
  }
}

// --- Natural time formatting ---

fn format_natural(locale: TimeLocale, hour: Int, minute: Int) -> String {
  let clock = locale.clock
  let rounded = round_to_5(minute)
  let #(rounded2, h) = case rounded == 60 {
    True -> #(0, { hour + 1 } % 24)
    False -> #(rounded, hour)
  }
  case rounded2 == 0 {
    True ->
      case h {
        0 -> clock.midnight
        12 -> clock.noon
        _ -> {
          let h12 = h % 12
          let h_name = list_at(clock.hours, h12)
          let pattern = find_pattern(clock.patterns, rounded2)
          string.replace(pattern, "{h}", h_name)
        }
      }
    False -> {
      let h12 = h % 12
      let next_h12 = { h + 1 } % 12
      let h_name = list_at(clock.hours, h12)
      let next_h_name = list_at(clock.hours, next_h12)
      let pattern = find_pattern(clock.patterns, rounded2)
      pattern
      |> string.replace("{h}", h_name)
      |> string.replace("{next_h}", next_h_name)
    }
  }
}

// --- Digital time formatting ---

fn format_digital(sc: ShortClockConfig, hour: Int, minute: Int) -> String {
  case sc.use24h {
    True ->
      sc.format
      |> string.replace("{h}", int.to_string(hour))
      |> string.replace("{mm}", pad2(minute))
    False -> {
      let h12 = case hour % 12 {
        0 -> 12
        n -> n
      }
      let am_pm = case sc.am_pm {
        Ok(#(am, pm)) ->
          case hour < 12 {
            True -> am
            False -> pm
          }
        Error(Nil) ->
          case hour < 12 {
            True -> "AM"
            False -> "PM"
          }
      }
      sc.format
      |> string.replace("{h}", int.to_string(h12))
      |> string.replace("{mm}", pad2(minute))
      |> string.replace("{ampm}", am_pm)
    }
  }
}

// --- Helpers ---

fn round_to_5(minute: Int) -> Int {
  { { minute + 2 } / 5 } * 5
}

fn pad2(n: Int) -> String {
  case n < 10 {
    True -> "0" <> int.to_string(n)
    False -> int.to_string(n)
  }
}

fn list_at(items: List(String), index: Int) -> String {
  case items, index {
    [first, ..], 0 -> first
    [_, ..rest], n if n > 0 -> list_at(rest, n - 1)
    _, _ -> ""
  }
}

fn find_pattern(patterns: List(#(Int, String)), key: Int) -> String {
  case patterns {
    [] -> ""
    [#(k, v), ..rest] ->
      case k == key {
        True -> v
        False -> find_pattern(rest, key)
      }
  }
}

// --- Time parsing ---

fn try_parse(
  s: String,
  continuation: fn(#(Int, Int)) -> Result(String, Nil),
) -> Result(String, Nil) {
  case parse_time(s) {
    Ok(result) -> continuation(result)
    Error(Nil) -> Error(Nil)
  }
}

fn parse_time(input: String) -> Result(#(Int, Int), Nil) {
  let t = case string.contains(input, "T") {
    True -> {
      let parts = string.split(input, "T")
      case parts {
        [_, time_part, ..] -> time_part
        _ -> input
      }
    }
    False -> input
  }
  let t2 = case string.contains(t, "+") {
    True -> {
      let parts = string.split(t, "+")
      case parts {
        [first, ..] -> first
        _ -> t
      }
    }
    False -> t
  }
  let t3 = case string.contains(t2, "Z") {
    True -> {
      let parts = string.split(t2, "Z")
      case parts {
        [first, ..] -> first
        _ -> t2
      }
    }
    False -> t2
  }
  let parts = string.split(t3, ":")
  case parts {
    [hour_str, min_str, ..] -> {
      let min_clean = case string.contains(min_str, ".") {
        True -> {
          let ps = string.split(min_str, ".")
          case ps {
            [first, ..] -> first
            _ -> min_str
          }
        }
        False -> min_str
      }
      case int.parse(hour_str), int.parse(min_clean) {
        Ok(h), Ok(m) ->
          case h >= 0 && h <= 23 && m >= 0 && m <= 59 {
            True -> Ok(#(h, m))
            False -> Error(Nil)
          }
        _, _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}
