// Sayable CLI — unified command-line interface to all four Sayable components.
//
// See cli/SPEC.md for the full specification.
package main

import "core:fmt"
import "core:os"
import "core:time"
import "core:time/datetime"

import age "sayable:age/impl/odin"
import date "sayable:date/impl/odin"
import dur "sayable:duration/impl/odin"
import tm "sayable:time/impl/odin"

VERSION :: "0.5.0"

HELP :: `Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version`

Options :: struct {
    locale:      string,
    as_of:       string,
    has_as_of:   bool,
    compactness: string,
    gender:      string,
    with_year:   bool,
}

str_eq :: proc(a, b: string) -> bool {
    if len(a) != len(b) do return false
    for i := 0; i < len(a); i += 1 {
        if a[i] != b[i] do return false
    }
    return true
}

starts_with :: proc(s, prefix: string) -> bool {
    if len(s) < len(prefix) do return false
    return str_eq(s[0:len(prefix)], prefix)
}

parse_args :: proc(argv: []string) -> (command: string, positionals: [dynamic]string, opts: Options) {
    positionals = make([dynamic]string)
    opts = Options{
        locale      = "en",
        compactness = "normal",
    }

    if len(argv) == 0 {
        return "", positionals, opts
    }

    // Global flags that can appear as the first argument
    if str_eq(argv[0], "-h") || str_eq(argv[0], "--help") || str_eq(argv[0], "help") {
        return "help", positionals, opts
    }
    if str_eq(argv[0], "-v") || str_eq(argv[0], "--version") || str_eq(argv[0], "version") {
        return "version", positionals, opts
    }

    command = argv[0]
    i := 1
    stop_opts := false

    for i < len(argv) {
        a := argv[i]

        if str_eq(a, "--") && !stop_opts {
            stop_opts = true
            i += 1
            continue
        }

        if !stop_opts && len(a) > 0 && a[0] == '-' {
            if str_eq(a, "-l") || str_eq(a, "--locale") {
                if i + 1 >= len(argv) {
                    cli_error_opt(a, "requires a value")
                }
                i += 1
                opts.locale = argv[i]
            } else if str_eq(a, "-d") || str_eq(a, "--as-of") {
                if i + 1 >= len(argv) {
                    cli_error_opt(a, "requires a value")
                }
                i += 1
                opts.as_of = argv[i]
                opts.has_as_of = true
            } else if str_eq(a, "-g") || str_eq(a, "--gender") {
                if i + 1 >= len(argv) {
                    cli_error_opt(a, "requires a value")
                }
                i += 1
                opts.gender = argv[i]
            } else if str_eq(a, "--short") {
                opts.compactness = "short"
            } else if str_eq(a, "--compact") {
                opts.compactness = "compact"
            } else if str_eq(a, "--with-year") {
                opts.with_year = true
            } else if str_eq(a, "-h") || str_eq(a, "--help") {
                return "help", positionals, opts
            } else if str_eq(a, "-v") || str_eq(a, "--version") {
                return "version", positionals, opts
            } else {
                cli_error_msg("unknown option '", a, "'")
            }
        } else {
            append(&positionals, a)
        }

        i += 1
    }

    return command, positionals, opts
}

nullify :: proc(value: string) -> (string, bool) {
    if str_eq(value, "null") {
        return "", true
    }
    return value, false
}

cli_error :: proc(msg: string) -> ! {
    fmt.eprintln("error:", msg)
    fmt.eprintln("Run 'sayable help' for usage.")
    os.exit(2)
}

cli_error_opt :: proc(opt, msg: string) -> ! {
    fmt.eprintf("error: '%s' %s\n", opt, msg)
    fmt.eprintln("Run 'sayable help' for usage.")
    os.exit(2)
}

cli_error_msg :: proc(parts: ..string) -> ! {
    fmt.eprint("error: ")
    for p in parts {
        fmt.eprint(p)
    }
    fmt.eprintln()
    fmt.eprintln("Run 'sayable help' for usage.")
    os.exit(2)
}

get_today :: proc() -> string {
    now := time.now()
    y, mon, d := time.date(now)
    // Format as YYYY-MM-DD into a static buffer
    @(static) buf: [10]u8
    write_4digit(buf[:], 0, y)
    buf[4] = '-'
    write_2digit(buf[:], 5, int(mon))
    buf[7] = '-'
    write_2digit(buf[:], 8, d)
    return string(buf[:])
}

write_4digit :: proc(buf: []u8, off, val: int) {
    v := val
    buf[off + 3] = u8(v %% 10) + '0'; v /= 10
    buf[off + 2] = u8(v %% 10) + '0'; v /= 10
    buf[off + 1] = u8(v %% 10) + '0'; v /= 10
    buf[off + 0] = u8(v %% 10) + '0'
}

write_2digit :: proc(buf: []u8, off, val: int) {
    buf[off + 0] = u8(val / 10) + '0'
    buf[off + 1] = u8(val %% 10) + '0'
}

age_compactness :: proc(s: string) -> age.Compactness {
    if str_eq(s, "short") do return .Short
    if str_eq(s, "compact") do return .Compact
    return .Normal
}

date_compactness :: proc(s: string) -> date.Compactness {
    if str_eq(s, "short") do return .Short
    if str_eq(s, "compact") do return .Compact
    return .Normal
}

time_compactness :: proc(s: string) -> tm.Compactness {
    if str_eq(s, "short") do return .Short
    if str_eq(s, "compact") do return .Compact
    return .Normal
}

duration_compactness :: proc(s: string) -> dur.Compactness {
    if str_eq(s, "short") do return .Short
    if str_eq(s, "compact") do return .Compact
    return .Normal
}

is_integer :: proc(s: string) -> bool {
    if len(s) == 0 do return false
    start := 0
    if s[0] == '-' {
        start = 1
        if len(s) == 1 do return false
    }
    for i := start; i < len(s); i += 1 {
        if s[i] < '0' || s[i] > '9' do return false
    }
    return true
}

parse_int :: proc(s: string) -> int {
    negative := false
    start := 0
    if s[0] == '-' {
        negative = true
        start = 1
    }
    n := 0
    for i := start; i < len(s); i += 1 {
        n = n * 10 + int(s[i] - '0')
    }
    return negative ? -n : n
}

cmd_age :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("age requires a date-of-birth argument")
    }
    dob, is_null := nullify(positionals[0])

    locale := age.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    as_of: string
    if opts.has_as_of {
        as_of_val, as_of_null := nullify(opts.as_of)
        as_of = as_of_null ? "" : as_of_val
    } else {
        as_of = get_today()
    }

    buf: [512]u8
    result: Maybe(string)
    if is_null {
        result = age.format_age(buf[:], locale, age_compactness(opts.compactness), "", as_of)
    } else {
        result = age.format_age(buf[:], locale, age_compactness(opts.compactness), dob, as_of)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_stage :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("stage requires a date-of-birth argument")
    }
    dob, is_null := nullify(positionals[0])

    locale := age.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    as_of: string
    if opts.has_as_of {
        as_of_val, as_of_null := nullify(opts.as_of)
        as_of = as_of_null ? "" : as_of_val
    } else {
        as_of = get_today()
    }

    result: Maybe(string)
    if is_null {
        result = age.format_stage(locale, "", as_of, opts.gender)
    } else {
        result = age.format_stage(locale, dob, as_of, opts.gender)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_date :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("date requires a date argument")
    }
    date_val, is_null := nullify(positionals[0])

    locale := date.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    val := is_null ? "" : date_val

    if opts.with_year {
        result = date.format_date_with_year(buf[:], locale, date_compactness(opts.compactness), val)
    } else {
        result = date.format_date(buf[:], locale, date_compactness(opts.compactness), val)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_relative :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("relative requires a date argument")
    }
    date_val, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        cli_error("relative requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := date.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    if is_null || as_of_null {
        result = date.format_relative(buf[:], locale, date_compactness(opts.compactness), "", "")
    } else {
        result = date.format_relative(buf[:], locale, date_compactness(opts.compactness), date_val, as_of)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_time :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("time requires a time argument")
    }
    time_val, is_null := nullify(positionals[0])

    locale := tm.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    val := is_null ? "" : time_val
    result = tm.format_time(buf[:], locale, time_compactness(opts.compactness), val)

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_duration :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("duration requires a value argument")
    }
    value, is_null := nullify(positionals[0])

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null {
        result = dur.format_duration_int(buf[:], locale, compact, -1)
    } else if is_integer(value) {
        seconds := parse_int(value)
        result = dur.format_duration_int(buf[:], locale, compact, seconds)
    } else {
        // Timestamp mode: need an end argument
        if len(positionals) < 2 {
            cli_error("duration with timestamps requires start and end arguments")
        }
        end, _ := nullify(positionals[1])
        result = dur.format_duration_iso(buf[:], locale, compact, value, end)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_since :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("since requires a start timestamp argument")
    }
    start, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        cli_error("since requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null || as_of_null {
        result = dur.format_since(buf[:], locale, compact, "", "")
    } else {
        result = dur.format_since(buf[:], locale, compact, start, as_of)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

cmd_until :: proc(positionals: [dynamic]string, opts: Options) {
    if len(positionals) == 0 {
        cli_error("until requires a target timestamp argument")
    }
    target, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        cli_error("until requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null || as_of_null {
        result = dur.format_until(buf[:], locale, compact, "", "")
    } else {
        result = dur.format_until(buf[:], locale, compact, target, as_of)
    }

    if v, ok := result.?; ok {
        fmt.println(v)
    } else {
        os.exit(1)
    }
}

LOCALE_CODES :: [168]string{
    "af", "ak", "am", "ar", "ay", "az",
    "bci", "be", "bem", "bg", "bi", "bm", "bn", "br", "bs",
    "ca", "cak", "ceb", "cs", "cy",
    "da", "de", "din", "dje", "dv", "dyu", "dz",
    "ee", "el", "en", "es", "et", "eu",
    "fa", "fan", "ff", "fi", "fil", "fj", "fon", "fr",
    "ga", "gd", "gl", "gn", "gu", "gv",
    "ha", "he", "hi", "hmn", "hr", "ht", "hu", "hy",
    "id", "ig", "is", "it",
    "ja", "jv",
    "ka", "kbp", "kek", "ki", "kk", "kl", "km", "kn", "ko", "kpe", "kri", "ktu", "ku", "kw", "ky",
    "lb", "lg", "ln", "lo", "lt", "luo", "lv",
    "mam", "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr", "ms", "mt", "my",
    "nb", "nd", "ne", "ng", "nl", "nr", "nso", "nus", "ny",
    "om", "or",
    "pa", "pis", "pl", "pov", "ps", "pt",
    "qu", "quc",
    "ro", "ru", "rw",
    "sar", "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
    "ta", "te", "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr", "ts", "tum", "tzm",
    "uk", "umb", "ur", "uz",
    "ve", "vi", "vmw",
    "wo",
    "xh",
    "yao", "yo", "yue",
    "zdj", "zh", "zu",
}

cmd_locales :: proc() {
    for code in LOCALE_CODES {
        fmt.println(code)
    }
}

main :: proc() {
    args := os.args[1:]
    command, positionals, opts := parse_args(args)

    if len(command) == 0 {
        fmt.println(HELP)
        os.exit(2)
    }

    if str_eq(command, "help") {
        fmt.println(HELP)
        os.exit(0)
    }

    if str_eq(command, "version") {
        fmt.printf("sayable %s\n", VERSION)
        os.exit(0)
    }

    if str_eq(command, "locales") {
        cmd_locales()
        os.exit(0)
    }

    if str_eq(command, "age") {
        cmd_age(positionals, opts)
    } else if str_eq(command, "stage") {
        cmd_stage(positionals, opts)
    } else if str_eq(command, "date") {
        cmd_date(positionals, opts)
    } else if str_eq(command, "relative") {
        cmd_relative(positionals, opts)
    } else if str_eq(command, "time") {
        cmd_time(positionals, opts)
    } else if str_eq(command, "duration") {
        cmd_duration(positionals, opts)
    } else if str_eq(command, "since") {
        cmd_since(positionals, opts)
    } else if str_eq(command, "until") {
        cmd_until(positionals, opts)
    } else {
        cli_error_msg("unknown command '", command, "'")
    }
}
