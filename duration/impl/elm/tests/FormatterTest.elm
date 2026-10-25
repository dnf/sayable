module FormatterTest exposing (suite)

import Expect
import SayableDuration.Formatter exposing (formatDuration, formatDurationTimestamps, formatSince, formatUntil)
import SayableDuration.Locales exposing (getLocale)
import SayableDuration.Locales.De as De
import SayableDuration.Locales.En as En
import SayableDuration.Locales.Fr as Fr
import SayableDuration.Locales.Ja as Ja
import SayableDuration.Types exposing (..)
import Test exposing (..)


en : Locale
en =
    En.locale


dur : Int -> Maybe String
dur seconds =
    formatDuration en Normal seconds


durShort : Int -> Maybe String
durShort seconds =
    formatDuration en Short seconds


durCompact : Int -> Maybe String
durCompact seconds =
    formatDuration en Compact seconds


since : String -> String -> Maybe String
since =
    formatSince en Normal


until : String -> String -> Maybe String
until =
    formatUntil en Normal


suite : Test
suite =
    describe "SayableDuration"
        [ describe "1. Null / edge cases"
            [ test "1.1 null seconds" <|
                -- 1.1: null input (Elm uses -1 to represent invalid)
                \_ -> Expect.equal Nothing (formatDuration en Normal -1)
            , test "1.2 negative seconds" <|
                -- 1.2
                \_ -> Expect.equal Nothing (formatDuration en Normal -1)
            , test "1.3 format_since null start" <|
                -- 1.3
                \_ -> Expect.equal Nothing (since "" "2025-01-15T10:00:00")
            , test "1.4 format_until null target" <|
                -- 1.4
                \_ -> Expect.equal Nothing (until "" "2025-01-15T10:00:00")
            , test "1.5 asOf before start" <|
                -- 1.5
                \_ -> Expect.equal Nothing (since "2025-01-15T10:00:00" "2025-01-15T09:00:00")
            , test "1.6 target in the past" <|
                -- 1.6
                \_ -> Expect.equal Nothing (until "2025-01-15T09:00:00" "2025-01-15T10:00:00")
            ]
        , describe "2. Duration - seconds tier (0-59s)"
            [ test "2.1 0 seconds" <|
                \_ -> Expect.equal (Just "just now") (dur 0)
            , test "2.2 1 second" <|
                \_ -> Expect.equal (Just "1 second") (dur 1)
            , test "2.3 45 seconds" <|
                \_ -> Expect.equal (Just "45 seconds") (dur 45)
            , test "2.4 59 seconds" <|
                \_ -> Expect.equal (Just "59 seconds") (dur 59)
            ]
        , describe "3. Duration - minutes + seconds tier (1-4 min)"
            [ test "3.1 1 minute" <|
                \_ -> Expect.equal (Just "1 minute") (dur 60)
            , test "3.2 1 minute, 30 seconds" <|
                \_ -> Expect.equal (Just "1 minute, 30 seconds") (dur 90)
            , test "3.3 4 minutes" <|
                \_ -> Expect.equal (Just "4 minutes") (dur 240)
            , test "3.4 4 minutes, 30 seconds" <|
                \_ -> Expect.equal (Just "4 minutes, 30 seconds") (dur 270)
            ]
        , describe "4. Duration - minutes tier (5-59 min)"
            [ test "4.1 5 minutes" <|
                \_ -> Expect.equal (Just "5 minutes") (dur 300)
            , test "4.2 25 minutes" <|
                \_ -> Expect.equal (Just "25 minutes") (dur 1500)
            , test "4.3 59 minutes" <|
                \_ -> Expect.equal (Just "59 minutes") (dur 3540)
            ]
        , describe "5. Duration - hours + minutes tier (1-5 hr)"
            [ test "5.1 1 hour" <|
                \_ -> Expect.equal (Just "1 hour") (dur 3600)
            , test "5.2 1\u{00BD} hours (half marker)" <|
                \_ -> Expect.equal (Just "1\u{00BD} hours") (dur 5400)
            , test "5.3 2 hours, 15 minutes" <|
                \_ -> Expect.equal (Just "2 hours, 15 minutes") (dur 8100)
            , test "5.4 5 hours" <|
                \_ -> Expect.equal (Just "5 hours") (dur 18000)
            ]
        , describe "6. Duration - hours tier (6-23 hr)"
            [ test "6.1 8 hours" <|
                \_ -> Expect.equal (Just "8 hours") (dur 28800)
            , test "6.2 23 hours" <|
                \_ -> Expect.equal (Just "23 hours") (dur 82800)
            ]
        , describe "7. Duration - days tier"
            [ test "7.1 1 day" <|
                \_ -> Expect.equal (Just "1 day") (dur 86400)
            , test "7.2 1 day, 3 hours" <|
                \_ -> Expect.equal (Just "1 day, 3 hours") (dur 97200)
            , test "7.3 1\u{00BD} days (half marker)" <|
                \_ -> Expect.equal (Just "1\u{00BD} days") (dur 129600)
            , test "7.4 5 days" <|
                \_ -> Expect.equal (Just "5 days") (dur 432000)
            , test "7.5 2 days" <|
                \_ -> Expect.equal (Just "2 days") (dur 172800)
            ]
        , describe "8. Duration - weeks tier"
            [ test "8.1 1 week" <|
                \_ -> Expect.equal (Just "1 week") (dur 604800)
            , test "8.2 2 weeks, 1 day" <|
                \_ -> Expect.equal (Just "2 weeks, 1 day") (dur 1296000)
            , test "8.3 4 weeks" <|
                \_ -> Expect.equal (Just "4 weeks") (dur 2419200)
            ]
        , describe "9. Duration - months and years tier"
            [ test "9.1 1 month" <|
                \_ -> Expect.equal (Just "1 month") (dur 2678400)
            , test "9.2 3 months" <|
                \_ -> Expect.equal (Just "3 months") (dur 7884000)
            , test "9.3 1 year" <|
                \_ -> Expect.equal (Just "1 year") (dur 31536000)
            , test "9.4 1 year, 3 months" <|
                \_ -> Expect.equal (Just "1 year, 3 months") (dur 39420000)
            ]
        , describe "10. Duration from ISO timestamps"
            [ test "10.1 1\u{00BD} hours from timestamps" <|
                \_ -> Expect.equal (Just "1\u{00BD} hours") (formatDurationTimestamps en Normal "2025-01-15T10:00:00" "2025-01-15T11:30:00")
            , test "10.2 45 minutes from timestamps" <|
                \_ -> Expect.equal (Just "45 minutes") (formatDurationTimestamps en Normal "2025-01-15T10:00:00" "2025-01-15T10:45:00")
            ]
        , describe "11. Relative time - since"
            [ test "11.1 just now" <|
                \_ -> Expect.equal (Just "just now") (since "2025-01-15T10:00:00" "2025-01-15T10:00:00")
            , test "11.2 30 seconds ago" <|
                \_ -> Expect.equal (Just "30 seconds ago") (since "2025-01-15T10:00:00" "2025-01-15T10:00:30")
            , test "11.3 45 minutes ago" <|
                \_ -> Expect.equal (Just "45 minutes ago") (since "2025-01-15T10:00:00" "2025-01-15T10:45:00")
            , test "11.4 3 hours ago" <|
                \_ -> Expect.equal (Just "3 hours ago") (since "2025-01-15T10:00:00" "2025-01-15T13:00:00")
            ]
        , describe "12. Relative time - until"
            [ test "12.1 just now" <|
                \_ -> Expect.equal (Just "just now") (until "2025-01-15T10:00:00" "2025-01-15T10:00:00")
            , test "12.2 in 20 minutes" <|
                \_ -> Expect.equal (Just "in 20 minutes") (until "2025-01-15T10:20:00" "2025-01-15T10:00:00")
            , test "12.3 in 3 hours" <|
                \_ -> Expect.equal (Just "in 3 hours") (until "2025-01-15T13:00:00" "2025-01-15T10:00:00")
            ]
        , describe "13. Locale - German"
            [ test "13.1 German 1 Stunde" <|
                \_ -> Expect.equal (Just "1 Stunde") (formatDuration De.locale Normal 3600)
            , test "13.2 German vor 5 Minuten" <|
                \_ -> Expect.equal (Just "vor 5 Minuten") (formatSince De.locale Normal "2025-01-15T10:00:00" "2025-01-15T10:05:00")
            ]
        , describe "14. Locale - French"
            [ test "14.1 French 2 heures" <|
                \_ -> Expect.equal (Just "2 heures") (formatDuration Fr.locale Normal 7200)
            ]
        , describe "15. Locale - Japanese"
            [ test "15.1 Japanese 2\u{5206}" <|
                \_ -> Expect.equal (Just "2\u{5206}") (formatDuration Ja.locale Normal 120)
            , test "15.2 Japanese 1\u{6642}\u{9593}\u{524D}" <|
                \_ -> Expect.equal (Just "1\u{6642}\u{9593}\u{524D}") (formatSince Ja.locale Normal "2025-01-15T10:00:00" "2025-01-15T11:00:00")
            ]
        , describe "16. Short compactness - duration"
            [ test "16.1 short 1h" <|
                \_ -> Expect.equal (Just "1h") (durShort 3600)
            , test "16.2 short 1m, 30s" <|
                \_ -> Expect.equal (Just "1m, 30s") (durShort 90)
            ]
        , describe "17. Compact compactness - duration"
            [ test "17.1 compact 1h" <|
                \_ -> Expect.equal (Just "1h") (durCompact 3600)
            , test "17.2 compact 1m30s" <|
                \_ -> Expect.equal (Just "1m30s") (durCompact 90)
            ]
        , describe "18. Short compactness - relative time"
            [ test "18.1 Mende keeps days and hours" <|
                \_ ->
                    Expect.equal (Just "l\u{0254}h\u{0254}nga 2, awa 14 taa gb\u{0254}y\u{0254}")
                        (getLocale "men" |> Maybe.andThen (\loc -> formatSince loc Short "2025-01-20T01:32:11" "2025-01-22T15:39:16"))
            ]
        , describe "19. Range (500-year ceiling)"
            [ test "19.1 500 Julian years is the ceiling" <|
                \_ -> Expect.equal (Just "500 years") (dur 15778800000)
            , test "19.2 over 6000 months" <|
                \_ -> Expect.equal Nothing (dur 15800000000)
            , test "19.3 well beyond the ceiling" <|
                \_ -> Expect.equal Nothing (dur 99999999999)
            , test "19.4 525 years ago" <|
                \_ -> Expect.equal Nothing (since "1500-01-01T00:00:00" "2025-01-01T00:00:00")
            , test "19.5 575 years from now" <|
                \_ -> Expect.equal Nothing (until "2600-01-01T00:00:00" "2025-01-01T00:00:00")
            ]
        , describe "20. Timestamp validation"
            [ test "20.1 seconds are optional" <|
                \_ -> Expect.equal (Just "1\u{00BD} hours") (formatDurationTimestamps en Normal "2025-01-15T10:00" "2025-01-15T11:30:00")
            , test "20.2 minutes are required" <|
                \_ -> Expect.equal Nothing (formatDurationTimestamps en Normal "2025-01-15T10" "2025-01-15T11:30:00")
            , test "20.3 unpadded date" <|
                \_ -> Expect.equal Nothing (formatDurationTimestamps en Normal "2025-1-5T10:00:00" "2025-01-15T11:30:00")
            , test "20.4 impossible date" <|
                \_ -> Expect.equal Nothing (formatDurationTimestamps en Normal "2025-02-30T10:00:00" "2025-03-15T11:30:00")
            , test "20.5 hour out of range" <|
                \_ -> Expect.equal Nothing (since "2025-01-15T10:00:00" "2025-01-15T25:00:00")
            ]
        ]
