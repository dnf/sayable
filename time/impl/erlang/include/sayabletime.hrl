-ifndef(SAYABLETIME_HRL).
-define(SAYABLETIME_HRL, true).

-define(VERSION, "0.5.0").

-type compactness() :: normal | short | compact.
-type optional(T) :: nothing | {just, T}.

-record(clock_config, {
    hours    :: [string()],
    midnight :: string(),
    noon     :: string(),
    patterns :: [{integer(), string()}]
}).

-record(short_clock_config, {
    use24h :: boolean(),
    format :: string(),
    am_pm  :: optional({string(), string()})
}).

-record(time_compactness_override, {
    clock :: optional(#short_clock_config{})
}).

-record(time_locale, {
    code    :: string(),
    clock   :: #clock_config{},
    short   :: optional(#time_compactness_override{}),
    compact :: optional(#time_compactness_override{})
}).

-endif.
