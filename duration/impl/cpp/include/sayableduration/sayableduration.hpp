#ifndef SAYABLEDURATION_SAYABLEDURATION_HPP
#define SAYABLEDURATION_SAYABLEDURATION_HPP

#include "types.hpp"

#include <optional>
#include <string>

namespace sayableduration {

/// SayableDuration is a locale-aware duration and relative time formatter.
class SayableDuration {
public:
    /// Construct with a locale and optional compactness level.
    explicit SayableDuration(const DurationLocale& locale,
                             Compactness compactness = Compactness::Normal);

    /// Format a duration in human-friendly terms from total seconds.
    /// Returns std::nullopt for null or negative input.
    std::optional<std::string> format_duration(int seconds) const;

    /// Format a duration between two ISO datetime strings.
    /// Returns std::nullopt if either string is empty or unparseable.
    std::optional<std::string> format_duration(const std::string& start,
                                               const std::string& end) const;

    /// Format elapsed time as "X ago" from an ISO start to an ISO as_of.
    /// Returns std::nullopt if start is empty, unparseable, or after as_of.
    std::optional<std::string> format_since(const std::string& start,
                                            const std::string& as_of) const;

    /// Format time until a future event as "in X".
    /// Returns std::nullopt if target is empty, unparseable, or before as_of.
    std::optional<std::string> format_until(const std::string& target,
                                            const std::string& as_of) const;

private:
    const DurationLocale* locale_;
    UnitForms second_;
    UnitForms minute_;
    UnitForms hour_;
    UnitForms day_;
    UnitForms week_;
    UnitForms month_;
    UnitForms year_;
    std::string half_;
    std::string delimiter_;
    std::string just_now_;
    std::string ago_;
    std::string in_future_;

    /// Internal: format total seconds into a human string.
    std::string format_seconds(int total) const;
};

// Free functions using the default English locale.

/// Format a duration in seconds using the default English locale.
std::optional<std::string> format_duration(int seconds);

/// Format a duration between ISO datetime strings using the default English locale.
std::optional<std::string> format_duration(const std::string& start,
                                           const std::string& end);

/// Format elapsed time using the default English locale.
std::optional<std::string> format_since(const std::string& start,
                                        const std::string& as_of);

/// Format time until event using the default English locale.
std::optional<std::string> format_until(const std::string& target,
                                        const std::string& as_of);

} // namespace sayableduration

#endif // SAYABLEDURATION_SAYABLEDURATION_HPP
