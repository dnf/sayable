-module(sayableduration_internal).
-export([parse_iso_to_seconds/1]).

-spec parse_iso_to_seconds(string()) -> {ok, integer()} | error.
parse_iso_to_seconds([]) -> error;
parse_iso_to_seconds(S) ->
    case find_char($T, S) of
        {DatePart, TimePart} ->
            case parse_date_part(DatePart) of
                {ok, {Y, M, D}} ->
                    case parse_time_part(TimePart) of
                        {ok, {Hr, Min, Sec}} ->
                            Days = days_since_epoch(Y, M, D),
                            {ok, Days * 86400 + Hr * 3600 + Min * 60 + Sec};
                        error -> error
                    end;
                error -> error
            end;
        not_found -> error
    end.

%% Internal helpers

parse_date_part(S) ->
    case length(S) >= 10 andalso
         lists:nth(5, S) =:= $- andalso
         lists:nth(8, S) =:= $- of
        true ->
            YStr = lists:sublist(S, 1, 4),
            MStr = lists:sublist(S, 6, 2),
            DStr = lists:sublist(S, 9, 2),
            case all_digits(YStr) andalso all_digits(MStr) andalso all_digits(DStr) of
                true ->
                    {ok, {list_to_integer(YStr), list_to_integer(MStr), list_to_integer(DStr)}};
                false -> error
            end;
        false -> error
    end.

parse_time_part(S) ->
    S1 = strip_at_char($+, S),
    S2 = strip_at_char($Z, S1),
    Parts = split_colons(S2),
    case Parts of
        [HStr] ->
            case all_digits(HStr) of
                true -> {ok, {list_to_integer(HStr), 0, 0}};
                false -> error
            end;
        [HStr, MStr] ->
            case all_digits(HStr) andalso all_digits(MStr) of
                true -> {ok, {list_to_integer(HStr), list_to_integer(MStr), 0}};
                false -> error
            end;
        [HStr, MStr, SStr0] ->
            SStr = strip_at_char($., SStr0),
            case all_digits(HStr) andalso all_digits(MStr) andalso all_digits(SStr) of
                true -> {ok, {list_to_integer(HStr), list_to_integer(MStr), list_to_integer(SStr)}};
                false -> error
            end;
        _ -> error
    end.

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

find_char(_C, []) -> not_found;
find_char(C, [C | Rest]) -> {[], Rest};
find_char(C, [H | Rest]) ->
    case find_char(C, Rest) of
        {Before, After} -> {[H | Before], After};
        not_found -> not_found
    end.

strip_at_char(C, S) ->
    case find_char(C, S) of
        {Before, _After} -> Before;
        not_found -> S
    end.

split_colons(S) -> split_colons(S, [], []).

split_colons([], Cur, Acc) -> lists:reverse([lists:reverse(Cur) | Acc]);
split_colons([$: | Rest], Cur, Acc) -> split_colons(Rest, [], [lists:reverse(Cur) | Acc]);
split_colons([C | Rest], Cur, Acc) -> split_colons(Rest, [C | Cur], Acc).

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.
