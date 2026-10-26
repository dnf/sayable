/// Core formatting logic for sayable-time.
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import sayabletime/types.{
  type Compactness, type ShortClockConfig, type TimeLocale, Compact, Normal,
  Short,
}

/// Replace every occurrence of a placeholder, matching code points rather
/// than graphemes (see sayabletime_ffi.erl).
@external(erlang, "sayabletime_ffi", "replace_all")
fn replace_placeholder(in: String, pattern: String, with: String) -> String

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
          replace_placeholder(pattern, "{h}", h_name)
        }
      }
    False -> {
      let h12 = h % 12
      let next_h12 = { h + 1 } % 12
      let h_name = list_at(clock.hours, h12)
      let next_h_name = list_at(clock.hours, next_h12)
      let pattern = find_pattern(clock.patterns, rounded2)
      pattern
      |> replace_placeholder("{h}", h_name)
      |> replace_placeholder("{next_h}", next_h_name)
    }
  }
}

// --- Digital time formatting ---

fn format_digital(sc: ShortClockConfig, hour: Int, minute: Int) -> String {
  case sc.use24h {
    True ->
      sc.format
      |> replace_placeholder("{h}", int.to_string(hour))
      |> replace_placeholder("{mm}", pad2(minute))
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
      |> replace_placeholder("{h}", int.to_string(h12))
      |> replace_placeholder("{mm}", pad2(minute))
      |> replace_placeholder("{ampm}", am_pm)
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

/// Parse a clock time, alone or after the T of an ISO datetime whose date
/// part names a real calendar day, to (hour, minute).
fn parse_time(input: String) -> Result(#(Int, Int), Nil) {
  case string.split_once(input, "T") {
    Ok(#(date_part, clock)) ->
      case is_real_date(date_part) {
        True -> parse_clock(clock)
        False -> Error(Nil)
      }
    Error(Nil) -> parse_clock(input)
  }
}

/// H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored).
fn parse_clock(clock: String) -> Result(#(Int, Int), Nil) {
  let #(hour_digits, after_hour) = case bit_array.from_string(clock) {
    <<h1, h2, 0x3A, rest:bits>> -> #([h1, h2], rest)
    <<h1, 0x3A, rest:bits>> -> #([h1], rest)
    other -> #([], other)
  }
  case after_hour {
    <<m1, m2, rest:bits>> -> {
      use hour <- result.try(digits_value(hour_digits))
      use minute <- result.try(digits_value([m1, m2]))
      use second <- result.try(parse_seconds_and_zone(rest))
      case hour <= 23 && minute <= 59 && second <= 59 {
        True -> Ok(#(hour, minute))
        False -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

/// The optional :SS (with optional fraction) and zone suffix after the
/// minutes; the seconds value, 0 when absent.
fn parse_seconds_and_zone(rest: BitArray) -> Result(Int, Nil) {
  case rest {
    <<0x3A, s1, s2, after_seconds:bits>> -> {
      use second <- result.try(digits_value([s1, s2]))
      use zone <- result.try(skip_fraction(after_seconds))
      case is_zone_suffix(zone) {
        True -> Ok(second)
        False -> Error(Nil)
      }
    }
    _ ->
      case is_zone_suffix(rest) {
        True -> Ok(0)
        False -> Error(Nil)
      }
  }
}

/// Skip an optional . followed by one or more digits.
fn skip_fraction(rest: BitArray) -> Result(BitArray, Nil) {
  case rest {
    <<0x2E, digit, after:bits>> if digit >= 0x30 && digit <= 0x39 ->
      Ok(skip_digits(after))
    <<0x2E, _:bits>> -> Error(Nil)
    _ -> Ok(rest)
  }
}

fn skip_digits(rest: BitArray) -> BitArray {
  case rest {
    <<digit, after:bits>> if digit >= 0x30 && digit <= 0x39 -> skip_digits(after)
    _ -> rest
  }
}

/// Nothing, Z, or +HH:MM / -HH:MM.
fn is_zone_suffix(rest: BitArray) -> Bool {
  case rest {
    <<>> | <<0x5A>> -> True
    <<sign, a, b, 0x3A, c, d>> if sign == 0x2B || sign == 0x2D ->
      result.is_ok(digits_value([a, b, c, d]))
    _ -> False
  }
}

/// Exactly YYYY-MM-DD naming a real calendar day (Gregorian leap years).
fn is_real_date(s: String) -> Bool {
  case bit_array.from_string(s) {
    <<y1, y2, y3, y4, 0x2D, m1, m2, 0x2D, d1, d2>> ->
      case
        digits_value([y1, y2, y3, y4]),
        digits_value([m1, m2]),
        digits_value([d1, d2])
      {
        Ok(y), Ok(m), Ok(d) ->
          m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m)
        _, _, _ -> False
      }
    _ -> False
  }
}

fn days_in_month(y: Int, m: Int) -> Int {
  case m {
    4 | 6 | 9 | 11 -> 30
    2 ->
      case { y % 4 == 0 && y % 100 != 0 } || y % 400 == 0 {
        True -> 29
        False -> 28
      }
    _ -> 31
  }
}

/// The value of a non-empty run of ASCII digit bytes, or an error if any byte
/// is not one.
fn digits_value(bytes: List(Int)) -> Result(Int, Nil) {
  case bytes {
    [] -> Error(Nil)
    _ ->
      list.try_fold(bytes, 0, fn(acc, byte) {
        case byte >= 0x30 && byte <= 0x39 {
          True -> Ok(acc * 10 + byte - 0x30)
          False -> Error(Nil)
        }
      })
  }
}
