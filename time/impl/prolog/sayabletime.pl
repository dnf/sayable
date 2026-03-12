%% sayabletime.pl — Human-friendly clock time formatting for SWI-Prolog.
%%
%% Public predicates:
%%   format_time(+Code, +Time, -Result)
%%   format_time(+Code, +Time, +Compactness, -Result)
%%   get_locale(+Code)
%%   version(-Version)

:- module(sayabletime, [
    format_time/3,
    format_time/4,
    get_locale/1,
    version/1
]).

:- use_module(library(lists)).

:- include('locales/registry').

version('0.5.0').

%% get_locale(+Code) — succeeds if Code is a known locale.
get_locale(Code) :-
    st_locale(Code).

%% format_time(+Code, +Time, -Result) — normal compactness.
format_time(Code, Time, Result) :-
    format_time(Code, Time, normal, Result).

%% format_time(+Code, +Time, +Compactness, -Result)
format_time(Code, Time, Compactness, Result) :-
    nonvar(Time), Time \== '',
    parse_time_input(Time, Hour, Minute),
    (Compactness \== normal, has_short_clock(Code, Compactness)
     -> format_digital(Code, Hour, Minute, Compactness, Result)
     ;  format_natural(Code, Hour, Minute, Result)
    ).

%% parse_time_input(+Input, -Hour, -Minute) — parse HH:MM or ISO datetime.
parse_time_input(Atom, Hour, Minute) :-
    atom_string(Atom, Str),
    % Strip ISO datetime prefix
    (sub_string(Str, _, _, _, "T")
     -> split_string(Str, "T", "", [_, TimePart0])
     ;  TimePart0 = Str
    ),
    % Strip timezone suffix
    (sub_string(TimePart0, Pos, _, _, "+")
     -> sub_string(TimePart0, 0, Pos, _, TimePart)
     ;  (sub_string(TimePart0, Pos2, _, _, "Z")
         -> sub_string(TimePart0, 0, Pos2, _, TimePart)
         ;  TimePart = TimePart0
        )
    ),
    split_string(TimePart, ":", "", Parts),
    length(Parts, PLen),
    PLen >= 2,
    nth0(0, Parts, HStr),
    nth0(1, Parts, MinStr0),
    % Strip fractional seconds from minutes if needed
    split_string(MinStr0, ".", "", MinParts),
    nth0(0, MinParts, MinStr),
    number_string(Hour, HStr),
    number_string(Minute, MinStr),
    Hour >= 0, Hour =< 23,
    Minute >= 0, Minute =< 59.

%% has_short_clock(+Code, +Compactness) — check if locale has digital clock config.
has_short_clock(Code, short) :-
    short_st_format(Code, _), !.
has_short_clock(Code, compact) :-
    compact_st_format(Code, _), !.

%% format_natural(+Code, +Hour, +Minute, -Result)
format_natural(Code, Hour, Minute, Result) :-
    round_to_5(Minute, Rounded0),
    (Rounded0 =:= 60
     -> Rounded = 0, H is (Hour + 1) mod 24
     ;  Rounded = Rounded0, H = Hour
    ),
    (Rounded =:= 0, H =:= 0
     -> st_midnight(Code, Result)
     ;  Rounded =:= 0, H =:= 12
     -> st_noon(Code, Result)
     ;  H12 is H mod 12,
        NextH12 is (H + 1) mod 12,
        st_hours(Code, Hours),
        nth0(H12, Hours, HName),
        nth0(NextH12, Hours, NextHName),
        st_pattern(Code, Rounded, Pattern),
        atom_string(Pattern, PatStr),
        atom_string(HName, HStr),
        atom_string(NextHName, NextHStr),
        string_replace(PatStr, "{h}", HStr, R1),
        string_replace(R1, "{next_h}", NextHStr, R2),
        atom_string(Result, R2)
    ).

%% format_digital(+Code, +Hour, +Minute, +Compactness, -Result)
format_digital(Code, Hour, Minute, short, Result) :-
    !,
    short_st_format(Code, FmtAtom),
    short_st_use24h(Code, Use24h),
    format_digital_impl(Code, Hour, Minute, FmtAtom, Use24h, short, Result).
format_digital(Code, Hour, Minute, compact, Result) :-
    compact_st_format(Code, FmtAtom),
    compact_st_use24h(Code, Use24h),
    format_digital_impl(Code, Hour, Minute, FmtAtom, Use24h, compact, Result).

%% format_digital_impl(+Code, +Hour, +Minute, +FmtAtom, +Use24h, +Compactness, -Result)
format_digital_impl(Code, Hour, Minute, FmtAtom, Use24h, Compactness, Result) :-
    atom_string(FmtAtom, Fmt),
    (Use24h == true
     -> number_string(Hour, HStr)
     ;  H12_0 is Hour mod 12,
        (H12_0 =:= 0 -> H12 = 12 ; H12 = H12_0),
        number_string(H12, HStr)
    ),
    % Zero-pad minutes
    number_string(Minute, MinRaw),
    (string_length(MinRaw, 1) -> string_concat("0", MinRaw, MinStr) ; MinStr = MinRaw),
    string_replace(Fmt, "{h}", HStr, R1),
    string_replace(R1, "{mm}", MinStr, R2),
    % AM/PM substitution
    (Use24h == true
     -> R3 = R2
     ;  get_ampm(Code, Hour, Compactness, AmPmStr),
        string_replace(R2, "{ampm}", AmPmStr, R3)
    ),
    atom_string(Result, R3).

%% get_ampm(+Code, +Hour, +Compactness, -AmPm)
get_ampm(Code, Hour, short, AmPm) :-
    (Hour < 12
     -> (short_st_am(Code, A) -> atom_string(A, AmPm) ; AmPm = "AM")
     ;  (short_st_pm(Code, P) -> atom_string(P, AmPm) ; AmPm = "PM")
    ).
get_ampm(Code, Hour, compact, AmPm) :-
    (Hour < 12
     -> (compact_st_am(Code, A) -> atom_string(A, AmPm) ; AmPm = "a")
     ;  (compact_st_pm(Code, P) -> atom_string(P, AmPm) ; AmPm = "p")
    ).

%% round_to_5(+Minute, -Rounded)
round_to_5(Minute, Rounded) :-
    Rounded is ((Minute + 2) // 5) * 5.

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
