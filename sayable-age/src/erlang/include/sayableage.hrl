-ifndef(SAYABLEAGE_HRL).
-define(SAYABLEAGE_HRL, true).

-define(VERSION, "0.5.0").

-type plural_category() :: zero | one | two | few | many | other.
-type compactness() :: normal | short | compact.
-type gender() :: male | female.
-type unit_forms() :: {simple, string()} | {pluralized, [{plural_category(), string()}]}.
-type stage_label() :: {neutral, string()} | {gendered, string(), string()}.
-type optional(T) :: nothing | {just, T}.

-record(compactness_override, {
    day    :: optional(unit_forms()),
    week   :: optional(unit_forms()),
    month  :: optional(unit_forms()),
    year   :: optional(unit_forms()),
    half   :: optional(string()),
    delimiter :: optional(string()),
    just_born :: optional(string())
}).

-record(stages, {
    newborn  :: stage_label(),
    infant   :: stage_label(),
    toddler  :: stage_label(),
    child    :: stage_label(),
    teenager :: stage_label(),
    adult    :: stage_label()
}).

-record(locale, {
    code      :: string(),
    plural    :: fun((non_neg_integer()) -> plural_category()),
    day       :: unit_forms(),
    week      :: unit_forms(),
    month     :: unit_forms(),
    year      :: unit_forms(),
    half      :: string(),
    delimiter :: string(),
    just_born :: string(),
    stages    :: #stages{},
    short     :: optional(#compactness_override{}),
    compact   :: optional(#compactness_override{})
}).

-endif.
