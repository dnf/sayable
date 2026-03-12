#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import SayableAge
import SayableDate
import SayableTime
import SayableDuration

// MARK: - Constants

let VERSION = "0.5.0"

let HELP = """
Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version
"""

// MARK: - Helpers

func writeStderr(_ msg: String) {
    var data = Array((msg + "\n").utf8)
    data.withUnsafeMutableBufferPointer { buf in
        _ = write(STDERR_FILENO, buf.baseAddress, buf.count)
    }
}

func error(_ msg: String) -> Never {
    writeStderr("error: \(msg)")
    writeStderr("Run 'sayable help' for usage.")
    exit(2)
}

func nullify(_ value: String) -> String? {
    if value == "null" { return nil }
    return value
}

func getToday() -> String {
    var rawTime = time(nil)
    let timeInfo = localtime(&rawTime).pointee
    let y = Int(timeInfo.tm_year) + 1900
    let m = Int(timeInfo.tm_mon) + 1
    let d = Int(timeInfo.tm_mday)
    let yStr = String(y)
    let mStr = m < 10 ? "0\(m)" : String(m)
    let dStr = d < 10 ? "0\(d)" : String(d)
    return "\(yStr)-\(mStr)-\(dStr)"
}

// MARK: - Argument Parsing

struct Options {
    var locale: String = "en"
    var asOf: String? = nil
    var compactness: String = "normal"
    var gender: String? = nil
    var withYear: Bool = false
}

func parseArgs(_ argv: [String]) -> (String?, [String], Options) {
    if argv.isEmpty {
        return (nil, [], Options())
    }

    // Global flags that can appear as the first argument
    if argv[0] == "-h" || argv[0] == "--help" || argv[0] == "help" {
        return ("help", [], Options())
    }
    if argv[0] == "-v" || argv[0] == "--version" || argv[0] == "version" {
        return ("version", [], Options())
    }

    let command = argv[0]
    var positionals: [String] = []
    var options = Options()

    var i = 1
    var stopOpts = false
    while i < argv.count {
        let arg = argv[i]

        if arg == "--" && !stopOpts {
            stopOpts = true
            i += 1
            continue
        }

        if !stopOpts && arg.hasPrefix("-") {
            if arg == "-l" || arg == "--locale" {
                if i + 1 >= argv.count {
                    error("'\(arg)' requires a value")
                }
                i += 1
                options.locale = argv[i]
            } else if arg == "-d" || arg == "--as-of" {
                if i + 1 >= argv.count {
                    error("'\(arg)' requires a value")
                }
                i += 1
                options.asOf = argv[i]
            } else if arg == "-g" || arg == "--gender" {
                if i + 1 >= argv.count {
                    error("'\(arg)' requires a value")
                }
                i += 1
                options.gender = argv[i]
            } else if arg == "--short" {
                options.compactness = "short"
            } else if arg == "--compact" {
                options.compactness = "compact"
            } else if arg == "--with-year" {
                options.withYear = true
            } else if arg == "-h" || arg == "--help" {
                return ("help", [], Options())
            } else if arg == "-v" || arg == "--version" {
                return ("version", [], Options())
            } else {
                error("unknown option '\(arg)'")
            }
        } else {
            positionals.append(arg)
        }

        i += 1
    }

    return (command, positionals, options)
}

// MARK: - Compactness Conversion

func ageCompactness(_ s: String) -> SayableAge.Compactness {
    switch s {
    case "short": return .short
    case "compact": return .compact
    default: return .normal
    }
}

func dateCompactness(_ s: String) -> SayableDate.Compactness {
    switch s {
    case "short": return .short
    case "compact": return .compact
    default: return .normal
    }
}

func timeCompactness(_ s: String) -> SayableTime.Compactness {
    switch s {
    case "short": return .short
    case "compact": return .compact
    default: return .normal
    }
}

func durationCompactness(_ s: String) -> SayableDuration.Compactness {
    switch s {
    case "short": return .short
    case "compact": return .compact
    default: return .normal
    }
}

// MARK: - Commands

func cmdAge(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("age requires a date-of-birth argument")
    }
    let dob = nullify(positionals[0])

    let localeCode = options.locale
    guard let locale = SayableAge.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    var asOf: String?
    if let rawAsOf = options.asOf {
        asOf = nullify(rawAsOf)
    } else {
        asOf = getToday()
    }

    let formatter = SayableAgeFormatter(locale, compactness: ageCompactness(options.compactness))
    let result = formatter.formatAge(dob, asOf)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdStage(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("stage requires a date-of-birth argument")
    }
    let dob = nullify(positionals[0])

    let localeCode = options.locale
    guard let locale = SayableAge.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    var asOf: String?
    if let rawAsOf = options.asOf {
        asOf = nullify(rawAsOf)
    } else {
        asOf = getToday()
    }

    let gender = options.gender

    let formatter = SayableAgeFormatter(locale, compactness: ageCompactness(options.compactness))
    let result = formatter.formatStage(dob, asOf, gender: gender)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdDate(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("date requires a date argument")
    }
    let dateVal = nullify(positionals[0])

    let localeCode = options.locale
    guard let locale = SayableDate.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableDateFormatter(locale, compactness: dateCompactness(options.compactness))

    let result: String?
    if options.withYear {
        result = formatter.formatDateWithYear(dateVal)
    } else {
        result = formatter.formatDate(dateVal)
    }

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdRelative(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("relative requires a date argument")
    }
    let dateVal = nullify(positionals[0])

    guard let rawAsOf = options.asOf else {
        error("relative requires --as-of / -d option")
    }
    let asOf = nullify(rawAsOf)

    let localeCode = options.locale
    guard let locale = SayableDate.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableDateFormatter(locale, compactness: dateCompactness(options.compactness))
    let result = formatter.formatRelative(dateVal, asOf: asOf)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdTime(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("time requires a time argument")
    }
    let timeVal = nullify(positionals[0])

    let localeCode = options.locale
    guard let locale = SayableTime.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableTimeFormatter(locale, compactness: timeCompactness(options.compactness))
    let result = formatter.formatTime(timeVal)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdDuration(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("duration requires a value argument")
    }
    let value = nullify(positionals[0])

    let localeCode = options.locale
    guard let locale = SayableDuration.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableDurationFormatter(locale, compactness: durationCompactness(options.compactness))

    let result: String?
    if value == nil {
        result = formatter.formatDuration(nil)
    } else if isInteger(value!) {
        result = formatter.formatDuration(Int(value!))
    } else {
        // Timestamp mode: need an end argument
        if positionals.count < 2 {
            error("duration with timestamps requires start and end arguments")
        }
        let end = nullify(positionals[1])
        result = formatter.formatDuration(start: value, end: end)
    }

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func isInteger(_ s: String) -> Bool {
    // Handle negative integers
    var chars = s
    if chars.hasPrefix("-") {
        chars = String(chars.dropFirst())
    }
    if chars.isEmpty { return false }
    return chars.allSatisfy { $0 >= "0" && $0 <= "9" }
}

func cmdSince(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("since requires a start timestamp argument")
    }
    let start = nullify(positionals[0])

    guard let rawAsOf = options.asOf else {
        error("since requires --as-of / -d option")
    }
    let asOf = nullify(rawAsOf)

    let localeCode = options.locale
    guard let locale = SayableDuration.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableDurationFormatter(locale, compactness: durationCompactness(options.compactness))
    let result = formatter.formatSince(start: start, asOf: asOf)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdUntil(_ positionals: [String], _ options: Options) {
    if positionals.isEmpty {
        error("until requires a target timestamp argument")
    }
    let target = nullify(positionals[0])

    guard let rawAsOf = options.asOf else {
        error("until requires --as-of / -d option")
    }
    let asOf = nullify(rawAsOf)

    let localeCode = options.locale
    guard let locale = SayableDuration.Locales.get(localeCode) else {
        error("unknown locale '\(localeCode)'")
    }

    let formatter = SayableDurationFormatter(locale, compactness: durationCompactness(options.compactness))
    let result = formatter.formatUntil(target: target, asOf: asOf)

    if let result {
        print(result)
    } else {
        exit(1)
    }
}

func cmdLocales() {
    // Use age locales as the canonical list (all components share the same set)
    let codes = SayableAge.Locales.all.keys.sorted()
    for code in codes {
        print(code)
    }
}

// MARK: - Main

let argv = Array(CommandLine.arguments.dropFirst())
let (command, positionals, options) = parseArgs(argv)

if command == nil {
    print(HELP)
    exit(2)
}

switch command! {
case "help":
    print(HELP)
    exit(0)
case "version":
    print("sayable \(VERSION)")
    exit(0)
case "locales":
    cmdLocales()
    exit(0)
case "age":
    cmdAge(positionals, options)
case "stage":
    cmdStage(positionals, options)
case "date":
    cmdDate(positionals, options)
case "relative":
    cmdRelative(positionals, options)
case "time":
    cmdTime(positionals, options)
case "duration":
    cmdDuration(positionals, options)
case "since":
    cmdSince(positionals, options)
case "until":
    cmdUntil(positionals, options)
default:
    error("unknown command '\(command!)'")
}
