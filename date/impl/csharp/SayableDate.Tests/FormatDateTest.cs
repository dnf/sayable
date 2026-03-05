using SayableDateLib;
using Xunit;

namespace SayableDateLib.Tests;

public class FormatDateTest
{
    // ── Section 1: Null / edge cases ────────────────────────────────────

    // 1.1
    [Fact]
    public void FormatDate_null_returns_null()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Null(f.Format(null));
    }

    // 1.2
    [Fact]
    public void FormatDate_empty_returns_null()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Null(f.Format(""));
    }

    // 1.3
    [Fact]
    public void FormatDate_invalid_returns_null()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Null(f.Format("invalid"));
    }

    // 1.4
    [Fact]
    public void FormatRelative_null_asOf_returns_null()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Null(f.Relative("2025-03-15", null));
    }

    // 1.5
    [Fact]
    public void FormatRelative_null_date_returns_null()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Null(f.Relative(null, "2025-03-15"));
    }

    // ── Section 2: format_date — normal compactness (English) ───────────

    // 2.1
    [Fact]
    public void FormatDate_March_15th()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("March 15th", f.Format("2025-03-15"));
    }

    // 2.2
    [Fact]
    public void FormatDate_January_1st()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("January 1st", f.Format("2025-01-01"));
    }

    // 2.3
    [Fact]
    public void FormatDate_May_22nd()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("May 22nd", f.Format("2025-05-22"));
    }

    // 2.4
    [Fact]
    public void FormatDate_July_3rd()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("July 3rd", f.Format("2025-07-03"));
    }

    // 2.5
    [Fact]
    public void FormatDate_December_31st()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("December 31st", f.Format("2025-12-31"));
    }

    // 2.6
    [Fact]
    public void FormatDate_June_11th()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("June 11th", f.Format("2025-06-11"));
    }

    // 2.7
    [Fact]
    public void FormatDate_ISO_datetime_input()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("March 15th", f.Format("2025-03-15T14:30:00"));
    }

    // ── Section 3: format_date — short compactness (English) ────────────

    // 3.1
    [Fact]
    public void FormatDate_short_Mar_15()
    {
        var f = new SayableDate(Locales.EN, Compactness.Short);
        Assert.Equal("Mar 15", f.Format("2025-03-15"));
    }

    // 3.2
    [Fact]
    public void FormatDate_short_Jan_1()
    {
        var f = new SayableDate(Locales.EN, Compactness.Short);
        Assert.Equal("Jan 1", f.Format("2025-01-01"));
    }

    // 3.3
    [Fact]
    public void FormatDate_short_Dec_25()
    {
        var f = new SayableDate(Locales.EN, Compactness.Short);
        Assert.Equal("Dec 25", f.Format("2025-12-25"));
    }

    // ── Section 4: format_date — compact (English) ──────────────────────

    // 4.1
    [Fact]
    public void FormatDate_compact_3_15()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("3/15", f.Format("2025-03-15"));
    }

    // 4.2
    [Fact]
    public void FormatDate_compact_1_1()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("1/1", f.Format("2025-01-01"));
    }

    // ── Section 5: format_relative — proximity tiers (English) ──────────

    // 5.1
    [Fact]
    public void FormatRelative_today()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("today", f.Relative("2025-03-15", "2025-03-15"));
    }

    // 5.2
    [Fact]
    public void FormatRelative_tomorrow()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("tomorrow", f.Relative("2025-03-16", "2025-03-15"));
    }

    // 5.3
    [Fact]
    public void FormatRelative_yesterday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("yesterday", f.Relative("2025-03-14", "2025-03-15"));
    }

    // 5.4
    [Fact]
    public void FormatRelative_day_after_tomorrow()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("the day after tomorrow", f.Relative("2025-03-17", "2025-03-15"));
    }

    // 5.5
    [Fact]
    public void FormatRelative_day_before_yesterday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("the day before yesterday", f.Relative("2025-03-13", "2025-03-15"));
    }

    // 5.6
    [Fact]
    public void FormatRelative_this_Wednesday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("this Wednesday", f.Relative("2025-03-19", "2025-03-15"));
    }

    // 5.7
    [Fact]
    public void FormatRelative_this_Thursday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("this Thursday", f.Relative("2025-03-20", "2025-03-15"));
    }

    // 5.8
    [Fact]
    public void FormatRelative_last_Tuesday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("last Tuesday", f.Relative("2025-03-11", "2025-03-15"));
    }

    // 5.9
    [Fact]
    public void FormatRelative_next_Saturday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("next Saturday", f.Relative("2025-03-22", "2025-03-15"));
    }

    // 5.10
    [Fact]
    public void FormatRelative_next_Thursday()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("next Thursday", f.Relative("2025-03-27", "2025-03-15"));
    }

    // 5.11
    [Fact]
    public void FormatRelative_calendar_same_year_past()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("March 1st", f.Relative("2025-03-01", "2025-03-15"));
    }

    // 5.12
    [Fact]
    public void FormatRelative_calendar_same_year_future()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("April 10th", f.Relative("2025-04-10", "2025-03-15"));
    }

    // 5.13
    [Fact]
    public void FormatRelative_different_year_future()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("January 5th, 2026", f.Relative("2026-01-05", "2025-03-15"));
    }

    // 5.14
    [Fact]
    public void FormatRelative_past_year()
    {
        var f = new SayableDate(Locales.EN);
        Assert.Equal("December 25th, 2024", f.Relative("2024-12-25", "2025-03-15"));
    }

    // ── Section 6: format_relative — compact skips weekday tiers ────────

    // 6.1
    [Fact]
    public void FormatRelative_compact_today()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("today", f.Relative("2025-03-15", "2025-03-15"));
    }

    // 6.2
    [Fact]
    public void FormatRelative_compact_tomorrow()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("tomorrow", f.Relative("2025-03-16", "2025-03-15"));
    }

    // 6.3
    [Fact]
    public void FormatRelative_compact_goes_straight_to_numeric()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("3/19", f.Relative("2025-03-19", "2025-03-15"));
    }

    // 6.4
    [Fact]
    public void FormatRelative_compact_different_year()
    {
        var f = new SayableDate(Locales.EN, Compactness.Compact);
        Assert.Equal("1/5/26", f.Relative("2026-01-05", "2025-03-15"));
    }

    // ── Section 7: Locale — German ──────────────────────────────────────

    // 7.1
    [Fact]
    public void FormatDate_German()
    {
        var f = new SayableDate(Locales.DE);
        Assert.Equal("15. M\u00E4rz", f.Format("2025-03-15"));
    }

    // 7.2
    [Fact]
    public void FormatRelative_German_tomorrow()
    {
        var f = new SayableDate(Locales.DE);
        Assert.Equal("morgen", f.Relative("2025-03-16", "2025-03-15"));
    }

    // 7.3
    [Fact]
    public void FormatRelative_German_day_after_tomorrow()
    {
        var f = new SayableDate(Locales.DE);
        Assert.Equal("\u00FCbermorgen", f.Relative("2025-03-17", "2025-03-15"));
    }

    // 7.4
    [Fact]
    public void FormatRelative_German_this_Wednesday()
    {
        var f = new SayableDate(Locales.DE);
        Assert.Equal("diesen Mittwoch", f.Relative("2025-03-19", "2025-03-15"));
    }

    // ── Section 8: Locale — French ──────────────────────────────────────

    // 8.1
    [Fact]
    public void FormatDate_French_1er_mars()
    {
        var f = new SayableDate(Locales.FR);
        Assert.Equal("1er mars", f.Format("2025-03-01"));
    }

    // 8.2
    [Fact]
    public void FormatDate_French_15_mars()
    {
        var f = new SayableDate(Locales.FR);
        Assert.Equal("15 mars", f.Format("2025-03-15"));
    }

    // 8.3
    [Fact]
    public void FormatRelative_French_tomorrow()
    {
        var f = new SayableDate(Locales.FR);
        Assert.Equal("demain", f.Relative("2025-03-16", "2025-03-15"));
    }

    // ── Section 9: Locale — Japanese ────────────────────────────────────

    // 9.1
    [Fact]
    public void FormatDate_Japanese()
    {
        var f = new SayableDate(Locales.JA);
        Assert.Equal("3\u670815\u65E5", f.Format("2025-03-15"));
    }

    // 9.2
    [Fact]
    public void FormatRelative_Japanese_tomorrow()
    {
        var f = new SayableDate(Locales.JA);
        Assert.Equal("\u660E\u65E5", f.Relative("2025-03-16", "2025-03-15"));
    }

    // 9.3
    [Fact]
    public void FormatRelative_Japanese_this_Wednesday()
    {
        var f = new SayableDate(Locales.JA);
        Assert.Equal("\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5", f.Relative("2025-03-19", "2025-03-15"));
    }

    // ── Section 10: Locale — Russian (genitive months) ──────────────────

    // 10.1
    [Fact]
    public void FormatDate_Russian_genitive_months()
    {
        var f = new SayableDate(Locales.RU);
        Assert.Equal("15 \u043C\u0430\u0440\u0442\u0430", f.Format("2025-03-15"));
    }

    // 10.2
    [Fact]
    public void FormatRelative_Russian_tomorrow()
    {
        var f = new SayableDate(Locales.RU);
        Assert.Equal("\u0437\u0430\u0432\u0442\u0440\u0430", f.Relative("2025-03-16", "2025-03-15"));
    }

    // ── Section 11: Locale — Arabic ─────────────────────────────────────

    // 11.1
    [Fact]
    public void FormatDate_Arabic()
    {
        var f = new SayableDate(Locales.AR);
        Assert.Equal("15 \u0645\u0627\u0631\u0633", f.Format("2025-03-15"));
    }

    // 11.2
    [Fact]
    public void FormatRelative_Arabic_tomorrow()
    {
        var f = new SayableDate(Locales.AR);
        Assert.Equal("\u063A\u062F\u0627\u064B", f.Relative("2025-03-16", "2025-03-15"));
    }

    // ── Section 12: Locale — Spanish ────────────────────────────────────

    // 12.1
    [Fact]
    public void FormatDate_Spanish()
    {
        var f = new SayableDate(Locales.ES);
        Assert.Equal("15 de marzo", f.Format("2025-03-15"));
    }

    // 12.2
    [Fact]
    public void FormatRelative_Spanish_day_after_tomorrow()
    {
        var f = new SayableDate(Locales.ES);
        Assert.Equal("pasado ma\u00F1ana", f.Relative("2025-03-17", "2025-03-15"));
    }
}
