-module(sayabletime_internal).
-export([parse_time/1, round_to_5/1]).

%% Accepts a clock time (H:MM or HH:MM, optional :SS and fraction, optional
%% zone suffix, which is ignored), alone or after the T of an ISO datetime.
-spec parse_time(string()) -> {ok, {integer(), integer()}} | error.
parse_time([]) -> error;
parse_time(S) ->
    case find_char($T, S) of
        {DatePart, Clock} ->
            case is_real_date(DatePart) of
                true -> parse_clock(Clock);
                false -> error
            end;
        not_found -> parse_clock(S)
    end.

-spec round_to_5(integer()) -> integer().
round_to_5(M) ->
    ((M + 2) div 5) * 5.

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
        true -> {ok, {H, M}};
        false -> error
    end;
clock_zone(_, _, _, _) -> error.

is_zone_suffix([]) -> true;
is_zone_suffix("Z") -> true;
is_zone_suffix([Sign, A, B, $:, C, D]) when Sign =:= $+ orelse Sign =:= $- ->
    all_digits([A, B, C, D]);
is_zone_suffix(_) -> false.

two_digits(A, B) -> (A - $0) * 10 + (B - $0).

is_real_date([Y1, Y2, Y3, Y4, $-, M1, M2, $-, D1, D2]) ->
    all_digits([Y1, Y2, Y3, Y4, M1, M2, D1, D2]) andalso
        is_real_date(list_to_integer([Y1, Y2, Y3, Y4]), two_digits(M1, M2), two_digits(D1, D2));
is_real_date(_) -> false.

is_real_date(Y, M, D) ->
    M >= 1 andalso M =< 12 andalso D >= 1 andalso D =< days_in_month(Y, M).

days_in_month(Y, 2) ->
    case (Y rem 4 =:= 0 andalso Y rem 100 =/= 0) orelse Y rem 400 =:= 0 of
        true -> 29;
        false -> 28
    end;
days_in_month(_, M) when M =:= 4; M =:= 6; M =:= 9; M =:= 11 -> 30;
days_in_month(_, _) -> 31.

find_char(_C, []) -> not_found;
find_char(C, [C | Rest]) -> {[], Rest};
find_char(C, [H | Rest]) ->
    case find_char(C, Rest) of
        {Before, After} -> {[H | Before], After};
        not_found -> not_found
    end.

all_digits([]) -> true;
all_digits([C | Rest]) when ?IS_DIGIT(C) -> all_digits(Rest);
all_digits(_) -> false.
