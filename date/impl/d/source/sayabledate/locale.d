/// Types for sayable-date locale data.
module sayabledate.locale;

import std.typecons : Nullable;

/// Compactness display mode.
enum Compactness {
    normal,
    short_,
    compact,
}

/// Day format exception entry (maps a day number to its format string).
struct DayFormatException {
    int day;
    string format;
}

/// Create a Nullable!string from a string value.
Nullable!string nullable(string s) {
    return Nullable!string(s);
}

/// Nullable string array wrapper.
struct NullableStringArray {
    string[] values;
    bool isSet;

    this(string[] v) {
        values = v;
        isSet = true;
    }
}

/// Optional overrides for short/compact display modes.
struct DateCompactnessOverride {
    NullableStringArray months;
    NullableStringArray weekdays;
    Nullable!string dayFormat;
    DayFormatException[] dayFormatExceptions;
    Nullable!string datePattern;
    Nullable!string datePatternWithYear;
}

/// Check if a DateCompactnessOverride has any values set.
bool isEmpty(ref const DateCompactnessOverride ovr) {
    return !ovr.months.isSet && !ovr.weekdays.isSet && ovr.dayFormat.isNull
        && ovr.dayFormatExceptions.length == 0 && ovr.datePattern.isNull
        && ovr.datePatternWithYear.isNull;
}

/// Locale-specific data for date formatting.
struct DateLocale {
    string code;
    string[12] months;
    string[7] weekdays;
    string dayFormat;
    DayFormatException[] dayFormatExceptions;
    string datePattern;
    string datePatternWithYear;
    string today;
    string tomorrow;
    string yesterday;
    Nullable!string dayAfterTomorrow;
    Nullable!string dayBeforeYesterday;
    Nullable!string thisWeekday;
    Nullable!string nextWeekday;
    Nullable!string lastWeekday;
    NullableStringArray monthsInDate;
    DateCompactnessOverride short_;
    DateCompactnessOverride compact_;
}

/// Look up day format exception for a given day number.
string lookupDayFormat(const DayFormatException[] exceptions, int day, string defaultFormat) {
    foreach (ref exc; exceptions) {
        if (exc.day == day) {
            return exc.format;
        }
    }
    return defaultFormat;
}
