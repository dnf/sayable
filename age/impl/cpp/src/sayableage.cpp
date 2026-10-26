#include "sayableage/sayableage.hpp"
#include "sayableage/locales/locales.hpp"

#include <algorithm>
#include <chrono>
#include <ctime>
#include <string>

namespace sayableage {

// ---------- testing clock override ----------

namespace testing {

static bool today_override_set = false;
static int today_override_y = 0;
static int today_override_m = 0;
static int today_override_d = 0;

void set_today(int year, int month, int day) {
    today_override_set = true;
    today_override_y = year;
    today_override_m = month;
    today_override_d = day;
}

void clear_today() {
    today_override_set = false;
}

} // namespace testing

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

/// Days in a given month.
int days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

/// Parse a fixed-width run of ASCII digits. Returns false if any isn't a digit.
bool parse_digits(const std::string& s, size_t pos, size_t count, int& out) {
    out = 0;
    for (size_t i = pos; i < pos + count; ++i) {
        const char c = s[i];
        if (c < '0' || c > '9') return false;
        out = out * 10 + (c - '0');
    }
    return true;
}

/// Parse exactly "YYYY-MM-DD" naming a real calendar day (docs/input-formats.md).
bool parse_date_parts(const std::string& s, int& y, int& m, int& d) {
    if (s.size() != 10 || s[4] != '-' || s[7] != '-') return false;
    if (!parse_digits(s, 0, 4, y) || !parse_digits(s, 5, 2, m) || !parse_digits(s, 8, 2, d)) {
        return false;
    }
    return m >= 1 && m <= 12 && d >= 1 && d <= days_in_month(y, m);
}

/// Julian Day Number for computing day differences between dates.
/// See https://en.wikipedia.org/wiki/Julian_day#Converting_Gregorian_calendar_date_to_JDN
int julian_day(int year, int month, int day) {
    const int a = (14 - month) / 12;
    const int y = year + 4800 - a;
    const int m = month + 12 * a - 3;
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
}

constexpr int MAX_AGE_MONTHS = 6000;

struct AgeComponents {
    const int months;
    const int diff_days;
};

/// Get current date as (year, month, day).
void get_today(int& y, int& m, int& d) {
    if (testing::today_override_set) {
        y = testing::today_override_y;
        m = testing::today_override_m;
        d = testing::today_override_d;
        return;
    }
    const auto now = std::chrono::system_clock::now();
    const std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm tm_buf{};
#if defined(_WIN32)
    gmtime_s(&tm_buf, &t);
#else
    gmtime_r(&t, &tm_buf);
#endif
    y = tm_buf.tm_year + 1900;
    m = tm_buf.tm_mon + 1;
    d = tm_buf.tm_mday;
}

/// Parse age into months and diff_days. Returns nullopt on invalid/future.
std::optional<AgeComponents> parse_age(const std::string& date_of_birth,
                                        const std::string& as_of) {
    if (date_of_birth.empty()) return std::nullopt;

    int dob_y = 0, dob_m = 0, dob_d = 0;
    if (!parse_date_parts(date_of_birth, dob_y, dob_m, dob_d)) return std::nullopt;

    int ref_y = 0, ref_m = 0, ref_d = 0;
    if (!as_of.empty()) {
        if (!parse_date_parts(as_of, ref_y, ref_m, ref_d)) return std::nullopt;
    } else {
        get_today(ref_y, ref_m, ref_d);
    }

    const int diff_days = julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d);
    if (diff_days < 0) return std::nullopt;

    // Calendar months: clamp birthday to last day of reference month so that
    // e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
    const int last_day = days_in_month(ref_y, ref_m);
    const int clamped_birthday = std::min(dob_d, last_day);
    int months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
    if (ref_d < clamped_birthday) months--;
    if (months > MAX_AGE_MONTHS) return std::nullopt;

    return AgeComponents{months, diff_days};
}

/// Determine the developmental stage key from months.
std::string stage_key(int months) {
    if (months < 2) return "newborn";
    if (months < 12) return "infant";
    if (months < 36) return "toddler";
    if (months < 156) return "child";
    if (months < 216) return "teenager";
    return "adult";
}

/// Format a count with unit forms, locale, and optional half marker.
///
/// The half template supports two placeholder styles:
///   {n} — modifies the formatted number before unit substitution (e.g. "3½" instead of "3")
///   {0} — wraps the fully resolved expression after unit substitution (e.g. "3 years and a half")
std::string resolve_unit(int count, const UnitForms& uf, const AgeLocale* loc,
                         const std::string& half) {
    const std::string base_n = loc->format_number
        ? loc->format_number(count) : itoa(count);

    // Apply {n}-style half marker to the number
    const std::string n = (!half.empty() && contains(half, "{n}"))
        ? replace_first(half, "{n}", base_n) : base_n;

    // Select template
    std::string tmpl;
    if (!uf.simple.empty()) {
        tmpl = uf.simple;
    } else {
        const PluralCategory cat = loc->plural(count);
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

} // anonymous namespace

// ---------- SayableAge ----------

SayableAge::SayableAge(const AgeLocale& locale, Compactness compactness)
    : locale_(&locale),
      day_(locale.units.day),
      week_(locale.units.week),
      month_(locale.units.month),
      year_(locale.units.year),
      half_(locale.half),
      delimiter_(locale.delimiter),
      just_born_(locale.just_born) {

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
        if (o.day.has_value()) day_ = o.day.value();
        if (o.week.has_value()) week_ = o.week.value();
        if (o.month.has_value()) month_ = o.month.value();
        if (o.year.has_value()) year_ = o.year.value();
        if (o.half.has_value()) half_ = o.half.value();
        if (o.delimiter.has_value()) delimiter_ = o.delimiter.value();
        if (o.just_born.has_value()) just_born_ = o.just_born.value();
    }
}

std::optional<std::string> SayableAge::format_age(
    const std::string& date_of_birth, const std::string& as_of) const {

    const auto age = parse_age(date_of_birth, as_of);
    if (!age.has_value()) return std::nullopt;

    const int months = age->months;
    const int diff_days = age->diff_days;

    // Tier 1: 0 days
    if (diff_days == 0) {
        return just_born_;
    }

    // Tier 1b: 1-6 days
    if (diff_days < 7) {
        return resolve_unit(diff_days, day_, locale_, "");
    }

    // Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
        const int weeks = diff_days / 7;
        const int days = diff_days % 7;
        std::string result = resolve_unit(weeks, week_, locale_, "");
        if (days > 0) {
            result += delimiter_ + resolve_unit(days, day_, locale_, "");
        }
        return result;
    }

    // Tier 3: 3-23 months
    if (months < 24) {
        return resolve_unit(months, month_, locale_, "");
    }

    // Tier 4: 24-35 months -> years + months
    if (months < 36) {
        const int years = months / 12;
        const int rem = months % 12;
        if (rem == 0) {
            return resolve_unit(years, year_, locale_, "");
        }
        return resolve_unit(years, year_, locale_, "") + delimiter_ +
               resolve_unit(rem, month_, locale_, "");
    }

    // Tier 5: 3-6 years -> years with half marker
    if (months < 84) {
        const int years = months / 12;
        const int rem = months % 12;
        if (rem >= 6) {
            return resolve_unit(years, year_, locale_, half_);
        }
        return resolve_unit(years, year_, locale_, "");
    }

    // Tier 6: 7+ years
    const int years = months / 12;
    return resolve_unit(years, year_, locale_, "");
}

std::optional<std::string> SayableAge::format_stage(
    const std::string& date_of_birth, const std::string& as_of,
    const std::string& gender) const {

    const auto age = parse_age(date_of_birth, as_of);
    if (!age.has_value()) return std::nullopt;

    const std::string key = stage_key(age->months);
    const StageLabel* label = nullptr;
    if (key == "newborn") label = &locale_->stages.newborn;
    else if (key == "infant") label = &locale_->stages.infant;
    else if (key == "toddler") label = &locale_->stages.toddler;
    else if (key == "child") label = &locale_->stages.child;
    else if (key == "teenager") label = &locale_->stages.teenager;
    else if (key == "adult") label = &locale_->stages.adult;
    if (!label) return std::nullopt;
    return label->resolve(gender);
}

// ---------- Free functions ----------

static const SayableAge& default_pt() {
    static const SayableAge pt(locales::EN());
    return pt;
}

std::optional<std::string> format_age(const std::string& date_of_birth,
                                      const std::string& as_of) {
    return default_pt().format_age(date_of_birth, as_of);
}

std::optional<std::string> format_stage(const std::string& date_of_birth,
                                        const std::string& as_of,
                                        const std::string& gender) {
    return default_pt().format_stage(date_of_birth, as_of, gender);
}

} // namespace sayableage
