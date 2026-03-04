#ifndef PARENTTIME_TYPES_HPP
#define PARENTTIME_TYPES_HPP

#include <functional>
#include <map>
#include <optional>
#include <string>

namespace parenttime {

constexpr const char* VERSION = "0.5.0";

/// CLDR-inspired plural categories.
enum class PluralCategory { Zero, One, Two, Few, Many, Other };

/// Compactness controls the verbosity of formatted output.
enum class Compactness { Normal, Short, Compact };

/// UnitForms holds a unit's display template(s).
/// Use Simple for languages with no plural forms, Forms for plural-aware.
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

/// A stage label with optional feminine form.
struct StageLabel {
    std::string label;   // neutral or masculine form
    std::string f;       // feminine form (empty = use label)

    /// Resolve to a string given an optional gender.
    const std::string& resolve(const std::string& gender = "") const {
        if (!f.empty() && gender == "f") return f;
        return label;
    }
};

/// Stage labels for developmental stages.
struct StageLabels {
    StageLabel newborn;
    StageLabel infant;
    StageLabel toddler;
    StageLabel child;
    StageLabel teenager;
    StageLabel adult;
};

/// Unit set (day, week, month, year).
struct UnitSet {
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
};

/// CompactnessOverride holds optional overrides for short/compact display modes.
/// std::nullopt means "use the base locale value."
struct CompactnessOverride {
    std::optional<UnitForms> day;
    std::optional<UnitForms> week;
    std::optional<UnitForms> month;
    std::optional<UnitForms> year;
    std::optional<std::string> half;
    std::optional<std::string> delimiter;
    std::optional<std::string> just_born;
};

/// AgeLocale defines all locale-specific data for age formatting.
struct AgeLocale {
    std::string code;
    std::function<PluralCategory(int)> plural;
    UnitSet units;
    std::string half;
    std::string delimiter;
    std::string just_born;
    StageLabels stages;
    std::optional<CompactnessOverride> short_override;
    std::optional<CompactnessOverride> compact_override;
    std::function<std::string(int)> format_number;
    std::function<std::string(int, const std::string&)> format_unit;
};

} // namespace parenttime

#endif // PARENTTIME_TYPES_HPP
