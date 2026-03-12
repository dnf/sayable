-module(sayabletime).
-include("sayabletime.hrl").
-export([format_time/3, get_locale/1]).

-spec format_time(#time_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_time(Locale, Compactness, Input) ->
    sayabletime_formatter:format_time(Locale, Compactness, Input).

-spec get_locale(string()) -> {ok, #time_locale{}} | error.
get_locale(Code) ->
    sayabletime_locales:get_locale(Code).
