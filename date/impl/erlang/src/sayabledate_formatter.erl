-module(sayabledate_formatter).
-include("sayabledate.hrl").
-export([format_date/3, format_date_with_year/3, format_relative/4]).

-spec format_date(#date_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_date(_Locale, _Compactness, undefined) -> error;
format_date(_Locale, _Compactness, []) -> error;
format_date(Locale, Compactness, Date) ->
    case sayabledate_internal:parse_date(Date) of
        {ok, {Y, M, D}} ->
            {Months, MonthsInDate, _Weekdays, DayFmt, DayFmtExc, DatePat, _DatePatYear,
             _Today, _Tomorrow, _Yesterday} = resolve_locale(Locale, Compactness),
            {ok, format_absolute(Y, M, D, false, Months, MonthsInDate, DayFmt, DayFmtExc, DatePat, DatePat)};
        error -> error
    end.

-spec format_date_with_year(#date_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_date_with_year(_Locale, _Compactness, undefined) -> error;
format_date_with_year(_Locale, _Compactness, []) -> error;
format_date_with_year(Locale, Compactness, Date) ->
    case sayabledate_internal:parse_date(Date) of
        {ok, {Y, M, D}} ->
            {Months, MonthsInDate, _Weekdays, DayFmt, DayFmtExc, _DatePat, DatePatYear,
             _Today, _Tomorrow, _Yesterday} = resolve_locale(Locale, Compactness),
            {ok, format_absolute(Y, M, D, true, Months, MonthsInDate, DayFmt, DayFmtExc, DatePatYear, DatePatYear)};
        error -> error
    end.

-spec format_relative(#date_locale{}, compactness(), string() | undefined, string() | undefined) -> {ok, string()} | error.
format_relative(_Locale, _Compactness, undefined, _AsOf) -> error;
format_relative(_Locale, _Compactness, [], _AsOf) -> error;
format_relative(_Locale, _Compactness, _Date, undefined) -> error;
format_relative(_Locale, _Compactness, _Date, []) -> error;
format_relative(Locale, Compactness, Date, AsOf) ->
    case {sayabledate_internal:parse_date(Date), sayabledate_internal:parse_date(AsOf)} of
        {{ok, {DY, DM, DD}}, {ok, {AY, AM, AD}}} ->
            DateJdn = sayabledate_internal:to_jdn(DY, DM, DD),
            AsOfJdn = sayabledate_internal:to_jdn(AY, AM, AD),
            Diff = DateJdn - AsOfJdn,
            {Months, MonthsInDate, Weekdays, DayFmt, DayFmtExc, DatePat, DatePatYear,
             Today, Tomorrow, Yesterday} = resolve_locale(Locale, Compactness),
            IsCompact = Compactness =:= compact,
            format_relative_diff(Diff, DY, DM, DD, AY, Locale, IsCompact,
                                 Months, MonthsInDate, Weekdays, DayFmt, DayFmtExc,
                                 DatePat, DatePatYear, Today, Tomorrow, Yesterday);
        _ -> error
    end.

%% Internal

format_relative_diff(0, _DY, _DM, _DD, _AY, _Locale, _IsCompact,
                     _Months, _MonthsInDate, _Weekdays, _DayFmt, _DayFmtExc,
                     _DatePat, _DatePatYear, Today, _Tomorrow, _Yesterday) ->
    {ok, Today};
format_relative_diff(1, _DY, _DM, _DD, _AY, _Locale, _IsCompact,
                     _Months, _MonthsInDate, _Weekdays, _DayFmt, _DayFmtExc,
                     _DatePat, _DatePatYear, _Today, Tomorrow, _Yesterday) ->
    {ok, Tomorrow};
format_relative_diff(-1, _DY, _DM, _DD, _AY, _Locale, _IsCompact,
                     _Months, _MonthsInDate, _Weekdays, _DayFmt, _DayFmtExc,
                     _DatePat, _DatePatYear, _Today, _Tomorrow, Yesterday) ->
    {ok, Yesterday};
format_relative_diff(Diff, DY, DM, DD, AY, Locale, IsCompact,
                     Months, MonthsInDate, Weekdays, DayFmt, DayFmtExc,
                     DatePat, DatePatYear, _Today, _Tomorrow, _Yesterday) ->
    DayAfter = Locale#date_locale.day_after_tomorrow,
    DayBefore = Locale#date_locale.day_before_yesterday,
    ThisWd = Locale#date_locale.this_weekday,
    LastWd = Locale#date_locale.last_weekday,
    NextWd = Locale#date_locale.next_weekday,

    if
        Diff =:= 2, DayAfter =/= nothing, not IsCompact ->
            {just, Val} = DayAfter,
            {ok, Val};
        Diff =:= -2, DayBefore =/= nothing, not IsCompact ->
            {just, Val} = DayBefore,
            {ok, Val};
        IsCompact ->
            IncludeYear = DY =/= AY,
            Pat = case IncludeYear of true -> DatePatYear; false -> DatePat end,
            {ok, format_absolute(DY, DM, DD, IncludeYear, Months, MonthsInDate, DayFmt, DayFmtExc, Pat, Pat)};
        Diff >= 2, Diff =< 6, ThisWd =/= nothing ->
            {just, Pattern} = ThisWd,
            Dow = sayabledate_internal:weekday(DY, DM, DD),
            WeekdayName = lists:nth(Dow + 1, Weekdays),
            {ok, str_replace(Pattern, "{weekday}", WeekdayName)};
        Diff >= -6, Diff =< -2, LastWd =/= nothing ->
            {just, Pattern} = LastWd,
            Dow = sayabledate_internal:weekday(DY, DM, DD),
            WeekdayName = lists:nth(Dow + 1, Weekdays),
            {ok, str_replace(Pattern, "{weekday}", WeekdayName)};
        Diff >= 7, Diff =< 13, NextWd =/= nothing ->
            {just, Pattern} = NextWd,
            Dow = sayabledate_internal:weekday(DY, DM, DD),
            WeekdayName = lists:nth(Dow + 1, Weekdays),
            {ok, str_replace(Pattern, "{weekday}", WeekdayName)};
        true ->
            IncludeYear = DY =/= AY,
            Pat = case IncludeYear of true -> DatePatYear; false -> DatePat end,
            {ok, format_absolute(DY, DM, DD, IncludeYear, Months, MonthsInDate, DayFmt, DayFmtExc, Pat, Pat)}
    end.

format_absolute(Year, Month, Day, IncludeYear, Months, MonthsInDate, DayFmt, DayFmtExc, _Pat, PatternToUse) ->
    DayStr = integer_to_list(Day),
    Fmt = case lists:keyfind(DayStr, 1, DayFmtExc) of
              {DayStr, ExcFmt} -> ExcFmt;
              false -> DayFmt
          end,
    FormattedDay = str_replace(Fmt, "{n}", DayStr),
    MonthNames = case MonthsInDate of
                     nothing -> Months;
                     {just, MID} -> MID
                 end,
    MonthName = lists:nth(Month, MonthNames),
    Result0 = str_replace(PatternToUse, "{month}", MonthName),
    Result1 = str_replace(Result0, "{day}", FormattedDay),
    Result2 = str_replace(Result1, "{d}", DayStr),
    Result3 = str_replace(Result2, "{m}", integer_to_list(Month)),
    case IncludeYear of
        true ->
            Result4 = str_replace(Result3, "{year}", integer_to_list(Year)),
            YY = Year rem 100,
            YYStr = case YY < 10 of
                        true -> [$0 | integer_to_list(YY)];
                        false -> integer_to_list(YY)
                    end,
            str_replace(Result4, "{yy}", YYStr);
        false ->
            Result3
    end.

resolve_locale(Locale, Compactness) ->
    MOvr = case Compactness of
               normal -> nothing;
               short -> Locale#date_locale.short;
               compact -> Locale#date_locale.compact
           end,
    case MOvr of
        nothing ->
            {Locale#date_locale.months,
             Locale#date_locale.months_in_date,
             Locale#date_locale.weekdays,
             Locale#date_locale.day_format,
             Locale#date_locale.day_format_exceptions,
             Locale#date_locale.date_pattern,
             Locale#date_locale.date_pattern_with_year,
             Locale#date_locale.today,
             Locale#date_locale.tomorrow,
             Locale#date_locale.yesterday};
        {just, Ovr} ->
            DayFmt = ovr_or_str(Ovr#date_compactness_override.day_format, Locale#date_locale.day_format),
            DayFmtExc = case Ovr#date_compactness_override.day_format of
                             {just, _} ->
                                 case Ovr#date_compactness_override.day_format_exceptions of
                                     nothing -> [];
                                     {just, V} -> V
                                 end;
                             nothing ->
                                 ovr_or_list(Ovr#date_compactness_override.day_format_exceptions,
                                             Locale#date_locale.day_format_exceptions)
                         end,
            {ovr_or_list(Ovr#date_compactness_override.months, Locale#date_locale.months),
             ovr_or_opt(Ovr#date_compactness_override.months_in_date, Locale#date_locale.months_in_date),
             ovr_or_list(Ovr#date_compactness_override.weekdays, Locale#date_locale.weekdays),
             DayFmt,
             DayFmtExc,
             ovr_or_str(Ovr#date_compactness_override.date_pattern, Locale#date_locale.date_pattern),
             ovr_or_str(Ovr#date_compactness_override.date_pattern_with_year, Locale#date_locale.date_pattern_with_year),
             ovr_or_str(Ovr#date_compactness_override.today, Locale#date_locale.today),
             ovr_or_str(Ovr#date_compactness_override.tomorrow, Locale#date_locale.tomorrow),
             ovr_or_str(Ovr#date_compactness_override.yesterday, Locale#date_locale.yesterday)}
    end.

ovr_or_str(nothing, Default) -> Default;
ovr_or_str({just, Val}, _Default) -> Val.

ovr_or_list(nothing, Default) -> Default;
ovr_or_list({just, Val}, _Default) -> Val.

ovr_or_opt(nothing, Default) -> Default;
ovr_or_opt({just, Val}, _Default) -> {just, Val}.

str_replace(Haystack, Needle, Replacement) ->
    NLen = length(Needle),
    str_replace(Haystack, Needle, Replacement, NLen).

str_replace([], _Needle, _Replacement, _NLen) -> [];
str_replace(Haystack, Needle, Replacement, NLen) ->
    case lists:prefix(Needle, Haystack) of
        true -> Replacement ++ str_replace(lists:nthtail(NLen, Haystack), Needle, Replacement, NLen);
        false -> [hd(Haystack) | str_replace(tl(Haystack), Needle, Replacement, NLen)]
    end.
