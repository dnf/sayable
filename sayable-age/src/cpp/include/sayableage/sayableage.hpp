#ifndef SAYABLEAGE_SAYABLEAGE_HPP
#define SAYABLEAGE_SAYABLEAGE_HPP

#include "types.hpp"

#include <optional>
#include <string>

namespace sayableage {

/// SayableAge is a locale-aware age formatter.
class SayableAge {
public:
    /// Construct with a locale and optional compactness level.
    explicit SayableAge(const AgeLocale& locale,
                        Compactness compactness = Compactness::Normal);

    /// Format a human-friendly age string.
    /// dateOfBirth and asOf must be "YYYY-MM-DD".
    /// Returns std::nullopt if dateOfBirth is empty or in the future.
    std::optional<std::string> format_age(const std::string& date_of_birth,
                                          const std::string& as_of = "") const;

    /// Return the developmental stage label based on age.
    /// Returns std::nullopt if dateOfBirth is empty or in the future.
    /// gender: "f" for feminine forms (where available), "" for default.
    std::optional<std::string> format_stage(const std::string& date_of_birth,
                                            const std::string& as_of = "",
                                            const std::string& gender = "") const;

private:
    const AgeLocale* locale_;
    UnitForms day_;
    UnitForms week_;
    UnitForms month_;
    UnitForms year_;
    std::string half_;
    std::string delimiter_;
    std::string just_born_;
};

// Free functions using the default English locale.

/// Format an age using the default English locale (normal compactness).
std::optional<std::string> format_age(const std::string& date_of_birth,
                                      const std::string& as_of = "");

/// Return the developmental stage using the default English locale.
std::optional<std::string> format_stage(const std::string& date_of_birth,
                                        const std::string& as_of = "",
                                        const std::string& gender = "");

} // namespace sayableage

#endif // SAYABLEAGE_SAYABLEAGE_HPP
