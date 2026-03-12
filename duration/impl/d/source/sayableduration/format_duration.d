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

/// Parse ISO datetime string to epoch-ish seconds for diffing.
private Nullable!long parseISOToSeconds(string s) {
    if (s.length == 0) {
        return Nullable!long.init;
    }
    // Find 'T' separator
    int tPos = -1;
    foreach (i, c; s) {
        if (c == 'T') {
            tPos = cast(int) i;
            break;
        }
    }
    if (tPos < 0) {
        return Nullable!long.init;
    }

    string datePart = s[0 .. tPos];
    string timePart = s[tPos + 1 .. $];

    // Parse date
    if (datePart.length < 10 || datePart[4] != '-' || datePart[7] != '-') {
        return Nullable!long.init;
    }
    int year = atoiSlice(datePart[0 .. 4]);
    int month = atoiSlice(datePart[5 .. 7]);
    int day = atoiSlice(datePart[8 .. 10]);

    // Strip timezone from time part
    string timeStr = timePart;
    foreach (i, c; timeStr) {
        if (c == '+' || c == 'Z') {
            timeStr = timeStr[0 .. i];
            break;
        }
    }

    // Parse time HH:MM:SS
    if (timeStr.length < 5 || timeStr[2] != ':') {
        return Nullable!long.init;
    }
    int hour = atoiSlice(timeStr[0 .. 2]);
    int minute = atoiSlice(timeStr[3 .. 5]);
    int second = 0;
    if (timeStr.length >= 8 && timeStr[5] == ':') {
        // Handle fractional seconds by only taking digits before '.'
        string secStr = timeStr[6 .. 8];
        foreach (i, c; secStr) {
            if (c == '.') {
                secStr = secStr[0 .. i];
                break;
            }
        }
        second = atoiSlice(secStr);
    }

    long days = daysSinceEpoch(year, month, day);
    return Nullable!long(days * 86400 + hour * 3600 + minute * 60 + second);
}

/// Round to nearest integer (for positive values).
private int roundToInt(double v) {
    return cast(int)(v + 0.5);
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
    Nullable!string formatDuration(int totalSeconds) {
        if (totalSeconds < 0) {
            return Nullable!string.init;
        }
        return Nullable!string(formatDurationSeconds(totalSeconds));
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
        return Nullable!string(formatDurationSeconds(cast(int) diff));
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
        string dur = formatDurationSeconds(cast(int) diff);
        return Nullable!string(strReplace(_ago, "{0}", dur));
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
        string dur = formatDurationSeconds(cast(int) diff);
        return Nullable!string(strReplace(_inFuture, "{0}", dur));
    }

    /// Apply duration tiers to total seconds.
    private string formatDurationSeconds(int total) {
        // 0 seconds
        if (total == 0) return _justNow;

        // 1-59 seconds
        if (total < 60) {
            return resolveUnit(total, _second, _locale, "");
        }

        int totalMinutes = total / 60;
        int remainderSeconds = total % 60;

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

        int totalHours = total / 3600;
        int remainderMinutes = (total % 3600) / 60;

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

        int totalDays = total / 86400;
        int remainderHours = (total % 86400) / 3600;

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
        int totalMonths = roundToInt(cast(double) totalDays / 30.44);

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
