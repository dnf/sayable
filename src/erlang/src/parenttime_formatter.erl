-module(parenttime_formatter).
-include("parenttime.hrl").
-export([format_age_pure/4, format_stage_pure/4]).

-define(MAX_AGE_MONTHS, 6000).

-spec format_age_pure(#locale{}, compactness(), string(), string()) -> {ok, string()} | error.
format_age_pure(_Locale, _Compactness, [], _AsOf) -> error;
format_age_pure(Locale, Compactness, DOB, AsOf) ->
    case parenttime_internal:compute_age(DOB, AsOf) of
        {ok, {Months, DiffDays}} when Months =< ?MAX_AGE_MONTHS ->
            {Day, Week, Month, Year, Half, Delim, JustBorn} = resolve_locale(Locale, Compactness),
            {ok, format_tier(Locale, Day, Week, Month, Year, Half, Delim, JustBorn, Months, DiffDays)};
        _ -> error
    end.

-spec format_stage_pure(#locale{}, string(), string(), gender() | undefined) -> {ok, string()} | error.
format_stage_pure(_Locale, [], _AsOf, _Gender) -> error;
format_stage_pure(Locale, DOB, AsOf, Gender) ->
    case parenttime_internal:compute_age(DOB, AsOf) of
        {ok, {Months, _DiffDays}} ->
            Stages = Locale#locale.stages,
            Label = stage_label(Months, Stages),
            {ok, resolve_stage_label(Label, Gender)};
        error -> error
    end.

%% Internal

format_tier(_Locale, _Day, _Week, _Month, _Year, _Half, _Delim, JustBorn, _Months, DiffDays) when DiffDays =:= 0 ->
    JustBorn;
format_tier(Locale, Day, _Week, _Month, _Year, _Half, _Delim, _JustBorn, _Months, DiffDays) when DiffDays < 7 ->
    resolve_unit(DiffDays, Day, Locale, "");
format_tier(Locale, Day, Week, _Month, _Year, _Half, Delim, _JustBorn, Months, DiffDays) when Months < 3 ->
    Weeks = DiffDays div 7,
    Days = DiffDays rem 7,
    WStr = resolve_unit(Weeks, Week, Locale, ""),
    case Days > 0 of
        true -> WStr ++ Delim ++ resolve_unit(Days, Day, Locale, "");
        false -> WStr
    end;
format_tier(Locale, _Day, _Week, Month, _Year, _Half, _Delim, _JustBorn, Months, _DiffDays) when Months < 24 ->
    resolve_unit(Months, Month, Locale, "");
format_tier(Locale, _Day, _Week, Month, Year, _Half, Delim, _JustBorn, Months, _DiffDays) when Months < 36 ->
    Years = Months div 12,
    Rem = Months rem 12,
    YStr = resolve_unit(Years, Year, Locale, ""),
    case Rem =:= 0 of
        true -> YStr;
        false -> YStr ++ Delim ++ resolve_unit(Rem, Month, Locale, "")
    end;
format_tier(Locale, _Day, _Week, _Month, Year, Half, _Delim, _JustBorn, Months, _DiffDays) when Months < 84 ->
    Years = Months div 12,
    Rem = Months rem 12,
    case Rem >= 6 of
        true -> resolve_unit(Years, Year, Locale, Half);
        false -> resolve_unit(Years, Year, Locale, "")
    end;
format_tier(Locale, _Day, _Week, _Month, Year, _Half, _Delim, _JustBorn, Months, _DiffDays) ->
    Years = Months div 12,
    resolve_unit(Years, Year, Locale, "").

resolve_unit(Count, UnitForms, Locale, Half) ->
    BaseN = integer_to_list(Count),
    N = case Half =/= "" andalso str_contains(Half, "{n}") of
            true -> str_replace(Half, "{n}", BaseN);
            false -> BaseN
        end,
    Plural = Locale#locale.plural,
    Template = case UnitForms of
                   {simple, S} -> S;
                   {pluralized, Forms} -> lookup_unit_form(Plural(Count), Forms)
               end,
    Result = str_replace(Template, "{n}", N),
    case Half =/= "" andalso str_contains(Half, "{0}") of
        true -> str_replace(Half, "{0}", Result);
        false -> Result
    end.

lookup_unit_form(Cat, Forms) ->
    case lists:keyfind(Cat, 1, Forms) of
        {Cat, S} -> S;
        false ->
            case lists:keyfind(other, 1, Forms) of
                {other, S} -> S;
                false -> ""
            end
    end.

resolve_locale(Locale, Compactness) ->
    MOvr = case Compactness of
               normal -> nothing;
               short -> Locale#locale.short;
               compact -> Locale#locale.compact
           end,
    case MOvr of
        nothing ->
            {Locale#locale.day, Locale#locale.week, Locale#locale.month, Locale#locale.year,
             Locale#locale.half, Locale#locale.delimiter, Locale#locale.just_born};
        {just, Ovr} ->
            {ovr_or(Ovr#compactness_override.day, Locale#locale.day),
             ovr_or(Ovr#compactness_override.week, Locale#locale.week),
             ovr_or(Ovr#compactness_override.month, Locale#locale.month),
             ovr_or(Ovr#compactness_override.year, Locale#locale.year),
             ovr_or_str(Ovr#compactness_override.half, Locale#locale.half),
             ovr_or_str(Ovr#compactness_override.delimiter, Locale#locale.delimiter),
             ovr_or_str(Ovr#compactness_override.just_born, Locale#locale.just_born)}
    end.

ovr_or(nothing, Default) -> Default;
ovr_or({just, Val}, _Default) -> Val.

ovr_or_str(nothing, Default) -> Default;
ovr_or_str({just, Val}, _Default) -> Val.

stage_label(Months, Stages) when Months < 2 -> Stages#stages.newborn;
stage_label(Months, Stages) when Months < 12 -> Stages#stages.infant;
stage_label(Months, Stages) when Months < 36 -> Stages#stages.toddler;
stage_label(Months, Stages) when Months < 156 -> Stages#stages.child;
stage_label(Months, Stages) when Months < 216 -> Stages#stages.teenager;
stage_label(_Months, Stages) -> Stages#stages.adult.

resolve_stage_label({neutral, S}, _Gender) -> S;
resolve_stage_label({gendered, _M, F}, female) -> F;
resolve_stage_label({gendered, M, _F}, _) -> M.

str_replace(Haystack, Needle, Replacement) ->
    NLen = length(Needle),
    str_replace(Haystack, Needle, Replacement, NLen).

str_replace([], _Needle, _Replacement, _NLen) -> [];
str_replace(Haystack, Needle, Replacement, NLen) ->
    case lists:prefix(Needle, Haystack) of
        true -> Replacement ++ str_replace(lists:nthtail(NLen, Haystack), Needle, Replacement, NLen);
        false -> [hd(Haystack) | str_replace(tl(Haystack), Needle, Replacement, NLen)]
    end.

str_contains(Haystack, Needle) ->
    NLen = length(Needle),
    str_contains(Haystack, Needle, NLen).

str_contains(Haystack, _Needle, NLen) when length(Haystack) < NLen -> false;
str_contains(Haystack, Needle, NLen) ->
    case lists:prefix(Needle, Haystack) of
        true -> true;
        false -> str_contains(tl(Haystack), Needle, NLen)
    end.
