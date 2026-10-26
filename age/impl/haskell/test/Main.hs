module Main (main) where

import Data.List (isInfixOf)
import Data.Maybe (isNothing)
import Test.Hspec

import SayableAge.Formatter (formatAgePure, formatStagePure)
import SayableAge.Types

import qualified SayableAge.Locales.Am as Am
import qualified SayableAge.Locales.En as En
import qualified SayableAge.Locales.Es as Es
import qualified SayableAge.Locales.He as He
import qualified SayableAge.Locales.Id as Id
import qualified SayableAge.Locales.Mk as Mk
import qualified SayableAge.Locales.Sw as Sw
import SayableAge.Locales (getLocale)

en :: Locale
en = En.locale

age :: String -> String -> Maybe String
age = formatAgePure en Normal

ageS :: Locale -> String -> String -> Maybe String
ageS loc = formatAgePure loc Normal

ageShort :: String -> String -> Maybe String
ageShort = formatAgePure en Short

ageCompact :: String -> String -> Maybe String
ageCompact = formatAgePure en Compact

stage :: String -> String -> Maybe String
stage dob asOf = formatStagePure en dob asOf Nothing

stageG :: Locale -> String -> String -> Maybe Gender -> Maybe String
stageG = formatStagePure

shouldContainWeeks :: Maybe String -> Expectation
shouldContainWeeks result = case result of
    Nothing -> expectationFailure "expected weeks pattern, got Nothing"
    Just s  -> s `shouldSatisfy` ("week" `isInfixOf`)

-- | Formats with the locale for a code (Nothing for an unknown code).
withLocale :: String -> (Locale -> Maybe String) -> Maybe String
withLocale code f = getLocale code >>= f

main :: IO ()
main = hspec $ do

    -- 1. Null / edge cases
    describe "1. Null / edge cases" $ do
        it "1.1 null dateOfBirth" $
            age "" "2025-06-15" `shouldBe` Nothing
        it "1.3 empty string" $
            age "" "2025-06-15" `shouldBe` Nothing
        it "1.4 future DOB" $
            age "2025-07-01" "2025-06-15" `shouldBe` Nothing
        it "1.5 exactly 500 years" $
            age "1525-06-15" "2025-06-15" `shouldBe` Just "500 years"
        it "1.6 501 years" $
            age "1524-06-15" "2025-06-15" `shouldBe` Nothing
        it "1.7 1000 years" $
            age "1025-06-15" "2025-06-15" `shouldBe` Nothing

    -- 2. Days tier (0-6 days)
    describe "2. Days tier" $ do
        it "2.1 born today" $
            age "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "2.2 1 day" $
            age "2025-06-14" "2025-06-15" `shouldBe` Just "1 day"
        it "2.3 3 days" $
            age "2025-06-12" "2025-06-15" `shouldBe` Just "3 days"
        it "2.4 6 days" $
            age "2025-06-09" "2025-06-15" `shouldBe` Just "6 days"
        it "2.5 7 days = 1 week" $
            age "2025-06-08" "2025-06-15" `shouldBe` Just "1 week"

    -- 3. Weeks+days tier
    describe "3. Weeks+days tier" $ do
        it "3.1 exactly 7 days" $
            age "2025-06-08" "2025-06-15" `shouldBe` Just "1 week"
        it "3.2 1 week, 1 day" $
            age "2025-06-07" "2025-06-15" `shouldBe` Just "1 week, 1 day"
        it "3.3 1 week, 2 days" $
            age "2025-06-06" "2025-06-15" `shouldBe` Just "1 week, 2 days"
        it "3.4 1 week, 6 days" $
            age "2025-06-02" "2025-06-15" `shouldBe` Just "1 week, 6 days"
        it "3.5 2 weeks" $
            age "2025-06-01" "2025-06-15" `shouldBe` Just "2 weeks"
        it "3.6 2 weeks, 1 day" $
            age "2025-05-31" "2025-06-15" `shouldBe` Just "2 weeks, 1 day"
        it "3.7 2 weeks, 6 days" $
            age "2025-05-26" "2025-06-15" `shouldBe` Just "2 weeks, 6 days"
        it "3.8 3 weeks" $
            age "2025-05-25" "2025-06-15" `shouldBe` Just "3 weeks"
        it "3.9 4 weeks, 3 days" $
            age "2025-05-15" "2025-06-15" `shouldBe` Just "4 weeks, 3 days"
        it "3.10 8 weeks, 5 days" $
            age "2025-04-15" "2025-06-15" `shouldBe` Just "8 weeks, 5 days"
        it "3.11 13 weeks" $
            age "2025-03-15" "2025-06-14" `shouldBe` Just "13 weeks"
        it "3.12 3 months transition" $
            age "2025-03-15" "2025-06-15" `shouldBe` Just "3 months"

    -- 4. Month boundaries - standard months
    describe "4. Month boundaries - standard" $ do
        it "4.1 Jan1 -> Apr1 = 3 months" $
            age "2025-01-01" "2025-04-01" `shouldBe` Just "3 months"
        it "4.2 Jan1 -> Mar31 still weeks" $
            shouldContainWeeks (age "2025-01-01" "2025-03-31")
        it "4.3 Jun15 -> Sep15 = 3 months" $
            age "2025-06-15" "2025-09-15" `shouldBe` Just "3 months"
        it "4.4 Jun15 -> Sep14 still weeks" $
            shouldContainWeeks (age "2025-06-15" "2025-09-14")
        it "4.5 Jun15 -> Dec15 = 6 months" $
            age "2025-06-15" "2025-12-15" `shouldBe` Just "6 months"

    -- 5. Month boundaries - Feb non-leap
    describe "5. Month boundaries - Feb non-leap" $ do
        it "5.1 Jan31 -> Feb28" $
            age "2025-01-31" "2025-02-28" `shouldBe` Just "4 weeks"
        it "5.2 Jan31 -> Apr30 = 3 months" $
            age "2025-01-31" "2025-04-30" `shouldBe` Just "3 months"
        it "5.3 Jan31 -> Apr29 still weeks" $
            shouldContainWeeks (age "2025-01-31" "2025-04-29")
        it "5.4 Feb1 -> May1 = 3 months" $
            age "2025-02-01" "2025-05-01" `shouldBe` Just "3 months"
        it "5.5 Feb1 -> Apr30 still weeks" $
            shouldContainWeeks (age "2025-02-01" "2025-04-30")

    -- 6. Month boundaries - Feb leap year
    describe "6. Month boundaries - Feb leap" $ do
        it "6.1 Jan31 -> Feb29 leap" $
            age "2024-01-31" "2024-02-29" `shouldBe` Just "4 weeks, 1 day"
        it "6.2 Jan31 -> Feb28 leap" $
            age "2024-01-31" "2024-02-28" `shouldBe` Just "4 weeks"
        it "6.3 Jan31 -> Apr30 = 3 months" $
            age "2024-01-31" "2024-04-30" `shouldBe` Just "3 months"
        it "6.4 Jan30 -> Feb29 weeks" $
            shouldContainWeeks (age "2024-01-30" "2024-02-29")
        it "6.5 Jan30 -> Feb28 weeks" $
            shouldContainWeeks (age "2024-01-30" "2024-02-28")

    -- 7. Month boundaries - 30-day months
    describe "7. Month boundaries - 30-day months" $ do
        it "7.1 Mar31 -> Jun30 = 3 months" $
            age "2025-03-31" "2025-06-30" `shouldBe` Just "3 months"
        it "7.2 Mar31 -> Jun29 still weeks" $
            shouldContainWeeks (age "2025-03-31" "2025-06-29")
        it "7.3 Aug31 -> Nov30 = 3 months" $
            age "2025-08-31" "2025-11-30" `shouldBe` Just "3 months"
        it "7.4 Aug31 -> Nov29 still weeks" $
            shouldContainWeeks (age "2025-08-31" "2025-11-29")

    -- 8. Month boundaries - leap year baby
    describe "8. Leap year baby" $ do
        it "8.1 Feb29 -> May29 = 3 months" $
            age "2024-02-29" "2024-05-29" `shouldBe` Just "3 months"
        it "8.2 Feb29 -> May28 still weeks" $
            shouldContainWeeks (age "2024-02-29" "2024-05-28")
        it "8.3 Feb29 -> Feb28 next year = 12 months" $
            age "2024-02-29" "2025-02-28" `shouldBe` Just "12 months"
        it "8.4 Feb29 -> Mar1 next year = 12 months" $
            age "2024-02-29" "2025-03-01" `shouldBe` Just "12 months"

    -- 9. Months tier (3-23 months)
    describe "9. Months tier" $ do
        it "9.1 3 months" $
            age "2025-01-15" "2025-04-15" `shouldBe` Just "3 months"
        it "9.2 6 months" $
            age "2025-01-15" "2025-07-15" `shouldBe` Just "6 months"
        it "9.3 12 months (not 1 year)" $
            age "2024-06-15" "2025-06-15" `shouldBe` Just "12 months"
        it "9.4 23 months" $
            age "2024-01-15" "2025-12-15" `shouldBe` Just "23 months"
        it "9.5 5 months (day before boundary)" $
            age "2025-01-15" "2025-07-14" `shouldBe` Just "5 months"
        it "9.6 5 months (cross-year)" $
            age "2024-11-10" "2025-04-10" `shouldBe` Just "5 months"

    -- 10. Years+months tier (24-35 months)
    describe "10. Years+months tier" $ do
        it "10.1 2 years" $
            age "2023-06-15" "2025-06-15" `shouldBe` Just "2 years"
        it "10.2 2 years, 1 month" $
            age "2023-06-15" "2025-07-15" `shouldBe` Just "2 years, 1 month"
        it "10.3 2 years, 6 months" $
            age "2023-06-15" "2025-12-15" `shouldBe` Just "2 years, 6 months"
        it "10.4 2 years, 11 months" $
            age "2023-06-15" "2026-05-15" `shouldBe` Just "2 years, 11 months"
        it "10.5 day before 24 months = 23 months" $
            age "2023-06-15" "2025-06-14" `shouldBe` Just "23 months"

    -- 11. Half-year tier (3-6 years)
    describe "11. Half-year tier" $ do
        it "11.1 3 years" $
            age "2022-06-15" "2025-06-15" `shouldBe` Just "3 years"
        it "11.2 3y5m = 3 years" $
            age "2022-06-15" "2025-11-15" `shouldBe` Just "3 years"
        it "11.3 3y6m = 3\189 years" $
            age "2022-06-15" "2025-12-15" `shouldBe` Just "3\189 years"
        it "11.4 3y11m = 3\189 years" $
            age "2022-06-15" "2026-05-15" `shouldBe` Just "3\189 years"
        it "11.5 4 years" $
            age "2021-06-15" "2025-06-15" `shouldBe` Just "4 years"
        it "11.6 4y6m = 4\189 years" $
            age "2021-06-15" "2025-12-15" `shouldBe` Just "4\189 years"
        it "11.7 5 years" $
            age "2020-06-15" "2025-06-15" `shouldBe` Just "5 years"
        it "11.8 5y8m = 5\189 years" $
            age "2020-06-15" "2026-02-15" `shouldBe` Just "5\189 years"
        it "11.9 6 years" $
            age "2019-06-15" "2025-06-15" `shouldBe` Just "6 years"
        it "11.10 6y6m = 6\189 years" $
            age "2019-06-15" "2025-12-15" `shouldBe` Just "6\189 years"
        it "11.11 6y11m = 6\189 years" $
            age "2019-06-15" "2026-05-15" `shouldBe` Just "6\189 years"
        it "11.12 day before 3rd birthday = 2 years, 11 months" $
            age "2022-06-15" "2025-06-14" `shouldBe` Just "2 years, 11 months"

    -- 12. Integer tier (7+ years)
    describe "12. Integer tier" $ do
        it "12.1 7 years" $
            age "2018-06-15" "2025-06-15" `shouldBe` Just "7 years"
        it "12.2 7y3m = 7 years (no half)" $
            age "2018-03-20" "2025-06-15" `shouldBe` Just "7 years"
        it "12.3 45 years" $
            age "1980-01-01" "2025-06-15" `shouldBe` Just "45 years"

    -- 13. Cross-year transitions with February
    describe "13. Cross-year transitions" $ do
        it "13.1 Dec31 -> Mar31 = 3 months" $
            age "2024-12-31" "2025-03-31" `shouldBe` Just "3 months"
        it "13.2 Dec31 -> Mar30 still weeks" $
            shouldContainWeeks (age "2024-12-31" "2025-03-30")
        it "13.3 Nov30 -> Feb28 = 3 months" $
            age "2024-11-30" "2025-02-28" `shouldBe` Just "3 months"
        it "13.4 Nov30 -> Feb27 still weeks" $
            shouldContainWeeks (age "2024-11-30" "2025-02-27")

    -- 14. Born-on-31st progression
    describe "14. Born-on-31st progression" $ do
        it "14.1 Jan31 -> Apr30 = 3 months" $
            age "2025-01-31" "2025-04-30" `shouldBe` Just "3 months"
        it "14.2 Jan31 -> May31 = 4 months" $
            age "2025-01-31" "2025-05-31" `shouldBe` Just "4 months"
        it "14.3 Jan31 -> Jun30 = 5 months" $
            age "2025-01-31" "2025-06-30" `shouldBe` Just "5 months"
        it "14.4 Jan31 -> Jul1 = 5 months" $
            age "2025-01-31" "2025-07-01" `shouldBe` Just "5 months"
        it "14.5 Jan31 -> Jul31 = 6 months" $
            age "2025-01-31" "2025-07-31" `shouldBe` Just "6 months"

    -- 16. formatStage - null / edge cases
    describe "16. formatStage null/edge" $ do
        it "16.1/16.3 empty string" $
            stage "" "2025-06-15" `shouldBe` Nothing
        it "16.4 future DOB" $
            stage "2025-07-01" "2025-06-15" `shouldBe` Nothing
        it "16.5 exactly 500 years" $
            stage "1525-06-15" "2025-06-15" `shouldBe` Just "Adult"
        it "16.6 501 years" $
            stage "1524-06-15" "2025-06-15" `shouldBe` Nothing

    -- 17. formatStage - Newborn (0-1 months)
    describe "17. formatStage - Newborn" $ do
        it "17.1 born today" $
            stage "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "17.2 1 day" $
            stage "2025-06-14" "2025-06-15" `shouldBe` Just "Newborn"
        it "17.3 3 weeks" $
            stage "2025-05-25" "2025-06-15" `shouldBe` Just "Newborn"
        it "17.4 1 month" $
            stage "2025-05-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "17.5 1 month 29 days" $
            stage "2025-04-16" "2025-06-15" `shouldBe` Just "Newborn"
        it "17.6 2 months = Infant" $
            stage "2025-04-15" "2025-06-15" `shouldBe` Just "Infant"

    -- 18. formatStage - Infant (2-11 months)
    describe "18. formatStage - Infant" $ do
        it "18.1 2 months" $
            stage "2025-04-15" "2025-06-15" `shouldBe` Just "Infant"
        it "18.2 6 months" $
            stage "2024-12-15" "2025-06-15" `shouldBe` Just "Infant"
        it "18.3 11 months" $
            stage "2024-07-15" "2025-06-15" `shouldBe` Just "Infant"
        it "18.4 12 months = Toddler" $
            stage "2024-06-15" "2025-06-15" `shouldBe` Just "Toddler"

    -- 19. formatStage - Toddler (12-35 months)
    describe "19. formatStage - Toddler" $ do
        it "19.1 12 months" $
            stage "2024-06-15" "2025-06-15" `shouldBe` Just "Toddler"
        it "19.2 18 months" $
            stage "2024-01-15" "2025-07-15" `shouldBe` Just "Toddler"
        it "19.3 24 months" $
            stage "2023-06-15" "2025-06-15" `shouldBe` Just "Toddler"
        it "19.4 35 months" $
            stage "2023-06-15" "2026-05-15" `shouldBe` Just "Toddler"
        it "19.5 36 months = Child" $
            stage "2022-06-15" "2025-06-15" `shouldBe` Just "Child"

    -- 20. formatStage - Child (36-155 months)
    describe "20. formatStage - Child" $ do
        it "20.1 3 years" $
            stage "2022-06-15" "2025-06-15" `shouldBe` Just "Child"
        it "20.2 4 years" $
            stage "2021-06-15" "2025-06-15" `shouldBe` Just "Child"
        it "20.3 6 years" $
            stage "2019-06-15" "2025-06-15" `shouldBe` Just "Child"
        it "20.4 9 years" $
            stage "2016-06-15" "2025-06-15" `shouldBe` Just "Child"
        it "20.5 12y11m" $
            stage "2013-06-15" "2026-05-15" `shouldBe` Just "Child"
        it "20.6 13 years = Teenager" $
            stage "2012-06-15" "2025-06-15" `shouldBe` Just "Teenager"

    -- 21. formatStage - Teenager (156-215 months)
    describe "21. formatStage - Teenager" $ do
        it "21.1 13 years" $
            stage "2012-06-15" "2025-06-15" `shouldBe` Just "Teenager"
        it "21.2 15 years" $
            stage "2010-06-15" "2025-06-15" `shouldBe` Just "Teenager"
        it "21.3 17y11m" $
            stage "2008-06-15" "2026-05-15" `shouldBe` Just "Teenager"
        it "21.4 18 years = Adult" $
            stage "2007-06-15" "2025-06-15" `shouldBe` Just "Adult"

    -- 22. formatStage - Adult (216+ months)
    describe "22. formatStage - Adult" $ do
        it "22.1 18 years" $
            stage "2007-06-15" "2025-06-15" `shouldBe` Just "Adult"
        it "22.2 25 years" $
            stage "2000-06-15" "2025-06-15" `shouldBe` Just "Adult"
        it "22.3 45 years" $
            stage "1980-01-01" "2025-06-15" `shouldBe` Just "Adult"

    -- 24. Class delegation (English locale)
    describe "24. English locale delegation" $ do
        it "24.1 Newborn" $
            age "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "24.2 3 days" $
            age "2025-06-12" "2025-06-15" `shouldBe` Just "3 days"
        it "24.3 1 week, 1 day" $
            age "2025-06-07" "2025-06-15" `shouldBe` Just "1 week, 1 day"
        it "24.4 6 months" $
            age "2025-01-15" "2025-07-15" `shouldBe` Just "6 months"
        it "24.5 2 years, 1 month" $
            age "2023-06-15" "2025-07-15" `shouldBe` Just "2 years, 1 month"
        it "24.6 3\189 years" $
            age "2022-06-15" "2025-12-15" `shouldBe` Just "3\189 years"
        it "24.7 7 years" $
            age "2018-06-15" "2025-06-15" `shouldBe` Just "7 years"
        it "24.8 stage Newborn" $
            stage "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "24.9 stage Infant" $
            stage "2025-01-15" "2025-06-15" `shouldBe` Just "Infant"
        it "24.10 stage Toddler" $
            stage "2024-06-15" "2025-06-15" `shouldBe` Just "Toddler"
        it "24.11 stage Child" $
            stage "2022-06-15" "2025-06-15" `shouldBe` Just "Child"
        it "24.12 stage Teenager" $
            stage "2012-06-15" "2025-06-15" `shouldBe` Just "Teenager"
        it "24.13 stage Adult" $
            stage "2007-06-15" "2025-06-15" `shouldBe` Just "Adult"
        it "24.14 null formatAge" $
            age "" "2025-06-15" `shouldBe` Nothing
        it "24.15 null formatStage" $
            stage "" "2025-06-15" `shouldBe` Nothing

    -- 25. i18n - Spanish locale
    describe "25. i18n - Spanish" $ do
        let es = Es.locale
        it "25.1 justBorn" $
            ageS es "2025-06-15" "2025-06-15" `shouldBe` Just "Reci\233n nacido"
        it "25.2 singular day" $
            ageS es "2025-06-14" "2025-06-15" `shouldBe` Just "1 d\237a"
        it "25.3 plural days" $
            ageS es "2025-06-12" "2025-06-15" `shouldBe` Just "3 d\237as"
        it "25.4 singular week" $
            ageS es "2025-06-08" "2025-06-15" `shouldBe` Just "1 semana"
        it "25.5 compound" $
            ageS es "2025-06-07" "2025-06-15" `shouldBe` Just "1 semana, 1 d\237a"
        it "25.6 plural compound" $
            ageS es "2025-05-26" "2025-06-15" `shouldBe` Just "2 semanas, 6 d\237as"
        it "25.7 months" $
            ageS es "2025-01-15" "2025-07-15" `shouldBe` Just "6 meses"
        it "25.8 singular month" $
            ageS es "2023-06-15" "2025-07-15" `shouldBe` Just "2 a\241os, 1 mes"
        it "25.9 years+months" $
            ageS es "2023-06-15" "2025-12-15" `shouldBe` Just "2 a\241os, 6 meses"
        it "25.10 half marker" $
            ageS es "2022-06-15" "2025-12-15" `shouldBe` Just "3 a\241os y medio"
        it "25.11 no half" $
            ageS es "2022-06-15" "2025-06-15" `shouldBe` Just "3 a\241os"
        it "25.12 7+ years" $
            ageS es "2018-06-15" "2025-06-15" `shouldBe` Just "7 a\241os"
        it "25.13 stage Newborn" $
            formatStagePure es "2025-06-15" "2025-06-15" Nothing `shouldBe` Just "Reci\233n nacido"
        it "25.14 stage Infant" $
            formatStagePure es "2025-01-15" "2025-06-15" Nothing `shouldBe` Just "Beb\233"
        it "25.15 stage Toddler" $
            formatStagePure es "2024-06-15" "2025-06-15" Nothing `shouldBe` Just "Ni\241o peque\241o"
        it "25.16 stage Child" $
            formatStagePure es "2022-06-15" "2025-06-15" Nothing `shouldBe` Just "Ni\241o"
        it "25.17 stage Teenager" $
            formatStagePure es "2012-06-15" "2025-06-15" Nothing `shouldBe` Just "Adolescente"
        it "25.18 stage Adult" $
            formatStagePure es "2007-06-15" "2025-06-15" Nothing `shouldBe` Just "Adulto"
        it "25.19 null age" $
            ageS es "" "2025-06-15" `shouldBe` Nothing
        it "25.20 null stage" $
            formatStagePure es "" "2025-06-15" Nothing `shouldBe` Nothing

    -- 26. Compactness - short
    describe "26. Compactness - short" $ do
        it "26.1 short days" $
            ageShort "2025-06-12" "2025-06-15" `shouldBe` Just "3 d"
        it "26.2 short week" $
            ageShort "2025-06-08" "2025-06-15" `shouldBe` Just "1 wk"
        it "26.3 short compound" $
            ageShort "2025-06-07" "2025-06-15" `shouldBe` Just "1 wk, 1 d"
        it "26.4 short months" $
            ageShort "2025-01-15" "2025-07-15" `shouldBe` Just "6 mo"
        it "26.5 short years+months" $
            ageShort "2023-06-15" "2025-07-15" `shouldBe` Just "2 yr, 1 mo"
        it "26.6 short half" $
            ageShort "2022-06-15" "2025-12-15" `shouldBe` Just "3\189 yr"
        it "26.7 short years" $
            ageShort "2018-06-15" "2025-06-15" `shouldBe` Just "7 yr"
        it "26.8 justBorn unchanged" $
            ageShort "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"
        it "26.9 stages unchanged" $
            formatStagePure en "2025-01-15" "2025-06-15" Nothing `shouldBe` Just "Infant"

    -- 27. Compactness - compact
    describe "27. Compactness - compact" $ do
        it "27.1 compact days" $
            ageCompact "2025-06-12" "2025-06-15" `shouldBe` Just "3d"
        it "27.2 compact week" $
            ageCompact "2025-06-08" "2025-06-15" `shouldBe` Just "1w"
        it "27.3 no delimiter" $
            ageCompact "2025-06-07" "2025-06-15" `shouldBe` Just "1w1d"
        it "27.4 compact months" $
            ageCompact "2025-01-15" "2025-07-15" `shouldBe` Just "6m"
        it "27.5 no delimiter" $
            ageCompact "2023-06-15" "2025-07-15" `shouldBe` Just "2y1m"
        it "27.6 compact half" $
            ageCompact "2022-06-15" "2025-12-15" `shouldBe` Just "3\189y"
        it "27.7 compact years" $
            ageCompact "2018-06-15" "2025-06-15" `shouldBe` Just "7y"
        it "27.8 justBorn unchanged" $
            ageCompact "2025-06-15" "2025-06-15" `shouldBe` Just "Newborn"

    -- 29.1 Hebrew dual forms
    describe "29.1 Hebrew dual forms" $ do
        let he = He.locale
        it "29.1 justBorn" $
            ageS he "2025-06-15" "2025-06-15" `shouldBe` Just "\1512\1511 \1504\1493\1500\1491"
        it "29.2 1 day" $
            ageS he "2025-06-14" "2025-06-15" `shouldBe` Just "\1497\1493\1501"
        it "29.3 3 days" $
            ageS he "2025-06-12" "2025-06-15" `shouldBe` Just "3 \1497\1502\1497\1501"
        it "29.4 2 weeks dual" $
            ageS he "2025-06-01" "2025-06-15" `shouldBe` Just "\1513\1489\1493\1506\1497\1497\1501"
        it "29.5 3 weeks" $
            ageS he "2025-05-25" "2025-06-15" `shouldBe` Just "3 \1513\1489\1493\1506\1493\1514"
        it "29.6 6 months" $
            ageS he "2025-01-15" "2025-07-15" `shouldBe` Just "6 \1495\1493\1491\1513\1497\1501"
        it "29.7 3 months" $
            ageS he "2025-03-15" "2025-06-15" `shouldBe` Just "3 \1495\1493\1491\1513\1497\1501"
        it "29.8 2y dual + 1m" $
            ageS he "2023-06-15" "2025-07-15" `shouldBe` Just "\1513\1504\1514\1497\1497\1501, \1495\1493\1491\1513"
        it "29.9 3.5 years" $
            ageS he "2022-06-15" "2025-12-15" `shouldBe` Just "3 \1513\1504\1497\1501 \1493\1495\1510\1497"
        it "29.10 7 years" $
            ageS he "2018-06-15" "2025-06-15" `shouldBe` Just "7 \1513\1504\1497\1501"
        it "29.11 masculine newborn" $
            stageG he "2025-06-15" "2025-06-15" (Just M) `shouldBe` Just "\1512\1511 \1504\1493\1500\1491"
        it "29.12 feminine newborn" $
            stageG he "2025-06-15" "2025-06-15" (Just F) `shouldBe` Just "\1512\1511 \1504\1493\1500\1491\1492"
        it "29.13 masculine adult" $
            stageG he "2007-06-15" "2025-06-15" (Just M) `shouldBe` Just "\1502\1489\1493\1490\1512"
        it "29.14 feminine adult" $
            stageG he "2007-06-15" "2025-06-15" (Just F) `shouldBe` Just "\1502\1489\1493\1490\1512\1514"

    -- 29.2 Macedonian mod10/mod100
    describe "29.2 Macedonian" $ do
        let mk = Mk.locale
        it "29.15 justBorn" $
            ageS mk "2025-06-15" "2025-06-15" `shouldBe` Just "\1053\1086\1074\1086\1088\1086\1076\1077\1085\1095\1077"
        it "29.16 1 day" $
            ageS mk "2025-06-14" "2025-06-15" `shouldBe` Just "1 \1076\1077\1085"
        it "29.17 3 days" $
            ageS mk "2025-06-12" "2025-06-15" `shouldBe` Just "3 \1076\1077\1085\1072"
        it "29.18 6 months" $
            ageS mk "2025-01-15" "2025-07-15" `shouldBe` Just "6 \1084\1077\1089\1077\1094\1080"
        it "29.19 2y1m" $
            ageS mk "2023-06-15" "2025-07-15" `shouldBe` Just "2 \1075\1086\1076\1080\1085\1080, 1 \1084\1077\1089\1077\1094"
        it "29.20 3.5 years" $
            ageS mk "2022-06-15" "2025-12-15" `shouldBe` Just "3 \1075\1086\1076\1080\1085\1080 \1080 \1087\1086\1083"
        it "29.21 7 years" $
            ageS mk "2018-06-15" "2025-06-15" `shouldBe` Just "7 \1075\1086\1076\1080\1085\1080"

    -- 29.3 Swahili
    describe "29.3 Swahili" $ do
        let sw = Sw.locale
        it "29.22 justBorn" $
            ageS sw "2025-06-15" "2025-06-15" `shouldBe` Just "Mzaliwa mpya"
        it "29.23 1 day" $
            ageS sw "2025-06-14" "2025-06-15" `shouldBe` Just "siku 1"
        it "29.24 3 days" $
            ageS sw "2025-06-12" "2025-06-15" `shouldBe` Just "siku 3"
        it "29.25 6 months" $
            ageS sw "2025-01-15" "2025-07-15" `shouldBe` Just "miezi 6"
        it "29.26 2y + 1m" $
            ageS sw "2023-06-15" "2025-07-15" `shouldBe` Just "miaka 2, mwezi 1"
        it "29.27 3.5 years" $
            ageS sw "2022-06-15" "2025-12-15" `shouldBe` Just "miaka 3 na nusu"

    -- 29.4 Indonesian
    describe "29.4 Indonesian" $ do
        let id' = Id.locale
        it "29.28 justBorn" $
            ageS id' "2025-06-15" "2025-06-15" `shouldBe` Just "Baru lahir"
        it "29.29 1 day" $
            ageS id' "2025-06-14" "2025-06-15" `shouldBe` Just "1 hari"
        it "29.30 3 days" $
            ageS id' "2025-06-12" "2025-06-15" `shouldBe` Just "3 hari"
        it "29.31 6 months" $
            ageS id' "2025-01-15" "2025-07-15" `shouldBe` Just "6 bulan"
        it "29.32 3.5 years" $
            ageS id' "2022-06-15" "2025-12-15" `shouldBe` Just "3 setengah tahun"
        it "29.33 7 years" $
            ageS id' "2018-06-15" "2025-06-15" `shouldBe` Just "7 tahun"

    -- 29.5 Amharic
    describe "29.5 Amharic" $ do
        let am = Am.locale
        it "29.34 justBorn" $
            ageS am "2025-06-15" "2025-06-15" `shouldBe` Just "\4768\4850\4661 \4840\4720\4808\4616\4848"
        it "29.35 1 day" $
            ageS am "2025-06-14" "2025-06-15" `shouldBe` Just "1 \4672\4757"
        it "29.36 3 days" $
            ageS am "2025-06-12" "2025-06-15" `shouldBe` Just "3 \4672\4755\4725"
        it "29.37 1w1d ethiopic delimiter" $
            ageS am "2025-06-07" "2025-06-15" `shouldBe` Just "1 \4659\4637\4757\4725\4963 1 \4672\4757"
        it "29.38 6 months" $
            ageS am "2025-01-15" "2025-07-15" `shouldBe` Just "6 \4808\4651\4725"
        it "29.39 3.5 years" $
            ageS am "2022-06-15" "2025-12-15" `shouldBe` Just "3 \4819\4632\4723\4725 \4720\4777\4621"

    -- 30. Locale lookup
    describe "30. Locale lookup" $ do
        it "30.1 known locale en" $
            fmap localeCode (getLocale "en") `shouldBe` Just "en"
        it "30.2 known locale fr" $
            fmap localeCode (getLocale "fr") `shouldBe` Just "fr"
        it "30.3 unknown code" $
            getLocale "xx" `shouldSatisfy` isNothing
        it "30.4 empty string" $
            getLocale "" `shouldSatisfy` isNothing
        it "30.5 case-sensitive" $
            getLocale "EN" `shouldSatisfy` isNothing

    -- Section 31: Weeks and days across month ends
    describe "31. Weeks and days across month ends" $ do
        -- 31.1
        it "31.1 88 days across a 28-day February" $
            withLocale "en" (\l -> formatAgePure l Normal "2016-12-31" "2017-03-29") `shouldBe` Just "12 weeks, 4 days"
        -- 31.2
        it "31.2 90 days across a year end into a leap year" $
            withLocale "en" (\l -> formatAgePure l Normal "1991-11-27" "1992-02-25") `shouldBe` Just "12 weeks, 6 days"
        -- 31.3
        it "31.3 33 days across a year end" $
            withLocale "en" (\l -> formatAgePure l Normal "2020-11-30" "2021-01-02") `shouldBe` Just "4 weeks, 5 days"
        -- 31.4
        it "31.4 Compact form of 31.1" $
            withLocale "en" (\l -> formatAgePure l Compact "2016-12-31" "2017-03-29") `shouldBe` Just "12w4d"

    -- Section 32: Half years take their plural form from whole years
    describe "32. Half years take their plural form from whole years" $ do
        -- 32.1
        it "32.1 Polish 3 is 'few'" $
            withLocale "pl" (\l -> formatAgePure l Normal "2021-06-15" "2025-01-15") `shouldBe` Just "3 i p\243\322 lata"
        -- 32.2
        it "32.2 Polish 5 is 'many'" $
            withLocale "pl" (\l -> formatAgePure l Short "2020-06-15" "2025-12-15") `shouldBe` Just "5 i p\243\322 lat"
        -- 32.3
        it "32.3 Tachelhit 6 is 'few'" $
            withLocale "shi" (\l -> formatAgePure l Normal "2005-06-08" "2012-06-07") `shouldBe` Just "6 iseggasen d uzgen"

    -- Section 33: Input validation
    describe "33. Input validation" $ do
        -- 33.1
        it "33.1 February 30 doesn't exist" $
            withLocale "en" (\l -> formatAgePure l Normal "2025-02-30" "2032-06-25") `shouldBe` Nothing
        -- 33.2
        it "33.2 Month 13" $
            withLocale "en" (\l -> formatAgePure l Normal "2025-13-01" "2027-01-31") `shouldBe` Nothing
        -- 33.3
        it "33.3 February 29 in a non-leap year" $
            withLocale "en" (\l -> formatAgePure l Normal "2023-02-29" "2025-03-01") `shouldBe` Nothing
        -- 33.4
        it "33.4 Day 00" $
            withLocale "en" (\l -> formatAgePure l Normal "2025-06-00" "2027-02-25") `shouldBe` Nothing
        -- 33.5
        it "33.5 Unpadded month and day" $
            withLocale "en" (\l -> formatAgePure l Normal "2025-6-1" "2027-02-25") `shouldBe` Nothing
        -- 33.6
        it "33.6 Surrounding whitespace" $
            withLocale "en" (\l -> formatAgePure l Normal " 2025-06-01" "2027-02-25") `shouldBe` Nothing
        -- 33.7
        it "33.7 A datetime is not a date" $
            withLocale "en" (\l -> formatAgePure l Normal "2025-06-15T10:00:00" "2027-02-25") `shouldBe` Nothing
        -- 33.8
        it "33.8 Invalid asOf" $
            withLocale "en" (\l -> formatAgePure l Normal "2020-01-01" "2025-04-31") `shouldBe` Nothing
        -- 33.9
        it "33.9 formatStage validates too" $
            withLocale "en" (\l -> formatStagePure l "2025-02-30" "2027-09-05" Nothing) `shouldBe` Nothing
        -- 33.10
        it "33.10 February 29 in a leap year is valid" $
            withLocale "en" (\l -> formatAgePure l Normal "2024-02-29" "2026-03-01") `shouldBe` Just "2 years"
