// Sayable CLI — unified command-line interface to all four Sayable components.
//
// See cli/SPEC.md for the full specification.
package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"

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

// `ok` is false after a usage error has been reported.
parse_args :: proc(argv: []string) -> (command: string, positionals: [dynamic]string, opts: Options, ok: bool) {
    positionals = make([dynamic]string)
    opts = Options{
        locale      = "en",
        compactness = "normal",
    }

    if len(argv) == 0 {
        return "", positionals, opts, true
    }

    // Global flags that can appear as the first argument
    if str_eq(argv[0], "-h") || str_eq(argv[0], "--help") || str_eq(argv[0], "help") {
        return "help", positionals, opts, true
    }
    if str_eq(argv[0], "-v") || str_eq(argv[0], "--version") || str_eq(argv[0], "version") {
        return "version", positionals, opts, true
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
                    return "", positionals, opts, false
                }
                i += 1
                opts.locale = argv[i]
            } else if str_eq(a, "-d") || str_eq(a, "--as-of") {
                if i + 1 >= len(argv) {
                    cli_error_opt(a, "requires a value")
                    return "", positionals, opts, false
                }
                i += 1
                opts.as_of = argv[i]
                opts.has_as_of = true
            } else if str_eq(a, "-g") || str_eq(a, "--gender") {
                if i + 1 >= len(argv) {
                    cli_error_opt(a, "requires a value")
                    return "", positionals, opts, false
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
                return "help", positionals, opts, true
            } else if str_eq(a, "-v") || str_eq(a, "--version") {
                return "version", positionals, opts, true
            } else {
                cli_error_msg("unknown option '", a, "'")
                return "", positionals, opts, false
            }
        } else {
            append(&positionals, a)
        }

        i += 1
    }

    return command, positionals, opts, true
}

nullify :: proc(value: string) -> (string, bool) {
    if str_eq(value, "null") {
        return "", true
    }
    return value, false
}

// The error procs report a usage error and return its exit code.
cli_error :: proc(msg: string) -> int {
    fmt.eprintln("error:", msg)
    fmt.eprintln("Run 'sayable help' for usage.")
    return 2
}

cli_error_opt :: proc(opt, msg: string) -> int {
    fmt.eprintf("error: '%s' %s\n", opt, msg)
    fmt.eprintln("Run 'sayable help' for usage.")
    return 2
}

cli_error_msg :: proc(parts: ..string) -> int {
    fmt.eprint("error: ")
    for p in parts {
        fmt.eprint(p)
    }
    fmt.eprintln()
    fmt.eprintln("Run 'sayable help' for usage.")
    return 2
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

// Seconds mode, as the reference CLI decides it: digits after any leading minus signs.
is_integer :: proc(s: string) -> bool {
    digits := strings.trim_left(s, "-")
    if len(digits) == 0 do return false
    for c in transmute([]u8)digits {
        if c < '0' || c > '9' do return false
    }
    return true
}

// Seconds as a 64-bit integer; false when malformed ("--5") or out of range,
// which is far beyond the 500-year ceiling either way.
parse_seconds :: proc(s: string) -> (i64, bool) {
    negative := len(s) > 0 && s[0] == '-'
    digits := negative ? s[1:] : s
    if len(digits) == 0 do return 0, false
    n: i64 = 0
    for c in transmute([]u8)digits {
        if c < '0' || c > '9' do return 0, false
        digit := i64(c - '0')
        if n > (max(i64) - digit) / 10 do return 0, false
        n = n * 10 + digit
    }
    return negative ? -n : n, true
}

cmd_age :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("age requires a date-of-birth argument")
    }
    dob, is_null := nullify(positionals[0])

    locale := age.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    // A missing, null or empty as-of means today, as in the reference CLI.
    as_of_val, as_of_null := nullify(opts.as_of)
    as_of := as_of_null || len(as_of_val) == 0 ? get_today() : as_of_val

    buf: [512]u8
    result: Maybe(string)
    if is_null {
        result = age.format_age(buf[:], locale, age_compactness(opts.compactness), "", as_of)
    } else {
        result = age.format_age(buf[:], locale, age_compactness(opts.compactness), dob, as_of)
    }

    return print_result(out, result)
}

cmd_stage :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("stage requires a date-of-birth argument")
    }
    dob, is_null := nullify(positionals[0])

    locale := age.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    // A missing, null or empty as-of means today, as in the reference CLI.
    as_of_val, as_of_null := nullify(opts.as_of)
    as_of := as_of_null || len(as_of_val) == 0 ? get_today() : as_of_val

    result: Maybe(string)
    if is_null {
        result = age.format_stage(locale, "", as_of, opts.gender)
    } else {
        result = age.format_stage(locale, dob, as_of, opts.gender)
    }

    return print_result(out, result)
}

cmd_date :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("date requires a date argument")
    }
    date_val, is_null := nullify(positionals[0])

    locale := date.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    val := is_null ? "" : date_val

    if opts.with_year {
        result = date.format_date_with_year(buf[:], locale, date_compactness(opts.compactness), val)
    } else {
        result = date.format_date(buf[:], locale, date_compactness(opts.compactness), val)
    }

    return print_result(out, result)
}

cmd_relative :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("relative requires a date argument")
    }
    date_val, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        return cli_error("relative requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := date.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    if is_null || as_of_null {
        result = date.format_relative(buf[:], locale, date_compactness(opts.compactness), "", "")
    } else {
        result = date.format_relative(buf[:], locale, date_compactness(opts.compactness), date_val, as_of)
    }

    return print_result(out, result)
}

cmd_time :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("time requires a time argument")
    }
    time_val, is_null := nullify(positionals[0])

    locale := tm.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    val := is_null ? "" : time_val
    result = tm.format_time(buf[:], locale, time_compactness(opts.compactness), val)

    return print_result(out, result)
}

cmd_duration :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("duration requires a value argument")
    }
    value, is_null := nullify(positionals[0])

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null {
        result = dur.format_duration_int(buf[:], locale, compact, -1)
    } else if is_integer(value) {
        seconds, seconds_ok := parse_seconds(value)
        if !seconds_ok do return 1
        result = dur.format_duration_int(buf[:], locale, compact, int(seconds))
    } else {
        // Timestamp mode: need an end argument
        if len(positionals) < 2 {
            return cli_error("duration with timestamps requires start and end arguments")
        }
        end, _ := nullify(positionals[1])
        result = dur.format_duration_iso(buf[:], locale, compact, value, end)
    }

    return print_result(out, result)
}

cmd_since :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("since requires a start timestamp argument")
    }
    start, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        return cli_error("since requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null || as_of_null {
        result = dur.format_since(buf[:], locale, compact, "", "")
    } else {
        result = dur.format_since(buf[:], locale, compact, start, as_of)
    }

    return print_result(out, result)
}

cmd_until :: proc(out: ^strings.Builder, positionals: [dynamic]string, opts: Options) -> int {
    if len(positionals) == 0 {
        return cli_error("until requires a target timestamp argument")
    }
    target, is_null := nullify(positionals[0])

    if !opts.has_as_of {
        return cli_error("until requires --as-of / -d option")
    }
    as_of, as_of_null := nullify(opts.as_of)

    locale := dur.get_locale(opts.locale)
    if locale == nil {
        return cli_error_msg("unknown locale '", opts.locale, "'")
    }

    buf: [512]u8
    result: Maybe(string)
    compact := duration_compactness(opts.compactness)

    if is_null || as_of_null {
        result = dur.format_until(buf[:], locale, compact, "", "")
    } else {
        result = dur.format_until(buf[:], locale, compact, target, as_of)
    }

    return print_result(out, result)
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

cmd_locales :: proc(out: ^strings.Builder) {
    for code in LOCALE_CODES {
        fmt.sbprintln(out, code)
    }
}

// A null result prints nothing and exits 1.
print_result :: proc(out: ^strings.Builder, result: Maybe(string)) -> int {
    v, ok := result.?
    if !ok do return 1
    fmt.sbprintln(out, v)
    return 0
}

// Runs one invocation, writing its stdout text to `out`; returns the exit code.
run :: proc(out: ^strings.Builder, args: []string) -> int {
    command, positionals, opts, ok := parse_args(args)
    defer delete(positionals)
    if !ok do return 2

    switch command {
    case "":
        fmt.sbprintln(out, HELP)
        return 2
    case "help":
        fmt.sbprintln(out, HELP)
        return 0
    case "version":
        fmt.sbprintf(out, "sayable %s\n", VERSION)
        return 0
    case "locales":
        cmd_locales(out)
        return 0
    case "age":
        return cmd_age(out, positionals, opts)
    case "stage":
        return cmd_stage(out, positionals, opts)
    case "date":
        return cmd_date(out, positionals, opts)
    case "relative":
        return cmd_relative(out, positionals, opts)
    case "time":
        return cmd_time(out, positionals, opts)
    case "duration":
        return cmd_duration(out, positionals, opts)
    case "since":
        return cmd_since(out, positionals, opts)
    case "until":
        return cmd_until(out, positionals, opts)
    }
    return cli_error_msg("unknown command '", command, "'")
}

// Answers one tab-separated request per stdin line (see cli/SPEC.md).
repl :: proc() {
    reader: bufio.Reader
    bufio.reader_init(&reader, os.to_reader(os.stdin))
    defer bufio.reader_destroy(&reader)

    for {
        line, err := bufio.reader_read_string(&reader, '\n', context.temp_allocator)
        if len(line) == 0 && err != nil do break

        request := strings.trim_suffix(strings.trim_suffix(line, "\n"), "\r")
        fields := strings.split(request, "\t", context.temp_allocator)

        out := strings.builder_make(context.temp_allocator)
        code := run(&out, fields)
        output := strings.trim_right(strings.to_string(out), "\n")
        flat, _ := strings.replace_all(output, "\n", "\t", context.temp_allocator)

        fmt.printf("%d\t%s\n", code, flat)
        os.flush(os.stdout)
        free_all(context.temp_allocator)
    }
}

main :: proc() {
    args := os.args[1:]
    if len(args) == 1 && args[0] == "--repl" {
        repl()
        return
    }

    out := strings.builder_make()
    code := run(&out, args)
    fmt.print(strings.to_string(out))
    os.exit(code)
}
