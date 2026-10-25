module FormatterTest exposing (suite)

import Expect
import SayableDate.Formatter exposing (formatDate, formatDateWithYear, formatRelative)
import SayableDate.Locales exposing (getLocale)
import SayableDate.Locales.Ar as Ar
import SayableDate.Locales.De as De
import SayableDate.Locales.En as En
import SayableDate.Locales.Es as Es
import SayableDate.Locales.Fr as Fr
import SayableDate.Locales.Ja as Ja
import SayableDate.Locales.Ru as Ru
import SayableDate.Types exposing (..)
import Test exposing (..)


en : Locale
en =
    En.locale


fmt : String -> Maybe String
fmt date =
    formatDate en Normal date


fmtShort : String -> Maybe String
fmtShort date =
    formatDate en Short date


fmtCompact : String -> Maybe String
fmtCompact date =
    formatDate en Compact date


rel : String -> String -> Maybe String
rel date asOf =
    formatRelative en Normal date asOf


relCompact : String -> String -> Maybe String
relCompact date asOf =
    formatRelative en Compact date asOf


withLocale : String -> (Locale -> Maybe String) -> Maybe String
withLocale code format =
    getLocale code |> Maybe.andThen format


suite : Test
suite =
    describe "SayableDate"
        [ describe "1. Null / edge cases"
            -- 1.1: null date
            [ test "1.1 null date" <|
                \_ -> Expect.equal Nothing (formatDate en Normal "")
            , test "1.2 empty string" <|
                -- 1.2
                \_ -> Expect.equal Nothing (formatDate en Normal "")
            , test "1.3 invalid" <|
                -- 1.3
                \_ -> Expect.equal Nothing (formatDate en Normal "invalid")
            , test "1.4 relative null asOf" <|
                -- 1.4
                \_ -> Expect.equal Nothing (formatRelative en Normal "2025-03-15" "")
            , test "1.5 relative null date" <|
                -- 1.5
                \_ -> Expect.equal Nothing (formatRelative en Normal "" "2025-03-15")
            ]
        , describe "2. format_date - normal compactness (English)"
            [ test "2.1 March 15th" <|
                \_ -> Expect.equal (Just "March 15th") (fmt "2025-03-15")
            , test "2.2 January 1st" <|
                \_ -> Expect.equal (Just "January 1st") (fmt "2025-01-01")
            , test "2.3 May 22nd" <|
                \_ -> Expect.equal (Just "May 22nd") (fmt "2025-05-22")
            , test "2.4 July 3rd" <|
                \_ -> Expect.equal (Just "July 3rd") (fmt "2025-07-03")
            , test "2.5 December 31st" <|
                \_ -> Expect.equal (Just "December 31st") (fmt "2025-12-31")
            , test "2.6 June 11th" <|
                \_ -> Expect.equal (Just "June 11th") (fmt "2025-06-11")
            , test "2.7 ISO datetime input" <|
                \_ -> Expect.equal (Just "March 15th") (fmt "2025-03-15T14:30:00")
            ]
        , describe "3. format_date - short compactness (English)"
            [ test "3.1 Mar 15" <|
                \_ -> Expect.equal (Just "Mar 15") (fmtShort "2025-03-15")
            , test "3.2 Jan 1" <|
                \_ -> Expect.equal (Just "Jan 1") (fmtShort "2025-01-01")
            , test "3.3 Dec 25" <|
                \_ -> Expect.equal (Just "Dec 25") (fmtShort "2025-12-25")
            ]
        , describe "4. format_date - compact (English)"
            [ test "4.1 3/15" <|
                \_ -> Expect.equal (Just "3/15") (fmtCompact "2025-03-15")
            , test "4.2 1/1" <|
                \_ -> Expect.equal (Just "1/1") (fmtCompact "2025-01-01")
            ]
        , describe "5. format_relative - proximity tiers (English)"
            [ test "5.1 today" <|
                \_ -> Expect.equal (Just "today") (rel "2025-03-15" "2025-03-15")
            , test "5.2 tomorrow" <|
                \_ -> Expect.equal (Just "tomorrow") (rel "2025-03-16" "2025-03-15")
            , test "5.3 yesterday" <|
                \_ -> Expect.equal (Just "yesterday") (rel "2025-03-14" "2025-03-15")
            , test "5.4 the day after tomorrow" <|
                \_ -> Expect.equal (Just "the day after tomorrow") (rel "2025-03-17" "2025-03-15")
            , test "5.5 the day before yesterday" <|
                \_ -> Expect.equal (Just "the day before yesterday") (rel "2025-03-13" "2025-03-15")
            , test "5.6 this Wednesday" <|
                \_ -> Expect.equal (Just "this Wednesday") (rel "2025-03-19" "2025-03-15")
            , test "5.7 this Thursday" <|
                \_ -> Expect.equal (Just "this Thursday") (rel "2025-03-20" "2025-03-15")
            , test "5.8 last Tuesday" <|
                \_ -> Expect.equal (Just "last Tuesday") (rel "2025-03-11" "2025-03-15")
            , test "5.9 next Saturday" <|
                \_ -> Expect.equal (Just "next Saturday") (rel "2025-03-22" "2025-03-15")
            , test "5.10 next Thursday" <|
                \_ -> Expect.equal (Just "next Thursday") (rel "2025-03-27" "2025-03-15")
            , test "5.11 calendar fallback same year" <|
                \_ -> Expect.equal (Just "March 1st") (rel "2025-03-01" "2025-03-15")
            , test "5.12 calendar fallback same year future" <|
                \_ -> Expect.equal (Just "April 10th") (rel "2025-04-10" "2025-03-15")
            , test "5.13 different year includes year" <|
                \_ -> Expect.equal (Just "January 5th, 2026") (rel "2026-01-05" "2025-03-15")
            , test "5.14 past year includes year" <|
                \_ -> Expect.equal (Just "December 25th, 2024") (rel "2024-12-25" "2025-03-15")
            ]
        , describe "6. format_relative - compact skips weekday tiers"
            [ test "6.1 compact today" <|
                \_ -> Expect.equal (Just "today") (relCompact "2025-03-15" "2025-03-15")
            , test "6.2 compact tomorrow" <|
                \_ -> Expect.equal (Just "tomorrow") (relCompact "2025-03-16" "2025-03-15")
            , test "6.3 compact goes straight to numeric" <|
                \_ -> Expect.equal (Just "3/19") (relCompact "2025-03-19" "2025-03-15")
            , test "6.4 compact different year" <|
                \_ -> Expect.equal (Just "1/5/26") (relCompact "2026-01-05" "2025-03-15")
            ]
        , describe "7. Locale - German"
            [ test "7.1 German format_date" <|
                \_ -> Expect.equal (Just "15. M\u{00E4}rz") (formatDate De.locale Normal "2025-03-15")
            , test "7.2 German morgen" <|
                \_ -> Expect.equal (Just "morgen") (formatRelative De.locale Normal "2025-03-16" "2025-03-15")
            , test "7.3 German \u{00FC}bermorgen" <|
                \_ -> Expect.equal (Just "\u{00FC}bermorgen") (formatRelative De.locale Normal "2025-03-17" "2025-03-15")
            , test "7.4 German this weekday" <|
                \_ -> Expect.equal (Just "diesen Mittwoch") (formatRelative De.locale Normal "2025-03-19" "2025-03-15")
            ]
        , describe "8. Locale - French"
            [ test "8.1 French 1er mars" <|
                \_ -> Expect.equal (Just "1er mars") (formatDate Fr.locale Normal "2025-03-01")
            , test "8.2 French 15 mars" <|
                \_ -> Expect.equal (Just "15 mars") (formatDate Fr.locale Normal "2025-03-15")
            , test "8.3 French demain" <|
                \_ -> Expect.equal (Just "demain") (formatRelative Fr.locale Normal "2025-03-16" "2025-03-15")
            ]
        , describe "9. Locale - Japanese"
            [ test "9.1 Japanese format_date" <|
                \_ -> Expect.equal (Just "3\u{6708}15\u{65E5}") (formatDate Ja.locale Normal "2025-03-15")
            , test "9.2 Japanese \u{660E}\u{65E5}" <|
                \_ -> Expect.equal (Just "\u{660E}\u{65E5}") (formatRelative Ja.locale Normal "2025-03-16" "2025-03-15")
            , test "9.3 Japanese this weekday" <|
                \_ -> Expect.equal (Just "\u{4ECA}\u{5EA6}\u{306E}\u{6C34}\u{66DC}\u{65E5}") (formatRelative Ja.locale Normal "2025-03-19" "2025-03-15")
            ]
        , describe "10. Locale - Russian (genitive months)"
            [ test "10.1 Russian genitive" <|
                \_ -> Expect.equal (Just "15 \u{043C}\u{0430}\u{0440}\u{0442}\u{0430}") (formatDate Ru.locale Normal "2025-03-15")
            , test "10.2 Russian \u{0437}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}" <|
                \_ -> Expect.equal (Just "\u{0437}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}") (formatRelative Ru.locale Normal "2025-03-16" "2025-03-15")
            ]
        , describe "11. Locale - Arabic"
            [ test "11.1 Arabic format_date" <|
                \_ -> Expect.equal (Just "15 \u{0645}\u{0627}\u{0631}\u{0633}") (formatDate Ar.locale Normal "2025-03-15")
            , test "11.2 Arabic \u{063A}\u{062F}\u{0627}\u{064B}" <|
                \_ -> Expect.equal (Just "\u{063A}\u{062F}\u{0627}\u{064B}") (formatRelative Ar.locale Normal "2025-03-16" "2025-03-15")
            ]
        , describe "12. Locale - Spanish"
            [ test "12.1 Spanish format_date" <|
                \_ -> Expect.equal (Just "15 de marzo") (formatDate Es.locale Normal "2025-03-15")
            , test "12.2 Spanish pasado ma\u{00F1}ana" <|
                \_ -> Expect.equal (Just "pasado ma\u{00F1}ana") (formatRelative Es.locale Normal "2025-03-17" "2025-03-15")
            ]
        , describe "13. format_date_with_year"
            [ test "13.1 normal" <|
                \_ -> Expect.equal (Just "February 4th, 2018") (formatDateWithYear en Normal "2018-02-04")
            , test "13.2 short" <|
                \_ -> Expect.equal (Just "Mar 15, 2025") (formatDateWithYear en Short "2025-03-15")
            , test "13.3 compact" <|
                \_ -> Expect.equal (Just "1/21/97") (formatDateWithYear en Compact "1997-01-21")
            , test "13.4 two-digit year keeps its leading zero" <|
                \_ -> Expect.equal (Just "20/5/07") (withLocale "tg" (\loc -> formatDateWithYear loc Compact "2007-05-20"))
            , test "13.5 Finnish short" <|
                \_ -> Expect.equal (Just "21. kes\u{00E4}kuuta 1996") (withLocale "fi" (\loc -> formatDateWithYear loc Short "1996-06-21"))
            ]
        , describe "14. Short month names (locales that keep the full genitive)"
            [ test "14.1 Slovak" <|
                \_ -> Expect.equal (Just "15. febru\u{00E1}ra") (withLocale "sk" (\loc -> formatDate loc Short "2031-02-15"))
            , test "14.2 Czech" <|
                \_ -> Expect.equal (Just "10. prosince") (withLocale "cs" (\loc -> formatDate loc Short "2025-12-10"))
            , test "14.3 Ukrainian" <|
                \_ -> Expect.equal (Just "5 \u{043B}\u{0438}\u{0441}\u{0442}\u{043E}\u{043F}\u{0430}\u{0434}\u{0430}") (withLocale "uk" (\loc -> formatDate loc Short "2025-11-05"))
            , test "14.4 Finnish relative" <|
                \_ -> Expect.equal (Just "8. elokuuta") (withLocale "fi" (\loc -> formatRelative loc Short "1998-08-08" "1998-08-15"))
            ]
        , describe "15. format_relative - short phrases"
            [ test "15.1 Cornish day after tomorrow" <|
                \_ -> Expect.equal (Just "an Mth ma") (withLocale "kw" (\loc -> formatRelative loc Short "2035-12-04" "2035-12-02"))
            , test "15.2 Mam day before yesterday" <|
                \_ -> Expect.equal (Just "Dom nchi'j") (withLocale "mam" (\loc -> formatRelative loc Short "2000-01-23" "2000-01-25"))
            , test "15.3 Q'eqchi' day after tomorrow" <|
                \_ -> Expect.equal (Just "a'in Vie") (withLocale "kek" (\loc -> formatRelative loc Short "2014-10-24" "2014-10-22"))
            ]
        , describe "16. Input validation"
            [ test "16.1 February 30" <|
                \_ -> Expect.equal Nothing (fmt "2025-02-30")
            , test "16.2 month 13" <|
                \_ -> Expect.equal Nothing (fmt "2025-13-01")
            , test "16.3 unpadded month and day" <|
                \_ -> Expect.equal Nothing (fmt "2025-6-1")
            , test "16.4 surrounding whitespace" <|
                \_ -> Expect.equal Nothing (fmt " 2025-06-01")
            , test "16.5 ISO datetime uses the date part" <|
                \_ -> Expect.equal (Just "June 1st") (fmt "2025-06-01T10:00:00")
            , test "16.6 February 29 in a non-leap year" <|
                \_ -> Expect.equal Nothing (formatDateWithYear en Normal "2023-02-29")
            , test "16.7 invalid asOf" <|
                \_ -> Expect.equal Nothing (rel "2025-03-16" "2025-04-31")
            ]
        ]
