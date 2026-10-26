/// Human-friendly clock time formatting.
module sayabletime.format_time;

import std.typecons : Nullable;
import sayabletime.locale;

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

/// Zero-padded 2-digit string.
private string zeroPad2(int n) {
    if (n < 10) return "0" ~ intToStr(n);
    return intToStr(n);
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

/// Convert a numeric string slice to int.
private int atoiSlice(string s) {
    int n = 0;
    foreach (c; s) {
        if (c < '0' || c > '9') {
            return -1;
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

/// Days in a Gregorian month (leap years by the 4/100/400 rule).
private int daysInMonth(int y, int m) {
    if (m == 2) {
        return ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28;
    }
    return (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31;
}

/// True for exactly YYYY-MM-DD naming a real calendar day.
private bool isRealDate(string s) {
    if (s.length != 10 || s[4] != '-' || s[7] != '-') return false;
    immutable year = atoiSlice(s[0 .. 4]);
    immutable month = atoiSlice(s[5 .. 7]);
    immutable day = atoiSlice(s[8 .. 10]);
    return year >= 0 && month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month);
}

/// Parse a clock time, alone or after the T of an ISO datetime whose date is
/// valid, to (hour, minute) (docs/input-formats.md). Returns false on failure.
private bool parseTime(string s, out int hour, out int minute) {
    string clock = s;
    foreach (i, c; s) {
        if (c == 'T') {
            if (!isRealDate(s[0 .. i])) return false;
            clock = s[i + 1 .. $];
            break;
        }
    }
    int second;
    return parseClock(clock, hour, minute, second);
}

/// Round minute to nearest 5.
private int roundTo5(int minute) {
    return ((minute + 2) / 5) * 5;
}

/// Locale-aware clock time formatter.
struct SayableTime {
    private const(TimeLocale)* _locale;
    private Compactness _compactness;
    private const(ShortClockConfig)* _shortClock;

    /// Create a new SayableTime instance with the given locale and optional compactness.
    this(ref const TimeLocale loc, Compactness compactness = Compactness.normal) {
        _locale = &loc;
        _compactness = compactness;
        _shortClock = null;

        final switch (compactness) {
            case Compactness.normal:
                break;
            case Compactness.short_:
                if (loc.short_.clock.isSet) {
                    _shortClock = &loc.short_.clock;
                }
                break;
            case Compactness.compact:
                if (loc.compact_.clock.isSet) {
                    _shortClock = &loc.compact_.clock;
                }
                break;
        }
    }

    /// Format a time as natural language clock reading.
    Nullable!string formatTime(string input) {
        if (input.length == 0) {
            return Nullable!string.init;
        }
        int hour, minute;
        if (!parseTime(input, hour, minute)) {
            return Nullable!string.init;
        }

        if (_compactness != Compactness.normal && _shortClock !is null) {
            return Nullable!string(formatDigital(hour, minute));
        }
        return Nullable!string(formatNatural(hour, minute));
    }

    /// Format time as natural spoken language.
    private string formatNatural(int hour, int minute) {
        int rounded = roundTo5(minute);
        int h = hour;
        if (rounded == 60) {
            rounded = 0;
            h = (h + 1) % 24;
        }
        if (rounded == 0) {
            if (h == 0) return _locale.clock.midnight;
            if (h == 12) return _locale.clock.noon;
        }
        int h12 = h % 12;
        int nextH12 = (h + 1) % 12;
        string hName = _locale.clock.hours[h12];
        string nextHName = _locale.clock.hours[nextH12];
        string pattern = lookupPattern(_locale.clock, rounded);
        string result = strReplace(pattern, "{h}", hName);
        result = strReplace(result, "{next_h}", nextHName);
        return result;
    }

    /// Format time as digital clock display.
    private string formatDigital(int hour, int minute) {
        string fmt = _shortClock.format;
        if (_shortClock.use24h) {
            return strReplace(strReplace(fmt, "{h}", intToStr(hour)), "{mm}", zeroPad2(minute));
        }
        int h12 = hour % 12;
        if (h12 == 0) h12 = 12;
        string ampmStr;
        if (!_shortClock.amPm.isNull) {
            ampmStr = hour < 12 ? _shortClock.amPm.get.am : _shortClock.amPm.get.pm;
        } else {
            ampmStr = hour < 12 ? "AM" : "PM";
        }
        string result = strReplace(fmt, "{h}", intToStr(h12));
        result = strReplace(result, "{mm}", zeroPad2(minute));
        result = strReplace(result, "{ampm}", ampmStr);
        return result;
    }
}
