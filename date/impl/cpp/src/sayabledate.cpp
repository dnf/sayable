#include "sayabledate/sayabledate.hpp"
#include "sayabledate/locales/locales.hpp"

#include <string>

namespace sayabledate {

// ---------- internal helpers ----------

namespace {

/// Days in a Gregorian month (leap years by the 4/100/400 rule).
int days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

/// Parse "YYYY-MM-DD", optionally followed by "T" and anything else, to
/// (year, month, day). The date must name a real calendar day
/// (docs/input-formats.md). Returns false on failure.
bool parse_date(const std::string& s, int& y, int& m, int& d) {
    if (s.empty()) return false;

    // Strip time component if present (ISO datetime)
    std::string date_part = s;
    const auto t_pos = s.find('T');
    if (t_pos != std::string::npos) {
        date_part = s.substr(0, t_pos);
    }

    if (date_part.size() != 10 || date_part[4] != '-' || date_part[7] != '-') {
        return false;
    }

    y = 0;
    for (int i = 0; i < 4; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return false;
        y = y * 10 + (c - '0');
    }
    m = 0;
    for (int i = 5; i < 7; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return false;
        m = m * 10 + (c - '0');
    }
    d = 0;
    for (int i = 8; i < 10; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return false;
        d = d * 10 + (c - '0');
    }

    return m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m);
}

/// Julian Day Number for date arithmetic.
int to_jdn(int year, int month, int day) {
    const int a = (14 - month) / 12;
    const int y = year + 4800 - a;
    const int m = month + 12 * a - 3;
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

/// Day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.
int weekday(int year, int month, int day) {
    return (to_jdn(year, month, day) + 1) % 7;
}

/// Replace all occurrences of `from` in `str` with `to`.
std::string replace_all(const std::string& str, const std::string& from,
                        const std::string& to) {
    if (from.empty()) return str;
    std::string result;
    size_t pos = 0;
    size_t prev = 0;
    while ((pos = str.find(from, prev)) != std::string::npos) {
        result.append(str, prev, pos - prev);
        result.append(to);
        prev = pos + from.size();
    }
    result.append(str, prev, str.size() - prev);
    return result;
}

/// Check if months_in_date array has any non-empty entries.
bool has_months_in_date(const std::string* arr) {
    for (int i = 0; i < 12; ++i) {
        if (!arr[i].empty()) return true;
    }
    return false;
}

/// Copy a vector into a fixed-size string array.
void copy_vector_to_array(std::string* dst, const std::vector<std::string>& src, int count) {
    for (int i = 0; i < count && i < static_cast<int>(src.size()); ++i) {
        dst[i] = src[static_cast<size_t>(i)];
    }
}

} // anonymous namespace

// ---------- SayableDate ----------

SayableDate::SayableDate(const DateLocale& locale, Compactness compactness)
    : locale_(&locale),
      compactness_(compactness),
      months_(locale.months),
      months_in_date_(nullptr),
      weekdays_(locale.weekdays),
      day_format_(locale.day_format),
      day_format_exceptions_(&locale.day_format_exceptions),
      date_pattern_(locale.date_pattern),
      date_pattern_with_year_(locale.date_pattern_with_year),
      today_(locale.today),
      tomorrow_(locale.tomorrow),
      yesterday_(locale.yesterday) {

    // Set up months_in_date
    if (has_months_in_date(locale.months_in_date)) {
        months_in_date_ = locale.months_in_date;
    }

    const CompactnessOverride* ovr = nullptr;
    if (compactness == Compactness::Short && locale.short_override.has_value()) {
        ovr = &locale.short_override.value();
    } else if (compactness == Compactness::Compact && locale.compact_override.has_value()) {
        ovr = &locale.compact_override.value();
    }

    if (ovr != nullptr) {
        // months override
        if (!ovr->months.empty()) {
            copy_vector_to_array(months_buf_, ovr->months, 12);
            months_ = months_buf_;
        }

        // months_in_date override
        if (!ovr->months_in_date.empty()) {
            copy_vector_to_array(months_in_date_buf_, ovr->months_in_date, 12);
            months_in_date_ = months_in_date_buf_;
        }

        // weekdays override
        if (!ovr->weekdays.empty()) {
            copy_vector_to_array(weekdays_buf_, ovr->weekdays, 7);
            weekdays_ = weekdays_buf_;
        }

        // day_format override
        if (!ovr->day_format.empty()) {
            day_format_ = ovr->day_format;
            // When day_format is overridden but exceptions are not explicitly set,
            // clear the exceptions (they no longer apply to the new format)
            if (!ovr->day_format_exceptions_set) {
                day_format_exceptions_buf_.clear();
                day_format_exceptions_ = &day_format_exceptions_buf_;
            }
        }

        // day_format_exceptions override (explicitly set, even if empty)
        if (ovr->day_format_exceptions_set) {
            day_format_exceptions_buf_ = ovr->day_format_exceptions;
            day_format_exceptions_ = &day_format_exceptions_buf_;
        }

        // date_pattern override
        if (!ovr->date_pattern.empty()) {
            date_pattern_ = ovr->date_pattern;
        }

        // date_pattern_with_year override
        if (!ovr->date_pattern_with_year.empty()) {
            date_pattern_with_year_ = ovr->date_pattern_with_year;
        }

        // today/tomorrow/yesterday overrides
        if (!ovr->today.empty()) today_ = ovr->today;
        if (!ovr->tomorrow.empty()) tomorrow_ = ovr->tomorrow;
        if (!ovr->yesterday.empty()) yesterday_ = ovr->yesterday;
    }
}

std::optional<std::string> SayableDate::format_date(const std::string& date) const {
    if (date.empty()) return std::nullopt;
    int y = 0, m = 0, d = 0;
    if (!parse_date(date, y, m, d)) return std::nullopt;
    return format_absolute(y, m, d, false);
}

std::optional<std::string> SayableDate::format_date_with_year(const std::string& date) const {
    if (date.empty()) return std::nullopt;
    int y = 0, m = 0, d = 0;
    if (!parse_date(date, y, m, d)) return std::nullopt;
    return format_absolute(y, m, d, true);
}

std::optional<std::string> SayableDate::format_relative(
    const std::string& date, const std::string& as_of) const {

    if (date.empty() || as_of.empty()) return std::nullopt;

    int dy = 0, dm = 0, dd = 0;
    int ay = 0, am = 0, ad = 0;
    if (!parse_date(date, dy, dm, dd)) return std::nullopt;
    if (!parse_date(as_of, ay, am, ad)) return std::nullopt;

    const int diff = to_jdn(dy, dm, dd) - to_jdn(ay, am, ad);

    // Today
    if (diff == 0) return today_;

    // Tomorrow
    if (diff == 1) return tomorrow_;

    // Yesterday
    if (diff == -1) return yesterday_;

    const bool is_compact = (compactness_ == Compactness::Compact);

    // Day after tomorrow (optional)
    if (diff == 2 && !locale_->day_after_tomorrow.empty() && !is_compact) {
        return locale_->day_after_tomorrow;
    }

    // Day before yesterday (optional)
    if (diff == -2 && !locale_->day_before_yesterday.empty() && !is_compact) {
        return locale_->day_before_yesterday;
    }

    // Compact mode: skip weekday references, go straight to calendar date
    if (is_compact) {
        return format_absolute(dy, dm, dd, dy != ay);
    }

    // This weekday (+2 to +6)
    if (diff >= 2 && diff <= 6 && !locale_->this_weekday.empty()) {
        const int dow = weekday(dy, dm, dd);
        const std::string& weekday_name = weekdays_[dow];
        return replace_all(locale_->this_weekday, "{weekday}", weekday_name);
    }

    // Last weekday (-2 to -6)
    if (diff >= -6 && diff <= -2 && !locale_->last_weekday.empty()) {
        const int dow = weekday(dy, dm, dd);
        const std::string& weekday_name = weekdays_[dow];
        return replace_all(locale_->last_weekday, "{weekday}", weekday_name);
    }

    // Next weekday (+7 to +13)
    if (diff >= 7 && diff <= 13 && !locale_->next_weekday.empty()) {
        const int dow = weekday(dy, dm, dd);
        const std::string& weekday_name = weekdays_[dow];
        return replace_all(locale_->next_weekday, "{weekday}", weekday_name);
    }

    // Calendar fallback
    return format_absolute(dy, dm, dd, dy != ay);
}

std::string SayableDate::format_absolute(int year, int month, int day,
                                         bool include_year) const {
    // Format the day with ordinal
    const std::string day_str = std::to_string(day);
    const auto it = day_format_exceptions_->find(day_str);
    const std::string& fmt = (it != day_format_exceptions_->end()) ? it->second : day_format_;
    const std::string formatted_day = replace_all(fmt, "{n}", day_str);

    // Pick month name (genitive form if available)
    const std::string* month_names = months_in_date_ ? months_in_date_ : months_;
    const std::string& month_name = month_names[month - 1];

    const std::string& pattern = include_year ? date_pattern_with_year_ : date_pattern_;
    std::string result = replace_all(pattern, "{month}", month_name);
    result = replace_all(result, "{day}", formatted_day);
    result = replace_all(result, "{d}", std::to_string(day));
    result = replace_all(result, "{m}", std::to_string(month));
    if (include_year) {
        result = replace_all(result, "{year}", std::to_string(year));
        // Two-digit year with zero padding
        const int yy = year % 100;
        const std::string yy_str = (yy < 10) ? "0" + std::to_string(yy) : std::to_string(yy);
        result = replace_all(result, "{yy}", yy_str);
    }

    return result;
}

// ---------- Free functions ----------

static const SayableDate& default_sd() {
    static const SayableDate sd(locales::EN());
    return sd;
}

std::optional<std::string> format_date(const std::string& date) {
    return default_sd().format_date(date);
}

std::optional<std::string> format_relative(const std::string& date,
                                           const std::string& as_of) {
    return default_sd().format_relative(date, as_of);
}

} // namespace sayabledate
