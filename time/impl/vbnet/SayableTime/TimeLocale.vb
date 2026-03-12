Imports System.Collections.Generic

Namespace SayableTimeLib

    Public Enum Compactness
        Normal
        [Short]
        Compact
    End Enum

    Public Class ClockConfig
        Public ReadOnly Property Hours As String()
        Public ReadOnly Property Midnight As String
        Public ReadOnly Property Noon As String
        Public ReadOnly Property Patterns As Dictionary(Of Integer, String)

        Public Sub New(hours As String(), midnight As String, noon As String,
                       patterns As Dictionary(Of Integer, String))
            Me.Hours = hours
            Me.Midnight = midnight
            Me.Noon = noon
            Me.Patterns = patterns
        End Sub
    End Class

    Public Class ShortClockConfig
        Public ReadOnly Property Use24h As Boolean
        Public ReadOnly Property AmPm As (Am As String, Pm As String)?
        Public ReadOnly Property Format As String

        Public Sub New(use24h As Boolean, amPm As (String, String)?, format As String)
            Me.Use24h = use24h
            Me.AmPm = amPm
            Me.Format = format
        End Sub
    End Class

    Public Class CompactnessOverride
        Public ReadOnly Property Clock As ShortClockConfig

        Public Sub New(Optional clock As ShortClockConfig = Nothing)
            Me.Clock = clock
        End Sub
    End Class

    Public Class TimeLocale
        Public ReadOnly Property Code As String
        Public ReadOnly Property Clock As ClockConfig
        Public ReadOnly Property ShortOverride As CompactnessOverride
        Public ReadOnly Property CompactOverride As CompactnessOverride

        Public Sub New(code As String, clock As ClockConfig,
                       Optional shortOverride As CompactnessOverride = Nothing,
                       Optional compactOverride As CompactnessOverride = Nothing)
            Me.Code = code
            Me.Clock = clock
            Me.ShortOverride = shortOverride
            Me.CompactOverride = compactOverride
        End Sub
    End Class

End Namespace
