-module(sayableduration_test).
-include_lib("eunit/include/eunit.hrl").
-include("sayableduration.hrl").

%% Helpers
dur(Seconds) -> sayableduration:format_duration(sayableduration_locales_en:locale(), normal, Seconds, undefined).
dur_ts(Start, End) -> sayableduration:format_duration(sayableduration_locales_en:locale(), normal, Start, End).
dur_short(Seconds) -> sayableduration:format_duration(sayableduration_locales_en:locale(), short, Seconds, undefined).
dur_compact(Seconds) -> sayableduration:format_duration(sayableduration_locales_en:locale(), compact, Seconds, undefined).
since(Start, AsOf) -> sayableduration:format_since(sayableduration_locales_en:locale(), normal, Start, AsOf).
until(Target, AsOf) -> sayableduration:format_until(sayableduration_locales_en:locale(), normal, Target, AsOf).
dur_locale(Locale, Seconds) -> sayableduration:format_duration(Locale, normal, Seconds, undefined).
since_locale(Locale, Start, AsOf) -> sayableduration:format_since(Locale, normal, Start, AsOf).

%% 1. Null / edge cases
null_edge_test_() ->
    [?_assertEqual(error, dur(undefined)),                                      %% 1.1
     ?_assertEqual(error, dur(-1)),                                             %% 1.2
     ?_assertEqual(error, since(undefined, "2025-01-15T10:00:00")),             %% 1.3
     ?_assertEqual(error, until(undefined, "2025-01-15T10:00:00")),             %% 1.4
     ?_assertEqual(error, since("2025-01-15T10:00:00", "2025-01-15T09:00:00")), %% 1.5
     ?_assertEqual(error, until("2025-01-15T09:00:00", "2025-01-15T10:00:00"))  %% 1.6
    ].

%% 2. Duration — seconds tier (0-59s)
seconds_tier_test_() ->
    [?_assertEqual({ok, "just now"}, dur(0)),                                   %% 2.1
     ?_assertEqual({ok, "1 second"}, dur(1)),                                   %% 2.2
     ?_assertEqual({ok, "45 seconds"}, dur(45)),                                %% 2.3
     ?_assertEqual({ok, "59 seconds"}, dur(59))                                 %% 2.4
    ].

%% 3. Duration — minutes + seconds tier (1-4 min)
minutes_seconds_tier_test_() ->
    [?_assertEqual({ok, "1 minute"}, dur(60)),                                  %% 3.1
     ?_assertEqual({ok, "1 minute, 30 seconds"}, dur(90)),                      %% 3.2
     ?_assertEqual({ok, "4 minutes"}, dur(240)),                                %% 3.3
     ?_assertEqual({ok, "4 minutes, 30 seconds"}, dur(270))                     %% 3.4
    ].

%% 4. Duration — minutes tier (5-59 min)
minutes_tier_test_() ->
    [?_assertEqual({ok, "5 minutes"}, dur(300)),                                %% 4.1
     ?_assertEqual({ok, "25 minutes"}, dur(1500)),                              %% 4.2
     ?_assertEqual({ok, "59 minutes"}, dur(3540))                               %% 4.3
    ].

%% 5. Duration — hours + minutes tier (1-5 hr)
hours_minutes_tier_test_() ->
    [?_assertEqual({ok, "1 hour"}, dur(3600)),                                  %% 5.1
     ?_assertEqual({ok, "1½ hours"}, dur(5400)),                                %% 5.2
     ?_assertEqual({ok, "2 hours, 15 minutes"}, dur(8100)),                     %% 5.3
     ?_assertEqual({ok, "5 hours"}, dur(18000))                                 %% 5.4
    ].

%% 6. Duration — hours tier (6-23 hr)
hours_tier_test_() ->
    [?_assertEqual({ok, "8 hours"}, dur(28800)),                                %% 6.1
     ?_assertEqual({ok, "23 hours"}, dur(82800))                                %% 6.2
    ].

%% 7. Duration — days tier
days_tier_test_() ->
    [?_assertEqual({ok, "1 day"}, dur(86400)),                                  %% 7.1
     ?_assertEqual({ok, "1 day, 3 hours"}, dur(97200)),                         %% 7.2
     ?_assertEqual({ok, "1½ days"}, dur(129600)),                               %% 7.3
     ?_assertEqual({ok, "5 days"}, dur(432000)),                                %% 7.4
     ?_assertEqual({ok, "2 days"}, dur(172800))                                 %% 7.5
    ].

%% 8. Duration — weeks tier
weeks_tier_test_() ->
    [?_assertEqual({ok, "1 week"}, dur(604800)),                                %% 8.1
     ?_assertEqual({ok, "2 weeks, 1 day"}, dur(1296000)),                       %% 8.2
     ?_assertEqual({ok, "4 weeks"}, dur(2419200))                               %% 8.3
    ].

%% 9. Duration — months and years tier
months_years_tier_test_() ->
    [?_assertEqual({ok, "1 month"}, dur(2678400)),                              %% 9.1
     ?_assertEqual({ok, "3 months"}, dur(7884000)),                             %% 9.2
     ?_assertEqual({ok, "1 year"}, dur(31536000)),                              %% 9.3
     ?_assertEqual({ok, "1 year, 3 months"}, dur(39420000))                     %% 9.4
    ].

%% 10. Duration from ISO timestamps
iso_timestamps_test_() ->
    [?_assertEqual({ok, "1½ hours"}, dur_ts("2025-01-15T10:00:00", "2025-01-15T11:30:00")),  %% 10.1
     ?_assertEqual({ok, "45 minutes"}, dur_ts("2025-01-15T10:00:00", "2025-01-15T10:45:00")) %% 10.2
    ].

%% 11. Relative time — since
since_test_() ->
    [?_assertEqual({ok, "just now"}, since("2025-01-15T10:00:00", "2025-01-15T10:00:00")),     %% 11.1
     ?_assertEqual({ok, "30 seconds ago"}, since("2025-01-15T10:00:00", "2025-01-15T10:00:30")), %% 11.2
     ?_assertEqual({ok, "45 minutes ago"}, since("2025-01-15T10:00:00", "2025-01-15T10:45:00")), %% 11.3
     ?_assertEqual({ok, "3 hours ago"}, since("2025-01-15T10:00:00", "2025-01-15T13:00:00"))   %% 11.4
    ].

%% 12. Relative time — until
until_test_() ->
    [?_assertEqual({ok, "just now"}, until("2025-01-15T10:00:00", "2025-01-15T10:00:00")),     %% 12.1
     ?_assertEqual({ok, "in 20 minutes"}, until("2025-01-15T10:20:00", "2025-01-15T10:00:00")), %% 12.2
     ?_assertEqual({ok, "in 3 hours"}, until("2025-01-15T13:00:00", "2025-01-15T10:00:00"))    %% 12.3
    ].

%% 13. Locale — German
german_test_() ->
    De = sayableduration_locales_de:locale(),
    [?_assertEqual({ok, "1 Stunde"}, dur_locale(De, 3600)),                     %% 13.1
     ?_assertEqual({ok, "vor 5 Minuten"}, since_locale(De, "2025-01-15T10:00:00", "2025-01-15T10:05:00")) %% 13.2
    ].

%% 14. Locale — French
french_test_() ->
    Fr = sayableduration_locales_fr:locale(),
    [?_assertEqual({ok, "2 heures"}, dur_locale(Fr, 7200))                      %% 14.1
    ].

%% 15. Locale — Japanese
japanese_test_() ->
    Ja = sayableduration_locales_ja:locale(),
    [?_assertEqual({ok, "2分"}, dur_locale(Ja, 120)),                           %% 15.1
     ?_assertEqual({ok, "1時間前"}, since_locale(Ja, "2025-01-15T10:00:00", "2025-01-15T11:00:00")) %% 15.2
    ].

%% 16. Short compactness — duration
short_test_() ->
    [?_assertEqual({ok, "1h"}, dur_short(3600)),                                %% 16.1
     ?_assertEqual({ok, "1m, 30s"}, dur_short(90))                              %% 16.2
    ].

%% 17. Compact compactness — duration
compact_test_() ->
    [?_assertEqual({ok, "1h"}, dur_compact(3600)),                              %% 17.1
     ?_assertEqual({ok, "1m30s"}, dur_compact(90))                              %% 17.2
    ].

%% 18. Short compactness — relative time
since_short_test_() ->
    [?_assertEqual({ok, "lɔhɔnga 2, awa 14 taa gbɔyɔ"},
                   sayableduration:format_since(sayableduration_locales_men:locale(), short,
                                                "2025-01-20T01:32:11", "2025-01-22T15:39:16"))     %% 18.1
    ].

%% 19. Range (500-year ceiling)
ceiling_test_() ->
    [?_assertEqual({ok, "500 years"}, dur(15778800000)),                                   %% 19.1
     ?_assertEqual(error, dur(15800000000)),                                               %% 19.2
     ?_assertEqual(error, dur(99999999999)),                                               %% 19.3
     ?_assertEqual(error, since("1500-01-01T00:00:00", "2025-01-01T00:00:00")),            %% 19.4
     ?_assertEqual(error, until("2600-01-01T00:00:00", "2025-01-01T00:00:00"))             %% 19.5
    ].

%% 20. Timestamp validation
timestamp_validation_test_() ->
    [?_assertEqual({ok, "1½ hours"}, dur_ts("2025-01-15T10:00", "2025-01-15T11:30:00")),   %% 20.1
     ?_assertEqual(error, dur_ts("2025-01-15T10", "2025-01-15T11:30:00")),                 %% 20.2
     ?_assertEqual(error, dur_ts("2025-1-5T10:00:00", "2025-01-15T11:30:00")),             %% 20.3
     ?_assertEqual(error, dur_ts("2025-02-30T10:00:00", "2025-03-15T11:30:00")),           %% 20.4
     ?_assertEqual(error, since("2025-01-15T10:00:00", "2025-01-15T25:00:00"))             %% 20.5
    ].

%% Locale lookup
locale_lookup_test_() ->
    [?_assertMatch({ok, #duration_locale{code = "en"}}, sayableduration:get_locale("en")),
     ?_assertMatch({ok, #duration_locale{code = "fr"}}, sayableduration:get_locale("fr")),
     ?_assertEqual(error, sayableduration:get_locale("xx")),
     ?_assertEqual(error, sayableduration:get_locale(""))
    ].
