/// Human-friendly duration and relative time formatting.
module sayableduration.format_duration;

import std.typecons : Nullable;
import sayableduration.locale;

/// Library version.
enum VERSION = "0.5.0";

/// Int to string conversion without allocator dependency.
private string intToStr(int n) {
    if (n == 0) return "0";
    if (n < 0) return "-" ~ intToStr(-n);
    char[20] buf;
    int pos = 20;
    while (n > 0) {
        pos--;
        buf[pos] = cast(char)('0' + n % 10);
        n /= 10;
    }
    return buf[pos .. 20].idup;
}

/// Check if a string contains a substring.
private bool strContains(string haystack, string needle) {
    if (needle.length == 0) return true;
    if (needle.length > haystack.length) return false;
    foreach (i; 0 .. haystack.length - needle.length + 1) {
        if (haystack[i .. i + needle.length] == needle) {
            return true;
        }
    }
    return false;
}

/// Replace first occurrence of a substring.
private string strReplace(string s, string from, string to) {
    if (from.length == 0) return s;
    foreach (i; 0 .. s.length) {
        if (i + from.length <= s.length && s[i .. i + from.length] == from) {
            return s[0 .. i] ~ to ~ s[i + from.length .. $];
        }
    }
    return s;
}

/// Resolve a unit form with count, plural function, and optional half marker.
private string resolveUnit(int count, ref const UnitForms uf, const(DurationLocale)* loc, string half) {
    string baseN = intToStr(count);

    // Apply {n}-style half marker to the number.
    string n = baseN;
    if (half.length > 0 && strContains(half, "{n}")) {
        n = strReplace(half, "{n}", baseN);
    }

    // Select template.
    string tmpl;
    if (uf.simple.length > 0) {
        tmpl = uf.simple;
    } else {
        // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
        PluralCategory cat;
        if (half.length > 0) {
            cat = PluralCategory.other;
        } else {
            cat = loc.plural(count);
        }
        tmpl = lookupForm(uf, cat);
    }

    string result = strReplace(tmpl, "{n}", n);

    // Apply {0}-style half marker (wraps the whole expression).
    if (half.length > 0 && strContains(half, "{0}")) {
        result = strReplace(half, "{0}", result);
    }

    return result;
}

/// Check if a year is a leap year.
private bool isLeapYear(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

/// Days in a given month of a given year.
private int daysInMonth(int y, int m) {
    static immutable int[12] _days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (m < 1 || m > 12) return 30;
    if (m == 2 && isLeapYear(y)) return 29;
    return _days[m - 1];
}

/// Calculate days since epoch (2000-01-01).
private long daysSinceEpoch(int y, int m, int d) {
    long days = 0;
    if (y >= 2000) {
        for (int yy = 2000; yy < y; yy++) {
            days += isLeapYear(yy) ? 366 : 365;
        }
    } else {
        for (int yy = y; yy < 2000; yy++) {
            days -= isLeapYear(yy) ? 366 : 365;
        }
    }
    for (int mm = 1; mm < m; mm++) {
        days += daysInMonth(y, mm);
    }
    days += d - 1;
    return days;
}

/// Convert a numeric string slice to int.
private int atoiSlice(string s) {
    int n = 0;
    foreach (c; s) {
        if (c < '0' || c > '9') {
            return 0;
        }
        n = n * 10 + (c - '0');
    }
    return n;
}

/// Number of leading ASCII digits in s.
private size_t digitRun(string s) {
    size_t n = 0;
    while (n < s.length && s[n] >= '0' && s[n] <= '9') {
        n++;
    }
    return n;
}

/// Nothing, "Z", or "+HH:MM" / "-HH:MM".
private bool isZoneSuffix(string s) {
    if (s.length == 0) return true;
    if (s.length == 1) return s[0] == 'Z';
    return s.length == 6 && (s[0] == '+' || s[0] == '-') && digitRun(s[1 .. 3]) == 2
        && s[3] == ':' && digitRun(s[4 .. 6]) == 2;
}

/// Parse H:MM or HH:MM, optional :SS, optional . plus digits after the seconds,
/// and an optional zone suffix, which is validated but ignored.
private bool parseClock(string clock, out int hour, out int minute, out int second) {
    immutable hourLen = digitRun(clock);
    if (hourLen < 1 || hourLen > 2 || clock.length < hourLen + 3 || clock[hourLen] != ':'
        || digitRun(clock[hourLen + 1 .. hourLen + 3]) != 2) {
        return false;
    }
    hour = atoiSlice(clock[0 .. hourLen]);
    minute = atoiSlice(clock[hourLen + 1 .. hourLen + 3]);
    second = 0;
    string rest = clock[hourLen + 3 .. $];
    if (rest.length > 0 && rest[0] == ':') {
        if (rest.length < 3 || digitRun(rest[1 .. 3]) != 2) return false;
        second = atoiSlice(rest[1 .. 3]);
        rest = rest[3 .. $];
        if (rest.length > 0 && rest[0] == '.') {
            immutable fractionLen = digitRun(rest[1 .. $]);
            if (fractionLen == 0) return false;
            rest = rest[1 + fractionLen .. $];
        }
    }
    return isZoneSuffix(rest) && hour <= 23 && minute <= 59 && second <= 59;
}

/// Parse a timestamp YYYY-MM-DDTHH:MM[:SS[.fff]][zone] (docs/input-formats.md)
/// to seconds since 2000-01-01 for diffing; null if malformed.
private Nullable!long parseISOToSeconds(string s) {
    if (s.length < 11 || s[4] != '-' || s[7] != '-' || s[10] != 'T'
        || digitRun(s[0 .. 4]) != 4 || digitRun(s[5 .. 7]) != 2 || digitRun(s[8 .. 10]) != 2) {
        return Nullable!long.init;
    }
    immutable year = atoiSlice(s[0 .. 4]);
    immutable month = atoiSlice(s[5 .. 7]);
    immutable day = atoiSlice(s[8 .. 10]);
    int hour, minute, second;
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)
        || !parseClock(s[11 .. $], hour, minute, second)) {
        return Nullable!long.init;
    }
    return Nullable!long(daysSinceEpoch(year, month, day) * 86400 + hour * 3600 + minute * 60 + second);
}

/// Durations over 6000 months (500 years) have no value: the same ceiling as sayable-age.
private enum MAX_DURATION_MONTHS = 6000;

/// Months from whole days, 30.44 days to the month, rounded.
private long approximateMonths(long totalDays) {
    return cast(long)(cast(double) totalDays / 30.44 + 0.5);
}

/// Locale-aware duration and relative time formatter.
struct SayableDuration {
    private const(DurationLocale)* _locale;
    private UnitForms _second;
    private UnitForms _minute;
    private UnitForms _hour;
    private UnitForms _day;
    private UnitForms _week;
    private UnitForms _month;
    private UnitForms _year;
    private string _half;
    private string _delimiter;
    private string _justNow;
    private string _ago;
    private string _inFuture;

    /// Create a new SayableDuration instance with the given locale and optional compactness.
    this(ref const DurationLocale loc, Compactness compactness = Compactness.normal) {
        _locale = &loc;
        _second = loc.second;
        _minute = loc.minute;
        _hour = loc.hour;
        _day = loc.day;
        _week = loc.week;
        _month = loc.month;
        _year = loc.year;
        _half = loc.half;
        _delimiter = loc.delimiter;
        _justNow = loc.justNow;
        _ago = loc.ago;
        _inFuture = loc.inFuture;

        const(DurationCompactnessOverride)* ovr;
        final switch (compactness) {
            case Compactness.normal:
                ovr = null;
                break;
            case Compactness.short_:
                ovr = &loc.short_;
                break;
            case Compactness.compact:
                ovr = &loc.compact_;
                break;
        }

        if (ovr !is null) {
            if (!isEmptyUnit(ovr.second)) _second = ovr.second;
            if (!isEmptyUnit(ovr.minute)) _minute = ovr.minute;
            if (!isEmptyUnit(ovr.hour)) _hour = ovr.hour;
            if (!isEmptyUnit(ovr.day)) _day = ovr.day;
            if (!isEmptyUnit(ovr.week)) _week = ovr.week;
            if (!isEmptyUnit(ovr.month)) _month = ovr.month;
            if (!isEmptyUnit(ovr.year)) _year = ovr.year;
            if (!ovr.half.isNull) _half = ovr.half.get;
            if (!ovr.delimiter.isNull) _delimiter = ovr.delimiter.get;
            if (!ovr.ago.isNull) _ago = ovr.ago.get;
            if (!ovr.inFuture.isNull) _inFuture = ovr.inFuture.get;
        }
    }

    /// Format a duration in seconds as human-friendly text.
    Nullable!string formatDuration(long totalSeconds) {
        if (totalSeconds < 0) {
            return Nullable!string.init;
        }
        return formatDurationSeconds(totalSeconds);
    }

    /// Format a duration between two ISO timestamps.
    Nullable!string formatDurationISO(string start, string end) {
        if (start.length == 0 || end.length == 0) {
            return Nullable!string.init;
        }
        auto s = parseISOToSeconds(start);
        auto e = parseISOToSeconds(end);
        if (s.isNull || e.isNull) {
            return Nullable!string.init;
        }
        long diff = e.get - s.get;
        if (diff < 0) diff = -diff;
        return formatDurationSeconds(diff);
    }

    /// Format elapsed time as "X ago".
    Nullable!string formatSince(string start, string asOf) {
        if (start.length == 0 || asOf.length == 0) {
            return Nullable!string.init;
        }
        auto s = parseISOToSeconds(start);
        auto a = parseISOToSeconds(asOf);
        if (s.isNull || a.isNull) {
            return Nullable!string.init;
        }
        long diff = a.get - s.get;
        if (diff < 0) return Nullable!string.init;
        if (diff == 0) return Nullable!string(_justNow);
        auto dur = formatDurationSeconds(diff);
        if (dur.isNull) return dur;
        return Nullable!string(strReplace(_ago, "{0}", dur.get));
    }

    /// Format time until a future event as "in X".
    Nullable!string formatUntil(string target, string asOf) {
        if (target.length == 0 || asOf.length == 0) {
            return Nullable!string.init;
        }
        auto t = parseISOToSeconds(target);
        auto a = parseISOToSeconds(asOf);
        if (t.isNull || a.isNull) {
            return Nullable!string.init;
        }
        long diff = t.get - a.get;
        if (diff < 0) return Nullable!string.init;
        if (diff == 0) return Nullable!string(_justNow);
        auto dur = formatDurationSeconds(diff);
        if (dur.isNull) return dur;
        return Nullable!string(strReplace(_inFuture, "{0}", dur.get));
    }

    /// Apply duration tiers to total seconds; null beyond the 500-year ceiling.
    private Nullable!string formatDurationSeconds(long totalSeconds) {
        immutable wholeDays = totalSeconds / 86400;
        if (wholeDays >= 30 && approximateMonths(wholeDays) > MAX_DURATION_MONTHS) {
            return Nullable!string.init;
        }
        // Within the ceiling (under 2^34 seconds) every count below fits an int.
        return Nullable!string(formatTiers(totalSeconds));
    }

    /// Apply duration tiers to total seconds within the 500-year ceiling.
    private string formatTiers(long total) {
        // 0 seconds
        if (total == 0) return _justNow;

        // 1-59 seconds
        if (total < 60) {
            return resolveUnit(cast(int) total, _second, _locale, "");
        }

        int totalMinutes = cast(int)(total / 60);
        int remainderSeconds = cast(int)(total % 60);

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5) {
            string result = resolveUnit(totalMinutes, _minute, _locale, "");
            if (remainderSeconds > 0) {
                result = result ~ _delimiter ~ resolveUnit(remainderSeconds, _second, _locale, "");
            }
            return result;
        }

        // 5-59 minutes
        if (totalMinutes < 60) {
            return resolveUnit(totalMinutes, _minute, _locale, "");
        }

        int totalHours = cast(int)(total / 3600);
        int remainderMinutes = cast(int)((total % 3600) / 60);

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5) {
            if (remainderMinutes == 30) {
                return resolveUnit(totalHours, _hour, _locale, _half);
            }
            string result = resolveUnit(totalHours, _hour, _locale, "");
            if (remainderMinutes > 0) {
                result = result ~ _delimiter ~ resolveUnit(remainderMinutes, _minute, _locale, "");
            }
            return result;
        }

        // 6-23 hours
        if (totalHours < 24) {
            return resolveUnit(totalHours, _hour, _locale, "");
        }

        int totalDays = cast(int)(total / 86400);
        int remainderHours = cast(int)((total % 86400) / 3600);

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2) {
            if (remainderHours == 12) {
                return resolveUnit(totalDays, _day, _locale, _half);
            }
            string result = resolveUnit(totalDays, _day, _locale, "");
            if (remainderHours > 0) {
                result = result ~ _delimiter ~ resolveUnit(remainderHours, _hour, _locale, "");
            }
            return result;
        }

        // 3-6 days
        if (totalDays < 7) {
            return resolveUnit(totalDays, _day, _locale, "");
        }

        int totalWeeks = totalDays / 7;
        int remainderDays = totalDays % 7;

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            string result = resolveUnit(totalWeeks, _week, _locale, "");
            if (remainderDays > 0) {
                result = result ~ _delimiter ~ resolveUnit(remainderDays, _day, _locale, "");
            }
            return result;
        }

        // Approximate months (30.44 days average)
        int totalMonths = cast(int) approximateMonths(totalDays);

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0) totalMonths = 1;
            return resolveUnit(totalMonths, _month, _locale, "");
        }

        // 12+ months: years + months
        int totalYears = totalMonths / 12;
        int remainderMonths = totalMonths % 12;
        string result = resolveUnit(totalYears, _year, _locale, "");
        if (remainderMonths > 0) {
            result = result ~ _delimiter ~ resolveUnit(remainderMonths, _month, _locale, "");
        }
        return result;
    }
}
