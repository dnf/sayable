-module(sayableduration_formatter).
-include("sayableduration.hrl").
-export([format_duration/4, format_since/4, format_until/4]).

-spec format_duration(#duration_locale{}, compactness(), integer() | string() | undefined, string() | undefined) -> {ok, string()} | error.
format_duration(_Locale, _Compactness, undefined, _End) -> error;
format_duration(Locale, Compactness, Seconds, _End) when is_integer(Seconds) ->
    case Seconds < 0 of
        true -> error;
        false ->
            {Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, _Ago, _InFuture} =
                resolve_locale(Locale, Compactness),
            {ok, format_seconds(Locale, Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, Seconds)}
    end;
format_duration(Locale, Compactness, Start, End) when is_list(Start) ->
    case End of
        undefined -> error;
        [] -> error;
        _ ->
            case {sayableduration_internal:parse_iso_to_seconds(Start),
                  sayableduration_internal:parse_iso_to_seconds(End)} of
                {{ok, S}, {ok, E}} ->
                    Total = abs(E - S),
                    {Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, _Ago, _InFuture} =
                        resolve_locale(Locale, Compactness),
                    {ok, format_seconds(Locale, Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, Total)};
                _ -> error
            end
    end;
format_duration(_Locale, _Compactness, _Start, _End) -> error.

-spec format_since(#duration_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_since(_Locale, _Compactness, undefined, _AsOf) -> error;
format_since(_Locale, _Compactness, [], _AsOf) -> error;
format_since(_Locale, _Compactness, _Start, undefined) -> error;
format_since(_Locale, _Compactness, _Start, []) -> error;
format_since(Locale, Compactness, Start, AsOf) ->
    case {sayableduration_internal:parse_iso_to_seconds(Start),
          sayableduration_internal:parse_iso_to_seconds(AsOf)} of
        {{ok, S}, {ok, A}} ->
            Diff = A - S,
            if
                Diff < 0 -> error;
                Diff =:= 0 ->
                    {_Second, _Minute, _Hour, _Day, _Week, _Month, _Year, _Half, _Delim, JustNow, _Ago, _InFuture} =
                        resolve_locale(Locale, Compactness),
                    {ok, JustNow};
                true ->
                    {Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, Ago, _InFuture} =
                        resolve_locale(Locale, Compactness),
                    Dur = format_seconds(Locale, Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, Diff),
                    {ok, str_replace(Ago, "{0}", Dur)}
            end;
        _ -> error
    end.

-spec format_until(#duration_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_until(_Locale, _Compactness, undefined, _AsOf) -> error;
format_until(_Locale, _Compactness, [], _AsOf) -> error;
format_until(_Locale, _Compactness, _Target, undefined) -> error;
format_until(_Locale, _Compactness, _Target, []) -> error;
format_until(Locale, Compactness, Target, AsOf) ->
    case {sayableduration_internal:parse_iso_to_seconds(Target),
          sayableduration_internal:parse_iso_to_seconds(AsOf)} of
        {{ok, T}, {ok, A}} ->
            Diff = T - A,
            if
                Diff < 0 -> error;
                Diff =:= 0 ->
                    {_Second, _Minute, _Hour, _Day, _Week, _Month, _Year, _Half, _Delim, JustNow, _Ago, _InFuture} =
                        resolve_locale(Locale, Compactness),
                    {ok, JustNow};
                true ->
                    {Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, _Ago, InFuture} =
                        resolve_locale(Locale, Compactness),
                    Dur = format_seconds(Locale, Second, Minute, Hour, Day, Week, Month, Year, Half, Delim, JustNow, Diff),
                    {ok, str_replace(InFuture, "{0}", Dur)}
            end;
        _ -> error
    end.

%% Internal

format_seconds(_Locale, _Second, _Minute, _Hour, _Day, _Week, _Month, _Year, _Half, _Delim, JustNow, 0) ->
    JustNow;
format_seconds(Locale, Second, _Minute, _Hour, _Day, _Week, _Month, _Year, _Half, _Delim, _JustNow, Total) when Total < 60 ->
    resolve_unit(Total, Second, Locale, "");
format_seconds(Locale, Second, Minute, _Hour, _Day, _Week, _Month, _Year, _Half, Delim, _JustNow, Total) when Total < 300 ->
    TotalMin = Total div 60,
    RemSec = Total rem 60,
    MStr = resolve_unit(TotalMin, Minute, Locale, ""),
    case RemSec > 0 of
        true -> MStr ++ Delim ++ resolve_unit(RemSec, Second, Locale, "");
        false -> MStr
    end;
format_seconds(Locale, _Second, Minute, _Hour, _Day, _Week, _Month, _Year, _Half, _Delim, _JustNow, Total) when Total < 3600 ->
    TotalMin = Total div 60,
    resolve_unit(TotalMin, Minute, Locale, "");
format_seconds(Locale, _Second, Minute, Hour, _Day, _Week, _Month, _Year, Half, Delim, _JustNow, Total) when Total div 3600 =< 5 ->
    TotalHr = Total div 3600,
    RemMin = (Total rem 3600) div 60,
    case RemMin =:= 30 of
        true -> resolve_unit(TotalHr, Hour, Locale, Half);
        false ->
            HStr = resolve_unit(TotalHr, Hour, Locale, ""),
            case RemMin > 0 of
                true -> HStr ++ Delim ++ resolve_unit(RemMin, Minute, Locale, "");
                false -> HStr
            end
    end;
format_seconds(Locale, _Second, _Minute, Hour, _Day, _Week, _Month, _Year, _Half, _Delim, _JustNow, Total) when Total < 86400 ->
    TotalHr = Total div 3600,
    resolve_unit(TotalHr, Hour, Locale, "");
format_seconds(Locale, _Second, _Minute, Hour, Day, _Week, _Month, _Year, Half, Delim, _JustNow, Total) when Total div 86400 =< 2 ->
    TotalDays = Total div 86400,
    RemHr = (Total rem 86400) div 3600,
    case RemHr =:= 12 of
        true -> resolve_unit(TotalDays, Day, Locale, Half);
        false ->
            DStr = resolve_unit(TotalDays, Day, Locale, ""),
            case RemHr > 0 of
                true -> DStr ++ Delim ++ resolve_unit(RemHr, Hour, Locale, "");
                false -> DStr
            end
    end;
format_seconds(Locale, _Second, _Minute, _Hour, Day, _Week, _Month, _Year, _Half, _Delim, _JustNow, Total) when Total div 86400 < 7 ->
    TotalDays = Total div 86400,
    resolve_unit(TotalDays, Day, Locale, "");
format_seconds(Locale, _Second, _Minute, _Hour, Day, Week, _Month, _Year, _Half, Delim, _JustNow, Total) when Total div 86400 < 30 ->
    TotalDays = Total div 86400,
    TotalWeeks = TotalDays div 7,
    RemDays = TotalDays rem 7,
    WStr = resolve_unit(TotalWeeks, Week, Locale, ""),
    case RemDays > 0 of
        true -> WStr ++ Delim ++ resolve_unit(RemDays, Day, Locale, "");
        false -> WStr
    end;
format_seconds(Locale, _Second, _Minute, _Hour, _Day, _Week, Month, Year, _Half, Delim, _JustNow, Total) ->
    TotalDays = Total div 86400,
    TotalMonths0 = round(TotalDays / 30.44),
    case TotalMonths0 < 12 of
        true ->
            TotalMonths = case TotalMonths0 =:= 0 of true -> 1; false -> TotalMonths0 end,
            resolve_unit(TotalMonths, Month, Locale, "");
        false ->
            TotalYears = TotalMonths0 div 12,
            RemMonths = TotalMonths0 rem 12,
            YStr = resolve_unit(TotalYears, Year, Locale, ""),
            case RemMonths > 0 of
                true -> YStr ++ Delim ++ resolve_unit(RemMonths, Month, Locale, "");
                false -> YStr
            end
    end.

resolve_unit(Count, UnitForms, Locale, Half) ->
    BaseN = integer_to_list(Count),
    N = case Half =/= "" andalso str_contains(Half, "{n}") of
            true -> str_replace(Half, "{n}", BaseN);
            false -> BaseN
        end,
    Plural = Locale#duration_locale.plural,
    Category = case Half =/= "" of
                   true -> other;
                   false -> Plural(Count)
               end,
    Template = case UnitForms of
                   {simple, S} -> S;
                   {pluralized, Forms} -> lookup_unit_form(Category, Forms)
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
               short -> Locale#duration_locale.short;
               compact -> Locale#duration_locale.compact
           end,
    case MOvr of
        nothing ->
            {Locale#duration_locale.second,
             Locale#duration_locale.minute,
             Locale#duration_locale.hour,
             Locale#duration_locale.day,
             Locale#duration_locale.week,
             Locale#duration_locale.month,
             Locale#duration_locale.year,
             Locale#duration_locale.half,
             Locale#duration_locale.delimiter,
             Locale#duration_locale.just_now,
             Locale#duration_locale.ago,
             Locale#duration_locale.in_future};
        {just, Ovr} ->
            {ovr_or(Ovr#duration_compactness_override.second, Locale#duration_locale.second),
             ovr_or(Ovr#duration_compactness_override.minute, Locale#duration_locale.minute),
             ovr_or(Ovr#duration_compactness_override.hour, Locale#duration_locale.hour),
             ovr_or(Ovr#duration_compactness_override.day, Locale#duration_locale.day),
             ovr_or(Ovr#duration_compactness_override.week, Locale#duration_locale.week),
             ovr_or(Ovr#duration_compactness_override.month, Locale#duration_locale.month),
             ovr_or(Ovr#duration_compactness_override.year, Locale#duration_locale.year),
             ovr_or_str(Ovr#duration_compactness_override.half, Locale#duration_locale.half),
             ovr_or_str(Ovr#duration_compactness_override.delimiter, Locale#duration_locale.delimiter),
             Locale#duration_locale.just_now,
             ovr_or_str(Ovr#duration_compactness_override.ago, Locale#duration_locale.ago),
             ovr_or_str(Ovr#duration_compactness_override.in_future, Locale#duration_locale.in_future)}
    end.

ovr_or(nothing, Default) -> Default;
ovr_or({just, Val}, _Default) -> Val.

ovr_or_str(nothing, Default) -> Default;
ovr_or_str({just, Val}, _Default) -> Val.

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
