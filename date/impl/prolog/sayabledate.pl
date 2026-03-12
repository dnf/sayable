%% sayabledate.pl — Human-friendly date formatting for SWI-Prolog.
%%
%% Public predicates:
%%   format_date(+Code, +Date, -Result)
%%   format_date(+Code, +Date, +Compactness, -Result)
%%   format_date_with_year(+Code, +Date, -Result)
%%   format_date_with_year(+Code, +Date, +Compactness, -Result)
%%   format_relative(+Code, +Date, +AsOf, -Result)
%%   format_relative(+Code, +Date, +AsOf, +Compactness, -Result)
%%   get_locale(+Code)
%%   version(-Version)

:- module(sayabledate, [
    format_date/3,
    format_date/4,
    format_date_with_year/3,
    format_date_with_year/4,
    format_relative/4,
    format_relative/5,
    get_locale/1,
    version/1
]).

:- use_module(library(lists)).

:- include('locales/registry').

version('0.5.0').

%% get_locale(+Code) — succeeds if Code is a known locale.
get_locale(Code) :-
    sd_locale(Code).

%% format_date(+Code, +Date, -Result) — normal compactness.
format_date(Code, Date, Result) :-
    format_date(Code, Date, normal, Result).

%% format_date(+Code, +Date, +Compactness, -Result)
format_date(Code, Date, Compactness, Result) :-
    nonvar(Date), Date \== '',
    parse_date(Date, Y, M, D),
    format_absolute(Code, Y, M, D, false, Compactness, Result).

%% format_date_with_year(+Code, +Date, -Result) — normal compactness.
format_date_with_year(Code, Date, Result) :-
    format_date_with_year(Code, Date, normal, Result).

%% format_date_with_year(+Code, +Date, +Compactness, -Result)
format_date_with_year(Code, Date, Compactness, Result) :-
    nonvar(Date), Date \== '',
    parse_date(Date, Y, M, D),
    format_absolute(Code, Y, M, D, true, Compactness, Result).

%% format_relative(+Code, +Date, +AsOf, -Result) — normal compactness.
format_relative(Code, Date, AsOf, Result) :-
    format_relative(Code, Date, AsOf, normal, Result).

%% format_relative(+Code, +Date, +AsOf, +Compactness, -Result)
format_relative(Code, Date, AsOf, Compactness, Result) :-
    nonvar(Date), Date \== '',
    nonvar(AsOf), AsOf \== '',
    parse_date(Date, DY, DM, DD),
    parse_date(AsOf, AY, AM, AD),
    julian_day(DY, DM, DD, DateJDN),
    julian_day(AY, AM, AD, AsOfJDN),
    Diff is DateJDN - AsOfJDN,
    format_relative_diff(Code, Diff, DY, DM, DD, AY, Compactness, Result).

%% parse_date(+Atom, -Y, -M, -D) — parse YYYY-MM-DD or ISO datetime.
parse_date(Atom, Y, M, D) :-
    atom_string(Atom, FullStr),
    % Strip time part if present (ISO datetime)
    (sub_string(FullStr, Before, _, _, "T")
     -> sub_string(FullStr, 0, Before, _, Str)
     ;  Str = FullStr
    ),
    string_length(Str, Len),
    Len >= 10,
    sub_string(Str, 0, 4, _, YStr),
    sub_string(Str, 5, 2, _, MStr),
    sub_string(Str, 8, 2, _, DStr),
    number_string(Y, YStr),
    number_string(M, MStr),
    number_string(D, DStr),
    M >= 1, M =< 12,
    D >= 1, D =< 31.

%% julian_day(+Y, +M, +D, -JD)
julian_day(Y, M, D, JD) :-
    A is (14 - M) // 12,
    Y1 is Y + 4800 - A,
    M1 is M + 12 * A - 3,
    JD is D + (153 * M1 + 2) // 5 + 365 * Y1 + Y1 // 4 - Y1 // 100 + Y1 // 400 - 32045.

%% weekday(+Y, +M, +D, -DOW) — 0=Sunday, 1=Monday, ..., 6=Saturday.
weekday(Y, M, D, DOW) :-
    julian_day(Y, M, D, JDN),
    DOW is (JDN + 1) mod 7.

%% format_relative_diff(+Code, +Diff, +DY, +DM, +DD, +AY, +Compactness, -Result)
format_relative_diff(Code, 0, _DY, _DM, _DD, _AY, Compactness, Result) :-
    !, effective_today(Code, Compactness, Result).

format_relative_diff(Code, 1, _DY, _DM, _DD, _AY, Compactness, Result) :-
    !, effective_tomorrow(Code, Compactness, Result).

format_relative_diff(Code, -1, _DY, _DM, _DD, _AY, Compactness, Result) :-
    !, effective_yesterday(Code, Compactness, Result).

format_relative_diff(Code, 2, _DY, _DM, _DD, _AY, Compactness, Result) :-
    Compactness \== compact,
    sd_day_after_tomorrow(Code, Val), !,
    Result = Val.
format_relative_diff(Code, 2, DY, DM, DD, AY, compact, Result) :-
    !, (DY =\= AY -> IncludeYear = true ; IncludeYear = false),
    format_absolute(Code, DY, DM, DD, IncludeYear, compact, Result).

format_relative_diff(Code, -2, _DY, _DM, _DD, _AY, Compactness, Result) :-
    Compactness \== compact,
    sd_day_before_yesterday(Code, Val), !,
    Result = Val.
format_relative_diff(Code, -2, DY, DM, DD, AY, compact, Result) :-
    !, (DY =\= AY -> IncludeYear = true ; IncludeYear = false),
    format_absolute(Code, DY, DM, DD, IncludeYear, compact, Result).

% Compact mode: skip weekday references, go straight to calendar date
format_relative_diff(Code, _Diff, DY, DM, DD, AY, compact, Result) :-
    !,
    (DY =\= AY -> IncludeYear = true ; IncludeYear = false),
    format_absolute(Code, DY, DM, DD, IncludeYear, compact, Result).

% This weekday (+2 to +6)
format_relative_diff(Code, Diff, DY, DM, DD, _AY, Compactness, Result) :-
    Diff >= 2, Diff =< 6,
    sd_this_weekday(Code, Pattern), !,
    weekday(DY, DM, DD, DOW),
    effective_weekdays(Code, Compactness, Weekdays),
    nth0(DOW, Weekdays, WeekdayName),
    atom_string(Pattern, PatStr),
    atom_string(WeekdayName, WDStr),
    string_replace(PatStr, "{weekday}", WDStr, ResStr),
    atom_string(Result, ResStr).

% Last weekday (-2 to -6)
format_relative_diff(Code, Diff, DY, DM, DD, _AY, Compactness, Result) :-
    Diff >= -6, Diff =< -2,
    sd_last_weekday(Code, Pattern), !,
    weekday(DY, DM, DD, DOW),
    effective_weekdays(Code, Compactness, Weekdays),
    nth0(DOW, Weekdays, WeekdayName),
    atom_string(Pattern, PatStr),
    atom_string(WeekdayName, WDStr),
    string_replace(PatStr, "{weekday}", WDStr, ResStr),
    atom_string(Result, ResStr).

% Next weekday (+7 to +13)
format_relative_diff(Code, Diff, DY, DM, DD, _AY, Compactness, Result) :-
    Diff >= 7, Diff =< 13,
    sd_next_weekday(Code, Pattern), !,
    weekday(DY, DM, DD, DOW),
    effective_weekdays(Code, Compactness, Weekdays),
    nth0(DOW, Weekdays, WeekdayName),
    atom_string(Pattern, PatStr),
    atom_string(WeekdayName, WDStr),
    string_replace(PatStr, "{weekday}", WDStr, ResStr),
    atom_string(Result, ResStr).

% Calendar fallback
format_relative_diff(Code, _Diff, DY, DM, DD, AY, Compactness, Result) :-
    (DY =\= AY -> IncludeYear = true ; IncludeYear = false),
    format_absolute(Code, DY, DM, DD, IncludeYear, Compactness, Result).

%% format_absolute(+Code, +Y, +M, +D, +IncludeYear, +Compactness, -Result)
format_absolute(Code, Y, M, D, IncludeYear, Compactness, Result) :-
    % Format day with ordinal
    number_string(D, DStr),
    effective_day_format(Code, DStr, Compactness, DayFmt),
    string_replace(DayFmt, "{n}", DStr, FormattedDay),
    % Pick month name (genitive form if available)
    effective_months_in_date(Code, Compactness, MonthNames),
    MIdx is M - 1,
    nth0(MIdx, MonthNames, MonthAtom),
    atom_string(MonthAtom, MonthName),
    % Pick pattern
    effective_date_pattern(Code, IncludeYear, Compactness, Pattern),
    % Replace placeholders
    string_replace(Pattern, "{month}", MonthName, R1),
    string_replace(R1, "{day}", FormattedDay, R2),
    number_string(D, DNumStr),
    string_replace(R2, "{d}", DNumStr, R3),
    number_string(M, MNumStr),
    string_replace(R3, "{m}", MNumStr, R4),
    (IncludeYear == true
     -> number_string(Y, YStr),
        string_replace(R4, "{year}", YStr, R5),
        YY is Y mod 100,
        number_string(YY, YYRaw),
        (string_length(YYRaw, 1) -> string_concat("0", YYRaw, YYStr) ; YYStr = YYRaw),
        string_replace(R5, "{yy}", YYStr, R6)
     ;  R6 = R4
    ),
    atom_string(Result, R6).

%% effective_day_format(+Code, +DayStr, +Compactness, -Fmt)
effective_day_format(Code, DayStr, short, Fmt) :-
    (short_sd_clear_exceptions(Code)
     -> (short_sd_day_format(Code, F) -> atom_string(F, Fmt) ; sd_day_format(Code, F), atom_string(F, Fmt))
     ;  (short_sd_day_format_exception(Code, DayStr, F)
         -> atom_string(F, Fmt)
         ;  (short_sd_day_format(Code, F)
             -> atom_string(F, Fmt)
             ;  effective_day_format(Code, DayStr, normal, Fmt)
            )
        )
    ), !.
effective_day_format(Code, DayStr, compact, Fmt) :-
    effective_day_format(Code, DayStr, normal, Fmt), !.
effective_day_format(Code, DayStr, normal, Fmt) :-
    atom_string(DayAtom, DayStr),
    (sd_day_format_exception(Code, DayAtom, F)
     -> atom_string(F, Fmt)
     ;  sd_day_format(Code, F), atom_string(F, Fmt)
    ).

%% effective_months_in_date(+Code, +Compactness, -Months)
effective_months_in_date(Code, short, Months) :-
    (short_sd_months(Code, M) -> Months = M ; effective_months_in_date(Code, normal, Months)), !.
effective_months_in_date(Code, compact, Months) :-
    effective_months_in_date(Code, normal, Months), !.
effective_months_in_date(Code, normal, Months) :-
    (sd_months_in_date(Code, M) -> Months = M ; sd_months(Code, Months)).

%% effective_weekdays(+Code, +Compactness, -Weekdays)
effective_weekdays(Code, short, WD) :-
    (short_sd_weekdays(Code, W) -> WD = W ; sd_weekdays(Code, WD)), !.
effective_weekdays(Code, _, WD) :-
    sd_weekdays(Code, WD).

%% effective_date_pattern(+Code, +IncludeYear, +Compactness, -Pattern)
effective_date_pattern(Code, true, short, Pattern) :-
    (short_sd_date_pattern_with_year(Code, P) -> atom_string(P, Pattern) ; sd_date_pattern_with_year(Code, P), atom_string(P, Pattern)), !.
effective_date_pattern(Code, false, short, Pattern) :-
    (short_sd_date_pattern(Code, P) -> atom_string(P, Pattern) ; sd_date_pattern(Code, P), atom_string(P, Pattern)), !.
effective_date_pattern(Code, true, compact, Pattern) :-
    (compact_sd_date_pattern_with_year(Code, P) -> atom_string(P, Pattern) ; sd_date_pattern_with_year(Code, P), atom_string(P, Pattern)), !.
effective_date_pattern(Code, false, compact, Pattern) :-
    (compact_sd_date_pattern(Code, P) -> atom_string(P, Pattern) ; sd_date_pattern(Code, P), atom_string(P, Pattern)), !.
effective_date_pattern(Code, true, normal, Pattern) :-
    sd_date_pattern_with_year(Code, P), atom_string(P, Pattern).
effective_date_pattern(Code, false, normal, Pattern) :-
    sd_date_pattern(Code, P), atom_string(P, Pattern).

%% effective_today(+Code, +Compactness, -Val)
effective_today(Code, _, Val) :-
    sd_today(Code, Val).

%% effective_tomorrow(+Code, +Compactness, -Val)
effective_tomorrow(Code, _, Val) :-
    sd_tomorrow(Code, Val).

%% effective_yesterday(+Code, +Compactness, -Val)
effective_yesterday(Code, _, Val) :-
    sd_yesterday(Code, Val).

%% string_replace(+Input, +Search, +Replace, -Output)
string_replace(Input, Search, Replace, Output) :-
    (sub_string(Input, Before, _, _, Search)
     -> string_length(Search, SLen),
        sub_string(Input, 0, Before, _, Prefix),
        After is Before + SLen,
        string_length(Input, ILen),
        RemLen is ILen - After,
        sub_string(Input, After, RemLen, _, Suffix),
        string_concat(Prefix, Replace, Tmp),
        string_concat(Tmp, Suffix, Output)
     ;  Output = Input
    ).
