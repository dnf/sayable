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

    // 6.2
    [Fact]
    public void French_one_oclock()
    {
        var st = new SayableTime(Locales.FR);
        Assert.Equal("une heure", st.Format("13:00"));
    }

    // 6.3
    [Fact]
    public void French_half_past_one()
    {
        var st = new SayableTime(Locales.FR);
        Assert.Equal("une heure et demie", st.Format("13:30"));
    }

    // 6.4
    [Fact]
    public void French_quarter_to_three()
    {
        var st = new SayableTime(Locales.FR);
        Assert.Equal("trois heures moins le quart", st.Format("14:45"));
    }

    // 6.5
    [Fact]
    public void French_ten_to_three()
    {
        var st = new SayableTime(Locales.FR);
        Assert.Equal("trois heures moins dix", st.Format("14:50"));
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

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================

    // 9.1
    [Fact]
    public void Spec9_1_DigitalModesKeepTheExactMinute()
    {
        var f = new SayableTime(Locales.EN, Compactness.Short);
        Assert.Equal("6:01 PM", f.Format("18:01"));
    }

    // 9.2
    [Fact]
    public void Spec9_2_DigitalModesKeepTheExactMinute()
    {
        var f = new SayableTime(Locales.EN, Compactness.Compact);
        Assert.Equal("7:05p", f.Format("19:05"));
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 10.1
    [Fact]
    public void Spec10_1_OneDigitHour()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Equal("half past nine", f.Format("9:30"));
    }

    // 10.2
    [Fact]
    public void Spec10_2_TwoDigitHour()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Equal("half past nine", f.Format("09:30"));
    }

    // 10.3
    [Fact]
    public void Spec10_3_LeadingWhitespace()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Null(f.Format(" 9:30"));
    }

    // 10.4
    [Fact]
    public void Spec10_4_TrailingWhitespace()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Null(f.Format("9:30 "));
    }

    // 10.5
    [Fact]
    public void Spec10_5_MinutesNeedTwoDigits()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Null(f.Format("9:5"));
    }

    // 10.6
    [Fact]
    public void Spec10_6_HourOutOfRange()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Null(f.Format("24:00"));
    }

    // 10.7
    [Fact]
    public void Spec10_7_SecondsAreAllowedAndIgnored()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Equal("a quarter past two", f.Format("14:15:30"));
    }

    // 10.8
    [Fact]
    public void Spec10_8_ISODatetimeWithZoneSuffixIgnored()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Equal("a quarter past two", f.Format("2025-01-15T14:15:00Z"));
    }

    // 10.9
    [Fact]
    public void Spec10_9_ISODatetimeWithAnImpossibleDate()
    {
        var f = new SayableTime(Locales.EN);
        Assert.Null(f.Format("2025-02-30T14:15:00"));
    }
}
