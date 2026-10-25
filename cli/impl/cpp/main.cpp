#include <algorithm>
#include <chrono>
#include <ctime>
#include <iostream>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

#include "sayableage/sayableage.hpp"
#include "sayableage/locales/locales.hpp"
#include "sayabledate/sayabledate.hpp"
#include "sayabledate/locales/locales.hpp"
#include "sayabletime/sayabletime.hpp"
#include "sayabletime/locales/locales.hpp"
#include "sayableduration/sayableduration.hpp"
#include "sayableduration/locales/locales.hpp"

static constexpr const char* VERSION = "0.5.0";

static const char* HELP_TEXT =
    "Usage: sayable <command> [arguments] [options]\n"
    "\n"
    "Commands:\n"
    "  age <dob>              Format an age\n"
    "  stage <dob>            Get developmental stage\n"
    "  date <date>            Format a calendar date\n"
    "  relative <date>        Format a relative date\n"
    "  time <time>            Format a clock time\n"
    "  duration <value> [end] Format a duration\n"
    "  since <start>          Format elapsed time\n"
    "  until <target>         Format remaining time\n"
    "  locales                List available locale codes\n"
    "  version                Show version\n"
    "  help                   Show this help\n"
    "\n"
    "Options:\n"
    "  -l, --locale <code>    Locale code (default: en)\n"
    "  -d, --as-of <value>    Reference date/timestamp\n"
    "      --short            Short compactness\n"
    "      --compact          Compact compactness\n"
    "  -g, --gender <m|f>     Gender for stage labels\n"
    "      --with-year        Include year (date only)\n"
    "  -h, --help             Show this help\n"
    "  -v, --version          Show version";

// All locale codes sorted alphabetically.
static const char* ALL_LOCALE_CODES[] = {
    "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bm",
    "bn", "br", "bs", "ca", "ceb", "cs", "cy", "da", "de", "din",
    "dje", "dyu", "ee", "el", "en", "es", "et", "eu", "fa", "fan",
    "ff", "fi", "fil", "fon", "fr", "ga", "gd", "gl", "gn", "gu",
    "gv", "ha", "he", "hi", "hr", "ht", "hu", "hy", "id", "ig",
    "is", "it", "ja", "jv", "ka", "kbp", "kk", "km", "kn", "ko",
    "kpe", "ktu", "ku", "kw", "ky", "lg", "ln", "lo", "lt", "lv",
    "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk", "mos", "mr",
    "ms", "mt", "my", "nb", "nd", "ne", "ng", "nl", "nso", "nus",
    "ny", "om", "or", "pa", "pl", "pov", "ps", "pt", "qu", "ro",
    "ru", "rw", "sar", "sd", "sg", "shi", "si", "sk", "sl", "sn",
    "snk", "so", "sq", "sr", "ss", "st", "su", "suk", "sv", "sw",
    "ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn", "tr",
    "ts", "tzm", "uk", "umb", "ur", "uz", "vi", "vmw", "wo", "xh",
    "yo", "yue", "zdj", "zh", "zu",
};
static constexpr int NUM_LOCALES = sizeof(ALL_LOCALE_CODES) / sizeof(ALL_LOCALE_CODES[0]);

// ---------- error helper ----------

// Thrown after a usage error has been reported; the invocation exits 2.
struct UsageError : std::runtime_error {
    using std::runtime_error::runtime_error;
};

[[noreturn]] static void cli_error(const std::string& msg) {
    std::cerr << "error: " << msg << "\n";
    std::cerr << "Run 'sayable help' for usage.\n";
    throw UsageError(msg);
}

// ---------- null sentinel ----------

static bool is_null(const std::string& s) {
    return s == "null";
}

// ---------- get today as YYYY-MM-DD ----------

static std::string get_today() {
    const auto now = std::chrono::system_clock::now();
    const std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm tm_buf{};
#if defined(_WIN32)
    gmtime_s(&tm_buf, &t);
#else
    gmtime_r(&t, &tm_buf);
#endif
    char buf[11];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                  tm_buf.tm_year + 1900, tm_buf.tm_mon + 1, tm_buf.tm_mday);
    return std::string(buf);
}

// ---------- integer detection ----------

static bool is_integer(const std::string& s) {
    if (s.empty()) return false;
    size_t start = 0;
    if (s[0] == '-') {
        if (s.size() == 1) return false;
        start = 1;
    }
    for (size_t i = start; i < s.size(); ++i) {
        if (s[i] < '0' || s[i] > '9') return false;
    }
    return true;
}

// ---------- parsed options ----------

struct Options {
    std::string locale = "en";
    std::string as_of;
    bool has_as_of = false;
    std::string compactness = "normal";
    std::string gender;
    bool with_year = false;
};

// ---------- argument parser ----------

struct ParseResult {
    std::string command;
    std::vector<std::string> positionals;
    Options options;
};

static ParseResult parse_args(const std::vector<std::string>& args) {
    ParseResult result;
    const auto argc = args.size();

    if (argc == 0) {
        return result;  // empty command
    }

    // Global flags as first argument
    const std::string& first = args[0];
    if (first == "-h" || first == "--help" || first == "help") {
        result.command = "help";
        return result;
    }
    if (first == "-v" || first == "--version" || first == "version") {
        result.command = "version";
        return result;
    }

    result.command = first;

    bool stop_opts = false;
    for (size_t i = 1; i < argc; ++i) {
        const std::string& arg = args[i];

        if (arg == "--" && !stop_opts) {
            stop_opts = true;
            continue;
        }

        if (!stop_opts && !arg.empty() && arg[0] == '-') {
            if (arg == "-l" || arg == "--locale") {
                if (i + 1 >= argc) cli_error("'" + arg + "' requires a value");
                ++i;
                result.options.locale = args[i];
            } else if (arg == "-d" || arg == "--as-of") {
                if (i + 1 >= argc) cli_error("'" + arg + "' requires a value");
                ++i;
                result.options.as_of = args[i];
                result.options.has_as_of = true;
            } else if (arg == "-g" || arg == "--gender") {
                if (i + 1 >= argc) cli_error("'" + arg + "' requires a value");
                ++i;
                result.options.gender = args[i];
            } else if (arg == "--short") {
                result.options.compactness = "short";
            } else if (arg == "--compact") {
                result.options.compactness = "compact";
            } else if (arg == "--with-year") {
                result.options.with_year = true;
            } else if (arg == "-h" || arg == "--help") {
                result.command = "help";
                return result;
            } else if (arg == "-v" || arg == "--version") {
                result.command = "version";
                return result;
            } else {
                cli_error("unknown option '" + arg + "'");
            }
        } else {
            result.positionals.push_back(arg);
        }
    }

    return result;
}

// ---------- compactness converters ----------

static sayableage::Compactness age_compactness(const std::string& s) {
    if (s == "short") return sayableage::Compactness::Short;
    if (s == "compact") return sayableage::Compactness::Compact;
    return sayableage::Compactness::Normal;
}

static sayabledate::Compactness date_compactness(const std::string& s) {
    if (s == "short") return sayabledate::Compactness::Short;
    if (s == "compact") return sayabledate::Compactness::Compact;
    return sayabledate::Compactness::Normal;
}

static sayabletime::Compactness time_compactness(const std::string& s) {
    if (s == "short") return sayabletime::Compactness::Short;
    if (s == "compact") return sayabletime::Compactness::Compact;
    return sayabletime::Compactness::Normal;
}

static sayableduration::Compactness duration_compactness(const std::string& s) {
    if (s == "short") return sayableduration::Compactness::Short;
    if (s == "compact") return sayableduration::Compactness::Compact;
    return sayableduration::Compactness::Normal;
}

// ---------- command handlers ----------

static int cmd_age(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("age requires a date-of-birth argument");

    const auto* locale = sayableage::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string dob = is_null(positionals[0]) ? "" : positionals[0];
    std::string as_of;
    if (opts.has_as_of) {
        as_of = is_null(opts.as_of) ? "" : opts.as_of;
    } else {
        as_of = get_today();
    }

    sayableage::SayableAge formatter(*locale, age_compactness(opts.compactness));
    auto result = formatter.format_age(dob, as_of);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_stage(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("stage requires a date-of-birth argument");

    const auto* locale = sayableage::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string dob = is_null(positionals[0]) ? "" : positionals[0];
    std::string as_of;
    if (opts.has_as_of) {
        as_of = is_null(opts.as_of) ? "" : opts.as_of;
    } else {
        as_of = get_today();
    }

    std::string gender = opts.gender;

    sayableage::SayableAge formatter(*locale, age_compactness(opts.compactness));
    auto result = formatter.format_stage(dob, as_of, gender);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_date(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("date requires a date argument");

    const auto* locale = sayabledate::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string date_val = is_null(positionals[0]) ? "" : positionals[0];

    sayabledate::SayableDate formatter(*locale, date_compactness(opts.compactness));

    std::optional<std::string> result;
    if (opts.with_year) {
        result = formatter.format_date_with_year(date_val);
    } else {
        result = formatter.format_date(date_val);
    }

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_relative(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("relative requires a date argument");

    if (!opts.has_as_of) cli_error("relative requires --as-of / -d option");

    const auto* locale = sayabledate::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string date_val = is_null(positionals[0]) ? "" : positionals[0];
    std::string as_of = is_null(opts.as_of) ? "" : opts.as_of;

    sayabledate::SayableDate formatter(*locale, date_compactness(opts.compactness));
    auto result = formatter.format_relative(date_val, as_of);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_time(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("time requires a time argument");

    const auto* locale = sayabletime::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string time_val = is_null(positionals[0]) ? "" : positionals[0];

    sayabletime::SayableTime formatter(*locale, time_compactness(opts.compactness));
    auto result = formatter.format_time(time_val);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_duration(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("duration requires a value argument");

    const auto* locale = sayableduration::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    const std::string& value_str = positionals[0];

    sayableduration::SayableDuration formatter(*locale, duration_compactness(opts.compactness));

    std::optional<std::string> result;

    if (is_null(value_str)) {
        // null input => format_duration with negative to get nullopt
        result = formatter.format_duration(-1);
    } else if (is_integer(value_str)) {
        // Seconds mode
        int seconds = std::stoi(value_str);
        result = formatter.format_duration(seconds);
    } else {
        // Timestamp mode: need an end argument
        if (positionals.size() < 2) {
            cli_error("duration with timestamps requires start and end arguments");
        }
        std::string start = value_str;
        std::string end = is_null(positionals[1]) ? "" : positionals[1];
        result = formatter.format_duration(start, end);
    }

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_since(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("since requires a start timestamp argument");

    if (!opts.has_as_of) cli_error("since requires --as-of / -d option");

    const auto* locale = sayableduration::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string start = is_null(positionals[0]) ? "" : positionals[0];
    std::string as_of = is_null(opts.as_of) ? "" : opts.as_of;

    sayableduration::SayableDuration formatter(*locale, duration_compactness(opts.compactness));
    auto result = formatter.format_since(start, as_of);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static int cmd_until(const std::vector<std::string>& positionals, const Options& opts, std::ostream& out) {
    if (positionals.empty()) cli_error("until requires a target timestamp argument");

    if (!opts.has_as_of) cli_error("until requires --as-of / -d option");

    const auto* locale = sayableduration::locales::get(opts.locale);
    if (locale == nullptr) cli_error("unknown locale '" + opts.locale + "'");

    std::string target = is_null(positionals[0]) ? "" : positionals[0];
    std::string as_of = is_null(opts.as_of) ? "" : opts.as_of;

    sayableduration::SayableDuration formatter(*locale, duration_compactness(opts.compactness));
    auto result = formatter.format_until(target, as_of);

    if (!result.has_value()) return 1;
    out << result.value() << "\n";
    return 0;
}

static void cmd_locales(std::ostream& out) {
    for (int i = 0; i < NUM_LOCALES; ++i) {
        out << ALL_LOCALE_CODES[i] << "\n";
    }
}

// ---------- dispatch ----------

static int dispatch(const std::vector<std::string>& args, std::ostream& out) {
    auto parsed = parse_args(args);

    if (parsed.command.empty()) {
        out << HELP_TEXT << "\n";
        return 2;
    }

    if (parsed.command == "help") {
        out << HELP_TEXT << "\n";
        return 0;
    }

    if (parsed.command == "version") {
        out << "sayable " << VERSION << "\n";
        return 0;
    }

    if (parsed.command == "locales") {
        cmd_locales(out);
        return 0;
    }

    const auto& pos = parsed.positionals;
    const auto& opts = parsed.options;
    if (parsed.command == "age") return cmd_age(pos, opts, out);
    if (parsed.command == "stage") return cmd_stage(pos, opts, out);
    if (parsed.command == "date") return cmd_date(pos, opts, out);
    if (parsed.command == "relative") return cmd_relative(pos, opts, out);
    if (parsed.command == "time") return cmd_time(pos, opts, out);
    if (parsed.command == "duration") return cmd_duration(pos, opts, out);
    if (parsed.command == "since") return cmd_since(pos, opts, out);
    if (parsed.command == "until") return cmd_until(pos, opts, out);
    cli_error("unknown command '" + parsed.command + "'");
}

// Runs one invocation, writing its stdout text to `out`; returns the exit code.
static int run(const std::vector<std::string>& args, std::ostream& out) {
    try {
        return dispatch(args, out);
    } catch (const UsageError&) {
        return 2;
    }
}

// ---------- REPL mode (see cli/SPEC.md) ----------

static std::vector<std::string> split_request(const std::string& line) {
    std::vector<std::string> fields;
    size_t start = 0;
    for (;;) {
        const auto tab = line.find('\t', start);
        if (tab == std::string::npos) {
            fields.push_back(line.substr(start));
            return fields;
        }
        fields.push_back(line.substr(start, tab - start));
        start = tab + 1;
    }
}

// Trailing newline dropped, inner newlines become tabs: one response line.
static std::string flatten_output(std::string text) {
    while (!text.empty() && text.back() == '\n') text.pop_back();
    std::replace(text.begin(), text.end(), '\n', '\t');
    return text;
}

static int repl() {
    std::string line;
    while (std::getline(std::cin, line)) {
        if (!line.empty() && line.back() == '\r') line.pop_back();
        std::ostringstream captured;
        int code = 1;
        try {
            code = run(split_request(line), captured);
        } catch (const std::exception& e) {
            // A one-shot run would crash here; report it and keep serving.
            std::cerr << "error: " << e.what() << "\n";
            captured.str("");
        }
        std::cout << code << '\t' << flatten_output(captured.str()) << std::endl;
    }
    return 0;
}

// ---------- main ----------

int main(int argc, char* argv[]) {
    const std::vector<std::string> args(argv + 1, argv + argc);
    if (args.size() == 1 && args[0] == "--repl") return repl();
    return run(args, std::cout);
}
