#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Testing
@testable import SayableAge

@Suite(.serialized) struct FormatAgeTests {

    init() {
        SayableAgeFormatter._timeNow = {
            var rawTime = time(nil)
            let timeInfo = localtime(&rawTime).pointee
            return (Int(timeInfo.tm_year) + 1900, Int(timeInfo.tm_mon) + 1, Int(timeInfo.tm_mday))
        }
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.3
    @Test func emptyStringReturnsNil() {
        #expect(SayableAgeFormatter.formatAgeDefault("", "2025-06-15") == nil)
    }

    // 1.4
    @Test func futureDobReturnsNil() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-07-01", "2025-06-15") == nil)
    }

    // 1.5
    @Test func exactly500YearsIsAllowed() {
        #expect(SayableAgeFormatter.formatAgeDefault("1525-06-15", "2025-06-15") == "500 years")
    }

    // 1.6
    @Test func years501ExceedsMaxAge() {
        #expect(SayableAgeFormatter.formatAgeDefault("1524-06-15", "2025-06-15") == nil)
    }

    // 1.7
    @Test func years1000ExceedsMaxAge() {
        #expect(SayableAgeFormatter.formatAgeDefault("1025-06-15", "2025-06-15") == nil)
    }

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test func bornToday() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 2.2
    @Test func oneDayAgo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-14", "2025-06-15") == "1 day")
    }

    // 2.3
    @Test func threeDaysAgo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-12", "2025-06-15") == "3 days")
    }

    // 2.4
    @Test func sixDaysAgo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-09", "2025-06-15") == "6 days")
    }

    // 2.5
    @Test func sevenDaysBecomesOneWeek() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-08", "2025-06-15") == "1 week")
    }

    // ================================================================
    // formatAge -- weeks+days tier
    // ================================================================
    // 3.1
    @Test func sevenDaysIsOneWeek() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-08", "2025-06-15") == "1 week")
    }

    // 3.2
    @Test func eightDaysIsOneWeekOneDay() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-07", "2025-06-15") == "1 week, 1 day")
    }

    // 3.3
    @Test func nineDaysIsOneWeekTwoDays() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-06", "2025-06-15") == "1 week, 2 days")
    }

    // 3.4
    @Test func thirteenDaysIsOneWeekSixDays() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-02", "2025-06-15") == "1 week, 6 days")
    }

    // 3.5
    @Test func fourteenDaysIsTwoWeeks() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-01", "2025-06-15") == "2 weeks")
    }

    // 3.6
    @Test func fifteenDaysIsTwoWeeksOneDay() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-05-31", "2025-06-15") == "2 weeks, 1 day")
    }

    // 3.7
    @Test func twentyDaysIsTwoWeeksSixDays() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-05-26", "2025-06-15") == "2 weeks, 6 days")
    }

    // 3.8
    @Test func twentyOneDaysIsThreeWeeks() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-05-25", "2025-06-15") == "3 weeks")
    }

    // 3.9
    @Test func atOneCalMonthStillWeeksDays() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-05-15", "2025-06-15") == "4 weeks, 3 days")
    }

    // 3.10
    @Test func atTwoCalMonthsStillWeeksDays() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-04-15", "2025-06-15") == "8 weeks, 5 days")
    }

    // 3.11
    @Test func oneDayBefore3moStillWeeks() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-03-15", "2025-06-14") == "13 weeks")
    }

    // 3.12
    @Test func on3moBirthdaySwitches() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-03-15", "2025-06-15") == "3 months")
    }

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test func jan1ToApr1Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-01", "2025-04-01") == "3 months")
    }

    // 4.2
    @Test func jan1ToMar31StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-01-01", "2025-03-31")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 4.3
    @Test func jun15ToSep15Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-15", "2025-09-15") == "3 months")
    }

    // 4.4
    @Test func jun15ToSep14StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-06-15", "2025-09-14")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 4.5
    @Test func jun15ToDec15Is6mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-15", "2025-12-15") == "6 months")
    }

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test func jan31ToFeb28NonLeap() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-02-28") == "4 weeks")
    }

    // 5.2
    @Test func jan31ToApr30Is3moClamp() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-04-30") == "3 months")
    }

    // 5.3
    @Test func jan31ToApr29StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-04-29")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 5.4
    @Test func feb1ToMay1Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-02-01", "2025-05-01") == "3 months")
    }

    // 5.5
    @Test func feb1ToApr30StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-02-01", "2025-04-30")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test func jan31ToFeb29Leap() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-01-31", "2024-02-29") == "4 weeks, 1 day")
    }

    // 6.2
    @Test func jan31ToFeb28Leap() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-01-31", "2024-02-28") == "4 weeks")
    }

    // 6.3
    @Test func jan31ToApr30LeapIs3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-01-31", "2024-04-30") == "3 months")
    }

    // 6.4
    @Test func jan30ToFeb29LeapStillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2024-01-30", "2024-02-29")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 6.5
    @Test func jan30ToFeb28LeapStillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2024-01-30", "2024-02-28")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test func mar31ToJun30Is3moClamped() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-03-31", "2025-06-30") == "3 months")
    }

    // 7.2
    @Test func mar31ToJun29StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-03-31", "2025-06-29")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 7.3
    @Test func aug31ToNov30Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-08-31", "2025-11-30") == "3 months")
    }

    // 7.4
    @Test func aug31ToNov29StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2025-08-31", "2025-11-29")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test func feb29ToMay29Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-02-29", "2024-05-29") == "3 months")
    }

    // 8.2
    @Test func feb29ToMay28StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2024-02-29", "2024-05-28")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 8.3
    @Test func feb29_2024ToFeb28_2025Is12mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-02-29", "2025-02-28") == "12 months")
    }

    // 8.4
    @Test func feb29_2024ToMar1_2025Is12mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-02-29", "2025-03-01") == "12 months")
    }

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test func threeMonthsAtTransition() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-15", "2025-04-15") == "3 months")
    }

    // 9.2
    @Test func sixMonths() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-15", "2025-07-15") == "6 months")
    }

    // 9.3
    @Test func twelveMonthsNotOneYear() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-06-15", "2025-06-15") == "12 months")
    }

    // 9.4
    @Test func twentyThreeMonthsAtUpper() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-01-15", "2025-12-15") == "23 months")
    }

    // 9.5
    @Test func oneDayBeforeBoundary() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-15", "2025-07-14") == "5 months")
    }

    // 9.6
    @Test func crossingYearBoundary() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-11-10", "2025-04-10") == "5 months")
    }

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test func twoYearsAt24mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2023-06-15", "2025-06-15") == "2 years")
    }

    // 10.2
    @Test func twoYearsOneMonth() {
        #expect(SayableAgeFormatter.formatAgeDefault("2023-06-15", "2025-07-15") == "2 years, 1 month")
    }

    // 10.3
    @Test func twoYearsSixMonths() {
        #expect(SayableAgeFormatter.formatAgeDefault("2023-06-15", "2025-12-15") == "2 years, 6 months")
    }

    // 10.4
    @Test func twoYearsElevenMonths() {
        #expect(SayableAgeFormatter.formatAgeDefault("2023-06-15", "2026-05-15") == "2 years, 11 months")
    }

    // 10.5
    @Test func oneDayBefore24mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2023-06-15", "2025-06-14") == "23 months")
    }

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test func threeYearsExactly() {
        #expect(SayableAgeFormatter.formatAgeDefault("2022-06-15", "2025-06-15") == "3 years")
    }

    // 11.2
    @Test func threeYearsFiveMonths() {
        #expect(SayableAgeFormatter.formatAgeDefault("2022-06-15", "2025-11-15") == "3 years")
    }

    // 11.3
    @Test func threeAndHalfYearsAt3y6m() {
        #expect(SayableAgeFormatter.formatAgeDefault("2022-06-15", "2025-12-15") == "3\u{00BD} years")
    }

    // 11.4
    @Test func threeAndHalfYearsAt3y11m() {
        #expect(SayableAgeFormatter.formatAgeDefault("2022-06-15", "2026-05-15") == "3\u{00BD} years")
    }

    // 11.5
    @Test func fourYearsExactly() {
        #expect(SayableAgeFormatter.formatAgeDefault("2021-06-15", "2025-06-15") == "4 years")
    }

    // 11.6
    @Test func fourAndHalfYears() {
        #expect(SayableAgeFormatter.formatAgeDefault("2021-06-15", "2025-12-15") == "4\u{00BD} years")
    }

    // 11.7
    @Test func fiveYears() {
        #expect(SayableAgeFormatter.formatAgeDefault("2020-06-15", "2025-06-15") == "5 years")
    }

    // 11.8
    @Test func fiveAndHalfYearsAt5y8m() {
        #expect(SayableAgeFormatter.formatAgeDefault("2020-06-15", "2026-02-15") == "5\u{00BD} years")
    }

    // 11.9
    @Test func sixYears() {
        #expect(SayableAgeFormatter.formatAgeDefault("2019-06-15", "2025-06-15") == "6 years")
    }

    // 11.10
    @Test func sixAndHalfYears() {
        #expect(SayableAgeFormatter.formatAgeDefault("2019-06-15", "2025-12-15") == "6\u{00BD} years")
    }

    // 11.11
    @Test func sixAndHalfYearsAt6y11m() {
        #expect(SayableAgeFormatter.formatAgeDefault("2019-06-15", "2026-05-15") == "6\u{00BD} years")
    }

    // 11.12
    @Test func oneDayBefore3rdBday() {
        #expect(SayableAgeFormatter.formatAgeDefault("2022-06-15", "2025-06-14") == "2 years, 11 months")
    }

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test func sevenYearsExactly() {
        #expect(SayableAgeFormatter.formatAgeDefault("2018-06-15", "2025-06-15") == "7 years")
    }

    // 12.2
    @Test func sevenYearsSixMonthsNoHalf() {
        #expect(SayableAgeFormatter.formatAgeDefault("2018-03-20", "2025-06-15") == "7 years")
    }

    // 12.3
    @Test func fortyFiveYears() {
        #expect(SayableAgeFormatter.formatAgeDefault("1980-01-01", "2025-06-15") == "45 years")
    }

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test func dec31ToMar31Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-12-31", "2025-03-31") == "3 months")
    }

    // 13.2
    @Test func dec31ToMar30StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2024-12-31", "2025-03-30")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // 13.3
    @Test func nov30ToFeb28Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2024-11-30", "2025-02-28") == "3 months")
    }

    // 13.4
    @Test func nov30ToFeb27StillWeeks() {
        let result = SayableAgeFormatter.formatAgeDefault("2024-11-30", "2025-02-27")
        #expect(result != nil)
        #expect(result!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test func jan31ToApr30Is3mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-04-30") == "3 months")
    }

    // 14.2
    @Test func jan31ToMay31Is4mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-05-31") == "4 months")
    }

    // 14.3
    @Test func jan31ToJun30Is5moClamped() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-06-30") == "5 months")
    }

    // 14.4
    @Test func jan31ToJul1Is5mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-07-01") == "5 months")
    }

    // 14.5
    @Test func jan31ToJul31Is6mo() {
        #expect(SayableAgeFormatter.formatAgeDefault("2025-01-31", "2025-07-31") == "6 months")
    }

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test func defaultAsOfUsesMockedToday() {
        SayableAgeFormatter._timeNow = { (2025, 6, 15) }
        #expect(SayableAgeFormatter.formatAgeDefault("2020-01-01") == "5 years") // 15.1
        #expect(SayableAgeFormatter.formatAgeDefault("2025-06-10") == "5 days") // 15.2
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    @Test func stageEmptyStringReturnsNil() {
        #expect(SayableAgeFormatter.formatStageDefault("", "2025-06-15") == nil)
    }

    @Test func stageFutureDobReturnsNil() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-07-01", "2025-06-15") == nil)
    }

    @Test func stageExactly500YearsReturnsAdult() {
        #expect(SayableAgeFormatter.formatStageDefault("1525-06-15", "2025-06-15") == "Adult")
    }

    @Test func stage501YearsExceedsMaxAge() {
        #expect(SayableAgeFormatter.formatStageDefault("1524-06-15", "2025-06-15") == nil)
    }

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    @Test func stageBornToday() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-06-15", "2025-06-15") == "Newborn")
    }

    @Test func stageOneDayOld() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-06-14", "2025-06-15") == "Newborn")
    }

    @Test func stageThreeWeeksOld() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-05-25", "2025-06-15") == "Newborn")
    }

    @Test func stageOneMonthOld() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-05-15", "2025-06-15") == "Newborn")
    }

    @Test func stageOneMonth29Days() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-04-16", "2025-06-15") == "Newborn")
    }

    @Test func stageExactly2MonthsBecomesInfant() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-04-15", "2025-06-15") == "Infant")
    }

    // ================================================================
    // formatStage -- infant through adult
    // ================================================================
    @Test func stageTwoMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-04-15", "2025-06-15") == "Infant")
    }

    @Test func stageSixMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2024-12-15", "2025-06-15") == "Infant")
    }

    @Test func stageElevenMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2024-07-15", "2025-06-15") == "Infant")
    }

    @Test func stageExactly12moBecomesToddler() {
        #expect(SayableAgeFormatter.formatStageDefault("2024-06-15", "2025-06-15") == "Toddler")
    }

    @Test func stageTwelveMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2024-06-15", "2025-06-15") == "Toddler")
    }

    @Test func stageEighteenMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2024-01-15", "2025-07-15") == "Toddler")
    }

    @Test func stageTwentyFourMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2023-06-15", "2025-06-15") == "Toddler")
    }

    @Test func stageThirtyFiveMonths() {
        #expect(SayableAgeFormatter.formatStageDefault("2023-06-15", "2026-05-15") == "Toddler")
    }

    @Test func stageExactly36moBecomesChild() {
        #expect(SayableAgeFormatter.formatStageDefault("2022-06-15", "2025-06-15") == "Child")
    }

    @Test func stageThreeYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2022-06-15", "2025-06-15") == "Child")
    }

    @Test func stageFourYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2021-06-15", "2025-06-15") == "Child")
    }

    @Test func stageSixYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2019-06-15", "2025-06-15") == "Child")
    }

    @Test func stageNineYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2016-06-15", "2025-06-15") == "Child")
    }

    @Test func stage12y11mo() {
        #expect(SayableAgeFormatter.formatStageDefault("2013-06-15", "2026-05-15") == "Child")
    }

    @Test func stageExactly13yBecomesTeenager() {
        #expect(SayableAgeFormatter.formatStageDefault("2012-06-15", "2025-06-15") == "Teenager")
    }

    @Test func stageThirteenYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2012-06-15", "2025-06-15") == "Teenager")
    }

    @Test func stageFifteenYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2010-06-15", "2025-06-15") == "Teenager")
    }

    @Test func stage17y11mo() {
        #expect(SayableAgeFormatter.formatStageDefault("2008-06-15", "2026-05-15") == "Teenager")
    }

    @Test func stageExactly18yBecomesAdult() {
        #expect(SayableAgeFormatter.formatStageDefault("2007-06-15", "2025-06-15") == "Adult")
    }

    @Test func stageEighteenYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2007-06-15", "2025-06-15") == "Adult")
    }

    @Test func stageTwentyFiveYears() {
        #expect(SayableAgeFormatter.formatStageDefault("2000-06-15", "2025-06-15") == "Adult")
    }

    @Test func stageFortyFiveYears() {
        #expect(SayableAgeFormatter.formatStageDefault("1980-01-01", "2025-06-15") == "Adult")
    }

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    @Test func stageDefaultAsOf() {
        SayableAgeFormatter._timeNow = { (2025, 6, 15) }
        #expect(SayableAgeFormatter.formatStageDefault("2025-06-15") == "Newborn")
        #expect(SayableAgeFormatter.formatStageDefault("2020-01-01") == "Child")
        #expect(SayableAgeFormatter.formatStageDefault("1980-01-01") == "Adult")
    }

    // ================================================================
    // SayableAgeFormatter with English locale
    // ================================================================
    @Test func parentTimeEnglishAllTiers() {
        let pt = SayableAgeFormatter(Locales.EN)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Newborn")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 days")
        #expect(pt.formatAge("2025-06-07", "2025-06-15") == "1 week, 1 day")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6 months")
        #expect(pt.formatAge("2023-06-15", "2025-07-15") == "2 years, 1 month")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3\u{00BD} years")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 years")

        #expect(pt.formatStage("2025-06-15", "2025-06-15") == "Newborn")
        #expect(pt.formatStage("2025-01-15", "2025-06-15") == "Infant")
        #expect(pt.formatStage("2024-06-15", "2025-06-15") == "Toddler")
        #expect(pt.formatStage("2022-06-15", "2025-06-15") == "Child")
        #expect(pt.formatStage("2012-06-15", "2025-06-15") == "Teenager")
        #expect(pt.formatStage("2007-06-15", "2025-06-15") == "Adult")

        #expect(pt.formatAge("") == nil)
        #expect(pt.formatStage("") == nil)
    }

    // ================================================================
    // SayableAgeFormatter with Spanish locale
    // ================================================================
    @Test func parentTimeSpanishInlineLocale() {
        let es = AgeLocale(
            code: "es",
            plural: { $0 == 1 ? .one : .other },
            units: Units(
                day: .plural([.one: "{n} d\u{00ED}a", .other: "{n} d\u{00ED}as"]),
                week: .plural([.one: "{n} semana", .other: "{n} semanas"]),
                month: .plural([.one: "{n} mes", .other: "{n} meses"]),
                year: .plural([.one: "{n} a\u{00F1}o", .other: "{n} a\u{00F1}os"])
            ),
            half: "{n} y medio",
            delimiter: ", ",
            justBorn: "Reci\u{00E9}n nacido",
            stages: Stages(
                newborn: .gendered(m: "Reci\u{00E9}n nacido", f: "Reci\u{00E9}n nacida"),
                infant: .neutral("Beb\u{00E9}"),
                toddler: .gendered(m: "Ni\u{00F1}o peque\u{00F1}o", f: "Ni\u{00F1}a peque\u{00F1}a"),
                child: .gendered(m: "Ni\u{00F1}o", f: "Ni\u{00F1}a"),
                teenager: .neutral("Adolescente"),
                adult: .gendered(m: "Adulto", f: "Adulta")
            )
        )

        let pt = SayableAgeFormatter(es)

        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Reci\u{00E9}n nacido")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "1 d\u{00ED}a")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 d\u{00ED}as")
        #expect(pt.formatAge("2025-06-08", "2025-06-15") == "1 semana")
        #expect(pt.formatAge("2025-06-07", "2025-06-15") == "1 semana, 1 d\u{00ED}a")
        #expect(pt.formatAge("2025-05-26", "2025-06-15") == "2 semanas, 6 d\u{00ED}as")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6 meses")
        #expect(pt.formatAge("2023-06-15", "2025-07-15") == "2 a\u{00F1}os, 1 mes")
        #expect(pt.formatAge("2023-06-15", "2025-12-15") == "2 a\u{00F1}os, 6 meses")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3 y medio a\u{00F1}os")
        #expect(pt.formatAge("2022-06-15", "2025-06-15") == "3 a\u{00F1}os")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 a\u{00F1}os")

        #expect(pt.formatStage("2025-06-15", "2025-06-15") == "Reci\u{00E9}n nacido")
        #expect(pt.formatStage("2025-01-15", "2025-06-15") == "Beb\u{00E9}")
        #expect(pt.formatStage("2024-06-15", "2025-06-15") == "Ni\u{00F1}o peque\u{00F1}o")
        #expect(pt.formatStage("2022-06-15", "2025-06-15") == "Ni\u{00F1}o")
        #expect(pt.formatStage("2012-06-15", "2025-06-15") == "Adolescente")
        #expect(pt.formatStage("2007-06-15", "2025-06-15") == "Adulto")

        #expect(pt.formatAge("") == nil)
        #expect(pt.formatStage("") == nil)
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    @Test func compactShort() {
        let pt = SayableAgeFormatter(Locales.EN, compactness: .short)

        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 d")
        #expect(pt.formatAge("2025-06-08", "2025-06-15") == "1 wk")
        #expect(pt.formatAge("2025-06-07", "2025-06-15") == "1 wk, 1 d")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6 mo")
        #expect(pt.formatAge("2023-06-15", "2025-07-15") == "2 yr, 1 mo")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3\u{00BD} yr")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 yr")
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Newborn")
        #expect(pt.formatStage("2025-01-15", "2025-06-15") == "Infant")
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    @Test func compactCompact() {
        let pt = SayableAgeFormatter(Locales.EN, compactness: .compact)

        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3d")
        #expect(pt.formatAge("2025-06-08", "2025-06-15") == "1w")
        #expect(pt.formatAge("2025-06-07", "2025-06-15") == "1w1d")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6m")
        #expect(pt.formatAge("2023-06-15", "2025-07-15") == "2y1m")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3\u{00BD}y")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7y")
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Newborn")
    }

    // ================================================================
    // All 168 locales exist
    // ================================================================
    @Test func all168LocalesExist() {
        #expect(Locales.all.count == 168)
        let expectedCodes = [
            "af", "ak", "am", "ar", "ay", "az", "bci", "be", "bem", "bg",
            "bi", "bm", "bn", "br", "bs", "ca", "cak", "ceb", "cs", "cy",
            "da", "de", "din", "dje", "dv", "dyu", "dz", "ee", "el", "en",
            "es", "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon",
            "fr", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi",
            "hmn", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "ja",
            "jv", "ka", "kbp", "kek", "ki", "kk", "kl", "km", "kn", "ko",
            "kpe", "kri", "ktu", "ku", "kw", "ky", "lb", "lg", "ln", "lo",
            "lt", "luo", "lv", "mam", "men", "mfe", "mg", "mi", "mk", "ml",
            "mn", "mnk", "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne",
            "ng", "nl", "nr", "nso", "nus", "ny", "om", "or", "pa", "pis",
            "pl", "pov", "ps", "pt", "qu", "quc", "ro", "ru", "rw", "sar",
            "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so",
            "sq", "sr", "ss", "st", "su", "suk", "sv", "sw", "ta", "te",
            "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr",
            "ts", "tum", "tzm", "uk", "umb", "ur", "uz", "ve", "vi", "vmw",
            "wo", "xh", "yao", "yo", "yue", "zdj", "zh", "zu"
        ]
        for code in expectedCodes {
            #expect(Locales.all[code] != nil, "Locale \(code) should exist")
            #expect(Locales.all[code]!.code == code)
        }
    }

    // ================================================================
    // Smoke test each locale
    // ================================================================
    @Test func allLocalesProduceOutputForBasicCases() {
        for (code, locale) in Locales.all {
            let pt = SayableAgeFormatter(locale)

            let justBorn = pt.formatAge("2025-06-15", "2025-06-15")
            #expect(justBorn != nil, "Locale \(code): justBorn should not be nil")
            #expect(!justBorn!.isEmpty, "Locale \(code): justBorn should not be empty")

            #expect(pt.formatAge("2025-06-12", "2025-06-15") != nil, "Locale \(code): days")
            #expect(pt.formatAge("2025-06-07", "2025-06-15") != nil, "Locale \(code): weeks")
            #expect(pt.formatAge("2025-01-15", "2025-07-15") != nil, "Locale \(code): months")
            #expect(pt.formatAge("2023-06-15", "2025-07-15") != nil, "Locale \(code): years+months")
            #expect(pt.formatAge("2022-06-15", "2025-12-15") != nil, "Locale \(code): half-year")
            #expect(pt.formatAge("2018-06-15", "2025-06-15") != nil, "Locale \(code): integer years")
            #expect(pt.formatStage("2020-01-01", "2025-06-15") != nil, "Locale \(code): stage")
        }
    }

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    @Test func genderNullDefaultsToMasculine() {
        let pt = SayableAgeFormatter(Locales.ES)
        #expect(pt.formatStage("2025-06-15", "2025-06-15") == "Reci\u{00E9}n nacido")
        #expect(pt.formatStage("2024-06-15", "2025-06-15") == "Ni\u{00F1}o peque\u{00F1}o")
        #expect(pt.formatStage("2022-06-15", "2025-06-15") == "Ni\u{00F1}o")
        #expect(pt.formatStage("2007-06-15", "2025-06-15") == "Adulto")
    }

    @Test func genderMReturnsMasculine() {
        let pt = SayableAgeFormatter(Locales.ES)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "Reci\u{00E9}n nacido")
        #expect(pt.formatStage("2024-06-15", "2025-06-15", gender: "m") == "Ni\u{00F1}o peque\u{00F1}o")
        #expect(pt.formatStage("2022-06-15", "2025-06-15", gender: "m") == "Ni\u{00F1}o")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "Adulto")
    }

    @Test func genderFReturnsFeminine() {
        let pt = SayableAgeFormatter(Locales.ES)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "Reci\u{00E9}n nacida")
        #expect(pt.formatStage("2024-06-15", "2025-06-15", gender: "f") == "Ni\u{00F1}a peque\u{00F1}a")
        #expect(pt.formatStage("2022-06-15", "2025-06-15", gender: "f") == "Ni\u{00F1}a")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "Adulta")
    }

    @Test func genderNeutralStagesUnaffected() {
        let pt = SayableAgeFormatter(Locales.ES)
        #expect(pt.formatStage("2025-01-15", "2025-06-15", gender: "f") == "Beb\u{00E9}")
        #expect(pt.formatStage("2025-01-15", "2025-06-15", gender: "m") == "Beb\u{00E9}")
        #expect(pt.formatStage("2012-06-15", "2025-06-15", gender: "f") == "Adolescente")
        #expect(pt.formatStage("2012-06-15", "2025-06-15", gender: "m") == "Adolescente")
    }

    @Test func genderHasNoEffectOnNeutralLocales() {
        let pt = SayableAgeFormatter(Locales.EN)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "Newborn")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "Newborn")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "Adult")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "Adult")
    }

    @Test func genderFrenchStages() {
        let pt = SayableAgeFormatter(Locales.FR)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "Nouveau-n\u{00E9}")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "Nouveau-n\u{00E9}e")
        #expect(pt.formatStage("2025-01-15", "2025-06-15", gender: "f") == "Nourrisson")
        #expect(pt.formatStage("2024-06-15", "2025-06-15", gender: "f") == "Tout-petit")
        #expect(pt.formatStage("2022-06-15", "2025-06-15", gender: "f") == "Enfant")
        #expect(pt.formatStage("2012-06-15", "2025-06-15", gender: "m") == "Adolescent")
        #expect(pt.formatStage("2012-06-15", "2025-06-15", gender: "f") == "Adolescente")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "Adulte")
    }

    @Test func genderItalianStages() {
        let pt = SayableAgeFormatter(Locales.IT)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "Neonato")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "Neonata")
        #expect(pt.formatStage("2024-06-15", "2025-06-15", gender: "m") == "Bimbo")
        #expect(pt.formatStage("2024-06-15", "2025-06-15", gender: "f") == "Bimba")
        #expect(pt.formatStage("2022-06-15", "2025-06-15", gender: "m") == "Bambino")
        #expect(pt.formatStage("2022-06-15", "2025-06-15", gender: "f") == "Bambina")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "Adulto")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "Adulta")
    }

    @Test func genderArabicAllStages() {
        let pt = SayableAgeFormatter(Locales.AR)
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "\u{062D}\u{062F}\u{064A}\u{062B} \u{0627}\u{0644}\u{0648}\u{0644}\u{0627}\u{062F}\u{0629}")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "\u{062D}\u{062F}\u{064A}\u{062B}\u{0629} \u{0627}\u{0644}\u{0648}\u{0644}\u{0627}\u{062F}\u{0629}")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "\u{0628}\u{0627}\u{0644}\u{063A}")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "\u{0628}\u{0627}\u{0644}\u{063A}\u{0629}")
    }

    @Test func genderGermanAdultOnly() {
        let pt = SayableAgeFormatter(Locales.DE)
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "Erwachsener")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "Erwachsene")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "Neugeborenes")
    }

    @Test func genderCompanionMethod() {
        #expect(SayableAgeFormatter.formatStageDefault("2025-06-15", "2025-06-15", gender: "f") == "Newborn")
        #expect(SayableAgeFormatter.formatStageDefault("2007-06-15", "2025-06-15", gender: "f") == "Adult")
    }

    // ================================================================
    // Locale-specific edge cases
    // ================================================================
    @Test func hebrewLocaleDualForms() {
        let pt = SayableAgeFormatter(Locales.HE)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "\u{05D9}\u{05D5}\u{05DD} 1")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 \u{05D9}\u{05DE}\u{05D9}\u{05DD}")
        #expect(pt.formatAge("2025-06-01", "2025-06-15") == "\u{05E9}\u{05D1}\u{05D5}\u{05E2}\u{05D9}\u{05D9}\u{05DD}")
        #expect(pt.formatAge("2025-05-25", "2025-06-15") == "3 \u{05E9}\u{05D1}\u{05D5}\u{05E2}\u{05D5}\u{05EA}")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 \u{05E9}\u{05E0}\u{05D9}\u{05DD}")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "m") == "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}")
        #expect(pt.formatStage("2025-06-15", "2025-06-15", gender: "f") == "\u{05E8}\u{05E7} \u{05E0}\u{05D5}\u{05DC}\u{05D3}\u{05D4}")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "m") == "\u{05DE}\u{05D1}\u{05D5}\u{05D2}\u{05E8}")
        #expect(pt.formatStage("2007-06-15", "2025-06-15", gender: "f") == "\u{05DE}\u{05D1}\u{05D5}\u{05D2}\u{05E8}\u{05EA}")
    }

    @Test func macedonianLocaleMod10Mod100Rule() {
        let pt = SayableAgeFormatter(Locales.MK)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "\u{041D}\u{043E}\u{0432}\u{043E}\u{0440}\u{043E}\u{0434}\u{0435}\u{043D}\u{0447}\u{0435}")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "1 \u{0434}\u{0435}\u{043D}")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 \u{0434}\u{0435}\u{043D}\u{0430}")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 \u{0433}\u{043E}\u{0434}\u{0438}\u{043D}\u{0438}")
    }

    @Test func swahiliLocaleNounClassChanges() {
        let pt = SayableAgeFormatter(Locales.SW)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Mzaliwa mpya")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "siku 1")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "siku 3")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "miezi 6")
        #expect(pt.formatAge("2023-06-15", "2025-07-15") == "miaka 2, mwezi 1")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "miaka 3 na nusu")
    }

    @Test func indonesianLocaleOtherOnly() {
        let pt = SayableAgeFormatter(Locales.ID)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "Baru lahir")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "1 hari")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 hari")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6 bulan")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3 tahun setengah")
        #expect(pt.formatAge("2018-06-15", "2025-06-15") == "7 tahun")
    }

    @Test func amharicLocaleEthiopicDelimiter() {
        let pt = SayableAgeFormatter(Locales.AM)
        #expect(pt.formatAge("2025-06-15", "2025-06-15") == "\u{12A0}\u{12F2}\u{1235} \u{12E8}\u{1270}\u{12C8}\u{1208}\u{12F0}")
        #expect(pt.formatAge("2025-06-14", "2025-06-15") == "1 \u{1240}\u{1295}")
        #expect(pt.formatAge("2025-06-12", "2025-06-15") == "3 \u{1240}\u{1293}\u{1275}")
        #expect(pt.formatAge("2025-06-07", "2025-06-15") == "1 \u{1233}\u{121D}\u{1295}\u{1275}\u{1363} 1 \u{1240}\u{1295}")
        #expect(pt.formatAge("2025-01-15", "2025-07-15") == "6 \u{12C8}\u{122B}\u{1275}")
        #expect(pt.formatAge("2022-06-15", "2025-12-15") == "3 \u{12D3}\u{1218}\u{1273}\u{1275} \u{1270}\u{12A9}\u{120D}")
    }

    // ================================================================
    // Locale lookup by code string
    // ================================================================
    @Test func getLocaleReturnsEnLocale() {
        let loc = Locales.get("en")
        #expect(loc != nil)
        #expect(loc!.code == "en")
    }

    @Test func getLocaleReturnsFrLocale() {
        let loc = Locales.get("fr")
        #expect(loc != nil)
        #expect(loc!.code == "fr")
    }

    @Test func getLocaleReturnsNilForUnknownCode() {
        #expect(Locales.get("xx") == nil)
    }

    @Test func getLocaleReturnsNilForEmptyString() {
        #expect(Locales.get("") == nil)
    }

    @Test func getLocaleIsCaseSensitive() {
        #expect(Locales.get("EN") == nil)
    }
}
