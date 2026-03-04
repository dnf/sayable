#ifndef SAYABLEDATE_SAYABLEDATE_HPP
#define SAYABLEDATE_SAYABLEDATE_HPP

#include "types.hpp"

#include <map>
#include <optional>
#include <string>

namespace sayabledate {

/// SayableDate is a locale-aware date formatter.
class SayableDate {
public:
    /// Construct with a locale and optional compactness level.
    explicit SayableDate(const DateLocale& locale,
                         Compactness compactness = Compactness::Normal);

    /// Format a calendar date in locale-appropriate form (no year).
    /// date must be "YYYY-MM-DD" or ISO datetime.
    /// Returns std::nullopt if date is empty or unparseable.
    std::optional<std::string> format_date(const std::string& date) const;

    /// Format a calendar date with year in locale-appropriate form.
    std::optional<std::string> format_date_with_year(const std::string& date) const;

    /// Format a date relative to as_of, picking the most natural reference.
    /// Falls back to absolute date for distant dates.
    std::optional<std::string> format_relative(const std::string& date,
                                               const std::string& as_of) const;

private:
    const DateLocale* locale_;
    Compactness compactness_;
    // Resolved values (with overrides applied)
    const std::string* months_;           // pointer to 12-element array
    const std::string* months_in_date_;   // pointer to 12-element array (or nullptr)
    const std::string* weekdays_;         // pointer to 7-element array
    std::string day_format_;
    const std::map<std::string, std::string>* day_format_exceptions_;
    std::string date_pattern_;
    std::string date_pattern_with_year_;
    std::string today_;
    std::string tomorrow_;
    std::string yesterday_;
    // Storage for overridden arrays
    std::string months_buf_[12];
    std::string months_in_date_buf_[12];
    std::string weekdays_buf_[7];
    std::map<std::string, std::string> day_format_exceptions_buf_;

    std::string format_absolute(int year, int month, int day,
                                bool include_year) const;
};

// Free functions using the default English locale.

/// Format a date using the default English locale (normal compactness).
std::optional<std::string> format_date(const std::string& date);

/// Format a relative date using the default English locale.
std::optional<std::string> format_relative(const std::string& date,
                                           const std::string& as_of);

} // namespace sayabledate

#endif // SAYABLEDATE_SAYABLEDATE_HPP
