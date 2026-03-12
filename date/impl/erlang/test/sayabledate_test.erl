-module(sayabledate_test).
-include_lib("eunit/include/eunit.hrl").
-include("sayabledate.hrl").

%% Helpers
fmt(Date) -> sayabledate:format_date(sayabledate_locales_en:locale(), normal, Date).
fmt_short(Date) -> sayabledate:format_date(sayabledate_locales_en:locale(), short, Date).
fmt_compact(Date) -> sayabledate:format_date(sayabledate_locales_en:locale(), compact, Date).
rel(Date, AsOf) -> sayabledate:format_relative(sayabledate_locales_en:locale(), normal, Date, AsOf).
rel_compact(Date, AsOf) -> sayabledate:format_relative(sayabledate_locales_en:locale(), compact, Date, AsOf).
fmt_locale(Locale, Date) -> sayabledate:format_date(Locale, normal, Date).
rel_locale(Locale, Date, AsOf) -> sayabledate:format_relative(Locale, normal, Date, AsOf).

%% 1. Null / edge cases
null_edge_test_() ->
    [?_assertEqual(error, fmt(undefined)),                                      %% 1.1
     ?_assertEqual(error, fmt("")),                                             %% 1.2
     ?_assertEqual(error, fmt("invalid")),                                      %% 1.3
     ?_assertEqual(error, rel("2025-03-15", undefined)),                        %% 1.4
     ?_assertEqual(error, rel(undefined, "2025-03-15"))                         %% 1.5
    ].

%% 2. format_date — normal compactness (English)
format_date_normal_test_() ->
    [?_assertEqual({ok, "March 15th"}, fmt("2025-03-15")),                      %% 2.1
     ?_assertEqual({ok, "January 1st"}, fmt("2025-01-01")),                     %% 2.2
     ?_assertEqual({ok, "May 22nd"}, fmt("2025-05-22")),                        %% 2.3
     ?_assertEqual({ok, "July 3rd"}, fmt("2025-07-03")),                        %% 2.4
     ?_assertEqual({ok, "December 31st"}, fmt("2025-12-31")),                   %% 2.5
     ?_assertEqual({ok, "June 11th"}, fmt("2025-06-11")),                       %% 2.6
     ?_assertEqual({ok, "March 15th"}, fmt("2025-03-15T14:30:00"))              %% 2.7
    ].

%% 3. format_date — short compactness (English)
format_date_short_test_() ->
    [?_assertEqual({ok, "Mar 15"}, fmt_short("2025-03-15")),                    %% 3.1
     ?_assertEqual({ok, "Jan 1"}, fmt_short("2025-01-01")),                     %% 3.2
     ?_assertEqual({ok, "Dec 25"}, fmt_short("2025-12-25"))                     %% 3.3
    ].

%% 4. format_date — compact (English)
format_date_compact_test_() ->
    [?_assertEqual({ok, "3/15"}, fmt_compact("2025-03-15")),                    %% 4.1
     ?_assertEqual({ok, "1/1"}, fmt_compact("2025-01-01"))                      %% 4.2
    ].

%% 5. format_relative — proximity tiers (English)
format_relative_test_() ->
    [?_assertEqual({ok, "today"}, rel("2025-03-15", "2025-03-15")),             %% 5.1
     ?_assertEqual({ok, "tomorrow"}, rel("2025-03-16", "2025-03-15")),          %% 5.2
     ?_assertEqual({ok, "yesterday"}, rel("2025-03-14", "2025-03-15")),         %% 5.3
     ?_assertEqual({ok, "the day after tomorrow"}, rel("2025-03-17", "2025-03-15")), %% 5.4
     ?_assertEqual({ok, "the day before yesterday"}, rel("2025-03-13", "2025-03-15")), %% 5.5
     ?_assertEqual({ok, "this Wednesday"}, rel("2025-03-19", "2025-03-15")),    %% 5.6
     ?_assertEqual({ok, "this Thursday"}, rel("2025-03-20", "2025-03-15")),     %% 5.7
     ?_assertEqual({ok, "last Tuesday"}, rel("2025-03-11", "2025-03-15")),      %% 5.8
     ?_assertEqual({ok, "next Saturday"}, rel("2025-03-22", "2025-03-15")),     %% 5.9
     ?_assertEqual({ok, "next Thursday"}, rel("2025-03-27", "2025-03-15")),     %% 5.10
     ?_assertEqual({ok, "March 1st"}, rel("2025-03-01", "2025-03-15")),         %% 5.11
     ?_assertEqual({ok, "April 10th"}, rel("2025-04-10", "2025-03-15")),        %% 5.12
     ?_assertEqual({ok, "January 5th, 2026"}, rel("2026-01-05", "2025-03-15")), %% 5.13
     ?_assertEqual({ok, "December 25th, 2024"}, rel("2024-12-25", "2025-03-15")) %% 5.14
    ].

%% 6. format_relative — compact skips weekday tiers
format_relative_compact_test_() ->
    [?_assertEqual({ok, "today"}, rel_compact("2025-03-15", "2025-03-15")),     %% 6.1
     ?_assertEqual({ok, "tomorrow"}, rel_compact("2025-03-16", "2025-03-15")),  %% 6.2
     ?_assertEqual({ok, "3/19"}, rel_compact("2025-03-19", "2025-03-15")),      %% 6.3
     ?_assertEqual({ok, "1/5/26"}, rel_compact("2026-01-05", "2025-03-15"))     %% 6.4
    ].

%% 7. Locale — German
german_test_() ->
    De = sayabledate_locales_de:locale(),
    [?_assertEqual({ok, "15. März"}, fmt_locale(De, "2025-03-15")),             %% 7.1
     ?_assertEqual({ok, "morgen"}, rel_locale(De, "2025-03-16", "2025-03-15")), %% 7.2
     ?_assertEqual({ok, "übermorgen"}, rel_locale(De, "2025-03-17", "2025-03-15")), %% 7.3
     ?_assertEqual({ok, "diesen Mittwoch"}, rel_locale(De, "2025-03-19", "2025-03-15")) %% 7.4
    ].

%% 8. Locale — French
french_test_() ->
    Fr = sayabledate_locales_fr:locale(),
    [?_assertEqual({ok, "1er mars"}, fmt_locale(Fr, "2025-03-01")),             %% 8.1
     ?_assertEqual({ok, "15 mars"}, fmt_locale(Fr, "2025-03-15")),              %% 8.2
     ?_assertEqual({ok, "demain"}, rel_locale(Fr, "2025-03-16", "2025-03-15")) %% 8.3
    ].

%% 9. Locale — Japanese
japanese_test_() ->
    Ja = sayabledate_locales_ja:locale(),
    [?_assertEqual({ok, "3月15日"}, fmt_locale(Ja, "2025-03-15")),              %% 9.1
     ?_assertEqual({ok, "明日"}, rel_locale(Ja, "2025-03-16", "2025-03-15")),   %% 9.2
     ?_assertEqual({ok, "今度の水曜日"}, rel_locale(Ja, "2025-03-19", "2025-03-15")) %% 9.3
    ].

%% 10. Locale — Russian (genitive months)
russian_test_() ->
    Ru = sayabledate_locales_ru:locale(),
    [?_assertEqual({ok, "15 марта"}, fmt_locale(Ru, "2025-03-15")),             %% 10.1
     ?_assertEqual({ok, "завтра"}, rel_locale(Ru, "2025-03-16", "2025-03-15")) %% 10.2
    ].

%% 11. Locale — Arabic
arabic_test_() ->
    Ar = sayabledate_locales_ar:locale(),
    [?_assertEqual({ok, "15 مارس"}, fmt_locale(Ar, "2025-03-15")),              %% 11.1
     ?_assertEqual({ok, "غداً"}, rel_locale(Ar, "2025-03-16", "2025-03-15"))    %% 11.2
    ].

%% 12. Locale — Spanish
spanish_test_() ->
    Es = sayabledate_locales_es:locale(),
    [?_assertEqual({ok, "15 de marzo"}, fmt_locale(Es, "2025-03-15")),          %% 12.1
     ?_assertEqual({ok, "pasado mañana"}, rel_locale(Es, "2025-03-17", "2025-03-15")) %% 12.2
    ].

%% Locale lookup
locale_lookup_test_() ->
    [?_assertMatch({ok, #date_locale{code = "en"}}, sayabledate:get_locale("en")),
     ?_assertMatch({ok, #date_locale{code = "fr"}}, sayabledate:get_locale("fr")),
     ?_assertEqual(error, sayabledate:get_locale("xx")),
     ?_assertEqual(error, sayabledate:get_locale(""))
    ].
