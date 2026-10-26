/// Human-friendly age formatting.
module sayableage.format_age;

import std.typecons : Nullable;
import sayableage.locale;

/// Library version.
enum VERSION = "0.5.0";

/// Maximum supported age in months (500 years).
private enum MAX_AGE_MONTHS = 6000;

/// Parsed age components.
private struct AgeComponents {
    int months;
    int diffDays;
}

/// Parse exactly YYYY-MM-DD naming a real calendar day into (year, month, day)
/// (docs/input-formats.md). Returns false for anything else.
private bool parseDateParts(string s, out int y, out int m, out int d) {
    if (s.length != 10 || s[4] != '-' || s[7] != '-') {
        return false;
    }
    if (!parseDigits(s[0 .. 4], y) || !parseDigits(s[5 .. 7], m) || !parseDigits(s[8 .. 10], d)) {
        return false;
    }
    return m >= 1 && m <= 12 && d >= 1 && d <= daysInMonth(y, m);
}

/// Convert a run of ASCII digits to int. Returns false if any isn't a digit.
private bool parseDigits(string s, out int n) {
    n = 0;
    foreach (c; s) {
        if (c < '0' || c > '9') {
            return false;
        }
        n = n * 10 + (c - '0');
    }
    return true;
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

/// Julian Day Number of a Gregorian date, for diffing.
/// See https://en.wikipedia.org/wiki/Julian_day#Converting_Gregorian_calendar_date_to_JDN
private long serialDay(int year, int month, int day) {
    immutable long a = (14 - month) / 12;
    immutable long y = year + 4800 - a;
    immutable long m = month + 12 * a - 3;
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

/// Parse age from date of birth and optional reference date.
private Nullable!AgeComponents parseAge(string dateOfBirth, string asOf = "") {
    if (dateOfBirth.length == 0) {
        return Nullable!AgeComponents.init;
    }

    int dobY, dobM, dobD;
    if (!parseDateParts(dateOfBirth, dobY, dobM, dobD)) {
        return Nullable!AgeComponents.init;
    }

    int refY, refM, refD;
    if (asOf.length > 0) {
        if (!parseDateParts(asOf, refY, refM, refD)) {
            return Nullable!AgeComponents.init;
        }
    } else {
        import std.datetime.systime : Clock;
        auto now = Clock.currTime();
        refY = now.year;
        refM = now.month;
        refD = now.day;
    }

    long diffDays = serialDay(refY, refM, refD) - serialDay(dobY, dobM, dobD);
    if (diffDays < 0) {
        return Nullable!AgeComponents.init;
    }

    // Calendar months with birthday clamping.
    int lastDay = daysInMonth(refY, refM);
    int clampedBirthday = dobD;
    if (clampedBirthday > lastDay) {
        clampedBirthday = lastDay;
    }
    int months = (refY - dobY) * 12 + (refM - dobM);
    if (refD < clampedBirthday) {
        months--;
    }
    if (months > MAX_AGE_MONTHS) {
        return Nullable!AgeComponents.init;
    }

    return Nullable!AgeComponents(AgeComponents(months, cast(int) diffDays));
}

/// Return the developmental stage key for the given calendar months.
private string stageKey(int months) {
    if (months < 2) return "newborn";
    if (months < 12) return "infant";
    if (months < 36) return "toddler";
    if (months < 156) return "child";
    if (months < 216) return "teenager";
    return "adult";
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
private string resolveUnit(int count, ref const UnitForms uf, const(AgeLocale)* loc, string half) {
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
        auto cat = loc.plural(count);
        tmpl = lookupForm(uf, cat);
    }

    string result = strReplace(tmpl, "{n}", n);

    // Apply {0}-style half marker (wraps the whole expression).
    if (half.length > 0 && strContains(half, "{0}")) {
        result = strReplace(half, "{0}", result);
    }

    return result;
}

/// Locale-aware age formatter.
struct SayableAge {
    private const(AgeLocale)* _locale;
    private UnitForms _day;
    private UnitForms _week;
    private UnitForms _month;
    private UnitForms _year;
    private string _half;
    private string _delimiter;
    private string _justBorn;

    /// Create a new SayableAge instance with the given locale and optional compactness.
    this(ref const AgeLocale locale, Compactness compactness = Compactness.normal) {
        _locale = &locale;
        _day = locale.day;
        _week = locale.week;
        _month = locale.month;
        _year = locale.year;
        _half = locale.half;
        _delimiter = locale.delimiter;
        _justBorn = locale.justBorn;

        const(CompactnessOverride)* ovr;
        final switch (compactness) {
            case Compactness.normal:
                ovr = null;
                break;
            case Compactness.short_:
                ovr = &locale.short_;
                break;
            case Compactness.compact:
                ovr = &locale.compact_;
                break;
        }

        if (ovr !is null) {
            if (!isEmptyUnit(ovr.day)) _day = ovr.day;
            if (!isEmptyUnit(ovr.week)) _week = ovr.week;
            if (!isEmptyUnit(ovr.month)) _month = ovr.month;
            if (!isEmptyUnit(ovr.year)) _year = ovr.year;
            if (!ovr.half.isNull) _half = ovr.half.get;
            if (!ovr.delimiter.isNull) _delimiter = ovr.delimiter.get;
            if (!ovr.justBorn.isNull) _justBorn = ovr.justBorn.get;
        }
    }

    /// Format an age as a human-friendly string.
    /// Returns null if dateOfBirth is empty or in the future.
    Nullable!string formatAge(string dateOfBirth, string asOf = "") {
        auto age = parseAge(dateOfBirth, asOf);
        if (age.isNull) {
            return Nullable!string.init;
        }

        int months = age.get.months;
        int diffDays = age.get.diffDays;

        // Tier 1: 0 days.
        if (diffDays == 0) {
            return Nullable!string(_justBorn);
        }

        // Tier 1b: 1-6 days.
        if (diffDays < 7) {
            return Nullable!string(resolveUnit(diffDays, _day, _locale, ""));
        }

        // Tier 2: weeks + days until 3 calendar months.
        if (months < 3) {
            int weeks = diffDays / 7;
            int days = diffDays % 7;
            string result = resolveUnit(weeks, _week, _locale, "");
            if (days > 0) {
                result = result ~ _delimiter ~ resolveUnit(days, _day, _locale, "");
            }
            return Nullable!string(result);
        }

        // Tier 3: 3-23 months.
        if (months < 24) {
            return Nullable!string(resolveUnit(months, _month, _locale, ""));
        }

        // Tier 4: 24-35 months -> years + months.
        if (months < 36) {
            int years = months / 12;
            int rem = months % 12;
            if (rem == 0) {
                return Nullable!string(resolveUnit(years, _year, _locale, ""));
            }
            string s = resolveUnit(years, _year, _locale, "") ~ _delimiter ~
                resolveUnit(rem, _month, _locale, "");
            return Nullable!string(s);
        }

        // Tier 5: 3-6 years -> years with half marker.
        if (months < 84) {
            int years = months / 12;
            int rem = months % 12;
            if (rem >= 6) {
                return Nullable!string(resolveUnit(years, _year, _locale, _half));
            }
            return Nullable!string(resolveUnit(years, _year, _locale, ""));
        }

        // Tier 6: 7+ years.
        int years = months / 12;
        return Nullable!string(resolveUnit(years, _year, _locale, ""));
    }

    /// Format the developmental stage label based on age.
    /// Returns null if dateOfBirth is empty or in the future.
    Nullable!string formatStage(string dateOfBirth, string asOf = "", string gender = "") {
        auto age = parseAge(dateOfBirth, asOf);
        if (age.isNull) {
            return Nullable!string.init;
        }
        string key = stageKey(age.get.months);
        StageLabel sl;
        switch (key) {
            case "newborn": sl = _locale.newborn; break;
            case "infant": sl = _locale.infant; break;
            case "toddler": sl = _locale.toddler; break;
            case "child": sl = _locale.child; break;
            case "teenager": sl = _locale.teenager; break;
            case "adult": sl = _locale.adult; break;
            default: break;
        }
        return Nullable!string(resolveStage(sl, gender));
    }
}
