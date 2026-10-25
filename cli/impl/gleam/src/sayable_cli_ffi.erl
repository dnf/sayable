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

%% Arguments arrive as lists of Unicode code points, not bytes.
get_args() ->
    [unicode:characters_to_binary(A) || A <- init:get_plain_arguments()].

%% One stdin line without its "\n" or "\r\n", or {error, nil} at end of input.
%% Read through an fd port, not io:get_line: on OTP 26/27 the I/O server's
%% line editing treats a tab as completion and drops it, merging the REPL's
%% tab-separated fields. The wrapper starts erl with -noinput so nothing
%% else reads stdin.
read_line() ->
    case get(sayable_stdin_eof) of
        true -> {error, nil};
        undefined -> read_line(stdin(), <<>>)
    end.

read_line(Stdin, Partial) ->
    receive
        {Stdin, {data, {noeol, Chunk}}} -> read_line(Stdin, <<Partial/binary, Chunk/binary>>);
        {Stdin, {data, {eol, Chunk}}} -> {ok, strip_cr(<<Partial/binary, Chunk/binary>>)};
        {Stdin, eof} when Partial =:= <<>> -> {error, nil};
        {Stdin, eof} -> put(sayable_stdin_eof, true), {ok, strip_cr(Partial)}
    end.

strip_cr(Line) -> string:trim(Line, trailing, "\r").

stdin() ->
    case get(sayable_stdin) of
        undefined ->
            ok = io:setopts(standard_io, [binary, {encoding, unicode}]),
            Stdin = open_port({fd, 0, 1}, [{line, 65536}, binary, eof, in]),
            put(sayable_stdin, Stdin),
            Stdin;
        Stdin ->
            Stdin
    end.

rescue(Fun) ->
    try
        {ok, Fun()}
    catch
        Class:Reason:Stack ->
            {error, unicode:characters_to_binary(io_lib:format("~p", [{Class, Reason, Stack}]))}
    end.
