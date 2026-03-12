/// Types for sayable-time locale data.
module sayabletime.locale;

import std.typecons : Nullable;

/// Compactness display mode.
enum Compactness {
    normal,
    short_,
    compact,
}

/// AM/PM labels pair.
struct AmPm {
    string am;
    string pm;
}

/// Create a Nullable!AmPm from an AmPm value.
Nullable!AmPm nullable(AmPm a) {
    return Nullable!AmPm(a);
}

/// Pattern entry mapping a rounded minute to its template string.
struct PatternEntry {
    int minute;
    string pattern;
}

/// Natural language clock reading configuration.
struct ClockConfig {
    string[12] hours;
    string midnight;
    string noon;
    PatternEntry[] patterns;
}

/// Look up pattern for a given rounded minute value.
string lookupPattern(ref const ClockConfig clock, int rounded) {
    foreach (ref p; clock.patterns) {
        if (p.minute == rounded) {
            return p.pattern;
        }
    }
    // Fallback to pattern for 0
    foreach (ref p; clock.patterns) {
        if (p.minute == 0) {
            return p.pattern;
        }
    }
    return "{h}";
}

/// Digital clock display configuration for short/compact modes.
struct ShortClockConfig {
    bool use24h;
    string format;
    Nullable!AmPm amPm;
    bool isSet;
}

/// Create a ShortClockConfig.
ShortClockConfig shortClockConfig(bool use24h, string fmt) {
    ShortClockConfig sc;
    sc.use24h = use24h;
    sc.format = fmt;
    sc.isSet = true;
    return sc;
}

/// Optional overrides for short/compact display modes.
struct TimeCompactnessOverride {
    ShortClockConfig clock;
}

/// Locale-specific data for time formatting.
struct TimeLocale {
    string code;
    ClockConfig clock;
    TimeCompactnessOverride short_;
    TimeCompactnessOverride compact_;
}
