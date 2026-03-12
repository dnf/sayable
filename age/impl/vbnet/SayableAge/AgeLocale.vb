Imports System
Imports System.Collections.Generic

Namespace SayableAgeLib

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

    Public Class StageLabel
        Private ReadOnly _label As String
        Private ReadOnly _m As String
        Private ReadOnly _f As String

        Private Sub New(label As String, m As String, f As String)
            _label = label
            _m = m
            _f = f
        End Sub

        Public Shared Function Neutral(label As String) As StageLabel
            Return New StageLabel(label, Nothing, Nothing)
        End Function

        Public Shared Function Gendered(m As String, f As String) As StageLabel
            Return New StageLabel(Nothing, m, f)
        End Function

        Public Function Resolve(gender As String) As String
            If _label IsNot Nothing Then Return _label
            If gender = "f" Then Return _f
            Return _m
        End Function
    End Class

    Public Class Units
        Public ReadOnly Property Day As UnitForms
        Public ReadOnly Property Week As UnitForms
        Public ReadOnly Property Month As UnitForms
        Public ReadOnly Property Year As UnitForms

        Public Sub New(day As UnitForms, week As UnitForms, month As UnitForms, year As UnitForms)
            Me.Day = day
            Me.Week = week
            Me.Month = month
            Me.Year = year
        End Sub
    End Class

    Public Class Stages
        Public ReadOnly Property Newborn As StageLabel
        Public ReadOnly Property Infant As StageLabel
        Public ReadOnly Property Toddler As StageLabel
        Public ReadOnly Property Child As StageLabel
        Public ReadOnly Property Teenager As StageLabel
        Public ReadOnly Property Adult As StageLabel

        Public Sub New(newborn As StageLabel, infant As StageLabel, toddler As StageLabel,
                       child As StageLabel, teenager As StageLabel, adult As StageLabel)
            Me.Newborn = newborn
            Me.Infant = infant
            Me.Toddler = toddler
            Me.Child = child
            Me.Teenager = teenager
            Me.Adult = adult
        End Sub
    End Class

    Public Class CompactnessOverride
        Public ReadOnly Property Day As UnitForms
        Public ReadOnly Property Week As UnitForms
        Public ReadOnly Property Month As UnitForms
        Public ReadOnly Property Year As UnitForms
        Public ReadOnly Property Half As String
        Public ReadOnly Property Delimiter As String
        Public ReadOnly Property JustBorn As String

        Public Sub New(day As UnitForms, week As UnitForms, month As UnitForms,
                       year As UnitForms, half As String, delimiter As String,
                       justBorn As String)
            Me.Day = day
            Me.Week = week
            Me.Month = month
            Me.Year = year
            Me.Half = half
            Me.Delimiter = delimiter
            Me.JustBorn = justBorn
        End Sub
    End Class

    Public Class AgeLocale
        Public ReadOnly Property Code As String
        Public ReadOnly Property Plural As PluralRule
        Public ReadOnly Property Units As Units
        Public ReadOnly Property Half As String
        Public ReadOnly Property Delimiter As String
        Public ReadOnly Property JustBorn As String
        Public ReadOnly Property Stages As Stages
        Public ReadOnly Property ShortOverride As CompactnessOverride
        Public ReadOnly Property CompactOverride As CompactnessOverride
        Public ReadOnly Property FormatNumber As Func(Of Integer, String)
        Public ReadOnly Property FormatUnit As Func(Of Integer, String, String)

        Public Sub New(code As String, plural As PluralRule, units As Units,
                       half As String, delimiter As String, justBorn As String,
                       stages As Stages,
                       Optional shortOverride As CompactnessOverride = Nothing,
                       Optional compactOverride As CompactnessOverride = Nothing,
                       Optional formatNumber As Func(Of Integer, String) = Nothing,
                       Optional formatUnit As Func(Of Integer, String, String) = Nothing)
            Me.Code = code
            Me.Plural = plural
            Me.Units = units
            Me.Half = half
            Me.Delimiter = delimiter
            Me.JustBorn = justBorn
            Me.Stages = stages
            Me.ShortOverride = shortOverride
            Me.CompactOverride = compactOverride
            Me.FormatNumber = formatNumber
            Me.FormatUnit = formatUnit
        End Sub
    End Class

End Namespace
