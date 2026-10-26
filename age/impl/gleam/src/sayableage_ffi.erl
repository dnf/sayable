-module(sayableage_ffi).
-export([replace_all/3, contains/2, today/0]).

%% Placeholder handling matches code points, not graphemes. gleam/string
%% compares graphemes, and a placeholder followed by a combining mark (Tamil
%% "{h}\x{0BC1}") is one grapheme "}\x{0BC1}", so it would never match.

replace_all(Subject, Pattern, Replacement) ->
    binary:replace(Subject, Pattern, Replacement, [global]).

contains(Subject, Pattern) ->
    binary:match(Subject, Pattern) =/= nomatch.

%% Today's local date as YYYY-MM-DD, the default when asOf is absent or empty.
today() ->
    {{Y, M, D}, _} = calendar:local_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0B", [Y, M, D])).
