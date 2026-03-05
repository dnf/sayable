#ifndef SAYABLETIME_TYPES_HPP
#define SAYABLETIME_TYPES_HPP

#include <map>
#include <optional>
#include <string>

namespace sayabletime {

constexpr const char* VERSION = "0.5.0";

enum class Compactness { Normal, Short, Compact };

struct ClockConfig {
    std::string hours[12];
    std::string midnight;
    std::string noon;
    std::map<int, std::string> patterns;
};

struct ShortClockConfig {
    bool use24h;
    std::string format;
    std::string am_pm[2];  // empty strings if not applicable
};

struct CompactnessOverride {
    ShortClockConfig clock;
};

struct TimeLocale {
    std::string code;
    ClockConfig clock;
    std::optional<CompactnessOverride> short_override;
    std::optional<CompactnessOverride> compact_override;
};

} // namespace sayabletime

#endif // SAYABLETIME_TYPES_HPP
