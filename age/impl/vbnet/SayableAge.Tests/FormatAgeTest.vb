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
        ' 1.1
        <Fact>
        Public Sub NullDobReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatAgeDefault(Nothing, "2025-06-15"))
        End Sub

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
        <Fact>
        Public Sub DefaultAsOfUsesMockedToday()
            SayableAgeFormatter.TimeNow = Function() New DateTime(2025, 6, 15)
            Assert.Equal("5 years", SayableAgeFormatter.FormatAgeDefault("2020-01-01")) ' 15.1
            Assert.Equal("5 days", SayableAgeFormatter.FormatAgeDefault("2025-06-10")) ' 15.2
        End Sub

        ' ================================================================
        ' formatStage -- null/edge cases
        ' ================================================================
        ' 16.1
        <Fact>
        Public Sub StageNullDobReturnsNull()
            Assert.Null(SayableAgeFormatter.FormatStageDefault(Nothing, "2025-06-15"))
        End Sub

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
        <Fact>
        Public Sub StageDefaultAsOf()
            SayableAgeFormatter.TimeNow = Function() New DateTime(2025, 6, 15)
            Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-15")) ' 23.1
            Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2020-01-01")) ' 23.2
            Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1980-01-01")) ' 23.3
        End Sub

        ' ================================================================
        ' SayableAgeFormatter class with English locale
        ' ================================================================
        ' 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
        <Fact>
        Public Sub SayableAgeEnglishAllTiers()
            Dim pt = New SayableAgeFormatter(Locales.EN)
            Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")) ' 24.1
            Assert.Equal("3 days", pt.FormatAge("2025-06-12", "2025-06-15")) ' 24.2
            Assert.Equal("1 week, 1 day", pt.FormatAge("2025-06-07", "2025-06-15")) ' 24.3
            Assert.Equal("6 months", pt.FormatAge("2025-01-15", "2025-07-15")) ' 24.4
            Assert.Equal("2 years, 1 month", pt.FormatAge("2023-06-15", "2025-07-15")) ' 24.5
            Assert.Equal("3½ years", pt.FormatAge("2022-06-15", "2025-12-15")) ' 24.6
            Assert.Equal("7 years", pt.FormatAge("2018-06-15", "2025-06-15")) ' 24.7
            Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15")) ' 24.8
            Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15")) ' 24.9
            Assert.Equal("Toddler", pt.FormatStage("2024-06-15", "2025-06-15")) ' 24.10
            Assert.Equal("Child", pt.FormatStage("2022-06-15", "2025-06-15")) ' 24.11
            Assert.Equal("Teenager", pt.FormatStage("2012-06-15", "2025-06-15")) ' 24.12
            Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15")) ' 24.13
            Assert.Null(pt.FormatAge(Nothing, "2025-06-15")) ' 24.14
            Assert.Null(pt.FormatStage(Nothing, "2025-06-15")) ' 24.15
        End Sub

        ' ================================================================
        ' SayableAgeFormatter with Spanish locale
        ' ================================================================
        ' 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
        <Fact>
        Public Sub SayableAgeSpanishInlineLocale()
            Dim es = New AgeLocale(
                "es",
                Function(n) If(n = 1, PluralCategory.One, PluralCategory.Other),
                New Units(
                    UnitForms.Plural(New Dictionary(Of PluralCategory, String) From {{PluralCategory.One, "{n} día"}, {PluralCategory.Other, "{n} días"}}),
                    UnitForms.Plural(New Dictionary(Of PluralCategory, String) From {{PluralCategory.One, "{n} semana"}, {PluralCategory.Other, "{n} semanas"}}),
                    UnitForms.Plural(New Dictionary(Of PluralCategory, String) From {{PluralCategory.One, "{n} mes"}, {PluralCategory.Other, "{n} meses"}}),
                    UnitForms.Plural(New Dictionary(Of PluralCategory, String) From {{PluralCategory.One, "{n} año"}, {PluralCategory.Other, "{n} años"}})
                ),
                "{0} y medio",
                ", ",
                "Recién nacido",
                New Stages(
                    StageLabel.Gendered("Recién nacido", "Recién nacida"),
                    StageLabel.Neutral("Bebé"),
                    StageLabel.Gendered("Niño pequeño", "Niña pequeña"),
                    StageLabel.Gendered("Niño", "Niña"),
                    StageLabel.Neutral("Adolescente"),
                    StageLabel.Gendered("Adulto", "Adulta")
                )
            )
            Dim pt = New SayableAgeFormatter(es)
            Assert.Equal("Recién nacido", pt.FormatAge("2025-06-15", "2025-06-15")) ' 25.1
            Assert.Equal("1 día", pt.FormatAge("2025-06-14", "2025-06-15")) ' 25.2
            Assert.Equal("3 días", pt.FormatAge("2025-06-12", "2025-06-15")) ' 25.3
            Assert.Equal("1 semana", pt.FormatAge("2025-06-08", "2025-06-15")) ' 25.4
            Assert.Equal("1 semana, 1 día", pt.FormatAge("2025-06-07", "2025-06-15")) ' 25.5
            Assert.Equal("2 semanas, 6 días", pt.FormatAge("2025-05-26", "2025-06-15")) ' 25.6
            Assert.Equal("6 meses", pt.FormatAge("2025-01-15", "2025-07-15")) ' 25.7
            Assert.Equal("2 años, 1 mes", pt.FormatAge("2023-06-15", "2025-07-15")) ' 25.8
            Assert.Equal("2 años, 6 meses", pt.FormatAge("2023-06-15", "2025-12-15")) ' 25.9
            Assert.Equal("3 años y medio", pt.FormatAge("2022-06-15", "2025-12-15")) ' 25.10
            Assert.Equal("3 años", pt.FormatAge("2022-06-15", "2025-06-15")) ' 25.11
            Assert.Equal("7 años", pt.FormatAge("2018-06-15", "2025-06-15")) ' 25.12
            Assert.Equal("Recién nacido", pt.FormatStage("2025-06-15", "2025-06-15")) ' 25.13
            Assert.Equal("Bebé", pt.FormatStage("2025-01-15", "2025-06-15")) ' 25.14
            Assert.Equal("Niño pequeño", pt.FormatStage("2024-06-15", "2025-06-15")) ' 25.15
            Assert.Equal("Niño", pt.FormatStage("2022-06-15", "2025-06-15")) ' 25.16
            Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15")) ' 25.17
            Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15")) ' 25.18
            Assert.Null(pt.FormatAge(Nothing, "2025-06-15")) ' 25.19
            Assert.Null(pt.FormatStage(Nothing, "2025-06-15")) ' 25.20
        End Sub

        ' ================================================================
        ' Compactness: short
        ' ================================================================
        ' 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
        <Fact>
        Public Sub CompactShort()
            Dim pt = New SayableAgeFormatter(Locales.EN, Compactness.Short)
            Assert.Equal("3 d", pt.FormatAge("2025-06-12", "2025-06-15")) ' 26.1
            Assert.Equal("1 wk", pt.FormatAge("2025-06-08", "2025-06-15")) ' 26.2
            Assert.Equal("1 wk, 1 d", pt.FormatAge("2025-06-07", "2025-06-15")) ' 26.3
            Assert.Equal("6 mo", pt.FormatAge("2025-01-15", "2025-07-15")) ' 26.4
            Assert.Equal("2 yr, 1 mo", pt.FormatAge("2023-06-15", "2025-07-15")) ' 26.5
            Assert.Equal("3½ yr", pt.FormatAge("2022-06-15", "2025-12-15")) ' 26.6
            Assert.Equal("7 yr", pt.FormatAge("2018-06-15", "2025-06-15")) ' 26.7
            Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")) ' 26.8
            Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15")) ' 26.9
        End Sub

        ' ================================================================
        ' Compactness: compact
        ' ================================================================
        ' 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
        <Fact>
        Public Sub CompactCompact()
            Dim pt = New SayableAgeFormatter(Locales.EN, Compactness.Compact)
            Assert.Equal("3d", pt.FormatAge("2025-06-12", "2025-06-15")) ' 27.1
            Assert.Equal("1w", pt.FormatAge("2025-06-08", "2025-06-15")) ' 27.2
            Assert.Equal("1w1d", pt.FormatAge("2025-06-07", "2025-06-15")) ' 27.3
            Assert.Equal("6m", pt.FormatAge("2025-01-15", "2025-07-15")) ' 27.4
            Assert.Equal("2y1m", pt.FormatAge("2023-06-15", "2025-07-15")) ' 27.5
            Assert.Equal("3½y", pt.FormatAge("2022-06-15", "2025-12-15")) ' 27.6
            Assert.Equal("7y", pt.FormatAge("2018-06-15", "2025-06-15")) ' 27.7
            Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")) ' 27.8
        End Sub

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
        <Fact>
        Public Sub LocaleHEPluralRules()
            Dim pt = New SayableAgeFormatter(Locales.HE)
            Assert.Equal("רק נולד", pt.FormatAge("2025-06-15", "2025-06-15")) ' 29.1
            Assert.Equal("יום", pt.FormatAge("2025-06-14", "2025-06-15")) ' 29.2
            Assert.Equal("3 ימים", pt.FormatAge("2025-06-12", "2025-06-15")) ' 29.3
            Assert.Equal("שבועיים", pt.FormatAge("2025-06-01", "2025-06-15")) ' 29.4
            Assert.Equal("3 שבועות", pt.FormatAge("2025-05-25", "2025-06-15")) ' 29.5
            Assert.Equal("6 חודשים", pt.FormatAge("2025-01-15", "2025-07-15")) ' 29.6
            Assert.Equal("3 חודשים", pt.FormatAge("2025-03-15", "2025-06-15")) ' 29.7
            Assert.Equal("שנתיים, חודש", pt.FormatAge("2023-06-15", "2025-07-15")) ' 29.8
            Assert.Equal("3 שנים וחצי", pt.FormatAge("2022-06-15", "2025-12-15")) ' 29.9
            Assert.Equal("7 שנים", pt.FormatAge("2018-06-15", "2025-06-15")) ' 29.10
            Assert.Equal("רק נולד", pt.FormatStage("2025-06-15", "2025-06-15", "m")) ' 29.11
            Assert.Equal("רק נולדה", pt.FormatStage("2025-06-15", "2025-06-15", "f")) ' 29.12
            Assert.Equal("מבוגר", pt.FormatStage("2007-06-15", "2025-06-15", "m")) ' 29.13
            Assert.Equal("מבוגרת", pt.FormatStage("2007-06-15", "2025-06-15", "f")) ' 29.14
        End Sub

        <Fact>
        Public Sub LocaleMKPluralRules()
            Dim pt = New SayableAgeFormatter(Locales.MK)
            Assert.Equal("Новороденче", pt.FormatAge("2025-06-15", "2025-06-15")) ' 29.15
            Assert.Equal("1 ден", pt.FormatAge("2025-06-14", "2025-06-15")) ' 29.16
            Assert.Equal("3 дена", pt.FormatAge("2025-06-12", "2025-06-15")) ' 29.17
            Assert.Equal("6 месеци", pt.FormatAge("2025-01-15", "2025-07-15")) ' 29.18
            Assert.Equal("2 години, 1 месец", pt.FormatAge("2023-06-15", "2025-07-15")) ' 29.19
            Assert.Equal("3 години и пол", pt.FormatAge("2022-06-15", "2025-12-15")) ' 29.20
            Assert.Equal("7 години", pt.FormatAge("2018-06-15", "2025-06-15")) ' 29.21
        End Sub

        <Fact>
        Public Sub LocaleSWPluralRules()
            Dim pt = New SayableAgeFormatter(Locales.SW)
            Assert.Equal("Mzaliwa mpya", pt.FormatAge("2025-06-15", "2025-06-15")) ' 29.22
            Assert.Equal("siku 1", pt.FormatAge("2025-06-14", "2025-06-15")) ' 29.23
            Assert.Equal("siku 3", pt.FormatAge("2025-06-12", "2025-06-15")) ' 29.24
            Assert.Equal("miezi 6", pt.FormatAge("2025-01-15", "2025-07-15")) ' 29.25
            Assert.Equal("miaka 2, mwezi 1", pt.FormatAge("2023-06-15", "2025-07-15")) ' 29.26
            Assert.Equal("miaka 3 na nusu", pt.FormatAge("2022-06-15", "2025-12-15")) ' 29.27
        End Sub

        <Fact>
        Public Sub LocaleIDPluralRules()
            Dim pt = New SayableAgeFormatter(Locales.ID)
            Assert.Equal("Baru lahir", pt.FormatAge("2025-06-15", "2025-06-15")) ' 29.28
            Assert.Equal("1 hari", pt.FormatAge("2025-06-14", "2025-06-15")) ' 29.29
            Assert.Equal("3 hari", pt.FormatAge("2025-06-12", "2025-06-15")) ' 29.30
            Assert.Equal("6 bulan", pt.FormatAge("2025-01-15", "2025-07-15")) ' 29.31
            Assert.Equal("3 setengah tahun", pt.FormatAge("2022-06-15", "2025-12-15")) ' 29.32
            Assert.Equal("7 tahun", pt.FormatAge("2018-06-15", "2025-06-15")) ' 29.33
        End Sub

        <Fact>
        Public Sub LocaleAMPluralRules()
            Dim pt = New SayableAgeFormatter(Locales.AM)
            Assert.Equal("አዲስ የተወለደ", pt.FormatAge("2025-06-15", "2025-06-15")) ' 29.34
            Assert.Equal("1 ቀን", pt.FormatAge("2025-06-14", "2025-06-15")) ' 29.35
            Assert.Equal("3 ቀናት", pt.FormatAge("2025-06-12", "2025-06-15")) ' 29.36
            Assert.Equal("1 ሳምንት፣ 1 ቀን", pt.FormatAge("2025-06-07", "2025-06-15")) ' 29.37
            Assert.Equal("6 ወራት", pt.FormatAge("2025-01-15", "2025-07-15")) ' 29.38
            Assert.Equal("3 ዓመታት ተኩል", pt.FormatAge("2022-06-15", "2025-12-15")) ' 29.39
        End Sub

        ' ================================================================
        ' Locale lookup by code string
        ' ================================================================
        <Fact>
        Public Sub Spec30_1GetLocale()
            Dim loc = Locales.Get("en")
            Assert.NotNull(loc)
            Assert.Equal("en", loc.Code) ' 30.1
        End Sub

        <Fact>
        Public Sub Spec30_2GetLocale()
            Dim loc = Locales.Get("fr")
            Assert.NotNull(loc)
            Assert.Equal("fr", loc.Code) ' 30.2
        End Sub

        <Fact>
        Public Sub Spec30_3GetLocale()
            Assert.Null(Locales.Get("xx")) ' 30.3
        End Sub

        <Fact>
        Public Sub Spec30_4GetLocale()
            Assert.Null(Locales.Get("")) ' 30.4
        End Sub

        <Fact>
        Public Sub Spec30_5GetLocale()
            Assert.Null(Locales.Get("EN")) ' 30.5
        End Sub

        ' ================================================================
        ' Weeks and days across month ends
        ' ================================================================

        ' 31.1
        <Fact>
        Public Sub Spec31_1_88DaysAcrossA28DayFebruary()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Equal("12 weeks, 4 days", f.FormatAge("2016-12-31", "2017-03-29"))
        End Sub

        ' 31.2
        <Fact>
        Public Sub Spec31_2_90DaysAcrossAYearEndInto()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Equal("12 weeks, 6 days", f.FormatAge("1991-11-27", "1992-02-25"))
        End Sub

        ' 31.3
        <Fact>
        Public Sub Spec31_3_33DaysAcrossAYearEnd()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Equal("4 weeks, 5 days", f.FormatAge("2020-11-30", "2021-01-02"))
        End Sub

        ' 31.4
        <Fact>
        Public Sub Spec31_4_CompactFormOf311()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN, Compactness.Compact)
            Assert.Equal("12w4d", f.FormatAge("2016-12-31", "2017-03-29"))
        End Sub

        ' ================================================================
        ' Half years take their plural form from whole years
        ' ================================================================

        ' 32.1
        <Fact>
        Public Sub Spec32_1_Polish3IsFew()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.PL)
            Assert.Equal("3 i pół lata", f.FormatAge("2021-06-15", "2025-01-15"))
        End Sub

        ' 32.2
        <Fact>
        Public Sub Spec32_2_Polish5IsMany()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.PL, Compactness.Short)
            Assert.Equal("5 i pół lat", f.FormatAge("2020-06-15", "2025-12-15"))
        End Sub

        ' 32.3
        <Fact>
        Public Sub Spec32_3_Tachelhit6IsFew()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.SHI)
            Assert.Equal("6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ", f.FormatAge("2005-06-08", "2012-06-07"))
        End Sub

        ' ================================================================
        ' Input validation
        ' ================================================================

        ' 33.1
        <Fact>
        Public Sub Spec33_1_February30DoesntExist()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2025-02-30", "2032-06-25"))
        End Sub

        ' 33.2
        <Fact>
        Public Sub Spec33_2_Month13()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2025-13-01", "2027-01-31"))
        End Sub

        ' 33.3
        <Fact>
        Public Sub Spec33_3_February29InANonLeapYear()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2023-02-29", "2025-03-01"))
        End Sub

        ' 33.4
        <Fact>
        Public Sub Spec33_4_Day00()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2025-06-00", "2027-02-25"))
        End Sub

        ' 33.5
        <Fact>
        Public Sub Spec33_5_UnpaddedMonthAndDay()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2025-6-1", "2027-02-25"))
        End Sub

        ' 33.6
        <Fact>
        Public Sub Spec33_6_SurroundingWhitespace()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge(" 2025-06-01", "2027-02-25"))
        End Sub

        ' 33.7
        <Fact>
        Public Sub Spec33_7_ADatetimeIsNotADate()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2025-06-15T10:00:00", "2027-02-25"))
        End Sub

        ' 33.8
        <Fact>
        Public Sub Spec33_8_InvalidAsOf()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatAge("2020-01-01", "2025-04-31"))
        End Sub

        ' 33.9
        <Fact>
        Public Sub Spec33_9_FormatStageValidatesToo()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Null(f.FormatStage("2025-02-30", "2027-09-05"))
        End Sub

        ' 33.10
        <Fact>
        Public Sub Spec33_10_February29InALeapYearIs()
            Dim f = New SayableAgeLib.SayableAgeFormatter(Locales.EN)
            Assert.Equal("2 years", f.FormatAge("2024-02-29", "2026-03-01"))
        End Sub

    End Class

End Namespace
