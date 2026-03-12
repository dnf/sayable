Imports SayableDurationLib
Imports Xunit

Namespace SayableDuration.Tests

    Public Class FormatDurationTest

        ' ================================================================
        ' Section 1: Null / edge cases
        ' ================================================================
        ' 1.1
        <Fact>
        Public Sub FormatDuration_null_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatDurationSeconds(-1))
        End Sub

        ' 1.2
        <Fact>
        Public Sub FormatDuration_negative_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatDurationSeconds(-1))
        End Sub

        ' 1.3
        <Fact>
        Public Sub FormatSince_null_start_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatSince(Nothing, "2025-01-15T10:00:00"))
        End Sub

        ' 1.4
        <Fact>
        Public Sub FormatUntil_null_target_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatUntil(Nothing, "2025-01-15T10:00:00"))
        End Sub

        ' 1.5
        <Fact>
        Public Sub FormatSince_asOf_before_start_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"))
        End Sub

        ' 1.6
        <Fact>
        Public Sub FormatUntil_target_in_the_past_returns_null()
            Assert.Null(SayableDurationLib.SayableDuration.FormatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"))
        End Sub

        ' ================================================================
        ' Section 2: Duration — seconds tier (0-59s)
        ' ================================================================
        ' 2.1
        <Fact>
        Public Sub Zero_seconds_is_just_now()
            Assert.Equal("just now", SayableDurationLib.SayableDuration.FormatDurationSeconds(0))
        End Sub

        ' 2.2
        <Fact>
        Public Sub One_second()
            Assert.Equal("1 second", SayableDurationLib.SayableDuration.FormatDurationSeconds(1))
        End Sub

        ' 2.3
        <Fact>
        Public Sub Seconds_45()
            Assert.Equal("45 seconds", SayableDurationLib.SayableDuration.FormatDurationSeconds(45))
        End Sub

        ' 2.4
        <Fact>
        Public Sub Seconds_59()
            Assert.Equal("59 seconds", SayableDurationLib.SayableDuration.FormatDurationSeconds(59))
        End Sub

        ' ================================================================
        ' Section 3: Duration — minutes + seconds tier (1-4 min)
        ' ================================================================
        ' 3.1
        <Fact>
        Public Sub One_minute()
            Assert.Equal("1 minute", SayableDurationLib.SayableDuration.FormatDurationSeconds(60))
        End Sub

        ' 3.2
        <Fact>
        Public Sub One_minute_30_seconds()
            Assert.Equal("1 minute, 30 seconds", SayableDurationLib.SayableDuration.FormatDurationSeconds(90))
        End Sub

        ' 3.3
        <Fact>
        Public Sub Four_minutes()
            Assert.Equal("4 minutes", SayableDurationLib.SayableDuration.FormatDurationSeconds(240))
        End Sub

        ' 3.4
        <Fact>
        Public Sub Four_minutes_30_seconds()
            Assert.Equal("4 minutes, 30 seconds", SayableDurationLib.SayableDuration.FormatDurationSeconds(270))
        End Sub

        ' ================================================================
        ' Section 4: Duration — minutes tier (5-59 min)
        ' ================================================================
        ' 4.1
        <Fact>
        Public Sub Five_minutes()
            Assert.Equal("5 minutes", SayableDurationLib.SayableDuration.FormatDurationSeconds(300))
        End Sub

        ' 4.2
        <Fact>
        Public Sub Minutes_25()
            Assert.Equal("25 minutes", SayableDurationLib.SayableDuration.FormatDurationSeconds(1500))
        End Sub

        ' 4.3
        <Fact>
        Public Sub Minutes_59()
            Assert.Equal("59 minutes", SayableDurationLib.SayableDuration.FormatDurationSeconds(3540))
        End Sub

        ' ================================================================
        ' Section 5: Duration — hours + minutes tier (1-5 hr)
        ' ================================================================
        ' 5.1
        <Fact>
        Public Sub One_hour()
            Assert.Equal("1 hour", SayableDurationLib.SayableDuration.FormatDurationSeconds(3600))
        End Sub

        ' 5.2
        <Fact>
        Public Sub One_and_half_hours()
            Assert.Equal("1½ hours", SayableDurationLib.SayableDuration.FormatDurationSeconds(5400))
        End Sub

        ' 5.3
        <Fact>
        Public Sub Two_hours_15_minutes()
            Assert.Equal("2 hours, 15 minutes", SayableDurationLib.SayableDuration.FormatDurationSeconds(8100))
        End Sub

        ' 5.4
        <Fact>
        Public Sub Five_hours()
            Assert.Equal("5 hours", SayableDurationLib.SayableDuration.FormatDurationSeconds(18000))
        End Sub

        ' ================================================================
        ' Section 6: Duration — hours tier (6-23 hr)
        ' ================================================================
        ' 6.1
        <Fact>
        Public Sub Eight_hours()
            Assert.Equal("8 hours", SayableDurationLib.SayableDuration.FormatDurationSeconds(28800))
        End Sub

        ' 6.2
        <Fact>
        Public Sub TwentyThree_hours()
            Assert.Equal("23 hours", SayableDurationLib.SayableDuration.FormatDurationSeconds(82800))
        End Sub

        ' ================================================================
        ' Section 7: Duration — days tier
        ' ================================================================
        ' 7.1
        <Fact>
        Public Sub One_day()
            Assert.Equal("1 day", SayableDurationLib.SayableDuration.FormatDurationSeconds(86400))
        End Sub

        ' 7.2
        <Fact>
        Public Sub One_day_3_hours()
            Assert.Equal("1 day, 3 hours", SayableDurationLib.SayableDuration.FormatDurationSeconds(97200))
        End Sub

        ' 7.3
        <Fact>
        Public Sub One_and_half_days()
            Assert.Equal("1½ days", SayableDurationLib.SayableDuration.FormatDurationSeconds(129600))
        End Sub

        ' 7.4
        <Fact>
        Public Sub Five_days()
            Assert.Equal("5 days", SayableDurationLib.SayableDuration.FormatDurationSeconds(432000))
        End Sub

        ' 7.5
        <Fact>
        Public Sub Two_days()
            Assert.Equal("2 days", SayableDurationLib.SayableDuration.FormatDurationSeconds(172800))
        End Sub

        ' ================================================================
        ' Section 8: Duration — weeks tier
        ' ================================================================
        ' 8.1
        <Fact>
        Public Sub One_week()
            Assert.Equal("1 week", SayableDurationLib.SayableDuration.FormatDurationSeconds(604800))
        End Sub

        ' 8.2
        <Fact>
        Public Sub Two_weeks_1_day()
            Assert.Equal("2 weeks, 1 day", SayableDurationLib.SayableDuration.FormatDurationSeconds(1296000))
        End Sub

        ' 8.3
        <Fact>
        Public Sub Four_weeks()
            Assert.Equal("4 weeks", SayableDurationLib.SayableDuration.FormatDurationSeconds(2419200))
        End Sub

        ' ================================================================
        ' Section 9: Duration — months and years tier
        ' ================================================================
        ' 9.1
        <Fact>
        Public Sub One_month()
            Assert.Equal("1 month", SayableDurationLib.SayableDuration.FormatDurationSeconds(2678400))
        End Sub

        ' 9.2
        <Fact>
        Public Sub Three_months()
            Assert.Equal("3 months", SayableDurationLib.SayableDuration.FormatDurationSeconds(7884000))
        End Sub

        ' 9.3
        <Fact>
        Public Sub One_year()
            Assert.Equal("1 year", SayableDurationLib.SayableDuration.FormatDurationSeconds(31536000))
        End Sub

        ' 9.4
        <Fact>
        Public Sub One_year_3_months()
            Assert.Equal("1 year, 3 months", SayableDurationLib.SayableDuration.FormatDurationSeconds(39420000))
        End Sub

        ' ================================================================
        ' Section 10: Duration from ISO timestamps
        ' ================================================================
        ' 10.1
        <Fact>
        Public Sub ISO_one_and_half_hours()
            Assert.Equal("1½ hours",
            SayableDurationLib.SayableDuration.FormatDurationIso("2025-01-15T10:00:00", "2025-01-15T11:30:00"))
        End Sub

        ' 10.2
        <Fact>
        Public Sub ISO_45_minutes()
            Assert.Equal("45 minutes",
            SayableDurationLib.SayableDuration.FormatDurationIso("2025-01-15T10:00:00", "2025-01-15T10:45:00"))
        End Sub

        ' ================================================================
        ' Section 11: Relative time — since
        ' ================================================================
        ' 11.1
        <Fact>
        Public Sub Since_just_now()
            Assert.Equal("just now",
            SayableDurationLib.SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00"))
        End Sub

        ' 11.2
        <Fact>
        Public Sub Since_30_seconds_ago()
            Assert.Equal("30 seconds ago",
            SayableDurationLib.SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30"))
        End Sub

        ' 11.3
        <Fact>
        Public Sub Since_45_minutes_ago()
            Assert.Equal("45 minutes ago",
            SayableDurationLib.SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00"))
        End Sub

        ' 11.4
        <Fact>
        Public Sub Since_3_hours_ago()
            Assert.Equal("3 hours ago",
            SayableDurationLib.SayableDuration.FormatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00"))
        End Sub

        ' ================================================================
        ' Section 12: Relative time — until
        ' ================================================================
        ' 12.1
        <Fact>
        Public Sub Until_just_now()
            Assert.Equal("just now",
            SayableDurationLib.SayableDuration.FormatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00"))
        End Sub

        ' 12.2
        <Fact>
        Public Sub Until_in_20_minutes()
            Assert.Equal("in 20 minutes",
            SayableDurationLib.SayableDuration.FormatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00"))
        End Sub

        ' 12.3
        <Fact>
        Public Sub Until_in_3_hours()
            Assert.Equal("in 3 hours",
            SayableDurationLib.SayableDuration.FormatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00"))
        End Sub

        ' ================================================================
        ' Section 13: Locale — German
        ' ================================================================
        ' 13.1
        <Fact>
        Public Sub German_1_hour()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.DE)
            Assert.Equal("1 Stunde", sd.FormatDuration(3600))
        End Sub

        ' 13.2
        <Fact>
        Public Sub German_since_5_minutes()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.DE)
            Assert.Equal("vor 5 Minuten",
            sd.Since("2025-01-15T10:00:00", "2025-01-15T10:05:00"))
        End Sub

        ' ================================================================
        ' Section 14: Locale — French
        ' ================================================================
        ' 14.1
        <Fact>
        Public Sub French_2_hours()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.FR)
            Assert.Equal("2 heures", sd.FormatDuration(7200))
        End Sub

        ' ================================================================
        ' Section 15: Locale — Japanese
        ' ================================================================
        ' 15.1
        <Fact>
        Public Sub Japanese_2_minutes()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.JA)
            Assert.Equal("2分", sd.FormatDuration(120))
        End Sub

        ' 15.2
        <Fact>
        Public Sub Japanese_since_1_hour()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.JA)
            Assert.Equal("1時間前",
            sd.Since("2025-01-15T10:00:00", "2025-01-15T11:00:00"))
        End Sub

        ' ================================================================
        ' Section 16: Short compactness — duration
        ' ================================================================
        ' 16.1
        <Fact>
        Public Sub Short_1_hour()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.EN, Compactness.Short)
            Assert.Equal("1h", sd.FormatDuration(3600))
        End Sub

        ' 16.2
        <Fact>
        Public Sub Short_1_minute_30_seconds()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.EN, Compactness.Short)
            Assert.Equal("1m, 30s", sd.FormatDuration(90))
        End Sub

        ' ================================================================
        ' Section 17: Compact compactness — duration
        ' ================================================================
        ' 17.1
        <Fact>
        Public Sub Compact_1_hour()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.EN, Compactness.Compact)
            Assert.Equal("1h", sd.FormatDuration(3600))
        End Sub

        ' 17.2
        <Fact>
        Public Sub Compact_1_minute_30_seconds()
            Dim sd = New SayableDurationLib.SayableDuration(Locales.EN, Compactness.Compact)
            Assert.Equal("1m30s", sd.FormatDuration(90))
        End Sub

    End Class

End Namespace
