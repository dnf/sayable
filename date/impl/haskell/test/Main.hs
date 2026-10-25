module Main (main) where

import Data.Maybe (isNothing)
import Test.Hspec

import SayableDate.Formatter (formatDate, formatDateWithYear, formatRelative)
import SayableDate.Types
import SayableDate.Locales (getLocale)

import qualified SayableDate.Locales.En as En
import qualified SayableDate.Locales.De as De
import qualified SayableDate.Locales.Fr as Fr
import qualified SayableDate.Locales.Ja as Ja
import qualified SayableDate.Locales.Ru as Ru
import qualified SayableDate.Locales.Ar as Ar
import qualified SayableDate.Locales.Es as Es

en :: DateLocale
en = En.locale

fmtDate :: Maybe String -> Maybe String
fmtDate = formatDate en Normal

fmtDateShort :: Maybe String -> Maybe String
fmtDateShort = formatDate en Short

fmtDateCompact :: Maybe String -> Maybe String
fmtDateCompact = formatDate en Compact

fmtRel :: Maybe String -> Maybe String -> Maybe String
fmtRel = formatRelative en Normal

fmtRelCompact :: Maybe String -> Maybe String -> Maybe String
fmtRelCompact = formatRelative en Compact

-- | Formats with the locale for a code (Nothing for an unknown code).
withLocale :: String -> (DateLocale -> Maybe String) -> Maybe String
withLocale code f = getLocale code >>= f

main :: IO ()
main = hspec $ do

    -- Section 1: Null / edge cases
    describe "1. Null / edge cases" $ do
        -- 1.1
        it "1.1 format_date null" $
            fmtDate Nothing `shouldBe` Nothing
        -- 1.2
        it "1.2 format_date empty" $
            fmtDate (Just "") `shouldBe` Nothing
        -- 1.3
        it "1.3 format_date invalid" $
            fmtDate (Just "invalid") `shouldBe` Nothing
        -- 1.4
        it "1.4 format_relative null asOf" $
            fmtRel (Just "2025-03-15") Nothing `shouldBe` Nothing
        -- 1.5
        it "1.5 format_relative null date" $
            fmtRel Nothing (Just "2025-03-15") `shouldBe` Nothing

    -- Section 2: format_date -- normal compactness (English)
    describe "2. format_date -- normal (English)" $ do
        -- 2.1
        it "2.1 March 15th" $
            fmtDate (Just "2025-03-15") `shouldBe` Just "March 15th"
        -- 2.2
        it "2.2 January 1st" $
            fmtDate (Just "2025-01-01") `shouldBe` Just "January 1st"
        -- 2.3
        it "2.3 May 22nd" $
            fmtDate (Just "2025-05-22") `shouldBe` Just "May 22nd"
        -- 2.4
        it "2.4 July 3rd" $
            fmtDate (Just "2025-07-03") `shouldBe` Just "July 3rd"
        -- 2.5
        it "2.5 December 31st" $
            fmtDate (Just "2025-12-31") `shouldBe` Just "December 31st"
        -- 2.6
        it "2.6 June 11th" $
            fmtDate (Just "2025-06-11") `shouldBe` Just "June 11th"
        -- 2.7
        it "2.7 ISO datetime input" $
            fmtDate (Just "2025-03-15T14:30:00") `shouldBe` Just "March 15th"

    -- Section 3: format_date -- short compactness (English)
    describe "3. format_date -- short (English)" $ do
        -- 3.1
        it "3.1 Mar 15" $
            fmtDateShort (Just "2025-03-15") `shouldBe` Just "Mar 15"
        -- 3.2
        it "3.2 Jan 1" $
            fmtDateShort (Just "2025-01-01") `shouldBe` Just "Jan 1"
        -- 3.3
        it "3.3 Dec 25" $
            fmtDateShort (Just "2025-12-25") `shouldBe` Just "Dec 25"

    -- Section 4: format_date -- compact (English)
    describe "4. format_date -- compact (English)" $ do
        -- 4.1
        it "4.1 3/15" $
            fmtDateCompact (Just "2025-03-15") `shouldBe` Just "3/15"
        -- 4.2
        it "4.2 1/1" $
            fmtDateCompact (Just "2025-01-01") `shouldBe` Just "1/1"

    -- Section 5: format_relative -- proximity tiers (English)
    describe "5. format_relative -- proximity tiers (English)" $ do
        -- 5.1
        it "5.1 today" $
            fmtRel (Just "2025-03-15") (Just "2025-03-15") `shouldBe` Just "today"
        -- 5.2
        it "5.2 tomorrow" $
            fmtRel (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "tomorrow"
        -- 5.3
        it "5.3 yesterday" $
            fmtRel (Just "2025-03-14") (Just "2025-03-15") `shouldBe` Just "yesterday"
        -- 5.4
        it "5.4 the day after tomorrow" $
            fmtRel (Just "2025-03-17") (Just "2025-03-15") `shouldBe` Just "the day after tomorrow"
        -- 5.5
        it "5.5 the day before yesterday" $
            fmtRel (Just "2025-03-13") (Just "2025-03-15") `shouldBe` Just "the day before yesterday"
        -- 5.6
        it "5.6 this Wednesday (+4 days)" $
            fmtRel (Just "2025-03-19") (Just "2025-03-15") `shouldBe` Just "this Wednesday"
        -- 5.7
        it "5.7 this Thursday (+5 days)" $
            fmtRel (Just "2025-03-20") (Just "2025-03-15") `shouldBe` Just "this Thursday"
        -- 5.8
        it "5.8 last Tuesday (-4 days)" $
            fmtRel (Just "2025-03-11") (Just "2025-03-15") `shouldBe` Just "last Tuesday"
        -- 5.9
        it "5.9 next Saturday (+7 days)" $
            fmtRel (Just "2025-03-22") (Just "2025-03-15") `shouldBe` Just "next Saturday"
        -- 5.10
        it "5.10 next Thursday (+12 days)" $
            fmtRel (Just "2025-03-27") (Just "2025-03-15") `shouldBe` Just "next Thursday"
        -- 5.11
        it "5.11 calendar fallback same year" $
            fmtRel (Just "2025-03-01") (Just "2025-03-15") `shouldBe` Just "March 1st"
        -- 5.12
        it "5.12 calendar fallback +26 days" $
            fmtRel (Just "2025-04-10") (Just "2025-03-15") `shouldBe` Just "April 10th"
        -- 5.13
        it "5.13 different year includes year" $
            fmtRel (Just "2026-01-05") (Just "2025-03-15") `shouldBe` Just "January 5th, 2026"
        -- 5.14
        it "5.14 past year includes year" $
            fmtRel (Just "2024-12-25") (Just "2025-03-15") `shouldBe` Just "December 25th, 2024"

    -- Section 6: format_relative -- compact skips weekday tiers
    describe "6. format_relative -- compact" $ do
        -- 6.1
        it "6.1 compact today" $
            fmtRelCompact (Just "2025-03-15") (Just "2025-03-15") `shouldBe` Just "today"
        -- 6.2
        it "6.2 compact tomorrow" $
            fmtRelCompact (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "tomorrow"
        -- 6.3
        it "6.3 compact goes straight to numeric" $
            fmtRelCompact (Just "2025-03-19") (Just "2025-03-15") `shouldBe` Just "3/19"
        -- 6.4
        it "6.4 compact different year" $
            fmtRelCompact (Just "2026-01-05") (Just "2025-03-15") `shouldBe` Just "1/5/26"

    -- Section 7: Locale -- German
    describe "7. Locale -- German" $ do
        -- 7.1
        it "7.1 German format_date" $
            formatDate De.locale Normal (Just "2025-03-15") `shouldBe` Just "15. M\228rz"
        -- 7.2
        it "7.2 German tomorrow" $
            formatRelative De.locale Normal (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "morgen"
        -- 7.3
        it "7.3 German day after tomorrow" $
            formatRelative De.locale Normal (Just "2025-03-17") (Just "2025-03-15") `shouldBe` Just "\252bermorgen"
        -- 7.4
        it "7.4 German this Wednesday" $
            formatRelative De.locale Normal (Just "2025-03-19") (Just "2025-03-15") `shouldBe` Just "diesen Mittwoch"

    -- Section 8: Locale -- French
    describe "8. Locale -- French" $ do
        -- 8.1
        it "8.1 French 1er mars" $
            formatDate Fr.locale Normal (Just "2025-03-01") `shouldBe` Just "1er mars"
        -- 8.2
        it "8.2 French 15 mars" $
            formatDate Fr.locale Normal (Just "2025-03-15") `shouldBe` Just "15 mars"
        -- 8.3
        it "8.3 French tomorrow" $
            formatRelative Fr.locale Normal (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "demain"

    -- Section 9: Locale -- Japanese
    describe "9. Locale -- Japanese" $ do
        -- 9.1
        it "9.1 Japanese date" $
            formatDate Ja.locale Normal (Just "2025-03-15") `shouldBe` Just "3\26376\&15\26085"
        -- 9.2
        it "9.2 Japanese tomorrow" $
            formatRelative Ja.locale Normal (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "\26126\26085"
        -- 9.3
        it "9.3 Japanese this Wednesday" $
            formatRelative Ja.locale Normal (Just "2025-03-19") (Just "2025-03-15") `shouldBe` Just "\20170\24230\12398\27700\26332\26085"

    -- Section 10: Locale -- Russian (genitive months)
    describe "10. Locale -- Russian" $ do
        -- 10.1
        it "10.1 Russian genitive month" $
            formatDate Ru.locale Normal (Just "2025-03-15") `shouldBe` Just "15 \1084\1072\1088\1090\1072"
        -- 10.2
        it "10.2 Russian tomorrow" $
            formatRelative Ru.locale Normal (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "\1079\1072\1074\1090\1088\1072"

    -- Section 11: Locale -- Arabic
    describe "11. Locale -- Arabic" $ do
        -- 11.1
        it "11.1 Arabic date" $
            formatDate Ar.locale Normal (Just "2025-03-15") `shouldBe` Just "15 \1605\1575\1585\1587"
        -- 11.2
        it "11.2 Arabic tomorrow" $
            formatRelative Ar.locale Normal (Just "2025-03-16") (Just "2025-03-15") `shouldBe` Just "\1594\1583\1575\1611"

    -- Section 12: Locale -- Spanish
    describe "12. Locale -- Spanish" $ do
        -- 12.1
        it "12.1 Spanish date" $
            formatDate Es.locale Normal (Just "2025-03-15") `shouldBe` Just "15 de marzo"
        -- 12.2
        it "12.2 Spanish day after tomorrow" $
            formatRelative Es.locale Normal (Just "2025-03-17") (Just "2025-03-15") `shouldBe` Just "pasado ma\241ana"

    -- Locale lookup
    describe "Locale lookup" $ do
        it "known locale en" $
            fmap localeCode (getLocale "en") `shouldBe` Just "en"
        it "unknown code" $
            getLocale "xx" `shouldSatisfy` isNothing

    -- Section 13: format_date_with_year
    describe "13. format_date_with_year" $ do
        -- 13.1
        it "13.1 format_date_with_year en normal" $
            withLocale "en" (\l -> formatDateWithYear l Normal (Just "2018-02-04")) `shouldBe` Just "February 4th, 2018"
        -- 13.2
        it "13.2 format_date_with_year en short" $
            withLocale "en" (\l -> formatDateWithYear l Short (Just "2025-03-15")) `shouldBe` Just "Mar 15, 2025"
        -- 13.3
        it "13.3 format_date_with_year en compact" $
            withLocale "en" (\l -> formatDateWithYear l Compact (Just "1997-01-21")) `shouldBe` Just "1/21/97"
        -- 13.4
        it "13.4 two-digit year keeps its leading zero" $
            withLocale "tg" (\l -> formatDateWithYear l Compact (Just "2007-05-20")) `shouldBe` Just "20/5/07"
        -- 13.5
        it "13.5 format_date_with_year fi short" $
            withLocale "fi" (\l -> formatDateWithYear l Short (Just "1996-06-21")) `shouldBe` Just "21. kes\228kuuta 1996"

    -- Section 14: Short month names (locales that keep the full genitive)
    describe "14. Short month names (locales that keep the full genitive)" $ do
        -- 14.1
        it "14.1 format_date sk short" $
            withLocale "sk" (\l -> formatDate l Short (Just "2031-02-15")) `shouldBe` Just "15. febru\225ra"
        -- 14.2
        it "14.2 format_date cs short" $
            withLocale "cs" (\l -> formatDate l Short (Just "2025-12-10")) `shouldBe` Just "10. prosince"
        -- 14.3
        it "14.3 format_date uk short" $
            withLocale "uk" (\l -> formatDate l Short (Just "2025-11-05")) `shouldBe` Just "5 \1083\1080\1089\1090\1086\1087\1072\1076\1072"
        -- 14.4
        it "14.4 format_relative fi short" $
            withLocale "fi" (\l -> formatRelative l Short (Just "1998-08-08") (Just "1998-08-15")) `shouldBe` Just "8. elokuuta"

    -- Section 15: format_relative — short phrases
    describe "15. format_relative \8212 short phrases" $ do
        -- 15.1
        it "15.1 day after tomorrow" $
            withLocale "kw" (\l -> formatRelative l Short (Just "2035-12-04") (Just "2035-12-02")) `shouldBe` Just "an Mth ma"
        -- 15.2
        it "15.2 day before yesterday" $
            withLocale "mam" (\l -> formatRelative l Short (Just "2000-01-23") (Just "2000-01-25")) `shouldBe` Just "Dom nchi'j"
        -- 15.3
        it "15.3 day after tomorrow" $
            withLocale "kek" (\l -> formatRelative l Short (Just "2014-10-24") (Just "2014-10-22")) `shouldBe` Just "a'in Vie"

    -- Section 16: Input validation
    describe "16. Input validation" $ do
        -- 16.1
        it "16.1 February 30 doesn't exist" $
            withLocale "en" (\l -> formatDate l Normal (Just "2025-02-30")) `shouldBe` Nothing
        -- 16.2
        it "16.2 Month 13" $
            withLocale "en" (\l -> formatDate l Normal (Just "2025-13-01")) `shouldBe` Nothing
        -- 16.3
        it "16.3 Unpadded month and day" $
            withLocale "en" (\l -> formatDate l Normal (Just "2025-6-1")) `shouldBe` Nothing
        -- 16.4
        it "16.4 Surrounding whitespace" $
            withLocale "en" (\l -> formatDate l Normal (Just " 2025-06-01")) `shouldBe` Nothing
        -- 16.5
        it "16.5 An ISO datetime: only the date part is used" $
            withLocale "en" (\l -> formatDate l Normal (Just "2025-06-01T10:00:00")) `shouldBe` Just "June 1st"
        -- 16.6
        it "16.6 February 29 in a non-leap year" $
            withLocale "en" (\l -> formatDateWithYear l Normal (Just "2023-02-29")) `shouldBe` Nothing
        -- 16.7
        it "16.7 Invalid asOf" $
            withLocale "en" (\l -> formatRelative l Normal (Just "2025-03-16") (Just "2025-04-31")) `shouldBe` Nothing
