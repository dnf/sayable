/// Types for sayable-duration locale data.
module sayableduration.locale;

import std.typecons : Nullable;

/// CLDR plural categories.
enum PluralCategory {
    zero,
    one,
    two,
    few,
    many,
    other,
}

/// Number of plural categories.
enum NUM_CATEGORIES = 6;

/// Unit display template(s).
/// Uses a fixed array indexed by PluralCategory for compile-time compatibility.
struct UnitForms {
    /// Simple form (single template for all counts).
    string simple;
    /// Plural-aware forms indexed by PluralCategory.
    string[NUM_CATEGORIES] forms;
    /// Whether this has plural forms.
    bool hasPlural;
}

/// Create a UnitForms with a single template for all counts.
UnitForms simpleUnit(string s) {
    UnitForms uf;
    uf.simple = s;
    return uf;
}

/// Create a UnitForms from individual category strings.
/// Empty strings mean "not set" (will fall back to other).
UnitForms makePluralUnit(
    string zero = "",
    string one = "",
    string two = "",
    string few = "",
    string many = "",
    string other = "",
) {
    UnitForms uf;
    uf.hasPlural = true;
    uf.forms[PluralCategory.zero] = zero;
    uf.forms[PluralCategory.one] = one;
    uf.forms[PluralCategory.two] = two;
    uf.forms[PluralCategory.few] = few;
    uf.forms[PluralCategory.many] = many;
    uf.forms[PluralCategory.other] = other;
    return uf;
}

/// Look up the form for a given category, falling back to "other".
string lookupForm(ref const UnitForms uf, PluralCategory cat) {
    string result = uf.forms[cat];
    if (result.length > 0) {
        return result;
    }
    return uf.forms[PluralCategory.other];
}

/// Compactness display mode.
enum Compactness {
    normal,
    short_,
    compact,
}

/// Create a Nullable!string from a string value.
Nullable!string nullable(string s) {
    return Nullable!string(s);
}

/// Check if a UnitForms is empty (unset).
bool isEmptyUnit(ref const UnitForms uf) {
    return uf.simple.length == 0 && !uf.hasPlural;
}

/// Optional overrides for short/compact display modes.
struct DurationCompactnessOverride {
    UnitForms second;
    UnitForms minute;
    UnitForms hour;
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
    Nullable!string half;
    Nullable!string delimiter;
    Nullable!string ago;
    Nullable!string inFuture;
}

/// Locale-specific data for duration formatting.
struct DurationLocale {
    string code;
    PluralCategory function(int) plural;
    UnitForms second;
    UnitForms minute;
    UnitForms hour;
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
    string half;
    string delimiter;
    string justNow;
    string ago;
    string inFuture;
    DurationCompactnessOverride short_;
    DurationCompactnessOverride compact_;
}
