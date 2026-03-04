#include "sayabletime/sayabletime.hpp"
#include "sayabletime/locales/locales.hpp"

#include <optional>
#include <string>
#include <utility>

namespace sayabletime {

namespace {

/// Parse "HH:MM" or ISO datetime string to (hour, minute).
/// Returns std::nullopt on failure.
std::optional<std::pair<int, int>> parse_time(const std::string& input) {
    if (input.empty()) return std::nullopt;

    std::string t = input;

    // Extract time portion from ISO datetime
    auto pos_t = t.find('T');
    if (pos_t != std::string::npos) {
        t = t.substr(pos_t + 1);
    }

    // Strip timezone suffix
    auto pos_plus = t.find('+');
    if (pos_plus != std::string::npos) {
        t = t.substr(0, pos_plus);
    }
    auto pos_z = t.find('Z');
    if (pos_z != std::string::npos) {
        t = t.substr(0, pos_z);
    }

    // Split on ':'
    auto colon_pos = t.find(':');
    if (colon_pos == std::string::npos) return std::nullopt;

    std::string hour_str = t.substr(0, colon_pos);
    std::string rest = t.substr(colon_pos + 1);

    // Strip fractional seconds from minute part
    auto dot_pos = rest.find('.');
    if (dot_pos != std::string::npos) {
        rest = rest.substr(0, dot_pos);
    }
    // Also handle seconds part (HH:MM:SS)
    auto colon2 = rest.find(':');
    if (colon2 != std::string::npos) {
        rest = rest.substr(0, colon2);
    }

    int hour = 0;
    int minute = 0;
    try {
        hour = std::stoi(hour_str);
        minute = std::stoi(rest);
    } catch (...) {
        return std::nullopt;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return std::nullopt;
    }

    return std::make_pair(hour, minute);
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
