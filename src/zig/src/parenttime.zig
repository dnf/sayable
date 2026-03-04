// parent-time Zig implementation — types and formatter.

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

pub const StageLabel = struct {
    label: []const u8,
    f: []const u8,
};

pub const Stages = struct {
    newborn: StageLabel,
    infant: StageLabel,
    toddler: StageLabel,
    child: StageLabel,
    teenager: StageLabel,
    adult: StageLabel,
};

pub const UnitSet = struct {
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
};

pub const CompactnessOverride = struct {
    day: ?UnitForms = null,
    week: ?UnitForms = null,
    month: ?UnitForms = null,
    year: ?UnitForms = null,
    half: ?[]const u8 = null,
    delimiter: ?[]const u8 = null,
    just_born: ?[]const u8 = null,
};

pub const Locale = struct {
    code: []const u8,
    plural: *const fn (n: i32) PluralCategory,
    units: UnitSet,
    half: []const u8,
    delimiter: []const u8,
    just_born: []const u8,
    stages: Stages,
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

// ---- Itoa into static buffer ----

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

fn parseDate(s: []const u8) ?Date {
    if (s.len < 10 or s[4] != '-' or s[7] != '-') return null;
    const y = parseDigits(s[0..4]) orelse return null;
    const m = parseDigits(s[5..7]) orelse return null;
    const d = parseDigits(s[8..10]) orelse return null;
    if (y == 0 and m == 0 and d == 0) return null;
    return .{ .y = y, .m = m, .d = d };
}

fn parseDigits(s: []const u8) ?i32 {
    var v: i32 = 0;
    for (s) |c| {
        if (c < '0' or c > '9') return null;
        v = v * 10 + @as(i32, c - '0');
    }
    return v;
}

fn daysInMonth(year: i32, month: i32) i32 {
    if (month == 2) {
        return if (@mod(year, 4) == 0 and (@mod(year, 100) != 0 or @mod(year, 400) == 0)) 29 else 28;
    }
    if (month == 4 or month == 6 or month == 9 or month == 11) return 30;
    return 31;
}

fn julianDay(year: i32, month: i32, day: i32) i32 {
    const a = @divTrunc(14 - month, 12);
    const y = year + 4800 - a;
    const m = month + 12 * a - 3;
    return day + @divTrunc(153 * m + 2, 5) + 365 * y + @divTrunc(y, 4) - @divTrunc(y, 100) + @divTrunc(y, 400) - 32045;
}

const max_age_months = 6000;

// ---- String search ----

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

// ---- Replace first occurrence ----

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

fn resolveUnit(w: *Writer, count: i32, uf: UnitForms, locale: *const Locale, half: []const u8) void {
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

    // Select template
    const cat = locale.plural(count);
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

// ---- Public API ----

pub fn formatAge(buf: []u8, locale: *const Locale, compactness: Compactness, dob: []const u8, as_of: []const u8) ?[]const u8 {
    const dob_date = parseDate(dob) orelse return null;
    if (as_of.len == 0) return null;
    const ref_date = parseDate(as_of) orelse return null;

    const diff_days = julianDay(ref_date.y, ref_date.m, ref_date.d) - julianDay(dob_date.y, dob_date.m, dob_date.d);
    if (diff_days < 0) return null;

    const last_day = daysInMonth(ref_date.y, ref_date.m);
    const clamped_birthday = if (dob_date.d < last_day) dob_date.d else last_day;
    var months = (ref_date.y - dob_date.y) * 12 + (ref_date.m - dob_date.m);
    if (ref_date.d < clamped_birthday) months -= 1;
    if (months > max_age_months) return null;

    // Resolve compactness overrides
    var day_uf = locale.units.day;
    var week_uf = locale.units.week;
    var month_uf = locale.units.month;
    var year_uf = locale.units.year;
    var half = locale.half;
    var delimiter = locale.delimiter;
    var just_born = locale.just_born;

    const ovr: ?CompactnessOverride = switch (compactness) {
        .short_mode => locale.short_override,
        .compact => locale.compact_override,
        .normal => null,
    };

    if (ovr) |o| {
        if (o.day) |d| day_uf = d;
        if (o.week) |w| week_uf = w;
        if (o.month) |m| month_uf = m;
        if (o.year) |y| year_uf = y;
        if (o.half) |h| half = h;
        if (o.delimiter) |d| delimiter = d;
        if (o.just_born) |j| just_born = j;
    }

    var w = Writer.init(buf);

    // Tier 1: 0 days
    if (diff_days == 0) {
        w.writeStr(just_born);
        return if (w.overflow) null else w.slice();
    }

    // Tier 1b: 1-6 days
    if (diff_days < 7) {
        resolveUnit(&w, diff_days, day_uf, locale, "");
        return if (w.overflow) null else w.slice();
    }

    // Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
        const weeks = @divTrunc(diff_days, 7);
        const days = @mod(diff_days, 7);
        resolveUnit(&w, weeks, week_uf, locale, "");
        if (days > 0) {
            w.writeStr(delimiter);
            resolveUnit(&w, days, day_uf, locale, "");
        }
        return if (w.overflow) null else w.slice();
    }

    // Tier 3: 3-23 months
    if (months < 24) {
        resolveUnit(&w, months, month_uf, locale, "");
        return if (w.overflow) null else w.slice();
    }

    // Tier 4: 24-35 months -> years + months
    if (months < 36) {
        const years = @divTrunc(months, 12);
        const rem = @mod(months, 12);
        if (rem == 0) {
            resolveUnit(&w, years, year_uf, locale, "");
        } else {
            resolveUnit(&w, years, year_uf, locale, "");
            w.writeStr(delimiter);
            resolveUnit(&w, rem, month_uf, locale, "");
        }
        return if (w.overflow) null else w.slice();
    }

    // Tier 5: 3-6 years -> years with half marker
    if (months < 84) {
        const years = @divTrunc(months, 12);
        const rem = @mod(months, 12);
        if (rem >= 6) {
            resolveUnit(&w, years, year_uf, locale, half);
        } else {
            resolveUnit(&w, years, year_uf, locale, "");
        }
        return if (w.overflow) null else w.slice();
    }

    // Tier 6: 7+ years
    {
        const years = @divTrunc(months, 12);
        resolveUnit(&w, years, year_uf, locale, "");
        return if (w.overflow) null else w.slice();
    }
}

pub fn formatStage(locale: *const Locale, dob: []const u8, as_of: []const u8, gender: ?[]const u8) ?[]const u8 {
    const dob_date = parseDate(dob) orelse return null;
    if (as_of.len == 0) return null;
    const ref_date = parseDate(as_of) orelse return null;

    const diff_days = julianDay(ref_date.y, ref_date.m, ref_date.d) - julianDay(dob_date.y, dob_date.m, dob_date.d);
    if (diff_days < 0) return null;

    const last_day = daysInMonth(ref_date.y, ref_date.m);
    const clamped_birthday = if (dob_date.d < last_day) dob_date.d else last_day;
    var months = (ref_date.y - dob_date.y) * 12 + (ref_date.m - dob_date.m);
    if (ref_date.d < clamped_birthday) months -= 1;
    if (months > max_age_months) return null;

    const label: StageLabel = if (months < 2)
        locale.stages.newborn
    else if (months < 12)
        locale.stages.infant
    else if (months < 36)
        locale.stages.toddler
    else if (months < 156)
        locale.stages.child
    else if (months < 216)
        locale.stages.teenager
    else
        locale.stages.adult;

    if (gender) |g| {
        if (g.len > 0 and g[0] == 'f' and label.f.len > 0) return label.f;
    }
    return label.label;
}
