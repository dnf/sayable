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

/// Parse HH:MM or ISO datetime to (hour, minute). Returns false on failure.
private bool parseTime(string s, out int hour, out int minute) {
    if (s.length == 0) {
        return false;
    }

    string t = s;
    // Strip date part if ISO datetime
    foreach (i, c; s) {
        if (c == 'T') {
            t = s[i + 1 .. $];
            break;
        }
    }
    // Strip timezone
    foreach (i, c; t) {
        if (c == '+' || c == 'Z') {
            t = t[0 .. i];
            break;
        }
    }

    // Find the colon
    int colonPos = -1;
    foreach (i, c; t) {
        if (c == ':') {
            colonPos = cast(int) i;
            break;
        }
    }
    if (colonPos < 1) return false;

    hour = atoiSlice(t[0 .. colonPos]);
    if (hour < 0) return false;

    // Get minute part (strip fractional seconds)
    string minPart = t[colonPos + 1 .. $];
    if (minPart.length < 2) return false;
    // Only take first 2 chars
    minPart = minPart[0 .. 2];
    minute = atoiSlice(minPart);
    if (minute < 0) return false;

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return false;
    }
    return true;
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
