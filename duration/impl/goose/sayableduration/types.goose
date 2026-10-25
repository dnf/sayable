// sayable-duration Goose implementation — types.

namespace sayableduration;

enum PluralCategory { Zero, One, Two, Few, Many, Other }

enum Compactness { Normal, Short, Compact }

// A unit's templates, one per plural category. An empty template means
// the category is absent and falls back to `other`, so a unit with a
// single template for every count stores just `other`. A unit whose
// `other` is empty is absent altogether (see CompactnessOverride).
struct UnitForms {
    zero: const u8[:] = "",
    one: const u8[:] = "",
    two: const u8[:] = "",
    few: const u8[:] = "",
    many: const u8[:] = "",
    other: const u8[:] = "",
}

struct UnitSet {
    second: UnitForms = UnitForms { .. },
    minute: UnitForms = UnitForms { .. },
    hour: UnitForms = UnitForms { .. },
    day: UnitForms = UnitForms { .. },
    week: UnitForms = UnitForms { .. },
    month: UnitForms = UnitForms { .. },
    year: UnitForms = UnitForms { .. },
}

// A short or compact override. Every field is optional: an absent unit
// has an empty `other`, and the has_* flags keep an absent string
// distinct from an empty one, since a compact delimiter of "" is a real
// override.
struct CompactnessOverride {
    units: UnitSet = UnitSet { .. },
    has_half: bool = false,
    half: const u8[:] = "",
    has_delimiter: bool = false,
    delimiter: const u8[:] = "",
    has_ago: bool = false,
    ago: const u8[:] = "",
    has_in_future: bool = false,
    in_future: const u8[:] = "",
}

struct Locale {
    code: const u8[:],
    plural: PluralRule,
    units: UnitSet,
    half: const u8[:],
    delimiter: const u8[:],
    just_now: const u8[:],
    ago: const u8[:],
    in_future: const u8[:],
    short_override: CompactnessOverride = CompactnessOverride { .. },
    compact_override: CompactnessOverride = CompactnessOverride { .. },
}

fn resolve_forms(uf: const UnitForms&, cat: PluralCategory) -> const u8[:] {
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
