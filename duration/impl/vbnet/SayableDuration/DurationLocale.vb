Imports System
Imports System.Collections.Generic

Namespace SayableDurationLib

    Public Enum PluralCategory
        Zero
        One
        Two
        Few
        Many
        Other
    End Enum

    Public Enum Compactness
        Normal
        [Short]
        Compact
    End Enum

    Public Delegate Function PluralRule(n As Integer) As PluralCategory

    Public Class UnitForms
        Public ReadOnly Property SimpleTemplate As String
        Public ReadOnly Property Forms As IReadOnlyDictionary(Of PluralCategory, String)

        Private Sub New(simple As String, forms As IReadOnlyDictionary(Of PluralCategory, String))
            Me.SimpleTemplate = simple
            Me.Forms = forms
        End Sub

        Public Shared Function Simple(template As String) As UnitForms
            Return New UnitForms(template, Nothing)
        End Function

        Public Shared Function Plural(forms As Dictionary(Of PluralCategory, String)) As UnitForms
            Return New UnitForms(Nothing, forms)
        End Function
    End Class

    Public Class Units
        Public ReadOnly Property Second As UnitForms
        Public ReadOnly Property Minute As UnitForms
        Public ReadOnly Property Hour As UnitForms
        Public ReadOnly Property Day As UnitForms
        Public ReadOnly Property Week As UnitForms
        Public ReadOnly Property Month As UnitForms
        Public ReadOnly Property Year As UnitForms

        Public Sub New(second As UnitForms, minute As UnitForms, hour As UnitForms,
                       day As UnitForms, week As UnitForms, month As UnitForms, year As UnitForms)
            Me.Second = second
            Me.Minute = minute
            Me.Hour = hour
            Me.Day = day
            Me.Week = week
            Me.Month = month
            Me.Year = year
        End Sub
    End Class

    Public Class CompactnessOverride
        Public ReadOnly Property Second As UnitForms
        Public ReadOnly Property Minute As UnitForms
        Public ReadOnly Property Hour As UnitForms
        Public ReadOnly Property Day As UnitForms
        Public ReadOnly Property Week As UnitForms
        Public ReadOnly Property Month As UnitForms
        Public ReadOnly Property Year As UnitForms
        Public ReadOnly Property Half As String
        Public ReadOnly Property Delimiter As String
        Public ReadOnly Property Ago As String
        Public ReadOnly Property InFuture As String

        Public Sub New(Optional second As UnitForms = Nothing, Optional minute As UnitForms = Nothing,
                       Optional hour As UnitForms = Nothing, Optional day As UnitForms = Nothing,
                       Optional week As UnitForms = Nothing, Optional month As UnitForms = Nothing,
                       Optional year As UnitForms = Nothing, Optional half As String = Nothing,
                       Optional delimiter As String = Nothing, Optional ago As String = Nothing,
                       Optional inFuture As String = Nothing)
            Me.Second = second
            Me.Minute = minute
            Me.Hour = hour
            Me.Day = day
            Me.Week = week
            Me.Month = month
            Me.Year = year
            Me.Half = half
            Me.Delimiter = delimiter
            Me.Ago = ago
            Me.InFuture = inFuture
        End Sub
    End Class

    Public Class DurationLocale
        Public ReadOnly Property Code As String
        Public ReadOnly Property Plural As PluralRule
        Public ReadOnly Property Units As Units
        Public ReadOnly Property Half As String
        Public ReadOnly Property Delimiter As String
        Public ReadOnly Property JustNow As String
        Public ReadOnly Property Ago As String
        Public ReadOnly Property InFuture As String
        Public ReadOnly Property ShortOverride As CompactnessOverride
        Public ReadOnly Property CompactOverride As CompactnessOverride
        Public ReadOnly Property FormatNumber As Func(Of Integer, String)
        Public ReadOnly Property FormatUnit As Func(Of Integer, String, String)

        Public Sub New(code As String, plural As PluralRule, units As Units,
                       half As String, delimiter As String, justNow As String,
                       ago As String, inFuture As String,
                       Optional shortOverride As CompactnessOverride = Nothing,
                       Optional compactOverride As CompactnessOverride = Nothing,
                       Optional formatNumber As Func(Of Integer, String) = Nothing,
                       Optional formatUnit As Func(Of Integer, String, String) = Nothing)
            Me.Code = code
            Me.Plural = plural
            Me.Units = units
            Me.Half = half
            Me.Delimiter = delimiter
            Me.JustNow = justNow
            Me.Ago = ago
            Me.InFuture = inFuture
            Me.ShortOverride = shortOverride
            Me.CompactOverride = compactOverride
            Me.FormatNumber = formatNumber
            Me.FormatUnit = formatUnit
        End Sub
    End Class

End Namespace
