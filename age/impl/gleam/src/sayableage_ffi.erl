-module(sayableage_ffi).
-export([replace_all/3, contains/2]).

%% Placeholder handling matches code points, not graphemes. gleam/string
%% compares graphemes, and a placeholder followed by a combining mark (Tamil
%% "{h}\x{0BC1}") is one grapheme "}\x{0BC1}", so it would never match.

replace_all(Subject, Pattern, Replacement) ->
    binary:replace(Subject, Pattern, Replacement, [global]).

contains(Subject, Pattern) ->
    binary:match(Subject, Pattern) =/= nomatch.
