"""Sayable CLI -- unified command-line interface to all four Sayable components.

See cli/SPEC.md for the full specification.
"""

from io.io import _fdopen
from sys import argv, exit, stderr, stdin
from sys.ffi import external_call

from sayable_age.formatter import SayableAge
from sayable_age.locales.registry import get_locale as get_age_locale
from sayable_age.locales.registry import has_locale as has_age_locale
from sayable_date.formatter import SayableDate
from sayable_date.locales.registry import get_locale as get_date_locale
from sayable_date.locales.registry import has_locale as has_date_locale
from sayable_duration.formatter import SayableDuration
from sayable_duration.locales.registry import get_locale as get_duration_locale
from sayable_duration.locales.registry import has_locale as has_duration_locale
from sayable_time.formatter import SayableTime
from sayable_time.locales.registry import get_locale as get_time_locale
from sayable_time.locales.registry import has_locale as has_time_locale

alias VERSION = "0.5.0"

alias HELP = """\
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

fn _all_locale_codes() -> List[String]:
    """Return a sorted list of all supported locale codes."""
    var codes = List[String]()
    codes.append("af")
    codes.append("ak")
    codes.append("am")
    codes.append("ar")
    codes.append("ay")
    codes.append("az")
    codes.append("bci")
    codes.append("be")
    codes.append("bem")
    codes.append("bg")
    codes.append("bi")
    codes.append("bm")
    codes.append("bn")
    codes.append("br")
    codes.append("bs")
    codes.append("ca")
    codes.append("cak")
    codes.append("ceb")
    codes.append("cs")
    codes.append("cy")
    codes.append("da")
    codes.append("de")
    codes.append("din")
    codes.append("dje")
    codes.append("dv")
    codes.append("dyu")
    codes.append("dz")
    codes.append("ee")
    codes.append("el")
    codes.append("en")
    codes.append("es")
    codes.append("et")
    codes.append("eu")
    codes.append("fa")
    codes.append("fan")
    codes.append("ff")
    codes.append("fi")
    codes.append("fil")
    codes.append("fj")
    codes.append("fon")
    codes.append("fr")
    codes.append("ga")
    codes.append("gd")
    codes.append("gl")
    codes.append("gn")
    codes.append("gu")
    codes.append("gv")
    codes.append("ha")
    codes.append("he")
    codes.append("hi")
    codes.append("hmn")
    codes.append("hr")
    codes.append("ht")
    codes.append("hu")
    codes.append("hy")
    codes.append("id")
    codes.append("ig")
    codes.append("is")
    codes.append("it")
    codes.append("ja")
    codes.append("jv")
    codes.append("ka")
    codes.append("kbp")
    codes.append("kek")
    codes.append("ki")
    codes.append("kk")
    codes.append("kl")
    codes.append("km")
    codes.append("kn")
    codes.append("ko")
    codes.append("kpe")
    codes.append("kri")
    codes.append("ktu")
    codes.append("ku")
    codes.append("kw")
    codes.append("ky")
    codes.append("lb")
    codes.append("lg")
    codes.append("ln")
    codes.append("lo")
    codes.append("lt")
    codes.append("luo")
    codes.append("lv")
    codes.append("mam")
    codes.append("men")
    codes.append("mfe")
    codes.append("mg")
    codes.append("mi")
    codes.append("mk")
    codes.append("ml")
    codes.append("mn")
    codes.append("mnk")
    codes.append("mos")
    codes.append("mr")
    codes.append("ms")
    codes.append("mt")
    codes.append("my")
    codes.append("nb")
    codes.append("nd")
    codes.append("ne")
    codes.append("ng")
    codes.append("nl")
    codes.append("nr")
    codes.append("nso")
    codes.append("nus")
    codes.append("ny")
    codes.append("om")
    codes.append("or")
    codes.append("pa")
    codes.append("pis")
    codes.append("pl")
    codes.append("pov")
    codes.append("ps")
    codes.append("pt")
    codes.append("qu")
    codes.append("quc")
    codes.append("ro")
    codes.append("ru")
    codes.append("rw")
    codes.append("sar")
    codes.append("sd")
    codes.append("sg")
    codes.append("shi")
    codes.append("shn")
    codes.append("si")
    codes.append("sk")
    codes.append("sl")
    codes.append("sn")
    codes.append("snk")
    codes.append("so")
    codes.append("sq")
    codes.append("sr")
    codes.append("ss")
    codes.append("st")
    codes.append("su")
    codes.append("suk")
    codes.append("sv")
    codes.append("sw")
    codes.append("ta")
    codes.append("te")
    codes.append("tem")
    codes.append("tet")
    codes.append("tg")
    codes.append("th")
    codes.append("ti")
    codes.append("tig")
    codes.append("tk")
    codes.append("tn")
    codes.append("tpi")
    codes.append("tr")
    codes.append("ts")
    codes.append("tum")
    codes.append("tzm")
    codes.append("uk")
    codes.append("umb")
    codes.append("ur")
    codes.append("uz")
    codes.append("ve")
    codes.append("vi")
    codes.append("vmw")
    codes.append("wo")
    codes.append("xh")
    codes.append("yao")
    codes.append("yo")
    codes.append("yue")
    codes.append("zdj")
    codes.append("zh")
    codes.append("zu")
    return codes^


fn _write_stderr(s: String):
    """Write a string followed by newline to stderr."""
    print(s, file=stderr)


alias USAGE_ERROR = "sayable: usage error"


fn _usage_error(msg: String) -> Error:
    """Print a usage error to stderr; raising the result makes the run exit 2.
    """
    _write_stderr("error: " + msg)
    _write_stderr("Run 'sayable help' for usage.")
    return Error(USAGE_ERROR)


fn _nullify(value: String) -> String:
    """Convert the CLI 'null' sentinel to empty string."""
    if value == "null":
        return ""
    return value


fn _is_all_digits(s: String) -> Bool:
    """Check if a string consists entirely of ASCII digits."""
    if len(s) == 0:
        return False
    for i in range(len(s)):
        var c = s[i : i + 1]
        if c != "0" and c != "1" and c != "2" and c != "3" and c != "4" and c != "5" and c != "6" and c != "7" and c != "8" and c != "9":
            return False
    return True


fn _str_to_int(s: String) -> Int:
    """Parse a non-negative integer from a string of digits."""
    var result = 0
    for i in range(len(s)):
        var c = s[i : i + 1]
        if c == "0":
            result = result * 10
        elif c == "1":
            result = result * 10 + 1
        elif c == "2":
            result = result * 10 + 2
        elif c == "3":
            result = result * 10 + 3
        elif c == "4":
            result = result * 10 + 4
        elif c == "5":
            result = result * 10 + 5
        elif c == "6":
            result = result * 10 + 6
        elif c == "7":
            result = result * 10 + 7
        elif c == "8":
            result = result * 10 + 8
        elif c == "9":
            result = result * 10 + 9
    return result


fn _zfill2(n: Int) -> String:
    """Zero-pad an integer to 2 digits."""
    if n < 10:
        return "0" + String(n)
    return String(n)


fn _get_today() -> String:
    """Get today's date as YYYY-MM-DD using C time() and epoch arithmetic."""
    # C time() returns seconds since Unix epoch (1970-01-01 00:00:00 UTC).
    # Its pointer argument is optional; passing 0 (NULL) avoids needing a
    # typed null pointer, whose origin parameters vary between Mojo versions.
    var epoch_seconds = Int(external_call["time", Int64, Int](0))
    var total_days = epoch_seconds // 86400

    # Convert days since Unix epoch (1970-01-01) to date
    # Howard Hinnant's civil_from_days algorithm
    var days = total_days
    # Shift to March-based year (Mar 1 = day 0)
    days += 719468
    var era = days // 146097
    if days < 0:
        era = (days - 146096) // 146097
    var doe = days - era * 146097
    var yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    var y = yoe + era * 400
    var doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    var mp = (5 * doy + 2) // 153
    var d = doy - (153 * mp + 2) // 5 + 1
    var m = mp + 3
    if mp >= 10:
        m = mp - 9
    if m <= 2:
        y += 1

    return String(y) + "-" + _zfill2(m) + "-" + _zfill2(d)


struct ParsedArgs(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Parsed command-line arguments."""

    var command: String
    var pos0: String
    var pos1: String
    var num_positionals: Int
    var locale: String
    var as_of: String
    var has_as_of: Bool
    var compactness: String
    var gender: String
    var has_gender: Bool
    var with_year: Bool

    fn __init__(out self):
        self.command = ""
        self.pos0 = ""
        self.pos1 = ""
        self.num_positionals = 0
        self.locale = "en"
        self.as_of = ""
        self.has_as_of = False
        self.compactness = "normal"
        self.gender = ""
        self.has_gender = False
        self.with_year = False


fn _parse_args(args: List[String]) raises -> ParsedArgs:
    """Parse CLI arguments (without the program name) into structured form."""
    var result = ParsedArgs()
    var argc = len(args)

    if argc < 1:
        result.command = ""
        return result

    # Global flags that can appear as the first argument
    var first = args[0]
    if first == "-h" or first == "--help" or first == "help":
        result.command = "help"
        return result
    if first == "-v" or first == "--version" or first == "version":
        result.command = "version"
        return result

    result.command = first

    var i = 1
    var stop_opts = False
    while i < argc:
        var arg = args[i]

        if arg == "--" and not stop_opts:
            stop_opts = True
            i += 1
            continue

        if not stop_opts and len(arg) > 0 and arg[0:1] == "-":
            if arg == "-l" or arg == "--locale":
                if i + 1 >= argc:
                    raise _usage_error("'" + arg + "' requires a value")
                i += 1
                result.locale = args[i]
            elif arg == "-d" or arg == "--as-of":
                if i + 1 >= argc:
                    raise _usage_error("'" + arg + "' requires a value")
                i += 1
                result.as_of = args[i]
                result.has_as_of = True
            elif arg == "-g" or arg == "--gender":
                if i + 1 >= argc:
                    raise _usage_error("'" + arg + "' requires a value")
                i += 1
                result.gender = args[i]
                result.has_gender = True
            elif arg == "--short":
                result.compactness = "short"
            elif arg == "--compact":
                result.compactness = "compact"
            elif arg == "--with-year":
                result.with_year = True
            elif arg == "-h" or arg == "--help":
                result.command = "help"
                return result
            elif arg == "-v" or arg == "--version":
                result.command = "version"
                return result
            else:
                raise _usage_error("unknown option '" + arg + "'")
        else:
            if result.num_positionals == 0:
                result.pos0 = arg
            elif result.num_positionals == 1:
                result.pos1 = arg
            result.num_positionals += 1

        i += 1

    return result


fn _cmd_age(args: ParsedArgs) raises -> String:
    """Handle the 'age' command."""
    if args.num_positionals < 1:
        raise _usage_error("age requires a date-of-birth argument")

    var dob = _nullify(args.pos0)
    var locale_code = args.locale

    if not has_age_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_age_locale(locale_code)

    var as_of: String
    if args.has_as_of:
        as_of = _nullify(args.as_of)
    else:
        as_of = _get_today()

    var formatter = SayableAge(locale, compactness=args.compactness)
    var result = formatter.format_age(dob, as_of)

    return result


fn _cmd_stage(args: ParsedArgs) raises -> String:
    """Handle the 'stage' command."""
    if args.num_positionals < 1:
        raise _usage_error("stage requires a date-of-birth argument")

    var dob = _nullify(args.pos0)
    var locale_code = args.locale

    if not has_age_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_age_locale(locale_code)

    var as_of: String
    if args.has_as_of:
        as_of = _nullify(args.as_of)
    else:
        as_of = _get_today()

    var gender: String
    if args.has_gender:
        gender = args.gender
    else:
        gender = ""

    var formatter = SayableAge(locale, compactness=args.compactness)
    var result = formatter.format_stage(dob, as_of, gender)

    return result


fn _cmd_date(args: ParsedArgs) raises -> String:
    """Handle the 'date' command."""
    if args.num_positionals < 1:
        raise _usage_error("date requires a date argument")

    var date_val = _nullify(args.pos0)
    var locale_code = args.locale

    if not has_date_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_date_locale(locale_code)
    var formatter = SayableDate(locale, compactness=args.compactness)

    var result: String
    if args.with_year:
        result = formatter.format_date_with_year(date_val)
    else:
        result = formatter.format_date(date_val)

    return result


fn _cmd_relative(args: ParsedArgs) raises -> String:
    """Handle the 'relative' command."""
    if args.num_positionals < 1:
        raise _usage_error("relative requires a date argument")

    var date_val = _nullify(args.pos0)

    if not args.has_as_of:
        raise _usage_error("relative requires --as-of / -d option")
    var as_of = _nullify(args.as_of)

    var locale_code = args.locale
    if not has_date_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_date_locale(locale_code)
    var formatter = SayableDate(locale, compactness=args.compactness)
    var result = formatter.format_relative(date_val, as_of)

    return result


fn _cmd_time(args: ParsedArgs) raises -> String:
    """Handle the 'time' command."""
    if args.num_positionals < 1:
        raise _usage_error("time requires a time argument")

    var time_val = _nullify(args.pos0)
    var locale_code = args.locale

    if not has_time_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_time_locale(locale_code)
    var formatter = SayableTime(locale, compactness=args.compactness)
    var result = formatter.format_time(time_val)

    return result


comptime MAX_INT64_SAFE_DIGITS = 18


fn _is_negative_int(s: String) -> Bool:
    """Check if string is a negative integer like '-1'."""
    if len(s) < 2:
        return False
    if s[0:1] != "-":
        return False
    return _is_all_digits(String(s[1:]))


fn _cmd_duration(args: ParsedArgs) raises -> String:
    """Handle the 'duration' command."""
    if args.num_positionals < 1:
        raise _usage_error("duration requires a value argument")

    var value = args.pos0
    var locale_code = args.locale

    if not has_duration_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_duration_locale(locale_code)
    var formatter = SayableDuration(locale, compactness=args.compactness)

    var result: String

    if value == "null":
        result = formatter.format_duration_seconds(-1)
    elif _is_negative_int(value):
        # Any negative duration has no value
        result = formatter.format_duration_seconds(-1)
    elif _is_all_digits(value):
        if len(value) > MAX_INT64_SAFE_DIGITS:
            # Far past the 500-year ceiling, and too long for 64 bits
            result = ""
        else:
            result = formatter.format_duration_seconds(_str_to_int(value))
    else:
        # Timestamp mode: need an end argument
        if args.num_positionals < 2:
            raise _usage_error("duration with timestamps requires start and end arguments")
        var end = _nullify(args.pos1)
        result = formatter.format_duration_iso(value, end)

    return result


fn _cmd_since(args: ParsedArgs) raises -> String:
    """Handle the 'since' command."""
    if args.num_positionals < 1:
        raise _usage_error("since requires a start timestamp argument")

    var start = _nullify(args.pos0)

    if not args.has_as_of:
        raise _usage_error("since requires --as-of / -d option")
    var as_of = _nullify(args.as_of)

    var locale_code = args.locale
    if not has_duration_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_duration_locale(locale_code)
    var formatter = SayableDuration(locale, compactness=args.compactness)
    var result = formatter.format_since(start, as_of)

    return result


fn _cmd_until(args: ParsedArgs) raises -> String:
    """Handle the 'until' command."""
    if args.num_positionals < 1:
        raise _usage_error("until requires a target timestamp argument")

    var target = _nullify(args.pos0)

    if not args.has_as_of:
        raise _usage_error("until requires --as-of / -d option")
    var as_of = _nullify(args.as_of)

    var locale_code = args.locale
    if not has_duration_locale(locale_code):
        raise _usage_error("unknown locale '" + locale_code + "'")

    var locale = get_duration_locale(locale_code)
    var formatter = SayableDuration(locale, compactness=args.compactness)
    var result = formatter.format_until(target, as_of)

    return result


fn _locales_text() -> String:
    """List every locale code, one per line."""
    var codes = _all_locale_codes()
    var text = String()
    for i in range(len(codes)):
        if i > 0:
            text += "\n"
        text += codes[i]
    return text


struct RunResult(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """What one command would exit with and print to stdout."""

    var code: Int
    var output: String

    fn __init__(out self, code: Int, output: String):
        self.code = code
        self.output = output


fn _dispatch(argv: List[String]) raises -> RunResult:
    """Run one command; usage errors are raised."""
    var args = _parse_args(argv)

    if len(args.command) == 0:
        return RunResult(2, HELP)
    if args.command == "help":
        return RunResult(0, HELP)
    if args.command == "version":
        return RunResult(0, "sayable " + VERSION)
    if args.command == "locales":
        return RunResult(0, _locales_text())

    var result: String
    if args.command == "age":
        result = _cmd_age(args)
    elif args.command == "stage":
        result = _cmd_stage(args)
    elif args.command == "date":
        result = _cmd_date(args)
    elif args.command == "relative":
        result = _cmd_relative(args)
    elif args.command == "time":
        result = _cmd_time(args)
    elif args.command == "duration":
        result = _cmd_duration(args)
    elif args.command == "since":
        result = _cmd_since(args)
    elif args.command == "until":
        result = _cmd_until(args)
    else:
        raise _usage_error("unknown command '" + args.command + "'")

    if len(result) == 0:
        return RunResult(1, "")
    return RunResult(0, result)


fn _run(argv: List[String]) raises -> RunResult:
    """Run one command as the one-shot CLI would, without printing or exiting.
    """
    try:
        return _dispatch(argv)
    except e:
        if String(e) == USAGE_ERROR:
            return RunResult(2, "")
        raise e^


fn _split_fields(line: String) -> List[String]:
    """Split a request on tabs, keeping empty fields."""
    var fields = List[String]()
    for field in line.split("\t"):
        fields.append(String(field))
    return fields^


fn _strip_line_ending(line: String) -> String:
    """Drop the trailing newline (and carriage return) from a request."""
    var end = len(line)
    while end > 0 and (line[end - 1 : end] == "\n" or line[end - 1 : end] == "\r"):
        end -= 1
    return String(line[0:end])


fn _repl():
    """Answer one tab-separated request per stdin line (see cli/SPEC.md)."""
    # input() opens a fresh buffered stream on every call and drops whatever
    # it read past the first line, so piped requests would be lost. One
    # stream kept open for the whole session reads every line.
    var reader = _fdopen["r"](stdin)
    while True:
        var line: String
        try:
            line = reader.readline()
        except:
            return  # end of input

        var response: String
        try:
            var result = _run(_split_fields(_strip_line_ending(line)))
            response = String(result.code) + "\t" + result.output.replace("\n", "\t")
        except e:
            # A crash exits 1 in one-shot mode; keep serving.
            _write_stderr(String(e))
            response = "1\t"
        print(response, flush=True)


fn main() raises:
    """Entry point for the sayable CLI."""
    var args = argv()
    var user_args = List[String]()
    for i in range(1, len(args)):
        user_args.append(String(args[i]))

    if len(user_args) == 1 and user_args[0] == "--repl":
        _repl()
        return

    var result = _run(user_args)
    if len(result.output) > 0:
        print(result.output)
    exit(result.code)
