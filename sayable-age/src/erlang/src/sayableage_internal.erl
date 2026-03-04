-module(sayableage_internal).
-export([parse_date/1, is_leap_year/1, days_in_month/2, days_between/2,
         compute_age/2, today/0, format_date/1]).

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
                    case Y =:= 0 andalso M =:= 0 andalso D =:= 0 of
                        true -> error;
                        false -> {ok, {Y, M, D}}
                    end;
                false -> error
            end;
        false -> error
    end.

-spec is_leap_year(integer()) -> boolean().
is_leap_year(Y) ->
    (Y rem 4 =:= 0 andalso Y rem 100 =/= 0) orelse Y rem 400 =:= 0.

-spec days_in_month(integer(), integer()) -> integer().
days_in_month(_, M) when M =:= 1; M =:= 3; M =:= 5; M =:= 7; M =:= 8; M =:= 10; M =:= 12 -> 31;
days_in_month(_, M) when M =:= 4; M =:= 6; M =:= 9; M =:= 11 -> 30;
days_in_month(Y, 2) ->
    case is_leap_year(Y) of
        true -> 29;
        false -> 28
    end;
days_in_month(_, _) -> 30.

-spec to_jdn(integer(), integer(), integer()) -> integer().
to_jdn(Y, M, D) ->
    A = (14 - M) div 12,
    YY = Y + 4800 - A,
    MM = M + 12 * A - 3,
    D + (153 * MM + 2) div 5 + 365 * YY + YY div 4 - YY div 100 + YY div 400 - 32045.

-spec days_between({integer(), integer(), integer()}, {integer(), integer(), integer()}) -> integer().
days_between({Y1, M1, D1}, {Y2, M2, D2}) ->
    to_jdn(Y2, M2, D2) - to_jdn(Y1, M1, D1).

-spec compute_age(string(), string()) -> {ok, {integer(), integer()}} | error.
compute_age(DOB, AsOf) ->
    case {parse_date(DOB), parse_date(AsOf)} of
        {{ok, {DY, DM, DD}}, {ok, {RY, RM, RD}}} ->
            DiffDays = days_between({DY, DM, DD}, {RY, RM, RD}),
            if DiffDays < 0 -> error;
               true ->
                    LastDay = days_in_month(RY, RM),
                    ClampedBirthday = min(DD, LastDay),
                    Months0 = (RY - DY) * 12 + (RM - DM),
                    Months = if RD < ClampedBirthday -> Months0 - 1;
                                true -> Months0
                             end,
                    if Months > 6000 -> error;
                       true -> {ok, {Months, DiffDays}}
                    end
            end;
        _ -> error
    end.

-spec today() -> {integer(), integer(), integer()}.
today() ->
    {Date, _Time} = calendar:local_time(),
    Date.

-spec format_date({integer(), integer(), integer()}) -> string().
format_date({Y, M, D}) ->
    pad4(Y) ++ "-" ++ pad2(M) ++ "-" ++ pad2(D).

%% Internal helpers

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.

pad2(N) when N < 10 -> [$0 | integer_to_list(N)];
pad2(N) -> integer_to_list(N).

pad4(N) ->
    S = integer_to_list(N),
    lists:duplicate(4 - length(S), $0) ++ S.
