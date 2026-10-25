-module(sayable_cli_ffi).
-export([write_stderr/1, get_today/0, halt/1, get_args/0, read_line/0, rescue/1]).

write_stderr(Msg) ->
    io:put_chars(standard_error, Msg),
    nil.

get_today() ->
    {Year, Month, Day} = erlang:date(),
    Y = integer_to_list(Year),
    M = string:right(integer_to_list(Month), 2, $0),
    D = string:right(integer_to_list(Day), 2, $0),
    list_to_binary(Y ++ "-" ++ M ++ "-" ++ D).

halt(Code) ->
    erlang:halt(Code).

get_args() ->
    [list_to_binary(A) || A <- init:get_plain_arguments()].

%% One stdin line without its "\n" or "\r\n"; a read error ends input like EOF.
read_line() ->
    ok = io:setopts(standard_io, [binary, {encoding, unicode}]),
    case io:get_line(standard_io, "") of
        eof -> {error, nil};
        {error, _Reason} -> {error, nil};
        Line -> {ok, string:chomp(Line)}
    end.

rescue(Fun) ->
    try
        {ok, Fun()}
    catch
        Class:Reason:Stack ->
            {error, unicode:characters_to_binary(io_lib:format("~p", [{Class, Reason, Stack}]))}
    end.
