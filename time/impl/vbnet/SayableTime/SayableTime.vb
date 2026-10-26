Imports System
Imports System.Globalization
Imports System.Text.RegularExpressions

Namespace SayableTimeLib

    Public Class SayableTime
        Public Const Version As String = "0.5.0"

        Private ReadOnly _locale As TimeLocale
        Private ReadOnly _shortClock As ShortClockConfig

        Private Shared ReadOnly DefaultInstance As New SayableTime(Locales.EN)

        Public Sub New(locale As TimeLocale, Optional compactness As Compactness = Compactness.Normal)
            _locale = locale
            Dim ovr As CompactnessOverride = Nothing
            Select Case compactness
                Case Compactness.Short
                    ovr = locale.ShortOverride
                Case Compactness.Compact
                    ovr = locale.CompactOverride
            End Select
            If ovr IsNot Nothing Then _shortClock = ovr.Clock Else _shortClock = Nothing
        End Sub

        Public Shared Function FormatTime(input As String) As String
            Return DefaultInstance.Format(input)
        End Function

        Public Function Format(input As String) As String
            If String.IsNullOrEmpty(input) Then Return Nothing
            Dim parsed = ParseTime(input)
            If parsed Is Nothing Then Return Nothing

            If _shortClock IsNot Nothing Then
                Return FormatDigital(parsed(0), parsed(1))
            End If
            Return FormatNatural(parsed(0), parsed(1))
        End Function

        Private Function FormatNatural(hour As Integer, minute As Integer) As String
            Dim clock = _locale.Clock
            Dim rounded = RoundTo5(minute)
            Dim h = hour
            If rounded = 60 Then
                rounded = 0
                h = (h + 1) Mod 24
            End If
            If rounded = 0 Then
                If h = 0 Then Return clock.Midnight
                If h = 12 Then Return clock.Noon
            End If
            Dim h12 = h Mod 12
            Dim nextH12 = (h + 1) Mod 12
            Dim hName = clock.Hours(h12)
            Dim nextHName = clock.Hours(nextH12)
            Dim p As String = Nothing
            Dim p0 As String = Nothing
            Dim pattern As String
            If clock.Patterns.TryGetValue(rounded, p) Then
                pattern = p
            ElseIf clock.Patterns.TryGetValue(0, p0) Then
                pattern = p0
            Else
                pattern = "{h}"
            End If
            Return pattern.Replace("{h}", hName).Replace("{next_h}", nextHName)
        End Function

        Private Function FormatDigital(hour As Integer, minute As Integer) As String
            Dim sc = _shortClock
            Dim fmt = sc.Format
            If sc.Use24h Then
                Return fmt.Replace("{h}", hour.ToString()).Replace("{mm}", minute.ToString().PadLeft(2, "0"c))
            End If
            Dim h12 = hour Mod 12
            If h12 = 0 Then h12 = 12
            Dim amPm As (Am As String, Pm As String)
            If sc.AmPm.HasValue Then
                amPm = sc.AmPm.Value
            Else
                amPm = ("AM", "PM")
            End If
            Dim ampmStr As String
            If hour < 12 Then ampmStr = amPm.Am Else ampmStr = amPm.Pm
            Return fmt.Replace("{h}", h12.ToString()).Replace("{mm}", minute.ToString().PadLeft(2, "0"c)).Replace("{ampm}", ampmStr)
        End Function

        ''' <summary>H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored).</summary>
        Private Shared ReadOnly Clock As New Regex(
            "\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z",
            RegexOptions.CultureInvariant)

        Private Shared ReadOnly DateOnly As New Regex(
            "\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z", RegexOptions.CultureInvariant)

        Friend Shared Function ParseTime(input As String) As Integer()
            If String.IsNullOrEmpty(input) Then Return Nothing
            Dim clockPart = input
            Dim tIdx = input.IndexOf("T"c)
            If tIdx >= 0 Then
                If Not IsRealDate(input.Substring(0, tIdx)) Then Return Nothing
                clockPart = input.Substring(tIdx + 1)
            End If
            Dim match = Clock.Match(clockPart)
            If Not match.Success Then Return Nothing
            Dim hour = Field(match, 1)
            Dim minute = Field(match, 2)
            Dim second = If(match.Groups(3).Success, Field(match, 3), 0)
            If hour > 23 OrElse minute > 59 OrElse second > 59 Then Return Nothing
            Return New Integer() {hour, minute}
        End Function

        Private Shared Function IsRealDate(s As String) As Boolean
            Dim match = DateOnly.Match(s)
            If Not match.Success Then Return False
            Dim month = Field(match, 2)
            Dim day = Field(match, 3)
            Return month >= 1 AndAlso month <= 12 AndAlso day >= 1 AndAlso day <= DaysInMonth(Field(match, 1), month)
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

        Private Shared Function Field(match As Match, group As Integer) As Integer
            Return Integer.Parse(match.Groups(group).Value, CultureInfo.InvariantCulture)
        End Function

        Friend Shared Function RoundTo5(minute As Integer) As Integer
            Return ((minute + 2) \ 5) * 5
        End Function
    End Class

End Namespace
