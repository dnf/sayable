Imports System.Collections.Generic

Namespace SayableDateLib

    Public Enum Compactness
        Normal
        [Short]
        Compact
    End Enum

    Public Class CompactnessOverride
        Public ReadOnly Property Months As String()
        Public ReadOnly Property MonthsInDate As String()
        Public ReadOnly Property Weekdays As String()
        Public ReadOnly Property DayFormat As String
        Public ReadOnly Property DayFormatExceptions As IReadOnlyDictionary(Of String, String)
        Public ReadOnly Property DatePattern As String
        Public ReadOnly Property DatePatternWithYear As String
        Public ReadOnly Property Today As String
        Public ReadOnly Property Tomorrow As String
        Public ReadOnly Property Yesterday As String

        Public Sub New(Optional months As String() = Nothing, Optional monthsInDate As String() = Nothing,
                       Optional weekdays As String() = Nothing, Optional dayFormat As String = Nothing,
                       Optional dayFormatExceptions As Dictionary(Of String, String) = Nothing,
                       Optional datePattern As String = Nothing, Optional datePatternWithYear As String = Nothing,
                       Optional today As String = Nothing, Optional tomorrow As String = Nothing,
                       Optional yesterday As String = Nothing)
            Me.Months = months
            Me.MonthsInDate = monthsInDate
            Me.Weekdays = weekdays
            Me.DayFormat = dayFormat
            Me.DayFormatExceptions = dayFormatExceptions
            Me.DatePattern = datePattern
            Me.DatePatternWithYear = datePatternWithYear
            Me.Today = today
            Me.Tomorrow = tomorrow
            Me.Yesterday = yesterday
        End Sub
    End Class

    Public Class DateLocale
        Public ReadOnly Property Code As String
        Public ReadOnly Property Months As String()
        Public ReadOnly Property Weekdays As String()
        Public ReadOnly Property DayFormat As String
        Public ReadOnly Property DayFormatExceptions As IReadOnlyDictionary(Of String, String)
        Public ReadOnly Property DatePattern As String
        Public ReadOnly Property DatePatternWithYear As String
        Public ReadOnly Property Today As String
        Public ReadOnly Property Tomorrow As String
        Public ReadOnly Property Yesterday As String
        Public ReadOnly Property DayAfterTomorrow As String
        Public ReadOnly Property DayBeforeYesterday As String
        Public ReadOnly Property ThisWeekday As String
        Public ReadOnly Property NextWeekday As String
        Public ReadOnly Property LastWeekday As String
        Public ReadOnly Property MonthsInDate As String()
        Public ReadOnly Property ShortOverride As CompactnessOverride
        Public ReadOnly Property CompactOverride As CompactnessOverride

        Public Sub New(code As String, months As String(), weekdays As String(),
                       dayFormat As String,
                       Optional dayFormatExceptions As Dictionary(Of String, String) = Nothing,
                       Optional datePattern As String = "{day} {month}",
                       Optional datePatternWithYear As String = "{day} {month} {year}",
                       Optional today As String = "today", Optional tomorrow As String = "tomorrow",
                       Optional yesterday As String = "yesterday",
                       Optional dayAfterTomorrow As String = Nothing,
                       Optional dayBeforeYesterday As String = Nothing,
                       Optional thisWeekday As String = Nothing,
                       Optional nextWeekday As String = Nothing,
                       Optional lastWeekday As String = Nothing,
                       Optional monthsInDate As String() = Nothing,
                       Optional shortOverride As CompactnessOverride = Nothing,
                       Optional compactOverride As CompactnessOverride = Nothing)
            Me.Code = code
            Me.Months = months
            Me.Weekdays = weekdays
            Me.DayFormat = dayFormat
            If dayFormatExceptions IsNot Nothing Then
                Me.DayFormatExceptions = dayFormatExceptions
            Else
                Me.DayFormatExceptions = New Dictionary(Of String, String)()
            End If
            Me.DatePattern = datePattern
            Me.DatePatternWithYear = datePatternWithYear
            Me.Today = today
            Me.Tomorrow = tomorrow
            Me.Yesterday = yesterday
            Me.DayAfterTomorrow = dayAfterTomorrow
            Me.DayBeforeYesterday = dayBeforeYesterday
            Me.ThisWeekday = thisWeekday
            Me.NextWeekday = nextWeekday
            Me.LastWeekday = lastWeekday
            Me.MonthsInDate = monthsInDate
            Me.ShortOverride = shortOverride
            Me.CompactOverride = compactOverride
        End Sub
    End Class

End Namespace
