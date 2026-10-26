// sayable-date Zig implementation — types and formatter.

pub const version = "0.5.0";

pub const locales = @import("locales/locales.zig");

// ---- Types ----

pub const Compactness = enum {
    normal,
    short_mode,
    compact,
};

pub const CompactnessOverride = struct {
    months: ?*const [12][]const u8 = null,
    months_in_date: ?*const [12][]const u8 = null,
    weekdays: ?*const [7][]const u8 = null,
    day_format: ?[]const u8 = null,
    day_format_exceptions: ?[]const DayFormatException = null,
    clear_exceptions: bool = false,
    date_pattern: ?[]const u8 = null,
    date_pattern_with_year: ?[]const u8 = null,
    today: ?[]const u8 = null,
    tomorrow: ?[]const u8 = null,
    yesterday: ?[]const u8 = null,
};

pub const DayFormatException = struct {
    day: []const u8,
    format: []const u8,
};

pub const DateLocale = struct {
    code: []const u8,
    months: [12][]const u8,
    weekdays: [7][]const u8,
    day_format: []const u8,
    day_format_exceptions: []const DayFormatException = &.{},
    date_pattern: []const u8,
    date_pattern_with_year: []const u8,
    today: []const u8,
    tomorrow: []const u8,
    yesterday: []const u8,
    day_after_tomorrow: ?[]const u8 = null,
    day_before_yesterday: ?[]const u8 = null,
    this_weekday: ?[]const u8 = null,
    next_weekday: ?[]const u8 = null,
    last_weekday: ?[]const u8 = null,
    months_in_date: ?*const [12][]const u8 = null,
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

fn itoa(n: i32) []const u8 {
    const S = struct {
        var buf: [12]u8 = undefined;
    };
    var w = Writer.init(&S.buf);
    w.writeInt(n);
    return w.slice();
}

// ---- Date parsing ----

const Date = struct { y: i32, m: i32, d: i32 };

/// YYYY-MM-DD naming a real calendar day, optionally followed by T and
/// anything else (docs/input-formats.md).
fn parseDate(s: []const u8) ?Date {
    const is_date_alone = s.len == 10;
    const is_datetime = s.len > 10 and s[10] == 'T';
    if (!(is_date_alone or is_datetime) or s[4] != '-' or s[7] != '-') return null;
    const y = parseDigits(s[0..4]) orelse return null;
    const m = parseDigits(s[5..7]) orelse return null;
    const d = parseDigits(s[8..10]) orelse return null;
    if (m < 1 or m > 12 or d < 1 or d > daysInMonth(y, m)) return null;
    return .{ .y = y, .m = m, .d = d };
}

fn daysInMonth(year: i32, month: i32) i32 {
    if (month == 2) {
        return if (@mod(year, 4) == 0 and (@mod(year, 100) != 0 or @mod(year, 400) == 0)) 29 else 28;
    }
    if (month == 4 or month == 6 or month == 9 or month == 11) return 30;
    return 31;
}

fn parseDigits(s: []const u8) ?i32 {
    if (s.len == 0) return null;
    var v: i32 = 0;
    for (s) |c| {
        if (c < '0' or c > '9') return null;
        v = v * 10 + @as(i32, c - '0');
    }
    return v;
}

fn julianDay(year: i32, month: i32, day: i32) i32 {
    const a = @divTrunc(14 - month, 12);
    const y = year + 4800 - a;
    const m = month + 12 * a - 3;
    return day + @divTrunc(153 * m + 2, 5) + 365 * y + @divTrunc(y, 4) - @divTrunc(y, 100) + @divTrunc(y, 400) - 32045;
}

fn weekday(year: i32, month: i32, day: i32) usize {
    const jdn = julianDay(year, month, day);
    return @intCast(@mod(jdn + 1, 7));
}

// Resolved locale fields after compactness override is applied
const ResolvedLocale = struct {
    months: [12][]const u8,
    months_in_date: ?*const [12][]const u8,
    weekdays: [7][]const u8,
    day_format: []const u8,
    day_format_exceptions: []const DayFormatException,
    date_pattern: []const u8,
    date_pattern_with_year: []const u8,
    today: []const u8,
    tomorrow: []const u8,
    yesterday: []const u8,
};

fn resolveLocale(locale: *const DateLocale, compactness: Compactness) ResolvedLocale {
    var r = ResolvedLocale{
        .months = locale.months,
        .months_in_date = locale.months_in_date,
        .weekdays = locale.weekdays,
        .day_format = locale.day_format,
        .day_format_exceptions = locale.day_format_exceptions,
        .date_pattern = locale.date_pattern,
        .date_pattern_with_year = locale.date_pattern_with_year,
        .today = locale.today,
        .tomorrow = locale.tomorrow,
        .yesterday = locale.yesterday,
    };

    const ovr: ?CompactnessOverride = switch (compactness) {
        .short_mode => locale.short_override,
        .compact => locale.compact_override,
        .normal => null,
    };

    if (ovr) |o| {
        if (o.months) |m| r.months = m.*;
        if (o.months_in_date) |m| r.months_in_date = m;
        if (o.weekdays) |w| r.weekdays = w.*;
        if (o.day_format) |d| {
            r.day_format = d;
            // When DayFormat is overridden but exceptions are not, clear exceptions
            if (o.day_format_exceptions == null and o.clear_exceptions) {
                r.day_format_exceptions = &.{};
            }
        }
        if (o.day_format_exceptions) |e| r.day_format_exceptions = e;
        if (o.date_pattern) |p| r.date_pattern = p;
        if (o.date_pattern_with_year) |p| r.date_pattern_with_year = p;
        if (o.today) |t| r.today = t;
        if (o.tomorrow) |t| r.tomorrow = t;
        if (o.yesterday) |t| r.yesterday = t;
    }

    return r;
}

// ---- Formatting ----

fn formatAbsolute(buf: []u8, rl: *const ResolvedLocale, year: i32, month: i32, day: i32, include_year: bool) ?[]const u8 {
    const day_str = itoa(day);

    // Find exception for this day
    var day_fmt = rl.day_format;
    for (rl.day_format_exceptions) |exc| {
        if (eql(exc.day, day_str)) {
            day_fmt = exc.format;
            break;
        }
    }

    // Format the day
    var day_buf: [32]u8 = undefined;
    var day_w = Writer.init(&day_buf);
    replaceFirst(&day_w, day_fmt, "{n}", day_str);
    if (day_w.overflow) return null;
    const formatted_day = day_w.slice();

    // Pick month name (genitive form if available)
    const month_idx: usize = @intCast(month - 1);
    const month_name = if (rl.months_in_date) |mid| mid[month_idx] else rl.months[month_idx];

    const pattern = if (include_year) rl.date_pattern_with_year else rl.date_pattern;

    var w = Writer.init(buf);

    // Replace {month}
    var tmp1: [256]u8 = undefined;
    var w1 = Writer.init(&tmp1);
    replaceFirst(&w1, pattern, "{month}", month_name);
    if (w1.overflow) return null;

    // Replace {day}
    var tmp2: [256]u8 = undefined;
    var w2 = Writer.init(&tmp2);
    replaceFirst(&w2, w1.slice(), "{day}", formatted_day);
    if (w2.overflow) return null;

    // Replace {d} (numeric day without format)
    var tmp3: [256]u8 = undefined;
    var w3 = Writer.init(&tmp3);
    replaceFirst(&w3, w2.slice(), "{d}", day_str);
    if (w3.overflow) return null;

    // Replace {m} (numeric month)
    var tmp4: [256]u8 = undefined;
    var w4 = Writer.init(&tmp4);
    replaceFirst(&w4, w3.slice(), "{m}", itoa(month));
    if (w4.overflow) return null;

    if (include_year) {
        // Replace {year}
        var tmp5: [256]u8 = undefined;
        var w5 = Writer.init(&tmp5);
        replaceFirst(&w5, w4.slice(), "{year}", itoa(year));
        if (w5.overflow) return null;

        // Replace {yy}
        const yy = @mod(year, 100);
        var yy_buf: [4]u8 = undefined;
        var yy_w = Writer.init(&yy_buf);
        if (yy < 10) {
            yy_w.writeByte('0');
        }
        yy_w.writeInt(yy);
        replaceFirst(&w, w5.slice(), "{yy}", yy_w.slice());
    } else {
        w.writeStr(w4.slice());
    }

    return if (w.overflow) null else w.slice();
}

// ---- Public API ----

pub fn formatDate(buf: []u8, locale: *const DateLocale, compactness: Compactness, date: []const u8) ?[]const u8 {
    if (date.len == 0) return null;
    const parsed = parseDate(date) orelse return null;
    const rl = resolveLocale(locale, compactness);
    return formatAbsolute(buf, &rl, parsed.y, parsed.m, parsed.d, false);
}

pub fn formatDateWithYear(buf: []u8, locale: *const DateLocale, compactness: Compactness, date: []const u8) ?[]const u8 {
    if (date.len == 0) return null;
    const parsed = parseDate(date) orelse return null;
    const rl = resolveLocale(locale, compactness);
    return formatAbsolute(buf, &rl, parsed.y, parsed.m, parsed.d, true);
}

pub fn formatRelative(buf: []u8, locale: *const DateLocale, compactness: Compactness, date: []const u8, as_of: []const u8) ?[]const u8 {
    if (date.len == 0 or as_of.len == 0) return null;
    const parsed_date = parseDate(date) orelse return null;
    const parsed_as_of = parseDate(as_of) orelse return null;

    const rl = resolveLocale(locale, compactness);

    const date_jdn = julianDay(parsed_date.y, parsed_date.m, parsed_date.d);
    const asof_jdn = julianDay(parsed_as_of.y, parsed_as_of.m, parsed_as_of.d);
    const diff = date_jdn - asof_jdn;

    // Today
    if (diff == 0) {
        var w = Writer.init(buf);
        w.writeStr(rl.today);
        return if (w.overflow) null else w.slice();
    }

    // Tomorrow
    if (diff == 1) {
        var w = Writer.init(buf);
        w.writeStr(rl.tomorrow);
        return if (w.overflow) null else w.slice();
    }

    // Yesterday
    if (diff == -1) {
        var w = Writer.init(buf);
        w.writeStr(rl.yesterday);
        return if (w.overflow) null else w.slice();
    }

    const is_compact = compactness == .compact;

    // Day after tomorrow (optional, skipped in compact mode)
    if (diff == 2 and locale.day_after_tomorrow != null and !is_compact) {
        var w = Writer.init(buf);
        w.writeStr(locale.day_after_tomorrow.?);
        return if (w.overflow) null else w.slice();
    }

    // Day before yesterday (optional, skipped in compact mode)
    if (diff == -2 and locale.day_before_yesterday != null and !is_compact) {
        var w = Writer.init(buf);
        w.writeStr(locale.day_before_yesterday.?);
        return if (w.overflow) null else w.slice();
    }

    // Compact mode: skip weekday references
    if (is_compact) {
        const include_year = parsed_date.y != parsed_as_of.y;
        return formatAbsolute(buf, &rl, parsed_date.y, parsed_date.m, parsed_date.d, include_year);
    }

    // This weekday (+2 to +6)
    if (diff >= 2 and diff <= 6 and locale.this_weekday != null) {
        const dow = weekday(parsed_date.y, parsed_date.m, parsed_date.d);
        const weekday_name = rl.weekdays[dow];
        var w = Writer.init(buf);
        replaceFirst(&w, locale.this_weekday.?, "{weekday}", weekday_name);
        return if (w.overflow) null else w.slice();
    }

    // Last weekday (-6 to -2)
    if (diff >= -6 and diff <= -2 and locale.last_weekday != null) {
        const dow = weekday(parsed_date.y, parsed_date.m, parsed_date.d);
        const weekday_name = rl.weekdays[dow];
        var w = Writer.init(buf);
        replaceFirst(&w, locale.last_weekday.?, "{weekday}", weekday_name);
        return if (w.overflow) null else w.slice();
    }

    // Next weekday (+7 to +13)
    if (diff >= 7 and diff <= 13 and locale.next_weekday != null) {
        const dow = weekday(parsed_date.y, parsed_date.m, parsed_date.d);
        const weekday_name = rl.weekdays[dow];
        var w = Writer.init(buf);
        replaceFirst(&w, locale.next_weekday.?, "{weekday}", weekday_name);
        return if (w.overflow) null else w.slice();
    }

    // Calendar fallback
    const include_year = parsed_date.y != parsed_as_of.y;
    return formatAbsolute(buf, &rl, parsed_date.y, parsed_date.m, parsed_date.d, include_year);
}
