/// Sayable CLI — unified command-line interface to all four Sayable components.
/// See cli/SPEC.md for the full specification.
module main;

import std.typecons : Nullable;
import core.stdc.stdlib : exit;

// Age
import sayableage.format_age : SayableAge;
import sayableage.locale : AgeCompactness = Compactness, AgeLocale;
import sayableage.locales : getAgeLocale = getLocale;

// Date
import sayabledate.format_date : SayableDate;
import sayabledate.locale : DateCompactness = Compactness, DateLocale;
import sayabledate.locales : getDateLocale = getLocale;

// Duration
import sayableduration.format_duration : SayableDuration;
import sayableduration.locale : DurationCompactness = Compactness, DurationLocale;
import sayableduration.locales : getDurationLocale = getLocale;

// Time
import sayabletime.format_time : SayableTime;
import sayabletime.locale : TimeCompactness = Compactness, TimeLocale;
import sayabletime.locales : getTimeLocale = getLocale;

/// Library version.
enum VERSION = "0.5.0";

/// Write to stderr.
private void writeStderr(string s) {
    import core.stdc.stdio : fprintf, stderr;
    foreach (c; s) {
        fprintf(stderr, "%c", c);
    }
    fprintf(stderr, "\n");
}

/// Write to stdout.
private void writeStdout(string s) {
    import core.stdc.stdio : printf;
    foreach (c; s) {
        printf("%c", c);
    }
    printf("\n");
}

/// Print error and exit with code 2.
private void error(string msg) {
    writeStderr("error: " ~ msg);
    writeStderr("Run 'sayable help' for usage.");
    exit(2);
}

/// Convert CLI "null" sentinel to empty string.
private string nullify(string s) {
    if (s == "null") return "";
    return s;
}

/// Check if a string is all digits (possibly with leading minus).
private bool isInteger(string s) {
    if (s.length == 0) return false;
    size_t start = 0;
    if (s[0] == '-') {
        if (s.length == 1) return false;
        start = 1;
    }
    foreach (i; start .. s.length) {
        if (s[i] < '0' || s[i] > '9') return false;
    }
    return true;
}

/// Parse int from string.
private int parseInt(string s) {
    bool neg = false;
    size_t start = 0;
    if (s[0] == '-') {
        neg = true;
        start = 1;
    }
    int n = 0;
    foreach (i; start .. s.length) {
        n = n * 10 + (s[i] - '0');
    }
    return neg ? -n : n;
}

/// Get today's date as YYYY-MM-DD.
private string getToday() {
    import core.stdc.time : time, localtime, time_t;
    time_t t = time(null);
    auto tm = localtime(&t);
    int y = tm.tm_year + 1900;
    int m = tm.tm_mon + 1;
    int d = tm.tm_mday;

    char[10] buf;
    buf[0] = cast(char)('0' + y / 1000);
    buf[1] = cast(char)('0' + (y / 100) % 10);
    buf[2] = cast(char)('0' + (y / 10) % 10);
    buf[3] = cast(char)('0' + y % 10);
    buf[4] = '-';
    buf[5] = cast(char)('0' + m / 10);
    buf[6] = cast(char)('0' + m % 10);
    buf[7] = '-';
    buf[8] = cast(char)('0' + d / 10);
    buf[9] = cast(char)('0' + d % 10);
    return buf[0 .. 10].idup;
}

/// Parsed CLI options.
struct Options {
    string locale = "en";
    string asOf;
    bool asOfSet = false;
    string compactness = "normal";
    string gender;
    bool withYear = false;
}

/// HELP text.
enum HELP = `Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version`;

void main(string[] allArgs) {
    string[] argv = allArgs[1 .. $];
    if (argv.length == 0) {
        writeStdout(HELP);
        exit(2);
    }

    // Global flags
    if (argv[0] == "-h" || argv[0] == "--help" || argv[0] == "help") {
        writeStdout(HELP);
        exit(0);
    }
    if (argv[0] == "-v" || argv[0] == "--version" || argv[0] == "version") {
        writeStdout("sayable " ~ VERSION);
        exit(0);
    }

    string command = argv[0];
    string[] positionals;
    Options opts;

    // Parse remaining arguments
    bool stopOpts = false;
    size_t i = 1;
    while (i < argv.length) {
        string arg = argv[i];

        if (arg == "--" && !stopOpts) {
            stopOpts = true;
            i++;
            continue;
        }

        if (!stopOpts && arg.length > 0 && arg[0] == '-') {
            if (arg == "-l" || arg == "--locale") {
                if (i + 1 >= argv.length) error("'" ~ arg ~ "' requires a value");
                i++;
                opts.locale = argv[i];
            } else if (arg == "-d" || arg == "--as-of") {
                if (i + 1 >= argv.length) error("'" ~ arg ~ "' requires a value");
                i++;
                opts.asOf = argv[i];
                opts.asOfSet = true;
            } else if (arg == "-g" || arg == "--gender") {
                if (i + 1 >= argv.length) error("'" ~ arg ~ "' requires a value");
                i++;
                opts.gender = argv[i];
            } else if (arg == "--short") {
                opts.compactness = "short";
            } else if (arg == "--compact") {
                opts.compactness = "compact";
            } else if (arg == "--with-year") {
                opts.withYear = true;
            } else if (arg == "-h" || arg == "--help") {
                writeStdout(HELP);
                exit(0);
            } else if (arg == "-v" || arg == "--version") {
                writeStdout("sayable " ~ VERSION);
                exit(0);
            } else {
                error("unknown option '" ~ arg ~ "'");
            }
        } else {
            positionals ~= arg;
        }
        i++;
    }

    if (command == "locales") { cmdLocales(); exit(0); }
    if (command == "age") { cmdAge(positionals, opts); return; }
    if (command == "stage") { cmdStage(positionals, opts); return; }
    if (command == "date") { cmdDate(positionals, opts); return; }
    if (command == "relative") { cmdRelative(positionals, opts); return; }
    if (command == "time") { cmdTime(positionals, opts); return; }
    if (command == "duration") { cmdDuration(positionals, opts); return; }
    if (command == "since") { cmdSince(positionals, opts); return; }
    if (command == "until") { cmdUntil(positionals, opts); return; }

    error("unknown command '" ~ command ~ "'");
}

void cmdAge(string[] positionals, Options opts) {
    if (positionals.length == 0) error("age requires a date-of-birth argument");
    string dob = nullify(positionals[0]);

    auto loc = getAgeLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    string asOf;
    if (opts.asOfSet) {
        asOf = nullify(opts.asOf);
    } else {
        asOf = getToday();
    }

    AgeCompactness comp;
    if (opts.compactness == "short") comp = AgeCompactness.short_;
    else if (opts.compactness == "compact") comp = AgeCompactness.compact;
    else comp = AgeCompactness.normal;

    auto formatter = SayableAge(*loc, comp);
    auto result = formatter.formatAge(dob, asOf);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdStage(string[] positionals, Options opts) {
    if (positionals.length == 0) error("stage requires a date-of-birth argument");
    string dob = nullify(positionals[0]);

    auto loc = getAgeLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    string asOf;
    if (opts.asOfSet) {
        asOf = nullify(opts.asOf);
    } else {
        asOf = getToday();
    }

    AgeCompactness comp;
    if (opts.compactness == "short") comp = AgeCompactness.short_;
    else if (opts.compactness == "compact") comp = AgeCompactness.compact;
    else comp = AgeCompactness.normal;

    auto formatter = SayableAge(*loc, comp);
    auto result = formatter.formatStage(dob, asOf, opts.gender);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdDate(string[] positionals, Options opts) {
    if (positionals.length == 0) error("date requires a date argument");
    string dateVal = nullify(positionals[0]);

    auto loc = getDateLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    DateCompactness comp;
    if (opts.compactness == "short") comp = DateCompactness.short_;
    else if (opts.compactness == "compact") comp = DateCompactness.compact;
    else comp = DateCompactness.normal;

    auto formatter = SayableDate(*loc, comp);
    Nullable!string result;
    if (opts.withYear) {
        result = formatter.formatDateWithYear(dateVal);
    } else {
        result = formatter.formatDate(dateVal);
    }
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdRelative(string[] positionals, Options opts) {
    if (positionals.length == 0) error("relative requires a date argument");
    string dateVal = nullify(positionals[0]);

    if (!opts.asOfSet) error("relative requires --as-of / -d option");
    string asOf = nullify(opts.asOf);

    auto loc = getDateLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    DateCompactness comp;
    if (opts.compactness == "short") comp = DateCompactness.short_;
    else if (opts.compactness == "compact") comp = DateCompactness.compact;
    else comp = DateCompactness.normal;

    auto formatter = SayableDate(*loc, comp);
    auto result = formatter.formatRelative(dateVal, asOf);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdTime(string[] positionals, Options opts) {
    if (positionals.length == 0) error("time requires a time argument");
    string timeVal = nullify(positionals[0]);

    auto loc = getTimeLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    TimeCompactness comp;
    if (opts.compactness == "short") comp = TimeCompactness.short_;
    else if (opts.compactness == "compact") comp = TimeCompactness.compact;
    else comp = TimeCompactness.normal;

    auto formatter = SayableTime(*loc, comp);
    auto result = formatter.formatTime(timeVal);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdDuration(string[] positionals, Options opts) {
    if (positionals.length == 0) error("duration requires a value argument");
    string value = nullify(positionals[0]);

    auto loc = getDurationLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    DurationCompactness comp;
    if (opts.compactness == "short") comp = DurationCompactness.short_;
    else if (opts.compactness == "compact") comp = DurationCompactness.compact;
    else comp = DurationCompactness.normal;

    auto formatter = SayableDuration(*loc, comp);

    if (value.length == 0) {
        // null input
        exit(1);
    } else if (isInteger(value)) {
        int secs = parseInt(value);
        auto result = formatter.formatDuration(secs);
        if (result.isNull) exit(1);
        writeStdout(result.get);
    } else {
        // Timestamp mode
        if (positionals.length < 2) error("duration with timestamps requires start and end arguments");
        string end = nullify(positionals[1]);
        auto result = formatter.formatDurationISO(value, end);
        if (result.isNull) exit(1);
        writeStdout(result.get);
    }
}

void cmdSince(string[] positionals, Options opts) {
    if (positionals.length == 0) error("since requires a start timestamp argument");
    string start = nullify(positionals[0]);

    if (!opts.asOfSet) error("since requires --as-of / -d option");
    string asOf = nullify(opts.asOf);

    auto loc = getDurationLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    DurationCompactness comp;
    if (opts.compactness == "short") comp = DurationCompactness.short_;
    else if (opts.compactness == "compact") comp = DurationCompactness.compact;
    else comp = DurationCompactness.normal;

    auto formatter = SayableDuration(*loc, comp);
    auto result = formatter.formatSince(start, asOf);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdUntil(string[] positionals, Options opts) {
    if (positionals.length == 0) error("until requires a target timestamp argument");
    string target = nullify(positionals[0]);

    if (!opts.asOfSet) error("until requires --as-of / -d option");
    string asOf = nullify(opts.asOf);

    auto loc = getDurationLocale(opts.locale);
    if (loc is null) error("unknown locale '" ~ opts.locale ~ "'");

    DurationCompactness comp;
    if (opts.compactness == "short") comp = DurationCompactness.short_;
    else if (opts.compactness == "compact") comp = DurationCompactness.compact;
    else comp = DurationCompactness.normal;

    auto formatter = SayableDuration(*loc, comp);
    auto result = formatter.formatUntil(target, asOf);
    if (result.isNull) exit(1);
    writeStdout(result.get);
}

void cmdLocales() {
    // Use age locales as the canonical list.
    // We need to get all locale codes; since the getLocale function uses a switch,
    // we'll enumerate by trying all common codes. Instead, just import the full
    // locale module and iterate static members.
    import sayableage.locales;
    string[] codes;
    static foreach (field; __traits(allMembers, sayableage.locales)) {{
        static if (is(typeof(__traits(getMember, sayableage.locales, field)) == immutable(AgeLocale))) {
            codes ~= __traits(getMember, sayableage.locales, field).code;
        }
    }}
    // Simple insertion sort since we can't use std.algorithm in CTFE easily
    for (size_t ii = 1; ii < codes.length; ii++) {
        string key = codes[ii];
        long j = cast(long)ii - 1;
        while (j >= 0 && codes[cast(size_t)j] > key) {
            codes[cast(size_t)(j + 1)] = codes[cast(size_t)j];
            j--;
        }
        codes[cast(size_t)(j + 1)] = key;
    }
    foreach (code; codes) {
        writeStdout(code);
    }
}
