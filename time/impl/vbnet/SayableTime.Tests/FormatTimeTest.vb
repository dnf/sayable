Imports SayableTimeLib
Imports Xunit

Namespace SayableTime.Tests

    Public Class FormatTimeTest

        ' ================================================================
        ' Section 1: Null / edge cases
        ' ================================================================
        ' 1.1
        <Fact>
        Public Sub Null_input_returns_null()
            Assert.Null(SayableTimeLib.SayableTime.FormatTime(Nothing))
        End Sub

        ' 1.2
        <Fact>
        Public Sub Empty_string_returns_null()
            Assert.Null(SayableTimeLib.SayableTime.FormatTime(""))
        End Sub

        ' 1.3
        <Fact>
        Public Sub Invalid_string_returns_null()
            Assert.Null(SayableTimeLib.SayableTime.FormatTime("invalid"))
        End Sub

        ' 1.4
        <Fact>
        Public Sub Out_of_range_returns_null()
            Assert.Null(SayableTimeLib.SayableTime.FormatTime("25:00"))
        End Sub

        ' ================================================================
        ' Section 2: Clock time (normal compactness)
        ' ================================================================
        ' 2.1
        <Fact>
        Public Sub Midnight()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("midnight", st.Format("00:00"))
        End Sub

        ' 2.2
        <Fact>
        Public Sub Noon()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("noon", st.Format("12:00"))
        End Sub

        ' 2.3
        <Fact>
        Public Sub Oclock()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("three o'clock", st.Format("15:00"))
        End Sub

        ' 2.4
        <Fact>
        Public Sub Quarter_past()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("a quarter past two", st.Format("14:15"))
        End Sub

        ' 2.5
        <Fact>
        Public Sub Half_past()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("half past nine", st.Format("09:30"))
        End Sub

        ' 2.6
        <Fact>
        Public Sub Quarter_to()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("a quarter to eleven", st.Format("10:45"))
        End Sub

        ' 2.7
        <Fact>
        Public Sub Five_past()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("five past eight", st.Format("08:05"))
        End Sub

        ' 2.8
        <Fact>
        Public Sub Five_to()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("five to five", st.Format("16:55"))
        End Sub

        ' 2.9
        <Fact>
        Public Sub Rounds_to_midnight()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("midnight", st.Format("23:58"))
        End Sub

        ' 2.10
        <Fact>
        Public Sub Rounds_to_twenty()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("twenty past seven", st.Format("07:22"))
        End Sub

        ' 2.11
        <Fact>
        Public Sub ISO_datetime_input()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("a quarter past two", st.Format("2025-01-15T14:15:00"))
        End Sub

        ' ================================================================
        ' Section 3: Clock time (short compactness)
        ' ================================================================
        ' 3.1
        <Fact>
        Public Sub Short_PM()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Short)
            Assert.Equal("2:15 PM", st.Format("14:15"))
        End Sub

        ' 3.2
        <Fact>
        Public Sub Short_AM()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Short)
            Assert.Equal("9:30 AM", st.Format("09:30"))
        End Sub

        ' 3.3
        <Fact>
        Public Sub Short_midnight()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Short)
            Assert.Equal("12:00 AM", st.Format("00:00"))
        End Sub

        ' 3.4
        <Fact>
        Public Sub Short_noon()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Short)
            Assert.Equal("12:00 PM", st.Format("12:00"))
        End Sub

        ' ================================================================
        ' Section 4: Clock time (compact)
        ' ================================================================
        ' 4.1
        <Fact>
        Public Sub Compact_PM()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Compact)
            Assert.Equal("2:15p", st.Format("14:15"))
        End Sub

        ' 4.2
        <Fact>
        Public Sub Compact_AM()
            Dim st = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Compact)
            Assert.Equal("9:30a", st.Format("09:30"))
        End Sub

        ' ================================================================
        ' Section 5: Locale — German
        ' ================================================================
        ' 5.1
        <Fact>
        Public Sub German_half_to_pattern()
            Dim st = New SayableTimeLib.SayableTime(Locales.DE)
            Assert.Equal("halb vier", st.Format("15:30"))
        End Sub

        ' ================================================================
        ' Section 6: Locale — French
        ' ================================================================
        ' 6.1
        <Fact>
        Public Sub French_quarter_past()
            Dim st = New SayableTimeLib.SayableTime(Locales.FR)
            Assert.Equal("trois heures et quart", st.Format("15:15"))
        End Sub

        ' 6.2
        <Fact>
        Public Sub French_singular_hour()
            Dim st = New SayableTimeLib.SayableTime(Locales.FR)
            Assert.Equal("une heure", st.Format("13:00"))
        End Sub

        ' 6.3
        <Fact>
        Public Sub French_half_past_singular_hour()
            Dim st = New SayableTimeLib.SayableTime(Locales.FR)
            Assert.Equal("une heure et demie", st.Format("13:30"))
        End Sub

        ' 6.4
        <Fact>
        Public Sub French_quarter_to()
            Dim st = New SayableTimeLib.SayableTime(Locales.FR)
            Assert.Equal("trois heures moins le quart", st.Format("14:45"))
        End Sub

        ' 6.5
        <Fact>
        Public Sub French_ten_to()
            Dim st = New SayableTimeLib.SayableTime(Locales.FR)
            Assert.Equal("trois heures moins dix", st.Format("14:50"))
        End Sub

        ' ================================================================
        ' Section 7: Locale — Japanese
        ' ================================================================
        ' 7.1
        <Fact>
        Public Sub Japanese_half_past()
            Dim st = New SayableTimeLib.SayableTime(Locales.JA)
            Assert.Equal("三時半", st.Format("15:30"))
        End Sub

        ' ================================================================
        ' Section 8: Locale — Finnish (dot separator, short)
        ' ================================================================
        ' 8.1
        <Fact>
        Public Sub Finnish_dot_separator()
            Dim st = New SayableTimeLib.SayableTime(Locales.FI, Compactness.Short)
            Assert.Equal("14.15", st.Format("14:15"))
        End Sub

        ' 8.2
        <Fact>
        Public Sub Finnish_midnight_dot()
            Dim st = New SayableTimeLib.SayableTime(Locales.FI, Compactness.Short)
            Assert.Equal("0.00", st.Format("00:00"))
        End Sub

        ' ================================================================
        ' Minutes in short and compact modes
        ' ================================================================

        ' 9.1
        <Fact>
        Public Sub Spec9_1_DigitalModesKeepTheExactMinute()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Short)
            Assert.Equal("6:01 PM", f.Format("18:01"))
        End Sub

        ' 9.2
        <Fact>
        Public Sub Spec9_2_DigitalModesKeepTheExactMinute()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN, Compactness.Compact)
            Assert.Equal("7:05p", f.Format("19:05"))
        End Sub

        ' ================================================================
        ' Input validation
        ' ================================================================

        ' 10.1
        <Fact>
        Public Sub Spec10_1_OneDigitHour()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("half past nine", f.Format("9:30"))
        End Sub

        ' 10.2
        <Fact>
        Public Sub Spec10_2_TwoDigitHour()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("half past nine", f.Format("09:30"))
        End Sub

        ' 10.3
        <Fact>
        Public Sub Spec10_3_LeadingWhitespace()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Null(f.Format(" 9:30"))
        End Sub

        ' 10.4
        <Fact>
        Public Sub Spec10_4_TrailingWhitespace()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Null(f.Format("9:30 "))
        End Sub

        ' 10.5
        <Fact>
        Public Sub Spec10_5_MinutesNeedTwoDigits()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Null(f.Format("9:5"))
        End Sub

        ' 10.6
        <Fact>
        Public Sub Spec10_6_HourOutOfRange()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Null(f.Format("24:00"))
        End Sub

        ' 10.7
        <Fact>
        Public Sub Spec10_7_SecondsAreAllowedAndIgnored()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("a quarter past two", f.Format("14:15:30"))
        End Sub

        ' 10.8
        <Fact>
        Public Sub Spec10_8_ISODatetimeWithZoneSuffixIgnored()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Equal("a quarter past two", f.Format("2025-01-15T14:15:00Z"))
        End Sub

        ' 10.9
        <Fact>
        Public Sub Spec10_9_ISODatetimeWithAnImpossibleDate()
            Dim f = New SayableTimeLib.SayableTime(Locales.EN)
            Assert.Null(f.Format("2025-02-30T14:15:00"))
        End Sub

    End Class

End Namespace
