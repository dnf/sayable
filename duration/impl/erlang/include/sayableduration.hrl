-ifndef(SAYABLEDURATION_HRL).
-define(SAYABLEDURATION_HRL, true).

-define(VERSION, "0.5.0").

-type plural_category() :: zero | one | two | few | many | other.
-type compactness() :: normal | short | compact.
-type unit_forms() :: {simple, string()} | {pluralized, [{plural_category(), string()}]}.
-type optional(T) :: nothing | {just, T}.

-record(duration_compactness_override, {
    second    :: optional(unit_forms()),
    minute    :: optional(unit_forms()),
    hour      :: optional(unit_forms()),
    day       :: optional(unit_forms()),
    week      :: optional(unit_forms()),
    month     :: optional(unit_forms()),
    year      :: optional(unit_forms()),
    half      :: optional(string()),
    delimiter :: optional(string()),
    ago       :: optional(string()),
    in_future :: optional(string())
}).

-record(duration_locale, {
    code      :: string(),
    plural    :: fun((non_neg_integer()) -> plural_category()),
    second    :: unit_forms(),
    minute    :: unit_forms(),
    hour      :: unit_forms(),
    day       :: unit_forms(),
    week      :: unit_forms(),
    month     :: unit_forms(),
    year      :: unit_forms(),
    half      :: string(),
    delimiter :: string(),
    just_now  :: string(),
    ago       :: string(),
    in_future :: string(),
    short     :: optional(#duration_compactness_override{}),
    compact   :: optional(#duration_compactness_override{})
}).

-endif.
