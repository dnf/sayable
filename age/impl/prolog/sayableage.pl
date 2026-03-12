%% sayableage.pl — Human-friendly age formatting for SWI-Prolog.
%%
%% Public predicates:
%%   format_age(+Code, +Dob, +AsOf, -Result)
%%   format_age(+Code, +Dob, +AsOf, +Compactness, -Result)
%%   format_stage(+Code, +Dob, +AsOf, +Gender, -Result)
%%   get_locale(+Code)
%%   version(-Version)

:- module(sayableage, [
    format_age/4,
    format_age/5,
    format_stage/4,
    format_stage/5,
    get_locale/1,
    version/1
]).

:- use_module(library(lists)).

:- include('locales/registry').

version('0.5.0').

%% Maximum age in months (500 years).
max_age_months(6000).

%% get_locale(+Code) — succeeds if Code is a known locale.
get_locale(Code) :-
    sa_locale(Code).

%% format_age(+Code, +Dob, +AsOf, -Result)
%% Format an age string using normal compactness.
format_age(Code, Dob, AsOf, Result) :-
    format_age(Code, Dob, AsOf, normal, Result).

%% format_age(+Code, +Dob, +AsOf, +Compactness, -Result)
%% Compactness is one of: normal, short, compact.
format_age(Code, Dob, AsOf, Compactness, Result) :-
    atom(Dob), Dob \== '',
    parse_date(Dob, DobY, DobM, DobD),
    parse_date(AsOf, AsOfY, AsOfM, AsOfD),
    parse_age(DobY, DobM, DobD, AsOfY, AsOfM, AsOfD, Months, DiffDays),
    format_age_from_components(Code, Months, DiffDays, Compactness, Result).

%% format_stage(+Code, +Dob, +AsOf, -Result) — no gender
format_stage(Code, Dob, AsOf, Result) :-
    format_stage(Code, Dob, AsOf, none, Result).

%% format_stage(+Code, +Dob, +AsOf, +Gender, -Result)
%% Gender is m, f, or none.
format_stage(Code, Dob, AsOf, Gender, Result) :-
    atom(Dob), Dob \== '',
    parse_date(Dob, DobY, DobM, DobD),
    parse_date(AsOf, AsOfY, AsOfM, AsOfD),
    parse_age(DobY, DobM, DobD, AsOfY, AsOfM, AsOfD, Months, _DiffDays),
    stage_key(Months, StageKey),
    sa_stage(Code, StageKey, Gender, Result).

%% parse_date(+Atom, -Y, -M, -D) — parse YYYY-MM-DD atom.
parse_date(Atom, Y, M, D) :-
    atom_string(Atom, Str),
    string_length(Str, Len),
    Len >= 10,
    sub_string(Str, 0, 4, _, YStr),
    sub_string(Str, 5, 2, _, MStr),
    sub_string(Str, 8, 2, _, DStr),
    number_string(Y, YStr),
    number_string(M, MStr),
    number_string(D, DStr).

%% parse_age(+DobY, +DobM, +DobD, +RefY, +RefM, +RefD, -Months, -DiffDays)
%% Computes calendar months and elapsed days. Fails if DOB is in the future
%% or age exceeds the maximum.
parse_age(DobY, DobM, DobD, RefY, RefM, RefD, Months, DiffDays) :-
    % Compute diff days using Julian Day Number
    julian_day(DobY, DobM, DobD, JDob),
    julian_day(RefY, RefM, RefD, JRef),
    DiffDays is JRef - JDob,
    DiffDays >= 0,
    % Calendar months with birthday clamping
    last_day_of_month(RefY, RefM, LastDay),
    ClampedBirthday is min(DobD, LastDay),
    RawMonths is (RefY - DobY) * 12 + (RefM - DobM),
    (RefD < ClampedBirthday -> Months is RawMonths - 1 ; Months is RawMonths),
    max_age_months(Max),
    Months =< Max.

%% julian_day(+Y, +M, +D, -JD) — Julian Day Number for date arithmetic.
julian_day(Y, M, D, JD) :-
    A is (14 - M) // 12,
    Y1 is Y + 4800 - A,
    M1 is M + 12 * A - 3,
    JD is D + (153 * M1 + 2) // 5 + 365 * Y1 + Y1 // 4 - Y1 // 100 + Y1 // 400 - 32045.

%% last_day_of_month(+Y, +M, -D) — last day of month M in year Y.
last_day_of_month(Y, M, D) :-
    M2 is M + 1,
    (M2 > 12
     -> Y2 is Y + 1, M3 is 1
     ;  Y2 is Y, M3 is M2
    ),
    julian_day(Y2, M3, 1, J2),
    julian_day(Y, M, 1, J1),
    D is J2 - J1.

%% stage_key(+Months, -Key)
stage_key(Months, newborn)  :- Months < 2, !.
stage_key(Months, infant)   :- Months < 12, !.
stage_key(Months, toddler)  :- Months < 36, !.
stage_key(Months, child)    :- Months < 156, !.
stage_key(Months, teenager) :- Months < 216, !.
stage_key(_, adult).

%% format_age_from_components(+Code, +Months, +DiffDays, +Compactness, -Result)
format_age_from_components(Code, _Months, 0, Compactness, Result) :-
    % Tier 1: born today
    !,
    effective_just_born(Code, Compactness, Result).

format_age_from_components(Code, _Months, DiffDays, Compactness, Result) :-
    DiffDays > 0, DiffDays < 7,
    % Tier 1b: 1-6 days
    !,
    resolve_unit(Code, DiffDays, day, "", Compactness, Result).

format_age_from_components(Code, Months, DiffDays, Compactness, Result) :-
    Months < 3,
    DiffDays >= 7,
    % Tier 2: weeks + days
    !,
    Weeks is DiffDays // 7,
    Days is DiffDays mod 7,
    resolve_unit(Code, Weeks, week, "", Compactness, WeekStr),
    (Days > 0
     -> resolve_unit(Code, Days, day, "", Compactness, DayStr),
        effective_delimiter(Code, Compactness, Delim),
        atom_concat(WeekStr, Delim, Tmp),
        atom_concat(Tmp, DayStr, Result)
     ;  Result = WeekStr
    ).

format_age_from_components(Code, Months, _DiffDays, Compactness, Result) :-
    Months >= 3, Months < 24,
    % Tier 3: months
    !,
    resolve_unit(Code, Months, month, "", Compactness, Result).

format_age_from_components(Code, Months, _DiffDays, Compactness, Result) :-
    Months >= 24, Months < 36,
    % Tier 4: years + months
    !,
    Years is Months // 12,
    Rem is Months mod 12,
    (Rem =:= 0
     -> resolve_unit(Code, Years, year, "", Compactness, Result)
     ;  resolve_unit(Code, Years, year, "", Compactness, YearStr),
        resolve_unit(Code, Rem, month, "", Compactness, MonthStr),
        effective_delimiter(Code, Compactness, Delim),
        atom_concat(YearStr, Delim, Tmp),
        atom_concat(Tmp, MonthStr, Result)
    ).

format_age_from_components(Code, Months, _DiffDays, Compactness, Result) :-
    Months >= 36, Months < 84,
    % Tier 5: years with half marker (3-6 years)
    !,
    Years is Months // 12,
    Rem is Months mod 12,
    (Rem >= 6
     -> effective_half(Code, Compactness, Half),
        resolve_unit(Code, Years, year, Half, Compactness, Result)
     ;  resolve_unit(Code, Years, year, "", Compactness, Result)
    ).

format_age_from_components(Code, Months, _DiffDays, Compactness, Result) :-
    % Tier 6: 7+ years
    Months >= 84,
    Years is Months // 12,
    resolve_unit(Code, Years, year, "", Compactness, Result).

%% resolve_unit(+Code, +Count, +UnitName, +Half, +Compactness, -Result)
%% Formats a count with the appropriate unit template.
resolve_unit(Code, Count, UnitName, Half, Compactness, Result) :-
    number_string(Count, CountStr),
    atom_string(BaseN, CountStr),
    % Apply {n}-style half marker to the number
    apply_n_half(BaseN, Half, N),
    % Select template
    select_template(Code, Count, UnitName, Compactness, Template),
    % Replace {n} in template with N
    replace_n(Template, N, Substituted),
    % Apply {0}-style half marker (wraps the whole expression)
    apply_zero_half(Substituted, Half, Result).

%% apply_n_half(+BaseN, +Half, -N)
%% If Half contains {n}, replace it with BaseN. Otherwise N = BaseN.
apply_n_half(BaseN, Half, N) :-
    (Half \== "", atom_string(Half, HalfStr), sub_string(HalfStr, _, _, _, "{n}")
     -> atom_string(BaseN, BaseNStr),
        string_replace(HalfStr, "{n}", BaseNStr, NStr),
        atom_string(N, NStr)
     ;  N = BaseN
    ).

%% apply_zero_half(+Substituted, +Half, -Result)
%% If Half contains {0}, replace it with Substituted. Otherwise Result = Substituted.
apply_zero_half(Substituted, Half, Result) :-
    (Half \== "", atom_string(Half, HalfStr), sub_string(HalfStr, _, _, _, "{0}")
     -> atom_string(Substituted, SubStr),
        string_replace(HalfStr, "{0}", SubStr, ResStr),
        atom_string(Result, ResStr)
     ;  Result = Substituted
    ).

%% select_template(+Code, +Count, +UnitName, +Compactness, -Template)
%% Selects the unit template based on compactness and plural category.
select_template(Code, Count, UnitName, Compactness, Template) :-
    sa_plural(Code, Count, Cat),
    (select_template_for_mode(Code, UnitName, Cat, Compactness, Template)
     -> true
     ;  % Fallback to 'other' category
        select_template_for_mode(Code, UnitName, other, Compactness, Template)
    ).

%% select_template_for_mode(+Code, +UnitName, +Cat, +Compactness, -Template)
select_template_for_mode(Code, UnitName, Cat, short, Template) :-
    short_sa_unit(Code, UnitName, Cat, Template), !.
select_template_for_mode(Code, UnitName, Cat, short, Template) :-
    sa_unit(Code, UnitName, Cat, Template).
select_template_for_mode(Code, UnitName, Cat, compact, Template) :-
    compact_sa_unit(Code, UnitName, Cat, Template), !.
select_template_for_mode(Code, UnitName, Cat, compact, Template) :-
    sa_unit(Code, UnitName, Cat, Template).
select_template_for_mode(Code, UnitName, Cat, normal, Template) :-
    sa_unit(Code, UnitName, Cat, Template).

%% replace_n(+Template, +N, -Result)
%% Replace {n} in Template atom with N atom.
replace_n(Template, N, Result) :-
    atom_string(Template, TStr),
    atom_string(N, NStr),
    string_replace(TStr, "{n}", NStr, ResStr),
    atom_string(Result, ResStr).

%% string_replace(+Input, +Search, +Replace, -Output)
%% Replace first occurrence of Search in Input with Replace.
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

%% effective_delimiter(+Code, +Compactness, -Delim)
effective_delimiter(Code, short, Delim) :-
    (short_sa_delimiter(Code, Delim) -> true ; sa_delimiter(Code, Delim)), !.
effective_delimiter(Code, compact, Delim) :-
    (compact_sa_delimiter(Code, Delim) -> true ; sa_delimiter(Code, Delim)), !.
effective_delimiter(Code, normal, Delim) :-
    sa_delimiter(Code, Delim).

%% effective_half(+Code, +Compactness, -Half)
effective_half(Code, short, Half) :-
    (short_sa_half(Code, Half) -> true ; sa_half(Code, Half)), !.
effective_half(Code, compact, Half) :-
    (compact_sa_half(Code, Half) -> true ; sa_half(Code, Half)), !.
effective_half(Code, normal, Half) :-
    sa_half(Code, Half).

%% effective_just_born(+Code, +Compactness, -JB)
effective_just_born(Code, short, JB) :-
    (short_sa_just_born(Code, JB) -> true ; sa_just_born(Code, JB)), !.
effective_just_born(Code, compact, JB) :-
    (compact_sa_just_born(Code, JB) -> true ; sa_just_born(Code, JB)), !.
effective_just_born(Code, normal, JB) :-
    sa_just_born(Code, JB).
