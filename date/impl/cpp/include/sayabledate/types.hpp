#ifndef SAYABLEDATE_TYPES_HPP
#define SAYABLEDATE_TYPES_HPP

#include <map>
#include <optional>
#include <string>
#include <vector>

namespace sayabledate {

constexpr const char* VERSION = "0.5.0";

/// Compactness controls the verbosity of formatted output.
enum class Compactness { Normal, Short, Compact };

/// CompactnessOverride holds optional overrides for short/compact display modes.
/// Empty strings and empty vectors mean "no override" (use the base locale value).
struct CompactnessOverride {
    std::vector<std::string> months;           // empty = no override
    std::vector<std::string> months_in_date;   // empty = no override
    std::vector<std::string> weekdays;         // empty = no override
    std::string day_format;                     // empty = no override
    std::map<std::string, std::string> day_format_exceptions;  // empty map = cleared if day_format set
    bool day_format_exceptions_set;             // true if explicitly set (even if empty)
    std::string date_pattern;                   // empty = no override
    std::string date_pattern_with_year;         // empty = no override
    std::string today;                          // empty = no override
    std::string tomorrow;                       // empty = no override
    std::string yesterday;                      // empty = no override
};

/// DateLocale defines all locale-specific data for date formatting.
struct DateLocale {
    std::string code;
    std::string months[12];
    std::string weekdays[7];                    // 0=Sunday, 1=Monday, ..., 6=Saturday
    std::string day_format;
    std::map<std::string, std::string> day_format_exceptions;
    std::string date_pattern;
    std::string date_pattern_with_year;
    std::string today;
    std::string tomorrow;
    std::string yesterday;
    std::string day_after_tomorrow;             // empty = not available
    std::string day_before_yesterday;           // empty = not available
    std::string this_weekday;                   // empty = not available (template with {weekday})
    std::string next_weekday;                   // empty = not available
    std::string last_weekday;                   // empty = not available
    std::string months_in_date[12];             // all empty = use months
    std::optional<CompactnessOverride> short_override;
    std::optional<CompactnessOverride> compact_override;
};

} // namespace sayabledate

#endif // SAYABLEDATE_TYPES_HPP
