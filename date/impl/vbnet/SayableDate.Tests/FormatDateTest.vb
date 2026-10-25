Imports SayableDateLib
Imports Xunit

Namespace SayableDate.Tests

    Public Class FormatDateTest

        ' ── Section 1: Null / edge cases ────────────────────────────────────
        ' 1.1
        <Fact>
        Public Sub FormatDate_null_returns_null()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format(Nothing))
        End Sub

        ' 1.2
        <Fact>
        Public Sub FormatDate_empty_returns_null()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format(""))
        End Sub

        ' 1.3
        <Fact>
        Public Sub FormatDate_invalid_returns_null()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format("invalid"))
        End Sub

        ' 1.4
        <Fact>
        Public Sub FormatRelative_null_asOf_returns_null()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Relative("2025-03-15", Nothing))
        End Sub

        ' 1.5
        <Fact>
        Public Sub FormatRelative_null_date_returns_null()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Relative(Nothing, "2025-03-15"))
        End Sub

        ' ── Section 2: format_date — normal compactness (English) ───────────
        ' 2.1
        <Fact>
        Public Sub FormatDate_March_15th()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("March 15th", f.Format("2025-03-15"))
        End Sub

        ' 2.2
        <Fact>
        Public Sub FormatDate_January_1st()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("January 1st", f.Format("2025-01-01"))
        End Sub

        ' 2.3
        <Fact>
        Public Sub FormatDate_May_22nd()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("May 22nd", f.Format("2025-05-22"))
        End Sub

        ' 2.4
        <Fact>
        Public Sub FormatDate_July_3rd()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("July 3rd", f.Format("2025-07-03"))
        End Sub

        ' 2.5
        <Fact>
        Public Sub FormatDate_December_31st()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("December 31st", f.Format("2025-12-31"))
        End Sub

        ' 2.6
        <Fact>
        Public Sub FormatDate_June_11th()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("June 11th", f.Format("2025-06-11"))
        End Sub

        ' 2.7
        <Fact>
        Public Sub FormatDate_ISO_datetime_input()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("March 15th", f.Format("2025-03-15T14:30:00"))
        End Sub

        ' ── Section 3: format_date — short compactness (English) ────────────
        ' 3.1
        <Fact>
        Public Sub FormatDate_short_Mar_15()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Short)
            Assert.Equal("Mar 15", f.Format("2025-03-15"))
        End Sub

        ' 3.2
        <Fact>
        Public Sub FormatDate_short_Jan_1()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Short)
            Assert.Equal("Jan 1", f.Format("2025-01-01"))
        End Sub

        ' 3.3
        <Fact>
        Public Sub FormatDate_short_Dec_25()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Short)
            Assert.Equal("Dec 25", f.Format("2025-12-25"))
        End Sub

        ' ── Section 4: format_date — compact (English) ──────────────────────
        ' 4.1
        <Fact>
        Public Sub FormatDate_compact_3_15()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("3/15", f.Format("2025-03-15"))
        End Sub

        ' 4.2
        <Fact>
        Public Sub FormatDate_compact_1_1()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("1/1", f.Format("2025-01-01"))
        End Sub

        ' ── Section 5: format_relative — proximity tiers (English) ──────────
        ' 5.1
        <Fact>
        Public Sub FormatRelative_today()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("today", f.Relative("2025-03-15", "2025-03-15"))
        End Sub

        ' 5.2
        <Fact>
        Public Sub FormatRelative_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("tomorrow", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' 5.3
        <Fact>
        Public Sub FormatRelative_yesterday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("yesterday", f.Relative("2025-03-14", "2025-03-15"))
        End Sub

        ' 5.4
        <Fact>
        Public Sub FormatRelative_day_after_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("the day after tomorrow", f.Relative("2025-03-17", "2025-03-15"))
        End Sub

        ' 5.5
        <Fact>
        Public Sub FormatRelative_day_before_yesterday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("the day before yesterday", f.Relative("2025-03-13", "2025-03-15"))
        End Sub

        ' 5.6
        <Fact>
        Public Sub FormatRelative_this_Wednesday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("this Wednesday", f.Relative("2025-03-19", "2025-03-15"))
        End Sub

        ' 5.7
        <Fact>
        Public Sub FormatRelative_this_Thursday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("this Thursday", f.Relative("2025-03-20", "2025-03-15"))
        End Sub

        ' 5.8
        <Fact>
        Public Sub FormatRelative_last_Tuesday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("last Tuesday", f.Relative("2025-03-11", "2025-03-15"))
        End Sub

        ' 5.9
        <Fact>
        Public Sub FormatRelative_next_Saturday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("next Saturday", f.Relative("2025-03-22", "2025-03-15"))
        End Sub

        ' 5.10
        <Fact>
        Public Sub FormatRelative_next_Thursday()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("next Thursday", f.Relative("2025-03-27", "2025-03-15"))
        End Sub

        ' 5.11
        <Fact>
        Public Sub FormatRelative_calendar_same_year_past()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("March 1st", f.Relative("2025-03-01", "2025-03-15"))
        End Sub

        ' 5.12
        <Fact>
        Public Sub FormatRelative_calendar_same_year_future()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("April 10th", f.Relative("2025-04-10", "2025-03-15"))
        End Sub

        ' 5.13
        <Fact>
        Public Sub FormatRelative_different_year_future()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("January 5th, 2026", f.Relative("2026-01-05", "2025-03-15"))
        End Sub

        ' 5.14
        <Fact>
        Public Sub FormatRelative_past_year()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("December 25th, 2024", f.Relative("2024-12-25", "2025-03-15"))
        End Sub

        ' ── Section 6: format_relative — compact skips weekday tiers ────────
        ' 6.1
        <Fact>
        Public Sub FormatRelative_compact_today()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("today", f.Relative("2025-03-15", "2025-03-15"))
        End Sub

        ' 6.2
        <Fact>
        Public Sub FormatRelative_compact_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("tomorrow", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' 6.3
        <Fact>
        Public Sub FormatRelative_compact_goes_straight_to_numeric()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("3/19", f.Relative("2025-03-19", "2025-03-15"))
        End Sub

        ' 6.4
        <Fact>
        Public Sub FormatRelative_compact_different_year()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("1/5/26", f.Relative("2026-01-05", "2025-03-15"))
        End Sub

        ' ── Section 7: Locale — German ──────────────────────────────────────
        ' 7.1
        <Fact>
        Public Sub FormatDate_German()
            Dim f = New SayableDateLib.SayableDate(Locales.DE)
            Assert.Equal("15. März", f.Format("2025-03-15"))
        End Sub

        ' 7.2
        <Fact>
        Public Sub FormatRelative_German_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.DE)
            Assert.Equal("morgen", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' 7.3
        <Fact>
        Public Sub FormatRelative_German_day_after_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.DE)
            Assert.Equal("übermorgen", f.Relative("2025-03-17", "2025-03-15"))
        End Sub

        ' 7.4
        <Fact>
        Public Sub FormatRelative_German_this_Wednesday()
            Dim f = New SayableDateLib.SayableDate(Locales.DE)
            Assert.Equal("diesen Mittwoch", f.Relative("2025-03-19", "2025-03-15"))
        End Sub

        ' ── Section 8: Locale — French ──────────────────────────────────────
        ' 8.1
        <Fact>
        Public Sub FormatDate_French_1er_mars()
            Dim f = New SayableDateLib.SayableDate(Locales.FR)
            Assert.Equal("1er mars", f.Format("2025-03-01"))
        End Sub

        ' 8.2
        <Fact>
        Public Sub FormatDate_French_15_mars()
            Dim f = New SayableDateLib.SayableDate(Locales.FR)
            Assert.Equal("15 mars", f.Format("2025-03-15"))
        End Sub

        ' 8.3
        <Fact>
        Public Sub FormatRelative_French_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.FR)
            Assert.Equal("demain", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' ── Section 9: Locale — Japanese ────────────────────────────────────
        ' 9.1
        <Fact>
        Public Sub FormatDate_Japanese()
            Dim f = New SayableDateLib.SayableDate(Locales.JA)
            Assert.Equal("3月15日", f.Format("2025-03-15"))
        End Sub

        ' 9.2
        <Fact>
        Public Sub FormatRelative_Japanese_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.JA)
            Assert.Equal("明日", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' 9.3
        <Fact>
        Public Sub FormatRelative_Japanese_this_Wednesday()
            Dim f = New SayableDateLib.SayableDate(Locales.JA)
            Assert.Equal("今度の水曜日", f.Relative("2025-03-19", "2025-03-15"))
        End Sub

        ' ── Section 10: Locale — Russian (genitive months) ──────────────────
        ' 10.1
        <Fact>
        Public Sub FormatDate_Russian_genitive_months()
            Dim f = New SayableDateLib.SayableDate(Locales.RU)
            Assert.Equal("15 марта", f.Format("2025-03-15"))
        End Sub

        ' 10.2
        <Fact>
        Public Sub FormatRelative_Russian_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.RU)
            Assert.Equal("завтра", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' ── Section 11: Locale — Arabic ─────────────────────────────────────
        ' 11.1
        <Fact>
        Public Sub FormatDate_Arabic()
            Dim f = New SayableDateLib.SayableDate(Locales.AR)
            Assert.Equal("15 مارس", f.Format("2025-03-15"))
        End Sub

        ' 11.2
        <Fact>
        Public Sub FormatRelative_Arabic_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.AR)
            Assert.Equal("غداً", f.Relative("2025-03-16", "2025-03-15"))
        End Sub

        ' ── Section 12: Locale — Spanish ────────────────────────────────────
        ' 12.1
        <Fact>
        Public Sub FormatDate_Spanish()
            Dim f = New SayableDateLib.SayableDate(Locales.ES)
            Assert.Equal("15 de marzo", f.Format("2025-03-15"))
        End Sub

        ' 12.2
        <Fact>
        Public Sub FormatRelative_Spanish_day_after_tomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.ES)
            Assert.Equal("pasado mañana", f.Relative("2025-03-17", "2025-03-15"))
        End Sub

        ' ================================================================
        ' format_date_with_year
        ' ================================================================

        ' 13.1
        <Fact>
        Public Sub Spec13_1_FormatDateWithYear()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("February 4th, 2018", f.FormatWithYear("2018-02-04"))
        End Sub

        ' 13.2
        <Fact>
        Public Sub Spec13_2_FormatDateWithYear()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Short)
            Assert.Equal("Mar 15, 2025", f.FormatWithYear("2025-03-15"))
        End Sub

        ' 13.3
        <Fact>
        Public Sub Spec13_3_FormatDateWithYear()
            Dim f = New SayableDateLib.SayableDate(Locales.EN, Compactness.Compact)
            Assert.Equal("1/21/97", f.FormatWithYear("1997-01-21"))
        End Sub

        ' 13.4
        <Fact>
        Public Sub Spec13_4_TwoDigitYearKeepsItsLeadingZero()
            Dim f = New SayableDateLib.SayableDate(Locales.TG, Compactness.Compact)
            Assert.Equal("20/5/07", f.FormatWithYear("2007-05-20"))
        End Sub

        ' 13.5
        <Fact>
        Public Sub Spec13_5_FormatDateWithYear()
            Dim f = New SayableDateLib.SayableDate(Locales.FI, Compactness.Short)
            Assert.Equal("21. kesäkuuta 1996", f.FormatWithYear("1996-06-21"))
        End Sub

        ' ================================================================
        ' Short month names (locales that keep the full genitive)
        ' ================================================================

        ' 14.1
        <Fact>
        Public Sub Spec14_1_ShortMonthNamesLocalesThatKeepThe()
            Dim f = New SayableDateLib.SayableDate(Locales.SK, Compactness.Short)
            Assert.Equal("15. februára", f.Format("2031-02-15"))
        End Sub

        ' 14.2
        <Fact>
        Public Sub Spec14_2_ShortMonthNamesLocalesThatKeepThe()
            Dim f = New SayableDateLib.SayableDate(Locales.CS, Compactness.Short)
            Assert.Equal("10. prosince", f.Format("2025-12-10"))
        End Sub

        ' 14.3
        <Fact>
        Public Sub Spec14_3_ShortMonthNamesLocalesThatKeepThe()
            Dim f = New SayableDateLib.SayableDate(Locales.UK, Compactness.Short)
            Assert.Equal("5 листопада", f.Format("2025-11-05"))
        End Sub

        ' 14.4
        <Fact>
        Public Sub Spec14_4_ShortMonthNamesLocalesThatKeepThe()
            Dim f = New SayableDateLib.SayableDate(Locales.FI, Compactness.Short)
            Assert.Equal("8. elokuuta", f.Relative("1998-08-08", "1998-08-15"))
        End Sub

        ' ================================================================
        ' format_relative — short phrases
        ' ================================================================

        ' 15.1
        <Fact>
        Public Sub Spec15_1_DayAfterTomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.KW, Compactness.Short)
            Assert.Equal("an Mth ma", f.Relative("2035-12-04", "2035-12-02"))
        End Sub

        ' 15.2
        <Fact>
        Public Sub Spec15_2_DayBeforeYesterday()
            Dim f = New SayableDateLib.SayableDate(Locales.MAM, Compactness.Short)
            Assert.Equal("Dom nchi'j", f.Relative("2000-01-23", "2000-01-25"))
        End Sub

        ' 15.3
        <Fact>
        Public Sub Spec15_3_DayAfterTomorrow()
            Dim f = New SayableDateLib.SayableDate(Locales.KEK, Compactness.Short)
            Assert.Equal("a'in Vie", f.Relative("2014-10-24", "2014-10-22"))
        End Sub

        ' ================================================================
        ' Input validation
        ' ================================================================

        ' 16.1
        <Fact>
        Public Sub Spec16_1_February30DoesntExist()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format("2025-02-30"))
        End Sub

        ' 16.2
        <Fact>
        Public Sub Spec16_2_Month13()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format("2025-13-01"))
        End Sub

        ' 16.3
        <Fact>
        Public Sub Spec16_3_UnpaddedMonthAndDay()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format("2025-6-1"))
        End Sub

        ' 16.4
        <Fact>
        Public Sub Spec16_4_SurroundingWhitespace()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Format(" 2025-06-01"))
        End Sub

        ' 16.5
        <Fact>
        Public Sub Spec16_5_AnISODatetimeOnlyTheDatePart()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Equal("June 1st", f.Format("2025-06-01T10:00:00"))
        End Sub

        ' 16.6
        <Fact>
        Public Sub Spec16_6_February29InANonLeapYear()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.FormatWithYear("2023-02-29"))
        End Sub

        ' 16.7
        <Fact>
        Public Sub Spec16_7_InvalidAsOf()
            Dim f = New SayableDateLib.SayableDate(Locales.EN)
            Assert.Null(f.Relative("2025-03-16", "2025-04-31"))
        End Sub

    End Class

End Namespace
