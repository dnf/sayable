-module(sayabledate).
-include("sayabledate.hrl").
-export([format_date/3, format_date_with_year/3, format_relative/4, get_locale/1]).

-spec format_date(#date_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_date(Locale, Compactness, Date) ->
    sayabledate_formatter:format_date(Locale, Compactness, Date).

-spec format_date_with_year(#date_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_date_with_year(Locale, Compactness, Date) ->
    sayabledate_formatter:format_date_with_year(Locale, Compactness, Date).

-spec format_relative(#date_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_relative(Locale, Compactness, Date, AsOf) ->
    sayabledate_formatter:format_relative(Locale, Compactness, Date, AsOf).

-spec get_locale(string()) -> {ok, #date_locale{}} | error.
get_locale(Code) ->
    sayabledate_locales:get_locale(Code).
