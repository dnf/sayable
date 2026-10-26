module FormatterTest exposing (suite)

import Expect
import SayableAge.Formatter exposing (formatAge, formatStage)
import SayableAge.Locales exposing (getLocale)
import SayableAge.Locales.Am as Am
import SayableAge.Locales.En as En
import SayableAge.Locales.Es as Es
import SayableAge.Locales.He as He
import SayableAge.Locales.Id as Id
import SayableAge.Locales.Mk as Mk
import SayableAge.Locales.Sw as Sw
import SayableAge.Types exposing (..)
import Test exposing (..)


en : Locale
en =
    En.locale


fmt : String -> String -> Maybe String
fmt =
    formatAge en Normal


fmtLoc : Locale -> String -> String -> Maybe String
fmtLoc loc =
    formatAge loc Normal


fmtShort : String -> String -> Maybe String
fmtShort =
    formatAge en Short


fmtCompact : String -> String -> Maybe String
fmtCompact =
    formatAge en Compact


fmtCode : String -> Compactness -> String -> String -> Maybe String
fmtCode code compactness dob asOf =
    getLocale code |> Maybe.andThen (\loc -> formatAge loc compactness dob asOf)


stg : String -> String -> Maybe String
stg dob asOf =
    formatStage en dob asOf Nothing


stgG : Locale -> String -> String -> Maybe Gender -> Maybe String
stgG =
    formatStage


shouldContainWeeks : Maybe String -> Expect.Expectation
shouldContainWeeks result =
    case result of
        Nothing ->
            Expect.fail "expected weeks pattern, got Nothing"

        Just s ->
            Expect.equal True (String.contains "week" s)


suite : Test
suite =
    describe "SayableAge"
        [ describe "1. Null / edge cases"
            [ test "1.1 null dateOfBirth" <|
                \_ -> Expect.equal Nothing (fmt "" "2025-06-15")
            , test "1.3 empty string" <|
                \_ -> Expect.equal Nothing (fmt "" "2025-06-15")
            , test "1.4 future DOB" <|
                \_ -> Expect.equal Nothing (fmt "2025-07-01" "2025-06-15")
            , test "1.5 exactly 500 years" <|
                \_ -> Expect.equal (Just "500 years") (fmt "1525-06-15" "2025-06-15")
            , test "1.6 501 years" <|
                \_ -> Expect.equal Nothing (fmt "1524-06-15" "2025-06-15")
            , test "1.7 1000 years" <|
                \_ -> Expect.equal Nothing (fmt "1025-06-15" "2025-06-15")
            ]
        , describe "2. Days tier"
            [ test "2.1 born today" <|
                \_ -> Expect.equal (Just "Newborn") (fmt "2025-06-15" "2025-06-15")
            , test "2.2 1 day" <|
                \_ -> Expect.equal (Just "1 day") (fmt "2025-06-14" "2025-06-15")
            , test "2.3 3 days" <|
                \_ -> Expect.equal (Just "3 days") (fmt "2025-06-12" "2025-06-15")
            , test "2.4 6 days" <|
                \_ -> Expect.equal (Just "6 days") (fmt "2025-06-09" "2025-06-15")
            , test "2.5 7 days = 1 week" <|
                \_ -> Expect.equal (Just "1 week") (fmt "2025-06-08" "2025-06-15")
            ]
        , describe "3. Weeks+days tier"
            [ test "3.1 exactly 7 days" <|
                \_ -> Expect.equal (Just "1 week") (fmt "2025-06-08" "2025-06-15")
            , test "3.2 1 week, 1 day" <|
                \_ -> Expect.equal (Just "1 week, 1 day") (fmt "2025-06-07" "2025-06-15")
            , test "3.3 1 week, 2 days" <|
                \_ -> Expect.equal (Just "1 week, 2 days") (fmt "2025-06-06" "2025-06-15")
            , test "3.4 1 week, 6 days" <|
                \_ -> Expect.equal (Just "1 week, 6 days") (fmt "2025-06-02" "2025-06-15")
            , test "3.5 2 weeks" <|
                \_ -> Expect.equal (Just "2 weeks") (fmt "2025-06-01" "2025-06-15")
            , test "3.6 2 weeks, 1 day" <|
                \_ -> Expect.equal (Just "2 weeks, 1 day") (fmt "2025-05-31" "2025-06-15")
            , test "3.7 2 weeks, 6 days" <|
                \_ -> Expect.equal (Just "2 weeks, 6 days") (fmt "2025-05-26" "2025-06-15")
            , test "3.8 3 weeks" <|
                \_ -> Expect.equal (Just "3 weeks") (fmt "2025-05-25" "2025-06-15")
            , test "3.9 4 weeks, 3 days" <|
                \_ -> Expect.equal (Just "4 weeks, 3 days") (fmt "2025-05-15" "2025-06-15")
            , test "3.10 8 weeks, 5 days" <|
                \_ -> Expect.equal (Just "8 weeks, 5 days") (fmt "2025-04-15" "2025-06-15")
            , test "3.11 13 weeks" <|
                \_ -> Expect.equal (Just "13 weeks") (fmt "2025-03-15" "2025-06-14")
            , test "3.12 3 months transition" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-03-15" "2025-06-15")
            ]
        , describe "4. Month boundaries - standard"
            [ test "4.1 Jan1 -> Apr1 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-01-01" "2025-04-01")
            , test "4.2 Jan1 -> Mar31 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-01-01" "2025-03-31")
            , test "4.3 Jun15 -> Sep15 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-06-15" "2025-09-15")
            , test "4.4 Jun15 -> Sep14 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-06-15" "2025-09-14")
            , test "4.5 Jun15 -> Dec15 = 6 months" <|
                \_ -> Expect.equal (Just "6 months") (fmt "2025-06-15" "2025-12-15")
            ]
        , describe "5. Month boundaries - Feb non-leap"
            [ test "5.1 Jan31 -> Feb28" <|
                \_ -> Expect.equal (Just "4 weeks") (fmt "2025-01-31" "2025-02-28")
            , test "5.2 Jan31 -> Apr30 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-01-31" "2025-04-30")
            , test "5.3 Jan31 -> Apr29 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-01-31" "2025-04-29")
            , test "5.4 Feb1 -> May1 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-02-01" "2025-05-01")
            , test "5.5 Feb1 -> Apr30 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-02-01" "2025-04-30")
            ]
        , describe "6. Month boundaries - Feb leap"
            [ test "6.1 Jan31 -> Feb29 leap" <|
                \_ -> Expect.equal (Just "4 weeks, 1 day") (fmt "2024-01-31" "2024-02-29")
            , test "6.2 Jan31 -> Feb28 leap" <|
                \_ -> Expect.equal (Just "4 weeks") (fmt "2024-01-31" "2024-02-28")
            , test "6.3 Jan31 -> Apr30 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2024-01-31" "2024-04-30")
            , test "6.4 Jan30 -> Feb29 weeks" <|
                \_ -> shouldContainWeeks (fmt "2024-01-30" "2024-02-29")
            , test "6.5 Jan30 -> Feb28 weeks" <|
                \_ -> shouldContainWeeks (fmt "2024-01-30" "2024-02-28")
            ]
        , describe "7. Month boundaries - 30-day months"
            [ test "7.1 Mar31 -> Jun30 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-03-31" "2025-06-30")
            , test "7.2 Mar31 -> Jun29 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-03-31" "2025-06-29")
            , test "7.3 Aug31 -> Nov30 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-08-31" "2025-11-30")
            , test "7.4 Aug31 -> Nov29 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2025-08-31" "2025-11-29")
            ]
        , describe "8. Leap year baby"
            [ test "8.1 Feb29 -> May29 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2024-02-29" "2024-05-29")
            , test "8.2 Feb29 -> May28 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2024-02-29" "2024-05-28")
            , test "8.3 Feb29 -> Feb28 next year = 12 months" <|
                \_ -> Expect.equal (Just "12 months") (fmt "2024-02-29" "2025-02-28")
            , test "8.4 Feb29 -> Mar1 next year = 12 months" <|
                \_ -> Expect.equal (Just "12 months") (fmt "2024-02-29" "2025-03-01")
            ]
        , describe "9. Months tier"
            [ test "9.1 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-01-15" "2025-04-15")
            , test "9.2 6 months" <|
                \_ -> Expect.equal (Just "6 months") (fmt "2025-01-15" "2025-07-15")
            , test "9.3 12 months (not 1 year)" <|
                \_ -> Expect.equal (Just "12 months") (fmt "2024-06-15" "2025-06-15")
            , test "9.4 23 months" <|
                \_ -> Expect.equal (Just "23 months") (fmt "2024-01-15" "2025-12-15")
            , test "9.5 5 months (day before boundary)" <|
                \_ -> Expect.equal (Just "5 months") (fmt "2025-01-15" "2025-07-14")
            , test "9.6 5 months (cross-year)" <|
                \_ -> Expect.equal (Just "5 months") (fmt "2024-11-10" "2025-04-10")
            ]
        , describe "10. Years+months tier"
            [ test "10.1 2 years" <|
                \_ -> Expect.equal (Just "2 years") (fmt "2023-06-15" "2025-06-15")
            , test "10.2 2 years, 1 month" <|
                \_ -> Expect.equal (Just "2 years, 1 month") (fmt "2023-06-15" "2025-07-15")
            , test "10.3 2 years, 6 months" <|
                \_ -> Expect.equal (Just "2 years, 6 months") (fmt "2023-06-15" "2025-12-15")
            , test "10.4 2 years, 11 months" <|
                \_ -> Expect.equal (Just "2 years, 11 months") (fmt "2023-06-15" "2026-05-15")
            , test "10.5 day before 24 months = 23 months" <|
                \_ -> Expect.equal (Just "23 months") (fmt "2023-06-15" "2025-06-14")
            ]
        , describe "11. Half-year tier"
            [ test "11.1 3 years" <|
                \_ -> Expect.equal (Just "3 years") (fmt "2022-06-15" "2025-06-15")
            , test "11.2 3y5m = 3 years" <|
                \_ -> Expect.equal (Just "3 years") (fmt "2022-06-15" "2025-11-15")
            , test "11.3 3y6m = 3\u{00BD} years" <|
                \_ -> Expect.equal (Just "3\u{00BD} years") (fmt "2022-06-15" "2025-12-15")
            , test "11.4 3y11m = 3\u{00BD} years" <|
                \_ -> Expect.equal (Just "3\u{00BD} years") (fmt "2022-06-15" "2026-05-15")
            , test "11.5 4 years" <|
                \_ -> Expect.equal (Just "4 years") (fmt "2021-06-15" "2025-06-15")
            , test "11.6 4y6m = 4\u{00BD} years" <|
                \_ -> Expect.equal (Just "4\u{00BD} years") (fmt "2021-06-15" "2025-12-15")
            , test "11.7 5 years" <|
                \_ -> Expect.equal (Just "5 years") (fmt "2020-06-15" "2025-06-15")
            , test "11.8 5y8m = 5\u{00BD} years" <|
                \_ -> Expect.equal (Just "5\u{00BD} years") (fmt "2020-06-15" "2026-02-15")
            , test "11.9 6 years" <|
                \_ -> Expect.equal (Just "6 years") (fmt "2019-06-15" "2025-06-15")
            , test "11.10 6y6m = 6\u{00BD} years" <|
                \_ -> Expect.equal (Just "6\u{00BD} years") (fmt "2019-06-15" "2025-12-15")
            , test "11.11 6y11m = 6\u{00BD} years" <|
                \_ -> Expect.equal (Just "6\u{00BD} years") (fmt "2019-06-15" "2026-05-15")
            , test "11.12 day before 3rd birthday = 2 years, 11 months" <|
                \_ -> Expect.equal (Just "2 years, 11 months") (fmt "2022-06-15" "2025-06-14")
            ]
        , describe "12. Integer tier"
            [ test "12.1 7 years" <|
                \_ -> Expect.equal (Just "7 years") (fmt "2018-06-15" "2025-06-15")
            , test "12.2 7y3m = 7 years (no half)" <|
                \_ -> Expect.equal (Just "7 years") (fmt "2018-03-20" "2025-06-15")
            , test "12.3 45 years" <|
                \_ -> Expect.equal (Just "45 years") (fmt "1980-01-01" "2025-06-15")
            ]
        , describe "13. Cross-year transitions"
            [ test "13.1 Dec31 -> Mar31 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2024-12-31" "2025-03-31")
            , test "13.2 Dec31 -> Mar30 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2024-12-31" "2025-03-30")
            , test "13.3 Nov30 -> Feb28 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2024-11-30" "2025-02-28")
            , test "13.4 Nov30 -> Feb27 still weeks" <|
                \_ -> shouldContainWeeks (fmt "2024-11-30" "2025-02-27")
            ]
        , describe "14. Born-on-31st progression"
            [ test "14.1 Jan31 -> Apr30 = 3 months" <|
                \_ -> Expect.equal (Just "3 months") (fmt "2025-01-31" "2025-04-30")
            , test "14.2 Jan31 -> May31 = 4 months" <|
                \_ -> Expect.equal (Just "4 months") (fmt "2025-01-31" "2025-05-31")
            , test "14.3 Jan31 -> Jun30 = 5 months" <|
                \_ -> Expect.equal (Just "5 months") (fmt "2025-01-31" "2025-06-30")
            , test "14.4 Jan31 -> Jul1 = 5 months" <|
                \_ -> Expect.equal (Just "5 months") (fmt "2025-01-31" "2025-07-01")
            , test "14.5 Jan31 -> Jul31 = 6 months" <|
                \_ -> Expect.equal (Just "6 months") (fmt "2025-01-31" "2025-07-31")
            ]
        -- 15.1: not applicable — Elm has no default asOf, and pure code cannot read the system clock (Time.now is a Task)
        -- 15.2: not applicable — same reason as 15.1
        , describe "16. formatStage null/edge"
            [ test "16.1/16.3 empty string" <|
                \_ -> Expect.equal Nothing (stg "" "2025-06-15")
            , test "16.4 future DOB" <|
                \_ -> Expect.equal Nothing (stg "2025-07-01" "2025-06-15")
            , test "16.5 exactly 500 years" <|
                \_ -> Expect.equal (Just "Adult") (stg "1525-06-15" "2025-06-15")
            , test "16.6 501 years" <|
                \_ -> Expect.equal Nothing (stg "1524-06-15" "2025-06-15")
            ]
        , describe "17. formatStage - Newborn"
            [ test "17.1 born today" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-06-15" "2025-06-15")
            , test "17.2 1 day" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-06-14" "2025-06-15")
            , test "17.3 3 weeks" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-05-25" "2025-06-15")
            , test "17.4 1 month" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-05-15" "2025-06-15")
            , test "17.5 1 month 29 days" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-04-16" "2025-06-15")
            , test "17.6 2 months = Infant" <|
                \_ -> Expect.equal (Just "Infant") (stg "2025-04-15" "2025-06-15")
            ]
        , describe "18. formatStage - Infant"
            [ test "18.1 2 months" <|
                \_ -> Expect.equal (Just "Infant") (stg "2025-04-15" "2025-06-15")
            , test "18.2 6 months" <|
                \_ -> Expect.equal (Just "Infant") (stg "2024-12-15" "2025-06-15")
            , test "18.3 11 months" <|
                \_ -> Expect.equal (Just "Infant") (stg "2024-07-15" "2025-06-15")
            , test "18.4 12 months = Toddler" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2024-06-15" "2025-06-15")
            ]
        , describe "19. formatStage - Toddler"
            [ test "19.1 12 months" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2024-06-15" "2025-06-15")
            , test "19.2 18 months" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2024-01-15" "2025-07-15")
            , test "19.3 24 months" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2023-06-15" "2025-06-15")
            , test "19.4 35 months" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2023-06-15" "2026-05-15")
            , test "19.5 36 months = Child" <|
                \_ -> Expect.equal (Just "Child") (stg "2022-06-15" "2025-06-15")
            ]
        , describe "20. formatStage - Child"
            [ test "20.1 3 years" <|
                \_ -> Expect.equal (Just "Child") (stg "2022-06-15" "2025-06-15")
            , test "20.2 4 years" <|
                \_ -> Expect.equal (Just "Child") (stg "2021-06-15" "2025-06-15")
            , test "20.3 6 years" <|
                \_ -> Expect.equal (Just "Child") (stg "2019-06-15" "2025-06-15")
            , test "20.4 9 years" <|
                \_ -> Expect.equal (Just "Child") (stg "2016-06-15" "2025-06-15")
            , test "20.5 12y11m" <|
                \_ -> Expect.equal (Just "Child") (stg "2013-06-15" "2026-05-15")
            , test "20.6 13 years = Teenager" <|
                \_ -> Expect.equal (Just "Teenager") (stg "2012-06-15" "2025-06-15")
            ]
        , describe "21. formatStage - Teenager"
            [ test "21.1 13 years" <|
                \_ -> Expect.equal (Just "Teenager") (stg "2012-06-15" "2025-06-15")
            , test "21.2 15 years" <|
                \_ -> Expect.equal (Just "Teenager") (stg "2010-06-15" "2025-06-15")
            , test "21.3 17y11m" <|
                \_ -> Expect.equal (Just "Teenager") (stg "2008-06-15" "2026-05-15")
            , test "21.4 18 years = Adult" <|
                \_ -> Expect.equal (Just "Adult") (stg "2007-06-15" "2025-06-15")
            ]
        , describe "22. formatStage - Adult"
            [ test "22.1 18 years" <|
                \_ -> Expect.equal (Just "Adult") (stg "2007-06-15" "2025-06-15")
            , test "22.2 25 years" <|
                \_ -> Expect.equal (Just "Adult") (stg "2000-06-15" "2025-06-15")
            , test "22.3 45 years" <|
                \_ -> Expect.equal (Just "Adult") (stg "1980-01-01" "2025-06-15")
            ]
        -- 23.1: not applicable — Elm has no default asOf, and pure code cannot read the system clock (Time.now is a Task)
        -- 23.2: not applicable — same reason as 23.1
        -- 23.3: not applicable — same reason as 23.1
        , describe "24. English locale delegation"
            [ test "24.1 Newborn" <|
                \_ -> Expect.equal (Just "Newborn") (fmt "2025-06-15" "2025-06-15")
            , test "24.2 3 days" <|
                \_ -> Expect.equal (Just "3 days") (fmt "2025-06-12" "2025-06-15")
            , test "24.3 1 week, 1 day" <|
                \_ -> Expect.equal (Just "1 week, 1 day") (fmt "2025-06-07" "2025-06-15")
            , test "24.4 6 months" <|
                \_ -> Expect.equal (Just "6 months") (fmt "2025-01-15" "2025-07-15")
            , test "24.5 2 years, 1 month" <|
                \_ -> Expect.equal (Just "2 years, 1 month") (fmt "2023-06-15" "2025-07-15")
            , test "24.6 3\u{00BD} years" <|
                \_ -> Expect.equal (Just "3\u{00BD} years") (fmt "2022-06-15" "2025-12-15")
            , test "24.7 7 years" <|
                \_ -> Expect.equal (Just "7 years") (fmt "2018-06-15" "2025-06-15")
            , test "24.8 stage Newborn" <|
                \_ -> Expect.equal (Just "Newborn") (stg "2025-06-15" "2025-06-15")
            , test "24.9 stage Infant" <|
                \_ -> Expect.equal (Just "Infant") (stg "2025-01-15" "2025-06-15")
            , test "24.10 stage Toddler" <|
                \_ -> Expect.equal (Just "Toddler") (stg "2024-06-15" "2025-06-15")
            , test "24.11 stage Child" <|
                \_ -> Expect.equal (Just "Child") (stg "2022-06-15" "2025-06-15")
            , test "24.12 stage Teenager" <|
                \_ -> Expect.equal (Just "Teenager") (stg "2012-06-15" "2025-06-15")
            , test "24.13 stage Adult" <|
                \_ -> Expect.equal (Just "Adult") (stg "2007-06-15" "2025-06-15")
            , test "24.14 null formatAge" <|
                \_ -> Expect.equal Nothing (fmt "" "2025-06-15")
            , test "24.15 null formatStage" <|
                \_ -> Expect.equal Nothing (stg "" "2025-06-15")
            ]
        , describe "25. i18n - Spanish"
            [ test "25.1 justBorn" <|
                \_ -> Expect.equal (Just "Reci\u{00E9}n nacido") (fmtLoc Es.locale "2025-06-15" "2025-06-15")
            , test "25.2 singular day" <|
                \_ -> Expect.equal (Just "1 d\u{00ED}a") (fmtLoc Es.locale "2025-06-14" "2025-06-15")
            , test "25.3 plural days" <|
                \_ -> Expect.equal (Just "3 d\u{00ED}as") (fmtLoc Es.locale "2025-06-12" "2025-06-15")
            , test "25.4 singular week" <|
                \_ -> Expect.equal (Just "1 semana") (fmtLoc Es.locale "2025-06-08" "2025-06-15")
            , test "25.5 compound" <|
                \_ -> Expect.equal (Just "1 semana, 1 d\u{00ED}a") (fmtLoc Es.locale "2025-06-07" "2025-06-15")
            , test "25.6 plural compound" <|
                \_ -> Expect.equal (Just "2 semanas, 6 d\u{00ED}as") (fmtLoc Es.locale "2025-05-26" "2025-06-15")
            , test "25.7 months" <|
                \_ -> Expect.equal (Just "6 meses") (fmtLoc Es.locale "2025-01-15" "2025-07-15")
            , test "25.8 singular month" <|
                \_ -> Expect.equal (Just "2 a\u{00F1}os, 1 mes") (fmtLoc Es.locale "2023-06-15" "2025-07-15")
            , test "25.9 years+months" <|
                \_ -> Expect.equal (Just "2 a\u{00F1}os, 6 meses") (fmtLoc Es.locale "2023-06-15" "2025-12-15")
            , test "25.10 half marker" <|
                \_ -> Expect.equal (Just "3 a\u{00F1}os y medio") (fmtLoc Es.locale "2022-06-15" "2025-12-15")
            , test "25.11 no half" <|
                \_ -> Expect.equal (Just "3 a\u{00F1}os") (fmtLoc Es.locale "2022-06-15" "2025-06-15")
            , test "25.12 7+ years" <|
                \_ -> Expect.equal (Just "7 a\u{00F1}os") (fmtLoc Es.locale "2018-06-15" "2025-06-15")
            , test "25.13 stage Newborn" <|
                \_ -> Expect.equal (Just "Reci\u{00E9}n nacido") (formatStage Es.locale "2025-06-15" "2025-06-15" Nothing)
            , test "25.14 stage Infant" <|
                \_ -> Expect.equal (Just "Beb\u{00E9}") (formatStage Es.locale "2025-01-15" "2025-06-15" Nothing)
            , test "25.15 stage Toddler" <|
                \_ -> Expect.equal (Just "Ni\u{00F1}o peque\u{00F1}o") (formatStage Es.locale "2024-06-15" "2025-06-15" Nothing)
            , test "25.16 stage Child" <|
                \_ -> Expect.equal (Just "Ni\u{00F1}o") (formatStage Es.locale "2022-06-15" "2025-06-15" Nothing)
            , test "25.17 stage Teenager" <|
                \_ -> Expect.equal (Just "Adolescente") (formatStage Es.locale "2012-06-15" "2025-06-15" Nothing)
            , test "25.18 stage Adult" <|
                \_ -> Expect.equal (Just "Adulto") (formatStage Es.locale "2007-06-15" "2025-06-15" Nothing)
            , test "25.19 null age" <|
                \_ -> Expect.equal Nothing (fmtLoc Es.locale "" "2025-06-15")
            , test "25.20 null stage" <|
                \_ -> Expect.equal Nothing (formatStage Es.locale "" "2025-06-15" Nothing)
            ]
        , describe "26. Compactness - short"
            [ test "26.1 short days" <|
                \_ -> Expect.equal (Just "3 d") (fmtShort "2025-06-12" "2025-06-15")
            , test "26.2 short week" <|
                \_ -> Expect.equal (Just "1 wk") (fmtShort "2025-06-08" "2025-06-15")
            , test "26.3 short compound" <|
                \_ -> Expect.equal (Just "1 wk, 1 d") (fmtShort "2025-06-07" "2025-06-15")
            , test "26.4 short months" <|
                \_ -> Expect.equal (Just "6 mo") (fmtShort "2025-01-15" "2025-07-15")
            , test "26.5 short years+months" <|
                \_ -> Expect.equal (Just "2 yr, 1 mo") (fmtShort "2023-06-15" "2025-07-15")
            , test "26.6 short half" <|
                \_ -> Expect.equal (Just "3\u{00BD} yr") (fmtShort "2022-06-15" "2025-12-15")
            , test "26.7 short years" <|
                \_ -> Expect.equal (Just "7 yr") (fmtShort "2018-06-15" "2025-06-15")
            , test "26.8 justBorn unchanged" <|
                \_ -> Expect.equal (Just "Newborn") (fmtShort "2025-06-15" "2025-06-15")
            , test "26.9 stages unchanged" <|
                \_ -> Expect.equal (Just "Infant") (formatStage en "2025-01-15" "2025-06-15" Nothing)
            ]
        , describe "27. Compactness - compact"
            [ test "27.1 compact days" <|
                \_ -> Expect.equal (Just "3d") (fmtCompact "2025-06-12" "2025-06-15")
            , test "27.2 compact week" <|
                \_ -> Expect.equal (Just "1w") (fmtCompact "2025-06-08" "2025-06-15")
            , test "27.3 no delimiter" <|
                \_ -> Expect.equal (Just "1w1d") (fmtCompact "2025-06-07" "2025-06-15")
            , test "27.4 compact months" <|
                \_ -> Expect.equal (Just "6m") (fmtCompact "2025-01-15" "2025-07-15")
            , test "27.5 no delimiter" <|
                \_ -> Expect.equal (Just "2y1m") (fmtCompact "2023-06-15" "2025-07-15")
            , test "27.6 compact half" <|
                \_ -> Expect.equal (Just "3\u{00BD}y") (fmtCompact "2022-06-15" "2025-12-15")
            , test "27.7 compact years" <|
                \_ -> Expect.equal (Just "7y") (fmtCompact "2018-06-15" "2025-06-15")
            , test "27.8 justBorn unchanged" <|
                \_ -> Expect.equal (Just "Newborn") (fmtCompact "2025-06-15" "2025-06-15")
            ]
        , describe "29.1 Hebrew dual forms"
            [ test "29.1 justBorn" <|
                \_ -> Expect.equal (Just "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}") (fmtLoc He.locale "2025-06-15" "2025-06-15")
            , test "29.2 1 day" <|
                \_ -> Expect.equal (Just "\u{05D9}\u{05D5}\u{05DD}") (fmtLoc He.locale "2025-06-14" "2025-06-15")
            , test "29.3 3 days" <|
                \_ -> Expect.equal (Just "3 \u{05D9}\u{05DE}\u{05D9}\u{05DD}") (fmtLoc He.locale "2025-06-12" "2025-06-15")
            , test "29.4 2 weeks dual" <|
                \_ -> Expect.equal (Just "\u{05E9}\u{05D1}\u{05D5}\u{05E2}\u{05D9}\u{05D9}\u{05DD}") (fmtLoc He.locale "2025-06-01" "2025-06-15")
            , test "29.5 3 weeks" <|
                \_ -> Expect.equal (Just "3 \u{05E9}\u{05D1}\u{05D5}\u{05E2}\u{05D5}\u{05EA}") (fmtLoc He.locale "2025-05-25" "2025-06-15")
            , test "29.6 6 months" <|
                \_ -> Expect.equal (Just "6 \u{05D7}\u{05D5}\u{05D3}\u{05E9}\u{05D9}\u{05DD}") (fmtLoc He.locale "2025-01-15" "2025-07-15")
            , test "29.7 3 months" <|
                \_ -> Expect.equal (Just "3 \u{05D7}\u{05D5}\u{05D3}\u{05E9}\u{05D9}\u{05DD}") (fmtLoc He.locale "2025-03-15" "2025-06-15")
            , test "29.8 2y dual + 1m" <|
                \_ -> Expect.equal (Just "\u{05E9}\u{05E0}\u{05EA}\u{05D9}\u{05D9}\u{05DD}, \u{05D7}\u{05D5}\u{05D3}\u{05E9}") (fmtLoc He.locale "2023-06-15" "2025-07-15")
            , test "29.9 3.5 years" <|
                \_ -> Expect.equal (Just "3 \u{05E9}\u{05E0}\u{05D9}\u{05DD} \u{05D5}\u{05D7}\u{05E6}\u{05D9}") (fmtLoc He.locale "2022-06-15" "2025-12-15")
            , test "29.10 7 years" <|
                \_ -> Expect.equal (Just "7 \u{05E9}\u{05E0}\u{05D9}\u{05DD}") (fmtLoc He.locale "2018-06-15" "2025-06-15")
            , test "29.11 masculine newborn" <|
                \_ -> Expect.equal (Just "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}") (stgG He.locale "2025-06-15" "2025-06-15" (Just M))
            , test "29.12 feminine newborn" <|
                \_ -> Expect.equal (Just "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}\u{05D4}") (stgG He.locale "2025-06-15" "2025-06-15" (Just F))
            , test "29.13 masculine adult" <|
                \_ -> Expect.equal (Just "\u{05DE}\u{05D1}\u{05D5}\u{05D2}\u{05E8}") (stgG He.locale "2007-06-15" "2025-06-15" (Just M))
            , test "29.14 feminine adult" <|
                \_ -> Expect.equal (Just "\u{05DE}\u{05D1}\u{05D5}\u{05D2}\u{05E8}\u{05EA}") (stgG He.locale "2007-06-15" "2025-06-15" (Just F))
            ]
        , describe "29.2 Macedonian"
            [ test "29.15 justBorn" <|
                \_ -> Expect.equal (Just "\u{041D}\u{043E}\u{0432}\u{043E}\u{0440}\u{043E}\u{0434}\u{0435}\u{043D}\u{0447}\u{0435}") (fmtLoc Mk.locale "2025-06-15" "2025-06-15")
            , test "29.16 1 day" <|
                \_ -> Expect.equal (Just "1 \u{0434}\u{0435}\u{043D}") (fmtLoc Mk.locale "2025-06-14" "2025-06-15")
            , test "29.17 3 days" <|
                \_ -> Expect.equal (Just "3 \u{0434}\u{0435}\u{043D}\u{0430}") (fmtLoc Mk.locale "2025-06-12" "2025-06-15")
            , test "29.18 6 months" <|
                \_ -> Expect.equal (Just "6 \u{043C}\u{0435}\u{0441}\u{0435}\u{0446}\u{0438}") (fmtLoc Mk.locale "2025-01-15" "2025-07-15")
            , test "29.19 2y1m" <|
                \_ -> Expect.equal (Just "2 \u{0433}\u{043E}\u{0434}\u{0438}\u{043D}\u{0438}, 1 \u{043C}\u{0435}\u{0441}\u{0435}\u{0446}") (fmtLoc Mk.locale "2023-06-15" "2025-07-15")
            , test "29.20 3.5 years" <|
                \_ -> Expect.equal (Just "3 \u{0433}\u{043E}\u{0434}\u{0438}\u{043D}\u{0438} \u{0438} \u{043F}\u{043E}\u{043B}") (fmtLoc Mk.locale "2022-06-15" "2025-12-15")
            , test "29.21 7 years" <|
                \_ -> Expect.equal (Just "7 \u{0433}\u{043E}\u{0434}\u{0438}\u{043D}\u{0438}") (fmtLoc Mk.locale "2018-06-15" "2025-06-15")
            ]
        , describe "29.3 Swahili"
            [ test "29.22 justBorn" <|
                \_ -> Expect.equal (Just "Mzaliwa mpya") (fmtLoc Sw.locale "2025-06-15" "2025-06-15")
            , test "29.23 1 day" <|
                \_ -> Expect.equal (Just "siku 1") (fmtLoc Sw.locale "2025-06-14" "2025-06-15")
            , test "29.24 3 days" <|
                \_ -> Expect.equal (Just "siku 3") (fmtLoc Sw.locale "2025-06-12" "2025-06-15")
            , test "29.25 6 months" <|
                \_ -> Expect.equal (Just "miezi 6") (fmtLoc Sw.locale "2025-01-15" "2025-07-15")
            , test "29.26 2y + 1m" <|
                \_ -> Expect.equal (Just "miaka 2, mwezi 1") (fmtLoc Sw.locale "2023-06-15" "2025-07-15")
            , test "29.27 3.5 years" <|
                \_ -> Expect.equal (Just "miaka 3 na nusu") (fmtLoc Sw.locale "2022-06-15" "2025-12-15")
            ]
        , describe "29.4 Indonesian"
            [ test "29.28 justBorn" <|
                \_ -> Expect.equal (Just "Baru lahir") (fmtLoc Id.locale "2025-06-15" "2025-06-15")
            , test "29.29 1 day" <|
                \_ -> Expect.equal (Just "1 hari") (fmtLoc Id.locale "2025-06-14" "2025-06-15")
            , test "29.30 3 days" <|
                \_ -> Expect.equal (Just "3 hari") (fmtLoc Id.locale "2025-06-12" "2025-06-15")
            , test "29.31 6 months" <|
                \_ -> Expect.equal (Just "6 bulan") (fmtLoc Id.locale "2025-01-15" "2025-07-15")
            , test "29.32 3.5 years" <|
                \_ -> Expect.equal (Just "3 setengah tahun") (fmtLoc Id.locale "2022-06-15" "2025-12-15")
            , test "29.33 7 years" <|
                \_ -> Expect.equal (Just "7 tahun") (fmtLoc Id.locale "2018-06-15" "2025-06-15")
            ]
        , describe "29.5 Amharic"
            [ test "29.34 justBorn" <|
                \_ -> Expect.equal (Just "\u{12A0}\u{12F2}\u{1235} \u{12E8}\u{1270}\u{12C8}\u{1208}\u{12F0}") (fmtLoc Am.locale "2025-06-15" "2025-06-15")
            , test "29.35 1 day" <|
                \_ -> Expect.equal (Just "1 \u{1240}\u{1295}") (fmtLoc Am.locale "2025-06-14" "2025-06-15")
            , test "29.36 3 days" <|
                \_ -> Expect.equal (Just "3 \u{1240}\u{1293}\u{1275}") (fmtLoc Am.locale "2025-06-12" "2025-06-15")
            , test "29.37 1w1d ethiopic delimiter" <|
                \_ -> Expect.equal (Just "1 \u{1233}\u{121D}\u{1295}\u{1275}\u{1363} 1 \u{1240}\u{1295}") (fmtLoc Am.locale "2025-06-07" "2025-06-15")
            , test "29.38 6 months" <|
                \_ -> Expect.equal (Just "6 \u{12C8}\u{122B}\u{1275}") (fmtLoc Am.locale "2025-01-15" "2025-07-15")
            , test "29.39 3.5 years" <|
                \_ -> Expect.equal (Just "3 \u{12D3}\u{1218}\u{1273}\u{1275} \u{1270}\u{12A9}\u{120D}") (fmtLoc Am.locale "2022-06-15" "2025-12-15")
            ]
        , describe "30. Locale lookup"
            [ test "30.1 known locale en" <|
                \_ -> Expect.equal (Just "en") (Maybe.map .code (getLocale "en"))
            , test "30.2 known locale fr" <|
                \_ -> Expect.equal (Just "fr") (Maybe.map .code (getLocale "fr"))
            , test "30.3 unknown code" <|
                \_ -> Expect.equal Nothing (getLocale "xx")
            , test "30.4 empty string" <|
                \_ -> Expect.equal Nothing (getLocale "")
            , test "30.5 case-sensitive" <|
                \_ -> Expect.equal Nothing (getLocale "EN")
            ]
        , describe "31. Weeks and days across month ends"
            [ test "31.1 88 days across February" <|
                \_ -> Expect.equal (Just "12 weeks, 4 days") (fmt "2016-12-31" "2017-03-29")
            , test "31.2 90 days into a leap year" <|
                \_ -> Expect.equal (Just "12 weeks, 6 days") (fmt "1991-11-27" "1992-02-25")
            , test "31.3 33 days across a year end" <|
                \_ -> Expect.equal (Just "4 weeks, 5 days") (fmt "2020-11-30" "2021-01-02")
            , test "31.4 compact form of 31.1" <|
                \_ -> Expect.equal (Just "12w4d") (fmtCompact "2016-12-31" "2017-03-29")
            ]
        , describe "32. Half years take their plural form from whole years"
            [ test "32.1 Polish 3 is few" <|
                \_ -> Expect.equal (Just "3 i pół lata") (fmtCode "pl" Normal "2021-06-15" "2025-01-15")
            , test "32.2 Polish 5 is many" <|
                \_ -> Expect.equal (Just "5 i pół lat") (fmtCode "pl" Short "2020-06-15" "2025-12-15")
            , test "32.3 Tachelhit 6 is few" <|
                \_ -> Expect.equal (Just "6 \u{2D49}\u{2D59}\u{2D33}\u{2D33}\u{2D6F}\u{2D30}\u{2D59}\u{2D4F} \u{2D37} \u{2D53}\u{2D63}\u{2D33}\u{2D4F}") (fmtCode "shi" Normal "2005-06-08" "2012-06-07")
            ]
        , describe "33. Input validation"
            [ test "33.1 February 30" <|
                \_ -> Expect.equal Nothing (fmt "2025-02-30" "2032-06-25")
            , test "33.2 month 13" <|
                \_ -> Expect.equal Nothing (fmt "2025-13-01" "2027-01-31")
            , test "33.3 February 29 in a non-leap year" <|
                \_ -> Expect.equal Nothing (fmt "2023-02-29" "2025-03-01")
            , test "33.4 day 00" <|
                \_ -> Expect.equal Nothing (fmt "2025-06-00" "2027-02-25")
            , test "33.5 unpadded month and day" <|
                \_ -> Expect.equal Nothing (fmt "2025-6-1" "2027-02-25")
            , test "33.6 surrounding whitespace" <|
                \_ -> Expect.equal Nothing (fmt " 2025-06-01" "2027-02-25")
            , test "33.7 a datetime is not a date" <|
                \_ -> Expect.equal Nothing (fmt "2025-06-15T10:00:00" "2027-02-25")
            , test "33.8 invalid asOf" <|
                \_ -> Expect.equal Nothing (fmt "2020-01-01" "2025-04-31")
            , test "33.9 formatStage validates too" <|
                \_ -> Expect.equal Nothing (stg "2025-02-30" "2027-09-05")
            , test "33.10 February 29 in a leap year" <|
                \_ -> Expect.equal (Just "2 years") (fmt "2024-02-29" "2026-03-01")
            ]
        ]
