/// Human-friendly date formatting.
module sayabledate.format_date;

import std.typecons : Nullable;
import sayabledate.locale;

/// Library version.
enum VERSION = "0.5.0";

/// Parse a YYYY-MM-DD or ISO datetime date string into (year, month, day).
/// Returns false if the string is invalid.
private bool parseDateParts(string s, out int y, out int m, out int d) {
    if (s.length == 0) {
        return false;
    }
    // Strip time part if ISO datetime
    string datePart = s;
    foreach (i, c; s) {
        if (c == 'T') {
            datePart = s[0 .. i];
            break;
        }
    }
    if (datePart.length < 10 || datePart[4] != '-' || datePart[7] != '-') {
        return false;
    }
    y = atoiSlice(datePart[0 .. 4]);
    m = atoiSlice(datePart[5 .. 7]);
    d = atoiSlice(datePart[8 .. 10]);
    if (m < 1 || m > 12 || d < 1 || d > 31) {
        return false;
    }
    return true;
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

/// Check if a year is a leap year.
private bool isLeapYear(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

/// Convert a date to Julian Day Number for day-difference arithmetic.
private long toJDN(int y, int m, int d) {
    int a = (14 - m) / 12;
    int yy = y + 4800 - a;
    int mm = m + 12 * a - 3;
    return cast(long) d + (153 * mm + 2) / 5 + 365 * cast(long) yy
        + yy / 4 - yy / 100 + yy / 400 - 32045;
}

/// Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.
private int weekday(int y, int m, int d) {
    long jdn = toJDN(y, m, d);
    return cast(int)((jdn + 1) % 7);
}

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

/// Locale-aware date formatter.
struct SayableDate {
    private const(DateLocale)* _locale;
    private Compactness _compactness;
    private string[12] _months;
    private string[7] _weekdays;
    private string _dayFormat;
    private const(DayFormatException)[] _dayFormatExceptions;
    private bool _clearExceptions;
    private string _datePattern;
    private string _datePatternWithYear;
    private string _today;
    private string _tomorrow;
    private string _yesterday;
    private bool _hasMonthsInDate;
    private string[12] _monthsInDate;

    /// Create a new SayableDate instance with the given locale and optional compactness.
    this(ref const DateLocale loc, Compactness compactness = Compactness.normal) {
        _locale = &loc;
        _compactness = compactness;
        _months = loc.months;
        _weekdays = loc.weekdays;
        _dayFormat = loc.dayFormat;
        _dayFormatExceptions = loc.dayFormatExceptions;
        _clearExceptions = false;
        _datePattern = loc.datePattern;
        _datePatternWithYear = loc.datePatternWithYear;
        _today = loc.today;
        _tomorrow = loc.tomorrow;
        _yesterday = loc.yesterday;
        _hasMonthsInDate = loc.monthsInDate.isSet;
        if (loc.monthsInDate.isSet) {
            foreach (i; 0 .. 12) {
                if (i < loc.monthsInDate.values.length) {
                    _monthsInDate[i] = loc.monthsInDate.values[i];
                }
            }
        }

        const(DateCompactnessOverride)* ovr;
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

        if (ovr !is null && !isEmpty(*ovr)) {
            if (ovr.months.isSet) {
                foreach (i; 0 .. 12) {
                    if (i < ovr.months.values.length) {
                        _months[i] = ovr.months.values[i];
                    }
                }
            }
            if (ovr.weekdays.isSet) {
                foreach (i; 0 .. 7) {
                    if (i < ovr.weekdays.values.length) {
                        _weekdays[i] = ovr.weekdays.values[i];
                    }
                }
            }
            if (!ovr.dayFormat.isNull) {
                _dayFormat = ovr.dayFormat.get;
                // When short overrides dayFormat but not dayFormatExceptions, clear exceptions
                if (ovr.dayFormatExceptions.length == 0) {
                    _clearExceptions = true;
                }
            }
            if (ovr.dayFormatExceptions.length > 0) {
                _dayFormatExceptions = ovr.dayFormatExceptions;
            }
            if (!ovr.datePattern.isNull) {
                _datePattern = ovr.datePattern.get;
            }
            if (!ovr.datePatternWithYear.isNull) {
                _datePatternWithYear = ovr.datePatternWithYear.get;
            }
        }
    }

    /// Format a calendar date in locale-appropriate form (no year).
    Nullable!string formatDate(string date) {
        if (date.length == 0) {
            return Nullable!string.init;
        }
        int y, m, d;
        if (!parseDateParts(date, y, m, d)) {
            return Nullable!string.init;
        }
        return Nullable!string(formatAbsolute(y, m, d, false));
    }

    /// Format a calendar date with year in locale-appropriate form.
    Nullable!string formatDateWithYear(string date) {
        if (date.length == 0) {
            return Nullable!string.init;
        }
        int y, m, d;
        if (!parseDateParts(date, y, m, d)) {
            return Nullable!string.init;
        }
        return Nullable!string(formatAbsolute(y, m, d, true));
    }

    /// Format a date relative to asOf, picking the most natural reference.
    Nullable!string formatRelative(string date, string asOf) {
        if (date.length == 0 || asOf.length == 0) {
            return Nullable!string.init;
        }
        int dy, dm, dd;
        int ay, am, ad;
        if (!parseDateParts(date, dy, dm, dd)) {
            return Nullable!string.init;
        }
        if (!parseDateParts(asOf, ay, am, ad)) {
            return Nullable!string.init;
        }

        long dateJDN = toJDN(dy, dm, dd);
        long asofJDN = toJDN(ay, am, ad);
        long diff = dateJDN - asofJDN;

        // Today
        if (diff == 0) return Nullable!string(_today);
        // Tomorrow
        if (diff == 1) return Nullable!string(_tomorrow);
        // Yesterday
        if (diff == -1) return Nullable!string(_yesterday);

        bool isCompact = _compactness == Compactness.compact;

        // Day after tomorrow (optional)
        if (diff == 2 && !_locale.dayAfterTomorrow.isNull && !isCompact) {
            return Nullable!string(_locale.dayAfterTomorrow.get);
        }
        // Day before yesterday (optional)
        if (diff == -2 && !_locale.dayBeforeYesterday.isNull && !isCompact) {
            return Nullable!string(_locale.dayBeforeYesterday.get);
        }

        // Compact mode: skip weekday references, go straight to calendar date
        if (isCompact) {
            bool includeYear = dy != ay;
            return Nullable!string(formatAbsolute(dy, dm, dd, includeYear));
        }

        // This weekday (+2 to +6)
        if (diff >= 2 && diff <= 6 && !_locale.thisWeekday.isNull) {
            int dow = weekday(dy, dm, dd);
            string weekdayName = _weekdays[dow];
            return Nullable!string(strReplace(_locale.thisWeekday.get, "{weekday}", weekdayName));
        }

        // Last weekday (-2 to -6)
        if (diff >= -6 && diff <= -2 && !_locale.lastWeekday.isNull) {
            int dow = weekday(dy, dm, dd);
            string weekdayName = _weekdays[dow];
            return Nullable!string(strReplace(_locale.lastWeekday.get, "{weekday}", weekdayName));
        }

        // Next weekday (+7 to +13)
        if (diff >= 7 && diff <= 13 && !_locale.nextWeekday.isNull) {
            int dow = weekday(dy, dm, dd);
            string weekdayName = _weekdays[dow];
            return Nullable!string(strReplace(_locale.nextWeekday.get, "{weekday}", weekdayName));
        }

        // Calendar fallback
        bool includeYear = dy != ay;
        return Nullable!string(formatAbsolute(dy, dm, dd, includeYear));
    }

    /// Format a date as an absolute calendar reference.
    private string formatAbsolute(int year, int month, int day, bool includeYear) {
        // Format the day with ordinal
        string dayStr = intToStr(day);
        string fmt;
        if (_clearExceptions) {
            fmt = _dayFormat;
        } else {
            fmt = lookupDayFormat(_dayFormatExceptions, day, _dayFormat);
        }
        string formattedDay = strReplace(fmt, "{n}", dayStr);

        // Pick month name (genitive form if available)
        string monthName;
        if (_hasMonthsInDate && month >= 1 && month <= 12) {
            monthName = _monthsInDate[month - 1];
        } else if (month >= 1 && month <= 12) {
            monthName = _months[month - 1];
        } else {
            monthName = "";
        }

        string pattern = includeYear ? _datePatternWithYear : _datePattern;
        string result = strReplace(pattern, "{month}", monthName);
        result = strReplace(result, "{day}", formattedDay);
        result = strReplace(result, "{d}", intToStr(day));
        result = strReplace(result, "{m}", intToStr(month));
        if (includeYear) {
            result = strReplace(result, "{year}", intToStr(year));
            result = strReplace(result, "{yy}", zeroPad2(year % 100));
        }

        return result;
    }
}
