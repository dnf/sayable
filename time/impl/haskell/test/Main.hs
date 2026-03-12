module Main (main) where

import Data.Maybe (isNothing)
import Test.Hspec

import SayableTime.Formatter (formatTime)
import SayableTime.Types
import SayableTime.Locales (getLocale)

import qualified SayableTime.Locales.En as En
import qualified SayableTime.Locales.De as De
import qualified SayableTime.Locales.Fr as Fr
import qualified SayableTime.Locales.Ja as Ja
import qualified SayableTime.Locales.Fi as Fi

en :: TimeLocale
en = En.locale

time :: Maybe String -> Maybe String
time = formatTime en Normal

timeShort :: Maybe String -> Maybe String
timeShort = formatTime en Short

timeCompact :: Maybe String -> Maybe String
timeCompact = formatTime en Compact

main :: IO ()
main = hspec $ do

    -- Section 1: Null / edge cases
    describe "1. Null / edge cases" $ do
        -- 1.1
        it "1.1 null input" $
            time Nothing `shouldBe` Nothing
        -- 1.2
        it "1.2 empty string" $
            time (Just "") `shouldBe` Nothing
        -- 1.3
        it "1.3 invalid string" $
            time (Just "invalid") `shouldBe` Nothing
        -- 1.4
        it "1.4 invalid hour" $
            time (Just "25:00") `shouldBe` Nothing

    -- Section 2: Clock time (normal compactness)
    describe "2. Clock time (normal)" $ do
        -- 2.1
        it "2.1 midnight" $
            time (Just "00:00") `shouldBe` Just "midnight"
        -- 2.2
        it "2.2 noon" $
            time (Just "12:00") `shouldBe` Just "noon"
        -- 2.3
        it "2.3 three o'clock" $
            time (Just "15:00") `shouldBe` Just "three o'clock"
        -- 2.4
        it "2.4 a quarter past two" $
            time (Just "14:15") `shouldBe` Just "a quarter past two"
        -- 2.5
        it "2.5 half past nine" $
            time (Just "09:30") `shouldBe` Just "half past nine"
        -- 2.6
        it "2.6 a quarter to eleven" $
            time (Just "10:45") `shouldBe` Just "a quarter to eleven"
        -- 2.7
        it "2.7 five past eight" $
            time (Just "08:05") `shouldBe` Just "five past eight"
        -- 2.8
        it "2.8 five to five" $
            time (Just "16:55") `shouldBe` Just "five to five"
        -- 2.9
        it "2.9 23:58 rounds to midnight" $
            time (Just "23:58") `shouldBe` Just "midnight"
        -- 2.10
        it "2.10 07:22 rounds to twenty past seven" $
            time (Just "07:22") `shouldBe` Just "twenty past seven"
        -- 2.11
        it "2.11 ISO datetime input" $
            time (Just "2025-01-15T14:15:00") `shouldBe` Just "a quarter past two"

    -- Section 3: Clock time (short compactness)
    describe "3. Clock time (short)" $ do
        -- 3.1
        it "3.1 2:15 PM" $
            timeShort (Just "14:15") `shouldBe` Just "2:15 PM"
        -- 3.2
        it "3.2 9:30 AM" $
            timeShort (Just "09:30") `shouldBe` Just "9:30 AM"
        -- 3.3
        it "3.3 12:00 AM" $
            timeShort (Just "00:00") `shouldBe` Just "12:00 AM"
        -- 3.4
        it "3.4 12:00 PM" $
            timeShort (Just "12:00") `shouldBe` Just "12:00 PM"

    -- Section 4: Clock time (compact)
    describe "4. Clock time (compact)" $ do
        -- 4.1
        it "4.1 2:15p" $
            timeCompact (Just "14:15") `shouldBe` Just "2:15p"
        -- 4.2
        it "4.2 9:30a" $
            timeCompact (Just "09:30") `shouldBe` Just "9:30a"

    -- Section 5: Locale -- German
    describe "5. Locale -- German" $ do
        -- 5.1
        it "5.1 German half-to pattern" $
            formatTime De.locale Normal (Just "15:30") `shouldBe` Just "halb vier"

    -- Section 6: Locale -- French
    describe "6. Locale -- French" $ do
        -- 6.1
        it "6.1 French quarter past" $
            formatTime Fr.locale Normal (Just "15:15") `shouldBe` Just "trois heures et quart"

    -- Section 7: Locale -- Japanese
    describe "7. Locale -- Japanese" $ do
        -- 7.1
        it "7.1 Japanese half past three" $
            formatTime Ja.locale Normal (Just "15:30") `shouldBe` Just "\19977\26178\21322"

    -- Section 8: Locale -- Finnish (dot separator, short)
    describe "8. Locale -- Finnish (dot separator, short)" $ do
        -- 8.1
        it "8.1 Finnish dot separator" $
            formatTime Fi.locale Short (Just "14:15") `shouldBe` Just "14.15"
        -- 8.2
        it "8.2 Finnish midnight dot" $
            formatTime Fi.locale Short (Just "00:00") `shouldBe` Just "0.00"

    -- Locale lookup
    describe "Locale lookup" $ do
        it "known locale en" $
            fmap localeCode (getLocale "en") `shouldBe` Just "en"
        it "unknown code" $
            getLocale "xx" `shouldSatisfy` isNothing
