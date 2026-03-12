-module(sayabledate_internal).
-export([parse_date/1, to_jdn/3, weekday/3]).

-spec parse_date(string()) -> {ok, {integer(), integer(), integer()}} | error.
parse_date(S) ->
    case length(S) >= 10 andalso
         lists:nth(5, S) =:= $- andalso
         lists:nth(8, S) =:= $- of
        true ->
            YStr = lists:sublist(S, 1, 4),
            MStr = lists:sublist(S, 6, 2),
            DStr = lists:sublist(S, 9, 2),
            case all_digits(YStr) andalso all_digits(MStr) andalso all_digits(DStr) of
                true ->
                    Y = list_to_integer(YStr),
                    M = list_to_integer(MStr),
                    D = list_to_integer(DStr),
                    case M >= 1 andalso M =< 12 andalso D >= 1 andalso D =< 31 of
                        true -> {ok, {Y, M, D}};
                        false -> error
                    end;
                false -> error
            end;
        false -> error
    end.

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

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.
