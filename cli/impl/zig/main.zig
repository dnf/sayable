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

/// `argv` excludes the program name.
fn parseArgs(sink: Sink, argv: []const []const u8, args: *Args) ParseResult {
    // No command: run() prints the help text and exits 2, as the reference CLI does.
    if (argv.len < 1) return .ok;

    const first = argv[0];
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
        sink.printError("unknown command '", first, "'");
        return .usage_error;
    }

    var i: usize = 1;
    var stop_opts = false;
    while (i < argv.len) : (i += 1) {
        const arg = argv[i];

        if (streql(arg, "--") and !stop_opts) {
            stop_opts = true;
            continue;
        }

        if (!stop_opts and arg.len > 1 and arg[0] == '-') {
            if (streql(arg, "-l") or streql(arg, "--locale")) {
                i += 1;
                if (i >= argv.len) {
                    sink.printError("'--locale' requires a value", "", "");
                    return .usage_error;
                }
                args.locale = argv[i];
            } else if (streql(arg, "-d") or streql(arg, "--as-of")) {
                i += 1;
                if (i >= argv.len) {
                    sink.printError("'--as-of' requires a value", "", "");
                    return .usage_error;
                }
                args.as_of = argv[i];
            } else if (streql(arg, "-g") or streql(arg, "--gender")) {
                i += 1;
                if (i >= argv.len) {
                    sink.printError("'--gender' requires a value", "", "");
                    return .usage_error;
                }
                args.gender = argv[i];
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
                sink.printError("unknown option '", arg, "'");
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

/// Where one invocation's output goes: its stdout text to `out`, errors to
/// stderr. Write failures are ignored, as a CLI has nowhere to report them.
const Sink = struct {
    io: std.Io,
    out: *std.Io.Writer,

    fn printError(sink: Sink, prefix: []const u8, arg: []const u8, suffix: []const u8) void {
        var buf: [1024]u8 = undefined;
        var stderr = std.Io.File.stderr().writerStreaming(sink.io, &buf);
        const w = &stderr.interface;
        w.print("error: {s}{s}{s}\nRun 'sayable help' for usage.\n", .{ prefix, arg, suffix }) catch {};
        w.flush() catch {};
    }

    fn write(sink: Sink, text: []const u8) void {
        sink.out.writeAll(text) catch {};
    }

    fn printLine(sink: Sink, text: []const u8) void {
        sink.write(text);
        sink.write("\n");
    }
};

fn isNull(s: []const u8) bool {
    return streql(s, "null");
}

// ---- Get today's date ----

fn getToday(io: std.Io, buf: *[10]u8) []const u8 {
    const ts = std.Io.Clock.real.now(io).toSeconds();
    const es = std.time.epoch.EpochSeconds{ .secs = @intCast(ts) };
    const ed = es.getEpochDay();
    const yd = ed.calculateYearDay();
    const md = yd.calculateMonthDay();

    const year: u32 = @intCast(yd.year);
    const month: u32 = @backingInt(md.month) + 1; // 0-indexed -> 1-indexed
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

fn cmdAge(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("age requires a date-of-birth argument", "", "");
        return 2;
    }

    const dob_arg = args.positionals[0];
    if (isNull(dob_arg)) return 1;
    if (dob_arg.len == 0) return 1;

    const locale = sayableage.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    var as_of: []const u8 = undefined;
    var today_buf: [10]u8 = undefined;
    // A null or empty as-of means today, as in the reference CLI.
    const given_as_of = args.as_of orelse "";
    if (isNull(given_as_of) or given_as_of.len == 0) {
        as_of = getToday(sink.io, &today_buf);
    } else {
        as_of = given_as_of;
    }

    const compactness: sayableage.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableage.formatAge(&buf, locale, compactness, dob_arg, as_of) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdStage(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("stage requires a date-of-birth argument", "", "");
        return 2;
    }

    const dob_arg = args.positionals[0];
    if (isNull(dob_arg)) return 1;
    if (dob_arg.len == 0) return 1;

    const locale = sayableage.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    var as_of: []const u8 = undefined;
    var today_buf: [10]u8 = undefined;
    // A null or empty as-of means today, as in the reference CLI.
    const given_as_of = args.as_of orelse "";
    if (isNull(given_as_of) or given_as_of.len == 0) {
        as_of = getToday(sink.io, &today_buf);
    } else {
        as_of = given_as_of;
    }

    const result = sayableage.formatStage(locale, dob_arg, as_of, args.gender) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdDate(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("date requires a date argument", "", "");
        return 2;
    }

    const date_arg = args.positionals[0];
    if (isNull(date_arg)) return 1;
    if (date_arg.len == 0) return 1;

    const locale = sayabledate.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
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
        sink.printLine(result);
    } else {
        const result = sayabledate.formatDate(&buf, locale, compactness, date_arg) orelse return 1;
        sink.printLine(result);
    }
    return 0;
}

fn cmdRelative(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("relative requires a date argument", "", "");
        return 2;
    }

    const date_arg = args.positionals[0];
    if (isNull(date_arg)) return 1;

    if (args.as_of == null) {
        sink.printError("relative requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayabledate.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayabledate.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayabledate.formatRelative(&buf, locale, compactness, date_arg, as_of) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdTime(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("time requires a time argument", "", "");
        return 2;
    }

    const time_arg = args.positionals[0];
    if (isNull(time_arg)) return 1;
    if (time_arg.len == 0) return 1;

    const locale = sayabletime.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayabletime.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayabletime.formatTime(&buf, locale, compactness, time_arg) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdDuration(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("duration requires a value argument", "", "");
        return 2;
    }

    const value_arg = args.positionals[0];
    if (isNull(value_arg)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;

    if (isInteger(value_arg)) {
        const seconds = parseSeconds(value_arg) orelse return 1;
        const result = sayableduration.formatDurationSecs(&buf, locale, compactness, seconds) orelse return 1;
        sink.printLine(result);
    } else {
        // Timestamp mode
        if (args.pos_count < 2) {
            sink.printError("duration with timestamps requires start and end arguments", "", "");
            return 2;
        }
        const end_arg = args.positionals[1];
        if (isNull(end_arg)) return 1;
        const result = sayableduration.formatDurationISO(&buf, locale, compactness, value_arg, end_arg) orelse return 1;
        sink.printLine(result);
    }
    return 0;
}

fn cmdSince(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("since requires a start timestamp argument", "", "");
        return 2;
    }

    const start_arg = args.positionals[0];
    if (isNull(start_arg)) return 1;

    if (args.as_of == null) {
        sink.printError("since requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableduration.formatSince(&buf, locale, compactness, start_arg, as_of) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdUntil(sink: Sink, args: *const Args) u8 {
    if (args.pos_count < 1) {
        sink.printError("until requires a target timestamp argument", "", "");
        return 2;
    }

    const target_arg = args.positionals[0];
    if (isNull(target_arg)) return 1;

    if (args.as_of == null) {
        sink.printError("until requires --as-of / -d option", "", "");
        return 2;
    }

    const as_of = args.as_of.?;
    if (isNull(as_of)) return 1;

    const locale = sayableduration.locales.get(args.locale) orelse {
        sink.printError("unknown locale '", args.locale, "'");
        return 2;
    };

    const compactness: sayableduration.Compactness = switch (args.compactness) {
        .normal => .normal,
        .short_mode => .short_mode,
        .compact => .compact,
    };

    var buf: [512]u8 = undefined;
    const result = sayableduration.formatUntil(&buf, locale, compactness, target_arg, as_of) orelse return 1;
    sink.printLine(result);
    return 0;
}

fn cmdLocales(sink: Sink) u8 {
    for (sayableage.locales.all) |entry| {
        sink.printLine(entry.code);
    }
    return 0;
}

// ---- Integer detection helpers ----

/// Seconds mode, as the reference CLI decides it: digits after any leading minus signs.
fn isInteger(s: []const u8) bool {
    const digits = std.mem.trimStart(u8, s, "-");
    if (digits.len == 0) return false;
    for (digits) |c| {
        if (c < '0' or c > '9') return false;
    }
    return true;
}

/// Seconds as a 64-bit integer; null when malformed ("--5") or out of range,
/// which is far beyond the 500-year ceiling either way.
fn parseSeconds(s: []const u8) ?i64 {
    return std.fmt.parseInt(i64, s, 10) catch null;
}

// ---- Dispatch ----

/// Runs one invocation (`argv` excludes the program name), writing its stdout
/// text to `sink.out`; returns the exit code.
fn run(sink: Sink, argv: []const []const u8) u8 {
    var args = Args{};
    const parse_result = parseArgs(sink, argv, &args);

    if (parse_result == .usage_error) return 2;

    const cmd = args.command orelse {
        sink.write(HELP);
        return 2;
    };

    switch (cmd) {
        .help => {
            sink.write(HELP);
            return 0;
        },
        .version => {
            sink.printLine("sayable " ++ VERSION);
            return 0;
        },
        .locales => return cmdLocales(sink),
        .age => return cmdAge(sink, &args),
        .stage => return cmdStage(sink, &args),
        .date => return cmdDate(sink, &args),
        .relative => return cmdRelative(sink, &args),
        .time_cmd => return cmdTime(sink, &args),
        .duration => return cmdDuration(sink, &args),
        .since => return cmdSince(sink, &args),
        .until => return cmdUntil(sink, &args),
    }
}

// ---- REPL mode (see cli/SPEC.md) ----

/// Large enough for any output (help is the longest), so it never truncates.
const MAX_OUTPUT = 16 * 1024;

fn answerRequest(io: std.Io, gpa: std.mem.Allocator, request: []const u8, stdout: *std.Io.Writer) !void {
    var fields: std.ArrayList([]const u8) = .empty;
    defer fields.deinit(gpa);
    var it = std.mem.splitScalar(u8, request, '\t');
    while (it.next()) |field| try fields.append(gpa, field);

    var out_buf: [MAX_OUTPUT]u8 = undefined;
    var captured: std.Io.Writer = .fixed(&out_buf);
    const code = run(.{ .io = io, .out = &captured }, fields.items);

    const written = captured.buffered();
    const output = written[0..std.mem.trimEnd(u8, written, "\n").len];
    std.mem.replaceScalar(u8, output, '\n', '\t');
    try stdout.print("{d}\t{s}\n", .{ code, output });
}

fn repl(io: std.Io, gpa: std.mem.Allocator) !void {
    var in_buf: [64 * 1024]u8 = undefined;
    var stdin = std.Io.File.stdin().readerStreaming(io, &in_buf);
    const reader = &stdin.interface;
    var out_buf: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writerStreaming(io, &out_buf);

    var line: std.Io.Writer.Allocating = .init(gpa);
    defer line.deinit();
    while (true) {
        line.clearRetainingCapacity();
        _ = try reader.streamDelimiterEnding(&line.writer, '\n');
        const at_end = reader.bufferedLen() == 0;
        if (at_end and line.written().len == 0) break;
        if (!at_end) reader.toss(1); // the newline

        const request = std.mem.trimEnd(u8, line.written(), "\r");
        answerRequest(io, gpa, request, &stdout.interface) catch |err| {
            std.log.err("{t}", .{err});
            try stdout.interface.writeAll("1\t\n");
        };
        try stdout.interface.flush();
    }
}

// ---- Main ----

pub fn main(init: std.process.Init) u8 {
    const argv = init.minimal.args.toSlice(init.arena.allocator()) catch return 1;
    const user_args: []const []const u8 = argv[1..];

    if (user_args.len == 1 and streql(user_args[0], "--repl")) {
        repl(init.io, init.gpa) catch |err| {
            std.log.err("{t}", .{err});
            return 1;
        };
        return 0;
    }

    var out_buf: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writerStreaming(init.io, &out_buf);
    const code = run(.{ .io = init.io, .out = &stdout.interface }, user_args);
    stdout.interface.flush() catch {};
    return code;
}
