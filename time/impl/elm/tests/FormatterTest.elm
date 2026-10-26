module FormatterTest exposing (suite)

import Expect
import SayableTime.Formatter exposing (formatTime)
import SayableTime.Locales.De as De
import SayableTime.Locales.En as En
import SayableTime.Locales.Fr as Fr
import SayableTime.Locales.Fi as Fi
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
            , test "6.2 une heure" <|
                \_ -> Expect.equal (Just "une heure") (formatTime Fr.locale Normal "13:00")
            , test "6.3 une heure et demie" <|
                \_ -> Expect.equal (Just "une heure et demie") (formatTime Fr.locale Normal "13:30")
            , test "6.4 trois heures moins le quart" <|
                \_ -> Expect.equal (Just "trois heures moins le quart") (formatTime Fr.locale Normal "14:45")
            , test "6.5 trois heures moins dix" <|
                \_ -> Expect.equal (Just "trois heures moins dix") (formatTime Fr.locale Normal "14:50")
            ]
        , describe "7. Locale - Japanese"
            [ test "7.1 \u{4E09}\u{6642}\u{534A}" <|
                \_ -> Expect.equal (Just "\u{4E09}\u{6642}\u{534A}") (formatTime Ja.locale Normal "15:30")
            ]
        , describe "8. Locale - Finnish (dot separator, short)"
            [ test "8.1 14.15 dot separator" <|
                \_ -> Expect.equal (Just "14.15") (formatTime Fi.locale Short "14:15")
            , test "8.2 0.00 midnight dot" <|
                \_ -> Expect.equal (Just "0.00") (formatTime Fi.locale Short "00:00")
            ]
        , describe "9. Minutes in short and compact modes"
            [ test "9.1 short keeps the exact minute" <|
                \_ -> Expect.equal (Just "6:01 PM") (fmtShort "18:01")
            , test "9.2 compact keeps the exact minute" <|
                \_ -> Expect.equal (Just "7:05p") (fmtCompact "19:05")
            ]
        , describe "10. Input validation"
            [ test "10.1 one-digit hour" <|
                \_ -> Expect.equal (Just "half past nine") (fmt "9:30")
            , test "10.2 two-digit hour" <|
                \_ -> Expect.equal (Just "half past nine") (fmt "09:30")
            , test "10.3 leading whitespace" <|
                \_ -> Expect.equal Nothing (fmt " 9:30")
            , test "10.4 trailing whitespace" <|
                \_ -> Expect.equal Nothing (fmt "9:30 ")
            , test "10.5 minutes need two digits" <|
                \_ -> Expect.equal Nothing (fmt "9:5")
            , test "10.6 hour out of range" <|
                \_ -> Expect.equal Nothing (fmt "24:00")
            , test "10.7 seconds are allowed and ignored" <|
                \_ -> Expect.equal (Just "a quarter past two") (fmt "14:15:30")
            , test "10.8 ISO datetime with zone suffix" <|
                \_ -> Expect.equal (Just "a quarter past two") (fmt "2025-01-15T14:15:00Z")
            , test "10.9 ISO datetime with an impossible date" <|
                \_ -> Expect.equal Nothing (fmt "2025-02-30T14:15:00")
            ]
        ]
