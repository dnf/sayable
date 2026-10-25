// sayable-duration Zig implementation — types and formatter.

pub const version = "0.5.0";

pub const locales = @import("locales/locales.zig");

// ---- Types ----

pub const PluralCategory = enum(u3) {
    zero = 0,
    one = 1,
    two = 2,
    few = 3,
    many = 4,
    other = 5,
};

pub const Compactness = enum {
    normal,
    short_mode,
    compact,
};

pub const UnitForms = union(enum) {
    simple: []const u8,
    forms: Forms,

    pub const Forms = struct {
        zero: ?[]const u8 = null,
        one: ?[]const u8 = null,
        two: ?[]const u8 = null,
        few: ?[]const u8 = null,
        many: ?[]const u8 = null,
        other: ?[]const u8 = null,
    };

    pub fn resolve(self: UnitForms, cat: PluralCategory) ?[]const u8 {
        return switch (self) {
            .simple => |s| s,
            .forms => |f| {
                const arr = [6]?[]const u8{ f.zero, f.one, f.two, f.few, f.many, f.other };
                return arr[@intFromEnum(cat)] orelse f.other;
            },
        };
    }
};

pub const UnitSet = struct {
    second: UnitForms,
    minute: UnitForms,
    hour: UnitForms,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
};

pub const CompactnessOverride = struct {
    second: ?UnitForms = null,
    minute: ?UnitForms = null,
    hour: ?UnitForms = null,
    day: ?UnitForms = null,
    week: ?UnitForms = null,
    month: ?UnitForms = null,
    year: ?UnitForms = null,
    half: ?[]const u8 = null,
    delimiter: ?[]const u8 = null,
    ago: ?[]const u8 = null,
    in_future: ?[]const u8 = null,
};

pub const DurationLocale = struct {
    code: []const u8,
    plural: *const fn (n: i32) PluralCategory,
    units: UnitSet,
    half: []const u8,
    delimiter: []const u8,
    just_now: []const u8,
    ago: []const u8,
    in_future: []const u8,
    short_override: ?CompactnessOverride = null,
    compact_override: ?CompactnessOverride = null,
};

// ---- Writer ----

const Writer = struct {
    buf: []u8,
    pos: usize,
    overflow: bool,

    fn init(buf: []u8) Writer {
        return .{ .buf = buf, .pos = 0, .overflow = false };
    }

    fn writeStr(self: *Writer, s: []const u8) void {
        if (self.overflow) return;
        if (self.pos + s.len > self.buf.len) {
            self.overflow = true;
            return;
        }
        @memcpy(self.buf[self.pos..][0..s.len], s);
        self.pos += s.len;
    }

    fn writeByte(self: *Writer, c: u8) void {
        if (self.overflow) return;
        if (self.pos >= self.buf.len) {
            self.overflow = true;
            return;
        }
        self.buf[self.pos] = c;
        self.pos += 1;
    }

    fn writeInt(self: *Writer, n: i32) void {
        var tmp: [12]u8 = undefined;
        var i: usize = 0;
        var val = n;
        if (val < 0) {
            self.writeByte('-');
            val = -val;
        }
        if (val == 0) {
            tmp[i] = '0';
            i += 1;
        } else {
            while (val > 0) {
                tmp[i] = @intCast(@as(u32, @intCast(@mod(val, 10))) + '0');
                i += 1;
                val = @divTrunc(val, 10);
            }
        }
        while (i > 0) {
            i -= 1;
            self.writeByte(tmp[i]);
        }
    }

    fn slice(self: *const Writer) []const u8 {
        return self.buf[0..self.pos];
    }
};

fn itoa(n: i32) []const u8 {
    const S = struct {
        var buf: [12]u8 = undefined;
    };
    var w = Writer.init(&S.buf);
    w.writeInt(n);
    return w.slice();
}

// ---- String helpers ----

fn indexOf(haystack: []const u8, needle: []const u8) ?usize {
    if (needle.len == 0) return 0;
    if (haystack.len < needle.len) return null;
    var i: usize = 0;
    while (i <= haystack.len - needle.len) : (i += 1) {
        if (eql(haystack[i..][0..needle.len], needle)) return i;
    }
    return null;
}

fn eql(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |ca, cb| {
        if (ca != cb) return false;
    }
    return true;
}

fn replaceFirst(w: *Writer, tmpl: []const u8, marker: []const u8, replacement: []const u8) void {
    if (indexOf(tmpl, marker)) |pos| {
        w.writeStr(tmpl[0..pos]);
        w.writeStr(replacement);
        w.writeStr(tmpl[pos + marker.len ..]);
    } else {
        w.writeStr(tmpl);
    }
}

// ---- Resolve unit with plural + half ----

fn resolveUnit(w: *Writer, count: i32, uf: UnitForms, locale: *const DurationLocale, half: []const u8) void {
    const base_n = itoa(count);

    // Apply {n}-style half marker to the number
    var n_buf: [64]u8 = undefined;
    var n_str: []const u8 = base_n;
    if (half.len > 0 and indexOf(half, "{n}") != null) {
        var nw = Writer.init(&n_buf);
        replaceFirst(&nw, half, "{n}", base_n);
        if (!nw.overflow) {
            n_str = nw.slice();
        }
    }

    // Select template — half-marked values use "other" plural
    const cat = if (half.len > 0) PluralCategory.other else locale.plural(count);
    const tmpl = uf.resolve(cat) orelse return;

    // Replace {n} with the (possibly half-marked) number
    var result_buf: [128]u8 = undefined;
    var rw = Writer.init(&result_buf);
    replaceFirst(&rw, tmpl, "{n}", n_str);
    if (rw.overflow) return;

    // Apply {0}-style half marker (wraps the whole expression)
    if (half.len > 0 and indexOf(half, "{0}") != null) {
        replaceFirst(w, half, "{0}", rw.slice());
    } else {
        w.writeStr(rw.slice());
    }
}

// ---- ISO datetime parsing ----

fn parseDigits(s: []const u8) ?i32 {
    if (s.len == 0) return null;
    var v: i32 = 0;
    for (s) |c| {
        if (c < '0' or c > '9') return null;
        v = v * 10 + @as(i32, c - '0');
    }
    return v;
}

fn isLeapYear(year: i32) bool {
    return (@mod(year, 4) == 0 and @mod(year, 100) != 0) or @mod(year, 400) == 0;
}

fn daysInMonth(year: i32, month: i32) i32 {
    if (month == 2) return if (isLeapYear(year)) 29 else 28;
    if (month == 4 or month == 6 or month == 9 or month == 11) return 30;
    return 31;
}

fn daysSinceEpoch(year: i32, month: i32, day: i32) i64 {
    var days: i64 = 0;
    if (year >= 2000) {
        var y: i32 = 2000;
        while (y < year) : (y += 1) {
            days += if (isLeapYear(y)) 366 else 365;
        }
    } else {
        var y: i32 = year;
        while (y < 2000) : (y += 1) {
            days -= if (isLeapYear(y)) 366 else 365;
        }
    }
    var m: i32 = 1;
    while (m < month) : (m += 1) {
        days += daysInMonth(year, m);
    }
    days += day - 1;
    return days;
}

/// Number of leading ASCII digits in s.
fn digitRun(s: []const u8) usize {
    var n: usize = 0;
    while (n < s.len and s[n] >= '0' and s[n] <= '9') n += 1;
    return n;
}

/// Nothing, "Z", or "+HH:MM" / "-HH:MM".
fn isZoneSuffix(s: []const u8) bool {
    if (s.len == 0) return true;
    if (s.len == 1) return s[0] == 'Z';
    return s.len == 6 and (s[0] == '+' or s[0] == '-') and digitRun(s[1..3]) == 2 and
        s[3] == ':' and digitRun(s[4..6]) == 2;
}

const Clock = struct { hour: i32, minute: i32, second: i32 };

/// H:MM or HH:MM, optional :SS, optional . plus digits after the seconds, and
/// an optional zone suffix, which is validated but ignored.
fn parseClock(clock: []const u8) ?Clock {
    const hour_len = digitRun(clock);
    if (hour_len < 1 or hour_len > 2 or clock.len < hour_len + 3 or clock[hour_len] != ':') return null;
    const hour = parseDigits(clock[0..hour_len]) orelse return null;
    const minute = parseDigits(clock[hour_len + 1 .. hour_len + 3]) orelse return null;
    var rest = clock[hour_len + 3 ..];
    var second: i32 = 0;
    if (rest.len > 0 and rest[0] == ':') {
        if (rest.len < 3) return null;
        second = parseDigits(rest[1..3]) orelse return null;
        rest = rest[3..];
        if (rest.len > 0 and rest[0] == '.') {
            const fraction_len = digitRun(rest[1..]);
            if (fraction_len == 0) return null;
            rest = rest[1 + fraction_len ..];
        }
    }
    if (!isZoneSuffix(rest) or hour > 23 or minute > 59 or second > 59) return null;
    return .{ .hour = hour, .minute = minute, .second = second };
}

/// A timestamp YYYY-MM-DDTHH:MM[:SS[.fff]][zone] (docs/input-formats.md) as
/// seconds since 2000-01-01 for diffing.
fn parseISOToSeconds(iso: []const u8) ?i64 {
    if (iso.len < 11 or iso[4] != '-' or iso[7] != '-' or iso[10] != 'T') return null;
    const year = parseDigits(iso[0..4]) orelse return null;
    const month = parseDigits(iso[5..7]) orelse return null;
    const day = parseDigits(iso[8..10]) orelse return null;
    if (month < 1 or month > 12 or day < 1 or day > daysInMonth(year, month)) return null;
    const clock = parseClock(iso[11..]) orelse return null;
    const days = daysSinceEpoch(year, month, day);
    return days * 86400 + @as(i64, clock.hour) * 3600 + @as(i64, clock.minute) * 60 + @as(i64, clock.second);
}

// ---- Resolved locale fields ----

const ResolvedLocale = struct {
    second: UnitForms,
    minute: UnitForms,
    hour: UnitForms,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
    half: []const u8,
    delimiter: []const u8,
    just_now: []const u8,
    ago: []const u8,
    in_future: []const u8,
};

fn resolveLocale(locale: *const DurationLocale, compactness: Compactness) ResolvedLocale {
    var r = ResolvedLocale{
        .second = locale.units.second,
        .minute = locale.units.minute,
        .hour = locale.units.hour,
        .day = locale.units.day,
        .week = locale.units.week,
        .month = locale.units.month,
        .year = locale.units.year,
        .half = locale.half,
        .delimiter = locale.delimiter,
        .just_now = locale.just_now,
        .ago = locale.ago,
        .in_future = locale.in_future,
    };

    const ovr: ?CompactnessOverride = switch (compactness) {
        .short_mode => locale.short_override,
        .compact => locale.compact_override,
        .normal => null,
    };

    if (ovr) |o| {
        if (o.second) |u| r.second = u;
        if (o.minute) |u| r.minute = u;
        if (o.hour) |u| r.hour = u;
        if (o.day) |u| r.day = u;
        if (o.week) |u| r.week = u;
        if (o.month) |u| r.month = u;
        if (o.year) |u| r.year = u;
        if (o.half) |h| r.half = h;
        if (o.delimiter) |d| r.delimiter = d;
        if (o.ago) |a| r.ago = a;
        if (o.in_future) |f| r.in_future = f;
    }

    return r;
}

// ---- Round division for month approximation ----

fn roundDiv(total_days: i64) i64 {
    // round(totalDays / 30.44) using integer arithmetic
    // = floor(totalDays * 100 / 3044 + 0.5)
    return @divTrunc(total_days * 200 + 3044, 6088);
}

/// Durations over 6000 months (500 years) have no value: the same ceiling as sayable-age.
const max_duration_months = 6000;

fn isOverCeiling(total_seconds: i64) bool {
    const total_days = @divTrunc(total_seconds, 86400);
    return total_days >= 30 and roundDiv(total_days) > max_duration_months;
}

// ---- Format duration from seconds ----

fn formatDurationSeconds(buf: []u8, locale: *const DurationLocale, rl: *const ResolvedLocale, total_seconds: i64) ?[]const u8 {
    if (total_seconds < 0 or isOverCeiling(total_seconds)) return null;
    // Within the 500-year ceiling (under 2^34 seconds), every count below fits an i32.
    const total: i64 = total_seconds;
    var w = Writer.init(buf);

    // 0 seconds
    if (total == 0) {
        w.writeStr(rl.just_now);
        return if (w.overflow) null else w.slice();
    }

    // 1-59 seconds
    if (total < 60) {
        resolveUnit(&w, @intCast(total), rl.second, locale, "");
        return if (w.overflow) null else w.slice();
    }

    const total_minutes: i32 = @intCast(@divTrunc(total, 60));
    const remainder_seconds: i32 = @intCast(@mod(total, 60));

    // 1-4 minutes: minutes + seconds
    if (total_minutes < 5) {
        resolveUnit(&w, total_minutes, rl.minute, locale, "");
        if (remainder_seconds > 0) {
            w.writeStr(rl.delimiter);
            resolveUnit(&w, remainder_seconds, rl.second, locale, "");
        }
        return if (w.overflow) null else w.slice();
    }

    // 5-59 minutes
    if (total_minutes < 60) {
        resolveUnit(&w, total_minutes, rl.minute, locale, "");
        return if (w.overflow) null else w.slice();
    }

    const total_hours: i32 = @intCast(@divTrunc(total, 3600));
    const remainder_minutes: i32 = @intCast(@divTrunc(@mod(total, 3600), 60));

    // 1-5 hours: hours + minutes (with half marker)
    if (total_hours <= 5) {
        if (remainder_minutes == 30) {
            resolveUnit(&w, total_hours, rl.hour, locale, rl.half);
        } else {
            resolveUnit(&w, total_hours, rl.hour, locale, "");
            if (remainder_minutes > 0) {
                w.writeStr(rl.delimiter);
                resolveUnit(&w, remainder_minutes, rl.minute, locale, "");
            }
        }
        return if (w.overflow) null else w.slice();
    }

    // 6-23 hours
    if (total_hours < 24) {
        resolveUnit(&w, total_hours, rl.hour, locale, "");
        return if (w.overflow) null else w.slice();
    }

    const total_days: i32 = @intCast(@divTrunc(total, 86400));
    const remainder_hours: i32 = @intCast(@divTrunc(@mod(total, 86400), 3600));

    // 1-2 days: days + hours (with half marker)
    if (total_days <= 2) {
        if (remainder_hours == 12) {
            resolveUnit(&w, total_days, rl.day, locale, rl.half);
        } else {
            resolveUnit(&w, total_days, rl.day, locale, "");
            if (remainder_hours > 0) {
                w.writeStr(rl.delimiter);
                resolveUnit(&w, remainder_hours, rl.hour, locale, "");
            }
        }
        return if (w.overflow) null else w.slice();
    }

    // 3-6 days
    if (total_days < 7) {
        resolveUnit(&w, total_days, rl.day, locale, "");
        return if (w.overflow) null else w.slice();
    }

    // 1-4 weeks (up to 29 days)
    if (total_days < 30) {
        const total_weeks = @divTrunc(total_days, 7);
        const remainder_days = @mod(total_days, 7);
        resolveUnit(&w, total_weeks, rl.week, locale, "");
        if (remainder_days > 0) {
            w.writeStr(rl.delimiter);
            resolveUnit(&w, remainder_days, rl.day, locale, "");
        }
        return if (w.overflow) null else w.slice();
    }

    // Approximate months
    var total_months: i32 = @intCast(roundDiv(total_days));
    if (total_months < 12) {
        if (total_months == 0) total_months = 1;
        resolveUnit(&w, total_months, rl.month, locale, "");
        return if (w.overflow) null else w.slice();
    }

    // Years + months
    const total_years = @divTrunc(total_months, 12);
    const remainder_months = @mod(total_months, 12);
    resolveUnit(&w, total_years, rl.year, locale, "");
    if (remainder_months > 0) {
        w.writeStr(rl.delimiter);
        resolveUnit(&w, remainder_months, rl.month, locale, "");
    }
    return if (w.overflow) null else w.slice();
}

// ---- Public API ----

pub fn formatDurationSecs(buf: []u8, locale: *const DurationLocale, compactness: Compactness, seconds: i64) ?[]const u8 {
    if (seconds < 0) return null;
    const rl = resolveLocale(locale, compactness);
    return formatDurationSeconds(buf, locale, &rl, seconds);
}

pub fn formatDurationISO(buf: []u8, locale: *const DurationLocale, compactness: Compactness, start: []const u8, end: []const u8) ?[]const u8 {
    if (start.len == 0 or end.len == 0) return null;
    const s = parseISOToSeconds(start) orelse return null;
    const e = parseISOToSeconds(end) orelse return null;
    var total = e - s;
    if (total < 0) total = -total;
    const rl = resolveLocale(locale, compactness);
    return formatDurationSeconds(buf, locale, &rl, total);
}

pub fn formatSince(buf: []u8, locale: *const DurationLocale, compactness: Compactness, start: []const u8, as_of: []const u8) ?[]const u8 {
    if (start.len == 0 or as_of.len == 0) return null;
    const s = parseISOToSeconds(start) orelse return null;
    const a = parseISOToSeconds(as_of) orelse return null;
    const diff = a - s;
    if (diff < 0) return null;

    const rl = resolveLocale(locale, compactness);

    if (diff == 0) {
        var w = Writer.init(buf);
        w.writeStr(rl.just_now);
        return if (w.overflow) null else w.slice();
    }

    // Format the duration part into a temp buffer
    var dur_buf: [256]u8 = undefined;
    const dur = formatDurationSeconds(&dur_buf, locale, &rl, diff) orelse return null;

    // Wrap with ago template
    var w = Writer.init(buf);
    replaceFirst(&w, rl.ago, "{0}", dur);
    return if (w.overflow) null else w.slice();
}

pub fn formatUntil(buf: []u8, locale: *const DurationLocale, compactness: Compactness, target: []const u8, as_of: []const u8) ?[]const u8 {
    if (target.len == 0 or as_of.len == 0) return null;
    const t = parseISOToSeconds(target) orelse return null;
    const a = parseISOToSeconds(as_of) orelse return null;
    const diff = t - a;
    if (diff < 0) return null;

    const rl = resolveLocale(locale, compactness);

    if (diff == 0) {
        var w = Writer.init(buf);
        w.writeStr(rl.just_now);
        return if (w.overflow) null else w.slice();
    }

    var dur_buf: [256]u8 = undefined;
    const dur = formatDurationSeconds(&dur_buf, locale, &rl, diff) orelse return null;

    var w = Writer.init(buf);
    replaceFirst(&w, rl.in_future, "{0}", dur);
    return if (w.overflow) null else w.slice();
}
