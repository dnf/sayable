/// Types for sayable-age locale data.
module sayableage.locale;

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

/// Create a UnitForms with per-category templates using variadic pairs.
UnitForms pluralUnit(PluralCategory cat0, string val0) {
    UnitForms uf;
    uf.hasPlural = true;
    uf.forms[cat0] = val0;
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

/// Stage label: either gender-neutral or gendered (masculine/feminine).
struct StageLabel {
    string label;
    string m;
    string f;
}

/// Create a gender-neutral stage label.
StageLabel stageNeutral(string s) {
    return StageLabel(s, "", "");
}

/// Create a gendered stage label with masculine and feminine forms.
StageLabel stageGendered(string gm, string gf) {
    return StageLabel("", gm, gf);
}

/// Resolve the appropriate string for the given gender.
string resolveStage(StageLabel sl, string gender) {
    if (sl.m.length == 0) {
        return sl.label;
    }
    if (gender == "f") {
        return sl.f;
    }
    return sl.m;
}

/// Compactness display mode.
enum Compactness {
    normal,
    short_,
    compact,
}

/// Optional overrides for short/compact display modes.
struct CompactnessOverride {
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
    Nullable!string half;
    Nullable!string delimiter;
    Nullable!string justBorn;
}

/// Create a Nullable!string from a string value.
Nullable!string nullable(string s) {
    return Nullable!string(s);
}

/// Check if a UnitForms is empty (unset).
bool isEmptyUnit(ref const UnitForms uf) {
    return uf.simple.length == 0 && !uf.hasPlural;
}

/// Locale-specific data for age formatting.
struct AgeLocale {
    string code;
    PluralCategory function(int) plural;
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
    string half;
    string delimiter;
    string justBorn;
    StageLabel newborn;
    StageLabel infant;
    StageLabel toddler;
    StageLabel child;
    StageLabel teenager;
    StageLabel adult;
    CompactnessOverride short_;
    CompactnessOverride compact_;
}
