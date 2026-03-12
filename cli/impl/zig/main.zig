// Sayable CLI — unified command-line interface to all four Sayable components.
// See cli/SPEC.md for the full specification.

const std = @import("std");
const sayableage = @import("sayableage");
const sayabledate = @import("sayabledate");
const sayabletime = @import("sayabletime");
const sayableduration = @import("sayableduration");

const VERSION = "0.5.0";

const HELP =
    \\Usage: sayable <command> [arguments] [options]
    \\
    \\Commands:
    \\  age <dob>              Format an age
    \\  stage <dob>            Get developmental stage
    \\  date <date>            Format a calendar date
    \\  relative <date>        Format a relative date
    \\  time <time>            Format a clock time
    \\  duration <value> [end] Format a duration
    \\  since <start>          Format elapsed time
    \\  until <target>         Format remaining time
    \\  locales                List available locale codes
    \\  version                Show version
    \\  help                   Show this help
    \\
    \\Options:
    \\  -l, --locale <code>    Locale code (default: en)
    \\  -d, --as-of <value>    Reference date/timestamp
    \\      --short            Short compactness
    \\      --compact          Compact compactness
    \\  -g, --gender <m|f>     Gender for stage labels
    \\      --with-year        Include year (date only)
    \\  -h, --help             Show this help
    \\  -v, --version          Show version
    \\
;

// ---- Argument parsing ----

const Command = enum {
    help,
    version,
    locales,
    age,
    stage,
    date,
    relative,
    time_cmd,
    duration,
    since,
    until,
};

const CompactnessOpt = enum {
    normal,
    short_mode,
    compact,
};

const MAX_POSITIONALS = 8;

const Args = struct {
    command: ?Command = null,
    positionals: [MAX_POSITIONALS][]const u8 = undefined,
    pos_count: usize = 0,
    locale: []const u8 = "en",
    as_of: ?[]const u8 = null,
    gender: ?[]const u8 = null,
    compactness: CompactnessOpt = .normal,
    with_year: bool = false,
};

fn streql(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |ca, cb| {
        if (ca != cb) return false;
    }
    return true;
}

fn parseCommand(s: []const u8) ?Command {
    if (streql(s, "help") or streql(s, "-h") or streql(s, "--help")) return .help;
    if (streql(s, "version") or streql(s, "-v") or streql(s, "--version")) return .version;
    if (streql(s, "locales")) return .locales;
    if (streql(s, "age")) return .age;
    if (streql(s, "stage")) return .stage;
    if (streql(s, "date")) return .date;
    if (streql(s, "relative")) return .relative;
    if (streql(s, "time")) return .time_cmd;
    if (streql(s, "duration")) return .duration;
    if (streql(s, "since")) return .since;
    if (streql(s, "until")) return .until;
    return null;
}

const ParseResult = enum {
    ok,
    usage_error,
};

/// Convert a sentinel-terminated pointer to a slice.
fn span(ptr: [*:0]u8) []const u8 {
    return std.mem.span(@as([*:0]const u8, ptr));
}

fn parseArgs(raw_argv: [][*:0]u8, args: *Args) ParseResult {
    if (raw_argv.len < 2) return .usage_error;

    const first = span(raw_argv[1]);
    // Global flags as first argument
    if (streql(first, "-h") or streql(first, "--help") or streql(first, "help")) {
        args.command = .help;
        return .ok;
    }
    if (streql(first, "-v") or streql(first, "--version") or streql(first, "version")) {
        args.command = .version;
        return .ok;
    }

    if (parseCommand(first)) |cmd| {
        args.command = cmd;
    } else {
        printError("unknown command '", first, "'");
        return .usage_error;
    }

    var i: usize = 2;
    var stop_opts = false;
    while (i < raw_argv.len) : (i += 1) {
        const arg = span(raw_argv[i]);

        if (streql(arg, "--") and !stop_opts) {
            stop_opts = true;
            continue;
        }

        if (!stop_opts and arg.len > 1 and arg[0] == '-') {
            if (streql(arg, "-l") or streql(arg, "--locale")) {
                i += 1;
                if (i >= raw_argv.len) {
                    printError("'--locale' requires a value", "", "");
                    return .usage_error;
                }
                args.locale = span(raw_argv[i]);
            } else if (streql(arg, "-d") or streql(arg, "--as-of")) {
                i += 1;
                if (i >= raw_argv.len) {
                    printError("'--as-of' requires a value", "", "");
                    return .usage_error;
                }
                args.as_of = span(raw_argv[i]);
            } else if (streql(arg, "-g") or streql(arg, "--gender")) {
                i += 1;
                if (i >= raw_argv.len) {
                    printError("'--gender' requires a value", "", "");
                    return .usage_error;
                }
                args.gender = span(raw_argv[i]);
            } else if (streql(arg, "--short")) {
                args.compactness = .short_mode;
            } else if (streql(arg, "--compact")) {
                args.compactness = .compact;
            } else if (streql(arg, "--with-year")) {
                args.with_year = true;
            } else if (streql(arg, "-h") or streql(arg, "--help")) {
                args.command = .help;
                return .ok;
            } else if (streql(arg, "-v") or streql(arg, "--version")) {
                args.command = .version;
                return .ok;
            } else {
                printError("unknown option '", arg, "'");
                return .usage_error;
            }
        } else {
            if (args.pos_count < MAX_POSITIONALS) {
                args.positionals[args.pos_count] = arg;
                args.pos_count += 1;
            }
        }
    }

    return .ok;
}

// ---- Output helpers ----

const STDOUT_FD = std.posix.STDOUT_FILENO;
const STDERR_FD = std.posix.STDERR_FILENO;

fn writeAll(fd: std.posix.fd_t, data: []const u8) void {
    var written: usize = 0;
    while (written < data.len) {
        written += std.posix.write(fd, data[written..]) catch return;
    }
}

fn printError(prefix: []const u8, arg: []const u8, suffix: []const u8) void {
    writeAll(STDERR_FD, "error: ");
    writeAll(STDERR_FD, prefix);
    writeAll(STDERR_FD, arg);
    writeAll(STDERR_FD, suffix);
    writeAll(STDERR_FD, "\n");
    writeAll(STDERR_FD, "Run 'sayable help' for usage.\n");
}

fn printResult(result: []const u8) void {
    writeAll(STDOUT_FD, result);
    writeAll(STDOUT_FD, "\n");
}

fn printLine(text: []const u8) void {
    writeAll(STDOUT_FD, text);
    writeAll(STDOUT_FD, "\n");
}

fn isNull(s: []const u8) bool {
    return streql(s, "null");
}

// ---- Get today's date ----

fn getToday(buf: *[10]u8) []const u8 {
    const ts = std.time.timestamp();
    const es = std.time.epoch.EpochSeconds{ .secs = @intCast(ts) };
    const ed = es.getEpochDay();
    const yd = ed.calculateYearDay();
    const md = yd.calculateMonthDay();

    const year: u32 = @intCast(yd.year);
    const month: u32 = @intFromEnum(md.month) + 1; // 0-indexed -> 1-indexed
    const day: u32 = md.day_index + 1; // 0-indexed -> 1-indexed

    buf[0] = @intCast('0' + year / 1000);
    buf[1] = @intCast('0' + (year / 100) % 10);
    buf[2] = @intCast('0' + (year / 10) % 10);
    buf[3] = @intCast('0' + year % 10);
    buf[4] = '-';
    buf[5] = @intCast('0' + month / 10);
    buf[6] = @intCast('0' + month % 10);
    buf[7] = '-';
    buf[8] = @intCast('0' + day / 10);
    buf[9] = @intCast('0' + day % 10);

    return buf[0..10];
}

// ---- Command handlers ----

fn cmdAge(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("age requires a date-of-birth argument", "", "");
        return 2;
    }

    const dob_arg = args.positionals[0];
    if (isNull(dob_arg)) return 1;
    if (dob_arg.len == 0) return 1;

    const locale = sayableage.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    var as_of: []const u8 = undefined;
    var today_buf: [10]u8 = undefined;
    if (args.as_of) |ao| {
        if (isNull(ao)) return 1;
        as_of = ao;
    } else {
        as_of = getToday(&today_buf);
    }

    const compactness: sayableage.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableage.formatAge(&buf, locale, compactness, dob_arg, as_of) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdStage(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("stage requires a date-of-birth argument", "", "");
        return 2;
    }

    const dob_arg = args.positionals[0];
    if (isNull(dob_arg)) return 1;
    if (dob_arg.len == 0) return 1;

    const locale = sayableage.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    var as_of: []const u8 = undefined;
    var today_buf: [10]u8 = undefined;
    if (args.as_of) |ao| {
        if (isNull(ao)) return 1;
        as_of = ao;
    } else {
        as_of = getToday(&today_buf);
    }

    const result = sayableage.formatStage(locale, dob_arg, as_of, args.gender) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdDate(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("date requires a date argument", "", "");
        return 2;
    }

    const date_arg = args.positionals[0];
    if (isNull(date_arg)) return 1;
    if (date_arg.len == 0) return 1;

    const locale = sayabledate.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayabledate.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    if (args.with_year) {
        const result = sayabledate.formatDateWithYear(&buf, locale, compactness, date_arg) orelse return 1;
        printResult(result);
    } else {
        const result = sayabledate.formatDate(&buf, locale, compactness, date_arg) orelse return 1;
        printResult(result);
    }
    return 0;
}

fn cmdRelative(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("relative requires a date argument", "", "");
        return 2;
    }

    const date_arg = args.positionals[0];
    if (isNull(date_arg)) return 1;

    if (args.as_of == null) {
        printError("relative requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayabledate.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayabledate.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayabledate.formatRelative(&buf, locale, compactness, date_arg, as_of) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdTime(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("time requires a time argument", "", "");
        return 2;
    }

    const time_arg = args.positionals[0];
    if (isNull(time_arg)) return 1;
    if (time_arg.len == 0) return 1;

    const locale = sayabletime.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayabletime.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayabletime.formatTime(&buf, locale, compactness, time_arg) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdDuration(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("duration requires a value argument", "", "");
        return 2;
    }

    const value_arg = args.positionals[0];
    if (isNull(value_arg)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;

    if (isNonNegativeInteger(value_arg)) {
        const seconds = parseInteger(value_arg);
        const result = sayableduration.formatDurationSecs(&buf, locale, compactness, seconds) orelse return 1;
        printResult(result);
    } else if (isNegativeInteger(value_arg)) {
        const seconds = parseSignedInteger(value_arg);
        const result = sayableduration.formatDurationSecs(&buf, locale, compactness, seconds) orelse return 1;
        printResult(result);
    } else {
        // Timestamp mode
        if (args.pos_count < 2) {
            printError("duration with timestamps requires start and end arguments", "", "");
            return 2;
        }
        const end_arg = args.positionals[1];
        if (isNull(end_arg)) return 1;
        const result = sayableduration.formatDurationISO(&buf, locale, compactness, value_arg, end_arg) orelse return 1;
        printResult(result);
    }
    return 0;
}

fn cmdSince(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("since requires a start timestamp argument", "", "");
        return 2;
    }

    const start_arg = args.positionals[0];
    if (isNull(start_arg)) return 1;

    if (args.as_of == null) {
        printError("since requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableduration.formatSince(&buf, locale, compactness, start_arg, as_of) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdUntil(args: *const Args) u8 {
    if (args.pos_count < 1) {
        printError("until requires a target timestamp argument", "", "");
        return 2;
    }

    const target_arg = args.positionals[0];
    if (isNull(target_arg)) return 1;

    if (args.as_of == null) {
        printError("until requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableduration.formatUntil(&buf, locale, compactness, target_arg, as_of) orelse return 1;
    printResult(result);
    return 0;
}

fn cmdLocales() u8 {
    for (sayableage.locales.all) |entry| {
        printLine(entry.code);
    }
    return 0;
}

// ---- Integer detection helpers ----

fn isNonNegativeInteger(s: []const u8) bool {
    if (s.len == 0) return false;
    for (s) |c| {
        if (c < '0' or c > '9') return false;
    }
    return true;
}

fn isNegativeInteger(s: []const u8) bool {
    if (s.len < 2) return false;
    if (s[0] != '-') return false;
    for (s[1..]) |c| {
        if (c < '0' or c > '9') return false;
    }
    return true;
}

fn parseInteger(s: []const u8) i32 {
    var val: i32 = 0;
    for (s) |c| {
        val = val * 10 + @as(i32, c - '0');
    }
    return val;
}

fn parseSignedInteger(s: []const u8) i32 {
    var val: i32 = 0;
    var start: usize = 0;
    var neg = false;
    if (s.len > 0 and s[0] == '-') {
        neg = true;
        start = 1;
    }
    for (s[start..]) |c| {
        val = val * 10 + @as(i32, c - '0');
    }
    return if (neg) -val else val;
}

// ---- Main ----

pub fn main() u8 {
    const argv = std.os.argv;

    var args = Args{};
    const parse_result = parseArgs(argv, &args);

    if (parse_result == .usage_error) return 2;

    const cmd = args.command orelse {
        writeAll(STDOUT_FD, HELP);
        return 2;
    };

    switch (cmd) {
        .help => {
            writeAll(STDOUT_FD, HELP);
            return 0;
        },
        .version => {
            writeAll(STDOUT_FD, "sayable ");
            writeAll(STDOUT_FD, VERSION);
            writeAll(STDOUT_FD, "\n");
            return 0;
        },
        .locales => return cmdLocales(),
        .age => return cmdAge(&args),
        .stage => return cmdStage(&args),
        .date => return cmdDate(&args),
        .relative => return cmdRelative(&args),
        .time_cmd => return cmdTime(&args),
        .duration => return cmdDuration(&args),
        .since => return cmdSince(&args),
        .until => return cmdUntil(&args),
    }
}
