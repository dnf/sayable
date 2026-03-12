-module(sayabletime_internal).
-export([parse_time/1, round_to_5/1]).

-spec parse_time(string()) -> {ok, {integer(), integer()}} | error.
parse_time([]) -> error;
parse_time(S) ->
    T = strip_time_part(S),
    case split_colon(T) of
        {HStr, MRest} ->
            MStr = strip_seconds(MRest),
            case all_digits(HStr) andalso all_digits(MStr) andalso
                 length(HStr) > 0 andalso length(MStr) > 0 of
                true ->
                    H = list_to_integer(HStr),
                    M = list_to_integer(MStr),
                    case H >= 0 andalso H =< 23 andalso M >= 0 andalso M =< 59 of
                        true -> {ok, {H, M}};
                        false -> error
                    end;
                false -> error
            end;
        error -> error
    end.

-spec round_to_5(integer()) -> integer().
round_to_5(M) ->
    ((M + 2) div 5) * 5.

%% Internal helpers

strip_time_part(S) ->
    case find_char($T, S) of
        {_Before, After} -> After;
        not_found -> S
    end.

strip_seconds(S) ->
    S1 = strip_at_char($:, S),
    S2 = strip_at_char($+, S1),
    S3 = strip_at_char($Z, S2),
    strip_at_char($., S3).

strip_at_char(C, S) ->
    case find_char(C, S) of
        {Before, _After} -> Before;
        not_found -> S
    end.

find_char(_C, []) -> not_found;
find_char(C, [C | Rest]) -> {[], Rest};
find_char(C, [H | Rest]) ->
    case find_char(C, Rest) of
        {Before, After} -> {[H | Before], After};
        not_found -> not_found
    end.

split_colon(S) ->
    case find_char($:, S) of
        {Before, After} -> {Before, After};
        not_found -> error
    end.

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.
