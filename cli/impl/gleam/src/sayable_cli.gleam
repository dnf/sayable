/// Sayable CLI — unified command-line interface to all four Sayable components.
///
/// See cli/SPEC.md for the full specification.

import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import sayableage
import sayableage/types as age_types
import sayabledate
import sayabledate/types as date_types
import sayableduration
import sayableduration/types as duration_types
import sayabletime
import sayabletime/types as time_types

const version = "0.5.0"

const help_text = "Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version"

// All 110 locale codes (shared across all components)
const all_locale_codes = [
  "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bi", "bm", "bn",
  "br", "bs", "ca", "ceb", "cs", "cy", "da", "de", "din", "dje", "dyu", "ee",
  "el", "en", "es", "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon",
  "fr", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi", "hr", "ht",
  "hu", "hy", "id", "ig", "is", "it", "ja", "jv", "ka", "kbp", "kk", "km",
  "kn", "ko", "kpe", "ktu", "ku", "kw", "ky", "lg", "ln", "lo", "lt", "lv",
  "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt",
  "my", "nb", "nd", "ne", "ng", "nl", "nso", "nus", "ny", "om", "or", "pa",
  "pis", "pl", "pov", "ps", "pt", "qu", "ro", "ru", "rw", "sar", "sd", "sg",
  "shi", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su",
  "suk", "sv", "sw", "ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn",
  "tpi", "tr", "ts", "tzm", "uk", "umb", "ur", "uz", "vi", "vmw", "wo", "xh",
  "yo", "yue", "zdj", "zh", "zu",
]

// --- Types ---

type Options {
  Options(
    locale: String,
    as_of: Option(String),
    compactness: String,
    gender: Option(String),
    with_year: Bool,
  )
}

// --- Erlang FFI ---

@external(erlang, "sayable_cli_ffi", "halt")
fn halt(code: Int) -> Nil

@external(erlang, "sayable_cli_ffi", "get_args")
fn get_plain_arguments() -> List(String)

@external(erlang, "sayable_cli_ffi", "write_stderr")
fn write_stderr(msg: String) -> Nil

@external(erlang, "sayable_cli_ffi", "get_today")
fn get_today() -> String

// --- Entry point ---

pub fn main() {
  let argv = get_plain_arguments()
  run(argv)
}

fn run(argv: List(String)) -> Nil {
  let #(command, positionals, options) = parse_args(argv)

  case command {
    None -> {
      io.println(help_text)
      halt(2)
    }
    Some("help") -> {
      io.println(help_text)
      halt(0)
    }
    Some("version") -> {
      io.println("sayable " <> version)
      halt(0)
    }
    Some("locales") -> {
      cmd_locales()
      halt(0)
    }
    Some("age") -> cmd_age(positionals, options)
    Some("stage") -> cmd_stage(positionals, options)
    Some("date") -> cmd_date(positionals, options)
    Some("relative") -> cmd_relative(positionals, options)
    Some("time") -> cmd_time(positionals, options)
    Some("duration") -> cmd_duration(positionals, options)
    Some("since") -> cmd_since(positionals, options)
    Some("until") -> cmd_until(positionals, options)
    Some(other) -> error("unknown command '" <> other <> "'")
  }
}

// --- Argument parsing ---

fn parse_args(
  argv: List(String),
) -> #(Option(String), List(String), Options) {
  case argv {
    [] -> #(None, [], default_options())
    [first, ..] -> {
      case first {
        "-h" | "--help" | "help" -> #(Some("help"), [], default_options())
        "-v" | "--version" | "version" ->
          #(Some("version"), [], default_options())
        _ -> {
          let rest = list_rest(argv)
          let #(positionals, options) =
            parse_options(rest, [], default_options(), False)
          #(Some(first), positionals, options)
        }
      }
    }
  }
}

fn default_options() -> Options {
  Options(
    locale: "en",
    as_of: None,
    compactness: "normal",
    gender: None,
    with_year: False,
  )
}

fn parse_options(
  args: List(String),
  positionals: List(String),
  options: Options,
  stop_opts: Bool,
) -> #(List(String), Options) {
  case args {
    [] -> #(list.reverse(positionals), options)
    ["--", ..rest] ->
      case stop_opts {
        True ->
          parse_options(rest, ["--", ..positionals], options, True)
        False -> parse_options(rest, positionals, options, True)
      }
    [arg, ..rest] -> {
      case stop_opts {
        True ->
          parse_options(rest, [arg, ..positionals], options, True)
        False ->
          case starts_with_dash(arg) {
            True -> parse_option(arg, rest, positionals, options)
            False ->
              parse_options(rest, [arg, ..positionals], options, False)
          }
      }
    }
  }
}

fn parse_option(
  arg: String,
  rest: List(String),
  positionals: List(String),
  options: Options,
) -> #(List(String), Options) {
  case arg {
    "-l" | "--locale" ->
      case rest {
        [] -> {
          error("'" <> arg <> "' requires a value")
          #([], options)
        }
        [val, ..rest2] ->
          parse_options(
            rest2,
            positionals,
            Options(..options, locale: val),
            False,
          )
      }
    "-d" | "--as-of" ->
      case rest {
        [] -> {
          error("'" <> arg <> "' requires a value")
          #([], options)
        }
        [val, ..rest2] ->
          parse_options(
            rest2,
            positionals,
            Options(..options, as_of: Some(val)),
            False,
          )
      }
    "-g" | "--gender" ->
      case rest {
        [] -> {
          error("'" <> arg <> "' requires a value")
          #([], options)
        }
        [val, ..rest2] ->
          parse_options(
            rest2,
            positionals,
            Options(..options, gender: Some(val)),
            False,
          )
      }
    "--short" ->
      parse_options(
        rest,
        positionals,
        Options(..options, compactness: "short"),
        False,
      )
    "--compact" ->
      parse_options(
        rest,
        positionals,
        Options(..options, compactness: "compact"),
        False,
      )
    "--with-year" ->
      parse_options(
        rest,
        positionals,
        Options(..options, with_year: True),
        False,
      )
    "-h" | "--help" -> {
      io.println(help_text)
      halt(0)
      #([], options)
    }
    "-v" | "--version" -> {
      io.println("sayable " <> version)
      halt(0)
      #([], options)
    }
    _ -> {
      error("unknown option '" <> arg <> "'")
      #([], options)
    }
  }
}

// --- Helpers ---

fn starts_with_dash(s: String) -> Bool {
  case string.first(s) {
    Ok("-") -> True
    _ -> False
  }
}

fn list_rest(l: List(a)) -> List(a) {
  case l {
    [] -> []
    [_, ..rest] -> rest
  }
}

fn nullify(value: String) -> String {
  case value {
    "null" -> ""
    _ -> value
  }
}

fn error(msg: String) -> Nil {
  write_stderr("error: " <> msg <> "\n")
  write_stderr("Run 'sayable help' for usage.\n")
  halt(2)
}

fn resolve_age_compactness(compactness: String) -> age_types.Compactness {
  case compactness {
    "short" -> age_types.Short
    "compact" -> age_types.Compact
    _ -> age_types.Normal
  }
}

fn resolve_date_compactness(compactness: String) -> date_types.Compactness {
  case compactness {
    "short" -> date_types.Short
    "compact" -> date_types.Compact
    _ -> date_types.Normal
  }
}

fn resolve_time_compactness(compactness: String) -> time_types.Compactness {
  case compactness {
    "short" -> time_types.Short
    "compact" -> time_types.Compact
    _ -> time_types.Normal
  }
}

fn resolve_duration_compactness(
  compactness: String,
) -> duration_types.Compactness {
  case compactness {
    "short" -> duration_types.Short
    "compact" -> duration_types.Compact
    _ -> duration_types.Normal
  }
}

fn resolve_gender(gender: Option(String)) -> Result(age_types.Gender, Nil) {
  case gender {
    Some("m") -> Ok(age_types.Male)
    Some("f") -> Ok(age_types.Female)
    _ -> Error(Nil)
  }
}

// --- Integer detection ---

fn is_integer_string(s: String) -> Bool {
  case s {
    "" -> False
    _ ->
      case string.first(s) {
        Ok("-") -> {
          let rest = string.drop_start(s, 1)
          case rest {
            "" -> False
            _ -> all_digits(rest)
          }
        }
        _ -> all_digits(s)
      }
  }
}

fn all_digits(s: String) -> Bool {
  case string.first(s) {
    Error(Nil) -> True
    Ok(c) ->
      case is_digit(c) {
        True -> all_digits(string.drop_start(s, 1))
        False -> False
      }
  }
}

fn is_digit(c: String) -> Bool {
  case c {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

fn parse_int(s: String) -> Int {
  case int.parse(s) {
    Ok(n) -> n
    Error(Nil) -> 0
  }
}

// --- Command implementations ---

fn cmd_age(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("age requires a date-of-birth argument")
    [raw_dob, ..] -> {
      let dob = nullify(raw_dob)
      let locale_code = options.locale

      case sayableage.get_locale(locale_code) {
        Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
        Ok(locale) -> {
          let as_of = case options.as_of {
            None -> get_today()
            Some(val) -> nullify(val)
          }
          let compactness = resolve_age_compactness(options.compactness)
          let result = sayableage.format_age(locale, compactness, dob, as_of)

          case result {
            Ok(text) -> io.println(text)
            Error(Nil) -> halt(1)
          }
        }
      }
    }
  }
}

fn cmd_stage(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("stage requires a date-of-birth argument")
    [raw_dob, ..] -> {
      let dob = nullify(raw_dob)
      let locale_code = options.locale

      case sayableage.get_locale(locale_code) {
        Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
        Ok(locale) -> {
          let as_of = case options.as_of {
            None -> get_today()
            Some(val) -> nullify(val)
          }
          let gender = resolve_gender(options.gender)
          let result = sayableage.format_stage(locale, dob, as_of, gender)

          case result {
            Ok(text) -> io.println(text)
            Error(Nil) -> halt(1)
          }
        }
      }
    }
  }
}

fn cmd_date(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("date requires a date argument")
    [raw_date, ..] -> {
      let date_val = nullify(raw_date)
      let locale_code = options.locale

      case sayabledate.get_locale(locale_code) {
        Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
        Ok(locale) -> {
          let compactness = resolve_date_compactness(options.compactness)
          let result = case options.with_year {
            True ->
              sayabledate.format_date_with_year(locale, compactness, date_val)
            False -> sayabledate.format_date(locale, compactness, date_val)
          }

          case result {
            Ok(text) -> io.println(text)
            Error(Nil) -> halt(1)
          }
        }
      }
    }
  }
}

fn cmd_relative(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("relative requires a date argument")
    [raw_date, ..] -> {
      let date_val = nullify(raw_date)

      case options.as_of {
        None -> error("relative requires --as-of / -d option")
        Some(raw_as_of) -> {
          let as_of = nullify(raw_as_of)
          let locale_code = options.locale

          case sayabledate.get_locale(locale_code) {
            Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
            Ok(locale) -> {
              let compactness = resolve_date_compactness(options.compactness)
              let result =
                sayabledate.format_relative(
                  locale,
                  compactness,
                  date_val,
                  as_of,
                )

              case result {
                Ok(text) -> io.println(text)
                Error(Nil) -> halt(1)
              }
            }
          }
        }
      }
    }
  }
}

fn cmd_time(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("time requires a time argument")
    [raw_time, ..] -> {
      let time_val = nullify(raw_time)
      let locale_code = options.locale

      case sayabletime.get_locale(locale_code) {
        Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
        Ok(locale) -> {
          let compactness = resolve_time_compactness(options.compactness)
          let result = sayabletime.format_time(locale, compactness, time_val)

          case result {
            Ok(text) -> io.println(text)
            Error(Nil) -> halt(1)
          }
        }
      }
    }
  }
}

fn cmd_duration(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("duration requires a value argument")
    [raw_value, ..rest] -> {
      let value = nullify(raw_value)
      let locale_code = options.locale

      case sayableduration.get_locale(locale_code) {
        Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
        Ok(locale) -> {
          let compactness = resolve_duration_compactness(options.compactness)
          let result = case value {
            "" ->
              // null input
              Error(Nil)
            _ ->
              case is_integer_string(value) {
                True -> {
                  let seconds = parse_int(value)
                  sayableduration.format_duration(locale, compactness, seconds)
                }
                False ->
                  // Timestamp mode: need an end argument
                  case rest {
                    [] -> {
                      error(
                        "duration with timestamps requires start and end arguments",
                      )
                      Error(Nil)
                    }
                    [raw_end, ..] -> {
                      let end_val = nullify(raw_end)
                      sayableduration.format_duration_timestamps(
                        locale,
                        compactness,
                        value,
                        end_val,
                      )
                    }
                  }
              }
          }

          case result {
            Ok(text) -> io.println(text)
            Error(Nil) -> halt(1)
          }
        }
      }
    }
  }
}

fn cmd_since(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("since requires a start timestamp argument")
    [raw_start, ..] -> {
      let start = nullify(raw_start)

      case options.as_of {
        None -> error("since requires --as-of / -d option")
        Some(raw_as_of) -> {
          let as_of = nullify(raw_as_of)
          let locale_code = options.locale

          case sayableduration.get_locale(locale_code) {
            Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
            Ok(locale) -> {
              let compactness =
                resolve_duration_compactness(options.compactness)
              let result =
                sayableduration.format_since(
                  locale,
                  compactness,
                  start,
                  as_of,
                )

              case result {
                Ok(text) -> io.println(text)
                Error(Nil) -> halt(1)
              }
            }
          }
        }
      }
    }
  }
}

fn cmd_until(positionals: List(String), options: Options) -> Nil {
  case positionals {
    [] -> error("until requires a target timestamp argument")
    [raw_target, ..] -> {
      let target = nullify(raw_target)

      case options.as_of {
        None -> error("until requires --as-of / -d option")
        Some(raw_as_of) -> {
          let as_of = nullify(raw_as_of)
          let locale_code = options.locale

          case sayableduration.get_locale(locale_code) {
            Error(Nil) -> error("unknown locale '" <> locale_code <> "'")
            Ok(locale) -> {
              let compactness =
                resolve_duration_compactness(options.compactness)
              let result =
                sayableduration.format_until(
                  locale,
                  compactness,
                  target,
                  as_of,
                )

              case result {
                Ok(text) -> io.println(text)
                Error(Nil) -> halt(1)
              }
            }
          }
        }
      }
    }
  }
}

fn cmd_locales() -> Nil {
  list.each(all_locale_codes, fn(code) {
    case sayableage.get_locale(code) {
      Ok(_) -> io.println(code)
      Error(Nil) -> Nil
    }
  })
}
