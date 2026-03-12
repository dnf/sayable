-module(sayabletime_formatter).
-include("sayabletime.hrl").
-export([format_time/3]).

-spec format_time(#time_locale{}, compactness(), string() | undefined) -> {ok, string()} | error.
format_time(_Locale, _Compactness, undefined) -> error;
format_time(_Locale, _Compactness, []) -> error;
format_time(Locale, Compactness, Input) ->
    case sayabletime_internal:parse_time(Input) of
        {ok, {Hour, Minute}} ->
            ShortClock = resolve_short_clock(Locale, Compactness),
            case Compactness =/= normal andalso ShortClock =/= nothing of
                true ->
                    {just, SC} = ShortClock,
                    {ok, format_digital(Hour, Minute, SC)};
                false ->
                    {ok, format_natural(Hour, Minute, Locale#time_locale.clock)}
            end;
        error -> error
    end.

%% Internal

format_natural(Hour, Minute, Clock) ->
    Rounded = sayabletime_internal:round_to_5(Minute),
    {R, H} = case Rounded of
                 60 -> {0, (Hour + 1) rem 24};
                 _ -> {Rounded, Hour}
             end,
    case R =:= 0 of
        true ->
            case H of
                0 -> Clock#clock_config.midnight;
                12 -> Clock#clock_config.noon;
                _ ->
                    H12 = H rem 12,
                    HName = lists:nth(H12 + 1, Clock#clock_config.hours),
                    Pattern = lookup_pattern(0, Clock#clock_config.patterns),
                    str_replace(Pattern, "{h}", HName)
            end;
        false ->
            H12 = H rem 12,
            NextH12 = (H + 1) rem 12,
            HName = lists:nth(H12 + 1, Clock#clock_config.hours),
            NextHName = lists:nth(NextH12 + 1, Clock#clock_config.hours),
            Pattern = lookup_pattern(R, Clock#clock_config.patterns),
            R1 = str_replace(Pattern, "{h}", HName),
            str_replace(R1, "{next_h}", NextHName)
    end.

format_digital(Hour, Minute, SC) ->
    Fmt = SC#short_clock_config.format,
    case SC#short_clock_config.use24h of
        true ->
            R1 = str_replace(Fmt, "{h}", integer_to_list(Hour)),
            str_replace(R1, "{mm}", pad2(Minute));
        false ->
            H12 = Hour rem 12,
            H12Adj = case H12 of 0 -> 12; _ -> H12 end,
            {AmStr, PmStr} = case SC#short_clock_config.am_pm of
                                 {just, {A, P}} -> {A, P};
                                 nothing -> {"AM", "PM"}
                             end,
            AmPm = case Hour < 12 of true -> AmStr; false -> PmStr end,
            R1 = str_replace(Fmt, "{h}", integer_to_list(H12Adj)),
            R2 = str_replace(R1, "{mm}", pad2(Minute)),
            str_replace(R2, "{ampm}", AmPm)
    end.

resolve_short_clock(Locale, Compactness) ->
    MOvr = case Compactness of
               normal -> nothing;
               short -> Locale#time_locale.short;
               compact -> Locale#time_locale.compact
           end,
    case MOvr of
        nothing -> nothing;
        {just, Ovr} -> Ovr#time_compactness_override.clock
    end.

lookup_pattern(Key, Patterns) ->
    case lists:keyfind(Key, 1, Patterns) of
        {Key, P} -> P;
        false ->
            case lists:keyfind(0, 1, Patterns) of
                {0, P} -> P;
                false -> "{h}"
            end
    end.

pad2(N) when N < 10 -> [$0 | integer_to_list(N)];
pad2(N) -> integer_to_list(N).

str_replace(Haystack, Needle, Replacement) ->
    NLen = length(Needle),
    str_replace(Haystack, Needle, Replacement, NLen).

str_replace([], _Needle, _Replacement, _NLen) -> [];
str_replace(Haystack, Needle, Replacement, NLen) ->
    case lists:prefix(Needle, Haystack) of
        true -> Replacement ++ str_replace(lists:nthtail(NLen, Haystack), Needle, Replacement, NLen);
        false -> [hd(Haystack) | str_replace(tl(Haystack), Needle, Replacement, NLen)]
    end.
