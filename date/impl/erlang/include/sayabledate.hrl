-ifndef(SAYABLEDATE_HRL).
-define(SAYABLEDATE_HRL, true).

-define(VERSION, "0.5.0").

-type compactness() :: normal | short | compact.
-type optional(T) :: nothing | {just, T}.

-record(date_compactness_override, {
    months               :: optional([string()]),
    months_in_date       :: optional([string()]),
    weekdays             :: optional([string()]),
    day_format           :: optional(string()),
    day_format_exceptions :: optional([{string(), string()}]),
    date_pattern         :: optional(string()),
    date_pattern_with_year :: optional(string()),
    today                :: optional(string()),
    tomorrow             :: optional(string()),
    yesterday            :: optional(string())
}).

-record(date_locale, {
    code                  :: string(),
    months                :: [string()],
    weekdays              :: [string()],
    day_format            :: string(),
    day_format_exceptions :: [{string(), string()}],
    date_pattern          :: string(),
    date_pattern_with_year :: string(),
    today                 :: string(),
    tomorrow              :: string(),
    yesterday             :: string(),
    day_after_tomorrow    :: optional(string()),
    day_before_yesterday  :: optional(string()),
    this_weekday          :: optional(string()),
    next_weekday          :: optional(string()),
    last_weekday          :: optional(string()),
    months_in_date        :: optional([string()]),
    short                 :: optional(#date_compactness_override{}),
    compact               :: optional(#date_compactness_override{})
}).

-endif.
