#!/usr/bin/env pwsh
# Sayable CLI -- unified command-line interface to all four Sayable components.
#
# See cli/SPEC.md for the full specification.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve project root relative to this script
$script:Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))

# Import all four component modules
Import-Module "$script:Root/age/impl/powershell/SayableAge.psm1" -Force
Import-Module "$script:Root/date/impl/powershell/SayableDate.psm1" -Force
Import-Module "$script:Root/duration/impl/powershell/SayableDuration.psm1" -Force
Import-Module "$script:Root/time/impl/powershell/SayableTime.psm1" -Force

$script:VERSION = '0.5.0'

$script:HELP = @'
Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version
'@

# Usage errors are thrown, so one request can fail without ending the process.
class SayableUsageError : System.Exception {
    SayableUsageError([string]$Message) : base($Message) {}
}

function Show-Error {
    param([string]$Message)
    throw [SayableUsageError]::new($Message)
}

function ConvertTo-NullSentinel {
    param([AllowNull()][string]$Value)
    if ($Value -eq 'null') {
        return $null
    }
    return $Value
}

function Get-Today {
    return [DateTime]::Today.ToString('yyyy-MM-dd')
}

function Read-Arguments {
    param([string[]]$Argv)

    if ($Argv.Count -eq 0) {
        return @{ Command = $null; Positionals = @(); Options = @{} }
    }

    # Global flags as first argument
    if ($Argv[0] -in @('-h', '--help', 'help')) {
        return @{ Command = 'help'; Positionals = @(); Options = @{} }
    }
    if ($Argv[0] -in @('-v', '--version', 'version')) {
        return @{ Command = 'version'; Positionals = @(); Options = @{} }
    }

    $command = $Argv[0]
    $positionals = [System.Collections.ArrayList]::new()
    $options = @{
        locale      = 'en'
        as_of       = $null
        compactness = 'normal'
        gender      = $null
        with_year   = $false
    }

    $i = 1
    $stopOpts = $false
    while ($i -lt $Argv.Count) {
        $arg = $Argv[$i]

        if ($arg -eq '--' -and -not $stopOpts) {
            $stopOpts = $true
            $i++
            continue
        }

        if (-not $stopOpts -and $arg.StartsWith('-')) {
            if ($arg -in @('-l', '--locale')) {
                if ($i + 1 -ge $Argv.Count) {
                    Show-Error "'$arg' requires a value"
                }
                $i++
                $options['locale'] = $Argv[$i]
            } elseif ($arg -in @('-d', '--as-of')) {
                if ($i + 1 -ge $Argv.Count) {
                    Show-Error "'$arg' requires a value"
                }
                $i++
                $options['as_of'] = $Argv[$i]
            } elseif ($arg -in @('-g', '--gender')) {
                if ($i + 1 -ge $Argv.Count) {
                    Show-Error "'$arg' requires a value"
                }
                $i++
                $options['gender'] = $Argv[$i]
            } elseif ($arg -eq '--short') {
                $options['compactness'] = 'short'
            } elseif ($arg -eq '--compact') {
                $options['compactness'] = 'compact'
            } elseif ($arg -eq '--with-year') {
                $options['with_year'] = $true
            } elseif ($arg -in @('-h', '--help')) {
                return @{ Command = 'help'; Positionals = @(); Options = @{} }
            } elseif ($arg -in @('-v', '--version')) {
                return @{ Command = 'version'; Positionals = @(); Options = @{} }
            } else {
                Show-Error "unknown option '$arg'"
            }
        } else {
            [void]$positionals.Add($arg)
        }

        $i++
    }

    return @{
        Command      = $command
        Positionals  = [string[]]$positionals
        Options      = $options
    }
}

function Invoke-AgeCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'age requires a date-of-birth argument'
    }
    $dob = ConvertTo-NullSentinel $Positionals[0]

    $localeCode = $Options['locale']
    $locale = Get-SayableAgeLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $asOf = $Options['as_of']
    if ($null -ne $asOf) {
        $asOf = ConvertTo-NullSentinel $asOf
    } else {
        $asOf = Get-Today
    }

    $formatter = New-SayableAgeFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableAge -Formatter $formatter -DateOfBirth $dob -AsOf $asOf

    return $result
}

function Invoke-StageCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'stage requires a date-of-birth argument'
    }
    $dob = ConvertTo-NullSentinel $Positionals[0]

    $localeCode = $Options['locale']
    $locale = Get-SayableAgeLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $asOf = $Options['as_of']
    if ($null -ne $asOf) {
        $asOf = ConvertTo-NullSentinel $asOf
    } else {
        $asOf = Get-Today
    }

    $gender = $Options['gender']

    $formatter = New-SayableAgeFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableAgeStage -Formatter $formatter -DateOfBirth $dob -AsOf $asOf -Gender $gender

    return $result
}

function Invoke-DateCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'date requires a date argument'
    }
    $dateVal = ConvertTo-NullSentinel $Positionals[0]

    $localeCode = $Options['locale']
    $locale = Get-SayableDateLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableDateFormatter -Locale $locale -Compactness $Options['compactness']

    if ($Options['with_year']) {
        $result = Format-SayableDateWithYear -Formatter $formatter -Date $dateVal
    } else {
        $result = Format-SayableDate -Formatter $formatter -Date $dateVal
    }

    return $result
}

function Invoke-RelativeCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'relative requires a date argument'
    }
    $dateVal = ConvertTo-NullSentinel $Positionals[0]

    $asOf = $Options['as_of']
    if ($null -eq $asOf) {
        Show-Error 'relative requires --as-of / -d option'
    }
    $asOf = ConvertTo-NullSentinel $asOf

    $localeCode = $Options['locale']
    $locale = Get-SayableDateLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableDateFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableRelativeDate -Formatter $formatter -Date $dateVal -AsOf $asOf

    return $result
}

function Invoke-TimeCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'time requires a time argument'
    }
    $timeVal = ConvertTo-NullSentinel $Positionals[0]

    $localeCode = $Options['locale']
    $locale = Get-SayableTimeLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableTimeFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableTime -Formatter $formatter -InputStr $timeVal

    return $result
}

function Invoke-DurationCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'duration requires a value argument'
    }
    $value = ConvertTo-NullSentinel $Positionals[0]

    $localeCode = $Options['locale']
    $locale = Get-SayableDurationLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableDurationFormatter -Locale $locale -Compactness $Options['compactness']

    if ($null -eq $value) {
        $result = Format-SayableDuration -Formatter $formatter -StartOrSeconds $null
    } elseif ($value -match '^-?\d+$') {
        $result = Format-SayableDuration -Formatter $formatter -StartOrSeconds ([int]$value)
    } else {
        # Timestamp mode: need an end argument
        if ($Positionals.Count -lt 2) {
            Show-Error 'duration with timestamps requires start and end arguments'
        }
        $end = ConvertTo-NullSentinel $Positionals[1]
        $result = Format-SayableDuration -Formatter $formatter -StartOrSeconds $value -End $end
    }

    return $result
}

function Invoke-SinceCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'since requires a start timestamp argument'
    }
    $start = ConvertTo-NullSentinel $Positionals[0]

    $asOf = $Options['as_of']
    if ($null -eq $asOf) {
        Show-Error 'since requires --as-of / -d option'
    }
    $asOf = ConvertTo-NullSentinel $asOf

    $localeCode = $Options['locale']
    $locale = Get-SayableDurationLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableDurationFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableSince -Formatter $formatter -Start $start -AsOf $asOf

    return $result
}

function Invoke-UntilCommand {
    param([string[]]$Positionals, [hashtable]$Options)

    if ($Positionals.Count -eq 0) {
        Show-Error 'until requires a target timestamp argument'
    }
    $target = ConvertTo-NullSentinel $Positionals[0]

    $asOf = $Options['as_of']
    if ($null -eq $asOf) {
        Show-Error 'until requires --as-of / -d option'
    }
    $asOf = ConvertTo-NullSentinel $asOf

    $localeCode = $Options['locale']
    $locale = Get-SayableDurationLocale -Code $localeCode
    if ($null -eq $locale) {
        Show-Error "unknown locale '$localeCode'"
    }

    $formatter = New-SayableDurationFormatter -Locale $locale -Compactness $Options['compactness']
    $result = Format-SayableUntil -Formatter $formatter -Target $target -AsOf $asOf

    return $result
}

function Invoke-LocalesCommand {
    # Enumerate locale codes from the age locale files (all components share the same set)
    $localesDir = Join-Path $script:Root 'age' 'impl' 'powershell' 'locales'
    $codes = Get-ChildItem -Path $localesDir -Filter '*.ps1' |
        Where-Object { $_.Name -ne 'registry.ps1' } |
        ForEach-Object { $_.BaseName } |
        Sort-Object
    return $codes -join "`n"
}

# Run one request; returns its exit code and stdout text ($null for no output).
function Invoke-Request {
    param([string[]]$Argv)

    try {
        $parsed = Read-Arguments $Argv
        $command = $parsed['Command']
        $positionals = $parsed['Positionals']
        $options = $parsed['Options']

        if ($null -eq $command) {
            return @{ Code = 2; Output = $script:HELP }
        }
        if ($command -eq 'help') {
            return @{ Code = 0; Output = $script:HELP }
        }
        if ($command -eq 'version') {
            return @{ Code = 0; Output = "sayable $script:VERSION" }
        }
        if ($command -eq 'locales') {
            return @{ Code = 0; Output = (Invoke-LocalesCommand) }
        }

        $result = switch ($command) {
            'age'      { Invoke-AgeCommand -Positionals $positionals -Options $options }
            'stage'    { Invoke-StageCommand -Positionals $positionals -Options $options }
            'date'     { Invoke-DateCommand -Positionals $positionals -Options $options }
            'relative' { Invoke-RelativeCommand -Positionals $positionals -Options $options }
            'time'     { Invoke-TimeCommand -Positionals $positionals -Options $options }
            'duration' { Invoke-DurationCommand -Positionals $positionals -Options $options }
            'since'    { Invoke-SinceCommand -Positionals $positionals -Options $options }
            'until'    { Invoke-UntilCommand -Positionals $positionals -Options $options }
            default    { Show-Error "unknown command '$command'" }
        }
        $code = if ($null -eq $result) { 1 } else { 0 }
        return @{ Code = $code; Output = $result }
    } catch [SayableUsageError] {
        [Console]::Error.WriteLine("error: $($_.Exception.Message)")
        [Console]::Error.WriteLine("Run 'sayable help' for usage.")
        return @{ Code = 2; Output = $null }
    }
}

# Answer one tab-separated request per stdin line (see cli/SPEC.md).
function Invoke-Repl {
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding = $utf8
    [Console]::OutputEncoding = $utf8

    while ($null -ne ($line = [Console]::In.ReadLine())) {
        try {
            $response = Invoke-Request $line.Split("`t")
        } catch {
            # A crash exits 1 in one-shot mode; report it and keep serving.
            [Console]::Error.WriteLine($_.ToString())
            $response = @{ Code = 1; Output = $null }
        }
        $output = ([string]$response.Output).TrimEnd("`n").Replace("`n", "`t")
        [Console]::Out.Write("$($response.Code)`t$output`n")
        [Console]::Out.Flush()
    }
}

# Main entry point
if ($args.Count -eq 1 -and $args[0] -eq '--repl') {
    Invoke-Repl
    exit 0
}

$response = Invoke-Request $args
if ($null -ne $response.Output) {
    [Console]::Out.Write($response.Output)
    [Console]::Out.WriteLine()
}
exit $response.Code
