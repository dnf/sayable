Imports System

Namespace SayableAgeLib

    Public Class SayableAgeFormatter
        Public Const Version As String = "0.5.0"

        Private Const MaxAgeMonths As Integer = 6000

        Private ReadOnly _locale As AgeLocale
        Private ReadOnly _day As UnitForms
        Private ReadOnly _week As UnitForms
        Private ReadOnly _month As UnitForms
        Private ReadOnly _year As UnitForms
        Private ReadOnly _half As String
        Private ReadOnly _delimiter As String
        Private ReadOnly _justBorn As String

        Friend Shared TimeNow As Func(Of DateTime) = Function() DateTime.Today

        Public Sub New(locale As AgeLocale, Optional compactness As Compactness = Compactness.Normal)
            _locale = locale

            Dim d = locale.Units.Day
            Dim w = locale.Units.Week
            Dim m = locale.Units.Month
            Dim y = locale.Units.Year
            Dim h = locale.Half
            Dim del2 = locale.Delimiter
            Dim jb = locale.JustBorn

            Dim ovr As CompactnessOverride = Nothing
            Select Case compactness
                Case Compactness.Short
                    ovr = locale.ShortOverride
                Case Compactness.Compact
                    ovr = locale.CompactOverride
            End Select

            If ovr IsNot Nothing Then
                If ovr.Day IsNot Nothing Then d = ovr.Day
                If ovr.Week IsNot Nothing Then w = ovr.Week
                If ovr.Month IsNot Nothing Then m = ovr.Month
                If ovr.Year IsNot Nothing Then y = ovr.Year
                If ovr.Half IsNot Nothing Then h = ovr.Half
                If ovr.Delimiter IsNot Nothing Then del2 = ovr.Delimiter
                If ovr.JustBorn IsNot Nothing Then jb = ovr.JustBorn
            End If

            _day = d
            _week = w
            _month = m
            _year = y
            _half = h
            _delimiter = del2
            _justBorn = jb
        End Sub

        Private Shared Function ParseAge(dateOfBirth As String, asOf As String) As Integer()
            If String.IsNullOrEmpty(dateOfBirth) Then Return Nothing

            Dim dobParts = ParseDateParts(dateOfBirth)
            If dobParts Is Nothing Then Return Nothing
            Dim dobY = dobParts(0)
            Dim dobM = dobParts(1)
            Dim dobD = dobParts(2)

            Dim refY, refM, refD As Integer
            If Not String.IsNullOrEmpty(asOf) Then
                Dim refParts = ParseDateParts(asOf)
                If refParts Is Nothing Then Return Nothing
                refY = refParts(0)
                refM = refParts(1)
                refD = refParts(2)
            Else
                Dim now = TimeNow()
                refY = now.Year
                refM = now.Month
                refD = now.Day
            End If

            Dim diffDays = JulianDay(refY, refM, refD) - JulianDay(dobY, dobM, dobD)
            If diffDays < 0 Then Return Nothing

            Dim lastDay = DaysInMonth(refY, refM)
            Dim clampedBirthday = Math.Min(dobD, lastDay)
            Dim months = (refY - dobY) * 12 + (refM - dobM)
            If refD < clampedBirthday Then months -= 1
            If months > MaxAgeMonths Then Return Nothing

            Return New Integer() {months, diffDays}
        End Function

        ''' <summary>Parses exactly YYYY-MM-DD naming a real calendar day; Nothing otherwise.</summary>
        Private Shared Function ParseDateParts(s As String) As Integer()
            If s.Length <> 10 OrElse s(4) <> "-"c OrElse s(7) <> "-"c Then Return Nothing
            Dim y = SafeAtoi(s, 0, 4)
            Dim m = SafeAtoi(s, 5, 7)
            Dim d = SafeAtoi(s, 8, 10)
            If y < 0 OrElse m < 1 OrElse m > 12 OrElse d < 1 OrElse d > DaysInMonth(y, m) Then Return Nothing
            Return New Integer() {y, m, d}
        End Function

        ' DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
        Private Shared Function DaysInMonth(year As Integer, month As Integer) As Integer
            Select Case month
                Case 2
                    Return If((year Mod 4 = 0 AndAlso year Mod 100 <> 0) OrElse year Mod 400 = 0, 29, 28)
                Case 4, 6, 9, 11
                    Return 30
                Case Else
                    Return 31
            End Select
        End Function

        Private Shared Function JulianDay(year As Integer, month As Integer, day As Integer) As Integer
            Dim a = (14 - month) \ 12
            Dim y = year + 4800 - a
            Dim m = month + 12 * a - 3
            Return day + (153 * m + 2) \ 5 + 365 * y + y \ 4 - y \ 100 + y \ 400 - 32045
        End Function

        Private Shared Function SafeAtoi(s As String, from2 As Integer, [to] As Integer) As Integer
            Dim n = 0
            For i = from2 To [to] - 1
                Dim c = s(i)
                If c < "0"c OrElse c > "9"c Then Return -1
                n = n * 10 + (AscW(c) - AscW("0"c))
            Next
            Return n
        End Function

        Private Shared Function StageKey(months As Integer) As String
            If months < 2 Then Return "newborn"
            If months < 12 Then Return "infant"
            If months < 36 Then Return "toddler"
            If months < 156 Then Return "child"
            If months < 216 Then Return "teenager"
            Return "adult"
        End Function

        Private Function ResolveUnit(count As Integer, uf As UnitForms, half As String) As String
            Dim baseN As String
            If _locale.FormatNumber IsNot Nothing Then
                baseN = _locale.FormatNumber(count)
            Else
                baseN = count.ToString()
            End If

            Dim n As String
            If half.Length > 0 AndAlso half.Contains("{n}") Then
                n = half.Replace("{n}", baseN)
            Else
                n = baseN
            End If

            Dim template As String
            If uf.SimpleTemplate IsNot Nothing Then
                template = uf.SimpleTemplate
            Else
                Dim cat = _locale.Plural(count)
                Dim form As String = Nothing
                If Not uf.Forms.TryGetValue(cat, form) Then
                    uf.Forms.TryGetValue(PluralCategory.Other, form)
                End If
                template = If(form, "{n}")
            End If

            Dim result = template.Replace("{n}", n)

            If _locale.FormatUnit IsNot Nothing Then
                result = _locale.FormatUnit(count, result)
            End If

            If half.Length > 0 AndAlso half.Contains("{0}") Then
                result = half.Replace("{0}", result)
            End If

            Return result
        End Function

        Public Function FormatAge(dateOfBirth As String, Optional asOf As String = Nothing) As String
            Dim age = ParseAge(dateOfBirth, asOf)
            If age Is Nothing Then Return Nothing

            Dim months = age(0)
            Dim diffDays = age(1)

            ' Tier 1: 0 days
            If diffDays = 0 Then Return _justBorn

            ' Tier 1b: 1-6 days
            If diffDays < 7 Then Return ResolveUnit(diffDays, _day, "")

            ' Tier 2: weeks + days until 3 calendar months
            If months < 3 Then
                Dim weeks = diffDays \ 7
                Dim days = diffDays Mod 7
                Dim result = ResolveUnit(weeks, _week, "")
                If days > 0 Then
                    result += _delimiter + ResolveUnit(days, _day, "")
                End If
                Return result
            End If

            ' Tier 3: 3-23 months
            If months < 24 Then Return ResolveUnit(months, _month, "")

            ' Tier 4: 24-35 months -> years + months
            If months < 36 Then
                Dim years = months \ 12
                Dim rem2 = months Mod 12
                If rem2 = 0 Then Return ResolveUnit(years, _year, "")
                Return ResolveUnit(years, _year, "") + _delimiter + ResolveUnit(rem2, _month, "")
            End If

            ' Tier 5: 3-6 years -> years with half marker
            If months < 84 Then
                Dim years = months \ 12
                Dim rem2 = months Mod 12
                If rem2 >= 6 Then
                    Return ResolveUnit(years, _year, _half)
                Else
                    Return ResolveUnit(years, _year, "")
                End If
            End If

            ' Tier 6: 7+ years
            Dim yrs = months \ 12
            Return ResolveUnit(yrs, _year, "")
        End Function

        Public Function FormatStage(dateOfBirth As String, Optional asOf As String = Nothing, Optional gender As String = Nothing) As String
            Dim age = ParseAge(dateOfBirth, asOf)
            If age Is Nothing Then Return Nothing

            Dim label As StageLabel
            Select Case StageKey(age(0))
                Case "newborn" : label = _locale.Stages.Newborn
                Case "infant" : label = _locale.Stages.Infant
                Case "toddler" : label = _locale.Stages.Toddler
                Case "child" : label = _locale.Stages.Child
                Case "teenager" : label = _locale.Stages.Teenager
                Case Else : label = _locale.Stages.Adult
            End Select

            Return label.Resolve(gender)
        End Function

        ' Static convenience methods using default English locale
        Private Shared ReadOnly DefaultFormatter As New SayableAgeFormatter(Locales.EN)

        Public Shared Function FormatAgeDefault(dateOfBirth As String, Optional asOf As String = Nothing) As String
            Return DefaultFormatter.FormatAge(dateOfBirth, asOf)
        End Function

        Public Shared Function FormatStageDefault(dateOfBirth As String, Optional asOf As String = Nothing, Optional gender As String = Nothing) As String
            Return DefaultFormatter.FormatStage(dateOfBirth, asOf, gender)
        End Function
    End Class

End Namespace
