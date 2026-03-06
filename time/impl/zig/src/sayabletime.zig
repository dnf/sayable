// sayable-time Zig implementation — types and formatter.

pub const version = "0.5.0";

pub const locales = @import("locales/locales.zig");

// ---- Types ----

pub const Compactness = enum {
    normal,
    short_mode,
    compact,
};

pub const ClockConfig = struct {
    hours: [12][]const u8,
    midnight: []const u8,
    noon: []const u8,
    patterns: [12][]const u8,
};

pub const ShortClockConfig = struct {
    use_24h: bool,
    am_pm: ?[2][]const u8 = null,
    format: []const u8,
};

pub const CompactnessOverride = struct {
    clock: ?ShortClockConfig = null,
};

pub const TimeLocale = struct {
    code: []const u8,
    clock: ClockConfig,
    short_override: ?CompactnessOverride = null,
    compact_override: ?CompactnessOverride = null,
};

// ---- Writer (buffer management) ----

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

// ---- Time parsing ----

fn parseTime(input: []const u8) ?[2]i32 {
    if (input.len == 0) return null;

    // Extract time portion from ISO datetime
    var t = input;
    if (indexOfByte(t, 'T')) |ti| {
        t = t[ti + 1 ..];
    }

    // Strip timezone
    for (t, 0..) |c, i| {
        if (c == '+' or c == 'Z') {
            t = t[0..i];
            break;
        }
    }

    // Split by ':'
    const colon_pos = indexOfByte(t, ':') orelse return null;
    const hour_str = t[0..colon_pos];
    var minute_str = t[colon_pos + 1 ..];

    // Strip fractional seconds or seconds part from minute
    for (minute_str, 0..) |c, i| {
        if (c == '.' or c == ':') {
            minute_str = minute_str[0..i];
            break;
        }
    }

    const hour = parseDigits(hour_str) orelse return null;
    const minute = parseDigits(minute_str) orelse return null;

    if (hour > 23 or minute > 59) return null;
    return .{ hour, minute };
}

fn indexOfByte(s: []const u8, needle: u8) ?usize {
    for (s, 0..) |c, i| {
        if (c == needle) return i;
    }
    return null;
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

fn roundTo5(minute: i32) i32 {
    return @divTrunc(minute + 2, 5) * 5;
}

fn zeroPad(w: *Writer, n: i32) void {
    if (n < 10) {
        w.writeByte('0');
    }
    w.writeInt(n);
}

// ---- Public API ----

pub fn formatTime(buf: []u8, locale: *const TimeLocale, compactness: Compactness, input: []const u8) ?[]const u8 {
    if (input.len == 0) return null;

    const parsed = parseTime(input) orelse return null;
    const hour = parsed[0];
    const minute = parsed[1];

    // Determine short clock config
    const short_clock: ?ShortClockConfig = switch (compactness) {
        .short_mode => if (locale.short_override) |ovr| ovr.clock else null,
        .compact => if (locale.compact_override) |ovr| ovr.clock else null,
        .normal => null,
    };

    if (compactness != .normal) {
        if (short_clock) |sc| {
            return formatDigital(buf, hour, minute, sc);
        }
    }

    return formatNatural(buf, hour, minute, &locale.clock);
}

fn formatNatural(buf: []u8, hour: i32, minute: i32, clock: *const ClockConfig) ?[]const u8 {
    var rounded = roundTo5(minute);
    var h = hour;
    if (rounded == 60) {
        rounded = 0;
        h = @mod(h + 1, 24);
    }

    if (rounded == 0) {
        if (h == 0) {
            var w = Writer.init(buf);
            w.writeStr(clock.midnight);
            return if (w.overflow) null else w.slice();
        }
        if (h == 12) {
            var w = Writer.init(buf);
            w.writeStr(clock.noon);
            return if (w.overflow) null else w.slice();
        }
    }

    const h12: usize = @intCast(@mod(h, 12));
    const next_h12: usize = @intCast(@mod(h + 1, 12));
    const h_name = clock.hours[h12];
    const next_h_name = clock.hours[next_h12];

    // Pattern index: rounded / 5
    const pattern_idx: usize = @intCast(@divTrunc(rounded, 5));
    const pattern = clock.patterns[pattern_idx];

    var w = Writer.init(buf);

    // Replace {h} and {next_h}
    var tmp_buf: [256]u8 = undefined;
    var tmp_w = Writer.init(&tmp_buf);
    replaceFirst(&tmp_w, pattern, "{h}", h_name);
    if (tmp_w.overflow) return null;

    replaceFirst(&w, tmp_w.slice(), "{next_h}", next_h_name);
    return if (w.overflow) null else w.slice();
}

fn formatDigital(buf: []u8, hour: i32, minute: i32, sc: ShortClockConfig) ?[]const u8 {
    var w = Writer.init(buf);

    if (sc.use_24h) {
        // Replace {h} and {mm} in format
        var tmp_buf: [64]u8 = undefined;
        var tmp_w = Writer.init(&tmp_buf);
        var h_buf: [12]u8 = undefined;
        var h_w = Writer.init(&h_buf);
        h_w.writeInt(hour);
        replaceFirst(&tmp_w, sc.format, "{h}", h_w.slice());
        if (tmp_w.overflow) return null;

        var mm_buf: [4]u8 = undefined;
        var mm_w = Writer.init(&mm_buf);
        zeroPad(&mm_w, minute);
        replaceFirst(&w, tmp_w.slice(), "{mm}", mm_w.slice());
    } else {
        var h12 = @mod(hour, 12);
        if (h12 == 0) h12 = 12;

        const am_pm = sc.am_pm orelse [2][]const u8{ "AM", "PM" };
        const ampm_str = if (hour < 12) am_pm[0] else am_pm[1];

        // Replace {h}, {mm}, {ampm}
        var tmp1_buf: [64]u8 = undefined;
        var tmp1_w = Writer.init(&tmp1_buf);
        var h_buf: [12]u8 = undefined;
        var h_w = Writer.init(&h_buf);
        h_w.writeInt(h12);
        replaceFirst(&tmp1_w, sc.format, "{h}", h_w.slice());
        if (tmp1_w.overflow) return null;

        var tmp2_buf: [64]u8 = undefined;
        var tmp2_w = Writer.init(&tmp2_buf);
        var mm_buf: [4]u8 = undefined;
        var mm_w = Writer.init(&mm_buf);
        zeroPad(&mm_w, minute);
        replaceFirst(&tmp2_w, tmp1_w.slice(), "{mm}", mm_w.slice());
        if (tmp2_w.overflow) return null;

        replaceFirst(&w, tmp2_w.slice(), "{ampm}", ampm_str);
    }

    return if (w.overflow) null else w.slice();
}
