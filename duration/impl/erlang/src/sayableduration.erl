-module(sayableduration).
-include("sayableduration.hrl").
-export([format_duration/4, format_since/4, format_until/4, get_locale/1]).

-spec format_duration(#duration_locale{}, compactness(), integer() | string() | undefined, string() | undefined) -> {ok, string()} | error.
format_duration(Locale, Compactness, StartOrSeconds, End) ->
    sayableduration_formatter:format_duration(Locale, Compactness, StartOrSeconds, End).

-spec format_since(#duration_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_since(Locale, Compactness, Start, AsOf) ->
    sayableduration_formatter:format_since(Locale, Compactness, Start, AsOf).

-spec format_until(#duration_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_until(Locale, Compactness, Target, AsOf) ->
    sayableduration_formatter:format_until(Locale, Compactness, Target, AsOf).

-spec get_locale(string()) -> {ok, #duration_locale{}} | error.
get_locale(Code) ->
    sayableduration_locales:get_locale(Code).
