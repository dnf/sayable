Imports System
Imports System.Collections.Generic
Imports System.Reflection

Imports AgeLib = SayableAgeLib
Imports DateLib = SayableDateLib
Imports TimeLib = SayableTimeLib
Imports DurationLib = SayableDurationLib

Module Program

    Private Const VersionStr As String = "0.5.0"

    Private Const HelpText As String =
"Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version"

    Private _ageLocales As Dictionary(Of String, AgeLib.AgeLocale)
    Private _dateLocales As Dictionary(Of String, DateLib.DateLocale)
    Private _timeLocales As Dictionary(Of String, TimeLib.TimeLocale)
    Private _durationLocales As Dictionary(Of String, DurationLib.DurationLocale)

    Private Function BuildAgeLocales() As Dictionary(Of String, AgeLib.AgeLocale)
        Dim dict As New Dictionary(Of String, AgeLib.AgeLocale)()
        For Each field In GetType(AgeLib.Locales).GetFields(BindingFlags.Public Or BindingFlags.Static)
            If field.FieldType Is GetType(AgeLib.AgeLocale) Then
                Dim locale = DirectCast(field.GetValue(Nothing), AgeLib.AgeLocale)
                If locale IsNot Nothing Then
                    dict(locale.Code) = locale
                End If
            End If
        Next
        Return dict
    End Function

    Private Function BuildDateLocales() As Dictionary(Of String, DateLib.DateLocale)
        Dim dict As New Dictionary(Of String, DateLib.DateLocale)()
        For Each field In GetType(DateLib.Locales).GetFields(BindingFlags.Public Or BindingFlags.Static)
            If field.FieldType Is GetType(DateLib.DateLocale) Then
                Dim locale = DirectCast(field.GetValue(Nothing), DateLib.DateLocale)
                If locale IsNot Nothing Then
                    dict(locale.Code) = locale
                End If
            End If
        Next
        Return dict
    End Function

    Private Function BuildTimeLocales() As Dictionary(Of String, TimeLib.TimeLocale)
        Dim dict As New Dictionary(Of String, TimeLib.TimeLocale)()
        For Each field In GetType(TimeLib.Locales).GetFields(BindingFlags.Public Or BindingFlags.Static)
            If field.FieldType Is GetType(TimeLib.TimeLocale) Then
                Dim locale = DirectCast(field.GetValue(Nothing), TimeLib.TimeLocale)
                If locale IsNot Nothing Then
                    dict(locale.Code) = locale
                End If
            End If
        Next
        Return dict
    End Function

    Private Function BuildDurationLocales() As Dictionary(Of String, DurationLib.DurationLocale)
        Dim dict As New Dictionary(Of String, DurationLib.DurationLocale)()
        For Each field In GetType(DurationLib.Locales).GetFields(BindingFlags.Public Or BindingFlags.Static)
            If field.FieldType Is GetType(DurationLib.DurationLocale) Then
                Dim locale = DirectCast(field.GetValue(Nothing), DurationLib.DurationLocale)
                If locale IsNot Nothing Then
                    dict(locale.Code) = locale
                End If
            End If
        Next
        Return dict
    End Function

    Private Function GetAgeLocales() As Dictionary(Of String, AgeLib.AgeLocale)
        If _ageLocales Is Nothing Then
            _ageLocales = BuildAgeLocales()
        End If
        Return _ageLocales
    End Function

    Private Function GetDateLocales() As Dictionary(Of String, DateLib.DateLocale)
        If _dateLocales Is Nothing Then
            _dateLocales = BuildDateLocales()
        End If
        Return _dateLocales
    End Function

    Private Function GetTimeLocales() As Dictionary(Of String, TimeLib.TimeLocale)
        If _timeLocales Is Nothing Then
            _timeLocales = BuildTimeLocales()
        End If
        Return _timeLocales
    End Function

    Private Function GetDurationLocales() As Dictionary(Of String, DurationLib.DurationLocale)
        If _durationLocales Is Nothing Then
            _durationLocales = BuildDurationLocales()
        End If
        Return _durationLocales
    End Function

    Function Main(args As String()) As Integer
        Dim parsed = ParseArgs(args)
        Dim command = parsed.Command
        Dim positionals = parsed.Positionals
        Dim opts = parsed.Opts

        Select Case command
            Case Nothing
                Console.WriteLine(HelpText)
                Return 2
            Case "help"
                Console.WriteLine(HelpText)
                Return 0
            Case "version"
                Console.WriteLine("sayable " & VersionStr)
                Return 0
            Case "locales"
                Return CmdLocales()
            Case "age"
                Return CmdAge(positionals, opts)
            Case "stage"
                Return CmdStage(positionals, opts)
            Case "date"
                Return CmdDate(positionals, opts)
            Case "relative"
                Return CmdRelative(positionals, opts)
            Case "time"
                Return CmdTime(positionals, opts)
            Case "duration"
                Return CmdDuration(positionals, opts)
            Case "since"
                Return CmdSince(positionals, opts)
            Case "until"
                Return CmdUntil(positionals, opts)
            Case Else
                Return PrintError("unknown command '" & command & "'")
        End Select
    End Function

    Private Function ParseArgs(argv As String()) As ParseResult
        If argv.Length = 0 Then
            Return New ParseResult(Nothing, New List(Of String)(), New Options())
        End If

        If argv(0) = "-h" OrElse argv(0) = "--help" OrElse argv(0) = "help" Then
            Return New ParseResult("help", New List(Of String)(), New Options())
        End If
        If argv(0) = "-v" OrElse argv(0) = "--version" OrElse argv(0) = "version" Then
            Return New ParseResult("version", New List(Of String)(), New Options())
        End If

        Dim command = argv(0)
        Dim positionals As New List(Of String)()
        Dim opts As New Options()

        Dim i = 1
        Dim stopOpts = False
        While i < argv.Length
            Dim arg = argv(i)

            If arg = "--" AndAlso Not stopOpts Then
                stopOpts = True
                i += 1
                Continue While
            End If

            If Not stopOpts AndAlso arg.StartsWith("-") Then
                If arg = "-l" OrElse arg = "--locale" Then
                    If i + 1 >= argv.Length Then
                        ErrorExit("'" & arg & "' requires a value")
                    End If
                    i += 1
                    opts.Locale = argv(i)
                ElseIf arg = "-d" OrElse arg = "--as-of" Then
                    If i + 1 >= argv.Length Then
                        ErrorExit("'" & arg & "' requires a value")
                    End If
                    i += 1
                    opts.AsOf = argv(i)
                ElseIf arg = "-g" OrElse arg = "--gender" Then
                    If i + 1 >= argv.Length Then
                        ErrorExit("'" & arg & "' requires a value")
                    End If
                    i += 1
                    opts.Gender = argv(i)
                ElseIf arg = "--short" Then
                    opts.Compactness = "short"
                ElseIf arg = "--compact" Then
                    opts.Compactness = "compact"
                ElseIf arg = "--with-year" Then
                    opts.WithYear = True
                ElseIf arg = "-h" OrElse arg = "--help" Then
                    Return New ParseResult("help", New List(Of String)(), New Options())
                ElseIf arg = "-v" OrElse arg = "--version" Then
                    Return New ParseResult("version", New List(Of String)(), New Options())
                Else
                    ErrorExit("unknown option '" & arg & "'")
                End If
            Else
                positionals.Add(arg)
            End If

            i += 1
        End While

        Return New ParseResult(command, positionals, opts)
    End Function

    Private Function Nullify(value As String) As String
        If value = "null" Then Return Nothing
        Return value
    End Function

    Private Function GetToday() As String
        Return DateTime.Today.ToString("yyyy-MM-dd")
    End Function

    Private Function ToAgeCompactness(compactness As String) As AgeLib.Compactness
        Select Case compactness
            Case "short"
                Return AgeLib.Compactness.Short
            Case "compact"
                Return AgeLib.Compactness.Compact
            Case Else
                Return AgeLib.Compactness.Normal
        End Select
    End Function

    Private Function ToDateCompactness(compactness As String) As DateLib.Compactness
        Select Case compactness
            Case "short"
                Return DateLib.Compactness.Short
            Case "compact"
                Return DateLib.Compactness.Compact
            Case Else
                Return DateLib.Compactness.Normal
        End Select
    End Function

    Private Function ToTimeCompactness(compactness As String) As TimeLib.Compactness
        Select Case compactness
            Case "short"
                Return TimeLib.Compactness.Short
            Case "compact"
                Return TimeLib.Compactness.Compact
            Case Else
                Return TimeLib.Compactness.Normal
        End Select
    End Function

    Private Function ToDurationCompactness(compactness As String) As DurationLib.Compactness
        Select Case compactness
            Case "short"
                Return DurationLib.Compactness.Short
            Case "compact"
                Return DurationLib.Compactness.Compact
            Case Else
                Return DurationLib.Compactness.Normal
        End Select
    End Function

    Private Function CmdAge(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("age requires a date-of-birth argument")
        End If

        Dim dob = Nullify(positionals(0))
        Dim localeCode = opts.Locale
        Dim locales = GetAgeLocales()
        Dim locale As AgeLib.AgeLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim asOf As String
        If opts.AsOf IsNot Nothing Then
            asOf = Nullify(opts.AsOf)
        Else
            asOf = GetToday()
        End If

        Dim formatter As New AgeLib.SayableAgeFormatter(locale, ToAgeCompactness(opts.Compactness))
        Dim result = formatter.FormatAge(dob, asOf)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdStage(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("stage requires a date-of-birth argument")
        End If

        Dim dob = Nullify(positionals(0))
        Dim localeCode = opts.Locale
        Dim locales = GetAgeLocales()
        Dim locale As AgeLib.AgeLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim asOf As String
        If opts.AsOf IsNot Nothing Then
            asOf = Nullify(opts.AsOf)
        Else
            asOf = GetToday()
        End If

        Dim gender = opts.Gender

        Dim formatter As New AgeLib.SayableAgeFormatter(locale, ToAgeCompactness(opts.Compactness))
        Dim result = formatter.FormatStage(dob, asOf, gender)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdDate(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("date requires a date argument")
        End If

        Dim dateVal = Nullify(positionals(0))
        Dim localeCode = opts.Locale
        Dim locales = GetDateLocales()
        Dim locale As DateLib.DateLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New DateLib.SayableDate(locale, ToDateCompactness(opts.Compactness))

        Dim result As String
        If opts.WithYear Then
            result = formatter.FormatWithYear(dateVal)
        Else
            result = formatter.Format(dateVal)
        End If

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdRelative(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("relative requires a date argument")
        End If

        Dim dateVal = Nullify(positionals(0))

        If opts.AsOf Is Nothing Then
            Return PrintError("relative requires --as-of / -d option")
        End If

        Dim asOf = Nullify(opts.AsOf)
        Dim localeCode = opts.Locale
        Dim locales = GetDateLocales()
        Dim locale As DateLib.DateLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New DateLib.SayableDate(locale, ToDateCompactness(opts.Compactness))
        Dim result = formatter.Relative(dateVal, asOf)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdTime(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("time requires a time argument")
        End If

        Dim timeVal = Nullify(positionals(0))
        Dim localeCode = opts.Locale
        Dim locales = GetTimeLocales()
        Dim locale As TimeLib.TimeLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New TimeLib.SayableTime(locale, ToTimeCompactness(opts.Compactness))
        Dim result = formatter.Format(timeVal)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdDuration(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("duration requires a value argument")
        End If

        Dim value = Nullify(positionals(0))
        Dim localeCode = opts.Locale
        Dim locales = GetDurationLocales()
        Dim locale As DurationLib.DurationLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New DurationLib.SayableDuration(locale, ToDurationCompactness(opts.Compactness))

        Dim result As String
        If value Is Nothing Then
            Return 1
        ElseIf IsInteger(value) Then
            Dim seconds = Integer.Parse(value)
            result = formatter.FormatDuration(seconds)
        Else
            If positionals.Count < 2 Then
                Return PrintError("duration with timestamps requires start and end arguments")
            End If
            Dim endVal = positionals(1)
            result = formatter.FormatIso(value, endVal)
        End If

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdSince(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("since requires a start timestamp argument")
        End If

        Dim start = Nullify(positionals(0))

        If opts.AsOf Is Nothing Then
            Return PrintError("since requires --as-of / -d option")
        End If

        Dim asOf = Nullify(opts.AsOf)
        Dim localeCode = opts.Locale
        Dim locales = GetDurationLocales()
        Dim locale As DurationLib.DurationLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New DurationLib.SayableDuration(locale, ToDurationCompactness(opts.Compactness))
        Dim result = formatter.Since(start, asOf)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdUntil(positionals As List(Of String), opts As Options) As Integer
        If positionals.Count = 0 Then
            Return PrintError("until requires a target timestamp argument")
        End If

        Dim target = Nullify(positionals(0))

        If opts.AsOf Is Nothing Then
            Return PrintError("until requires --as-of / -d option")
        End If

        Dim asOf = Nullify(opts.AsOf)
        Dim localeCode = opts.Locale
        Dim locales = GetDurationLocales()
        Dim locale As DurationLib.DurationLocale = Nothing

        If Not locales.TryGetValue(localeCode, locale) Then
            Return PrintError("unknown locale '" & localeCode & "'")
        End If

        Dim formatter As New DurationLib.SayableDuration(locale, ToDurationCompactness(opts.Compactness))
        Dim result = formatter.Until(target, asOf)

        If result Is Nothing Then Return 1
        Console.WriteLine(result)
        Return 0
    End Function

    Private Function CmdLocales() As Integer
        Dim codes As New SortedSet(Of String)()
        For Each kvp In GetAgeLocales()
            codes.Add(kvp.Key)
        Next
        For Each code In codes
            Console.WriteLine(code)
        Next
        Return 0
    End Function

    Private Function IsInteger(s As String) As Boolean
        If String.IsNullOrEmpty(s) Then Return False
        Dim startIdx = 0
        If s(0) = "-"c Then
            If s.Length = 1 Then Return False
            startIdx = 1
        End If
        For i = startIdx To s.Length - 1
            If s(i) < "0"c OrElse s(i) > "9"c Then Return False
        Next
        Return True
    End Function

    Private Function PrintError(msg As String) As Integer
        Console.Error.WriteLine("error: " & msg)
        Console.Error.WriteLine("Run 'sayable help' for usage.")
        Return 2
    End Function

    Private Sub ErrorExit(msg As String)
        Console.Error.WriteLine("error: " & msg)
        Console.Error.WriteLine("Run 'sayable help' for usage.")
        Environment.Exit(2)
    End Sub

End Module

Class ParseResult
    Public ReadOnly Property Command As String
    Public ReadOnly Property Positionals As List(Of String)
    Public ReadOnly Property Opts As Options

    Public Sub New(command As String, positionals As List(Of String), opts As Options)
        Me.Command = command
        Me.Positionals = positionals
        Me.Opts = opts
    End Sub
End Class

Class Options
    Public Property Locale As String = "en"
    Public Property AsOf As String = Nothing
    Public Property Compactness As String = "normal"
    Public Property Gender As String = Nothing
    Public Property WithYear As Boolean = False
End Class
