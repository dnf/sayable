#include "sayableduration/sayableduration.hpp"
#include "sayableduration/locales/locales.hpp"

#include <cmath>
#include <cstdlib>
#include <optional>
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

bool is_leap(int y) {
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

int days_in_month(int y, int m) {
    if (m == 2) return is_leap(y) ? 29 : 28;
    if (m == 4 || m == 6 || m == 9 || m == 11) return 30;
    return 31;
}

/// Days from 2000-01-01 to the given date (negative before it).
long long days_since_epoch(int year, int month, int day) {
    long long days = 0;
    if (year >= 2000) {
        for (int y = 2000; y < year; ++y) days += is_leap(y) ? 366 : 365;
    } else {
        for (int y = year; y < 2000; ++y) days -= is_leap(y) ? 366 : 365;
    }
    for (int m = 1; m < month; ++m) days += days_in_month(year, m);
    return days + day - 1;
}

/// True for nothing, "Z", or "+HH:MM" / "-HH:MM" starting at pos.
bool is_zone_suffix(const std::string& s, size_t pos) {
    const std::string zone = s.substr(pos);
    if (zone.empty() || zone == "Z") return true;
    return zone.size() == 6 && (zone[0] == '+' || zone[0] == '-') && digit_run(zone, 1) == 2 &&
           zone[3] == ':' && digit_run(zone, 4) == 2;
}

/// Parse a timestamp "YYYY-MM-DDTHH:MM", optional ":SS", optional "." plus
/// digits after the seconds, and an optional zone suffix, which is ignored
/// (docs/input-formats.md), into seconds since 2000-01-01 for diffing.
std::optional<long long> parse_iso_to_seconds(const std::string& iso) {
    if (iso.size() < 11 || iso[4] != '-' || iso[7] != '-' || iso[10] != 'T' ||
        digit_run(iso, 0) != 4 || digit_run(iso, 5) != 2 || digit_run(iso, 8) != 2) {
        return std::nullopt;
    }
    const int year = digits_value(iso, 0, 4);
    const int month = digits_value(iso, 5, 2);
    const int day = digits_value(iso, 8, 2);
    if (month < 1 || month > 12 || day < 1 || day > days_in_month(year, month)) return std::nullopt;

    const size_t clock = 11;
    const size_t hour_len = digit_run(iso, clock);
    if (hour_len < 1 || hour_len > 2 || clock + hour_len >= iso.size() || iso[clock + hour_len] != ':' ||
        digit_run(iso, clock + hour_len + 1) < 2) {
        return std::nullopt;
    }
    const int hour = digits_value(iso, clock, hour_len);
    const int minute = digits_value(iso, clock + hour_len + 1, 2);
    int second = 0;
    size_t rest = clock + hour_len + 3;
    if (rest < iso.size() && iso[rest] == ':') {
        if (digit_run(iso, rest + 1) < 2) return std::nullopt;
        second = digits_value(iso, rest + 1, 2);
        rest += 3;
        if (rest < iso.size() && iso[rest] == '.') {
            const size_t fraction_len = digit_run(iso, rest + 1);
            if (fraction_len == 0) return std::nullopt;
            rest += 1 + fraction_len;
        }
    }
    if (!is_zone_suffix(iso, rest) || hour > 23 || minute > 59 || second > 59) return std::nullopt;

    return days_since_epoch(year, month, day) * 86400 + hour * 3600 + minute * 60 + second;
}

/// Months from whole days, 30.44 days to the month, rounded (as Python's round()).
long long approximate_months(long long total_days) {
    return static_cast<long long>(std::round(static_cast<double>(total_days) / 30.44));
}

/// Durations over 6000 months (500 years) have no value: the same ceiling as sayable-age.
constexpr long long MAX_DURATION_MONTHS = 6000;

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

std::optional<std::string> SayableDuration::format_duration(long long seconds) const {
    if (seconds < 0) return std::nullopt;
    return format_seconds(seconds);
}

std::optional<std::string> SayableDuration::format_duration(
    const std::string& start, const std::string& end) const {

    const auto s = parse_iso_to_seconds(start);
    const auto e = parse_iso_to_seconds(end);
    if (!s || !e) return std::nullopt;
    return format_seconds(std::llabs(*e - *s));
}

std::optional<std::string> SayableDuration::format_since(
    const std::string& start, const std::string& as_of) const {

    const auto s = parse_iso_to_seconds(start);
    const auto a = parse_iso_to_seconds(as_of);
    if (!s || !a) return std::nullopt;
    const long long diff = *a - *s;
    if (diff < 0) return std::nullopt;
    if (diff == 0) return just_now_;
    const auto dur = format_seconds(diff);
    if (!dur) return std::nullopt;
    return replace_first(ago_, "{0}", *dur);
}

std::optional<std::string> SayableDuration::format_until(
    const std::string& target, const std::string& as_of) const {

    const auto t = parse_iso_to_seconds(target);
    const auto a = parse_iso_to_seconds(as_of);
    if (!t || !a) return std::nullopt;
    const long long diff = *t - *a;
    if (diff < 0) return std::nullopt;
    if (diff == 0) return just_now_;
    const auto dur = format_seconds(diff);
    if (!dur) return std::nullopt;
    return replace_first(in_future_, "{0}", *dur);
}

std::optional<std::string> SayableDuration::format_seconds(long long total_seconds) const {
    const long long whole_days = total_seconds / 86400;
    if (whole_days >= 30 && approximate_months(whole_days) > MAX_DURATION_MONTHS) return std::nullopt;
    return format_tiers(total_seconds);
}

std::string SayableDuration::format_tiers(long long total) const {
    // Within the 500-year ceiling every count below fits an int.

    // 0 seconds
    if (total == 0) return just_now_;

    // 1-59 seconds
    if (total < 60) {
        return resolve_unit(static_cast<int>(total), second_, locale_);
    }

    const int total_minutes = static_cast<int>(total / 60);
    const int remainder_seconds = static_cast<int>(total % 60);

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

    const int total_hours = static_cast<int>(total / 3600);
    const int remainder_minutes = static_cast<int>((total % 3600) / 60);

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

    const int total_days = static_cast<int>(total / 86400);
    const int remainder_hours = static_cast<int>((total % 86400) / 3600);

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
    int total_months = static_cast<int>(approximate_months(total_days));

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

std::optional<std::string> format_duration(long long seconds) {
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
