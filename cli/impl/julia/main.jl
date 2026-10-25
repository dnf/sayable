#!/usr/bin/env julia

# Sayable CLI — unified command-line interface to all four Sayable components.

const SCRIPT_DIR = @__DIR__
const PROJECT_ROOT = normpath(joinpath(SCRIPT_DIR, "..", "..", ".."))

# Add component source directories to the load path
for component in ("age", "date", "duration", "time")
    src = joinpath(PROJECT_ROOT, component, "impl", "julia", "src")
    if !(src in LOAD_PATH)
        push!(LOAD_PATH, src)
    end
end

using Dates
using SayableAge
using SayableDate
using SayableTime
using SayableDuration

import SayableAge
import SayableDate
import SayableTime
import SayableDuration

const CLI_VERSION = "0.5.0"

const HELP_TEXT = """
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
  -v, --version          Show version"""

"""A usage error: its message is already on stderr; the run exits 2."""
struct UsageError <: Exception end

function cli_error(msg::String)
    println(stderr, "error: $msg")
    println(stderr, "Run 'sayable help' for usage.")
    throw(UsageError())
end

function nullify(value::String)
    value == "null" ? "" : value
end

function nullify_to_nothing(value::String)
    value == "null" ? nothing : value
end

function get_today()
    Dates.format(Dates.today(), "yyyy-mm-dd")
end

function parse_args(argv)
    isempty(argv) && return (nothing, String[], Dict{String,Any}())

    if argv[1] in ("-h", "--help", "help")
        return ("help", String[], Dict{String,Any}())
    end
    if argv[1] in ("-v", "--version", "version")
        return ("version", String[], Dict{String,Any}())
    end

    command = argv[1]
    positionals = String[]
    options = Dict{String,Any}(
        "locale" => "en",
        "as_of" => nothing,
        "compactness" => "normal",
        "gender" => nothing,
        "with_year" => false,
    )

    i = 2
    stop_opts = false
    while i <= length(argv)
        arg = argv[i]

        if arg == "--" && !stop_opts
            stop_opts = true
            i += 1
            continue
        end

        if !stop_opts && startswith(arg, "-")
            if arg in ("-l", "--locale")
                i + 1 > length(argv) && cli_error("'$arg' requires a value")
                i += 1
                options["locale"] = argv[i]
            elseif arg in ("-d", "--as-of")
                i + 1 > length(argv) && cli_error("'$arg' requires a value")
                i += 1
                options["as_of"] = argv[i]
            elseif arg in ("-g", "--gender")
                i + 1 > length(argv) && cli_error("'$arg' requires a value")
                i += 1
                options["gender"] = argv[i]
            elseif arg == "--short"
                options["compactness"] = "short"
            elseif arg == "--compact"
                options["compactness"] = "compact"
            elseif arg == "--with-year"
                options["with_year"] = true
            elseif arg in ("-h", "--help")
                return ("help", String[], Dict{String,Any}())
            elseif arg in ("-v", "--version")
                return ("version", String[], Dict{String,Any}())
            else
                cli_error("unknown option '$arg'")
            end
        else
            push!(positionals, arg)
        end

        i += 1
    end

    (command, positionals, options)
end

function age_compactness(s::String)
    s == "short" && return SayableAge.Short
    s == "compact" && return SayableAge.Compact
    SayableAge.Normal
end

function date_compactness(s::String)
    s == "short" && return SayableDate.Short
    s == "compact" && return SayableDate.Compact
    SayableDate.Normal
end

function time_compactness(s::String)
    s == "short" && return SayableTime.Short
    s == "compact" && return SayableTime.Compact
    SayableTime.Normal
end

function duration_compactness(s::String)
    s == "short" && return SayableDuration.Short
    s == "compact" && return SayableDuration.Compact
    SayableDuration.Normal
end

function cmd_age(positionals, options)
    isempty(positionals) && cli_error("age requires a date-of-birth argument")
    dob_raw = positionals[1]
    is_null = dob_raw == "null"

    locale_code = options["locale"]
    locale = SayableAge.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    as_of = options["as_of"]
    if as_of !== nothing
        as_of = as_of == "null" ? "" : as_of
    else
        as_of = get_today()
    end

    dob = is_null ? "" : dob_raw
    formatter = SayableAge.SayableAgeFormatter(locale, age_compactness(options["compactness"]))
    result = SayableAge.format_age(formatter, dob, as_of)

    result
end

function cmd_stage(positionals, options)
    isempty(positionals) && cli_error("stage requires a date-of-birth argument")
    dob_raw = positionals[1]
    is_null = dob_raw == "null"

    locale_code = options["locale"]
    locale = SayableAge.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    as_of = options["as_of"]
    if as_of !== nothing
        as_of = as_of == "null" ? "" : as_of
    else
        as_of = get_today()
    end

    gender = options["gender"]
    gender_str = gender !== nothing ? gender : ""

    dob = is_null ? "" : dob_raw
    formatter = SayableAge.SayableAgeFormatter(locale, age_compactness(options["compactness"]))
    result = SayableAge.format_stage(formatter, dob, as_of, gender_str)

    result
end

function cmd_date(positionals, options)
    isempty(positionals) && cli_error("date requires a date argument")
    date_raw = positionals[1]
    is_null = date_raw == "null"

    locale_code = options["locale"]
    locale = SayableDate.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableDate.SayableDateFormatter(locale, date_compactness(options["compactness"]))

    date_val = is_null ? "" : date_raw
    result = if options["with_year"]
        SayableDate.format_date_with_year(formatter, date_val)
    else
        SayableDate.format_date(formatter, date_val)
    end

    result
end

function cmd_relative(positionals, options)
    isempty(positionals) && cli_error("relative requires a date argument")
    date_raw = positionals[1]
    is_null = date_raw == "null"

    as_of = options["as_of"]
    as_of === nothing && cli_error("relative requires --as-of / -d option")
    as_of = as_of == "null" ? "" : as_of

    locale_code = options["locale"]
    locale = SayableDate.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableDate.SayableDateFormatter(locale, date_compactness(options["compactness"]))
    date_val = is_null ? "" : date_raw
    result = SayableDate.format_relative(formatter, date_val, as_of)

    result
end

function cmd_time(positionals, options)
    isempty(positionals) && cli_error("time requires a time argument")
    time_raw = positionals[1]
    is_null = time_raw == "null"

    locale_code = options["locale"]
    locale = SayableTime.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableTime.SayableTimeFormatter(locale, time_compactness(options["compactness"]))
    time_val = is_null ? "" : time_raw
    result = SayableTime.format_time(formatter, time_val)

    result
end

function cmd_duration(positionals, options)
    isempty(positionals) && cli_error("duration requires a value argument")
    value_raw = positionals[1]

    locale_code = options["locale"]
    locale = SayableDuration.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableDuration.SayableDurationFormatter(locale, duration_compactness(options["compactness"]))

    value_raw == "null" && return nothing

    # Check if it's an integer (possibly negative)
    is_integer = all(c -> c == '-' || isdigit(c), value_raw) && !isempty(value_raw)
    if is_integer
        seconds = parse(Int, value_raw)
        result = SayableDuration.format_duration(formatter, seconds)
    else
        # Timestamp mode
        length(positionals) < 2 && cli_error("duration with timestamps requires start and end arguments")
        end_val = positionals[2]
        end_val == "null" && (end_val = "")
        result = SayableDuration.format_duration(formatter, value_raw, end_val)
    end

    result
end

function cmd_since(positionals, options)
    isempty(positionals) && cli_error("since requires a start timestamp argument")
    start_raw = positionals[1]
    is_null = start_raw == "null"

    as_of = options["as_of"]
    as_of === nothing && cli_error("since requires --as-of / -d option")
    as_of = as_of == "null" ? "" : as_of

    locale_code = options["locale"]
    locale = SayableDuration.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableDuration.SayableDurationFormatter(locale, duration_compactness(options["compactness"]))
    start_val = is_null ? "" : start_raw
    result = SayableDuration.format_since(formatter, start_val, as_of)

    result
end

function cmd_until(positionals, options)
    isempty(positionals) && cli_error("until requires a target timestamp argument")
    target_raw = positionals[1]
    is_null = target_raw == "null"

    as_of = options["as_of"]
    as_of === nothing && cli_error("until requires --as-of / -d option")
    as_of = as_of == "null" ? "" : as_of

    locale_code = options["locale"]
    locale = SayableDuration.get_locale(locale_code)
    locale === nothing && cli_error("unknown locale '$locale_code'")

    formatter = SayableDuration.SayableDurationFormatter(locale, duration_compactness(options["compactness"]))
    target_val = is_null ? "" : target_raw
    result = SayableDuration.format_until(formatter, target_val, as_of)

    result
end

function cmd_locales()
    # Use age locales as the canonical list
    codes = String[]
    for code in ["af", "ak", "am", "ar", "ay", "az", "bci", "be", "bem", "bg", "bi", "bm",
                 "bn", "br", "bs", "ca", "cak", "ceb", "chr", "co", "cs", "cy", "da", "de",
                 "dyu", "dz", "ee", "el", "en", "eo", "es", "et", "eu", "fa", "ff", "fi",
                 "fo", "fr", "fy", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "haw", "he",
                 "hi", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "iu", "ja", "jv",
                 "ka", "kea", "ki", "kk", "kl", "km", "kn", "ko", "ku", "kw", "ky", "la",
                 "lb", "lg", "ln", "lo", "lt", "lu", "lv", "mg", "mi", "mk", "ml", "mn",
                 "mr", "ms", "mt", "my", "nb", "nd", "ne", "nl", "nn", "ny", "oc", "om",
                 "or", "pa", "pap", "pcm", "pis", "pl", "ps", "pt", "qu", "rm", "rn", "ro",
                 "ru", "rw", "sa", "sc", "sd", "se", "sg", "shi", "si", "sk", "sl", "sn",
                 "so", "sq", "sr", "ss", "st", "su", "sv", "sw", "ta", "te", "tg", "th",
                 "ti", "tk", "tl", "tn", "to", "tok", "tpi", "tr", "ts", "tt", "tw", "ty",
                 "tzm", "ug", "uk", "ur", "uz", "ve", "vi", "wa", "wo", "xh", "yi", "yo",
                 "za", "zh", "zu"]
        loc = SayableAge.get_locale(code)
        if loc !== nothing
            push!(codes, code)
        end
    end
    join(sort(codes), "\n")
end

const COMMANDS = Dict(
    "age" => cmd_age,
    "stage" => cmd_stage,
    "date" => cmd_date,
    "relative" => cmd_relative,
    "time" => cmd_time,
    "duration" => cmd_duration,
    "since" => cmd_since,
    "until" => cmd_until,
)

function dispatch(argv)
    command, positionals, options = parse_args(argv)

    command === nothing && return (2, HELP_TEXT)
    command == "help" && return (0, HELP_TEXT)
    command == "version" && return (0, "sayable $CLI_VERSION")
    command == "locales" && return (0, cmd_locales())

    haskey(COMMANDS, command) || cli_error("unknown command '$command'")

    result = COMMANDS[command](positionals, options)
    result === nothing ? (1, nothing) : (0, result)
end

"""
    run_command(argv) -> (exit_code, output)

Run one command as the one-shot CLI would, without printing or exiting.
`output` is `nothing` when the run prints nothing to stdout.
"""
function run_command(argv)
    try
        dispatch(argv)
    catch err
        err isa UsageError || rethrow()
        (2, nothing)
    end
end

function format_response(code, output)
    text = replace(rstrip(==('\n'), something(output, "")), '\n' => '\t')
    "$code\t$text\n"
end

"""Answer one tab-separated request per stdin line (see cli/SPEC.md)."""
function repl()
    for line in eachline(stdin)
        code, output = try
            run_command(String.(split(line, '\t')))
        catch err
            # A crash exits 1 in one-shot mode; keep serving.
            showerror(stderr, err, catch_backtrace())
            println(stderr)
            (1, nothing)
        end
        print(stdout, format_response(code, output))
        flush(stdout)
    end
end

function main()
    if ARGS == ["--repl"]
        repl()
        return
    end

    code, output = run_command(ARGS)
    output === nothing || println(output)
    exit(code)
end

main()
