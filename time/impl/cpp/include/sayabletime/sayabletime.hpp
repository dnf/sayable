#ifndef SAYABLETIME_SAYABLETIME_HPP
#define SAYABLETIME_SAYABLETIME_HPP

#include "types.hpp"

#include <optional>
#include <string>

namespace sayabletime {

/// SayableTime is a locale-aware clock time formatter.
class SayableTime {
public:
    /// Construct with a locale and optional compactness level.
    explicit SayableTime(const TimeLocale& locale,
                         Compactness compactness = Compactness::Normal);

    /// Format a time as natural language clock reading.
    /// input must be "HH:MM" or ISO datetime string.
    /// Returns std::nullopt if input is empty or invalid.
    std::optional<std::string> format_time(const std::string& input) const;

private:
    const TimeLocale* locale_;
    Compactness compactness_;
    const CompactnessOverride* override_;

    std::string format_natural(int hour, int minute) const;
    std::string format_digital(int hour, int minute) const;
};

// Free function using the default English locale (normal compactness).

/// Format clock time using the default English locale.
std::optional<std::string> format_time(const std::string& input);

} // namespace sayabletime

#endif // SAYABLETIME_SAYABLETIME_HPP
