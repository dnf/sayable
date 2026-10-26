%% sayableduration.pl — Human-friendly duration formatting for SWI-Prolog.
%%
%% Public predicates:
%%   format_duration(+Code, +Seconds, -Result)
%%   format_duration(+Code, +Seconds, +Compactness, -Result)
%%   format_duration_ts(+Code, +Start, +End, -Result)
%%   format_duration_ts(+Code, +Start, +End, +Compactness, -Result)
%%   format_since(+Code, +Start, +AsOf, -Result)
%%   format_since(+Code, +Start, +AsOf, +Compactness, -Result)
%%   format_until(+Code, +Target, +AsOf, -Result)
%%   format_until(+Code, +Target, +AsOf, +Compactness, -Result)
%%   get_locale(+Code)
%%   version(-Version)

:- module(sayableduration, [
    format_duration/3,
    format_duration/4,
    format_duration_ts/4,
    format_duration_ts/5,
    format_since/4,
    format_since/5,
    format_until/4,
    format_until/5,
    get_locale/1,
    version/1
]).

:- use_module(library(lists)).

:- include('locales/registry').

version('0.5.0').

%% The 500-year ceiling (6000 months), the same as sayable-age.
max_duration_months(6000).

%% get_locale(+Code) — succeeds if Code is a known locale.
get_locale(Code) :-
    sd_locale(Code).

%% format_duration(+Code, +Seconds, -Result) — normal compactness.
format_duration(Code, Seconds, Result) :-
    format_duration(Code, Seconds, normal, Result).

%% format_duration(+Code, +Seconds, +Compactness, -Result)
format_duration(Code, Seconds, Compactness, Result) :-
    integer(Seconds),
    Seconds >= 0,
    format_duration_secs(Code, Seconds, Compactness, Result).

%% format_duration_ts(+Code, +Start, +End, -Result) — normal compactness.
format_duration_ts(Code, Start, End, Result) :-
    format_duration_ts(Code, Start, End, normal, Result).

%% format_duration_ts(+Code, +Start, +End, +Compactness, -Result)
format_duration_ts(Code, Start, End, Compactness, Result) :-
    nonvar(Start), Start \== '',
    nonvar(End), End \== '',
    parse_iso_to_seconds(Start, S),
    parse_iso_to_seconds(End, E),
    Diff is abs(E - S),
    format_duration_secs(Code, Diff, Compactness, Result).

%% format_since(+Code, +Start, +AsOf, -Result) — normal compactness.
format_since(Code, Start, AsOf, Result) :-
    format_since(Code, Start, AsOf, normal, Result).

%% format_since(+Code, +Start, +AsOf, +Compactness, -Result)
format_since(Code, Start, AsOf, Compactness, Result) :-
    nonvar(Start), Start \== '',
    nonvar(AsOf), AsOf \== '',
    parse_iso_to_seconds(Start, S),
    parse_iso_to_seconds(AsOf, A),
    Diff is A - S,
    Diff >= 0,
    (Diff =:= 0
     -> effective_just_now(Code, Compactness, Result)
     ;  format_duration_secs(Code, Diff, Compactness, DurStr),
        effective_ago(Code, Compactness, AgoTemplate),
        atom_string(DurStr, DurS),
        atom_string(AgoTemplate, AgoS),
        string_replace(AgoS, "{0}", DurS, ResS),
        atom_string(Result, ResS)
    ).

%% format_until(+Code, +Target, +AsOf, -Result) — normal compactness.
format_until(Code, Target, AsOf, Result) :-
    format_until(Code, Target, AsOf, normal, Result).

%% format_until(+Code, +Target, +AsOf, +Compactness, -Result)
format_until(Code, Target, AsOf, Compactness, Result) :-
    nonvar(Target), Target \== '',
    nonvar(AsOf), AsOf \== '',
    parse_iso_to_seconds(Target, T),
    parse_iso_to_seconds(AsOf, A),
    Diff is T - A,
    Diff >= 0,
    (Diff =:= 0
     -> effective_just_now(Code, Compactness, Result)
     ;  format_duration_secs(Code, Diff, Compactness, DurStr),
        effective_in_future(Code, Compactness, FutTemplate),
        atom_string(DurStr, DurS),
        atom_string(FutTemplate, FutS),
        string_replace(FutS, "{0}", DurS, ResS),
        atom_string(Result, ResS)
    ).

%% parse_iso_to_seconds(+ISOStr, -Seconds)
%% Parses YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (the
%% zone is accepted but not applied; docs/input-formats.md). Fails if the
%% timestamp is malformed or names an impossible date or time.
parse_iso_to_seconds(Atom, Seconds) :-
    atomic(Atom),
    atom_codes(Atom, Codes),
    phrase(timestamp(Y, Mo, D, H, Min, Sec), Codes),
    !,
    days_since_epoch(Y, Mo, D, Days),
    Seconds is Days * 86400 + H * 3600 + Min * 60 + Sec.

timestamp(Y, Mo, D, H, Min, Sec) -->
    fixed_digits(4, Y), "-", fixed_digits(2, Mo), "-", fixed_digits(2, D),
    { real_calendar_day(Y, Mo, D) },
    "T", clock_hour(H), ":", fixed_digits(2, Min), optional_seconds(Sec),
    optional_zone,
    { H =< 23, Min =< 59, Sec =< 59 }.

clock_hour(H) --> fixed_digits(2, H).
clock_hour(H) --> fixed_digits(1, H).

optional_seconds(Sec) --> ":", fixed_digits(2, Sec), optional_fraction.
optional_seconds(0) --> [].

optional_fraction --> ".", ascii_digits_1(_).
optional_fraction --> [].

optional_zone --> "Z".
optional_zone --> [Sign], { memberchk(Sign, `+-`) },
    fixed_digits(2, _), ":", fixed_digits(2, _).
optional_zone --> [].

%% fixed_digits(+Count, -Value)// — exactly Count ASCII digits.
fixed_digits(Count, Value) -->
    ascii_digits(Count, Codes),
    { number_codes(Value, Codes) }.

ascii_digits(0, []) --> !, [].
ascii_digits(Count, [C|Cs]) -->
    ascii_digit(C),
    { Rest is Count - 1 },
    ascii_digits(Rest, Cs).

%% ascii_digits_1(-Codes)// — one or more ASCII digits.
ascii_digits_1([C|Cs]) --> ascii_digit(C), ascii_digits_1(Cs).
ascii_digits_1([C]) --> ascii_digit(C).

ascii_digit(C) --> [C], { C >= 0'0, C =< 0'9 }.

real_calendar_day(Y, M, D) :-
    M >= 1, M =< 12,
    days_in_month(Y, M, LastDay),
    D >= 1, D =< LastDay.

%% days_since_epoch(+Y, +M, +D, -Days) — days since 2000-01-01.
days_since_epoch(Y, M, D, Days) :-
    days_from_years(2000, Y, YDays),
    days_from_months(Y, 1, M, MDays),
    Days is YDays + MDays + D - 1.

days_from_years(From, To, Days) :-
    (From =:= To
     -> Days = 0
     ;  From < To
     -> (is_leap_year(From) -> YD = 366 ; YD = 365),
        Next is From + 1,
        days_from_years(Next, To, Rest),
        Days is YD + Rest
     ;  % From > To
        Prev is From - 1,
        (is_leap_year(Prev) -> YD = 366 ; YD = 365),
        days_from_years(Prev, To, Rest),
        Days is Rest - YD
    ).

days_from_months(_, M, M, 0) :- !.
days_from_months(Y, From, To, Days) :-
    From < To,
    days_in_month(Y, From, DIM),
    Next is From + 1,
    days_from_months(Y, Next, To, Rest),
    Days is DIM + Rest.

is_leap_year(Y) :-
    (Y mod 4 =:= 0, Y mod 100 =\= 0 ; Y mod 400 =:= 0).

days_in_month(_, M, 31) :- member(M, [1, 3, 5, 7, 8, 10, 12]), !.
days_in_month(_, M, 30) :- member(M, [4, 6, 9, 11]), !.
days_in_month(Y, 2, D) :- (is_leap_year(Y) -> D = 29 ; D = 28).

%% format_duration_secs(+Code, +Total, +Compactness, -Result)
format_duration_secs(Code, 0, Compactness, Result) :-
    !, effective_just_now(Code, Compactness, Result).

format_duration_secs(Code, Total, Compactness, Result) :-
    Total > 0, Total < 60, !,
    resolve_unit(Code, Total, second, "", Compactness, Result).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalMin is Total // 60,
    RemSec is Total mod 60,
    TotalMin < 5, !,
    resolve_unit(Code, TotalMin, minute, "", Compactness, MinStr),
    (RemSec > 0
     -> resolve_unit(Code, RemSec, second, "", Compactness, SecStr),
        effective_delimiter(Code, Compactness, Delim),
        atom_concat(MinStr, Delim, Tmp),
        atom_concat(Tmp, SecStr, Result)
     ;  Result = MinStr
    ).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalMin is Total // 60,
    TotalMin >= 5, TotalMin < 60, !,
    resolve_unit(Code, TotalMin, minute, "", Compactness, Result).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalHrs is Total // 3600,
    RemMin is (Total mod 3600) // 60,
    TotalHrs >= 1, TotalHrs =< 5, !,
    (RemMin =:= 30
     -> effective_half(Code, Compactness, Half),
        resolve_unit(Code, TotalHrs, hour, Half, Compactness, Result)
     ;  resolve_unit(Code, TotalHrs, hour, "", Compactness, HrStr),
        (RemMin > 0
         -> resolve_unit(Code, RemMin, minute, "", Compactness, MinStr),
            effective_delimiter(Code, Compactness, Delim),
            atom_concat(HrStr, Delim, Tmp),
            atom_concat(Tmp, MinStr, Result)
         ;  Result = HrStr
        )
    ).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalHrs is Total // 3600,
    TotalHrs >= 6, TotalHrs < 24, !,
    resolve_unit(Code, TotalHrs, hour, "", Compactness, Result).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalDays is Total // 86400,
    RemHrs is (Total mod 86400) // 3600,
    TotalDays >= 1, TotalDays =< 2, !,
    (RemHrs =:= 12
     -> effective_half(Code, Compactness, Half),
        resolve_unit(Code, TotalDays, day, Half, Compactness, Result)
     ;  resolve_unit(Code, TotalDays, day, "", Compactness, DayStr),
        (RemHrs > 0
         -> resolve_unit(Code, RemHrs, hour, "", Compactness, HrStr),
            effective_delimiter(Code, Compactness, Delim),
            atom_concat(DayStr, Delim, Tmp),
            atom_concat(Tmp, HrStr, Result)
         ;  Result = DayStr
        )
    ).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalDays is Total // 86400,
    TotalDays >= 3, TotalDays < 7, !,
    resolve_unit(Code, TotalDays, day, "", Compactness, Result).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalDays is Total // 86400,
    TotalDays >= 7, TotalDays < 30, !,
    Weeks is TotalDays // 7,
    RemDays is TotalDays mod 7,
    resolve_unit(Code, Weeks, week, "", Compactness, WeekStr),
    (RemDays > 0
     -> resolve_unit(Code, RemDays, day, "", Compactness, DayStr),
        effective_delimiter(Code, Compactness, Delim),
        atom_concat(WeekStr, Delim, Tmp),
        atom_concat(Tmp, DayStr, Result)
     ;  Result = WeekStr
    ).

format_duration_secs(Code, Total, Compactness, Result) :-
    TotalDays is Total // 86400,
    TotalDays >= 30, !,
    TotalMonths0 is round(TotalDays / 30.44),
    max_duration_months(MaxMonths),
    TotalMonths0 =< MaxMonths,
    (TotalMonths0 < 12
     -> (TotalMonths0 =:= 0 -> TotalMonths = 1 ; TotalMonths = TotalMonths0),
        resolve_unit(Code, TotalMonths, month, "", Compactness, Result)
     ;  TotalYears is TotalMonths0 // 12,
        RemMonths is TotalMonths0 mod 12,
        resolve_unit(Code, TotalYears, year, "", Compactness, YearStr),
        (RemMonths > 0
         -> resolve_unit(Code, RemMonths, month, "", Compactness, MonthStr),
            effective_delimiter(Code, Compactness, Delim),
            atom_concat(YearStr, Delim, Tmp),
            atom_concat(Tmp, MonthStr, Result)
         ;  Result = YearStr
        )
    ).

%% resolve_unit(+Code, +Count, +UnitName, +Half, +Compactness, -Result)
resolve_unit(Code, Count, UnitName, Half, Compactness, Result) :-
    number_string(Count, CountStr),
    atom_string(BaseN, CountStr),
    apply_n_half(BaseN, Half, N),
    select_template(Code, Count, UnitName, Half, Compactness, Template),
    replace_n(Template, N, Substituted),
    apply_zero_half(Substituted, Half, Result).

%% apply_n_half(+BaseN, +Half, -N)
apply_n_half(BaseN, Half, N) :-
    (Half \== "", atom_string(Half, HalfStr), sub_string(HalfStr, _, _, _, "{n}")
     -> atom_string(BaseN, BaseNStr),
        string_replace(HalfStr, "{n}", BaseNStr, NStr),
        atom_string(N, NStr)
     ;  N = BaseN
    ).

%% apply_zero_half(+Substituted, +Half, -Result)
apply_zero_half(Substituted, Half, Result) :-
    (Half \== "", atom_string(Half, HalfStr), sub_string(HalfStr, _, _, _, "{0}")
     -> atom_string(Substituted, SubStr),
        string_replace(HalfStr, "{0}", SubStr, ResStr),
        atom_string(Result, ResStr)
     ;  Result = Substituted
    ).

%% select_template(+Code, +Count, +UnitName, +Half, +Compactness, -Template)
select_template(Code, Count, UnitName, Half, Compactness, Template) :-
    % Half-marked values use "other" category
    (Half \== ""
     -> Cat = other
     ;  sd_plural(Code, Count, Cat)
    ),
    (select_template_for_mode(Code, UnitName, Cat, Compactness, Template)
     -> true
     ;  select_template_for_mode(Code, UnitName, other, Compactness, Template)
    ).

%% select_template_for_mode(+Code, +UnitName, +Cat, +Compactness, -Template)
select_template_for_mode(Code, UnitName, Cat, short, Template) :-
    short_sd_unit(Code, UnitName, Cat, Template), !.
select_template_for_mode(Code, UnitName, Cat, short, Template) :-
    sd_unit(Code, UnitName, Cat, Template).
select_template_for_mode(Code, UnitName, Cat, compact, Template) :-
    compact_sd_unit(Code, UnitName, Cat, Template), !.
select_template_for_mode(Code, UnitName, Cat, compact, Template) :-
    sd_unit(Code, UnitName, Cat, Template).
select_template_for_mode(Code, UnitName, Cat, normal, Template) :-
    sd_unit(Code, UnitName, Cat, Template).

%% replace_n(+Template, +N, -Result)
replace_n(Template, N, Result) :-
    atom_string(Template, TStr),
    atom_string(N, NStr),
    string_replace(TStr, "{n}", NStr, ResStr),
    atom_string(Result, ResStr).

%% effective_delimiter(+Code, +Compactness, -Delim)
effective_delimiter(Code, short, Delim) :-
    (short_sd_delimiter(Code, Delim) -> true ; sd_delimiter(Code, Delim)), !.
effective_delimiter(Code, compact, Delim) :-
    (compact_sd_delimiter(Code, Delim) -> true ; sd_delimiter(Code, Delim)), !.
effective_delimiter(Code, normal, Delim) :-
    sd_delimiter(Code, Delim).

%% effective_half(+Code, +Compactness, -Half)
effective_half(Code, short, Half) :-
    (short_sd_half(Code, Half) -> true ; sd_half(Code, Half)), !.
effective_half(Code, compact, Half) :-
    (compact_sd_half(Code, Half) -> true ; sd_half(Code, Half)), !.
effective_half(Code, normal, Half) :-
    sd_half(Code, Half).

%% effective_just_now(+Code, +Compactness, -JN)
effective_just_now(Code, _, JN) :-
    sd_just_now(Code, JN).

%% effective_ago(+Code, +Compactness, -Ago)
effective_ago(Code, short, Ago) :-
    (short_sd_ago(Code, Ago) -> true ; sd_ago(Code, Ago)), !.
effective_ago(Code, compact, Ago) :-
    (compact_sd_ago(Code, Ago) -> true ; sd_ago(Code, Ago)), !.
effective_ago(Code, normal, Ago) :-
    sd_ago(Code, Ago).

%% effective_in_future(+Code, +Compactness, -InF)
effective_in_future(Code, short, InF) :-
    (short_sd_in_future(Code, InF) -> true ; sd_in_future(Code, InF)), !.
effective_in_future(Code, compact, InF) :-
    (compact_sd_in_future(Code, InF) -> true ; sd_in_future(Code, InF)), !.
effective_in_future(Code, normal, InF) :-
    sd_in_future(Code, InF).

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
