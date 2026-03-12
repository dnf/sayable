Imports System

Namespace SayableDurationLib

    Public Class SayableDuration
        Public Const Version As String = "0.5.0"

        Private ReadOnly _locale As DurationLocale
        Private ReadOnly _second As UnitForms
        Private ReadOnly _minute As UnitForms
        Private ReadOnly _hour As UnitForms
        Private ReadOnly _day As UnitForms
        Private ReadOnly _week As UnitForms
        Private ReadOnly _month As UnitForms
        Private ReadOnly _year As UnitForms
        Private ReadOnly _half As String
        Private ReadOnly _delimiter As String
        Private ReadOnly _justNow As String
        Private ReadOnly _ago As String
        Private ReadOnly _inFuture As String

        Private Shared ReadOnly DefaultInstance As New SayableDuration(Locales.EN)

        Public Sub New(locale As DurationLocale, Optional compactness As Compactness = Compactness.Normal)
            _locale = locale

            Dim ovr As CompactnessOverride = Nothing
            Select Case compactness
                Case Compactness.Short
                    ovr = locale.ShortOverride
                Case Compactness.Compact
                    ovr = locale.CompactOverride
            End Select

            If ovr IsNot Nothing AndAlso ovr.Second IsNot Nothing Then _second = ovr.Second Else _second = locale.Units.Second
            If ovr IsNot Nothing AndAlso ovr.Minute IsNot Nothing Then _minute = ovr.Minute Else _minute = locale.Units.Minute
            If ovr IsNot Nothing AndAlso ovr.Hour IsNot Nothing Then _hour = ovr.Hour Else _hour = locale.Units.Hour
            If ovr IsNot Nothing AndAlso ovr.Day IsNot Nothing Then _day = ovr.Day Else _day = locale.Units.Day
            If ovr IsNot Nothing AndAlso ovr.Week IsNot Nothing Then _week = ovr.Week Else _week = locale.Units.Week
            If ovr IsNot Nothing AndAlso ovr.Month IsNot Nothing Then _month = ovr.Month Else _month = locale.Units.Month
            If ovr IsNot Nothing AndAlso ovr.Year IsNot Nothing Then _year = ovr.Year Else _year = locale.Units.Year
            If ovr IsNot Nothing AndAlso ovr.Half IsNot Nothing Then _half = ovr.Half Else _half = locale.Half
            If ovr IsNot Nothing AndAlso ovr.Delimiter IsNot Nothing Then _delimiter = ovr.Delimiter Else _delimiter = locale.Delimiter
            _justNow = locale.JustNow
            If ovr IsNot Nothing AndAlso ovr.Ago IsNot Nothing Then _ago = ovr.Ago Else _ago = locale.Ago
            If ovr IsNot Nothing AndAlso ovr.InFuture IsNot Nothing Then _inFuture = ovr.InFuture Else _inFuture = locale.InFuture
        End Sub

        Public Shared Function FormatDurationSeconds(seconds As Integer) As String
            Return DefaultInstance.FormatDuration(seconds)
        End Function

        Public Shared Function FormatDurationIso(start As String, [end] As String) As String
            Return DefaultInstance.FormatIso(start, [end])
        End Function

        Public Shared Function FormatSince(start As String, asOf As String) As String
            Return DefaultInstance.Since(start, asOf)
        End Function

        Public Shared Function FormatUntil(target As String, asOf As String) As String
            Return DefaultInstance.Until(target, asOf)
        End Function

        Public Function FormatDuration(seconds As Integer) As String
            If seconds < 0 Then Return Nothing
            Return FormatDurationInternal(seconds)
        End Function

        Public Function FormatIso(start As String, [end] As String) As String
            If String.IsNullOrEmpty(start) OrElse String.IsNullOrEmpty([end]) Then Return Nothing
            Dim s = ParseIsoToSeconds(start)
            Dim e = ParseIsoToSeconds([end])
            If s Is Nothing OrElse e Is Nothing Then Return Nothing
            Dim total = Math.Abs(e.Value - s.Value)
            Return FormatDurationInternal(total)
        End Function

        Public Function Since(start As String, asOf As String) As String
            If String.IsNullOrEmpty(start) OrElse String.IsNullOrEmpty(asOf) Then Return Nothing
            Dim s = ParseIsoToSeconds(start)
            Dim a = ParseIsoToSeconds(asOf)
            If s Is Nothing OrElse a Is Nothing Then Return Nothing
            Dim diff = a.Value - s.Value
            If diff < 0 Then Return Nothing
            If diff = 0 Then Return _justNow
            Dim dur = FormatDurationInternal(diff)
            Return _ago.Replace("{0}", dur)
        End Function

        Public Function Until(target As String, asOf As String) As String
            If String.IsNullOrEmpty(target) OrElse String.IsNullOrEmpty(asOf) Then Return Nothing
            Dim t = ParseIsoToSeconds(target)
            Dim a = ParseIsoToSeconds(asOf)
            If t Is Nothing OrElse a Is Nothing Then Return Nothing
            Dim diff = t.Value - a.Value
            If diff < 0 Then Return Nothing
            If diff = 0 Then Return _justNow
            Dim dur = FormatDurationInternal(diff)
            Return _inFuture.Replace("{0}", dur)
        End Function

        Private Function FormatDurationInternal(total As Integer) As String
            If total = 0 Then Return _justNow

            ' 1-59 seconds
            If total < 60 Then Return ResolveUnit(total, _second)

            Dim totalMinutes = total \ 60
            Dim remainderSeconds = total Mod 60

            ' 1-4 minutes: minutes + seconds
            If totalMinutes < 5 Then
                Dim result = ResolveUnit(totalMinutes, _minute)
                If remainderSeconds > 0 Then
                    result += _delimiter + ResolveUnit(remainderSeconds, _second)
                End If
                Return result
            End If

            ' 5-59 minutes
            If totalMinutes < 60 Then Return ResolveUnit(totalMinutes, _minute)

            Dim totalHours = total \ 3600
            Dim remainderMinutes = (total Mod 3600) \ 60

            ' 1-5 hours: hours + minutes (with half marker)
            If totalHours <= 5 Then
                If remainderMinutes = 30 Then
                    Return ResolveUnit(totalHours, _hour, _half)
                End If
                Dim result = ResolveUnit(totalHours, _hour)
                If remainderMinutes > 0 Then
                    result += _delimiter + ResolveUnit(remainderMinutes, _minute)
                End If
                Return result
            End If

            ' 6-23 hours
            If totalHours < 24 Then Return ResolveUnit(totalHours, _hour)

            Dim totalDays = total \ 86400
            Dim remainderHours = (total Mod 86400) \ 3600

            ' 1-2 days: days + hours (with half marker)
            If totalDays <= 2 Then
                If remainderHours = 12 Then
                    Return ResolveUnit(totalDays, _day, _half)
                End If
                Dim result = ResolveUnit(totalDays, _day)
                If remainderHours > 0 Then
                    result += _delimiter + ResolveUnit(remainderHours, _hour)
                End If
                Return result
            End If

            ' 3-6 days
            If totalDays < 7 Then Return ResolveUnit(totalDays, _day)

            Dim totalWeeks = totalDays \ 7
            Dim remainderDays = totalDays Mod 7

            ' 1-4 weeks (up to 29 days; 30+ transitions to months)
            If totalDays < 30 Then
                Dim result = ResolveUnit(totalWeeks, _week)
                If remainderDays > 0 Then
                    result += _delimiter + ResolveUnit(remainderDays, _day)
                End If
                Return result
            End If

            ' Approximate months (30.44 days average)
            Dim totalMonths = CInt(Math.Round(totalDays / 30.44))

            ' 1-11 months
            If totalMonths < 12 Then
                If totalMonths = 0 Then totalMonths = 1
                Return ResolveUnit(totalMonths, _month)
            End If

            ' 12+ months: years + months
            Dim totalYears = totalMonths \ 12
            Dim remainderMonths = totalMonths Mod 12
            Dim yearResult = ResolveUnit(totalYears, _year)
            If remainderMonths > 0 Then
                yearResult += _delimiter + ResolveUnit(remainderMonths, _month)
            End If
            Return yearResult
        End Function

        Private Function ResolveUnit(count As Integer, uf As UnitForms, Optional half As String = "") As String
            Dim baseN As String
            If _locale.FormatNumber IsNot Nothing Then
                baseN = _locale.FormatNumber(count)
            Else
                baseN = count.ToString()
            End If

            ' Apply {n}-style half marker to the number
            Dim n As String
            If half.Length > 0 AndAlso half.Contains("{n}") Then
                n = half.Replace("{n}", baseN)
            Else
                n = baseN
            End If

            ' Select template
            Dim template As String
            If uf.SimpleTemplate IsNot Nothing Then
                template = uf.SimpleTemplate
            Else
                Dim cat As PluralCategory
                If half.Length > 0 Then
                    cat = PluralCategory.Other
                Else
                    cat = _locale.Plural(count)
                End If
                Dim form As String = Nothing
                If uf.Forms IsNot Nothing AndAlso uf.Forms.TryGetValue(cat, form) Then
                    template = form
                ElseIf uf.Forms IsNot Nothing AndAlso uf.Forms.TryGetValue(PluralCategory.Other, form) Then
                    template = form
                Else
                    template = "{n}"
                End If
            End If

            Dim result = template.Replace("{n}", n)

            If _locale.FormatUnit IsNot Nothing Then
                result = _locale.FormatUnit(count, result)
            End If

            ' Apply {0}-style half marker (wraps the whole expression)
            If half.Length > 0 AndAlso half.Contains("{0}") Then
                result = half.Replace("{0}", result)
            End If

            Return result
        End Function

        Friend Shared Function ParseIsoToSeconds(iso As String) As Integer?
            If String.IsNullOrEmpty(iso) Then Return Nothing

            Dim tIdx = iso.IndexOf("T"c)
            If tIdx < 0 Then Return Nothing

            Dim datePart = iso.Substring(0, tIdx)
            Dim timePart = iso.Substring(tIdx + 1)

            Dim dp = datePart.Split("-"c)
            If dp.Length < 3 Then Return Nothing
            Dim year = SafeAtoi(dp(0))
            Dim month = SafeAtoi(dp(1))
            Dim day = SafeAtoi(dp(2))
            If year Is Nothing OrElse month Is Nothing OrElse day Is Nothing Then Return Nothing

            Dim plusIdx = timePart.IndexOf("+"c)
            If plusIdx >= 0 Then timePart = timePart.Substring(0, plusIdx)
            Dim zIdx = timePart.IndexOf("Z"c)
            If zIdx >= 0 Then timePart = timePart.Substring(0, zIdx)

            Dim tp = timePart.Split(":"c)
            Dim hour = SafeAtoi(tp(0))
            If hour Is Nothing Then Return Nothing
            Dim minute As Integer?
            If tp.Length > 1 Then minute = SafeAtoi(tp(1)) Else minute = 0
            If minute Is Nothing Then Return Nothing
            Dim second As Integer
            If tp.Length > 2 Then
                Dim secStr = tp(2).Split("."c)(0)
                Dim s = SafeAtoi(secStr)
                If s Is Nothing Then Return Nothing
                second = s.Value
            Else
                second = 0
            End If

            Dim days = DaysSinceEpoch(year.Value, month.Value, day.Value)
            Return days * 86400 + hour.Value * 3600 + minute.Value * 60 + second
        End Function

        Private Shared Function SafeAtoi(s As String) As Integer?
            If String.IsNullOrEmpty(s) Then Return Nothing
            Dim n = 0
            For Each c In s
                If c < "0"c OrElse c > "9"c Then Return Nothing
                n = n * 10 + (AscW(c) - AscW("0"c))
            Next
            Return n
        End Function

        Private Shared Function IsLeapYear(year As Integer) As Boolean
            Return (year Mod 4 = 0 AndAlso year Mod 100 <> 0) OrElse (year Mod 400 = 0)
        End Function

        Private Shared Function DaysInMonth(year As Integer, month As Integer) As Integer
            Select Case month
                Case 1, 3, 5, 7, 8, 10, 12
                    Return 31
                Case 4, 6, 9, 11
                    Return 30
                Case 2
                    Return If(IsLeapYear(year), 29, 28)
                Case Else
                    Return 30
            End Select
        End Function

        Private Shared Function DaysSinceEpoch(year As Integer, month As Integer, day As Integer) As Integer
            Dim days = 0
            If year >= 2000 Then
                For y = 2000 To year - 1
                    days += If(IsLeapYear(y), 366, 365)
                Next
            Else
                For y = year To 1999
                    days -= If(IsLeapYear(y), 366, 365)
                Next
            End If
            For m = 1 To month - 1
                days += DaysInMonth(year, m)
            Next
            days += day - 1
            Return days
        End Function
    End Class

End Namespace
