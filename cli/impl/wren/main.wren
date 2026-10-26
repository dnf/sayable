// Sayable CLI — unified command-line interface to all four Sayable components.
// See cli/SPEC.md for the full specification.
//
// Note: wren_cli 0.4.0 has no Process.exit(), stderr or clock.
// Exit codes, stderr and today's date are handled by the shell wrapper
// (sayable): it passes the date as `--today YYYY-MM-DD` in one-shot mode and
// as the first field of every request line in --repl mode.
// A one-shot run uses special output prefixes:
//   __EXIT_1__ = null result
//   __EXIT_2__<message> = usage error with message
// In --repl mode each response is one stdout line, and a line starting with
// __STDERR__ is a message the wrapper moves to stderr.

import "io" for Stdin, Stdout
import "os" for Process

import "../../../age/impl/wren/sayableage" for SayableAge
import "../../../age/impl/wren/locales/registry" for LocaleRegistry as AgeLocaleRegistry
import "../../../date/impl/wren/format_date" for SayableDate
import "../../../date/impl/wren/locales/registry" for LocaleRegistry as DateLocaleRegistry
import "../../../time/impl/wren/format_time" for SayableTime
import "../../../time/impl/wren/locales/registry" for LocaleRegistry as TimeLocaleRegistry
import "../../../duration/impl/wren/format_duration" for SayableDuration
import "../../../duration/impl/wren/locales/registry" for LocaleRegistry as DurationLocaleRegistry

var VERSION = "0.5.0"

var HELP = "Usage: sayable <command> [arguments] [options]

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

// A usage error: the run exits 2 after reporting message (null: print help).
class UsageError {
  construct new(message) { _message = message }
  message { _message }
}

// The outcome of one command: what it would exit with and print to stdout,
// and for exit 2 the UsageError that caused it.
class RunResult {
  construct new(code, output) {
    _code = code
    _output = output
  }
  construct usage(error) {
    _code = 2
    _usageError = error
  }
  code { _code }
  output { _output }
  usageError { _usageError }
}

class Cli {
  static errorExit(msg) { Fiber.abort(UsageError.new(msg)) }

  // Today's date (YYYY-MM-DD), supplied by the wrapper.
  static today { __today }
  static today=(value) { __today = value }

  // age and stage default to today when -d is absent, null or empty.
  static referenceDate(asOf) {
    if (asOf == null || asOf == "null" || asOf == "") return today
    return asOf
  }

  static nullify(value) {
    if (value == "null") return null
    return value
  }

  // Runs one command as the one-shot CLI would, without printing or exiting.
  static run(args) {
    var fiber = Fiber.new { dispatch(args) }
    var output = fiber.try()
    if (fiber.error is UsageError) return RunResult.usage(fiber.error)
    if (fiber.error != null) Fiber.abort(fiber.error)
    if (output == null) return RunResult.new(1, null)
    return RunResult.new(0, output)
  }

  static dispatch(args) {
    if (args.count == 0) Fiber.abort(UsageError.new(null))

    // Global flags
    if (args[0] == "-h" || args[0] == "--help" || args[0] == "help") return HELP
    if (args[0] == "-v" || args[0] == "--version" || args[0] == "version") {
      return "sayable %(VERSION)"
    }

    var command = args[0]
    var positionals = []
    var locale = "en"
    var asOf = null
    var compactness = "normal"
    var gender = null
    var withYear = false

    var i = 1
    var stopOpts = false
    while (i < args.count) {
      var a = args[i]
      if (a == "--" && !stopOpts) {
        stopOpts = true
      } else if (!stopOpts && a.startsWith("-")) {
        if (a == "-l" || a == "--locale") {
          if (i + 1 >= args.count) errorExit("'%(a)' requires a value")
          i = i + 1
          locale = args[i]
        } else if (a == "-d" || a == "--as-of") {
          if (i + 1 >= args.count) errorExit("'%(a)' requires a value")
          i = i + 1
          asOf = args[i]
        } else if (a == "-g" || a == "--gender") {
          if (i + 1 >= args.count) errorExit("'%(a)' requires a value")
          i = i + 1
          gender = args[i]
        } else if (a == "--short") {
          compactness = "short"
        } else if (a == "--compact") {
          compactness = "compact"
        } else if (a == "--with-year") {
          withYear = true
        } else if (a == "-h" || a == "--help") {
          return HELP
        } else if (a == "-v" || a == "--version") {
          return "sayable %(VERSION)"
        } else {
          errorExit("unknown option '%(a)'")
        }
      } else {
        positionals.add(a)
      }
      i = i + 1
    }

    if (command == "locales") return cmdLocales()
    if (command == "age") return cmdAge(positionals, locale, asOf, compactness)
    if (command == "stage") return cmdStage(positionals, locale, asOf, compactness, gender)
    if (command == "date") return cmdDate(positionals, locale, compactness, withYear)
    if (command == "relative") return cmdRelative(positionals, locale, asOf, compactness)
    if (command == "time") return cmdTime(positionals, locale, compactness)
    if (command == "duration") return cmdDuration(positionals, locale, compactness)
    if (command == "since") return cmdSince(positionals, locale, asOf, compactness)
    if (command == "until") return cmdUntil(positionals, locale, asOf, compactness)
    errorExit("unknown command '%(command)'")
  }

  static cmdAge(positionals, localeCode, asOf, compactness) {
    if (positionals.count == 0) errorExit("age requires a date-of-birth argument")
    var dob = nullify(positionals[0])

    var loc = AgeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    asOf = referenceDate(asOf)

    var fmt = SayableAge.new(loc, compactness)
    var result = fmt.formatAge(dob, asOf)
    return result
  }

  static cmdStage(positionals, localeCode, asOf, compactness, gender) {
    if (positionals.count == 0) errorExit("stage requires a date-of-birth argument")
    var dob = nullify(positionals[0])

    var loc = AgeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    asOf = referenceDate(asOf)

    var fmt = SayableAge.new(loc, compactness)
    var result
    if (gender != null) {
      result = fmt.formatStage(dob, asOf, gender)
    } else {
      result = fmt.formatStage(dob, asOf)
    }
    return result
  }

  static cmdDate(positionals, localeCode, compactness, withYear) {
    if (positionals.count == 0) errorExit("date requires a date argument")
    var dateVal = nullify(positionals[0])

    var loc = DateLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableDate.new(loc, compactness)
    var result
    if (withYear) {
      result = fmt.formatDateWithYear(dateVal)
    } else {
      result = fmt.formatDate(dateVal)
    }
    return result
  }

  static cmdRelative(positionals, localeCode, asOf, compactness) {
    if (positionals.count == 0) errorExit("relative requires a date argument")
    var dateVal = nullify(positionals[0])

    if (asOf == null) errorExit("relative requires --as-of / -d option")
    asOf = nullify(asOf)

    var loc = DateLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableDate.new(loc, compactness)
    var result = fmt.formatRelative(dateVal, asOf)
    return result
  }

  static cmdTime(positionals, localeCode, compactness) {
    if (positionals.count == 0) errorExit("time requires a time argument")
    var timeVal = nullify(positionals[0])

    var loc = TimeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableTime.new(loc, compactness)
    var result = fmt.formatTime(timeVal)
    return result
  }

  static cmdDuration(positionals, localeCode, compactness) {
    if (positionals.count == 0) errorExit("duration requires a value argument")
    var value = nullify(positionals[0])

    var loc = DurationLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableDuration.new(loc, compactness)

    var result
    if (value == null) {
      result = fmt.formatDuration(null)
    } else {
      // Try to parse as integer
      var num = Num.fromString(value)
      if (num != null && !value.contains(".") && !value.contains("T")) {
        result = fmt.formatDuration(num)
      } else {
        // Timestamp mode
        if (positionals.count < 2) {
          errorExit("duration with timestamps requires start and end arguments")
        }
        var endVal = nullify(positionals[1])
        result = fmt.formatDuration(value, endVal)
      }
    }
    return result
  }

  static cmdSince(positionals, localeCode, asOf, compactness) {
    if (positionals.count == 0) errorExit("since requires a start timestamp argument")
    var start = nullify(positionals[0])

    if (asOf == null) errorExit("since requires --as-of / -d option")
    asOf = nullify(asOf)

    var loc = DurationLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableDuration.new(loc, compactness)
    var result = fmt.formatSince(start, asOf)
    return result
  }

  static cmdUntil(positionals, localeCode, asOf, compactness) {
    if (positionals.count == 0) errorExit("until requires a target timestamp argument")
    var target = nullify(positionals[0])

    if (asOf == null) errorExit("until requires --as-of / -d option")
    asOf = nullify(asOf)

    var loc = DurationLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableDuration.new(loc, compactness)
    var result = fmt.formatUntil(target, asOf)
    return result
  }

  static cmdLocales() {
    var codes = [
      "af", "ak", "am", "ar", "ay", "az", "bci", "be", "bem", "bg",
      "bi", "bm", "bn", "br", "bs", "ca", "cak", "ceb", "cs", "cy",
      "da", "de", "din", "dje", "dv", "dyu", "dz", "ee", "el", "en",
      "es", "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon",
      "fr", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi",
      "hmn", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "ja",
      "jv", "ka", "kbp", "kek", "ki", "kk", "kl", "km", "kn", "ko",
      "kpe", "kri", "ktu", "ku", "kw", "ky", "lb", "lg", "ln", "lo",
      "lt", "luo", "lv", "mam", "men", "mfe", "mg", "mi", "mk", "ml",
      "mn", "mnk", "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne",
      "ng", "nl", "nr", "nso", "nus", "ny", "om", "or", "pa", "pis",
      "pl", "pov", "ps", "pt", "qu", "quc", "ro", "ru", "rw", "sar",
      "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so",
      "sq", "sr", "ss", "st", "su", "suk", "sv", "sw", "ta", "te",
      "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr",
      "ts", "tum", "tzm", "uk", "umb", "ur", "uz", "ve", "vi", "vmw",
      "wo", "xh", "yao", "yo", "yue", "zdj", "zh", "zu"
    ]
    return codes.join("\n")
  }
}

// One-shot mode: report the result through the wrapper's output prefixes.
class OneShot {
  static run(args) {
    var result = Cli.run(args)
    if (result.code == 0) {
      System.print(result.output)
    } else if (result.code == 1) {
      System.print("__EXIT_1__")
      Fiber.abort("exit")
    } else if (result.usageError.message == null) {
      System.print("__EXIT_2_HELP__")
      Fiber.abort("exit")
    } else {
      System.print("__EXIT_2__%(result.usageError.message)")
      Fiber.abort("exit")
    }
  }
}

// Answers one tab-separated request per stdin line (see cli/SPEC.md).
//
// wren_cli 0.4.0 cannot tell a blank line from end of input and crashes once
// stdin closes, so the wrapper ends the input with endOfRequests instead.
class Repl {
  static endOfRequests { "\x1c" }

  static run() {
    while (true) {
      // Every line is "<today>\t<request>"; the end marker comes on its own line.
      var line = Stdin.readLine()
      if (line.endsWith(endOfRequests)) return
      if (line.endsWith("\r")) line = withoutLastByte(line)
      var fields = line.split("\t")
      Cli.today = fields[0]
      System.print(respond(fields[1..-1]))
      Stdout.flush()
    }
  }

  static respond(args) {
    var fiber = Fiber.new { Cli.run(args) }
    var result = fiber.try()
    if (fiber.error != null) {
      // A crash exits non-zero in one-shot mode; keep serving.
      stderr("%(fiber.error)")
      return "1\t"
    }
    if (result.code == 2) {
      var message = result.usageError.message
      if (message == null) {
        for (helpLine in HELP.split("\n")) stderr(helpLine)
        return "2\t"
      }
      stderr("error: %(message)")
      stderr("Run 'sayable help' for usage.")
      return "2\t"
    }
    return "%(result.code)\t%(tabbed(result.output))"
  }

  static tabbed(output) {
    if (output == null) return ""
    while (output.endsWith("\n")) output = withoutLastByte(output)
    return output.replace("\n", "\t")
  }

  static withoutLastByte(text) { text[0...(text.bytes.count - 1)] }

  static stderr(message) {
    System.print("__STDERR__%(message.replace("\n", " "))")
  }
}

// Extract user arguments (skip wren_cli and script path)
var allArgs = Process.allArguments
var userArgs = []
var idx = 2
while (idx < allArgs.count) {
  userArgs.add(allArgs[idx])
  idx = idx + 1
}

if (userArgs.count >= 2 && userArgs[0] == "--today") {
  Cli.today = userArgs[1]
  userArgs = userArgs[2..-1]
}

if (userArgs.count == 1 && userArgs[0] == "--repl") {
  Repl.run()
} else {
  OneShot.run(userArgs)
}
