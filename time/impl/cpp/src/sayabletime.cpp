#include "sayabletime/sayabletime.hpp"
#include "sayabletime/locales/locales.hpp"

#include <optional>
#include <string>
#include <utility>

namespace sayabletime {

namespace {

/// Number of leading ASCII digits in s from pos.
size_t digit_run(const std::string& s, size_t pos) {
    size_t n = 0;
    while (pos + n < s.size() && s[pos + n] >= '0' && s[pos + n] <= '9') ++n;
    return n;
}

/// Value of the count ASCII digits at pos (the caller has checked they are digits).
int digits_value(const std::string& s, size_t pos, size_t count) {
    int value = 0;
    for (size_t i = pos; i < pos + count; ++i) value = value * 10 + (s[i] - '0');
    return value;
}

/// Days in a Gregorian month (leap years by the 4/100/400 rule).
int days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

/// True for exactly "YYYY-MM-DD" naming a real calendar day.
bool is_real_date(const std::string& s) {
    if (s.size() != 10 || s[4] != '-' || s[7] != '-' || digit_run(s, 0) != 4 ||
        digit_run(s, 5) != 2 || digit_run(s, 8) != 2) {
        return false;
    }
    const int year = digits_value(s, 0, 4);
    const int month = digits_value(s, 5, 2);
    const int day = digits_value(s, 8, 2);
    return month >= 1 && month <= 12 && day >= 1 && day <= days_in_month(year, month);
}

/// True for nothing, "Z", or "+HH:MM" / "-HH:MM" starting at pos.
bool is_zone_suffix(const std::string& s, size_t pos) {
    const std::string zone = s.substr(pos);
    if (zone.empty() || zone == "Z") return true;
    return zone.size() == 6 && (zone[0] == '+' || zone[0] == '-') && digit_run(zone, 1) == 2 &&
           zone[3] == ':' && digit_run(zone, 4) == 2;
}

/// Parse "H:MM" or "HH:MM", optional ":SS", optional "." plus digits after the
/// seconds, and an optional zone suffix, which is validated but ignored.
std::optional<std::pair<int, int>> parse_clock(const std::string& clock) {
    const size_t hour_len = digit_run(clock, 0);
    if (hour_len < 1 || hour_len > 2 || hour_len >= clock.size() || clock[hour_len] != ':' ||
        digit_run(clock, hour_len + 1) < 2) {
        return std::nullopt;
    }
    const int hour = digits_value(clock, 0, hour_len);
    const int minute = digits_value(clock, hour_len + 1, 2);
    int second = 0;
    size_t rest = hour_len + 3;
    if (rest < clock.size() && clock[rest] == ':') {
        if (digit_run(clock, rest + 1) < 2) return std::nullopt;
        second = digits_value(clock, rest + 1, 2);
        rest += 3;
        if (rest < clock.size() && clock[rest] == '.') {
            const size_t fraction_len = digit_run(clock, rest + 1);
            if (fraction_len == 0) return std::nullopt;
            rest += 1 + fraction_len;
        }
    }
    if (!is_zone_suffix(clock, rest) || hour > 23 || minute > 59 || second > 59) {
        return std::nullopt;
    }
    return std::make_pair(hour, minute);
}

/// Parse a clock time, alone or after the "T" of an ISO datetime whose date
/// is valid, to (hour, minute) (docs/input-formats.md).
std::optional<std::pair<int, int>> parse_time(const std::string& input) {
    const auto pos_t = input.find('T');
    if (pos_t == std::string::npos) return parse_clock(input);
    if (!is_real_date(input.substr(0, pos_t))) return std::nullopt;
    return parse_clock(input.substr(pos_t + 1));
}

/// Round minute to nearest 5.
int round_to_5(int minute) {
    return ((minute + 2) / 5) * 5;
}

/// Replace all occurrences of `from` with `to` in `str`.
std::string replace_all(const std::string& str,
                        const std::string& from,
                        const std::string& to) {
    std::string result = str;
    std::string::size_type pos = 0;
    while ((pos = result.find(from, pos)) != std::string::npos) {
        result.replace(pos, from.length(), to);
        pos += to.length();
    }
    return result;
}

/// Zero-pad an integer to 2 digits.
std::string pad2(int n) {
    if (n < 10) return "0" + std::to_string(n);
    return std::to_string(n);
}

} // anonymous namespace


SayableTime::SayableTime(const TimeLocale& locale, Compactness compactness)
    : locale_(&locale)
    , compactness_(compactness)
    , override_(nullptr)
{
    if (compactness == Compactness::Short && locale.short_override.has_value()) {
        override_ = &locale.short_override.value();
    } else if (compactness == Compactness::Compact && locale.compact_override.has_value()) {
        override_ = &locale.compact_override.value();
    }
}

std::optional<std::string> SayableTime::format_time(const std::string& input) const {
    if (input.empty()) return std::nullopt;

    auto parsed = parse_time(input);
    if (!parsed.has_value()) return std::nullopt;

    auto [hour, minute] = parsed.value();

    if (compactness_ != Compactness::Normal && override_ != nullptr) {
        return format_digital(hour, minute);
    }
    return format_natural(hour, minute);
}

std::string SayableTime::format_natural(int hour, int minute) const {
    const auto& clock = locale_->clock;
    int rounded = round_to_5(minute);
    int h = hour;

    if (rounded == 60) {
        rounded = 0;
        h = (h + 1) % 24;
    }

    if (rounded == 0) {
        if (h == 0) return clock.midnight;
        if (h == 12) return clock.noon;
    }

    int h12 = h % 12;
    int next_h12 = (h + 1) % 12;
    const std::string& h_name = clock.hours[h12];
    const std::string& next_h_name = clock.hours[next_h12];

    // Look up pattern
    auto it = clock.patterns.find(rounded);
    std::string pattern;
    if (it != clock.patterns.end()) {
        pattern = it->second;
    } else {
        auto it0 = clock.patterns.find(0);
        pattern = (it0 != clock.patterns.end()) ? it0->second : "{h}";
    }

    std::string result = replace_all(pattern, "{h}", h_name);
    result = replace_all(result, "{next_h}", next_h_name);
    return result;
}

std::string SayableTime::format_digital(int hour, int minute) const {
    const auto& sc = override_->clock;
    std::string fmt = sc.format;

    if (sc.use24h) {
        std::string result = replace_all(fmt, "{h}", std::to_string(hour));
        result = replace_all(result, "{mm}", pad2(minute));
        return result;
    }

    int h12 = hour % 12;
    if (h12 == 0) h12 = 12;

    const std::string& ampm_str = (hour < 12) ? sc.am_pm[0] : sc.am_pm[1];

    std::string result = replace_all(fmt, "{h}", std::to_string(h12));
    result = replace_all(result, "{mm}", pad2(minute));
    result = replace_all(result, "{ampm}", ampm_str);
    return result;
}


// Free function using the default English locale.
std::optional<std::string> format_time(const std::string& input) {
    static const SayableTime default_formatter(locales::EN());
    return default_formatter.format_time(input);
}

} // namespace sayabletime
