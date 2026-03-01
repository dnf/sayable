using System;
using System.Collections.Generic;
using Xunit;

namespace ParentTimeLib.Tests;

public class FormatAgeTest : IDisposable
{
    public void Dispose()
    {
        ParentTimeFormatter.TimeNow = () => DateTime.Today;
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    [Fact] public void EmptyStringReturnsNull() =>
        Assert.Null(ParentTimeFormatter.FormatAgeDefault("", "2025-06-15"));

    [Fact] public void FutureDobReturnsNull() =>
        Assert.Null(ParentTimeFormatter.FormatAgeDefault("2025-07-01", "2025-06-15"));

    [Fact] public void Exactly500YearsIsAllowed() =>
        Assert.Equal("500 years", ParentTimeFormatter.FormatAgeDefault("1525-06-15", "2025-06-15"));

    [Fact] public void Years501ExceedsMaxAge() =>
        Assert.Null(ParentTimeFormatter.FormatAgeDefault("1524-06-15", "2025-06-15"));

    [Fact] public void Years1000ExceedsMaxAge() =>
        Assert.Null(ParentTimeFormatter.FormatAgeDefault("1025-06-15", "2025-06-15"));

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    [Fact] public void BornToday() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatAgeDefault("2025-06-15", "2025-06-15"));

    [Fact] public void OneDayAgo() =>
        Assert.Equal("1 day", ParentTimeFormatter.FormatAgeDefault("2025-06-14", "2025-06-15"));

    [Fact] public void ThreeDaysAgo() =>
        Assert.Equal("3 days", ParentTimeFormatter.FormatAgeDefault("2025-06-12", "2025-06-15"));

    [Fact] public void SixDaysAgo() =>
        Assert.Equal("6 days", ParentTimeFormatter.FormatAgeDefault("2025-06-09", "2025-06-15"));

    [Fact] public void SevenDaysBecomesOneWeek() =>
        Assert.Equal("1 week", ParentTimeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"));

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    [Fact] public void SevenDaysIsOneWeek() =>
        Assert.Equal("1 week", ParentTimeFormatter.FormatAgeDefault("2025-06-08", "2025-06-15"));

    [Fact] public void EightDaysIsOneWeekOneDay() =>
        Assert.Equal("1 week, 1 day", ParentTimeFormatter.FormatAgeDefault("2025-06-07", "2025-06-15"));

    [Fact] public void NineDaysIsOneWeekTwoDays() =>
        Assert.Equal("1 week, 2 days", ParentTimeFormatter.FormatAgeDefault("2025-06-06", "2025-06-15"));

    [Fact] public void ThirteenDaysIsOneWeekSixDays() =>
        Assert.Equal("1 week, 6 days", ParentTimeFormatter.FormatAgeDefault("2025-06-02", "2025-06-15"));

    [Fact] public void FourteenDaysIsTwoWeeks() =>
        Assert.Equal("2 weeks", ParentTimeFormatter.FormatAgeDefault("2025-06-01", "2025-06-15"));

    [Fact] public void FifteenDaysIsTwoWeeksOneDay() =>
        Assert.Equal("2 weeks, 1 day", ParentTimeFormatter.FormatAgeDefault("2025-05-31", "2025-06-15"));

    [Fact] public void TwentyDaysIsTwoWeeksSixDays() =>
        Assert.Equal("2 weeks, 6 days", ParentTimeFormatter.FormatAgeDefault("2025-05-26", "2025-06-15"));

    [Fact] public void TwentyOneDaysIsThreeWeeks() =>
        Assert.Equal("3 weeks", ParentTimeFormatter.FormatAgeDefault("2025-05-25", "2025-06-15"));

    [Fact] public void AtOneCalMonthStillWeeksDays() =>
        Assert.Equal("4 weeks, 3 days", ParentTimeFormatter.FormatAgeDefault("2025-05-15", "2025-06-15"));

    [Fact] public void AtTwoCalMonthsStillWeeksDays() =>
        Assert.Equal("8 weeks, 5 days", ParentTimeFormatter.FormatAgeDefault("2025-04-15", "2025-06-15"));

    [Fact] public void OneDayBefore3moStillWeeks() =>
        Assert.Equal("13 weeks", ParentTimeFormatter.FormatAgeDefault("2025-03-15", "2025-06-14"));

    [Fact] public void On3moBirthdaySwitches() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-03-15", "2025-06-15"));

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    [Fact] public void Jan1ToApr1Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-01-01", "2025-04-01"));

    [Fact] public void Jan1ToMar31StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-01-01", "2025-03-31");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Jun15ToSep15Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-06-15", "2025-09-15"));

    [Fact] public void Jun15ToSep14StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-06-15", "2025-09-14");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Jun15ToDec15Is6mo() =>
        Assert.Equal("6 months", ParentTimeFormatter.FormatAgeDefault("2025-06-15", "2025-12-15"));

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    [Fact] public void Jan31ToFeb28NonLeap() =>
        Assert.Equal("4 weeks", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-02-28"));

    [Fact] public void Jan31ToApr30Is3moClamp() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"));

    [Fact] public void Jan31ToApr29StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-04-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Feb1ToMay1Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-02-01", "2025-05-01"));

    [Fact] public void Feb1ToApr30StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-02-01", "2025-04-30");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    [Fact] public void Jan31ToFeb29Leap() =>
        Assert.Equal("4 weeks, 1 day", ParentTimeFormatter.FormatAgeDefault("2024-01-31", "2024-02-29"));

    [Fact] public void Jan31ToFeb28Leap() =>
        Assert.Equal("4 weeks", ParentTimeFormatter.FormatAgeDefault("2024-01-31", "2024-02-28"));

    [Fact] public void Jan31ToApr30LeapIs3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2024-01-31", "2024-04-30"));

    [Fact] public void Jan30ToFeb29LeapStillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2024-01-30", "2024-02-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Jan30ToFeb28LeapStillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2024-01-30", "2024-02-28");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    [Fact] public void Mar31ToJun30Is3moClamped() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-03-31", "2025-06-30"));

    [Fact] public void Mar31ToJun29StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-03-31", "2025-06-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Aug31ToNov30Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-08-31", "2025-11-30"));

    [Fact] public void Aug31ToNov29StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2025-08-31", "2025-11-29");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    [Fact] public void Feb29ToMay29Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2024-02-29", "2024-05-29"));

    [Fact] public void Feb29ToMay28StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2024-02-29", "2024-05-28");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Feb29_2024ToFeb28_2025Is12mo() =>
        Assert.Equal("12 months", ParentTimeFormatter.FormatAgeDefault("2024-02-29", "2025-02-28"));

    [Fact] public void Feb29_2024ToMar1_2025Is12mo() =>
        Assert.Equal("12 months", ParentTimeFormatter.FormatAgeDefault("2024-02-29", "2025-03-01"));

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    [Fact] public void ThreeMonthsAtTransition() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-01-15", "2025-04-15"));

    [Fact] public void SixMonths() =>
        Assert.Equal("6 months", ParentTimeFormatter.FormatAgeDefault("2025-01-15", "2025-07-15"));

    [Fact] public void TwelveMonthsNotOneYear() =>
        Assert.Equal("12 months", ParentTimeFormatter.FormatAgeDefault("2024-06-15", "2025-06-15"));

    [Fact] public void TwentyThreeMonthsAtUpper() =>
        Assert.Equal("23 months", ParentTimeFormatter.FormatAgeDefault("2024-01-15", "2025-12-15"));

    [Fact] public void OneDayBeforeBoundary() =>
        Assert.Equal("5 months", ParentTimeFormatter.FormatAgeDefault("2025-01-15", "2025-07-14"));

    [Fact] public void CrossingYearBoundary() =>
        Assert.Equal("5 months", ParentTimeFormatter.FormatAgeDefault("2024-11-10", "2025-04-10"));

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    [Fact] public void TwoYearsAt24mo() =>
        Assert.Equal("2 years", ParentTimeFormatter.FormatAgeDefault("2023-06-15", "2025-06-15"));

    [Fact] public void TwoYearsOneMonth() =>
        Assert.Equal("2 years, 1 month", ParentTimeFormatter.FormatAgeDefault("2023-06-15", "2025-07-15"));

    [Fact] public void TwoYearsSixMonths() =>
        Assert.Equal("2 years, 6 months", ParentTimeFormatter.FormatAgeDefault("2023-06-15", "2025-12-15"));

    [Fact] public void TwoYearsElevenMonths() =>
        Assert.Equal("2 years, 11 months", ParentTimeFormatter.FormatAgeDefault("2023-06-15", "2026-05-15"));

    [Fact] public void OneDayBefore24mo() =>
        Assert.Equal("23 months", ParentTimeFormatter.FormatAgeDefault("2023-06-15", "2025-06-14"));

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    [Fact] public void ThreeYearsExactly() =>
        Assert.Equal("3 years", ParentTimeFormatter.FormatAgeDefault("2022-06-15", "2025-06-15"));

    [Fact] public void ThreeYearsFiveMonths() =>
        Assert.Equal("3 years", ParentTimeFormatter.FormatAgeDefault("2022-06-15", "2025-11-15"));

    [Fact] public void ThreeAndHalfYearsAt3y6m() =>
        Assert.Equal("3\u00BD years", ParentTimeFormatter.FormatAgeDefault("2022-06-15", "2025-12-15"));

    [Fact] public void ThreeAndHalfYearsAt3y11m() =>
        Assert.Equal("3\u00BD years", ParentTimeFormatter.FormatAgeDefault("2022-06-15", "2026-05-15"));

    [Fact] public void FourYearsExactly() =>
        Assert.Equal("4 years", ParentTimeFormatter.FormatAgeDefault("2021-06-15", "2025-06-15"));

    [Fact] public void FourAndHalfYears() =>
        Assert.Equal("4\u00BD years", ParentTimeFormatter.FormatAgeDefault("2021-06-15", "2025-12-15"));

    [Fact] public void FiveYears() =>
        Assert.Equal("5 years", ParentTimeFormatter.FormatAgeDefault("2020-06-15", "2025-06-15"));

    [Fact] public void FiveAndHalfYearsAt5y8m() =>
        Assert.Equal("5\u00BD years", ParentTimeFormatter.FormatAgeDefault("2020-06-15", "2026-02-15"));

    [Fact] public void SixYears() =>
        Assert.Equal("6 years", ParentTimeFormatter.FormatAgeDefault("2019-06-15", "2025-06-15"));

    [Fact] public void SixAndHalfYears() =>
        Assert.Equal("6\u00BD years", ParentTimeFormatter.FormatAgeDefault("2019-06-15", "2025-12-15"));

    [Fact] public void SixAndHalfYearsAt6y11m() =>
        Assert.Equal("6\u00BD years", ParentTimeFormatter.FormatAgeDefault("2019-06-15", "2026-05-15"));

    [Fact] public void OneDayBefore3rdBday() =>
        Assert.Equal("2 years, 11 months", ParentTimeFormatter.FormatAgeDefault("2022-06-15", "2025-06-14"));

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    [Fact] public void SevenYearsExactly() =>
        Assert.Equal("7 years", ParentTimeFormatter.FormatAgeDefault("2018-06-15", "2025-06-15"));

    [Fact] public void SevenYearsSixMonthsNoHalf() =>
        Assert.Equal("7 years", ParentTimeFormatter.FormatAgeDefault("2018-03-20", "2025-06-15"));

    [Fact] public void FortyFiveYears() =>
        Assert.Equal("45 years", ParentTimeFormatter.FormatAgeDefault("1980-01-01", "2025-06-15"));

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    [Fact] public void Dec31ToMar31Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2024-12-31", "2025-03-31"));

    [Fact] public void Dec31ToMar30StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2024-12-31", "2025-03-30");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    [Fact] public void Nov30ToFeb28Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2024-11-30", "2025-02-28"));

    [Fact] public void Nov30ToFeb27StillWeeks()
    {
        var result = ParentTimeFormatter.FormatAgeDefault("2024-11-30", "2025-02-27");
        Assert.NotNull(result);
        Assert.Contains("weeks", result);
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    [Fact] public void Jan31ToApr30Is3mo() =>
        Assert.Equal("3 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-04-30"));

    [Fact] public void Jan31ToMay31Is4mo() =>
        Assert.Equal("4 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-05-31"));

    [Fact] public void Jan31ToJun30Is5moClamped() =>
        Assert.Equal("5 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-06-30"));

    [Fact] public void Jan31ToJul1Is5mo() =>
        Assert.Equal("5 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-07-01"));

    [Fact] public void Jan31ToJul31Is6mo() =>
        Assert.Equal("6 months", ParentTimeFormatter.FormatAgeDefault("2025-01-31", "2025-07-31"));

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    [Fact] public void DefaultAsOfUsesMockedToday()
    {
        ParentTimeFormatter.TimeNow = () => new DateTime(2025, 6, 15);
        Assert.Equal("5 years", ParentTimeFormatter.FormatAgeDefault("2020-01-01"));
        Assert.Equal("5 days", ParentTimeFormatter.FormatAgeDefault("2025-06-10"));
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    [Fact] public void StageEmptyStringReturnsNull() =>
        Assert.Null(ParentTimeFormatter.FormatStageDefault("", "2025-06-15"));

    [Fact] public void StageFutureDobReturnsNull() =>
        Assert.Null(ParentTimeFormatter.FormatStageDefault("2025-07-01", "2025-06-15"));

    [Fact] public void StageExactly500YearsReturnsAdult() =>
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("1525-06-15", "2025-06-15"));

    [Fact] public void Stage501YearsExceedsMaxAge() =>
        Assert.Null(ParentTimeFormatter.FormatStageDefault("1524-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    [Fact] public void StageBornToday() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-06-15", "2025-06-15"));

    [Fact] public void StageOneDayOld() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-06-14", "2025-06-15"));

    [Fact] public void StageThreeWeeksOld() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-05-25", "2025-06-15"));

    [Fact] public void StageOneMonthOld() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-05-15", "2025-06-15"));

    [Fact] public void StageOneMonth29Days() =>
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-04-16", "2025-06-15"));

    [Fact] public void StageExactly2MonthsBecomesInfant() =>
        Assert.Equal("Infant", ParentTimeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"));

    // ================================================================
    // formatStage -- infant
    // ================================================================
    [Fact] public void StageTwoMonths() =>
        Assert.Equal("Infant", ParentTimeFormatter.FormatStageDefault("2025-04-15", "2025-06-15"));

    [Fact] public void StageSixMonths() =>
        Assert.Equal("Infant", ParentTimeFormatter.FormatStageDefault("2024-12-15", "2025-06-15"));

    [Fact] public void StageElevenMonths() =>
        Assert.Equal("Infant", ParentTimeFormatter.FormatStageDefault("2024-07-15", "2025-06-15"));

    [Fact] public void StageExactly12moBecomesToddler() =>
        Assert.Equal("Toddler", ParentTimeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    [Fact] public void StageTwelveMonths() =>
        Assert.Equal("Toddler", ParentTimeFormatter.FormatStageDefault("2024-06-15", "2025-06-15"));

    [Fact] public void StageEighteenMonths() =>
        Assert.Equal("Toddler", ParentTimeFormatter.FormatStageDefault("2024-01-15", "2025-07-15"));

    [Fact] public void StageTwentyFourMonths() =>
        Assert.Equal("Toddler", ParentTimeFormatter.FormatStageDefault("2023-06-15", "2025-06-15"));

    [Fact] public void StageThirtyFiveMonths() =>
        Assert.Equal("Toddler", ParentTimeFormatter.FormatStageDefault("2023-06-15", "2026-05-15"));

    [Fact] public void StageExactly36moBecomesChild() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- child
    // ================================================================
    [Fact] public void StageThreeYears() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2022-06-15", "2025-06-15"));

    [Fact] public void StageFourYears() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2021-06-15", "2025-06-15"));

    [Fact] public void StageSixYears() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2019-06-15", "2025-06-15"));

    [Fact] public void StageNineYears() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2016-06-15", "2025-06-15"));

    [Fact] public void Stage12y11mo() =>
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2013-06-15", "2026-05-15"));

    [Fact] public void StageExactly13yBecomesTeenager() =>
        Assert.Equal("Teenager", ParentTimeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    [Fact] public void StageThirteenYears() =>
        Assert.Equal("Teenager", ParentTimeFormatter.FormatStageDefault("2012-06-15", "2025-06-15"));

    [Fact] public void StageFifteenYears() =>
        Assert.Equal("Teenager", ParentTimeFormatter.FormatStageDefault("2010-06-15", "2025-06-15"));

    [Fact] public void Stage17y11mo() =>
        Assert.Equal("Teenager", ParentTimeFormatter.FormatStageDefault("2008-06-15", "2026-05-15"));

    [Fact] public void StageExactly18yBecomesAdult() =>
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"));

    // ================================================================
    // formatStage -- adult
    // ================================================================
    [Fact] public void StageEighteenYears() =>
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("2007-06-15", "2025-06-15"));

    [Fact] public void StageTwentyFiveYears() =>
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("2000-06-15", "2025-06-15"));

    [Fact] public void StageFortyFiveYears() =>
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("1980-01-01", "2025-06-15"));

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    [Fact] public void StageDefaultAsOf()
    {
        ParentTimeFormatter.TimeNow = () => new DateTime(2025, 6, 15);
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-06-15"));
        Assert.Equal("Child", ParentTimeFormatter.FormatStageDefault("2020-01-01"));
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("1980-01-01"));
    }

    // ================================================================
    // ParentTimeFormatter class with English locale
    // ================================================================
    [Fact] public void ParentTimeEnglishAllTiers()
    {
        var pt = new ParentTimeFormatter(Locales.EN);
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("3 days", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("1 week, 1 day", pt.FormatAge("2025-06-07", "2025-06-15"));
        Assert.Equal("6 months", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("2 years, 1 month", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("3\u00BD years", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 years", pt.FormatAge("2018-06-15", "2025-06-15"));

        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15"));
        Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15"));
        Assert.Equal("Toddler", pt.FormatStage("2024-06-15", "2025-06-15"));
        Assert.Equal("Child", pt.FormatStage("2022-06-15", "2025-06-15"));
        Assert.Equal("Teenager", pt.FormatStage("2012-06-15", "2025-06-15"));
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15"));

        Assert.Null(pt.FormatAge(""));
        Assert.Null(pt.FormatStage(""));
    }

    // ================================================================
    // ParentTimeFormatter with Spanish locale
    // ================================================================
    [Fact] public void ParentTimeSpanishInlineLocale()
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

        var pt = new ParentTimeFormatter(es);

        Assert.Equal("Reci\u00E9n nacido", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("1 d\u00EDa", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 d\u00EDas", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("1 semana", pt.FormatAge("2025-06-08", "2025-06-15"));
        Assert.Equal("1 semana, 1 d\u00EDa", pt.FormatAge("2025-06-07", "2025-06-15"));
        Assert.Equal("2 semanas, 6 d\u00EDas", pt.FormatAge("2025-05-26", "2025-06-15"));
        Assert.Equal("6 meses", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("2 a\u00F1os, 1 mes", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("2 a\u00F1os, 6 meses", pt.FormatAge("2023-06-15", "2025-12-15"));
        Assert.Equal("3 y medio a\u00F1os", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("3 a\u00F1os", pt.FormatAge("2022-06-15", "2025-06-15"));
        Assert.Equal("7 a\u00F1os", pt.FormatAge("2018-06-15", "2025-06-15"));

        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15"));
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15"));

        Assert.Null(pt.FormatAge(""));
        Assert.Null(pt.FormatStage(""));
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    [Fact] public void CompactShort()
    {
        var pt = new ParentTimeFormatter(Locales.EN, Compactness.Short);

        Assert.Equal("3 d", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("1 wk", pt.FormatAge("2025-06-08", "2025-06-15"));
        Assert.Equal("1 wk, 1 d", pt.FormatAge("2025-06-07", "2025-06-15"));
        Assert.Equal("6 mo", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("2 yr, 1 mo", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("3\u00BD yr", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 yr", pt.FormatAge("2018-06-15", "2025-06-15"));
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("Infant", pt.FormatStage("2025-01-15", "2025-06-15"));
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    [Fact] public void CompactCompact()
    {
        var pt = new ParentTimeFormatter(Locales.EN, Compactness.Compact);

        Assert.Equal("3d", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("1w", pt.FormatAge("2025-06-08", "2025-06-15"));
        Assert.Equal("1w1d", pt.FormatAge("2025-06-07", "2025-06-15"));
        Assert.Equal("6m", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("2y1m", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("3\u00BDy", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7y", pt.FormatAge("2018-06-15", "2025-06-15"));
        Assert.Equal("Newborn", pt.FormatAge("2025-06-15", "2025-06-15"));
    }

    // ================================================================
    // All 71 locales exist and have correct codes
    // ================================================================
    [Fact] public void All71LocalesExist()
    {
        Assert.Equal(71, Locales.All.Count);
        string[] expectedCodes = {
            "am", "ar", "az", "bg", "bn", "br", "bs", "ca", "cs", "cy",
            "da", "de", "el", "en", "es", "et", "eu", "fa", "fi", "fil",
            "fr", "ga", "gd", "gu", "gv", "he", "hi", "hr", "hu", "id",
            "it", "ja", "jv", "ka", "kk", "km", "ko", "kw", "lt", "lv",
            "mk", "mr", "ms", "mt", "my", "nb", "ne", "nl", "pa", "pl",
            "pt", "ro", "ru", "shi", "si", "sk", "sl", "sq", "sr", "sv",
            "sw", "ta", "te", "th", "tr", "tzm", "uk", "ur", "uz", "vi",
            "zh"
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
            var pt = new ParentTimeFormatter(locale);

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
        var pt = new ParentTimeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15"));
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15"));
    }

    [Fact] public void GenderMReturnsMasculine()
    {
        var pt = new ParentTimeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacido", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Ni\u00F1o peque\u00F1o", pt.FormatStage("2024-06-15", "2025-06-15", "m"));
        Assert.Equal("Ni\u00F1o", pt.FormatStage("2022-06-15", "2025-06-15", "m"));
        Assert.Equal("Adulto", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderFReturnsFeminine()
    {
        var pt = new ParentTimeFormatter(Locales.ES);
        Assert.Equal("Reci\u00E9n nacida", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Ni\u00F1a peque\u00F1a", pt.FormatStage("2024-06-15", "2025-06-15", "f"));
        Assert.Equal("Ni\u00F1a", pt.FormatStage("2022-06-15", "2025-06-15", "f"));
        Assert.Equal("Adulta", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderNeutralStagesUnaffectedByGender()
    {
        var pt = new ParentTimeFormatter(Locales.ES);
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15", "f"));
        Assert.Equal("Beb\u00E9", pt.FormatStage("2025-01-15", "2025-06-15", "m"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15", "f"));
        Assert.Equal("Adolescente", pt.FormatStage("2012-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderHasNoEffectOnNeutralLocales()
    {
        var pt = new ParentTimeFormatter(Locales.EN);
        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Newborn", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
        Assert.Equal("Adult", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
    }

    [Fact] public void GenderFrenchStages()
    {
        var pt = new ParentTimeFormatter(Locales.FR);
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
        var pt = new ParentTimeFormatter(Locales.IT);
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
        var pt = new ParentTimeFormatter(Locales.AR);
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
        var pt = new ParentTimeFormatter(Locales.DE);
        Assert.Equal("Erwachsener", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
        Assert.Equal("Erwachsene", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
        Assert.Equal("Neugeborenes", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
    }

    [Fact] public void GenderCompanionMethod()
    {
        Assert.Equal("Newborn", ParentTimeFormatter.FormatStageDefault("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("Adult", ParentTimeFormatter.FormatStageDefault("2007-06-15", "2025-06-15", "f"));
    }

    // ================================================================
    // Locale-specific edge cases — new plural rules
    // ================================================================
    [Fact] public void HebrewLocaleDualForms()
    {
        var pt = new ParentTimeFormatter(Locales.HE);
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("\u05D9\u05D5\u05DD 1", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 \u05D9\u05DE\u05D9\u05DD", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD", pt.FormatAge("2025-06-01", "2025-06-15"));
        Assert.Equal("3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA", pt.FormatAge("2025-05-25", "2025-06-15"));
        Assert.Equal("6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge("2025-03-15", "2025-06-15"));
        Assert.Equal("\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9 1", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 \u05E9\u05E0\u05D9\u05DD", pt.FormatAge("2018-06-15", "2025-06-15"));
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatStage("2025-06-15", "2025-06-15", "m"));
        Assert.Equal("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4", pt.FormatStage("2025-06-15", "2025-06-15", "f"));
        Assert.Equal("\u05DE\u05D1\u05D5\u05D2\u05E8", pt.FormatStage("2007-06-15", "2025-06-15", "m"));
        Assert.Equal("\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA", pt.FormatStage("2007-06-15", "2025-06-15", "f"));
    }

    [Fact] public void MacedonianLocaleMod10Mod100Rule()
    {
        var pt = new ParentTimeFormatter(Locales.MK);
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
        var pt = new ParentTimeFormatter(Locales.SW);
        Assert.Equal("Mzaliwa mpya", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("siku 1", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("siku 3", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("miezi 6", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("miaka 2, mwezi 1", pt.FormatAge("2023-06-15", "2025-07-15"));
        Assert.Equal("miaka 3 na nusu", pt.FormatAge("2022-06-15", "2025-12-15"));
    }

    [Fact] public void IndonesianLocaleOtherOnly()
    {
        var pt = new ParentTimeFormatter(Locales.ID);
        Assert.Equal("Baru lahir", pt.FormatAge("2025-06-15", "2025-06-15"));
        Assert.Equal("1 hari", pt.FormatAge("2025-06-14", "2025-06-15"));
        Assert.Equal("3 hari", pt.FormatAge("2025-06-12", "2025-06-15"));
        Assert.Equal("6 bulan", pt.FormatAge("2025-01-15", "2025-07-15"));
        Assert.Equal("3 tahun setengah", pt.FormatAge("2022-06-15", "2025-12-15"));
        Assert.Equal("7 tahun", pt.FormatAge("2018-06-15", "2025-06-15"));
    }

    [Fact] public void AmharicLocaleEthiopicDelimiter()
    {
        var pt = new ParentTimeFormatter(Locales.AM);
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
