-module(sayabletime_test).
-include_lib("eunit/include/eunit.hrl").
-include("sayabletime.hrl").

%% Helpers
fmt(Time) -> sayabletime:format_time(sayabletime_locales_en:locale(), normal, Time).
fmt_short(Time) -> sayabletime:format_time(sayabletime_locales_en:locale(), short, Time).
fmt_compact(Time) -> sayabletime:format_time(sayabletime_locales_en:locale(), compact, Time).
fmt_locale(Locale, Time) -> sayabletime:format_time(Locale, normal, Time).

%% 1. Null / edge cases
null_edge_test_() ->
    [?_assertEqual(error, fmt(undefined)),                                      %% 1.1
     ?_assertEqual(error, fmt("")),                                             %% 1.2
     ?_assertEqual(error, fmt("invalid")),                                      %% 1.3
     ?_assertEqual(error, fmt("25:00"))                                         %% 1.4
    ].

%% 2. Clock time (normal compactness)
clock_normal_test_() ->
    [?_assertEqual({ok, "midnight"}, fmt("00:00")),                             %% 2.1
     ?_assertEqual({ok, "noon"}, fmt("12:00")),                                 %% 2.2
     ?_assertEqual({ok, "three o'clock"}, fmt("15:00")),                        %% 2.3
     ?_assertEqual({ok, "a quarter past two"}, fmt("14:15")),                   %% 2.4
     ?_assertEqual({ok, "half past nine"}, fmt("09:30")),                       %% 2.5
     ?_assertEqual({ok, "a quarter to eleven"}, fmt("10:45")),                  %% 2.6
     ?_assertEqual({ok, "five past eight"}, fmt("08:05")),                      %% 2.7
     ?_assertEqual({ok, "five to five"}, fmt("16:55")),                         %% 2.8
     ?_assertEqual({ok, "midnight"}, fmt("23:58")),                             %% 2.9
     ?_assertEqual({ok, "twenty past seven"}, fmt("07:22")),                    %% 2.10
     ?_assertEqual({ok, "a quarter past two"}, fmt("2025-01-15T14:15:00"))      %% 2.11
    ].

%% 3. Clock time (short compactness)
clock_short_test_() ->
    [?_assertEqual({ok, "2:15 PM"}, fmt_short("14:15")),                        %% 3.1
     ?_assertEqual({ok, "9:30 AM"}, fmt_short("09:30")),                        %% 3.2
     ?_assertEqual({ok, "12:00 AM"}, fmt_short("00:00")),                       %% 3.3
     ?_assertEqual({ok, "12:00 PM"}, fmt_short("12:00"))                        %% 3.4
    ].

%% 4. Clock time (compact)
clock_compact_test_() ->
    [?_assertEqual({ok, "2:15p"}, fmt_compact("14:15")),                        %% 4.1
     ?_assertEqual({ok, "9:30a"}, fmt_compact("09:30"))                         %% 4.2
    ].

%% 5. Locale — German
german_test_() ->
    De = sayabletime_locales_de:locale(),
    [?_assertEqual({ok, "halb vier"}, fmt_locale(De, "15:30"))                  %% 5.1
    ].

%% 6. Locale — French
french_test_() ->
    Fr = sayabletime_locales_fr:locale(),
    [?_assertEqual({ok, "trois heures et quart"}, fmt_locale(Fr, "15:15"))      %% 6.1
    ].

%% 7. Locale — Japanese
japanese_test_() ->
    Ja = sayabletime_locales_ja:locale(),
    [?_assertEqual({ok, "三時半"}, fmt_locale(Ja, "15:30"))                     %% 7.1
    ].

%% 8. Locale — Finnish (dot separator, short)
finnish_dot_test_() ->
    Fi = sayabletime_locales_fi:locale(),
    [?_assertEqual({ok, "14.15"}, sayabletime:format_time(Fi, short, "14:15")),  %% 8.1
     ?_assertEqual({ok, "0.00"}, sayabletime:format_time(Fi, short, "00:00"))    %% 8.2
    ].

%% 9. Minutes in short and compact modes
exact_minutes_test_() ->
    [?_assertEqual({ok, "6:01 PM"}, fmt_short("18:01")),                        %% 9.1
     ?_assertEqual({ok, "7:05p"}, fmt_compact("19:05"))                         %% 9.2
    ].

%% 10. Input validation
input_validation_test_() ->
    [?_assertEqual({ok, "half past nine"}, fmt("9:30")),                        %% 10.1
     ?_assertEqual({ok, "half past nine"}, fmt("09:30")),                       %% 10.2
     ?_assertEqual(error, fmt(" 9:30")),                                        %% 10.3
     ?_assertEqual(error, fmt("9:30 ")),                                        %% 10.4
     ?_assertEqual(error, fmt("9:5")),                                          %% 10.5
     ?_assertEqual(error, fmt("24:00")),                                        %% 10.6
     ?_assertEqual({ok, "a quarter past two"}, fmt("14:15:30")),                %% 10.7
     ?_assertEqual({ok, "a quarter past two"}, fmt("2025-01-15T14:15:00Z")),    %% 10.8
     ?_assertEqual(error, fmt("2025-02-30T14:15:00"))                           %% 10.9
    ].

%% Locale lookup
locale_lookup_test_() ->
    [?_assertMatch({ok, #time_locale{code = "en"}}, sayabletime:get_locale("en")),
     ?_assertMatch({ok, #time_locale{code = "fr"}}, sayabletime:get_locale("fr")),
     ?_assertEqual(error, sayabletime:get_locale("xx")),
     ?_assertEqual(error, sayabletime:get_locale(""))
    ].
