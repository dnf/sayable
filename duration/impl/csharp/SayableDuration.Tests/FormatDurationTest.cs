using SayableDurationLib;
using Xunit;

namespace SayableDurationLib.Tests;

public class FormatDurationTest
{
    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    [Fact]
    public void FormatDuration_null_returns_null()
    {
        Assert.Null(SayableDuration.FormatDurationSeconds(-1));
    }

    // 1.2
    [Fact]
    public void FormatDuration_negative_returns_null()
    {
        Assert.Null(SayableDuration.FormatDurationSeconds(-1));
    }

    // 1.3
    [Fact]
    public void FormatSince_null_start_returns_null()
    {
        Assert.Null(SayableDuration.FormatSince(null, "2025-01-15T10:00:00"));
    }

    // 1.4
    [Fact]
    public void FormatUntil_null_target_returns_null()
    {
        Assert.Null(SayableDuration.FormatUntil(null, "2025-01-15T10:00:00"));
    }

    // 1.5
    [Fact]
    public void FormatSince_asOf_before_start_returns_null()
    {
        Assert.Null(SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"));
    }

    // 1.6
    [Fact]
    public void FormatUntil_target_in_the_past_returns_null()
    {
        Assert.Null(SayableDuration.FormatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"));
    }

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    [Fact]
    public void Zero_seconds_is_just_now()
    {
        Assert.Equal("just now", SayableDuration.FormatDurationSeconds(0));
    }

    // 2.2
    [Fact]
    public void One_second()
    {
        Assert.Equal("1 second", SayableDuration.FormatDurationSeconds(1));
    }

    // 2.3
    [Fact]
    public void Seconds_45()
    {
        Assert.Equal("45 seconds", SayableDuration.FormatDurationSeconds(45));
    }

    // 2.4
    [Fact]
    public void Seconds_59()
    {
        Assert.Equal("59 seconds", SayableDuration.FormatDurationSeconds(59));
    }

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    [Fact]
    public void One_minute()
    {
        Assert.Equal("1 minute", SayableDuration.FormatDurationSeconds(60));
    }

    // 3.2
    [Fact]
    public void One_minute_30_seconds()
    {
        Assert.Equal("1 minute, 30 seconds", SayableDuration.FormatDurationSeconds(90));
    }

    // 3.3
    [Fact]
    public void Four_minutes()
    {
        Assert.Equal("4 minutes", SayableDuration.FormatDurationSeconds(240));
    }

    // 3.4
    [Fact]
    public void Four_minutes_30_seconds()
    {
        Assert.Equal("4 minutes, 30 seconds", SayableDuration.FormatDurationSeconds(270));
    }

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    [Fact]
    public void Five_minutes()
    {
        Assert.Equal("5 minutes", SayableDuration.FormatDurationSeconds(300));
    }

    // 4.2
    [Fact]
    public void Minutes_25()
    {
        Assert.Equal("25 minutes", SayableDuration.FormatDurationSeconds(1500));
    }

    // 4.3
    [Fact]
    public void Minutes_59()
    {
        Assert.Equal("59 minutes", SayableDuration.FormatDurationSeconds(3540));
    }

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    [Fact]
    public void One_hour()
    {
        Assert.Equal("1 hour", SayableDuration.FormatDurationSeconds(3600));
    }

    // 5.2
    [Fact]
    public void One_and_half_hours()
    {
        Assert.Equal("1\u00BD hours", SayableDuration.FormatDurationSeconds(5400));
    }

    // 5.3
    [Fact]
    public void Two_hours_15_minutes()
    {
        Assert.Equal("2 hours, 15 minutes", SayableDuration.FormatDurationSeconds(8100));
    }

    // 5.4
    [Fact]
    public void Five_hours()
    {
        Assert.Equal("5 hours", SayableDuration.FormatDurationSeconds(18000));
    }

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    [Fact]
    public void Eight_hours()
    {
        Assert.Equal("8 hours", SayableDuration.FormatDurationSeconds(28800));
    }

    // 6.2
    [Fact]
    public void TwentyThree_hours()
    {
        Assert.Equal("23 hours", SayableDuration.FormatDurationSeconds(82800));
    }

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    [Fact]
    public void One_day()
    {
        Assert.Equal("1 day", SayableDuration.FormatDurationSeconds(86400));
    }

    // 7.2
    [Fact]
    public void One_day_3_hours()
    {
        Assert.Equal("1 day, 3 hours", SayableDuration.FormatDurationSeconds(97200));
    }

    // 7.3
    [Fact]
    public void One_and_half_days()
    {
        Assert.Equal("1\u00BD days", SayableDuration.FormatDurationSeconds(129600));
    }

    // 7.4
    [Fact]
    public void Five_days()
    {
        Assert.Equal("5 days", SayableDuration.FormatDurationSeconds(432000));
    }

    // 7.5
    [Fact]
    public void Two_days()
    {
        Assert.Equal("2 days", SayableDuration.FormatDurationSeconds(172800));
    }

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    [Fact]
    public void One_week()
    {
        Assert.Equal("1 week", SayableDuration.FormatDurationSeconds(604800));
    }

    // 8.2
    [Fact]
    public void Two_weeks_1_day()
    {
        Assert.Equal("2 weeks, 1 day", SayableDuration.FormatDurationSeconds(1296000));
    }

    // 8.3
    [Fact]
    public void Four_weeks()
    {
        Assert.Equal("4 weeks", SayableDuration.FormatDurationSeconds(2419200));
    }

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    [Fact]
    public void One_month()
    {
        Assert.Equal("1 month", SayableDuration.FormatDurationSeconds(2678400));
    }

    // 9.2
    [Fact]
    public void Three_months()
    {
        Assert.Equal("3 months", SayableDuration.FormatDurationSeconds(7884000));
    }

    // 9.3
    [Fact]
    public void One_year()
    {
        Assert.Equal("1 year", SayableDuration.FormatDurationSeconds(31536000));
    }

    // 9.4
    [Fact]
    public void One_year_3_months()
    {
        Assert.Equal("1 year, 3 months", SayableDuration.FormatDurationSeconds(39420000));
    }

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    [Fact]
    public void ISO_one_and_half_hours()
    {
        Assert.Equal("1\u00BD hours",
            SayableDuration.FormatDurationIso("2025-01-15T10:00:00", "2025-01-15T11:30:00"));
    }

    // 10.2
    [Fact]
    public void ISO_45_minutes()
    {
        Assert.Equal("45 minutes",
            SayableDuration.FormatDurationIso("2025-01-15T10:00:00", "2025-01-15T10:45:00"));
    }

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    [Fact]
    public void Since_just_now()
    {
        Assert.Equal("just now",
            SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00"));
    }

    // 11.2
    [Fact]
    public void Since_30_seconds_ago()
    {
        Assert.Equal("30 seconds ago",
            SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30"));
    }

    // 11.3
    [Fact]
    public void Since_45_minutes_ago()
    {
        Assert.Equal("45 minutes ago",
            SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00"));
    }

    // 11.4
    [Fact]
    public void Since_3_hours_ago()
    {
        Assert.Equal("3 hours ago",
            SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00"));
    }

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    [Fact]
    public void Until_just_now()
    {
        Assert.Equal("just now",
            SayableDuration.FormatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00"));
    }

    // 12.2
    [Fact]
    public void Until_in_20_minutes()
    {
        Assert.Equal("in 20 minutes",
            SayableDuration.FormatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00"));
    }

    // 12.3
    [Fact]
    public void Until_in_3_hours()
    {
        Assert.Equal("in 3 hours",
            SayableDuration.FormatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00"));
    }

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    [Fact]
    public void German_1_hour()
    {
        var sd = new SayableDuration(Locales.DE);
        Assert.Equal("1 Stunde", sd.FormatDuration(3600));
    }

    // 13.2
    [Fact]
    public void German_since_5_minutes()
    {
        var sd = new SayableDuration(Locales.DE);
        Assert.Equal("vor 5 Minuten",
            sd.Since("2025-01-15T10:00:00", "2025-01-15T10:05:00"));
    }

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    [Fact]
    public void French_2_hours()
    {
        var sd = new SayableDuration(Locales.FR);
        Assert.Equal("2 heures", sd.FormatDuration(7200));
    }

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    [Fact]
    public void Japanese_2_minutes()
    {
        var sd = new SayableDuration(Locales.JA);
        Assert.Equal("2\u5206", sd.FormatDuration(120));
    }

    // 15.2
    [Fact]
    public void Japanese_since_1_hour()
    {
        var sd = new SayableDuration(Locales.JA);
        Assert.Equal("1\u6642\u9593\u524D",
            sd.Since("2025-01-15T10:00:00", "2025-01-15T11:00:00"));
    }

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    [Fact]
    public void Short_1_hour()
    {
        var sd = new SayableDuration(Locales.EN, Compactness.Short);
        Assert.Equal("1h", sd.FormatDuration(3600));
    }

    // 16.2
    [Fact]
    public void Short_1_minute_30_seconds()
    {
        var sd = new SayableDuration(Locales.EN, Compactness.Short);
        Assert.Equal("1m, 30s", sd.FormatDuration(90));
    }

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    [Fact]
    public void Compact_1_hour()
    {
        var sd = new SayableDuration(Locales.EN, Compactness.Compact);
        Assert.Equal("1h", sd.FormatDuration(3600));
    }

    // 17.2
    [Fact]
    public void Compact_1_minute_30_seconds()
    {
        var sd = new SayableDuration(Locales.EN, Compactness.Compact);
        Assert.Equal("1m30s", sd.FormatDuration(90));
    }
}
