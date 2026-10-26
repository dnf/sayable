module Main (main) where

import Data.Maybe (isNothing)
import Test.Hspec

import SayableDuration.Formatter (formatDuration, formatDurationIso, formatSince, formatUntil)
import SayableDuration.Types
import SayableDuration.Locales (getLocale)

import qualified SayableDuration.Locales.En as En
import qualified SayableDuration.Locales.De as De
import qualified SayableDuration.Locales.Fr as Fr
import qualified SayableDuration.Locales.Ja as Ja

en :: DurationLocale
en = En.locale

dur :: Int -> Maybe String
dur = formatDuration en Normal

durIso :: String -> String -> Maybe String
durIso = formatDurationIso en Normal

since :: Maybe String -> Maybe String -> Maybe String
since = formatSince en Normal

until' :: Maybe String -> Maybe String -> Maybe String
until' = formatUntil en Normal

-- | Formats with the locale for a code (Nothing for an unknown code).
withLocale :: String -> (DurationLocale -> Maybe String) -> Maybe String
withLocale code f = getLocale code >>= f

main :: IO ()
main = hspec $ do

    -- Section 1: Null / edge cases
    describe "1. Null / edge cases" $ do
        -- 1.1
        it "1.1 format_duration null returns null" $
            formatDuration en Normal (-1) `shouldBe` Nothing
        -- 1.2
        it "1.2 format_duration negative returns null" $
            dur (-1) `shouldBe` Nothing
        -- 1.3
        it "1.3 format_since null start returns null" $
            since Nothing (Just "2025-01-15T10:00:00") `shouldBe` Nothing
        -- 1.4
        it "1.4 format_until null target returns null" $
            until' Nothing (Just "2025-01-15T10:00:00") `shouldBe` Nothing
        -- 1.5
        it "1.5 format_since asOf before start returns null" $
            since (Just "2025-01-15T10:00:00") (Just "2025-01-15T09:00:00") `shouldBe` Nothing
        -- 1.6
        it "1.6 format_until target in the past returns null" $
            until' (Just "2025-01-15T09:00:00") (Just "2025-01-15T10:00:00") `shouldBe` Nothing

    -- Section 2: Duration -- seconds tier (0-59s)
    describe "2. Duration -- seconds tier" $ do
        -- 2.1
        it "2.1 0 seconds is just now" $
            dur 0 `shouldBe` Just "just now"
        -- 2.2
        it "2.2 1 second" $
            dur 1 `shouldBe` Just "1 second"
        -- 2.3
        it "2.3 45 seconds" $
            dur 45 `shouldBe` Just "45 seconds"
        -- 2.4
        it "2.4 59 seconds" $
            dur 59 `shouldBe` Just "59 seconds"

    -- Section 3: Duration -- minutes + seconds tier (1-4 min)
    describe "3. Duration -- minutes + seconds tier" $ do
        -- 3.1
        it "3.1 1 minute" $
            dur 60 `shouldBe` Just "1 minute"
        -- 3.2
        it "3.2 1 minute, 30 seconds" $
            dur 90 `shouldBe` Just "1 minute, 30 seconds"
        -- 3.3
        it "3.3 4 minutes" $
            dur 240 `shouldBe` Just "4 minutes"
        -- 3.4
        it "3.4 4 minutes, 30 seconds" $
            dur 270 `shouldBe` Just "4 minutes, 30 seconds"

    -- Section 4: Duration -- minutes tier (5-59 min)
    describe "4. Duration -- minutes tier" $ do
        -- 4.1
        it "4.1 5 minutes" $
            dur 300 `shouldBe` Just "5 minutes"
        -- 4.2
        it "4.2 25 minutes" $
            dur 1500 `shouldBe` Just "25 minutes"
        -- 4.3
        it "4.3 59 minutes" $
            dur 3540 `shouldBe` Just "59 minutes"

    -- Section 5: Duration -- hours + minutes tier (1-5 hr)
    describe "5. Duration -- hours + minutes tier" $ do
        -- 5.1
        it "5.1 1 hour" $
            dur 3600 `shouldBe` Just "1 hour"
        -- 5.2
        it "5.2 1\189 hours (half marker)" $
            dur 5400 `shouldBe` Just "1\189 hours"
        -- 5.3
        it "5.3 2 hours, 15 minutes" $
            dur 8100 `shouldBe` Just "2 hours, 15 minutes"
        -- 5.4
        it "5.4 5 hours" $
            dur 18000 `shouldBe` Just "5 hours"

    -- Section 6: Duration -- hours tier (6-23 hr)
    describe "6. Duration -- hours tier" $ do
        -- 6.1
        it "6.1 8 hours" $
            dur 28800 `shouldBe` Just "8 hours"
        -- 6.2
        it "6.2 23 hours" $
            dur 82800 `shouldBe` Just "23 hours"

    -- Section 7: Duration -- days tier
    describe "7. Duration -- days tier" $ do
        -- 7.1
        it "7.1 1 day" $
            dur 86400 `shouldBe` Just "1 day"
        -- 7.2
        it "7.2 1 day, 3 hours" $
            dur 97200 `shouldBe` Just "1 day, 3 hours"
        -- 7.3
        it "7.3 1\189 days (half marker)" $
            dur 129600 `shouldBe` Just "1\189 days"
        -- 7.4
        it "7.4 5 days" $
            dur 432000 `shouldBe` Just "5 days"
        -- 7.5
        it "7.5 2 days" $
            dur 172800 `shouldBe` Just "2 days"

    -- Section 8: Duration -- weeks tier
    describe "8. Duration -- weeks tier" $ do
        -- 8.1
        it "8.1 1 week" $
            dur 604800 `shouldBe` Just "1 week"
        -- 8.2
        it "8.2 2 weeks, 1 day" $
            dur 1296000 `shouldBe` Just "2 weeks, 1 day"
        -- 8.3
        it "8.3 4 weeks" $
            dur 2419200 `shouldBe` Just "4 weeks"

    -- Section 9: Duration -- months and years tier
    describe "9. Duration -- months and years tier" $ do
        -- 9.1
        it "9.1 1 month (~31 days)" $
            dur 2678400 `shouldBe` Just "1 month"
        -- 9.2
        it "9.2 3 months (~91 days)" $
            dur 7884000 `shouldBe` Just "3 months"
        -- 9.3
        it "9.3 1 year (365 days)" $
            dur 31536000 `shouldBe` Just "1 year"
        -- 9.4
        it "9.4 1 year, 3 months (~456 days)" $
            dur 39420000 `shouldBe` Just "1 year, 3 months"

    -- Section 10: Duration from ISO timestamps
    describe "10. Duration from ISO timestamps" $ do
        -- 10.1
        it "10.1 ISO 1\189 hours" $
            durIso "2025-01-15T10:00:00" "2025-01-15T11:30:00" `shouldBe` Just "1\189 hours"
        -- 10.2
        it "10.2 ISO 45 minutes" $
            durIso "2025-01-15T10:00:00" "2025-01-15T10:45:00" `shouldBe` Just "45 minutes"

    -- Section 11: Relative time -- since
    describe "11. Relative time -- since" $ do
        -- 11.1
        it "11.1 since just now" $
            since (Just "2025-01-15T10:00:00") (Just "2025-01-15T10:00:00") `shouldBe` Just "just now"
        -- 11.2
        it "11.2 since 30 seconds ago" $
            since (Just "2025-01-15T10:00:00") (Just "2025-01-15T10:00:30") `shouldBe` Just "30 seconds ago"
        -- 11.3
        it "11.3 since 45 minutes ago" $
            since (Just "2025-01-15T10:00:00") (Just "2025-01-15T10:45:00") `shouldBe` Just "45 minutes ago"
        -- 11.4
        it "11.4 since 3 hours ago" $
            since (Just "2025-01-15T10:00:00") (Just "2025-01-15T13:00:00") `shouldBe` Just "3 hours ago"

    -- Section 12: Relative time -- until
    describe "12. Relative time -- until" $ do
        -- 12.1
        it "12.1 until just now" $
            until' (Just "2025-01-15T10:00:00") (Just "2025-01-15T10:00:00") `shouldBe` Just "just now"
        -- 12.2
        it "12.2 until in 20 minutes" $
            until' (Just "2025-01-15T10:20:00") (Just "2025-01-15T10:00:00") `shouldBe` Just "in 20 minutes"
        -- 12.3
        it "12.3 until in 3 hours" $
            until' (Just "2025-01-15T13:00:00") (Just "2025-01-15T10:00:00") `shouldBe` Just "in 3 hours"

    -- Section 13: Locale -- German
    describe "13. Locale -- German" $ do
        -- 13.1
        it "13.1 German 1 hour" $
            formatDuration De.locale Normal 3600 `shouldBe` Just "1 Stunde"
        -- 13.2
        it "13.2 German since 5 minutes" $
            formatSince De.locale Normal (Just "2025-01-15T10:00:00") (Just "2025-01-15T10:05:00") `shouldBe` Just "vor 5 Minuten"

    -- Section 14: Locale -- French
    describe "14. Locale -- French" $ do
        -- 14.1
        it "14.1 French 2 hours" $
            formatDuration Fr.locale Normal 7200 `shouldBe` Just "2 heures"

    -- Section 15: Locale -- Japanese
    describe "15. Locale -- Japanese" $ do
        -- 15.1
        it "15.1 Japanese 2 minutes" $
            formatDuration Ja.locale Normal 120 `shouldBe` Just "2\20998"
        -- 15.2
        it "15.2 Japanese since 1 hour" $
            formatSince Ja.locale Normal (Just "2025-01-15T10:00:00") (Just "2025-01-15T11:00:00") `shouldBe` Just "1\26178\38291\21069"

    -- Section 16: Short compactness -- duration
    describe "16. Short compactness" $ do
        -- 16.1
        it "16.1 short 1 hour" $
            formatDuration en Short 3600 `shouldBe` Just "1h"
        -- 16.2
        it "16.2 short 1 minute, 30 seconds" $
            formatDuration en Short 90 `shouldBe` Just "1m, 30s"

    -- Section 17: Compact compactness -- duration
    describe "17. Compact compactness" $ do
        -- 17.1
        it "17.1 compact 1 hour" $
            formatDuration en Compact 3600 `shouldBe` Just "1h"
        -- 17.2
        it "17.2 compact 1 minute 30 seconds" $
            formatDuration en Compact 90 `shouldBe` Just "1m30s"

    -- Locale lookup
    describe "Locale lookup" $ do
        it "known locale en" $
            fmap localeCode (getLocale "en") `shouldBe` Just "en"
        it "unknown code" $
            getLocale "xx" `shouldSatisfy` isNothing

    -- Section 18: Short compactness — relative time
    describe "18. Short compactness \8212 relative time" $ do
        -- 18.1
        it "18.1 days and hours both kept" $
            withLocale "men" (\l -> formatSince l Normal (Just "2025-01-20T01:32:11") (Just "2025-01-22T15:39:16")) `shouldBe` Just "l\596h\596nga 2, awa 14 taa gb\596y\596"

    -- Section 19: Range (500-year ceiling)
    describe "19. Range (500-year ceiling)" $ do
        -- 19.1
        it "19.1 500 Julian years: 6000 months, the ceiling" $
            withLocale "en" (\l -> formatDuration l Normal 15778800000) `shouldBe` Just "500 years"
        -- 19.2
        it "19.2 over 6000 months" $
            withLocale "en" (\l -> formatDuration l Normal 15800000000) `shouldBe` Nothing
        -- 19.3
        it "19.3 well beyond the ceiling (and 32-bit range)" $
            withLocale "en" (\l -> formatDuration l Normal 99999999999) `shouldBe` Nothing
        -- 19.4
        it "19.4 525 years ago" $
            withLocale "en" (\l -> formatSince l Normal (Just "1500-01-01T00:00:00") (Just "2025-01-01T00:00:00")) `shouldBe` Nothing
        -- 19.5
        it "19.5 575 years from now" $
            withLocale "en" (\l -> formatUntil l Normal (Just "2600-01-01T00:00:00") (Just "2025-01-01T00:00:00")) `shouldBe` Nothing

    -- Section 20: Timestamp validation
    describe "20. Timestamp validation" $ do
        -- 20.1
        it "20.1 seconds are optional" $
            withLocale "en" (\l -> formatDurationIso l Normal "2025-01-15T10:00" "2025-01-15T11:30:00") `shouldBe` Just "1\189 hours"
        -- 20.2
        it "20.2 minutes are required" $
            withLocale "en" (\l -> formatDurationIso l Normal "2025-01-15T10" "2025-01-15T11:30:00") `shouldBe` Nothing
        -- 20.3
        it "20.3 unpadded date" $
            withLocale "en" (\l -> formatDurationIso l Normal "2025-1-5T10:00:00" "2025-01-15T11:30:00") `shouldBe` Nothing
        -- 20.4
        it "20.4 impossible date" $
            withLocale "en" (\l -> formatDurationIso l Normal "2025-02-30T10:00:00" "2025-03-15T11:30:00") `shouldBe` Nothing
        -- 20.5
        it "20.5 hour out of range" $
            withLocale "en" (\l -> formatSince l Normal (Just "2025-01-15T10:00:00") (Just "2025-01-15T25:00:00")) `shouldBe` Nothing
