-module(sayableage).
-include("sayableage.hrl").
-export([format_age/4, format_age_pure/4, format_stage/4, format_stage_pure/4, get_locale/1]).

-spec format_age_pure(#locale{}, compactness(), string(), string()) -> {ok, string()} | error.
format_age_pure(Locale, Compactness, DOB, AsOf) ->
    sayableage_formatter:format_age_pure(Locale, Compactness, DOB, AsOf).

-spec format_age(#locale{}, compactness(), string(), string() | undefined) -> {ok, string()} | error.
format_age(Locale, Compactness, DOB, undefined) ->
    AsOf = sayableage_internal:format_date(sayableage_internal:today()),
    format_age_pure(Locale, Compactness, DOB, AsOf);
format_age(Locale, Compactness, DOB, AsOf) ->
    format_age_pure(Locale, Compactness, DOB, AsOf).

-spec format_stage_pure(#locale{}, string(), string(), gender() | undefined) -> {ok, string()} | error.
format_stage_pure(Locale, DOB, AsOf, Gender) ->
    sayableage_formatter:format_stage_pure(Locale, DOB, AsOf, Gender).

-spec format_stage(#locale{}, string(), string() | undefined, gender() | undefined) -> {ok, string()} | error.
format_stage(Locale, DOB, undefined, Gender) ->
    AsOf = sayableage_internal:format_date(sayableage_internal:today()),
    format_stage_pure(Locale, DOB, AsOf, Gender);
format_stage(Locale, DOB, AsOf, Gender) ->
    format_stage_pure(Locale, DOB, AsOf, Gender).

-spec get_locale(string()) -> {ok, #locale{}} | error.
get_locale(Code) ->
    sayableage_locales:get_locale(Code).
