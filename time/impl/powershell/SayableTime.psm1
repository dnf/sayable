# SayableTime — Human-friendly clock time formatting for PowerShell
# Zero runtime dependencies.

$script:VERSION = '0.5.0'

# Source locale registry
. "$PSScriptRoot/locales/registry.ps1"

function Parse-SayableTime {
    param(
        [AllowNull()][AllowEmptyString()][string]$InputStr
    )

    if ([string]::IsNullOrEmpty($InputStr)) {
        return $null
    }

    $t = $InputStr
    if ($t.Contains('T')) {
        $t = $t.Split('T')[1]
    }
    if ($t.Contains('+')) {
        $t = $t.Split('+')[0]
    }
    if ($t.Contains('Z')) {
        $t = $t.Split('Z')[0]
    }

    $parts = $t.Split(':')
    if ($parts.Count -lt 2) {
        return $null
    }

    try {
        $minutePart = $parts[1]
        if ($minutePart.Contains('.')) {
            $minutePart = $minutePart.Split('.')[0]
        }
        [int]$hour = $parts[0]
        [int]$minute = $minutePart
    } catch {
        return $null
    }

    if ($hour -lt 0 -or $hour -gt 23 -or $minute -lt 0 -or $minute -gt 59) {
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
