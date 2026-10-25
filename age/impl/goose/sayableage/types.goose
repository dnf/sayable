// sayable-age Goose implementation — types.

namespace sayableage;

enum PluralCategory { Zero, One, Two, Few, Many, Other }

enum Compactness { Normal, Short, Compact }

// A unit's templates. A simple unit has one template for every count
// (stored in `other`); a plural unit has one template per category, and
// an empty template means the category is absent and falls back to other.
struct UnitForms {
    simple: bool = false,
    zero: const u8[:] = "",
    one: const u8[:] = "",
    two: const u8[:] = "",
    few: const u8[:] = "",
    many: const u8[:] = "",
    other: const u8[:] = "",
}

struct UnitSet {
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
}

// `f` is the feminine form, empty when the stage is not gendered.
struct StageLabel {
    label: const u8[:],
    f: const u8[:] = "",
}

struct Stages {
    newborn: StageLabel,
    infant: StageLabel,
    toddler: StageLabel,
    child: StageLabel,
    teenager: StageLabel,
    adult: StageLabel,
}

// A short or compact override. Every field is optional; the has_* flags
// keep "absent" distinct from "empty", since a compact delimiter of ""
// is a real override.
struct CompactnessOverride {
    has_day: bool = false,
    day: UnitForms = UnitForms { .. },
    has_week: bool = false,
    week: UnitForms = UnitForms { .. },
    has_month: bool = false,
    month: UnitForms = UnitForms { .. },
    has_year: bool = false,
    year: UnitForms = UnitForms { .. },
    has_half: bool = false,
    half: const u8[:] = "",
    has_delimiter: bool = false,
    delimiter: const u8[:] = "",
    has_just_born: bool = false,
    just_born: const u8[:] = "",
}

struct Locale {
    code: const u8[:],
    plural: PluralRule,
    units: UnitSet,
    half: const u8[:],
    delimiter: const u8[:],
    just_born: const u8[:],
    stages: Stages,
    short_override: CompactnessOverride = CompactnessOverride { .. },
    compact_override: CompactnessOverride = CompactnessOverride { .. },
}

fn resolve_forms(uf: const UnitForms&, cat: PluralCategory) -> const u8[:] {
    if uf.simple { return uf.other; }
    let chosen = match cat {
        Zero => uf.zero,
        One => uf.one,
        Two => uf.two,
        Few => uf.few,
        Many => uf.many,
        Other => uf.other,
    };
    if chosen.len == 0 { return uf.other; }
    return chosen;
}
