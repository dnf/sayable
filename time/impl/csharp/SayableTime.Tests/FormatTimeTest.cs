using SayableTimeLib;
using Xunit;

namespace SayableTimeLib.Tests;

public class FormatTimeTest
{
    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    [Fact]
    public void Null_input_returns_null()
    {
        Assert.Null(SayableTime.FormatTime(null));
    }

    // 1.2
    [Fact]
    public void Empty_string_returns_null()
    {
        Assert.Null(SayableTime.FormatTime(""));
    }

    // 1.3
    [Fact]
    public void Invalid_string_returns_null()
    {
        Assert.Null(SayableTime.FormatTime("invalid"));
    }

    // 1.4
    [Fact]
    public void Out_of_range_returns_null()
    {
        Assert.Null(SayableTime.FormatTime("25:00"));
    }

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================

    // 2.1
    [Fact]
    public void Midnight()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("midnight", st.Format("00:00"));
    }

    // 2.2
    [Fact]
    public void Noon()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("noon", st.Format("12:00"));
    }

    // 2.3
    [Fact]
    public void Oclock()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("three o'clock", st.Format("15:00"));
    }

    // 2.4
    [Fact]
    public void Quarter_past()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("a quarter past two", st.Format("14:15"));
    }

    // 2.5
    [Fact]
    public void Half_past()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("half past nine", st.Format("09:30"));
    }

    // 2.6
    [Fact]
    public void Quarter_to()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("a quarter to eleven", st.Format("10:45"));
    }

    // 2.7
    [Fact]
    public void Five_past()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("five past eight", st.Format("08:05"));
    }

    // 2.8
    [Fact]
    public void Five_to()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("five to five", st.Format("16:55"));
    }

    // 2.9
    [Fact]
    public void Rounds_to_midnight()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("midnight", st.Format("23:58"));
    }

    // 2.10
    [Fact]
    public void Rounds_to_twenty()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("twenty past seven", st.Format("07:22"));
    }

    // 2.11
    [Fact]
    public void ISO_datetime_input()
    {
        var st = new SayableTime(Locales.EN);
        Assert.Equal("a quarter past two", st.Format("2025-01-15T14:15:00"));
    }

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================

    // 3.1
    [Fact]
    public void Short_PM()
    {
        var st = new SayableTime(Locales.EN, Compactness.Short);
        Assert.Equal("2:15 PM", st.Format("14:15"));
    }

    // 3.2
    [Fact]
    public void Short_AM()
    {
        var st = new SayableTime(Locales.EN, Compactness.Short);
        Assert.Equal("9:30 AM", st.Format("09:30"));
    }

    // 3.3
    [Fact]
    public void Short_midnight()
    {
        var st = new SayableTime(Locales.EN, Compactness.Short);
        Assert.Equal("12:00 AM", st.Format("00:00"));
    }

    // 3.4
    [Fact]
    public void Short_noon()
    {
        var st = new SayableTime(Locales.EN, Compactness.Short);
        Assert.Equal("12:00 PM", st.Format("12:00"));
    }

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================

    // 4.1
    [Fact]
    public void Compact_PM()
    {
        var st = new SayableTime(Locales.EN, Compactness.Compact);
        Assert.Equal("2:15p", st.Format("14:15"));
    }

    // 4.2
    [Fact]
    public void Compact_AM()
    {
        var st = new SayableTime(Locales.EN, Compactness.Compact);
        Assert.Equal("9:30a", st.Format("09:30"));
    }

    // ================================================================
    // Section 5: Locale — German
    // ================================================================

    // 5.1
    [Fact]
    public void German_half_to_pattern()
    {
        var st = new SayableTime(Locales.DE);
        Assert.Equal("halb vier", st.Format("15:30"));
    }

    // ================================================================
    // Section 6: Locale — French
    // ================================================================

    // 6.1
    [Fact]
    public void French_quarter_past()
    {
        var st = new SayableTime(Locales.FR);
        Assert.Equal("trois heures et quart", st.Format("15:15"));
    }

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================

    // 7.1
    [Fact]
    public void Japanese_half_past()
    {
        var st = new SayableTime(Locales.JA);
        Assert.Equal("\u4E09\u6642\u534A", st.Format("15:30"));
    }

    // ================================================================
    // Section 8: Locale — Finnish (dot separator, short)
    // ================================================================

    // 8.1
    [Fact]
    public void Finnish_dot_separator()
    {
        var st = new SayableTime(Locales.FI, Compactness.Short);
        Assert.Equal("14.15", st.Format("14:15"));
    }

    // 8.2
    [Fact]
    public void Finnish_midnight_dot()
    {
        var st = new SayableTime(Locales.FI, Compactness.Short);
        Assert.Equal("0.00", st.Format("00:00"));
    }
}
