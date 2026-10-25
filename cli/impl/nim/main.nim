## Sayable CLI -- unified command-line interface to all four Sayable components.
##
## See cli/SPEC.md for the full specification.

import std/[options, os, strutils, times, algorithm]

# Import component formatters and registries via --path in compilation.
# Use qualified imports to avoid name clashes (each component defines Compactness, etc.)
import sayable_age/locale as ageLocale
import sayable_age/formatter as ageFormatter
import sayable_age/locales/registry as ageRegistry

import sayable_date/locale as dateLocale
import sayable_date/formatter as dateFormatter
import sayable_date/locales/registry as dateRegistry

import sayable_time/locale as timeLocale
import sayable_time/formatter as timeFormatter
import sayable_time/locales/registry as timeRegistry

import sayable_duration/locale as durLocale
import sayable_duration/formatter as durFormatter
import sayable_duration/locales/registry as durRegistry

const Version = "0.5.0"

const Help = """Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version"""

# All locale codes supported by the age component (canonical list).
const LocaleCodes = [
  "af", "ak", "am", "ar", "az",
  "bci", "be", "bem", "bg", "bi", "bm", "bn", "br", "bs",
  "ca", "ceb", "cs", "cy",
  "da", "de", "din", "dje", "dv", "dyu", "dz",
  "ee", "el", "en", "es", "et", "eu",
  "fa", "fan", "ff", "fi", "fil", "fj", "fon", "fr",
  "ga", "gd", "gl", "gn", "gu", "gv",
  "ha", "he", "hi", "hmn", "hr", "ht", "hu", "hy",
  "id", "ig", "is", "it",
  "ja", "jv",
  "ka", "kbp", "kk", "km", "kn", "ko", "kpe", "ktu", "ku", "kw", "ky",
  "lg", "ln", "lo", "lt", "lv",
  "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt", "my",
  "nb", "nd", "ne", "ng", "nl", "nso", "nus", "ny",
  "om", "or",
  "pa", "pis", "pl", "pov", "ps", "pt",
  "qu",
  "ro", "ru", "rw",
  "sar", "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
  "ta", "te", "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr", "ts", "tzm",
  "uk", "umb", "ur", "uz",
  "vi", "vmw",
  "wo",
  "xh",
  "yo", "yue",
  "zdj", "zh", "zu",
]


type
  Options = object
    locale: string
    asOf: string
    compactness: string
    gender: string
    withYear: bool


type UsageError = object of CatchableError
  ## Raised after a usage error has been reported; the invocation exits 2.


proc cliError(msg: string) {.noreturn.} =
  stderr.writeLine("error: " & msg)
  stderr.writeLine("Run 'sayable help' for usage.")
  raise newException(UsageError, msg)


proc nullify(value: string): string =
  ## Convert CLI "null" sentinel to empty string (representing nil).
  if value == "null": "" else: value


proc getToday(): string =
  let today = now().utc
  let y = today.year
  let m = ord(today.month)
  let d = today.monthday
  align($y, 4, '0') & "-" & align($m, 2, '0') & "-" & align($d, 2, '0')


proc parseArgs(argv: seq[string]): tuple[command: string, positionals: seq[
    string], options: Options] =
  if argv.len == 0:
    return ("", @[], Options(locale: "en", asOf: "", compactness: "normal",
        gender: "", withYear: false))

  if argv[0] in ["-h", "--help", "help"]:
    return ("help", @[], Options(locale: "en", asOf: "", compactness: "normal",
        gender: "", withYear: false))
  if argv[0] in ["-v", "--version", "version"]:
    return ("version", @[], Options(locale: "en", asOf: "",
        compactness: "normal", gender: "", withYear: false))

  let command = argv[0]
  var positionals: seq[string] = @[]
  var opts = Options(locale: "en", asOf: "", compactness: "normal", gender: "",
      withYear: false)

  var i = 1
  var stopOpts = false
  while i < argv.len:
    let arg = argv[i]

    if arg == "--" and not stopOpts:
      stopOpts = true
      i += 1
      continue

    if not stopOpts and arg.startsWith("-"):
      case arg
      of "-l", "--locale":
        if i + 1 >= argv.len:
          cliError("'" & arg & "' requires a value")
        i += 1
        opts.locale = argv[i]
      of "-d", "--as-of":
        if i + 1 >= argv.len:
          cliError("'" & arg & "' requires a value")
        i += 1
        opts.asOf = argv[i]
      of "-g", "--gender":
        if i + 1 >= argv.len:
          cliError("'" & arg & "' requires a value")
        i += 1
        opts.gender = argv[i]
      of "--short":
        opts.compactness = "short"
      of "--compact":
        opts.compactness = "compact"
      of "--with-year":
        opts.withYear = true
      of "-h", "--help":
        return ("help", @[], Options(locale: "en", asOf: "",
            compactness: "normal", gender: "", withYear: false))
      of "-v", "--version":
        return ("version", @[], Options(locale: "en", asOf: "",
            compactness: "normal", gender: "", withYear: false))
      else:
        cliError("unknown option '" & arg & "'")
    else:
      positionals.add(arg)

    i += 1

  (command, positionals, opts)


proc cmdAge(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("age requires a date-of-birth argument")
  let dob = nullify(positionals[0])

  let locale = ageRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  var asOf = opts.asOf
  if asOf.len > 0:
    asOf = nullify(asOf)
  else:
    asOf = getToday()

  let compactness = case opts.compactness
    of "short": ageLocale.cShort
    of "compact": ageLocale.cCompact
    else: ageLocale.cNormal

  let formatter = ageFormatter.newSayableAge(locale.get, compactness)
  let res = formatter.formatAge(dob, asOf)

  res


proc cmdStage(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("stage requires a date-of-birth argument")
  let dob = nullify(positionals[0])

  let locale = ageRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  var asOf = opts.asOf
  if asOf.len > 0:
    asOf = nullify(asOf)
  else:
    asOf = getToday()

  let gender = opts.gender

  let compactness = case opts.compactness
    of "short": ageLocale.cShort
    of "compact": ageLocale.cCompact
    else: ageLocale.cNormal

  let formatter = ageFormatter.newSayableAge(locale.get, compactness)
  let res = formatter.formatStage(dob, asOf, gender)

  res


proc cmdDate(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("date requires a date argument")
  let dateVal = nullify(positionals[0])

  let locale = dateRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": dateLocale.cShort
    of "compact": dateLocale.cCompact
    else: dateLocale.cNormal

  let formatter = dateFormatter.newSayableDate(locale.get, compactness)

  let res = if opts.withYear:
      formatter.formatDateWithYear(dateVal)
    else:
      formatter.formatDate(dateVal)

  res


proc cmdRelative(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("relative requires a date argument")
  let dateVal = nullify(positionals[0])

  if opts.asOf.len == 0:
    cliError("relative requires --as-of / -d option")
  let asOf = nullify(opts.asOf)

  let locale = dateRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": dateLocale.cShort
    of "compact": dateLocale.cCompact
    else: dateLocale.cNormal

  let formatter = dateFormatter.newSayableDate(locale.get, compactness)
  let res = formatter.formatRelative(dateVal, asOf)

  res


proc cmdTime(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("time requires a time argument")
  let timeVal = nullify(positionals[0])

  let locale = timeRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": timeLocale.cShort
    of "compact": timeLocale.cCompact
    else: timeLocale.cNormal

  let formatter = timeFormatter.newSayableTime(locale.get, compactness)
  let res = formatter.formatTime(timeVal)

  res


proc cmdDuration(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("duration requires a value argument")
  let value = nullify(positionals[0])

  let locale = durRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": durLocale.cShort
    of "compact": durLocale.cCompact
    else: durLocale.cNormal

  let formatter = durFormatter.newSayableDuration(locale.get, compactness)

  var res: Option[string]
  if value.len == 0:
    # null input
    res = none(string)
  else:
    # Check if it's a number (possibly negative, handled via --)
    var isNumber = true
    var startIdx = 0
    if value[0] == '-':
      startIdx = 1
    if startIdx >= value.len:
      isNumber = false
    else:
      for j in startIdx ..< value.len:
        if value[j] < '0' or value[j] > '9':
          isNumber = false
          break

    if isNumber:
      res = formatter.formatDuration(parseInt(value))
    else:
      # Timestamp mode: need an end argument
      if positionals.len < 2:
        cliError(
            "duration with timestamps requires start and end arguments")
      let endVal = nullify(positionals[1])
      res = formatter.formatDurationIso(value, endVal)

  res


proc cmdSince(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("since requires a start timestamp argument")
  let startVal = nullify(positionals[0])

  if opts.asOf.len == 0:
    cliError("since requires --as-of / -d option")
  let asOf = nullify(opts.asOf)

  let locale = durRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": durLocale.cShort
    of "compact": durLocale.cCompact
    else: durLocale.cNormal

  let formatter = durFormatter.newSayableDuration(locale.get, compactness)
  let res = formatter.formatSince(startVal, asOf)

  res


proc cmdUntil(positionals: seq[string], opts: Options): Option[string] =
  if positionals.len == 0:
    cliError("until requires a target timestamp argument")
  let target = nullify(positionals[0])

  if opts.asOf.len == 0:
    cliError("until requires --as-of / -d option")
  let asOf = nullify(opts.asOf)

  let locale = durRegistry.getLocale(opts.locale)
  if locale.isNone:
    cliError("unknown locale '" & opts.locale & "'")

  let compactness = case opts.compactness
    of "short": durLocale.cShort
    of "compact": durLocale.cCompact
    else: durLocale.cNormal

  let formatter = durFormatter.newSayableDuration(locale.get, compactness)
  let res = formatter.formatUntil(target, asOf)

  res


proc cmdLocales(): string =
  var codes: seq[string] = @[]
  for code in LocaleCodes:
    let locale = ageRegistry.getLocale(code)
    if locale.isSome:
      codes.add(code)
  codes.sort()
  codes.join("\n") & "\n"


proc dispatch(argv: seq[string]): tuple[code: int, output: string] =
  let (command, positionals, opts) = parseArgs(argv)

  if command.len == 0:
    return (2, Help & "\n")

  let res = case command
    of "help": return (0, Help & "\n")
    of "version": return (0, "sayable " & Version & "\n")
    of "locales": return (0, cmdLocales())
    of "age": cmdAge(positionals, opts)
    of "stage": cmdStage(positionals, opts)
    of "date": cmdDate(positionals, opts)
    of "relative": cmdRelative(positionals, opts)
    of "time": cmdTime(positionals, opts)
    of "duration": cmdDuration(positionals, opts)
    of "since": cmdSince(positionals, opts)
    of "until": cmdUntil(positionals, opts)
    else: cliError("unknown command '" & command & "'")

  if res.isNone: (1, "") else: (0, res.get & "\n")


proc run(argv: seq[string]): tuple[code: int, output: string] =
  ## Runs one invocation; returns its exit code and the text for stdout.
  try:
    dispatch(argv)
  except UsageError:
    (2, "")


proc repl() =
  ## Answers one tab-separated request per stdin line (see cli/SPEC.md).
  var line: string
  while stdin.readLine(line):
    var answer: tuple[code: int, output: string]
    try:
      answer = run(line.strip(leading = false, chars = {'\r'}).split('\t'))
    except CatchableError as e:
      # A one-shot run would crash with exit 1; report it and keep serving.
      stderr.writeLine("error: " & e.msg)
      answer = (1, "")
    let flat = answer.output.strip(leading = false, chars = {'\n'}).replace("\n", "\t")
    stdout.write($answer.code & "\t" & flat & "\n")
    stdout.flushFile()


proc main() =
  let argv = commandLineParams()
  if argv == @["--repl"]:
    repl()
    return
  let (code, output) = run(argv)
  stdout.write(output)
  quit(code)


main()
