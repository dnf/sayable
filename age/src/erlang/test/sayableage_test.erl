-module(sayableage_test).
-include_lib("eunit/include/eunit.hrl").
-include("sayableage.hrl").

%% Helpers
age(DOB, AsOf) -> sayableage:format_age_pure(sayableage_locales_en:locale(), normal, DOB, AsOf).
age_short(DOB, AsOf) -> sayableage:format_age_pure(sayableage_locales_en:locale(), short, DOB, AsOf).
age_compact(DOB, AsOf) -> sayableage:format_age_pure(sayableage_locales_en:locale(), compact, DOB, AsOf).
age_locale(Locale, DOB, AsOf) -> sayableage:format_age_pure(Locale, normal, DOB, AsOf).
stage(DOB, AsOf) -> sayableage:format_stage_pure(sayableage_locales_en:locale(), DOB, AsOf, undefined).
stage_locale(Locale, DOB, AsOf, Gender) -> sayableage:format_stage_pure(Locale, DOB, AsOf, Gender).

contains_week(Result) ->
    case Result of
        {ok, S} -> string:find(S, "week") =/= nomatch;
        error -> false
    end.

%% 1. Null / edge cases
null_edge_test_() ->
    [?_assertEqual(error, age("", "2025-06-15")),                           %% 1.1/1.3
     ?_assertEqual(error, age("", "2025-06-15")),                           %% 1.2
     ?_assertEqual(error, age("2025-07-01", "2025-06-15")),                 %% 1.4
     ?_assertEqual({ok, "500 years"}, age("1525-06-15", "2025-06-15")),     %% 1.5
     ?_assertEqual(error, age("1524-06-15", "2025-06-15")),                 %% 1.6
     ?_assertEqual(error, age("1025-06-15", "2025-06-15"))                  %% 1.7
    ].

%% 2. Days tier (0-6 days)
days_tier_test_() ->
    [?_assertEqual({ok, "Newborn"}, age("2025-06-15", "2025-06-15")),       %% 2.1
     ?_assertEqual({ok, "1 day"}, age("2025-06-14", "2025-06-15")),         %% 2.2
     ?_assertEqual({ok, "3 days"}, age("2025-06-12", "2025-06-15")),        %% 2.3
     ?_assertEqual({ok, "6 days"}, age("2025-06-09", "2025-06-15")),        %% 2.4
     ?_assertEqual({ok, "1 week"}, age("2025-06-08", "2025-06-15"))         %% 2.5
    ].

%% 3. Weeks+days tier
weeks_days_tier_test_() ->
    [?_assertEqual({ok, "1 week"}, age("2025-06-08", "2025-06-15")),              %% 3.1
     ?_assertEqual({ok, "1 week, 1 day"}, age("2025-06-07", "2025-06-15")),       %% 3.2
     ?_assertEqual({ok, "1 week, 2 days"}, age("2025-06-06", "2025-06-15")),      %% 3.3
     ?_assertEqual({ok, "1 week, 6 days"}, age("2025-06-02", "2025-06-15")),      %% 3.4
     ?_assertEqual({ok, "2 weeks"}, age("2025-06-01", "2025-06-15")),             %% 3.5
     ?_assertEqual({ok, "2 weeks, 1 day"}, age("2025-05-31", "2025-06-15")),      %% 3.6
     ?_assertEqual({ok, "2 weeks, 6 days"}, age("2025-05-26", "2025-06-15")),     %% 3.7
     ?_assertEqual({ok, "3 weeks"}, age("2025-05-25", "2025-06-15")),             %% 3.8
     ?_assertEqual({ok, "4 weeks, 3 days"}, age("2025-05-15", "2025-06-15")),     %% 3.9
     ?_assertEqual({ok, "8 weeks, 5 days"}, age("2025-04-15", "2025-06-15")),     %% 3.10
     ?_assertEqual({ok, "13 weeks"}, age("2025-03-15", "2025-06-14")),            %% 3.11
     ?_assertEqual({ok, "3 months"}, age("2025-03-15", "2025-06-15"))             %% 3.12
    ].

%% 4. Month boundaries - standard months
month_boundaries_standard_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2025-01-01", "2025-04-01")),      %% 4.1
     ?_assert(contains_week(age("2025-01-01", "2025-03-31"))),              %% 4.2
     ?_assertEqual({ok, "3 months"}, age("2025-06-15", "2025-09-15")),      %% 4.3
     ?_assert(contains_week(age("2025-06-15", "2025-09-14"))),              %% 4.4
     ?_assertEqual({ok, "6 months"}, age("2025-06-15", "2025-12-15"))       %% 4.5
    ].

%% 5. Month boundaries - Feb non-leap
month_boundaries_feb_nonleap_test_() ->
    [?_assertEqual({ok, "4 weeks"}, age("2025-01-31", "2025-02-28")),       %% 5.1
     ?_assertEqual({ok, "3 months"}, age("2025-01-31", "2025-04-30")),      %% 5.2
     ?_assert(contains_week(age("2025-01-31", "2025-04-29"))),              %% 5.3
     ?_assertEqual({ok, "3 months"}, age("2025-02-01", "2025-05-01")),      %% 5.4
     ?_assert(contains_week(age("2025-02-01", "2025-04-30")))               %% 5.5
    ].

%% 6. Month boundaries - Feb leap year
month_boundaries_feb_leap_test_() ->
    [?_assertEqual({ok, "4 weeks, 1 day"}, age("2024-01-31", "2024-02-29")),%% 6.1
     ?_assertEqual({ok, "4 weeks"}, age("2024-01-31", "2024-02-28")),       %% 6.2
     ?_assertEqual({ok, "3 months"}, age("2024-01-31", "2024-04-30")),      %% 6.3
     ?_assert(contains_week(age("2024-01-30", "2024-02-29"))),              %% 6.4
     ?_assert(contains_week(age("2024-01-30", "2024-02-28")))               %% 6.5
    ].

%% 7. Month boundaries - 30-day months
month_boundaries_30day_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2025-03-31", "2025-06-30")),      %% 7.1
     ?_assert(contains_week(age("2025-03-31", "2025-06-29"))),              %% 7.2
     ?_assertEqual({ok, "3 months"}, age("2025-08-31", "2025-11-30")),      %% 7.3
     ?_assert(contains_week(age("2025-08-31", "2025-11-29")))               %% 7.4
    ].

%% 8. Leap year baby
leap_year_baby_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2024-02-29", "2024-05-29")),      %% 8.1
     ?_assert(contains_week(age("2024-02-29", "2024-05-28"))),              %% 8.2
     ?_assertEqual({ok, "12 months"}, age("2024-02-29", "2025-02-28")),     %% 8.3
     ?_assertEqual({ok, "12 months"}, age("2024-02-29", "2025-03-01"))      %% 8.4
    ].

%% 9. Months tier (3-23 months)
months_tier_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2025-01-15", "2025-04-15")),      %% 9.1
     ?_assertEqual({ok, "6 months"}, age("2025-01-15", "2025-07-15")),      %% 9.2
     ?_assertEqual({ok, "12 months"}, age("2024-06-15", "2025-06-15")),     %% 9.3
     ?_assertEqual({ok, "23 months"}, age("2024-01-15", "2025-12-15")),     %% 9.4
     ?_assertEqual({ok, "5 months"}, age("2025-01-15", "2025-07-14")),      %% 9.5
     ?_assertEqual({ok, "5 months"}, age("2024-11-10", "2025-04-10"))       %% 9.6
    ].

%% 10. Years+months tier (24-35 months)
years_months_tier_test_() ->
    [?_assertEqual({ok, "2 years"}, age("2023-06-15", "2025-06-15")),             %% 10.1
     ?_assertEqual({ok, "2 years, 1 month"}, age("2023-06-15", "2025-07-15")),    %% 10.2
     ?_assertEqual({ok, "2 years, 6 months"}, age("2023-06-15", "2025-12-15")),   %% 10.3
     ?_assertEqual({ok, "2 years, 11 months"}, age("2023-06-15", "2026-05-15")),  %% 10.4
     ?_assertEqual({ok, "23 months"}, age("2023-06-15", "2025-06-14"))            %% 10.5
    ].

%% 11. Half-year tier (3-6 years)
half_year_tier_test_() ->
    [?_assertEqual({ok, "3 years"}, age("2022-06-15", "2025-06-15")),           %% 11.1
     ?_assertEqual({ok, "3 years"}, age("2022-06-15", "2025-11-15")),           %% 11.2
     ?_assertEqual({ok, "3½ years"}, age("2022-06-15", "2025-12-15")),    %% 11.3
     ?_assertEqual({ok, "3½ years"}, age("2022-06-15", "2026-05-15")),    %% 11.4
     ?_assertEqual({ok, "4 years"}, age("2021-06-15", "2025-06-15")),           %% 11.5
     ?_assertEqual({ok, "4½ years"}, age("2021-06-15", "2025-12-15")),    %% 11.6
     ?_assertEqual({ok, "5 years"}, age("2020-06-15", "2025-06-15")),           %% 11.7
     ?_assertEqual({ok, "5½ years"}, age("2020-06-15", "2026-02-15")),    %% 11.8
     ?_assertEqual({ok, "6 years"}, age("2019-06-15", "2025-06-15")),           %% 11.9
     ?_assertEqual({ok, "6½ years"}, age("2019-06-15", "2025-12-15")),    %% 11.10
     ?_assertEqual({ok, "6½ years"}, age("2019-06-15", "2026-05-15")),    %% 11.11
     ?_assertEqual({ok, "2 years, 11 months"}, age("2022-06-15", "2025-06-14")) %% 11.12
    ].

%% 12. Integer tier (7+ years)
integer_tier_test_() ->
    [?_assertEqual({ok, "7 years"}, age("2018-06-15", "2025-06-15")),       %% 12.1
     ?_assertEqual({ok, "7 years"}, age("2018-03-20", "2025-06-15")),       %% 12.2
     ?_assertEqual({ok, "45 years"}, age("1980-01-01", "2025-06-15"))       %% 12.3
    ].

%% 13. Cross-year transitions with February
cross_year_feb_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2024-12-31", "2025-03-31")),      %% 13.1
     ?_assert(contains_week(age("2024-12-31", "2025-03-30"))),              %% 13.2
     ?_assertEqual({ok, "3 months"}, age("2024-11-30", "2025-02-28")),      %% 13.3
     ?_assert(contains_week(age("2024-11-30", "2025-02-27")))               %% 13.4
    ].

%% 14. Born-on-31st progression
born_on_31st_test_() ->
    [?_assertEqual({ok, "3 months"}, age("2025-01-31", "2025-04-30")),      %% 14.1
     ?_assertEqual({ok, "4 months"}, age("2025-01-31", "2025-05-31")),      %% 14.2
     ?_assertEqual({ok, "5 months"}, age("2025-01-31", "2025-06-30")),      %% 14.3
     ?_assertEqual({ok, "5 months"}, age("2025-01-31", "2025-07-01")),      %% 14.4
     ?_assertEqual({ok, "6 months"}, age("2025-01-31", "2025-07-31"))       %% 14.5
    ].

%% 15. Default asOf — skipped (test only pure variants, matching Haskell approach)

%% 16. formatStage - null / edge cases
stage_null_edge_test_() ->
    [?_assertEqual(error, stage("", "2025-06-15")),                         %% 16.1/16.2/16.3
     ?_assertEqual(error, stage("2025-07-01", "2025-06-15")),               %% 16.4
     ?_assertEqual({ok, "Adult"}, stage("1525-06-15", "2025-06-15")),       %% 16.5
     ?_assertEqual(error, stage("1524-06-15", "2025-06-15"))                %% 16.6
    ].

%% 17. formatStage - Newborn
stage_newborn_test_() ->
    [?_assertEqual({ok, "Newborn"}, stage("2025-06-15", "2025-06-15")),     %% 17.1
     ?_assertEqual({ok, "Newborn"}, stage("2025-06-14", "2025-06-15")),     %% 17.2
     ?_assertEqual({ok, "Newborn"}, stage("2025-05-25", "2025-06-15")),     %% 17.3
     ?_assertEqual({ok, "Newborn"}, stage("2025-05-15", "2025-06-15")),     %% 17.4
     ?_assertEqual({ok, "Newborn"}, stage("2025-04-16", "2025-06-15")),     %% 17.5
     ?_assertEqual({ok, "Infant"}, stage("2025-04-15", "2025-06-15"))       %% 17.6
    ].

%% 18. formatStage - Infant
stage_infant_test_() ->
    [?_assertEqual({ok, "Infant"}, stage("2025-04-15", "2025-06-15")),      %% 18.1
     ?_assertEqual({ok, "Infant"}, stage("2024-12-15", "2025-06-15")),      %% 18.2
     ?_assertEqual({ok, "Infant"}, stage("2024-07-15", "2025-06-15")),      %% 18.3
     ?_assertEqual({ok, "Toddler"}, stage("2024-06-15", "2025-06-15"))      %% 18.4
    ].

%% 19. formatStage - Toddler
stage_toddler_test_() ->
    [?_assertEqual({ok, "Toddler"}, stage("2024-06-15", "2025-06-15")),     %% 19.1
     ?_assertEqual({ok, "Toddler"}, stage("2024-01-15", "2025-07-15")),     %% 19.2
     ?_assertEqual({ok, "Toddler"}, stage("2023-06-15", "2025-06-15")),     %% 19.3
     ?_assertEqual({ok, "Toddler"}, stage("2023-06-15", "2026-05-15")),     %% 19.4
     ?_assertEqual({ok, "Child"}, stage("2022-06-15", "2025-06-15"))        %% 19.5
    ].

%% 20. formatStage - Child
stage_child_test_() ->
    [?_assertEqual({ok, "Child"}, stage("2022-06-15", "2025-06-15")),       %% 20.1
     ?_assertEqual({ok, "Child"}, stage("2021-06-15", "2025-06-15")),       %% 20.2
     ?_assertEqual({ok, "Child"}, stage("2019-06-15", "2025-06-15")),       %% 20.3
     ?_assertEqual({ok, "Child"}, stage("2016-06-15", "2025-06-15")),       %% 20.4
     ?_assertEqual({ok, "Child"}, stage("2013-06-15", "2026-05-15")),       %% 20.5
     ?_assertEqual({ok, "Teenager"}, stage("2012-06-15", "2025-06-15"))     %% 20.6
    ].

%% 21. formatStage - Teenager
stage_teenager_test_() ->
    [?_assertEqual({ok, "Teenager"}, stage("2012-06-15", "2025-06-15")),    %% 21.1
     ?_assertEqual({ok, "Teenager"}, stage("2010-06-15", "2025-06-15")),    %% 21.2
     ?_assertEqual({ok, "Teenager"}, stage("2008-06-15", "2026-05-15")),    %% 21.3
     ?_assertEqual({ok, "Adult"}, stage("2007-06-15", "2025-06-15"))        %% 21.4
    ].

%% 22. formatStage - Adult
stage_adult_test_() ->
    [?_assertEqual({ok, "Adult"}, stage("2007-06-15", "2025-06-15")),       %% 22.1
     ?_assertEqual({ok, "Adult"}, stage("2000-06-15", "2025-06-15")),       %% 22.2
     ?_assertEqual({ok, "Adult"}, stage("1980-01-01", "2025-06-15"))        %% 22.3
    ].

%% 23. formatStage — default asOf — skipped (test only pure variants)

%% 24. SayableAge class — English locale delegation
class_delegation_test_() ->
    En = sayableage_locales_en:locale(),
    [?_assertEqual({ok, "Newborn"}, sayableage:format_age_pure(En, normal, "2025-06-15", "2025-06-15")),        %% 24.1
     ?_assertEqual({ok, "3 days"}, sayableage:format_age_pure(En, normal, "2025-06-12", "2025-06-15")),         %% 24.2
     ?_assertEqual({ok, "1 week, 1 day"}, sayableage:format_age_pure(En, normal, "2025-06-07", "2025-06-15")), %% 24.3
     ?_assertEqual({ok, "6 months"}, sayableage:format_age_pure(En, normal, "2025-01-15", "2025-07-15")),       %% 24.4
     ?_assertEqual({ok, "2 years, 1 month"}, sayableage:format_age_pure(En, normal, "2023-06-15", "2025-07-15")), %% 24.5
     ?_assertEqual({ok, "3½ years"}, sayableage:format_age_pure(En, normal, "2022-06-15", "2025-12-15")),  %% 24.6
     ?_assertEqual({ok, "7 years"}, sayableage:format_age_pure(En, normal, "2018-06-15", "2025-06-15")),        %% 24.7
     ?_assertEqual({ok, "Newborn"}, sayableage:format_stage_pure(En, "2025-06-15", "2025-06-15", undefined)),   %% 24.8
     ?_assertEqual({ok, "Infant"}, sayableage:format_stage_pure(En, "2025-01-15", "2025-06-15", undefined)),    %% 24.9
     ?_assertEqual({ok, "Toddler"}, sayableage:format_stage_pure(En, "2024-06-15", "2025-06-15", undefined)),   %% 24.10
     ?_assertEqual({ok, "Child"}, sayableage:format_stage_pure(En, "2022-06-15", "2025-06-15", undefined)),     %% 24.11
     ?_assertEqual({ok, "Teenager"}, sayableage:format_stage_pure(En, "2012-06-15", "2025-06-15", undefined)),  %% 24.12
     ?_assertEqual({ok, "Adult"}, sayableage:format_stage_pure(En, "2007-06-15", "2025-06-15", undefined)),     %% 24.13
     ?_assertEqual(error, sayableage:format_age_pure(En, normal, "", "2025-06-15")),                            %% 24.14
     ?_assertEqual(error, sayableage:format_stage_pure(En, "", "2025-06-15", undefined))                        %% 24.15
    ].

%% 25. i18n — Spanish locale
i18n_spanish_test_() ->
    Es = sayableage_locales_es:locale(),
    [?_assertEqual({ok, "Recién nacido"}, age_locale(Es, "2025-06-15", "2025-06-15")),                %% 25.1
     ?_assertEqual({ok, "1 día"}, age_locale(Es, "2025-06-14", "2025-06-15")),                         %% 25.2
     ?_assertEqual({ok, "3 días"}, age_locale(Es, "2025-06-12", "2025-06-15")),                        %% 25.3
     ?_assertEqual({ok, "1 semana"}, age_locale(Es, "2025-06-08", "2025-06-15")),                      %% 25.4
     ?_assertEqual({ok, "1 semana, 1 día"}, age_locale(Es, "2025-06-07", "2025-06-15")),              %% 25.5
     ?_assertEqual({ok, "2 semanas, 6 días"}, age_locale(Es, "2025-05-26", "2025-06-15")),            %% 25.6
     ?_assertEqual({ok, "6 meses"}, age_locale(Es, "2025-01-15", "2025-07-15")),                       %% 25.7
     ?_assertEqual({ok, "2 años, 1 mes"}, age_locale(Es, "2023-06-15", "2025-07-15")),                %% 25.8
     ?_assertEqual({ok, "2 años, 6 meses"}, age_locale(Es, "2023-06-15", "2025-12-15")),              %% 25.9
     ?_assertEqual({ok, "3 y medio años"}, age_locale(Es, "2022-06-15", "2025-12-15")),               %% 25.10
     ?_assertEqual({ok, "3 años"}, age_locale(Es, "2022-06-15", "2025-06-15")),                        %% 25.11
     ?_assertEqual({ok, "7 años"}, age_locale(Es, "2018-06-15", "2025-06-15")),                        %% 25.12
     ?_assertEqual({ok, "Recién nacido"}, stage_locale(Es, "2025-06-15", "2025-06-15", undefined)),   %% 25.13
     ?_assertEqual({ok, "Bebé"}, stage_locale(Es, "2025-01-15", "2025-06-15", undefined)),             %% 25.14
     ?_assertEqual({ok, "Niño pequeño"}, stage_locale(Es, "2024-06-15", "2025-06-15", undefined)),    %% 25.15
     ?_assertEqual({ok, "Niño"}, stage_locale(Es, "2022-06-15", "2025-06-15", undefined)),             %% 25.16
     ?_assertEqual({ok, "Adolescente"}, stage_locale(Es, "2012-06-15", "2025-06-15", undefined)),      %% 25.17
     ?_assertEqual({ok, "Adulto"}, stage_locale(Es, "2007-06-15", "2025-06-15", undefined)),           %% 25.18
     ?_assertEqual(error, age_locale(Es, "", "2025-06-15")),                                            %% 25.19
     ?_assertEqual(error, stage_locale(Es, "", "2025-06-15", undefined))                                %% 25.20
    ].

%% 26. Compactness - short
compactness_short_test_() ->
    [?_assertEqual({ok, "3 d"}, age_short("2025-06-12", "2025-06-15")),                 %% 26.1
     ?_assertEqual({ok, "1 wk"}, age_short("2025-06-08", "2025-06-15")),                %% 26.2
     ?_assertEqual({ok, "1 wk, 1 d"}, age_short("2025-06-07", "2025-06-15")),           %% 26.3
     ?_assertEqual({ok, "6 mo"}, age_short("2025-01-15", "2025-07-15")),                %% 26.4
     ?_assertEqual({ok, "2 yr, 1 mo"}, age_short("2023-06-15", "2025-07-15")),          %% 26.5
     ?_assertEqual({ok, "3½ yr"}, age_short("2022-06-15", "2025-12-15")),          %% 26.6
     ?_assertEqual({ok, "7 yr"}, age_short("2018-06-15", "2025-06-15")),                %% 26.7
     ?_assertEqual({ok, "Newborn"}, age_short("2025-06-15", "2025-06-15")),             %% 26.8
     ?_assertEqual({ok, "Infant"}, stage("2025-01-15", "2025-06-15"))                   %% 26.9
    ].

%% 27. Compactness - compact
compactness_compact_test_() ->
    [?_assertEqual({ok, "3d"}, age_compact("2025-06-12", "2025-06-15")),                %% 27.1
     ?_assertEqual({ok, "1w"}, age_compact("2025-06-08", "2025-06-15")),                %% 27.2
     ?_assertEqual({ok, "1w1d"}, age_compact("2025-06-07", "2025-06-15")),              %% 27.3
     ?_assertEqual({ok, "6m"}, age_compact("2025-01-15", "2025-07-15")),                %% 27.4
     ?_assertEqual({ok, "2y1m"}, age_compact("2023-06-15", "2025-07-15")),              %% 27.5
     ?_assertEqual({ok, "3½y"}, age_compact("2022-06-15", "2025-12-15")),          %% 27.6
     ?_assertEqual({ok, "7y"}, age_compact("2018-06-15", "2025-06-15")),                %% 27.7
     ?_assertEqual({ok, "Newborn"}, age_compact("2025-06-15", "2025-06-15"))            %% 27.8
    ].

%% 29. Locale-specific edge cases

%% 29.1 — Hebrew (he) — dual forms
hebrew_test_() ->
    He = sayableage_locales_he:locale(),
    [?_assertEqual({ok, "רק נולד"}, age_locale(He, "2025-06-15", "2025-06-15")),                    %% 29.1
     ?_assertEqual({ok, "יום 1"}, age_locale(He, "2025-06-14", "2025-06-15")),                       %% 29.2
     ?_assertEqual({ok, "3 ימים"}, age_locale(He, "2025-06-12", "2025-06-15")),                     %% 29.3
     ?_assertEqual({ok, "שבועיים"}, age_locale(He, "2025-06-01", "2025-06-15")),                    %% 29.4
     ?_assertEqual({ok, "3 שבועות"}, age_locale(He, "2025-05-25", "2025-06-15")),                   %% 29.5
     ?_assertEqual({ok, "6 חודשים"}, age_locale(He, "2025-01-15", "2025-07-15")),                   %% 29.6
     ?_assertEqual({ok, "3 חודשים"}, age_locale(He, "2025-03-15", "2025-06-15")),                   %% 29.7
     ?_assertEqual({ok, "שנתיים, חודש 1"}, age_locale(He, "2023-06-15", "2025-07-15")),            %% 29.8
     ?_assertEqual({ok, "3 שנים וחצי"}, age_locale(He, "2022-06-15", "2025-12-15")),               %% 29.9
     ?_assertEqual({ok, "7 שנים"}, age_locale(He, "2018-06-15", "2025-06-15")),                     %% 29.10
     ?_assertEqual({ok, "רק נולד"}, stage_locale(He, "2025-06-15", "2025-06-15", male)),            %% 29.11
     ?_assertEqual({ok, "רק נולדה"}, stage_locale(He, "2025-06-15", "2025-06-15", female)),         %% 29.12
     ?_assertEqual({ok, "מבוגר"}, stage_locale(He, "2007-06-15", "2025-06-15", male)),               %% 29.13
     ?_assertEqual({ok, "מבוגרת"}, stage_locale(He, "2007-06-15", "2025-06-15", female))             %% 29.14
    ].

%% 29.2 — Macedonian (mk)
macedonian_test_() ->
    Mk = sayableage_locales_mk:locale(),
    [?_assertEqual({ok, "Новороденче"}, age_locale(Mk, "2025-06-15", "2025-06-15")),                        %% 29.15
     ?_assertEqual({ok, "1 ден"}, age_locale(Mk, "2025-06-14", "2025-06-15")),                               %% 29.16
     ?_assertEqual({ok, "3 дена"}, age_locale(Mk, "2025-06-12", "2025-06-15")),                              %% 29.17
     ?_assertEqual({ok, "6 месеци"}, age_locale(Mk, "2025-01-15", "2025-07-15")),                            %% 29.18
     ?_assertEqual({ok, "2 години, 1 месец"}, age_locale(Mk, "2023-06-15", "2025-07-15")),                  %% 29.19
     ?_assertEqual({ok, "3 години и пол"}, age_locale(Mk, "2022-06-15", "2025-12-15")),                     %% 29.20
     ?_assertEqual({ok, "7 години"}, age_locale(Mk, "2018-06-15", "2025-06-15"))                             %% 29.21
    ].

%% 29.3 — Swahili (sw)
swahili_test_() ->
    Sw = sayableage_locales_sw:locale(),
    [?_assertEqual({ok, "Mzaliwa mpya"}, age_locale(Sw, "2025-06-15", "2025-06-15")),                %% 29.22
     ?_assertEqual({ok, "siku 1"}, age_locale(Sw, "2025-06-14", "2025-06-15")),                       %% 29.23
     ?_assertEqual({ok, "siku 3"}, age_locale(Sw, "2025-06-12", "2025-06-15")),                       %% 29.24
     ?_assertEqual({ok, "miezi 6"}, age_locale(Sw, "2025-01-15", "2025-07-15")),                      %% 29.25
     ?_assertEqual({ok, "miaka 2, mwezi 1"}, age_locale(Sw, "2023-06-15", "2025-07-15")),            %% 29.26
     ?_assertEqual({ok, "miaka 3 na nusu"}, age_locale(Sw, "2022-06-15", "2025-12-15"))              %% 29.27
    ].

%% 29.4 — Indonesian (id) — other_only
indonesian_test_() ->
    Id = sayableage_locales_id:locale(),
    [?_assertEqual({ok, "Baru lahir"}, age_locale(Id, "2025-06-15", "2025-06-15")),                   %% 29.28
     ?_assertEqual({ok, "1 hari"}, age_locale(Id, "2025-06-14", "2025-06-15")),                       %% 29.29
     ?_assertEqual({ok, "3 hari"}, age_locale(Id, "2025-06-12", "2025-06-15")),                       %% 29.30
     ?_assertEqual({ok, "6 bulan"}, age_locale(Id, "2025-01-15", "2025-07-15")),                      %% 29.31
     ?_assertEqual({ok, "3 tahun setengah"}, age_locale(Id, "2022-06-15", "2025-12-15")),             %% 29.32
     ?_assertEqual({ok, "7 tahun"}, age_locale(Id, "2018-06-15", "2025-06-15"))                       %% 29.33
    ].

%% 29.5 — Amharic (am)
amharic_test_() ->
    Am = sayableage_locales_am:locale(),
    [?_assertEqual({ok, "አዲስ የተወለደ"}, age_locale(Am, "2025-06-15", "2025-06-15")),              %% 29.34
     ?_assertEqual({ok, "1 ቀን"}, age_locale(Am, "2025-06-14", "2025-06-15")),                       %% 29.35
     ?_assertEqual({ok, "3 ቀናት"}, age_locale(Am, "2025-06-12", "2025-06-15")),                     %% 29.36
     ?_assertEqual({ok, "1 ሳምንት፣ 1 ቀን"}, age_locale(Am, "2025-06-07", "2025-06-15")),           %% 29.37
     ?_assertEqual({ok, "6 ወራት"}, age_locale(Am, "2025-01-15", "2025-07-15")),                     %% 29.38
     ?_assertEqual({ok, "3 ዓመታት ተኩል"}, age_locale(Am, "2022-06-15", "2025-12-15"))              %% 29.39
    ].

%% 30. Locale lookup by code string
locale_lookup_test_() ->
    [?_assertMatch({ok, #locale{code = "en"}}, sayableage:get_locale("en")),    %% 30.1
     ?_assertMatch({ok, #locale{code = "fr"}}, sayableage:get_locale("fr")),    %% 30.2
     ?_assertEqual(error, sayableage:get_locale("xx")),                          %% 30.3
     ?_assertEqual(error, sayableage:get_locale("")),                            %% 30.4
     ?_assertEqual(error, sayableage:get_locale("EN"))                           %% 30.5
    ].
