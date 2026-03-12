Imports System
Imports System.Collections.Generic

Namespace SayableDateLib

    Public Class SayableDate
        Public Const Version As String = "0.5.0"

        Private ReadOnly _locale As DateLocale
        Private ReadOnly _compactness As Compactness
        Private ReadOnly _months As String()
        Private ReadOnly _monthsInDate As String()
        Private ReadOnly _weekdays As String()
        Private ReadOnly _dayFormat As String
        Private ReadOnly _dayFormatExceptions As IReadOnlyDictionary(Of String, String)
        Private ReadOnly _datePattern As String
        Private ReadOnly _datePatternWithYear As String
        Private ReadOnly _todayStr As String
        Private ReadOnly _tomorrowStr As String
        Private ReadOnly _yesterdayStr As String

        Private Shared ReadOnly DefaultInstance As New SayableDate(Locales.EN)

        Public Sub New(locale As DateLocale, Optional compactness As Compactness = Compactness.Normal)
            _locale = locale
            _compactness = compactness

            Dim ovr As CompactnessOverride = Nothing
            Select Case compactness
                Case Compactness.Short
                    ovr = locale.ShortOverride
                Case Compactness.Compact
                    ovr = locale.CompactOverride
            End Select

            If ovr IsNot Nothing AndAlso ovr.Months IsNot Nothing Then _months = ovr.Months Else _months = locale.Months
            If ovr IsNot Nothing AndAlso ovr.MonthsInDate IsNot Nothing Then _monthsInDate = ovr.MonthsInDate Else _monthsInDate = locale.MonthsInDate
            If ovr IsNot Nothing AndAlso ovr.Weekdays IsNot Nothing Then _weekdays = ovr.Weekdays Else _weekdays = locale.Weekdays

            ' When override provides dayFormat but not dayFormatExceptions, clear exceptions
            If ovr IsNot Nothing AndAlso ovr.DayFormat IsNot Nothing AndAlso ovr.DayFormatExceptions Is Nothing Then
                _dayFormat = ovr.DayFormat
                _dayFormatExceptions = New Dictionary(Of String, String)()
            Else
                If ovr IsNot Nothing AndAlso ovr.DayFormat IsNot Nothing Then _dayFormat = ovr.DayFormat Else _dayFormat = locale.DayFormat
                If ovr IsNot Nothing AndAlso ovr.DayFormatExceptions IsNot Nothing Then _dayFormatExceptions = ovr.DayFormatExceptions Else _dayFormatExceptions = locale.DayFormatExceptions
            End If

            If ovr IsNot Nothing AndAlso ovr.DatePattern IsNot Nothing Then _datePattern = ovr.DatePattern Else _datePattern = locale.DatePattern
            If ovr IsNot Nothing AndAlso ovr.DatePatternWithYear IsNot Nothing Then _datePatternWithYear = ovr.DatePatternWithYear Else _datePatternWithYear = locale.DatePatternWithYear
            If ovr IsNot Nothing AndAlso ovr.Today IsNot Nothing Then _todayStr = ovr.Today Else _todayStr = locale.Today
            If ovr IsNot Nothing AndAlso ovr.Tomorrow IsNot Nothing Then _tomorrowStr = ovr.Tomorrow Else _tomorrowStr = locale.Tomorrow
            If ovr IsNot Nothing AndAlso ovr.Yesterday IsNot Nothing Then _yesterdayStr = ovr.Yesterday Else _yesterdayStr = locale.Yesterday
        End Sub

        Public Shared Function FormatDate(d As String) As String
            Return DefaultInstance.Format(d)
        End Function

        Public Shared Function FormatRelative(d As String, asOf As String) As String
            Return DefaultInstance.Relative(d, asOf)
        End Function

        Public Function Format(d As String) As String
            If String.IsNullOrEmpty(d) Then Return Nothing
            Dim parsed = ParseDate(d)
            If parsed Is Nothing Then Return Nothing
            Return FormatAbsolute(parsed(0), parsed(1), parsed(2), False)
        End Function

        Public Function FormatWithYear(d As String) As String
            If String.IsNullOrEmpty(d) Then Return Nothing
            Dim parsed = ParseDate(d)
            If parsed Is Nothing Then Return Nothing
            Return FormatAbsolute(parsed(0), parsed(1), parsed(2), True)
        End Function

        Public Function Relative(d As String, asOf As String) As String
            If String.IsNullOrEmpty(d) OrElse String.IsNullOrEmpty(asOf) Then Return Nothing
            Dim parsedDate = ParseDate(d)
            Dim parsedAsOf = ParseDate(asOf)
            If parsedDate Is Nothing OrElse parsedAsOf Is Nothing Then Return Nothing

            Dim dy = parsedDate(0)
            Dim dm = parsedDate(1)
            Dim dd = parsedDate(2)
            Dim ay = parsedAsOf(0)

            Dim dateJdn = ToJdn(dy, dm, dd)
            Dim asofJdn = ToJdn(parsedAsOf(0), parsedAsOf(1), parsedAsOf(2))
            Dim diff = dateJdn - asofJdn

            If diff = 0 Then Return _todayStr
            If diff = 1 Then Return _tomorrowStr
            If diff = -1 Then Return _yesterdayStr

            Dim isCompact = _compactness = Compactness.Compact

            ' Day after tomorrow (optional, skipped in compact mode)
            If diff = 2 AndAlso _locale.DayAfterTomorrow IsNot Nothing AndAlso Not isCompact Then
                Return _locale.DayAfterTomorrow
            End If

            ' Day before yesterday (optional, skipped in compact mode)
            If diff = -2 AndAlso _locale.DayBeforeYesterday IsNot Nothing AndAlso Not isCompact Then
                Return _locale.DayBeforeYesterday
            End If

            ' Compact mode: skip weekday references
            If isCompact Then
                Return FormatAbsolute(dy, dm, dd, dy <> ay)
            End If

            ' This weekday (+2 to +6)
            If diff >= 2 AndAlso diff <= 6 AndAlso _locale.ThisWeekday IsNot Nothing Then
                Dim dow = Weekday(dy, dm, dd)
                Dim wdName = _weekdays(dow)
                Return _locale.ThisWeekday.Replace("{weekday}", wdName)
            End If

            ' Last weekday (-6 to -2)
            If diff >= -6 AndAlso diff <= -2 AndAlso _locale.LastWeekday IsNot Nothing Then
                Dim dow = Weekday(dy, dm, dd)
                Dim wdName = _weekdays(dow)
                Return _locale.LastWeekday.Replace("{weekday}", wdName)
            End If

            ' Next weekday (+7 to +13)
            If diff >= 7 AndAlso diff <= 13 AndAlso _locale.NextWeekday IsNot Nothing Then
                Dim dow = Weekday(dy, dm, dd)
                Dim wdName = _weekdays(dow)
                Return _locale.NextWeekday.Replace("{weekday}", wdName)
            End If

            ' Calendar fallback
            Return FormatAbsolute(dy, dm, dd, dy <> ay)
        End Function

        Private Function FormatAbsolute(year As Integer, month As Integer, day As Integer, includeYear As Boolean) As String
            Dim dayStr = day.ToString()
            Dim ex As String = Nothing
            Dim fmt As String
            If _dayFormatExceptions.TryGetValue(dayStr, ex) Then
                fmt = ex
            Else
                fmt = _dayFormat
            End If
            Dim formattedDay = fmt.Replace("{n}", dayStr)

            Dim monthArr = If(_monthsInDate, _months)
            Dim monthName = monthArr(month - 1)

            Dim pattern = If(includeYear, _datePatternWithYear, _datePattern)
            Dim result = pattern.Replace("{month}", monthName)
            result = result.Replace("{day}", formattedDay)
            result = result.Replace("{d}", day.ToString())
            result = result.Replace("{m}", month.ToString())
            If includeYear Then
                result = result.Replace("{year}", year.ToString())
                Dim yy = year Mod 100
                result = result.Replace("{yy}", yy.ToString().PadLeft(2, "0"c))
            End If

            Return result
        End Function

        Friend Shared Function ParseDate(s As String) As Integer()
            If String.IsNullOrEmpty(s) Then Return Nothing
            Dim datePart As String
            If s.Contains("T"c) Then
                datePart = s.Substring(0, s.IndexOf("T"c))
            Else
                datePart = s
            End If
            Dim parts = datePart.Split("-"c)
            If parts.Length <> 3 Then Return Nothing
            Dim year, month, day As Integer
            If Not Integer.TryParse(parts(0), year) Then Return Nothing
            If Not Integer.TryParse(parts(1), month) Then Return Nothing
            If Not Integer.TryParse(parts(2), day) Then Return Nothing
            If month < 1 OrElse month > 12 OrElse day < 1 OrElse day > 31 Then Return Nothing
            Return New Integer() {year, month, day}
        End Function

        Friend Shared Function ToJdn(year As Integer, month As Integer, day As Integer) As Integer
            Dim a = (14 - month) \ 12
            Dim y = year + 4800 - a
            Dim m = month + 12 * a - 3
            Return day + (153 * m + 2) \ 5 + 365 * y + y \ 4 - y \ 100 + y \ 400 - 32045
        End Function

        Friend Shared Function Weekday(year As Integer, month As Integer, day As Integer) As Integer
            Return (ToJdn(year, month, day) + 1) Mod 7
        End Function
    End Class

End Namespace
