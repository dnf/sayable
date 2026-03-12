// Sayable CLI — unified command-line interface to all four Sayable components.
// See cli/SPEC.md for the full specification.
//
// Note: wren_cli 0.4.0 has no Process.exit() or stderr support.
// Exit codes and stderr are handled by the shell wrapper (sayable).
// This script uses special output prefixes:
//   __EXIT_1__ = null result
//   __EXIT_2__<message> = usage error with message

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

class Cli {
  static errorExit(msg) {
    System.print("__EXIT_2__%(msg)")
    Fiber.abort("exit")
  }

  static nullExit() {
    System.print("__EXIT_1__")
    Fiber.abort("exit")
  }

  static nullify(value) {
    if (value == "null") return null
    return value
  }

  static run(args) {
    if (args.count == 0) {
      System.print("__EXIT_2_HELP__")
      Fiber.abort("exit")
    }

    // Global flags
    if (args[0] == "-h" || args[0] == "--help" || args[0] == "help") {
      System.print(HELP)
      return
    }
    if (args[0] == "-v" || args[0] == "--version" || args[0] == "version") {
      System.print("sayable %(VERSION)")
      return
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
          System.print(HELP)
          return
        } else if (a == "-v" || a == "--version") {
          System.print("sayable %(VERSION)")
          return
        } else {
          errorExit("unknown option '%(a)'")
        }
      } else {
        positionals.add(a)
      }
      i = i + 1
    }

    if (command == "locales") {
      cmdLocales()
      return
    }

    if (command == "age") {
      cmdAge(positionals, locale, asOf, compactness)
    } else if (command == "stage") {
      cmdStage(positionals, locale, asOf, compactness, gender)
    } else if (command == "date") {
      cmdDate(positionals, locale, compactness, withYear)
    } else if (command == "relative") {
      cmdRelative(positionals, locale, asOf, compactness)
    } else if (command == "time") {
      cmdTime(positionals, locale, compactness)
    } else if (command == "duration") {
      cmdDuration(positionals, locale, compactness)
    } else if (command == "since") {
      cmdSince(positionals, locale, asOf, compactness)
    } else if (command == "until") {
      cmdUntil(positionals, locale, asOf, compactness)
    } else {
      errorExit("unknown command '%(command)'")
    }
  }

  static cmdAge(positionals, localeCode, asOf, compactness) {
    if (positionals.count == 0) errorExit("age requires a date-of-birth argument")
    var dob = nullify(positionals[0])

    var loc = AgeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    if (asOf == null) errorExit("age requires --as-of / -d option in Wren (no system date)")
    asOf = nullify(asOf)

    var fmt = SayableAge.new(loc, compactness)
    var result = fmt.formatAge(dob, asOf)
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
  }

  static cmdStage(positionals, localeCode, asOf, compactness, gender) {
    if (positionals.count == 0) errorExit("stage requires a date-of-birth argument")
    var dob = nullify(positionals[0])

    var loc = AgeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    if (asOf == null) errorExit("stage requires --as-of / -d option in Wren (no system date)")
    asOf = nullify(asOf)

    var fmt = SayableAge.new(loc, compactness)
    var result
    if (gender != null) {
      result = fmt.formatStage(dob, asOf, gender)
    } else {
      result = fmt.formatStage(dob, asOf)
    }
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
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
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
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
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
  }

  static cmdTime(positionals, localeCode, compactness) {
    if (positionals.count == 0) errorExit("time requires a time argument")
    var timeVal = nullify(positionals[0])

    var loc = TimeLocaleRegistry.getLocale(localeCode)
    if (loc == null) errorExit("unknown locale '%(localeCode)'")

    var fmt = SayableTime.new(loc, compactness)
    var result = fmt.formatTime(timeVal)
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
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
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
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
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
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
    if (result == null) {
      nullExit()
      return
    }
    System.print(result)
  }

  static cmdLocales() {
    var codes = [
      "af", "ak", "am", "ar", "ay", "az", "bci", "be", "bem", "bg",
      "bi", "bm", "bn", "br", "bs", "ca", "cak", "ceb", "cs", "cy",
      "da", "de", "din", "dje", "dyu", "ee", "el", "en", "es", "et",
      "eu", "fa", "fan", "ff", "fi", "fil", "fon", "fr", "ga", "gd",
      "gl", "gn", "gu", "gv", "ha", "he", "hi", "hr", "ht", "hu",
      "hy", "id", "ig", "is", "it", "ja", "jv", "ka", "kbp", "kk",
      "km", "kn", "ko", "kpe", "ktu", "ku", "kw", "ky", "lg", "ln",
      "lo", "lt", "lv", "men", "mfe", "mg", "mi", "mk", "ml", "mn",
      "mnk", "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne", "ng",
      "nl", "nso", "nus", "ny", "om", "or", "pa", "pl", "pov", "ps",
      "pt", "qu", "ro", "ru", "rw", "sar", "sd", "sg", "shi", "si",
      "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su",
      "suk", "sv", "sw", "ta", "te", "tem", "tg", "th", "ti", "tig",
      "tk", "tn", "tr", "ts", "tzm", "uk", "umb", "ur", "uz", "vi",
      "vmw", "wo", "xh", "yo", "yue", "zdj", "zh", "zu"
    ]
    for (code in codes) {
      System.print(code)
    }
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

Cli.run(userArgs)
