Imports System
Imports System.Collections.Generic
Imports SayableAgeLib
Imports Xunit

Namespace SayableAge.Tests

    Public Class FormatAgeTest
        Implements IDisposable

        Public Sub Dispose() Implements IDisposable.Dispose
            SayableAgeFormatter.TimeNow = Function() DateTime.Today
        End Sub

        ' ================================================================
        ' formatAge -- null/edge cases
        ' ================================================================
        ' 1.3
        <Fact>
        Public Sub EmptyStringReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatAgeDefault("", "2025-06-15"))
        End Sub

        ' 1.4
        <Fact>
        Public Sub FutureDobReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatAgeDefault("2025-07-01", "2025-06-15"))
        End Sub

        ' 1.5
        <Fact>
        Public Sub Exactly500YearsIsAllowed()
            Assert.Equal("500 years", SayableAgeFormatter.FormatAgeDefault("1525-06-15", "2025-06-15"))
        End Sub

        ' 1.6
        <Fact>
        Public Sub Years501ExceedsMaxAge()
            Assert.Null(SayableAgeFormatter.FormatAgeDefault("1524-06-15", "2025-06-15"))
        End Sub

        ' 1.7
        <Fact>
        Public Sub Years1000ExceedsMaxAge()
            Assert.Null(SayableAgeFormatter.FormatAgeDefault("1025-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatAge -- days tier (0-6)
        ' ================================================================
        ' 2.1
        <Fact>
        Public Sub BornToday()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-06-15"))
        End Sub

        ' 2.2
        <Fact>
        Public Sub OneDayAgo()
            Assert.Equal("1 day", SayableAgeFormatter.FormatAgeDefault("2025-06-14", "2025-06-15"))
        End Sub

        ' 2.3
        <Fact>
        Public Sub ThreeDaysAgo()
            Assert.Equal("3 days", SayableAgeFormatter.FormatAgeDefault("2025-06-12", "2025-06-15"))
        End Sub

        ' 2.4
        <Fact>
        Public Sub SixDaysAgo()
            Assert.Equal("6 days", SayableAgeFormatter.FormatAgeDefault("2025-06-09", "2025-06-15"))
        End Sub

        ' 2.5
        <Fact>
        Public Sub SevenDaysBecomesOneWeek()
            Assert.Equal("1 week", SayableAgeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatAge -- weeks+days tier (7 days to less than 3 months)
        ' ================================================================
        ' 3.1
        <Fact>
        Public Sub SevenDaysIsOneWeek()
            Assert.Equal("1 week", SayableAgeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"))
        End Sub

        ' 3.2
        <Fact>
        Public Sub EightDaysIsOneWeekOneDay()
            Assert.Equal("1 week, 1 day", SayableAgeFormatter.FormatAgeDefault("2025-06-07", "2025-06-15"))
        End Sub

        ' 3.3
        <Fact>
        Public Sub NineDaysIsOneWeekTwoDays()
            Assert.Equal("1 week, 2 days", SayableAgeFormatter.FormatAgeDefault("2025-06-06", "2025-06-15"))
        End Sub

        ' 3.4
        <Fact>
        Public Sub ThirteenDaysIsOneWeekSixDays()
            Assert.Equal("1 week, 6 days", SayableAgeFormatter.FormatAgeDefault("2025-06-02", "2025-06-15"))
        End Sub

        ' 3.5
        <Fact>
        Public Sub FourteenDaysIsTwoWeeks()
            Assert.Equal("2 weeks", SayableAgeFormatter.FormatAgeDefault("2025-06-01", "2025-06-15"))
        End Sub

        ' 3.6
        <Fact>
        Public Sub FifteenDaysIsTwoWeeksOneDay()
            Assert.Equal("2 weeks, 1 day", SayableAgeFormatter.FormatAgeDefault("2025-05-31", "2025-06-15"))
        End Sub

        ' 3.7
        <Fact>
        Public Sub TwentyDaysIsTwoWeeksSixDays()
            Assert.Equal("2 weeks, 6 days", SayableAgeFormatter.FormatAgeDefault("2025-05-26", "2025-06-15"))
        End Sub

        ' 3.8
        <Fact>
        Public Sub TwentyOneDaysIsThreeWeeks()
            Assert.Equal("3 weeks", SayableAgeFormatter.FormatAgeDefault("2025-05-25", "2025-06-15"))
        End Sub

        ' 3.9
        <Fact>
        Public Sub AtOneCalMonthStillWeeksDays()
            Assert.Equal("4 weeks, 3 days", SayableAgeFormatter.FormatAgeDefault("2025-05-15", "2025-06-15"))
        End Sub

        ' 3.10
        <Fact>
        Public Sub AtTwoCalMonthsStillWeeksDays()
            Assert.Equal("8 weeks, 5 days", SayableAgeFormatter.FormatAgeDefault("2025-04-15", "2025-06-15"))
        End Sub

        ' 3.11
        <Fact>
        Public Sub OneDayBefore3moStillWeeks()
            Assert.Equal("13 weeks", SayableAgeFormatter.FormatAgeDefault("2025-03-15", "2025-06-14"))
        End Sub

        ' 3.12
        <Fact>
        Public Sub On3moBirthdaySwitches()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-03-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatAge -- month boundaries: standard months
        ' ================================================================
        ' 4.1
        <Fact>
        Public Sub Jan1ToApr1Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-01", "2025-04-01"))
        End Sub

        ' 4.2
        ' 4.3
        <Fact>
        Public Sub Jun15ToSep15Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-09-15"))
        End Sub

        ' 4.4
        ' 4.5
        <Fact>
        Public Sub Jun15ToDec15Is6mo()
            Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-12-15"))
        End Sub

        ' ================================================================
        ' formatAge -- month boundaries: February non-leap
        ' ================================================================
        ' 5.1
        <Fact>
        Public Sub Jan31ToFeb28NonLeap()
            Assert.Equal("4 weeks", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-02-28"))
        End Sub

        ' 5.2
        <Fact>
        Public Sub Jan31ToApr30Is3moClamp()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"))
        End Sub

        ' 5.3
        ' 5.4
        <Fact>
        Public Sub Feb1ToMay1Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-02-01", "2025-05-01"))
        End Sub

        ' 5.5
        ' ================================================================
        ' formatAge -- month boundaries: February leap year
        ' ================================================================
        ' 6.1
        <Fact>
        Public Sub Jan31ToFeb29Leap()
            Assert.Equal("4 weeks, 1 day", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-02-29"))
        End Sub

        ' 6.2
        <Fact>
        Public Sub Jan31ToFeb28Leap()
            Assert.Equal("4 weeks", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-02-28"))
        End Sub

        ' 6.3
        <Fact>
        Public Sub Jan31ToApr30LeapIs3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-04-30"))
        End Sub

        ' 6.4
        ' 6.5
        ' ================================================================
        ' formatAge -- month boundaries: 30-day months
        ' ================================================================
        ' 7.1
        <Fact>
        Public Sub Mar31ToJun30Is3moClamped()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-03-31", "2025-06-30"))
        End Sub

        ' 7.2
        ' 7.3
        <Fact>
        Public Sub Aug31ToNov30Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-08-31", "2025-11-30"))
        End Sub

        ' 7.4
        ' ================================================================
        ' formatAge -- month boundaries: leap year baby (born Feb 29)
        ' ================================================================
        ' 8.1
        <Fact>
        Public Sub Feb29ToMay29Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2024-05-29"))
        End Sub

        ' 8.2
        ' 8.3
        <Fact>
        Public Sub Feb29_2024ToFeb28_2025Is12mo()
            Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2025-02-28"))
        End Sub

        ' 8.4
        <Fact>
        Public Sub Feb29_2024ToMar1_2025Is12mo()
            Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2025-03-01"))
        End Sub

        ' ================================================================
        ' formatAge -- months tier (3-23)
        ' ================================================================
        ' 9.1
        <Fact>
        Public Sub ThreeMonthsAtTransition()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-04-15"))
        End Sub

        ' 9.2
        <Fact>
        Public Sub SixMonths()
            Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-07-15"))
        End Sub

        ' 9.3
        <Fact>
        Public Sub TwelveMonthsNotOneYear()
            Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-06-15", "2025-06-15"))
        End Sub

        ' 9.4
        <Fact>
        Public Sub TwentyThreeMonthsAtUpper()
            Assert.Equal("23 months", SayableAgeFormatter.FormatAgeDefault("2024-01-15", "2025-12-15"))
        End Sub

        ' 9.5
        <Fact>
        Public Sub OneDayBeforeBoundary()
            Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-07-14"))
        End Sub

        ' 9.6
        <Fact>
        Public Sub CrossingYearBoundary()
            Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2024-11-10", "2025-04-10"))
        End Sub

        ' ================================================================
        ' formatAge -- years+months tier (24-35 months)
        ' ================================================================
        ' 10.1
        <Fact>
        Public Sub TwoYearsAt24mo()
            Assert.Equal("2 years", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-06-15"))
        End Sub

        ' 10.2
        <Fact>
        Public Sub TwoYearsOneMonth()
            Assert.Equal("2 years, 1 month", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-07-15"))
        End Sub

        ' 10.3
        <Fact>
        Public Sub TwoYearsSixMonths()
            Assert.Equal("2 years, 6 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-12-15"))
        End Sub

        ' 10.4
        <Fact>
        Public Sub TwoYearsElevenMonths()
            Assert.Equal("2 years, 11 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2026-05-15"))
        End Sub

        ' 10.5
        <Fact>
        Public Sub OneDayBefore24mo()
            Assert.Equal("23 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-06-14"))
        End Sub

        ' ================================================================
        ' formatAge -- half-year tier (3-6 years)
        ' ================================================================
        ' 11.1
        <Fact>
        Public Sub ThreeYearsExactly()
            Assert.Equal("3 years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-06-15"))
        End Sub

        ' 11.2
        <Fact>
        Public Sub ThreeYearsFiveMonths()
            Assert.Equal("3 years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-11-15"))
        End Sub

        ' 11.3
        <Fact>
        Public Sub ThreeAndHalfYearsAt3y6m()
            Assert.Equal("3½ years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-12-15"))
        End Sub

        ' 11.4
        <Fact>
        Public Sub ThreeAndHalfYearsAt3y11m()
            Assert.Equal("3½ years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2026-05-15"))
        End Sub

        ' 11.5
        <Fact>
        Public Sub FourYearsExactly()
            Assert.Equal("4 years", SayableAgeFormatter.FormatAgeDefault("2021-06-15", "2025-06-15"))
        End Sub

        ' 11.6
        <Fact>
        Public Sub FourAndHalfYears()
            Assert.Equal("4½ years", SayableAgeFormatter.FormatAgeDefault("2021-06-15", "2025-12-15"))
        End Sub

        ' 11.7
        <Fact>
        Public Sub FiveYears()
            Assert.Equal("5 years", SayableAgeFormatter.FormatAgeDefault("2020-06-15", "2025-06-15"))
        End Sub

        ' 11.8
        <Fact>
        Public Sub FiveAndHalfYearsAt5y8m()
            Assert.Equal("5½ years", SayableAgeFormatter.FormatAgeDefault("2020-06-15", "2026-02-15"))
        End Sub

        ' 11.9
        <Fact>
        Public Sub SixYears()
            Assert.Equal("6 years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2025-06-15"))
        End Sub

        ' 11.10
        <Fact>
        Public Sub SixAndHalfYears()
            Assert.Equal("6½ years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2025-12-15"))
        End Sub

        ' 11.11
        <Fact>
        Public Sub SixAndHalfYearsAt6y11m()
            Assert.Equal("6½ years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2026-05-15"))
        End Sub

        ' 11.12
        <Fact>
        Public Sub OneDayBefore3rdBday()
            Assert.Equal("2 years, 11 months", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-06-14"))
        End Sub

        ' ================================================================
        ' formatAge -- integer tier (7+ years)
        ' ================================================================
        ' 12.1
        <Fact>
        Public Sub SevenYearsExactly()
            Assert.Equal("7 years", SayableAgeFormatter.FormatAgeDefault("2018-06-15", "2025-06-15"))
        End Sub

        ' 12.2
        <Fact>
        Public Sub SevenYearsSixMonthsNoHalf()
            Assert.Equal("7 years", SayableAgeFormatter.FormatAgeDefault("2018-03-20", "2025-06-15"))
        End Sub

        ' 12.3
        <Fact>
        Public Sub FortyFiveYears()
            Assert.Equal("45 years", SayableAgeFormatter.FormatAgeDefault("1980-01-01", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatAge -- cross-year transitions with Feb
        ' ================================================================
        ' 13.1
        <Fact>
        Public Sub Dec31ToMar31Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-12-31", "2025-03-31"))
        End Sub

        ' 13.2
        ' 13.3
        <Fact>
        Public Sub Nov30ToFeb28Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-11-30", "2025-02-28"))
        End Sub

        ' 13.4
        ' ================================================================
        ' formatAge -- born-on-31st progression
        ' ================================================================
        ' 14.1
        <Fact>
        Public Sub Jan31ToApr30Is3mo()
            Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"))
        End Sub

        ' 14.2
        <Fact>
        Public Sub Jan31ToMay31Is4mo()
            Assert.Equal("4 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-05-31"))
        End Sub

        ' 14.3
        <Fact>
        Public Sub Jan31ToJun30Is5moClamped()
            Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-06-30"))
        End Sub

        ' 14.4
        <Fact>
        Public Sub Jan31ToJul1Is5mo()
            Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-07-01"))
        End Sub

        ' 14.5
        <Fact>
        Public Sub Jan31ToJul31Is6mo()
            Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-07-31"))
        End Sub

        ' ================================================================
        ' formatAge -- default asOf (uses current date)
        ' ================================================================
        ' 15.1, 15.2
        ' ================================================================
        ' formatStage -- null/edge cases
        ' ================================================================
        ' 16.3
        <Fact>
        Public Sub StageEmptyStringReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatStageDefault("", "2025-06-15"))
        End Sub

        ' 16.4
        <Fact>
        Public Sub StageFutureDobReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatStageDefault("2025-07-01", "2025-06-15"))
        End Sub

        ' 16.5
        <Fact>
        Public Sub StageExactly500YearsReturnsAdult()
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1525-06-15", "2025-06-15"))
        End Sub

        ' 16.6
        <Fact>
        Public Sub Stage501YearsExceedsMaxAge()
            Assert.Null(SayableAgeFormatter.FormatStageDefault("1524-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- newborn
        ' ================================================================
        ' 17.1
        <Fact>
        Public Sub StageBornToday()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-15", "2025-06-15"))
        End Sub

        ' 17.2
        <Fact>
        Public Sub StageOneDayOld()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-14", "2025-06-15"))
        End Sub

        ' 17.3
        <Fact>
        Public Sub StageThreeWeeksOld()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-05-25", "2025-06-15"))
        End Sub

        ' 17.4
        <Fact>
        Public Sub StageOneMonthOld()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-05-15", "2025-06-15"))
        End Sub

        ' 17.5
        <Fact>
        Public Sub StageOneMonth29Days()
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-04-16", "2025-06-15"))
        End Sub

        ' 17.6
        <Fact>
        Public Sub StageExactly2MonthsBecomesInfant()
            Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- infant
        ' ================================================================
        ' 18.1
        <Fact>
        Public Sub StageTwoMonths()
            Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"))
        End Sub

        ' 18.2
        <Fact>
        Public Sub StageSixMonths()
            Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2024-12-15", "2025-06-15"))
        End Sub

        ' 18.3
        <Fact>
        Public Sub StageElevenMonths()
            Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2024-07-15", "2025-06-15"))
        End Sub

        ' 18.4
        <Fact>
        Public Sub StageExactly12moBecomesToddler()
            Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- toddler
        ' ================================================================
        ' 19.1
        <Fact>
        Public Sub StageTwelveMonths()
            Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"))
        End Sub

        ' 19.2
        <Fact>
        Public Sub StageEighteenMonths()
            Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-01-15", "2025-07-15"))
        End Sub

        ' 19.3
        <Fact>
        Public Sub StageTwentyFourMonths()
            Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2023-06-15", "2025-06-15"))
        End Sub

        ' 19.4
        <Fact>
        Public Sub StageThirtyFiveMonths()
            Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2023-06-15", "2026-05-15"))
        End Sub

        ' 19.5
        <Fact>
        Public Sub StageExactly36moBecomesChild()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- child
        ' ================================================================
        ' 20.1
        <Fact>
        Public Sub StageThreeYears()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"))
        End Sub

        ' 20.2
        <Fact>
        Public Sub StageFourYears()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2021-06-15", "2025-06-15"))
        End Sub

        ' 20.3
        <Fact>
        Public Sub StageSixYears()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2019-06-15", "2025-06-15"))
        End Sub

        ' 20.4
        <Fact>
        Public Sub StageNineYears()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2016-06-15", "2025-06-15"))
        End Sub

        ' 20.5
        <Fact>
        Public Sub Stage12y11mo()
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2013-06-15", "2026-05-15"))
        End Sub

        ' 20.6
        <Fact>
        Public Sub StageExactly13yBecomesTeenager()
            Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- teenager
        ' ================================================================
        ' 21.1
        <Fact>
        Public Sub StageThirteenYears()
            Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"))
        End Sub

        ' 21.2
        <Fact>
        Public Sub StageFifteenYears()
            Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2010-06-15", "2025-06-15"))
        End Sub

        ' 21.3
        <Fact>
        Public Sub Stage17y11mo()
            Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2008-06-15", "2026-05-15"))
        End Sub

        ' 21.4
        <Fact>
        Public Sub StageExactly18yBecomesAdult()
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- adult
        ' ================================================================
        ' 22.1
        <Fact>
        Public Sub StageEighteenYears()
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"))
        End Sub

        ' 22.2
        <Fact>
        Public Sub StageTwentyFiveYears()
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2000-06-15", "2025-06-15"))
        End Sub

        ' 22.3
        <Fact>
        Public Sub StageFortyFiveYears()
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1980-01-01", "2025-06-15"))
        End Sub

        ' ================================================================
        ' formatStage -- default asOf
        ' ================================================================
        ' 23.1, 23.2, 23.3
        ' ================================================================
        ' SayableAgeFormatter class with English locale
        ' ================================================================
        ' 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
        ' ================================================================
        ' SayableAgeFormatter with Spanish locale
        ' ================================================================
        ' 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
        ' ================================================================
        ' Compactness: short
        ' ================================================================
        ' 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
        ' ================================================================
        ' Compactness: compact
        ' ================================================================
        ' 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
        ' ================================================================
        ' All 110 locales exist and have correct codes
        ' ================================================================
        ' ================================================================
        ' Smoke test each locale produces non-null output
        ' ================================================================
        ' ================================================================
        ' formatStage -- gender support
        ' ================================================================
        ' ================================================================
        ' Locale-specific edge cases — new plural rules
        ' ================================================================
        ' 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
        ' ================================================================
        ' Locale lookup by code string
        ' ================================================================
        <Fact>
        Public Sub GetLocaleReturnsNullForUnknownCode()
            Assert.Null(Locales.Get("xx"))
        End Sub

        <Fact>
        Public Sub GetLocaleReturnsNullForEmptyString()
            Assert.Null(Locales.Get(""))
        End Sub

        <Fact>
        Public Sub GetLocaleIsCaseSensitive()
            Assert.Null(Locales.Get("EN"))
        End Sub

    End Class

End Namespace
