module FormatterTest exposing (suite)

import Expect
import SayableTime.Formatter exposing (formatTime)
import SayableTime.Locales.De as De
import SayableTime.Locales.En as En
import SayableTime.Locales.Fr as Fr
import SayableTime.Locales.Ja as Ja
import SayableTime.Types exposing (..)
import Test exposing (..)


en : Locale
en =
    En.locale


fmt : String -> Maybe String
fmt =
    formatTime en Normal


fmtShort : String -> Maybe String
fmtShort =
    formatTime en Short


fmtCompact : String -> Maybe String
fmtCompact =
    formatTime en Compact


suite : Test
suite =
    describe "SayableTime"
        [ describe "1. Null / edge cases"
            [ test "1.1 null time" <|
                -- 1.1
                \_ -> Expect.equal Nothing (fmt "")
            , test "1.2 empty string" <|
                -- 1.2
                \_ -> Expect.equal Nothing (fmt "")
            , test "1.3 invalid" <|
                -- 1.3
                \_ -> Expect.equal Nothing (fmt "invalid")
            , test "1.4 out of range" <|
                -- 1.4
                \_ -> Expect.equal Nothing (fmt "25:00")
            ]
        , describe "2. Clock time (normal compactness)"
            [ test "2.1 midnight" <|
                \_ -> Expect.equal (Just "midnight") (fmt "00:00")
            , test "2.2 noon" <|
                \_ -> Expect.equal (Just "noon") (fmt "12:00")
            , test "2.3 three o'clock" <|
                \_ -> Expect.equal (Just "three o'clock") (fmt "15:00")
            , test "2.4 a quarter past two" <|
                \_ -> Expect.equal (Just "a quarter past two") (fmt "14:15")
            , test "2.5 half past nine" <|
                \_ -> Expect.equal (Just "half past nine") (fmt "09:30")
            , test "2.6 a quarter to eleven" <|
                \_ -> Expect.equal (Just "a quarter to eleven") (fmt "10:45")
            , test "2.7 five past eight" <|
                \_ -> Expect.equal (Just "five past eight") (fmt "08:05")
            , test "2.8 five to five" <|
                \_ -> Expect.equal (Just "five to five") (fmt "16:55")
            , test "2.9 rounds to midnight" <|
                \_ -> Expect.equal (Just "midnight") (fmt "23:58")
            , test "2.10 twenty past seven (22 rounds to 20)" <|
                \_ -> Expect.equal (Just "twenty past seven") (fmt "07:22")
            , test "2.11 ISO datetime input" <|
                \_ -> Expect.equal (Just "a quarter past two") (fmt "2025-01-15T14:15:00")
            ]
        , describe "3. Clock time (short compactness)"
            [ test "3.1 2:15 PM" <|
                \_ -> Expect.equal (Just "2:15 PM") (fmtShort "14:15")
            , test "3.2 9:30 AM" <|
                \_ -> Expect.equal (Just "9:30 AM") (fmtShort "09:30")
            , test "3.3 12:00 AM" <|
                \_ -> Expect.equal (Just "12:00 AM") (fmtShort "00:00")
            , test "3.4 12:00 PM" <|
                \_ -> Expect.equal (Just "12:00 PM") (fmtShort "12:00")
            ]
        , describe "4. Clock time (compact)"
            [ test "4.1 2:15p" <|
                \_ -> Expect.equal (Just "2:15p") (fmtCompact "14:15")
            , test "4.2 9:30a" <|
                \_ -> Expect.equal (Just "9:30a") (fmtCompact "09:30")
            ]
        , describe "5. Locale - German"
            [ test "5.1 halb vier" <|
                \_ -> Expect.equal (Just "halb vier") (formatTime De.locale Normal "15:30")
            ]
        , describe "6. Locale - French"
            [ test "6.1 trois heures et quart" <|
                \_ -> Expect.equal (Just "trois heures et quart") (formatTime Fr.locale Normal "15:15")
            ]
        , describe "7. Locale - Japanese"
            [ test "7.1 \u{4E09}\u{6642}\u{534A}" <|
                \_ -> Expect.equal (Just "\u{4E09}\u{6642}\u{534A}") (formatTime Ja.locale Normal "15:30")
            ]
        ]
