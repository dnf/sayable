# SayableTime — Human-friendly clock time formatting for PowerShell
# Zero runtime dependencies.

$script:VERSION = '0.5.0'

# Source locale registry
. "$PSScriptRoot/locales/registry.ps1"

function Get-DaysInMonthTime {
    param([int]$Year, [int]$Month)
    if ($Month -eq 2) {
        $isLeap = ($Year % 4 -eq 0 -and $Year % 100 -ne 0) -or ($Year % 400 -eq 0)
        return $(if ($isLeap) { 29 } else { 28 })
    }
    if ($Month -in @(4, 6, 9, 11)) { return 30 }
    return 31
}

# A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
# suffix, which is ignored), alone or after the T of an ISO datetime.
$script:CLOCK_TIME = '\A(?:([0-9]{4})-([0-9]{2})-([0-9]{2})T)?([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z'

function Parse-SayableTime {
    param(
        [AllowNull()][AllowEmptyString()][string]$InputStr
    )

    $m = [regex]::Match($InputStr, $script:CLOCK_TIME)
    if (-not $m.Success) {
        return $null
    }
    if ($m.Groups[1].Success) {
        [int]$year = $m.Groups[1].Value
        [int]$month = $m.Groups[2].Value
        [int]$day = $m.Groups[3].Value
        if ($month -lt 1 -or $month -gt 12 -or $day -lt 1 -or $day -gt (Get-DaysInMonthTime -Year $year -Month $month)) {
            return $null
        }
    }
    [int]$hour = $m.Groups[4].Value
    [int]$minute = $m.Groups[5].Value
    [int]$second = $(if ($m.Groups[6].Success) { $m.Groups[6].Value } else { 0 })
    if ($hour -gt 23 -or $minute -gt 59 -or $second -gt 59) {
        return $null
    }

    return @($hour, $minute)
}

function Get-RoundedTo5 {
    param([int]$Minute)
    return [int]([Math]::Floor(($Minute + 2) / 5) * 5)
}

function New-SayableTimeFormatter {
    param(
        [hashtable]$Locale,
        [ValidateSet('normal', 'short', 'compact')]
        [string]$Compactness = 'normal'
    )

    $ovr = $null
    if ($Compactness -eq 'short') {
        $ovr = $Locale['short']
    } elseif ($Compactness -eq 'compact') {
        $ovr = $Locale['compact']
    }

    $shortClock = if ($ovr -and $ovr.ContainsKey('clock')) { $ovr['clock'] } else { $null }

    return @{
        locale      = $Locale
        compactness = $Compactness
        shortClock  = $shortClock
    }
}

function Format-SayableTimeNatural {
    param(
        [hashtable]$Formatter,
        [int]$Hour,
        [int]$Minute
    )

    $clock = $Formatter['locale']['clock']
    $rounded = Get-RoundedTo5 -Minute $Minute
    $h = $Hour

    if ($rounded -eq 60) {
        $rounded = 0
        $h = ($h + 1) % 24
    }

    if ($rounded -eq 0) {
        if ($h -eq 0) {
            return $clock['midnight']
        }
        if ($h -eq 12) {
            return $clock['noon']
        }
    }

    $h12 = $h % 12
    $nextH12 = ($h + 1) % 12
    $hName = $clock['hours'][$h12]
    $nextHName = $clock['hours'][$nextH12]

    $patterns = $clock['patterns']
    if ($patterns.ContainsKey($rounded)) {
        $pattern = $patterns[$rounded]
    } elseif ($patterns.ContainsKey(0)) {
        $pattern = $patterns[0]
    } else {
        $pattern = '{h}'
    }

    return $pattern.Replace('{h}', $hName).Replace('{next_h}', $nextHName)
}

function Format-SayableTimeDigital {
    param(
        [hashtable]$Formatter,
        [int]$Hour,
        [int]$Minute
    )

    $sc = $Formatter['shortClock']
    $fmt = $sc['format']

    if ($sc['use24h']) {
        return $fmt.Replace('{h}', [string]$Hour).Replace('{mm}', $Minute.ToString('D2'))
    }

    $h12 = $Hour % 12
    if ($h12 -eq 0) {
        $h12 = 12
    }

    $amPm = $sc['amPm']
    if ($null -eq $amPm) {
        $amPm = @('AM', 'PM')
    }
    $ampmStr = if ($Hour -lt 12) { $amPm[0] } else { $amPm[1] }

    return $fmt.Replace('{h}', [string]$h12).Replace('{mm}', $Minute.ToString('D2')).Replace('{ampm}', $ampmStr)
}

function Format-SayableTime {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$InputStr
    )

    if ([string]::IsNullOrEmpty($InputStr)) {
        return $null
    }

    $parsed = Parse-SayableTime -InputStr $InputStr
    if ($null -eq $parsed) {
        return $null
    }

    [int]$hour = $parsed[0]
    [int]$minute = $parsed[1]

    if ($Formatter['compactness'] -ne 'normal' -and $Formatter['shortClock']) {
        return Format-SayableTimeDigital -Formatter $Formatter -Hour $hour -Minute $minute
    }

    return Format-SayableTimeNatural -Formatter $Formatter -Hour $hour -Minute $minute
}

# Module-level convenience: default English locale, normal compactness
$script:_defaultTimeLocale = $null
$script:_defaultTimeFormatter = $null

function Get-DefaultTimeFormatter {
    if ($null -eq $script:_defaultTimeFormatter) {
        $script:_defaultTimeLocale = Get-SayableTimeLocale -Code 'en'
        $script:_defaultTimeFormatter = New-SayableTimeFormatter -Locale $script:_defaultTimeLocale
    }
    return $script:_defaultTimeFormatter
}

function Get-SayableTime {
    param(
        [AllowNull()][AllowEmptyString()][string]$InputStr
    )

    $fmt = Get-DefaultTimeFormatter
    return Format-SayableTime -Formatter $fmt -InputStr $InputStr
}

Export-ModuleMember -Function @(
    'Get-SayableTime',
    'Get-SayableTimeLocale',
    'New-SayableTimeFormatter',
    'Format-SayableTime'
)
