using System;
using System.Collections.Generic;
using Xunit;

namespace SayableAgeLib.Tests;

public class FormatAgeTest : IDisposable
{
    public void Dispose()
    {
        SayableAgeFormatter.TimeNow = () => DateTime.Today;
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.3
    [Fact] public void EmptyStringReturnsNull() =>
        Assert.Null(SayableAgeFormatter.FormatAgeDefault("", "2025-06-15"));

    // 1.4
    [Fact] public void FutureDobReturnsNull() =>
        Assert.Null(SayableAgeFormatter.FormatAgeDefault("2025-07-01", "2025-06-15"));

    // 1.5
    [Fact] public void Exactly500YearsIsAllowed() =>
        Assert.Equal("500 years", SayableAgeFormatter.FormatAgeDefault("1525-06-15", "2025-06-15"));

    // 1.6
    [Fact] public void Years501ExceedsMaxAge() =>
        Assert.Null(SayableAgeFormatter.FormatAgeDefault("1524-06-15", "2025-06-15"));

    // 1.7
    [Fact] public void Years1000ExceedsMaxAge() =>
        Assert.Null(SayableAgeFormatter.FormatAgeDefault("1025-06-15", "2025-06-15"));

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    [Fact] public void BornToday() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-06-15"));

    // 2.2
    [Fact] public void OneDayAgo() =>
        Assert.Equal("1 day", SayableAgeFormatter.FormatAgeDefault("2025-06-14", "2025-06-15"));

    // 2.3
    [Fact] public void ThreeDaysAgo() =>
        Assert.Equal("3 days", SayableAgeFormatter.FormatAgeDefault("2025-06-12", "2025-06-15"));

    // 2.4
    [Fact] public void SixDaysAgo() =>
        Assert.Equal("6 days", SayableAgeFormatter.FormatAgeDefault("2025-06-09", "2025-06-15"));

    // 2.5
    [Fact] public void SevenDaysBecomesOneWeek() =>
        Assert.Equal("1 week", SayableAgeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"));

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    [Fact] public void SevenDaysIsOneWeek() =>
        Assert.Equal("1 week", SayableAgeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"));

    // 3.2
    [Fact] public void EightDaysIsOneWeekOneDay() =>
        Assert.Equal("1 week, 1 day", SayableAgeFormatter.FormatAgeDefault("2025-06-07", "2025-06-15"));

    // 3.3
    [Fact] public void NineDaysIsOneWeekTwoDays() =>
        Assert.Equal("1 week, 2 days", SayableAgeFormatter.FormatAgeDefault("2025-06-06", "2025-06-15"));

    // 3.4
    [Fact] public void ThirteenDaysIsOneWeekSixDays() =>
        Assert.Equal("1 week, 6 days", SayableAgeFormatter.FormatAgeDefault("2025-06-02", "2025-06-15"));

    // 3.5
    [Fact] public void FourteenDaysIsTwoWeeks() =>
        Assert.Equal("2 weeks", SayableAgeFormatter.FormatAgeDefault("2025-06-01", "2025-06-15"));

    // 3.6
    [Fact] public void FifteenDaysIsTwoWeeksOneDay() =>
        Assert.Equal("2 weeks, 1 day", SayableAgeFormatter.FormatAgeDefault("2025-05-31", "2025-06-15"));

    // 3.7
    [Fact] public void TwentyDaysIsTwoWeeksSixDays() =>
        Assert.Equal("2 weeks, 6 days", SayableAgeFormatter.FormatAgeDefault("2025-05-26", "2025-06-15"));

    // 3.8
    [Fact] public void TwentyOneDaysIsThreeWeeks() =>
        Assert.Equal("3 weeks", SayableAgeFormatter.FormatAgeDefault("2025-05-25", "2025-06-15"));

    // 3.9
    [Fact] public void AtOneCalMonthStillWeeksDays() =>
        Assert.Equal("4 weeks, 3 days", SayableAgeFormatter.FormatAgeDefault("2025-05-15", "2025-06-15"));

    // 3.10
    [Fact] public void AtTwoCalMonthsStillWeeksDays() =>
        Assert.Equal("8 weeks, 5 days", SayableAgeFormatter.FormatAgeDefault("2025-04-15", "2025-06-15"));

    // 3.11
    [Fact] public void OneDayBefore3moStillWeeks() =>
        Assert.Equal("13 weeks", SayableAgeFormatter.FormatAgeDefault("2025-03-15", "2025-06-14"));

    // 3.12
    [Fact] public void On3moBirthdaySwitches() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-03-15", "2025-06-15"));

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    [Fact] public void Jan1ToApr1Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-01", "2025-04-01"));

    // 4.2
    [Fact] public void Jan1ToMar31StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-01-01", "2025-03-31");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 4.3
    [Fact] public void Jun15ToSep15Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-09-15"));

    // 4.4
    [Fact] public void Jun15ToSep14StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-09-14");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 4.5
    [Fact] public void Jun15ToDec15Is6mo() =>
        Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-12-15"));

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    [Fact] public void Jan31ToFeb28NonLeap() =>
        Assert.Equal("4 weeks", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-02-28"));

    // 5.2
    [Fact] public void Jan31ToApr30Is3moClamp() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"));

    // 5.3
    [Fact] public void Jan31ToApr29StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-04-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 5.4
    [Fact] public void Feb1ToMay1Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-02-01", "2025-05-01"));

    // 5.5
    [Fact] public void Feb1ToApr30StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-02-01", "2025-04-30");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    [Fact] public void Jan31ToFeb29Leap() =>
        Assert.Equal("4 weeks, 1 day", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-02-29"));

    // 6.2
    [Fact] public void Jan31ToFeb28Leap() =>
        Assert.Equal("4 weeks", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-02-28"));

    // 6.3
    [Fact] public void Jan31ToApr30LeapIs3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-01-31", "2024-04-30"));

    // 6.4
    [Fact] public void Jan30ToFeb29LeapStillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2024-01-30", "2024-02-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 6.5
    [Fact] public void Jan30ToFeb28LeapStillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2024-01-30", "2024-02-28");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    [Fact] public void Mar31ToJun30Is3moClamped() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-03-31", "2025-06-30"));

    // 7.2
    [Fact] public void Mar31ToJun29StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-03-31", "2025-06-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 7.3
    [Fact] public void Aug31ToNov30Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-08-31", "2025-11-30"));

    // 7.4
    [Fact] public void Aug31ToNov29StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2025-08-31", "2025-11-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    [Fact] public void Feb29ToMay29Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2024-05-29"));

    // 8.2
    [Fact] public void Feb29ToMay28StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2024-05-28");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 8.3
    [Fact] public void Feb29_2024ToFeb28_2025Is12mo() =>
        Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2025-02-28"));

    // 8.4
    [Fact] public void Feb29_2024ToMar1_2025Is12mo() =>
        Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-02-29", "2025-03-01"));

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    [Fact] public void ThreeMonthsAtTransition() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-04-15"));

    // 9.2
    [Fact] public void SixMonths() =>
        Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-07-15"));

    // 9.3
    [Fact] public void TwelveMonthsNotOneYear() =>
        Assert.Equal("12 months", SayableAgeFormatter.FormatAgeDefault("2024-06-15", "2025-06-15"));

    // 9.4
    [Fact] public void TwentyThreeMonthsAtUpper() =>
        Assert.Equal("23 months", SayableAgeFormatter.FormatAgeDefault("2024-01-15", "2025-12-15"));

    // 9.5
    [Fact] public void OneDayBeforeBoundary() =>
        Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-07-14"));

    // 9.6
    [Fact] public void CrossingYearBoundary() =>
        Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2024-11-10", "2025-04-10"));

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    [Fact] public void TwoYearsAt24mo() =>
        Assert.Equal("2 years", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-06-15"));

    // 10.2
    [Fact] public void TwoYearsOneMonth() =>
        Assert.Equal("2 years, 1 month", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-07-15"));

    // 10.3
    [Fact] public void TwoYearsSixMonths() =>
        Assert.Equal("2 years, 6 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-12-15"));

    // 10.4
    [Fact] public void TwoYearsElevenMonths() =>
        Assert.Equal("2 years, 11 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2026-05-15"));

    // 10.5
    [Fact] public void OneDayBefore24mo() =>
        Assert.Equal("23 months", SayableAgeFormatter.FormatAgeDefault("2023-06-15", "2025-06-14"));

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    [Fact] public void ThreeYearsExactly() =>
        Assert.Equal("3 years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-06-15"));

    // 11.2
    [Fact] public void ThreeYearsFiveMonths() =>
        Assert.Equal("3 years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-11-15"));

    // 11.3
    [Fact] public void ThreeAndHalfYearsAt3y6m() =>
        Assert.Equal("3\u00BD years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-12-15"));

    // 11.4
    [Fact] public void ThreeAndHalfYearsAt3y11m() =>
        Assert.Equal("3\u00BD years", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2026-05-15"));

    // 11.5
    [Fact] public void FourYearsExactly() =>
        Assert.Equal("4 years", SayableAgeFormatter.FormatAgeDefault("2021-06-15", "2025-06-15"));

    // 11.6
    [Fact] public void FourAndHalfYears() =>
        Assert.Equal("4\u00BD years", SayableAgeFormatter.FormatAgeDefault("2021-06-15", "2025-12-15"));

    // 11.7
    [Fact] public void FiveYears() =>
        Assert.Equal("5 years", SayableAgeFormatter.FormatAgeDefault("2020-06-15", "2025-06-15"));

    // 11.8
    [Fact] public void FiveAndHalfYearsAt5y8m() =>
        Assert.Equal("5\u00BD years", SayableAgeFormatter.FormatAgeDefault("2020-06-15", "2026-02-15"));

    // 11.9
    [Fact] public void SixYears() =>
        Assert.Equal("6 years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2025-06-15"));

    // 11.10
    [Fact] public void SixAndHalfYears() =>
        Assert.Equal("6\u00BD years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2025-12-15"));

    // 11.11
    [Fact] public void SixAndHalfYearsAt6y11m() =>
        Assert.Equal("6\u00BD years", SayableAgeFormatter.FormatAgeDefault("2019-06-15", "2026-05-15"));

    // 11.12
    [Fact] public void OneDayBefore3rdBday() =>
        Assert.Equal("2 years, 11 months", SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-06-14"));

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    [Fact] public void SevenYearsExactly() =>
        Assert.Equal("7 years", SayableAgeFormatter.FormatAgeDefault("2018-06-15", "2025-06-15"));

    // 12.2
    [Fact] public void SevenYearsSixMonthsNoHalf() =>
        Assert.Equal("7 years", SayableAgeFormatter.FormatAgeDefault("2018-03-20", "2025-06-15"));

    // 12.3
    [Fact] public void FortyFiveYears() =>
        Assert.Equal("45 years", SayableAgeFormatter.FormatAgeDefault("1980-01-01", "2025-06-15"));

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    [Fact] public void Dec31ToMar31Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-12-31", "2025-03-31"));

    // 13.2
    [Fact] public void Dec31ToMar30StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2024-12-31", "2025-03-30");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // 13.3
    [Fact] public void Nov30ToFeb28Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2024-11-30", "2025-02-28"));

    // 13.4
    [Fact] public void Nov30ToFeb27StillWeeks()
    {
        var result = SayableAgeFormatter.FormatAgeDefault("2024-11-30", "2025-02-27");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    [Fact] public void Jan31ToApr30Is3mo() =>
        Assert.Equal("3 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"));

    // 14.2
    [Fact] public void Jan31ToMay31Is4mo() =>
        Assert.Equal("4 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-05-31"));

    // 14.3
    [Fact] public void Jan31ToJun30Is5moClamped() =>
        Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-06-30"));

    // 14.4
    [Fact] public void Jan31ToJul1Is5mo() =>
        Assert.Equal("5 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-07-01"));

    // 14.5
    [Fact] public void Jan31ToJul31Is6mo() =>
        Assert.Equal("6 months", SayableAgeFormatter.FormatAgeDefault("2025-01-31", "2025-07-31"));

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    [Fact] public void DefaultAsOfUsesMockedToday()
    {
        SayableAgeFormatter.TimeNow = () => new DateTime(2025, 6, 15);
        Assert.Equal("5 years", SayableAgeFormatter.FormatAgeDefault("2020-01-01")); // 15.1
        Assert.Equal("5 days", SayableAgeFormatter.FormatAgeDefault("2025-06-10")); // 15.2
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.3
    [Fact] public void StageEmptyStringReturnsNull() =>
        Assert.Null(SayableAgeFormatter.FormatStageDefault("", "2025-06-15"));

    // 16.4
    [Fact] public void StageFutureDobReturnsNull() =>
        Assert.Null(SayableAgeFormatter.FormatStageDefault("2025-07-01", "2025-06-15"));

    // 16.5
    [Fact] public void StageExactly500YearsReturnsAdult() =>
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1525-06-15", "2025-06-15"));

    // 16.6
    [Fact] public void Stage501YearsExceedsMaxAge() =>
        Assert.Null(SayableAgeFormatter.FormatStageDefault("1524-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    [Fact] public void StageBornToday() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-15", "2025-06-15"));

    // 17.2
    [Fact] public void StageOneDayOld() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-14", "2025-06-15"));

    // 17.3
    [Fact] public void StageThreeWeeksOld() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-05-25", "2025-06-15"));

    // 17.4
    [Fact] public void StageOneMonthOld() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-05-15", "2025-06-15"));

    // 17.5
    [Fact] public void StageOneMonth29Days() =>
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-04-16", "2025-06-15"));

    // 17.6
    [Fact] public void StageExactly2MonthsBecomesInfant() =>
        Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"));

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    [Fact] public void StageTwoMonths() =>
        Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"));

    // 18.2
    [Fact] public void StageSixMonths() =>
        Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2024-12-15", "2025-06-15"));

    // 18.3
    [Fact] public void StageElevenMonths() =>
        Assert.Equal("Infant", SayableAgeFormatter.FormatStageDefault("2024-07-15", "2025-06-15"));

    // 18.4
    [Fact] public void StageExactly12moBecomesToddler() =>
        Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    [Fact] public void StageTwelveMonths() =>
        Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"));

    // 19.2
    [Fact] public void StageEighteenMonths() =>
        Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2024-01-15", "2025-07-15"));

    // 19.3
    [Fact] public void StageTwentyFourMonths() =>
        Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2023-06-15", "2025-06-15"));

    // 19.4
    [Fact] public void StageThirtyFiveMonths() =>
        Assert.Equal("Toddler", SayableAgeFormatter.FormatStageDefault("2023-06-15", "2026-05-15"));

    // 19.5
    [Fact] public void StageExactly36moBecomesChild() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    [Fact] public void StageThreeYears() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"));

    // 20.2
    [Fact] public void StageFourYears() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2021-06-15", "2025-06-15"));

    // 20.3
    [Fact] public void StageSixYears() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2019-06-15", "2025-06-15"));

    // 20.4
    [Fact] public void StageNineYears() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2016-06-15", "2025-06-15"));

    // 20.5
    [Fact] public void Stage12y11mo() =>
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2013-06-15", "2026-05-15"));

    // 20.6
    [Fact] public void StageExactly13yBecomesTeenager() =>
        Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    [Fact] public void StageThirteenYears() =>
        Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"));

    // 21.2
    [Fact] public void StageFifteenYears() =>
        Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2010-06-15", "2025-06-15"));

    // 21.3
    [Fact] public void Stage17y11mo() =>
        Assert.Equal("Teenager", SayableAgeFormatter.FormatStageDefault("2008-06-15", "2026-05-15"));

    // 21.4
    [Fact] public void StageExactly18yBecomesAdult() =>
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    [Fact] public void StageEighteenYears() =>
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"));

    // 22.2
    [Fact] public void StageTwentyFiveYears() =>
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2000-06-15", "2025-06-15"));

    // 22.3
    [Fact] public void StageFortyFiveYears() =>
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1980-01-01", "2025-06-15"));

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    [Fact] public void StageDefaultAsOf()
    {
        SayableAgeFormatter.TimeNow = () => new DateTime(2025, 6, 15);
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-15")); // 23.1
        Assert.Equal("Child", SayableAgeFormatter.FormatStageDefault("2020-01-01")); // 23.2
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("1980-01-01")); // 23.3
    }

    // ================================================================
    // SayableAgeFormatter class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    [Fact] public void SayableAgeEnglishAllTiers()
    {
        var pt = new SayableAgeFormatter(Locales.EN);
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")); // 24.1
        Assert.Equal("3 days", pt.FormatAge("2025-06-12", "2025-06-15")); // 24.2
        Assert.Equal("1 week, 1 day", pt.FormatAge("2025-06-07", "2025-06-15")); // 24.3
        Assert.Equal("6 months", pt.FormatAge("2025-01-15", "2025-07-15")); // 24.4
        Assert.Equal("2 years, 1 month", pt.FormatAge("2023-06-15", "2025-07-15")); // 24.5
        Assert.Equal("3\u00BD years", pt.FormatAge("2022-06-15", "2025-12-15")); // 24.6
        Assert.Equal("7 years", pt.FormatAge("2018-06-15", "2025-06-15")); // 24.7

        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15")); // 24.8
        Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15")); // 24.9
        Assert.Equal("Toddler", pt.FormatStage("2024-06-15", "2025-06-15")); // 24.10
        Assert.Equal("Child", pt.FormatStage("2022-06-15", "2025-06-15")); // 24.11
        Assert.Equal("Teenager", pt.FormatStage("2012-06-15", "2025-06-15")); // 24.12
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15")); // 24.13

        Assert.Null(pt.FormatAge("")); // 24.14
        Assert.Null(pt.FormatStage("")); // 24.15
    }

    // ================================================================
    // SayableAgeFormatter with Spanish locale
    // ================================================================
    // 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
    [Fact] public void SayableAgeSpanishInlineLocale()
    {
        var es = new AgeLocale(
            "es",
            n => n == 1 ? PluralCategory.One : PluralCategory.Other,
            new Units(
                UnitForms.Plural(new Dictionary<PluralCategory, string> { { PluralCategory.One, "{n} d\u00EDa" }, { PluralCategory.Other, "{n} d\u00EDas" } }),
                UnitForms.Plural(new Dictionary<PluralCategory, string> { { PluralCategory.One, "{n} semana" }, { PluralCategory.Other, "{n} semanas" } }),
                UnitForms.Plural(new Dictionary<PluralCategory, string> { { PluralCategory.One, "{n} mes" }, { PluralCategory.Other, "{n} meses" } }),
                UnitForms.Plural(new Dictionary<PluralCategory, string> { { PluralCategory.One, "{n} a\u00F1o" }, { PluralCategory.Other, "{n} a\u00F1os" } })
            ),
            "{n} y medio",
            ", ",
            "Reci\u00E9n nacido",
            new Stages(
                StageLabel.Gendered("Reci\u00E9n nacido", "Reci\u00E9n nacida"),
                StageLabel.Neutral("Beb\u00E9"),
                StageLabel.Gendered("Ni\u00F1o peque\u00F1o", "Ni\u00F1a peque\u00F1a"),
                StageLabel.Gendered("Ni\u00F1o", "Ni\u00F1a"),
                StageLabel.Neutral("Adolescente"),
                StageLabel.Gendered("Adulto", "Adulta")
            )
        );

        var pt = new SayableAgeFormatter(es);

        Assert.Equal("Reci\u00E9n nacido", pt.FormatAge("2025-06-15", "2025-06-15")); // 25.1
        Assert.Equal("1 d\u00EDa", pt.FormatAge("2025-06-14", "2025-06-15")); // 25.2
        Assert.Equal("3 d\u00EDas", pt.FormatAge("2025-06-12", "2025-06-15")); // 25.3
        Assert.Equal("1 semana", pt.FormatAge("2025-06-08", "2025-06-15")); // 25.4
        Assert.Equal("1 semana, 1 d\u00EDa", pt.FormatAge("2025-06-07", "2025-06-15")); // 25.5
        Assert.Equal("2 semanas, 6 d\u00EDas", pt.FormatAge("2025-05-26", "2025-06-15")); // 25.6
        Assert.Equal("6 meses", pt.FormatAge("2025-01-15", "2025-07-15")); // 25.7
        Assert.Equal("2 a\u00F1os, 1 mes", pt.FormatAge("2023-06-15", "2025-07-15")); // 25.8
        Assert.Equal("2 a\u00F1os, 6 meses", pt.FormatAge("2023-06-15", "2025-12-15")); // 25.9
        Assert.Equal("3 y medio a\u00F1os", pt.FormatAge("2022-06-15", "2025-12-15")); // 25.10
        Assert.Equal("3 a\u00F1os", pt.FormatAge("2022-06-15", "2025-06-15")); // 25.11
        Assert.Equal("7 a\u00F1os", pt.FormatAge("2018-06-15", "2025-06-15")); // 25.12

        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15")); // 25.13
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15")); // 25.14
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15")); // 25.15
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15")); // 25.16
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15")); // 25.17
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15")); // 25.18

        Assert.Null(pt.FormatAge("")); // 25.19
        Assert.Null(pt.FormatStage("")); // 25.20
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    // 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
    [Fact] public void CompactShort()
    {
        var pt = new SayableAgeFormatter(Locales.EN, Compactness.Short);

        Assert.Equal("3 d", pt.FormatAge("2025-06-12", "2025-06-15")); // 26.1
        Assert.Equal("1 wk", pt.FormatAge("2025-06-08", "2025-06-15")); // 26.2
        Assert.Equal("1 wk, 1 d", pt.FormatAge("2025-06-07", "2025-06-15")); // 26.3
        Assert.Equal("6 mo", pt.FormatAge("2025-01-15", "2025-07-15")); // 26.4
        Assert.Equal("2 yr, 1 mo", pt.FormatAge("2023-06-15", "2025-07-15")); // 26.5
        Assert.Equal("3\u00BD yr", pt.FormatAge("2022-06-15", "2025-12-15")); // 26.6
        Assert.Equal("7 yr", pt.FormatAge("2018-06-15", "2025-06-15")); // 26.7
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")); // 26.8
        Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15")); // 26.9
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    // 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
    [Fact] public void CompactCompact()
    {
        var pt = new SayableAgeFormatter(Locales.EN, Compactness.Compact);

        Assert.Equal("3d", pt.FormatAge("2025-06-12", "2025-06-15")); // 27.1
        Assert.Equal("1w", pt.FormatAge("2025-06-08", "2025-06-15")); // 27.2
        Assert.Equal("1w1d", pt.FormatAge("2025-06-07", "2025-06-15")); // 27.3
        Assert.Equal("6m", pt.FormatAge("2025-01-15", "2025-07-15")); // 27.4
        Assert.Equal("2y1m", pt.FormatAge("2023-06-15", "2025-07-15")); // 27.5
        Assert.Equal("3\u00BDy", pt.FormatAge("2022-06-15", "2025-12-15")); // 27.6
        Assert.Equal("7y", pt.FormatAge("2018-06-15", "2025-06-15")); // 27.7
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15")); // 27.8
    }

    // ================================================================
    // All 168 locales exist and have correct codes
    // ================================================================
    [Fact] public void All168LocalesExist()
    {
        Assert.Equal(168, Locales.All.Count);
        string[] expectedCodes = {
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
        };
        foreach (var code in expectedCodes)
        {
            Assert.True(Locales.All.ContainsKey(code), $"Locale {code} should exist");
            Assert.Equal(code, Locales.All[code].Code);
        }
    }

    // ================================================================
    // Smoke test each locale produces non-null output
    // ================================================================
    [Fact] public void AllLocalesProduceOutputForBasicCases()
    {
        foreach (var (code, locale) in Locales.All)
        {
            var pt = new SayableAgeFormatter(locale);

            var justBorn = pt.FormatAge("2025-06-15", "2025-06-15");
            Assert.NotNull(justBorn);
            Assert.NotEmpty(justBorn);

            Assert.NotNull(pt.FormatAge("2025-06-12", "2025-06-15"));
            Assert.NotNull(pt.FormatAge("2025-06-07", "2025-06-15"));
            Assert.NotNull(pt.FormatAge("2025-01-15", "2025-07-15"));
            Assert.NotNull(pt.FormatAge("2023-06-15", "2025-07-15"));
            Assert.NotNull(pt.FormatAge("2022-06-15", "2025-12-15"));
            Assert.NotNull(pt.FormatAge("2018-06-15", "2025-06-15"));
            Assert.NotNull(pt.FormatStage("2020-01-01", "2025-06-15"));
        }
    }

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    [Fact] public void GenderNullDefaultsToMasculineForGenderedLocales()
    {
        var pt = new SayableAgeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15"));
    }

    [Fact] public void GenderMReturnsMasculine()
    {
        var pt = new SayableAgeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15", "m"));
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15", "m"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderFReturnsFeminine()
    {
        var pt = new SayableAgeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacida", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Ni\u00F1a peque\u00F1a", pt.FormatStage("2024-06-15", "2025-06-15", "f"));
        Assert.Equal("Ni\u00F1a", pt.FormatStage("2022-06-15", "2025-06-15", "f"));
        Assert.Equal("Adulta", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderNeutralStagesUnaffectedByGender()
    {
        var pt = new SayableAgeFormatter(Locales.ES);
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15", "f"));
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15", "m"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15", "f"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderHasNoEffectOnNeutralLocales()
    {
        var pt = new SayableAgeFormatter(Locales.EN);
        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderFrenchStages()
    {
        var pt = new SayableAgeFormatter(Locales.FR);
        Assert.Equal("Nouveau-n\u00E9", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Nouveau-n\u00E9e", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Nourrisson", pt.FormatStage("2025-01-15", "2025-06-15", "f"));
        Assert.Equal("Tout-petit", pt.FormatStage("2024-06-15", "2025-06-15", "f"));
        Assert.Equal("Enfant", pt.FormatStage("2022-06-15", "2025-06-15", "f"));
        Assert.Equal("Adolescent", pt.FormatStage("2012-06-15", "2025-06-15", "m"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15", "f"));
        Assert.Equal("Adulte", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderItalianStages()
    {
        var pt = new SayableAgeFormatter(Locales.IT);
        Assert.Equal("Neonato", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Neonata", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Bimbo", pt.FormatStage("2024-06-15", "2025-06-15", "m"));
        Assert.Equal("Bimba", pt.FormatStage("2024-06-15", "2025-06-15", "f"));
        Assert.Equal("Bambino", pt.FormatStage("2022-06-15", "2025-06-15", "m"));
        Assert.Equal("Bambina", pt.FormatStage("2022-06-15", "2025-06-15", "f"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
        Assert.Equal("Adulta", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderArabicAllStages()
    {
        var pt = new SayableAgeFormatter(Locales.AR);
        Assert.Equal("\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("\u062D\u062F\u064A\u062B\u0629 \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("\u0631\u0636\u064A\u0639", pt.FormatStage("2025-01-15", "2025-06-15", "m"));
        Assert.Equal("\u0631\u0636\u064A\u0639\u0629", pt.FormatStage("2025-01-15", "2025-06-15", "f"));
        Assert.Equal("\u0637\u0641\u0644 \u0635\u063A\u064A\u0631", pt.FormatStage("2024-06-15", "2025-06-15", "m"));
        Assert.Equal("\u0637\u0641\u0644\u0629 \u0635\u063A\u064A\u0631\u0629", pt.FormatStage("2024-06-15", "2025-06-15", "f"));
        Assert.Equal("\u0637\u0641\u0644", pt.FormatStage("2022-06-15", "2025-06-15", "m"));
        Assert.Equal("\u0637\u0641\u0644\u0629", pt.FormatStage("2022-06-15", "2025-06-15", "f"));
        Assert.Equal("\u0645\u0631\u0627\u0647\u0642", pt.FormatStage("2012-06-15", "2025-06-15", "m"));
        Assert.Equal("\u0645\u0631\u0627\u0647\u0642\u0629", pt.FormatStage("2012-06-15", "2025-06-15", "f"));
        Assert.Equal("\u0628\u0627\u0644\u063A", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
        Assert.Equal("\u0628\u0627\u0644\u063A\u0629", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderGermanAdultOnly()
    {
        var pt = new SayableAgeFormatter(Locales.DE);
        Assert.Equal("Erwachsener", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
        Assert.Equal("Erwachsene", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
        Assert.Equal("Neugeborenes", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderCompanionMethod()
    {
        Assert.Equal("Newborn", SayableAgeFormatter.FormatStageDefault("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Adult", SayableAgeFormatter.FormatStageDefault("2007-06-15", "2025-06-15", "f"));
    }

    // ================================================================
    // Locale-specific edge cases — new plural rules
    // ================================================================
    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    [Fact] public void HebrewLocaleDualForms()
    {
        var pt = new SayableAgeFormatter(Locales.HE);
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatAge("2025-06-15", "2025-06-15")); // 29.1
        Assert.Equal("\u05D9\u05D5\u05DD 1", pt.FormatAge("2025-06-14", "2025-06-15")); // 29.2
        Assert.Equal("3 \u05D9\u05DE\u05D9\u05DD", pt.FormatAge("2025-06-12", "2025-06-15")); // 29.3
        Assert.Equal("\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD", pt.FormatAge("2025-06-01", "2025-06-15")); // 29.4
        Assert.Equal("3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA", pt.FormatAge("2025-05-25", "2025-06-15")); // 29.5
        Assert.Equal("6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge("2025-01-15", "2025-07-15")); // 29.6
        Assert.Equal("3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge("2025-03-15", "2025-06-15")); // 29.7
        Assert.Equal("\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9 1", pt.FormatAge("2023-06-15", "2025-07-15")); // 29.8
        Assert.Equal("3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9", pt.FormatAge("2022-06-15", "2025-12-15")); // 29.9
        Assert.Equal("7 \u05E9\u05E0\u05D9\u05DD", pt.FormatAge("2018-06-15", "2025-06-15")); // 29.10
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatStage("2025-06-15", "2025-06-15", "m")); // 29.11
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4", pt.FormatStage("2025-06-15", "2025-06-15", "f")); // 29.12
        Assert.Equal("\u05DE\u05D1\u05D5\u05D2\u05E8", pt.FormatStage("2007-06-15", "2025-06-15", "m")); // 29.13
        Assert.Equal("\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA", pt.FormatStage("2007-06-15", "2025-06-15", "f")); // 29.14
    }

    [Fact] public void MacedonianLocaleMod10Mod100Rule()
    {
        var pt = new SayableAgeFormatter(Locales.MK);
        Assert.Equal("\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("1 \u0434\u0435\u043D", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 \u0434\u0435\u043D\u0430", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("6 \u043C\u0435\u0441\u0435\u0446\u0438", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 \u0433\u043E\u0434\u0438\u043D\u0438", pt.FormatAge("2018-06-15", "2025-06-15"));
    }

    [Fact] public void SwahiliLocaleNounClassChanges()
    {
        var pt = new SayableAgeFormatter(Locales.SW);
        Assert.Equal("Mzaliwa mpya", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("siku 1", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("siku 3", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("miezi 6", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("miaka 2, mwezi 1", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("miaka 3 na nusu", pt.FormatAge("2022-06-15", "2025-12-15"));
    }

    [Fact] public void IndonesianLocaleOtherOnly()
    {
        var pt = new SayableAgeFormatter(Locales.ID);
        Assert.Equal("Baru lahir", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("1 hari", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 hari", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("6 bulan", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("3 tahun setengah", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 tahun", pt.FormatAge("2018-06-15", "2025-06-15"));
    }

    [Fact] public void AmharicLocaleEthiopicDelimiter()
    {
        var pt = new SayableAgeFormatter(Locales.AM);
        Assert.Equal("\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("1 \u1240\u1295", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 \u1240\u1293\u1275", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295", pt.FormatAge("2025-06-07", "2025-06-15"));
        Assert.Equal("6 \u12C8\u122B\u1275", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D", pt.FormatAge("2022-06-15", "2025-12-15"));
    }

    // ================================================================
    // Locale lookup by code string
    // ================================================================
    [Fact] public void GetLocaleReturnsEnLocale()
    {
        var loc = Locales.Get("en");
        Assert.NotNull(loc);
        Assert.Equal("en", loc!.Code);
    }

    [Fact] public void GetLocaleReturnsFrLocale()
    {
        var loc = Locales.Get("fr");
        Assert.NotNull(loc);
        Assert.Equal("fr", loc!.Code);
    }

    [Fact] public void GetLocaleReturnsNullForUnknownCode() =>
        Assert.Null(Locales.Get("xx"));

    [Fact] public void GetLocaleReturnsNullForEmptyString() =>
        Assert.Null(Locales.Get(""));

    [Fact] public void GetLocaleIsCaseSensitive() =>
        Assert.Null(Locales.Get("EN"));
}
