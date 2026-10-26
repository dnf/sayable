-module(sayableduration_internal).
-export([parse_iso_to_seconds/1]).

%% Accepts YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix
%% (the zone is validated but ignored).
-spec parse_iso_to_seconds(string()) -> {ok, integer()} | error.
parse_iso_to_seconds([Y1, Y2, Y3, Y4, $-, M1, M2, $-, D1, D2, $T | Clock]) ->
    case all_digits([Y1, Y2, Y3, Y4, M1, M2, D1, D2]) of
        true ->
            Y = list_to_integer([Y1, Y2, Y3, Y4]),
            M = two_digits(M1, M2),
            D = two_digits(D1, D2),
            case is_real_date(Y, M, D) andalso parse_clock(Clock) of
                {ok, {Hr, Min, Sec}} ->
                    {ok, days_since_epoch(Y, M, D) * 86400 + Hr * 3600 + Min * 60 + Sec};
                _ -> error
            end;
        false -> error
    end;
parse_iso_to_seconds(_) -> error.

%% Internal helpers

-define(IS_DIGIT(C), (C >= $0 andalso C =< $9)).

parse_clock([H1, H2, $: | Rest]) when ?IS_DIGIT(H1), ?IS_DIGIT(H2) ->
    clock_minutes(two_digits(H1, H2), Rest);
parse_clock([H1, $: | Rest]) when ?IS_DIGIT(H1) ->
    clock_minutes(H1 - $0, Rest);
parse_clock(_) -> error.

clock_minutes(H, [M1, M2 | Rest]) when ?IS_DIGIT(M1), ?IS_DIGIT(M2) ->
    clock_seconds(H, two_digits(M1, M2), Rest);
clock_minutes(_, _) -> error.

clock_seconds(H, M, [$:, S1, S2 | Rest]) when ?IS_DIGIT(S1), ?IS_DIGIT(S2) ->
    clock_fraction(H, M, two_digits(S1, S2), Rest);
clock_seconds(H, M, Rest) ->
    clock_zone(H, M, 0, Rest).

clock_fraction(H, M, Sec, [$., C | Rest]) when ?IS_DIGIT(C) ->
    clock_zone(H, M, Sec, lists:dropwhile(fun(D) -> ?IS_DIGIT(D) end, Rest));
clock_fraction(H, M, Sec, Rest) ->
    clock_zone(H, M, Sec, Rest).

clock_zone(H, M, Sec, Zone) when H =< 23, M =< 59, Sec =< 59 ->
    case is_zone_suffix(Zone) of
        true -> {ok, {H, M, Sec}};
        false -> error
    end;
clock_zone(_, _, _, _) -> error.

is_zone_suffix([]) -> true;
is_zone_suffix("Z") -> true;
is_zone_suffix([Sign, A, B, $:, C, D]) when Sign =:= $+ orelse Sign =:= $- ->
    all_digits([A, B, C, D]);
is_zone_suffix(_) -> false.

two_digits(A, B) -> (A - $0) * 10 + (B - $0).

is_real_date(Y, M, D) ->
    M >= 1 andalso M =< 12 andalso D >= 1 andalso D =< dim(Y, M).

days_since_epoch(Year, Month, Day) ->
    YDays = year_days(2000, Year),
    MDays = month_days(Year, 1, Month),
    YDays + MDays + Day - 1.

year_days(From, To) when From =:= To -> 0;
year_days(From, To) when From < To ->
    case is_leap_year(From) of
        true -> 366 + year_days(From + 1, To);
        false -> 365 + year_days(From + 1, To)
    end;
year_days(From, To) when From > To ->
    case is_leap_year(To) of
        true -> -366 + year_days(From, To + 1);
        false -> -365 + year_days(From, To + 1)
    end.

month_days(_Year, Cur, Target) when Cur >= Target -> 0;
month_days(Year, Cur, Target) ->
    dim(Year, Cur) + month_days(Year, Cur + 1, Target).

is_leap_year(Y) ->
    (Y rem 4 =:= 0 andalso Y rem 100 =/= 0) orelse Y rem 400 =:= 0.

dim(_, M) when M =:= 1; M =:= 3; M =:= 5; M =:= 7; M =:= 8; M =:= 10; M =:= 12 -> 31;
dim(_, M) when M =:= 4; M =:= 6; M =:= 9; M =:= 11 -> 30;
dim(Y, 2) ->
    case is_leap_year(Y) of true -> 29; false -> 28 end.

all_digits([]) -> true;
all_digits([C | Rest]) when ?IS_DIGIT(C) -> all_digits(Rest);
all_digits(_) -> false.
