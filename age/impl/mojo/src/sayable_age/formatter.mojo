"""Human-friendly age formatting for young children."""

from .locale import (
    AgeLocale,
    CompactnessOverride,
    UnitForms,
    resolve_unit,
    resolve_stage,
)
from .dateutil import parse_age
from .locales.en import build_en

alias VERSION = "0.5.0"


fn _stage_key(months: Int) -> String:
    """Map calendar months to a stage key."""
    if months < 2:
        return "newborn"
    if months < 12:
        return "infant"
    if months < 36:
        return "toddler"
    if months < 156:
        return "child"
    if months < 216:
        return "teenager"
    return "adult"


fn _pick_str(
    override: CompactnessOverride,
    has_override: Bool,
    field: String,
    default: String,
) -> String:
    """Pick override value if set, else default."""
    if not has_override:
        return default
    if field == "half" and override.has_half:
        return override.half
    if field == "delimiter" and override.has_delimiter:
        return override.delimiter
    if field == "just_born" and override.has_just_born:
        return override.just_born
    return default


fn _get_stage(locale: AgeLocale, key: String, gender: String) -> String:
    """Look up a stage label by key and resolve it."""
    if key == "newborn":
        return resolve_stage(locale.newborn, gender)
    if key == "infant":
        return resolve_stage(locale.infant, gender)
    if key == "toddler":
        return resolve_stage(locale.toddler, gender)
    if key == "child":
        return resolve_stage(locale.child, gender)
    if key == "teenager":
        return resolve_stage(locale.teenager, gender)
    return resolve_stage(locale.adult, gender)


struct SayableAge(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale-aware age formatter."""

    var locale: AgeLocale
    var day: UnitForms
    var week: UnitForms
    var month: UnitForms
    var year: UnitForms
    var half: String
    var delimiter: String
    var just_born: String

    fn __init__(
        out self,
        locale: AgeLocale,
        compactness: String = "normal",
    ):
        var use_override = False
        var ovr = CompactnessOverride()

        if compactness == "short" and locale.has_short:
            ovr = locale.short_override
            use_override = True
        elif compactness == "compact" and locale.has_compact:
            ovr = locale.compact_override
            use_override = True

        if use_override:
            self.day = ovr.get_unit("day", locale.day)
            self.week = ovr.get_unit("week", locale.week)
            self.month = ovr.get_unit("month", locale.month)
            self.year = ovr.get_unit("year", locale.year)
        else:
            self.day = locale.day
            self.week = locale.week
            self.month = locale.month
            self.year = locale.year

        self.half = _pick_str(ovr, use_override, "half", locale.half)
        self.delimiter = _pick_str(ovr, use_override, "delimiter", locale.delimiter)
        self.just_born = _pick_str(ovr, use_override, "just_born", locale.just_born)
        self.locale = locale

    fn format_age(self, date_of_birth: String, as_of: String = "") -> String:
        """Human-friendly age string.

        Returns empty string if input is invalid, DOB is in the future,
        or age exceeds 500 years.
        """
        var parsed = parse_age(date_of_birth, as_of)
        if not parsed.valid:
            return ""

        var months = parsed.months
        var diff_days = parsed.diff_days

        # Tier 1: 0-6 days
        if diff_days == 0:
            return self.just_born
        if diff_days < 7:
            return resolve_unit(diff_days, self.day, self.locale)

        # Tier 2: weeks + days until 3 calendar months
        if months < 3:
            var weeks = diff_days // 7
            var days = diff_days % 7
            var result = resolve_unit(weeks, self.week, self.locale)
            if days > 0:
                result = result + self.delimiter + resolve_unit(
                    days, self.day, self.locale
                )
            return result

        # Tier 3: 3-23 months
        if months < 24:
            return resolve_unit(months, self.month, self.locale)

        # Tier 4: 24-35 months -> years + months
        if months < 36:
            var years = months // 12
            var rem = months % 12
            if rem == 0:
                return resolve_unit(years, self.year, self.locale)
            return (
                resolve_unit(years, self.year, self.locale)
                + self.delimiter
                + resolve_unit(rem, self.month, self.locale)
            )

        # Tier 5: 3-6 years -> years with half marker
        if months < 84:
            var years = months // 12
            var rem = months % 12
            if rem >= 6:
                return resolve_unit(years, self.year, self.locale, self.half)
            return resolve_unit(years, self.year, self.locale)

        # Tier 6: 7+ years
        return resolve_unit(months // 12, self.year, self.locale)

    fn format_stage(
        self,
        date_of_birth: String,
        as_of: String = "",
        gender: String = "",
    ) -> String:
        """Developmental stage label based on age.

        Returns empty string if input is invalid.
        """
        var parsed = parse_age(date_of_birth, as_of)
        if not parsed.valid:
            return ""
        var key = _stage_key(parsed.months)
        return _get_stage(self.locale, key, gender)


fn format_age(date_of_birth: String, as_of: String = "") -> String:
    """Human-friendly age string using the default English locale."""
    var sa = SayableAge(build_en())
    return sa.format_age(date_of_birth, as_of)


fn format_stage(
    date_of_birth: String, as_of: String = "", gender: String = ""
) -> String:
    """Developmental stage label using the default English locale."""
    var sa = SayableAge(build_en())
    return sa.format_stage(date_of_birth, as_of, gender)
