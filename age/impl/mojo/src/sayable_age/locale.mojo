"""Locale definitions for age formatting."""


struct UnitForms(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """A unit's display forms: either a single template or plural forms."""

    var is_simple: Bool
    var template_str: String
    var zero: String
    var one: String
    var two: String
    var few: String
    var many: String
    var other: String

    fn __init__(out self):
        self.is_simple = True
        self.template_str = ""
        self.zero = ""
        self.one = ""
        self.two = ""
        self.few = ""
        self.many = ""
        self.other = ""

    fn get_template(self, category: String) -> String:
        """Get the template for a plural category."""
        if self.is_simple:
            return self.template_str
        if category == "zero":
            return self.zero
        if category == "one":
            return self.one
        if category == "two":
            return self.two
        if category == "few":
            return self.few
        if category == "many":
            return self.many
        return self.other


fn simple_unit(template: String) -> UnitForms:
    """Create a simple unit with a single template."""
    var uf = UnitForms()
    uf.is_simple = True
    uf.template_str = template
    return uf


fn plural_unit(
    zero: String = "",
    one: String = "",
    two: String = "",
    few: String = "",
    many: String = "",
    other: String = "",
) -> UnitForms:
    """Create a plural unit with category-template pairs."""
    var uf = UnitForms()
    uf.is_simple = False
    uf.zero = zero
    uf.one = one
    uf.two = two
    uf.few = few
    uf.many = many
    uf.other = other
    return uf


struct StageLabel(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """A stage label: either neutral or gendered."""

    var is_gendered: Bool
    var label: String
    var masculine: String
    var feminine: String

    fn __init__(out self):
        self.is_gendered = False
        self.label = ""
        self.masculine = ""
        self.feminine = ""


fn stage_neutral(label: String) -> StageLabel:
    """Create a neutral (ungendered) stage label."""
    var sl = StageLabel()
    sl.is_gendered = False
    sl.label = label
    return sl


fn stage_gendered(m: String, f: String) -> StageLabel:
    """Create a gendered stage label."""
    var sl = StageLabel()
    sl.is_gendered = True
    sl.masculine = m
    sl.feminine = f
    return sl


struct CompactnessOverride(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Optional overrides for short/compact display modes."""

    var day: UnitForms
    var has_day: Bool
    var week: UnitForms
    var has_week: Bool
    var month: UnitForms
    var has_month: Bool
    var year: UnitForms
    var has_year: Bool
    var half: String
    var has_half: Bool
    var delimiter: String
    var has_delimiter: Bool
    var just_born: String
    var has_just_born: Bool

    fn __init__(out self):
        self.day = UnitForms()
        self.has_day = False
        self.week = UnitForms()
        self.has_week = False
        self.month = UnitForms()
        self.has_month = False
        self.year = UnitForms()
        self.has_year = False
        self.half = ""
        self.has_half = False
        self.delimiter = ""
        self.has_delimiter = False
        self.just_born = ""
        self.has_just_born = False

    fn get_unit(self, name: String, fallback: UnitForms) -> UnitForms:
        """Get override unit or fallback."""
        if name == "day" and self.has_day:
            return self.day
        if name == "week" and self.has_week:
            return self.week
        if name == "month" and self.has_month:
            return self.month
        if name == "year" and self.has_year:
            return self.year
        return fallback


alias PluralFn = fn (Int) -> String


struct AgeLocale(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale definition for age formatting."""

    var code: String
    var plural_fn: PluralFn
    var day: UnitForms
    var week: UnitForms
    var month: UnitForms
    var year: UnitForms
    var half: String
    var delimiter: String
    var just_born: String
    var newborn: StageLabel
    var infant: StageLabel
    var toddler: StageLabel
    var child: StageLabel
    var teenager: StageLabel
    var adult: StageLabel
    var short_override: CompactnessOverride
    var has_short: Bool
    var compact_override: CompactnessOverride
    var has_compact: Bool

    fn __init__(
        out self,
        code: String,
        plural_fn: PluralFn,
        day: UnitForms,
        week: UnitForms,
        month: UnitForms,
        year: UnitForms,
        half: String,
        delimiter: String,
        just_born: String,
        newborn: StageLabel,
        infant: StageLabel,
        toddler: StageLabel,
        child: StageLabel,
        teenager: StageLabel,
        adult: StageLabel,
        short_override: CompactnessOverride = CompactnessOverride(),
        has_short: Bool = False,
        compact_override: CompactnessOverride = CompactnessOverride(),
        has_compact: Bool = False,
    ):
        self.code = code
        self.plural_fn = plural_fn
        self.day = day
        self.week = week
        self.month = month
        self.year = year
        self.half = half
        self.delimiter = delimiter
        self.just_born = just_born
        self.newborn = newborn
        self.infant = infant
        self.toddler = toddler
        self.child = child
        self.teenager = teenager
        self.adult = adult
        self.short_override = short_override
        self.has_short = has_short
        self.compact_override = compact_override
        self.has_compact = has_compact


fn _str_contains(s: String, sub: String) -> Bool:
    """Check if a string contains a substring."""
    return s.find(sub) != -1


fn _str_replace(s: String, old: String, new: String) -> String:
    """Replace first occurrence of old with new in s."""
    var idx = s.find(old)
    if idx == -1:
        return s
    return s[:idx] + new + s[idx + len(old) :]


fn resolve_unit(
    count: Int,
    unit_forms: UnitForms,
    locale: AgeLocale,
    half: String = "",
) -> String:
    """Resolve a unit count to its display string using locale rules.

    The half template supports two placeholders:

    * {n} -- replaces the formatted number before unit substitution
    * {0} -- wraps the fully resolved expression after unit substitution
    """
    var base_n = String(count)
    var n: String
    if len(half) > 0 and _str_contains(half, "{n}"):
        n = _str_replace(half, "{n}", base_n)
    else:
        n = base_n

    var tmpl: String
    if unit_forms.is_simple:
        tmpl = unit_forms.template_str
    else:
        var cat = locale.plural_fn(count)
        tmpl = unit_forms.get_template(cat)

    var result = _str_replace(tmpl, "{n}", n)

    if len(half) > 0 and _str_contains(half, "{0}"):
        result = _str_replace(half, "{0}", result)

    return result


fn resolve_stage(label: StageLabel, gender: String = "") -> String:
    """Resolve a stage label, optionally selecting a gendered variant."""
    if not label.is_gendered:
        return label.label
    if gender == "f":
        return label.feminine
    return label.masculine
