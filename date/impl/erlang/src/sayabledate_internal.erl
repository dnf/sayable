-module(sayabledate_internal).
-export([parse_date/1, to_jdn/3, weekday/3]).

%% Accepts YYYY-MM-DD, optionally followed by T and anything (an ISO datetime);
%% only the first ten characters are read.
-spec parse_date(string()) -> {ok, {integer(), integer(), integer()}} | error.
parse_date([_, _, _, _, _, _, _, _, _, _] = S) -> parse_ymd(S);
parse_date([_, _, _, _, _, _, _, _, _, _, $T | _] = S) -> parse_ymd(lists:sublist(S, 10));
parse_date(_) -> error.

-spec to_jdn(integer(), integer(), integer()) -> integer().
to_jdn(Y, M, D) ->
    A = (14 - M) div 12,
    YY = Y + 4800 - A,
    MM = M + 12 * A - 3,
    D + (153 * MM + 2) div 5 + 365 * YY + YY div 4 - YY div 100 + YY div 400 - 32045.

-spec weekday(integer(), integer(), integer()) -> integer().
weekday(Y, M, D) ->
    Jdn = to_jdn(Y, M, D),
    (Jdn + 1) rem 7.

%% Internal helpers

parse_ymd([Y1, Y2, Y3, Y4, $-, M1, M2, $-, D1, D2]) ->
    case all_digits([Y1, Y2, Y3, Y4, M1, M2, D1, D2]) of
        true ->
            Y = list_to_integer([Y1, Y2, Y3, Y4]),
            M = list_to_integer([M1, M2]),
            D = list_to_integer([D1, D2]),
            case is_real_date(Y, M, D) of
                true -> {ok, {Y, M, D}};
                false -> error
            end;
        false -> error
    end;
parse_ymd(_) -> error.

is_real_date(Y, M, D) ->
    M >= 1 andalso M =< 12 andalso D >= 1 andalso D =< days_in_month(Y, M).

days_in_month(Y, 2) ->
    case (Y rem 4 =:= 0 andalso Y rem 100 =/= 0) orelse Y rem 400 =:= 0 of
        true -> 29;
        false -> 28
    end;
days_in_month(_, M) when M =:= 4; M =:= 6; M =:= 9; M =:= 11 -> 30;
days_in_month(_, _) -> 31.

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.
