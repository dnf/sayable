#include "sayableduration/sayableduration.hpp"
#include "sayableduration/locales/locales.hpp"

#include <cmath>
#include <string>

namespace sayableduration {

// ---------- internal helpers ----------

namespace {

std::string itoa(int n) {
    if (n < 0) return "-" + itoa(-n);
    return std::to_string(n);
}

std::string replace_first(const std::string& str, const std::string& from,
                          const std::string& to) {
    const auto pos = str.find(from);
    if (pos == std::string::npos) return str;
    std::string result = str;
    result.replace(pos, from.size(), to);
    return result;
}

bool contains(const std::string& str, const std::string& substr) {
    return str.find(substr) != std::string::npos;
}

/// Format a count with unit forms, locale, and optional half marker.
///
/// The half template supports two placeholder styles:
///   {n} -- modifies the formatted number before unit substitution (e.g. "3\xC2\xBD" instead of "3")
///   {0} -- wraps the fully resolved expression after unit substitution (e.g. "3 hours and a half")
std::string resolve_unit(int count, const UnitForms& uf, const DurationLocale* loc,
                         const std::string& half = "") {
    const std::string base_n = loc->format_number
        ? loc->format_number(count) : itoa(count);

    // Apply {n}-style half marker to the number
    const std::string n = (!half.empty() && contains(half, "{n}"))
        ? replace_first(half, "{n}", base_n) : base_n;

    // Select template: half-marked values use "other" plural (e.g. "1.5 hours" not "1.5 hour")
    std::string tmpl;
    if (!uf.simple.empty()) {
        tmpl = uf.simple;
    } else {
        const PluralCategory cat = half.empty() ? loc->plural(count) : PluralCategory::Other;
        const auto it = uf.forms.find(cat);
        if (it != uf.forms.end()) {
            tmpl = it->second;
        } else {
            const auto ot = uf.forms.find(PluralCategory::Other);
            if (ot != uf.forms.end()) {
                tmpl = ot->second;
            }
        }
    }

    std::string result = replace_first(tmpl, "{n}", n);

    if (loc->format_unit) {
        result = loc->format_unit(count, result);
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if (!half.empty() && contains(half, "{0}")) {
        result = replace_first(half, "{0}", result);
    }

    return result;
}

/// Parse an ISO datetime "YYYY-MM-DDTHH:MM:SS" into total seconds since epoch.
/// Returns -1 on parse failure.
int parse_iso_to_seconds(const std::string& iso) {
    if (iso.empty()) return -1;

    // Find T separator
    const auto t_pos = iso.find('T');
    if (t_pos == std::string::npos || t_pos < 10) return -1;

    // Parse date part
    const std::string date_part = iso.substr(0, t_pos);
    if (date_part.size() < 10 || date_part[4] != '-' || date_part[7] != '-') return -1;

    int year = 0;
    for (int i = 0; i < 4; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return -1;
        year = year * 10 + (c - '0');
    }
    int month = 0;
    for (int i = 5; i < 7; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return -1;
        month = month * 10 + (c - '0');
    }
    int day = 0;
    for (int i = 8; i < 10; ++i) {
        const char c = date_part[static_cast<size_t>(i)];
        if (c < '0' || c > '9') return -1;
        day = day * 10 + (c - '0');
    }

    // Parse time part (strip timezone suffix)
    std::string time_str = iso.substr(t_pos + 1);
    {
        const auto plus_pos = time_str.find('+');
        if (plus_pos != std::string::npos) {
            time_str = time_str.substr(0, plus_pos);
        }
        const auto z_pos = time_str.find('Z');
        if (z_pos != std::string::npos) {
            time_str = time_str.substr(0, z_pos);
        }
    }

    int hour = 0;
    int minute = 0;
    int second = 0;

    if (time_str.size() >= 2) {
        for (int i = 0; i < 2; ++i) {
            const char c = time_str[static_cast<size_t>(i)];
            if (c < '0' || c > '9') return -1;
            hour = hour * 10 + (c - '0');
        }
    }
    if (time_str.size() >= 5 && time_str[2] == ':') {
        for (int i = 3; i < 5; ++i) {
            const char c = time_str[static_cast<size_t>(i)];
            if (c < '0' || c > '9') return -1;
            minute = minute * 10 + (c - '0');
        }
    }
    if (time_str.size() >= 8 && time_str[5] == ':') {
        for (int i = 6; i < 8; ++i) {
            const char c = time_str[static_cast<size_t>(i)];
            if (c < '0' || c > '9') return -1;
            second = second * 10 + (c - '0');
        }
    }

    // Calculate days since epoch (2000-01-01)
    auto is_leap = [](int y) -> bool {
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
    };

    auto days_in_month_fn = [&is_leap](int y, int m) -> int {
        if (m == 2) return is_leap(y) ? 29 : 28;
        if (m == 4 || m == 6 || m == 9 || m == 11) return 30;
        return 31;
    };

    int days = 0;
    if (year >= 2000) {
        for (int y = 2000; y < year; ++y) {
            days += is_leap(y) ? 366 : 365;
        }
    } else {
        for (int y = year; y < 2000; ++y) {
            days -= is_leap(y) ? 366 : 365;
        }
    }
    for (int m = 1; m < month; ++m) {
        days += days_in_month_fn(year, m);
    }
    days += day - 1;

    return days * 86400 + hour * 3600 + minute * 60 + second;
}

} // anonymous namespace

// ---------- SayableDuration ----------

SayableDuration::SayableDuration(const DurationLocale& locale, Compactness compactness)
    : locale_(&locale),
      second_(locale.units.second),
      minute_(locale.units.minute),
      hour_(locale.units.hour),
      day_(locale.units.day),
      week_(locale.units.week),
      month_(locale.units.month),
      year_(locale.units.year),
      half_(locale.half),
      delimiter_(locale.delimiter),
      just_now_(locale.just_now),
      ago_(locale.ago),
      in_future_(locale.in_future) {

    const std::optional<CompactnessOverride>* ovr = nullptr;
    switch (compactness) {
        case Compactness::Short:
            ovr = &locale.short_override;
            break;
        case Compactness::Compact:
            ovr = &locale.compact_override;
            break;
        case Compactness::Normal:
            break;
    }

    if (ovr != nullptr && ovr->has_value()) {
        const auto& o = ovr->value();
        if (o.second.has_value()) second_ = o.second.value();
        if (o.minute.has_value()) minute_ = o.minute.value();
        if (o.hour.has_value()) hour_ = o.hour.value();
        if (o.day.has_value()) day_ = o.day.value();
        if (o.week.has_value()) week_ = o.week.value();
        if (o.month.has_value()) month_ = o.month.value();
        if (o.year.has_value()) year_ = o.year.value();
        if (o.half.has_value()) half_ = o.half.value();
        if (o.delimiter.has_value()) delimiter_ = o.delimiter.value();
        if (o.ago.has_value()) ago_ = o.ago.value();
        if (o.in_future.has_value()) in_future_ = o.in_future.value();
    }
}

std::optional<std::string> SayableDuration::format_duration(int seconds) const {
    if (seconds < 0) return std::nullopt;
    return format_seconds(seconds);
}

std::optional<std::string> SayableDuration::format_duration(
    const std::string& start, const std::string& end) const {

    if (start.empty() || end.empty()) return std::nullopt;
    const int s = parse_iso_to_seconds(start);
    const int e = parse_iso_to_seconds(end);
    if (s < 0 || e < 0) return std::nullopt;
    const int diff = e - s;
    if (diff < 0) return std::nullopt;
    return format_seconds(diff);
}

std::optional<std::string> SayableDuration::format_since(
    const std::string& start, const std::string& as_of) const {

    if (start.empty() || as_of.empty()) return std::nullopt;
    const int s = parse_iso_to_seconds(start);
    const int a = parse_iso_to_seconds(as_of);
    if (s < 0 || a < 0) return std::nullopt;
    const int diff = a - s;
    if (diff < 0) return std::nullopt;
    if (diff == 0) return just_now_;
    const std::string dur = format_seconds(diff);
    return replace_first(ago_, "{0}", dur);
}

std::optional<std::string> SayableDuration::format_until(
    const std::string& target, const std::string& as_of) const {

    if (target.empty() || as_of.empty()) return std::nullopt;
    const int t = parse_iso_to_seconds(target);
    const int a = parse_iso_to_seconds(as_of);
    if (t < 0 || a < 0) return std::nullopt;
    const int diff = t - a;
    if (diff < 0) return std::nullopt;
    if (diff == 0) return just_now_;
    const std::string dur = format_seconds(diff);
    return replace_first(in_future_, "{0}", dur);
}

std::string SayableDuration::format_seconds(int total) const {
    // 0 seconds
    if (total == 0) return just_now_;

    // 1-59 seconds
    if (total < 60) {
        return resolve_unit(total, second_, locale_);
    }

    const int total_minutes = total / 60;
    const int remainder_seconds = total % 60;

    // 1-4 minutes: minutes + seconds
    if (total_minutes < 5) {
        std::string result = resolve_unit(total_minutes, minute_, locale_);
        if (remainder_seconds > 0) {
            result += delimiter_ + resolve_unit(remainder_seconds, second_, locale_);
        }
        return result;
    }

    // 5-59 minutes
    if (total_minutes < 60) {
        return resolve_unit(total_minutes, minute_, locale_);
    }

    const int total_hours = total / 3600;
    const int remainder_minutes = (total % 3600) / 60;

    // 1-5 hours: hours + minutes (with half marker)
    if (total_hours <= 5) {
        if (remainder_minutes == 30) {
            return resolve_unit(total_hours, hour_, locale_, half_);
        }
        std::string result = resolve_unit(total_hours, hour_, locale_);
        if (remainder_minutes > 0) {
            result += delimiter_ + resolve_unit(remainder_minutes, minute_, locale_);
        }
        return result;
    }

    // 6-23 hours
    if (total_hours < 24) {
        return resolve_unit(total_hours, hour_, locale_);
    }

    const int total_days = total / 86400;
    const int remainder_hours = (total % 86400) / 3600;

    // 1-2 days: days + hours (with half marker)
    if (total_days <= 2) {
        if (remainder_hours == 12) {
            return resolve_unit(total_days, day_, locale_, half_);
        }
        std::string result = resolve_unit(total_days, day_, locale_);
        if (remainder_hours > 0) {
            result += delimiter_ + resolve_unit(remainder_hours, hour_, locale_);
        }
        return result;
    }

    // 3-6 days
    if (total_days < 7) {
        return resolve_unit(total_days, day_, locale_);
    }

    const int total_weeks = total_days / 7;
    const int remainder_days = total_days % 7;

    // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    if (total_days < 30) {
        std::string result = resolve_unit(total_weeks, week_, locale_);
        if (remainder_days > 0) {
            result += delimiter_ + resolve_unit(remainder_days, day_, locale_);
        }
        return result;
    }

    // Approximate months (30.44 days average)
    int total_months = static_cast<int>(std::round(static_cast<double>(total_days) / 30.44));

    // 1-11 months
    if (total_months < 12) {
        if (total_months == 0) total_months = 1;
        return resolve_unit(total_months, month_, locale_);
    }

    // 12+ months: years + months
    const int total_years = total_months / 12;
    const int remainder_months = total_months % 12;
    std::string result = resolve_unit(total_years, year_, locale_);
    if (remainder_months > 0) {
        result += delimiter_ + resolve_unit(remainder_months, month_, locale_);
    }
    return result;
}

// ---------- Free functions ----------

static const SayableDuration& default_sd() {
    static const SayableDuration sd(locales::EN());
    return sd;
}

std::optional<std::string> format_duration(int seconds) {
    return default_sd().format_duration(seconds);
}

std::optional<std::string> format_duration(const std::string& start,
                                           const std::string& end) {
    return default_sd().format_duration(start, end);
}

std::optional<std::string> format_since(const std::string& start,
                                        const std::string& as_of) {
    return default_sd().format_since(start, as_of);
}

std::optional<std::string> format_until(const std::string& target,
                                        const std::string& as_of) {
    return default_sd().format_until(target, as_of);
}

} // namespace sayableduration
