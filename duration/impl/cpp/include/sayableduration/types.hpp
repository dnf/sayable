#ifndef SAYABLEDURATION_TYPES_HPP
#define SAYABLEDURATION_TYPES_HPP

#include <functional>
#include <map>
#include <optional>
#include <string>

namespace sayableduration {

constexpr const char* VERSION = "0.5.0";

/// CLDR-inspired plural categories.
enum class PluralCategory { Zero, One, Two, Few, Many, Other };

/// Compactness controls the verbosity of formatted output.
enum class Compactness { Normal, Short, Compact };

/// UnitForms holds a unit's display template(s).
/// Use Simple for languages with no plural forms, Plural for plural-aware.
struct UnitForms {
    std::string simple;
    std::map<PluralCategory, std::string> forms;

    /// Create a UnitForms with a single template for all counts.
    static UnitForms Simple(const std::string& s) {
        UnitForms uf;
        uf.simple = s;
        return uf;
    }

    /// Create a UnitForms with per-category templates.
    static UnitForms Plural(std::map<PluralCategory, std::string> f) {
        UnitForms uf;
        uf.forms = std::move(f);
        return uf;
    }
};

/// Unit set (second, minute, hour, day, week, month, year).
struct UnitSet {
    UnitForms second;
    UnitForms minute;
    UnitForms hour;
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
};

/// CompactnessOverride holds optional overrides for short/compact display modes.
/// std::nullopt means "use the base locale value."
struct CompactnessOverride {
    std::optional<UnitForms> second;
    std::optional<UnitForms> minute;
    std::optional<UnitForms> hour;
    std::optional<UnitForms> day;
    std::optional<UnitForms> week;
    std::optional<UnitForms> month;
    std::optional<UnitForms> year;
    std::optional<std::string> half;
    std::optional<std::string> delimiter;
    std::optional<std::string> ago;
    std::optional<std::string> in_future;
};

/// DurationLocale defines all locale-specific data for duration formatting.
struct DurationLocale {
    std::string code;
    std::function<PluralCategory(int)> plural;
    UnitSet units;
    std::string just_now;
    std::string half;
    std::string delimiter;
    std::string ago;
    std::string in_future;
    std::optional<CompactnessOverride> short_override;
    std::optional<CompactnessOverride> compact_override;
    std::function<std::string(int)> format_number;
    std::function<std::string(int, const std::string&)> format_unit;
};

} // namespace sayableduration

#endif // SAYABLEDURATION_TYPES_HPP
