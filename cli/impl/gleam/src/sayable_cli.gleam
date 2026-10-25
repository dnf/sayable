/// Sayable CLI — unified command-line interface to all four Sayable components.
///
/// See cli/SPEC.md for the full specification.
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
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

const help_text =
  "Usage: sayable <command> [arguments] [options]

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
  "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bi", "bm", "bn", "br",
  "bs", "ca", "ceb", "cs", "cy", "da", "de", "din", "dje", "dyu", "ee", "el",
  "en", "es", "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon", "fr",
  "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi", "hr", "ht", "hu", "hy",
  "id", "ig", "is", "it", "ja", "jv", "ka", "kbp", "kk", "km", "kn", "ko", "kpe",
  "ktu", "ku", "kw", "ky", "lg", "ln", "lo", "lt", "lv", "men", "mfe", "mg",
  "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne",
  "ng", "nl", "nso", "nus", "ny", "om", "or", "pa", "pis", "pl", "pov", "ps",
  "pt", "qu", "ro", "ru", "rw", "sar", "sd", "sg", "shi", "si", "sk", "sl", "sn",
  "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw", "ta", "te",
  "tem", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr", "ts", "tzm", "uk",
  "umb", "ur", "uz", "vi", "vmw", "wo", "xh", "yo", "yue", "zdj", "zh", "zu",
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

/// What a one-shot run exits with and prints to stdout, one entry per line.
pub type Response {
  Response(exit_code: Int, lines: List(String))
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

@external(erlang, "sayable_cli_ffi", "read_line")
fn read_line() -> Result(String, Nil)

@external(erlang, "sayable_cli_ffi", "rescue")
fn rescue(f: fn() -> a) -> Result(a, String)

// --- Entry point ---

pub fn main() {
  case get_plain_arguments() {
    ["--repl"] -> {
      repl()
      halt(0)
    }
    argv -> {
      let response = run(argv)
      list.each(response.lines, io.println)
      halt(response.exit_code)
    }
  }
}

pub fn run(argv: List(String)) -> Response {
  case parse_args(argv) {
    Error(response) -> response
    Ok(#(command, positionals, options)) ->
      dispatch(command, positionals, options)
  }
}

fn dispatch(
  command: Option(String),
  positionals: List(String),
  options: Options,
) -> Response {
  case command {
    None -> Response(2, [help_text])
    Some("help") -> help_response()
    Some("version") -> version_response()
    Some("locales") -> cmd_locales()
    Some("age") -> cmd_age(positionals, options)
    Some("stage") -> cmd_stage(positionals, options)
    Some("date") -> cmd_date(positionals, options)
    Some("relative") -> cmd_relative(positionals, options)
    Some("time") -> cmd_time(positionals, options)
    Some("duration") -> cmd_duration(positionals, options)
    Some("since") -> cmd_since(positionals, options)
    Some("until") -> cmd_until(positionals, options)
    Some(other) -> usage_error("unknown command '" <> other <> "'")
  }
}

fn help_response() -> Response {
  Response(0, [help_text])
}

fn version_response() -> Response {
  Response(0, ["sayable " <> version])
}

// --- REPL mode (see cli/SPEC.md) ---

fn repl() -> Nil {
  case read_line() {
    Error(Nil) -> Nil
    Ok(line) -> {
      let response = run_isolated(string.split(line, "\t"))
      io.print(
        int.to_string(response.exit_code)
        <> "\t"
        <> string.replace(string.join(response.lines, "\t"), "\n", "\t")
        <> "\n",
      )
      repl()
    }
  }
}

/// A crashed one-shot run exits 1, so a crashed request answers 1 and the
/// REPL keeps serving.
fn run_isolated(argv: List(String)) -> Response {
  case rescue(fn() { run(argv) }) {
    Ok(response) -> response
    Error(reason) -> {
      write_stderr("error: " <> reason <> "\n")
      null_result()
    }
  }
}

// --- Argument parsing ---
// An Error carries the response that ends the run early (usage error, help).

fn parse_args(
  argv: List(String),
) -> Result(#(Option(String), List(String), Options), Response) {
  case argv {
    [] -> Ok(#(None, [], default_options()))
    ["-h", ..] | ["--help", ..] | ["help", ..] ->
      Ok(#(Some("help"), [], default_options()))
    ["-v", ..] | ["--version", ..] | ["version", ..] ->
      Ok(#(Some("version"), [], default_options()))
    [first, ..rest] -> {
      use #(positionals, options) <- result.map(parse_options(
        rest,
        [],
        default_options(),
        False,
      ))
      #(Some(first), positionals, options)
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
) -> Result(#(List(String), Options), Response) {
  case args {
    [] -> Ok(#(list.reverse(positionals), options))
    ["--", ..rest] ->
      case stop_opts {
        True -> parse_options(rest, ["--", ..positionals], options, True)
        False -> parse_options(rest, positionals, options, True)
      }
    [arg, ..rest] -> {
      case stop_opts {
        True -> parse_options(rest, [arg, ..positionals], options, True)
        False ->
          case starts_with_dash(arg) {
            True -> parse_option(arg, rest, positionals, options)
            False -> parse_options(rest, [arg, ..positionals], options, False)
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
) -> Result(#(List(String), Options), Response) {
  let continue = fn(rest, options) {
    parse_options(rest, positionals, options, False)
  }
  let missing_value = fn() {
    Error(usage_error("'" <> arg <> "' requires a value"))
  }
  case arg, rest {
    "-l", [val, ..rest2] | "--locale", [val, ..rest2] ->
      continue(rest2, Options(..options, locale: val))
    "-d", [val, ..rest2] | "--as-of", [val, ..rest2] ->
      continue(rest2, Options(..options, as_of: Some(val)))
    "-g", [val, ..rest2] | "--gender", [val, ..rest2] ->
      continue(rest2, Options(..options, gender: Some(val)))
    "-l", [] | "--locale", [] -> missing_value()
    "-d", [] | "--as-of", [] -> missing_value()
    "-g", [] | "--gender", [] -> missing_value()
    "--short", _ -> continue(rest, Options(..options, compactness: "short"))
    "--compact", _ -> continue(rest, Options(..options, compactness: "compact"))
    "--with-year", _ -> continue(rest, Options(..options, with_year: True))
    "-h", _ | "--help", _ -> Error(help_response())
    "-v", _ | "--version", _ -> Error(version_response())
    _, _ -> Error(usage_error("unknown option '" <> arg <> "'"))
  }
}

// --- Helpers ---

fn starts_with_dash(s: String) -> Bool {
  case string.first(s) {
    Ok("-") -> True
    _ -> False
  }
}

fn nullify(value: String) -> String {
  case value {
    "null" -> ""
    _ -> value
  }
}

fn usage_error(msg: String) -> Response {
  write_stderr("error: " <> msg <> "\n")
  write_stderr("Run 'sayable help' for usage.\n")
  Response(2, [])
}

fn null_result() -> Response {
  Response(1, [])
}

fn formatted(result: Result(String, Nil)) -> Response {
  case result {
    Ok(text) -> Response(0, [text])
    Error(Nil) -> null_result()
  }
}

fn with_locale(
  lookup: Result(locale, Nil),
  locale_code: String,
  continue: fn(locale) -> Response,
) -> Response {
  case lookup {
    Ok(locale) -> continue(locale)
    Error(Nil) -> usage_error("unknown locale '" <> locale_code <> "'")
  }
}

fn as_of_or_today(options: Options) -> String {
  case options.as_of {
    None -> get_today()
    Some(val) -> nullify(val)
  }
}

fn with_required_as_of(
  command: String,
  options: Options,
  continue: fn(String) -> Response,
) -> Response {
  case options.as_of {
    None -> usage_error(command <> " requires --as-of / -d option")
    Some(raw_as_of) -> continue(nullify(raw_as_of))
  }
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

fn cmd_age(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("age requires a date-of-birth argument")
    [raw_dob, ..] -> {
      use locale <- with_locale(
        sayableage.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_age_compactness(options.compactness)
      sayableage.format_age(
        locale,
        compactness,
        nullify(raw_dob),
        as_of_or_today(options),
      )
      |> formatted
    }
  }
}

fn cmd_stage(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("stage requires a date-of-birth argument")
    [raw_dob, ..] -> {
      use locale <- with_locale(
        sayableage.get_locale(options.locale),
        options.locale,
      )
      let gender = resolve_gender(options.gender)
      sayableage.format_stage(
        locale,
        nullify(raw_dob),
        as_of_or_today(options),
        gender,
      )
      |> formatted
    }
  }
}

fn cmd_date(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("date requires a date argument")
    [raw_date, ..] -> {
      let date_val = nullify(raw_date)
      use locale <- with_locale(
        sayabledate.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_date_compactness(options.compactness)
      case options.with_year {
        True -> sayabledate.format_date_with_year(locale, compactness, date_val)
        False -> sayabledate.format_date(locale, compactness, date_val)
      }
      |> formatted
    }
  }
}

fn cmd_relative(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("relative requires a date argument")
    [raw_date, ..] -> {
      use as_of <- with_required_as_of("relative", options)
      use locale <- with_locale(
        sayabledate.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_date_compactness(options.compactness)
      sayabledate.format_relative(locale, compactness, nullify(raw_date), as_of)
      |> formatted
    }
  }
}

fn cmd_time(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("time requires a time argument")
    [raw_time, ..] -> {
      use locale <- with_locale(
        sayabletime.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_time_compactness(options.compactness)
      sayabletime.format_time(locale, compactness, nullify(raw_time))
      |> formatted
    }
  }
}

fn cmd_duration(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("duration requires a value argument")
    [raw_value, ..rest] -> {
      use locale <- with_locale(
        sayableduration.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_duration_compactness(options.compactness)
      case nullify(raw_value), rest {
        "", _ -> null_result()
        value, rest ->
          case is_integer_string(value), rest {
            True, _ ->
              sayableduration.format_duration(
                locale,
                compactness,
                parse_int(value),
              )
              |> formatted
            False, [] ->
              usage_error(
                "duration with timestamps requires start and end arguments",
              )
            False, [raw_end, ..] ->
              sayableduration.format_duration_timestamps(
                locale,
                compactness,
                value,
                nullify(raw_end),
              )
              |> formatted
          }
      }
    }
  }
}

fn cmd_since(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("since requires a start timestamp argument")
    [raw_start, ..] -> {
      use as_of <- with_required_as_of("since", options)
      use locale <- with_locale(
        sayableduration.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_duration_compactness(options.compactness)
      sayableduration.format_since(
        locale,
        compactness,
        nullify(raw_start),
        as_of,
      )
      |> formatted
    }
  }
}

fn cmd_until(positionals: List(String), options: Options) -> Response {
  case positionals {
    [] -> usage_error("until requires a target timestamp argument")
    [raw_target, ..] -> {
      use as_of <- with_required_as_of("until", options)
      use locale <- with_locale(
        sayableduration.get_locale(options.locale),
        options.locale,
      )
      let compactness = resolve_duration_compactness(options.compactness)
      sayableduration.format_until(
        locale,
        compactness,
        nullify(raw_target),
        as_of,
      )
      |> formatted
    }
  }
}

fn cmd_locales() -> Response {
  Response(
    0,
    list.filter(all_locale_codes, fn(code) {
      result.is_ok(sayableage.get_locale(code))
    }),
  )
}
