// Sayable CLI — Goose implementation. See cli/SPEC.md.

import sayableage from "../../../age/impl/goose/sayableage";
import sayabledate from "../../../date/impl/goose/sayabledate";
import sayableduration from "../../../duration/impl/goose/sayableduration";
import sayabletime from "../../../time/impl/goose/sayabletime";
import std;
import os;

let VERSION = "0.5.0";

let HELP_LINES = [
    "Usage: sayable <command> [arguments] [options]",
    "",
    "Commands:",
    "  age <dob>              Format an age",
    "  stage <dob>            Get developmental stage",
    "  date <date>            Format a calendar date",
    "  relative <date>        Format a relative date",
    "  time <time>            Format a clock time",
    "  duration <value> [end] Format a duration",
    "  since <start>          Format elapsed time",
    "  until <target>         Format remaining time",
    "  locales                List available locale codes",
    "  version                Show version",
    "  help                   Show this help",
    "",
    "Options:",
    "  -l, --locale <code>    Locale code (default: en)",
    "  -d, --as-of <value>    Reference date/timestamp",
    "      --short            Short compactness",
    "      --compact          Compact compactness",
    "  -g, --gender <m|f>     Gender for stage labels",
    "      --with-year        Include year (date only)",
    "  -h, --help             Show this help",
    "  -v, --version          Show version",
];

fn append_help(out: u8[>..]&) {
    for line in HELP_LINES {
        out.append(line);
        out.push('\n');
    }
}

let EXIT_OK = 0;
let EXIT_NULL = 1;
let EXIT_USAGE = 2;

enum Compactness { Normal, Short, Compact }

// Options are views into the request's arguments, which outlive them.
struct Options {
    locale: const u8[:] = "en",
    has_as_of: bool = false,
    as_of: const u8[:] = "",
    compactness: Compactness = Compactness.Normal,
    gender: const u8[:] = "",
    with_year: bool = false,
}

fn usage_error(message: u8[:]) -> i64 {
    write_stderr(str("error: ", message, "\nRun 'sayable help' for usage.\n"));
    return EXIT_USAGE;
}

// The literal argument "null" stands for a null input, which every
// library function answers with no value; "" does the same here.
fn nullify(value: u8[:]) -> u8[:] {
    if value == "null" { return ""; }
    return value;
}

fn is_leap_year(year: i64) -> bool { (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 }

fn days_in_month(year: i64, month: i64) -> i64 {
    match month {
        2 => if is_leap_year(year) { 29 } else { 28 },
        4, 6, 9, 11 => 30,
        _ => 31,
    }
}

// Today's date (UTC) as YYYY-MM-DD, for age and stage without -d.
fn today() -> u8[>..] {
    var days = (time() / 86400.0) as i64;
    var year = 1970;
    loop {
        let year_days = if is_leap_year(year) { 366 } else { 365 };
        if days < year_days { break; }
        days -= year_days;
        year += 1;
    }
    var month = 1;
    while days >= days_in_month(year, month) {
        days -= days_in_month(year, month);
        month += 1;
    }
    var out: u8[>..] = [];
    format_int(out, year, 10, 4, '0');
    out.push('-');
    format_int(out, month, 10, 2, '0');
    out.push('-');
    format_int(out, days + 1, 10, 2, '0');
    return out;
}

fn is_integer(value: u8[:]) -> bool {
    var digits = 0;
    for c, i in value {
        if c == '-' && i == 0 { continue; }
        if c < '0' || c > '9' { return false; }
        digits += 1;
    }
    return digits > 0;
}

fn emit(out: u8[>..]&, result: u8[:], ok: bool) -> i64 {
    guard ok else { return EXIT_NULL; }
    out.append(result);
    out.push('\n');
    return EXIT_OK;
}

fn age_compactness(c: Compactness) -> sayableage::Compactness {
    match c { Normal => sayableage::Compactness.Normal, Short => sayableage::Compactness.Short, Compact => sayableage::Compactness.Compact }
}
fn date_compactness(c: Compactness) -> sayabledate::Compactness {
    match c { Normal => sayabledate::Compactness.Normal, Short => sayabledate::Compactness.Short, Compact => sayabledate::Compactness.Compact }
}
fn duration_compactness(c: Compactness) -> sayableduration::Compactness {
    match c { Normal => sayableduration::Compactness.Normal, Short => sayableduration::Compactness.Short, Compact => sayableduration::Compactness.Compact }
}
fn time_compactness(c: Compactness) -> sayabletime::Compactness {
    match c { Normal => sayabletime::Compactness.Normal, Short => sayabletime::Compactness.Short, Compact => sayabletime::Compactness.Compact }
}

// ---- Commands: each writes its stdout to `out` and returns the exit code ----

fn cmd_age(out: u8[>..]&, value: u8[:], o: Options&, stage: bool) -> i64 {
    let locale, found = sayableage::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    var as_of: u8[>..] = [];
    if o.has_as_of { as_of.append(nullify(o.as_of)); } else { as_of.append(today()); }
    if stage {
        let label, ok = sayableage::format_stage(locale, nullify(value), as_of, o.gender);
        return emit(out, label, ok);
    }
    let result, ok = sayableage::format_age(locale, age_compactness(o.compactness), nullify(value), as_of);
    return emit(out, result, ok);
}

fn cmd_date(out: u8[>..]&, value: u8[:], o: Options&) -> i64 {
    let locale, found = sayabledate::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    let compactness = date_compactness(o.compactness);
    if o.with_year {
        let result, ok = sayabledate::format_date_with_year(locale, compactness, nullify(value));
        return emit(out, result, ok);
    }
    let result, ok = sayabledate::format_date(locale, compactness, nullify(value));
    return emit(out, result, ok);
}

fn cmd_relative(out: u8[>..]&, value: u8[:], o: Options&) -> i64 {
    guard o.has_as_of else { return usage_error("relative requires --as-of / -d option"); }
    let locale, found = sayabledate::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    let result, ok = sayabledate::format_relative(locale, date_compactness(o.compactness), nullify(value), nullify(o.as_of));
    return emit(out, result, ok);
}

fn cmd_time(out: u8[>..]&, value: u8[:], o: Options&) -> i64 {
    let locale, found = sayabletime::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    let result, ok = sayabletime::format_time(locale, time_compactness(o.compactness), nullify(value));
    return emit(out, result, ok);
}

fn cmd_duration(out: u8[>..]&, value: u8[:], end: u8[:], has_end: bool, o: Options&) -> i64 {
    let locale, found = sayableduration::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    let compactness = duration_compactness(o.compactness);
    if value == "null" { return EXIT_NULL; }
    if is_integer(value) {
        let seconds, parsed = parse_int(value);
        guard parsed else { return EXIT_NULL; }
        let result, ok = sayableduration::format_duration(locale, compactness, seconds);
        return emit(out, result, ok);
    }
    guard has_end else { return usage_error("duration with timestamps requires start and end arguments"); }
    let result, ok = sayableduration::format_duration_iso(locale, compactness, value, nullify(end));
    return emit(out, result, ok);
}

fn cmd_since_until(out: u8[>..]&, command: u8[:], value: u8[:], o: Options&) -> i64 {
    guard o.has_as_of else { return usage_error(str(command, " requires --as-of / -d option")); }
    let locale, found = sayableduration::get_locale(o.locale);
    guard found else { return usage_error(str("unknown locale '", o.locale, "'")); }
    let compactness = duration_compactness(o.compactness);
    if command == "since" {
        let result, ok = sayableduration::format_since(locale, compactness, nullify(value), nullify(o.as_of));
        return emit(out, result, ok);
    }
    let result, ok = sayableduration::format_until(locale, compactness, nullify(value), nullify(o.as_of));
    return emit(out, result, ok);
}

fn cmd_locales(out: u8[>..]&) -> i64 {
    for code in sayableage::LOCALE_CODES {
        out.append(code);
        out.push('\n');
    }
    return EXIT_OK;
}

fn missing_argument(command: u8[:]) -> u8[>..] {
    if command == "age" || command == "stage" { return str(command, " requires a date-of-birth argument"); }
    if command == "date" || command == "relative" { return str(command, " requires a date argument"); }
    if command == "time" { return str("time requires a time argument"); }
    if command == "duration" { return str("duration requires a value argument"); }
    if command == "since" { return str("since requires a start timestamp argument"); }
    return str("until requires a target timestamp argument");
}

// Run one command line (without the program name); returns the exit code.
fn run(out: u8[>..]&, argv) -> i64 {
    if argv.len == 0 {
        append_help(out);
        return EXIT_USAGE;
    }
    let first = argv[0];
    if first == "-h" || first == "--help" || first == "help" { append_help(out); return EXIT_OK; }
    if first == "-v" || first == "--version" || first == "version" { out.append(str("sayable ", VERSION, "\n")); return EXIT_OK; }

    var o = Options { .. };
    var positionals: (const u8[:])[>..] = [];
    var stop_options = false;
    var i = 1;
    while i < argv.len {
        let arg = argv[i];
        i += 1;
        if arg == "--" && !stop_options { stop_options = true; continue; }
        if stop_options || arg.len == 0 || arg[0] != '-' { positionals.push(arg); continue; }
        if arg == "-l" || arg == "--locale" || arg == "-d" || arg == "--as-of" || arg == "-g" || arg == "--gender" {
            guard i < argv.len else { return usage_error(str("'", arg, "' requires a value")); }
            let value = argv[i];
            i += 1;
            if arg == "-l" || arg == "--locale" { o.locale = value; }
            else if arg == "-d" || arg == "--as-of" { o.has_as_of = true; o.as_of = value; }
            else { o.gender = value; }
        } else if arg == "--short" { o.compactness = Compactness.Short; }
        else if arg == "--compact" { o.compactness = Compactness.Compact; }
        else if arg == "--with-year" { o.with_year = true; }
        else if arg == "-h" || arg == "--help" { append_help(out); return EXIT_OK; }
        else if arg == "-v" || arg == "--version" { out.append(str("sayable ", VERSION, "\n")); return EXIT_OK; }
        else { return usage_error(str("unknown option '", arg, "'")); }
    }

    let command = first;
    if command == "locales" { return cmd_locales(out); }
    let known = command == "age" || command == "stage" || command == "date" || command == "relative"
        || command == "time" || command == "duration" || command == "since" || command == "until";
    guard known else { return usage_error(str("unknown command '", command, "'")); }
    guard positionals.len > 0 else { return usage_error(missing_argument(command)); }
    let value = positionals[0];

    if command == "age" { return cmd_age(out, value, o, false); }
    if command == "stage" { return cmd_age(out, value, o, true); }
    if command == "date" { return cmd_date(out, value, o); }
    if command == "relative" { return cmd_relative(out, value, o); }
    if command == "time" { return cmd_time(out, value, o); }
    if command == "duration" {
        let has_end = positionals.len > 1;
        return cmd_duration(out, value, if has_end { positionals[1] } else { "" }, has_end, o);
    }
    return cmd_since_until(out, command, value, o);
}

// Answer one tab-separated request per stdin line with "<exit>\t<output>",
// flushing each line (cli/SPEC.md, REPL Mode).
fn repl() {
    var line: u8[>..] = [];
    while read_line(line) {
        if line.len > 0 && line[line.len - 1] == '\r' { line.pop(); }
        let request = split(line, '\t');
        var out: u8[>..] = [];
        let code = run(out, request);
        var response: u8[>..] = [];
        format(response, code);
        response.push('\t');
        var end = out.len;
        while end > 0 && out[end - 1] == '\n' { end -= 1; }
        for c in out[..end] { response.push(if c == '\n' { '\t' } else { c }); }
        response.push('\n');
        write_stdout(response);
        flush_stdout();
        line.clear();
    }
}

fn main() {
    let argv = args();
    if argv.len == 2 && argv[1] == "--repl" {
        repl();
        return;
    }
    var out: u8[>..] = [];
    let code = run(out, argv[1..]);
    write_stdout(out);
    exit(code);
}
