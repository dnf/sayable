# SayableDuration — Human-friendly duration and relative time formatting for PowerShell
# Zero runtime dependencies.

$script:VERSION = '0.5.0'
$script:MAX_DURATION_MONTHS = 6000  # 500 years, the same ceiling as sayable-age

# Source locale registry
. "$PSScriptRoot/locales/registry.ps1"

function Resolve-SayableDurationUnit {
    param(
        [int]$Count,
        $UnitForms,
        [hashtable]$Locale,
        [string]$Half = ''
    )

    $baseN = [string]$Count
    if ($Half -and $Half.Contains('{n}')) {
        $n = $Half.Replace('{n}', $baseN)
    } else {
        $n = $baseN
    }

    if ($UnitForms -is [string]) {
        $template = $UnitForms
    } else {
        if ($Half) {
            $cat = 'other'
        } else {
            $pluralFunc = $Locale['plural']
            $cat = & $pluralFunc $Count
        }
        if ($UnitForms.ContainsKey($cat)) {
            $template = $UnitForms[$cat]
        } else {
            $template = $UnitForms['other']
        }
    }

    $result = $template.Replace('{n}', $n)

    if ($Half -and $Half.Contains('{0}')) {
        $result = $Half.Replace('{0}', $result)
    }

    return $result
}

# YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
$script:TIMESTAMP = '\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z'

function Parse-SayableDurationISO {
    param(
        [AllowNull()][AllowEmptyString()][string]$ISOStr
    )

    $m = [regex]::Match($ISOStr, $script:TIMESTAMP)
    if (-not $m.Success) {
        return $null
    }
    [int]$year = $m.Groups[1].Value
    [int]$month = $m.Groups[2].Value
    [int]$day = $m.Groups[3].Value
    [int]$hour = $m.Groups[4].Value
    [int]$minute = $m.Groups[5].Value
    [int]$second = $(if ($m.Groups[6].Success) { $m.Groups[6].Value } else { 0 })
    if ($month -lt 1 -or $month -gt 12 -or $day -lt 1 -or $day -gt (Get-DaysInMonthDuration -Year $year -Month $month)) {
        return $null
    }
    if ($hour -gt 23 -or $minute -gt 59 -or $second -gt 59) {
        return $null
    }

    $days = Get-DaysSinceEpoch -Year $year -Month $month -Day $day
    return [long]$days * 86400 + $hour * 3600 + $minute * 60 + $second
}

function Test-IsLeapYear {
    param([int]$Year)
    return ($Year % 4 -eq 0 -and $Year % 100 -ne 0) -or ($Year % 400 -eq 0)
}

function Get-DaysInMonthDuration {
    param([int]$Year, [int]$Month)
    if ($Month -in @(1, 3, 5, 7, 8, 10, 12)) { return 31 }
    if ($Month -in @(4, 6, 9, 11)) { return 30 }
    return $(if (Test-IsLeapYear -Year $Year) { 29 } else { 28 })
}

function Get-DaysSinceEpoch {
    param([int]$Year, [int]$Month, [int]$Day)

    [int]$days = 0
    if ($Year -ge 2000) {
        for ($y = 2000; $y -lt $Year; $y++) {
            $days += $(if (Test-IsLeapYear -Year $y) { 366 } else { 365 })
        }
    } else {
        for ($y = $Year; $y -lt 2000; $y++) {
            $days -= $(if (Test-IsLeapYear -Year $y) { 366 } else { 365 })
        }
    }
    for ($m = 1; $m -lt $Month; $m++) {
        $days += Get-DaysInMonthDuration -Year $Year -Month $m
    }
    $days += $Day - 1
    return $days
}

function New-SayableDurationFormatter {
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

    $ovrUnits = if ($ovr -and $ovr.ContainsKey('units')) { $ovr['units'] } else { $null }

    $units = @{}
    foreach ($k in @('second', 'minute', 'hour', 'day', 'week', 'month', 'year')) {
        if ($ovrUnits -and $ovrUnits.ContainsKey($k)) {
            $units[$k] = $ovrUnits[$k]
        } else {
            $units[$k] = $Locale['units'][$k]
        }
    }

    $half = if ($ovr -and $ovr.ContainsKey('half')) { $ovr['half'] } else { $Locale['half'] }
    $delimiter = if ($ovr -and $ovr.ContainsKey('delimiter')) { $ovr['delimiter'] } else { $Locale['delimiter'] }
    $justNow = $Locale['justNow']
    $ago = if ($ovr -and $ovr.ContainsKey('ago')) { $ovr['ago'] } else { $Locale['ago'] }
    $inFuture = if ($ovr -and $ovr.ContainsKey('inFuture')) { $ovr['inFuture'] } else { $Locale['inFuture'] }

    return @{
        locale    = $Locale
        units     = $units
        half      = $half
        delimiter = $delimiter
        justNow   = $justNow
        ago       = $ago
        inFuture  = $inFuture
    }
}

function Format-SayableDurationSeconds {
    param(
        [hashtable]$Formatter,
        [long]$Total
    )

    $loc = $Formatter['locale']

    # 0 seconds
    if ($Total -eq 0) {
        return $Formatter['justNow']
    }

    # 1-59 seconds
    if ($Total -lt 60) {
        return Resolve-SayableDurationUnit -Count $Total -UnitForms $Formatter['units']['second'] -Locale $loc
    }

    $totalMinutes = [Math]::Floor($Total / 60)
    $remainderSeconds = $Total % 60

    # 1-4 minutes: minutes + seconds
    if ($totalMinutes -lt 5) {
        $result = Resolve-SayableDurationUnit -Count $totalMinutes -UnitForms $Formatter['units']['minute'] -Locale $loc
        if ($remainderSeconds -gt 0) {
            $secStr = Resolve-SayableDurationUnit -Count $remainderSeconds -UnitForms $Formatter['units']['second'] -Locale $loc
            $result = $result + $Formatter['delimiter'] + $secStr
        }
        return $result
    }

    # 5-59 minutes
    if ($totalMinutes -lt 60) {
        return Resolve-SayableDurationUnit -Count $totalMinutes -UnitForms $Formatter['units']['minute'] -Locale $loc
    }

    $totalHours = [Math]::Floor($Total / 3600)
    $remainderMinutes = [Math]::Floor(($Total % 3600) / 60)

    # 1-5 hours: hours + minutes (with half marker)
    if ($totalHours -le 5) {
        if ($remainderMinutes -eq 30) {
            return Resolve-SayableDurationUnit -Count $totalHours -UnitForms $Formatter['units']['hour'] -Locale $loc -Half $Formatter['half']
        }
        $result = Resolve-SayableDurationUnit -Count $totalHours -UnitForms $Formatter['units']['hour'] -Locale $loc
        if ($remainderMinutes -gt 0) {
            $minStr = Resolve-SayableDurationUnit -Count $remainderMinutes -UnitForms $Formatter['units']['minute'] -Locale $loc
            $result = $result + $Formatter['delimiter'] + $minStr
        }
        return $result
    }

    # 6-23 hours
    if ($totalHours -lt 24) {
        return Resolve-SayableDurationUnit -Count $totalHours -UnitForms $Formatter['units']['hour'] -Locale $loc
    }

    $totalDays = [Math]::Floor($Total / 86400)
    $remainderHours = [Math]::Floor(($Total % 86400) / 3600)

    # 1-2 days: days + hours (with half marker)
    if ($totalDays -le 2) {
        if ($remainderHours -eq 12) {
            return Resolve-SayableDurationUnit -Count $totalDays -UnitForms $Formatter['units']['day'] -Locale $loc -Half $Formatter['half']
        }
        $result = Resolve-SayableDurationUnit -Count $totalDays -UnitForms $Formatter['units']['day'] -Locale $loc
        if ($remainderHours -gt 0) {
            $hrStr = Resolve-SayableDurationUnit -Count $remainderHours -UnitForms $Formatter['units']['hour'] -Locale $loc
            $result = $result + $Formatter['delimiter'] + $hrStr
        }
        return $result
    }

    # 3-6 days
    if ($totalDays -lt 7) {
        return Resolve-SayableDurationUnit -Count $totalDays -UnitForms $Formatter['units']['day'] -Locale $loc
    }

    $totalWeeks = [Math]::Floor($totalDays / 7)
    $remainderDays = $totalDays % 7

    # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    if ($totalDays -lt 30) {
        $result = Resolve-SayableDurationUnit -Count $totalWeeks -UnitForms $Formatter['units']['week'] -Locale $loc
        if ($remainderDays -gt 0) {
            $dayStr = Resolve-SayableDurationUnit -Count $remainderDays -UnitForms $Formatter['units']['day'] -Locale $loc
            $result = $result + $Formatter['delimiter'] + $dayStr
        }
        return $result
    }

    # Approximate months (30.44 days average)
    $totalMonths = [Math]::Round($totalDays / 30.44)
    if ($totalMonths -gt $script:MAX_DURATION_MONTHS) {
        return $null
    }

    # 1-11 months
    if ($totalMonths -lt 12) {
        if ($totalMonths -eq 0) {
            $totalMonths = 1
        }
        return Resolve-SayableDurationUnit -Count $totalMonths -UnitForms $Formatter['units']['month'] -Locale $loc
    }

    # 12+ months: years + months
    $totalYears = [Math]::Floor($totalMonths / 12)
    $remainderMonths = $totalMonths % 12
    $result = Resolve-SayableDurationUnit -Count $totalYears -UnitForms $Formatter['units']['year'] -Locale $loc
    if ($remainderMonths -gt 0) {
        $moStr = Resolve-SayableDurationUnit -Count $remainderMonths -UnitForms $Formatter['units']['month'] -Locale $loc
        $result = $result + $Formatter['delimiter'] + $moStr
    }
    return $result
}

function Format-SayableDuration {
    param(
        [hashtable]$Formatter,
        $StartOrSeconds,
        [AllowNull()][AllowEmptyString()][string]$End = $null
    )

    if ($null -eq $StartOrSeconds) {
        return $null
    }

    if ($StartOrSeconds -is [int] -or $StartOrSeconds -is [long] -or $StartOrSeconds -is [double]) {
        $totalSeconds = [long]$StartOrSeconds
    } elseif ($StartOrSeconds -is [string]) {
        if ([string]::IsNullOrEmpty($End)) {
            return $null
        }
        $s = Parse-SayableDurationISO -ISOStr $StartOrSeconds
        $e = Parse-SayableDurationISO -ISOStr $End
        if ($null -eq $s -or $null -eq $e) {
            return $null
        }
        $totalSeconds = [Math]::Abs($e - $s)
    } else {
        return $null
    }

    if ($totalSeconds -lt 0) {
        return $null
    }

    return Format-SayableDurationSeconds -Formatter $Formatter -Total $totalSeconds
}

function Format-SayableSince {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$Start,
        [AllowNull()][AllowEmptyString()][string]$AsOf
    )

    if ([string]::IsNullOrEmpty($Start) -or [string]::IsNullOrEmpty($AsOf)) {
        return $null
    }

    $s = Parse-SayableDurationISO -ISOStr $Start
    $a = Parse-SayableDurationISO -ISOStr $AsOf
    if ($null -eq $s -or $null -eq $a) {
        return $null
    }

    $diff = $a - $s
    if ($diff -lt 0) {
        return $null
    }
    if ($diff -eq 0) {
        return $Formatter['justNow']
    }

    $dur = Format-SayableDurationSeconds -Formatter $Formatter -Total $diff
    if ($null -eq $dur) {
        return $null
    }
    return $Formatter['ago'].Replace('{0}', $dur)
}

function Format-SayableUntil {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$Target,
        [AllowNull()][AllowEmptyString()][string]$AsOf
    )

    if ([string]::IsNullOrEmpty($Target) -or [string]::IsNullOrEmpty($AsOf)) {
        return $null
    }

    $t = Parse-SayableDurationISO -ISOStr $Target
    $a = Parse-SayableDurationISO -ISOStr $AsOf
    if ($null -eq $t -or $null -eq $a) {
        return $null
    }

    $diff = $t - $a
    if ($diff -lt 0) {
        return $null
    }
    if ($diff -eq 0) {
        return $Formatter['justNow']
    }

    $dur = Format-SayableDurationSeconds -Formatter $Formatter -Total $diff
    if ($null -eq $dur) {
        return $null
    }
    return $Formatter['inFuture'].Replace('{0}', $dur)
}

# Module-level convenience: default English locale, normal compactness
$script:_defaultDurationLocale = $null
$script:_defaultDurationFormatter = $null

function Get-DefaultDurationFormatter {
    if ($null -eq $script:_defaultDurationFormatter) {
        $script:_defaultDurationLocale = Get-SayableDurationLocale -Code 'en'
        $script:_defaultDurationFormatter = New-SayableDurationFormatter -Locale $script:_defaultDurationLocale
    }
    return $script:_defaultDurationFormatter
}

function Get-SayableDuration {
    param(
        $StartOrSeconds,
        [AllowNull()][AllowEmptyString()][string]$End = $null
    )

    $fmt = Get-DefaultDurationFormatter
    return Format-SayableDuration -Formatter $fmt -StartOrSeconds $StartOrSeconds -End $End
}

function Get-SayableSince {
    param(
        [AllowNull()][AllowEmptyString()][string]$Start,
        [AllowNull()][AllowEmptyString()][string]$AsOf
    )

    $fmt = Get-DefaultDurationFormatter
    return Format-SayableSince -Formatter $fmt -Start $Start -AsOf $AsOf
}

function Get-SayableUntil {
    param(
        [AllowNull()][AllowEmptyString()][string]$Target,
        [AllowNull()][AllowEmptyString()][string]$AsOf
    )

    $fmt = Get-DefaultDurationFormatter
    return Format-SayableUntil -Formatter $fmt -Target $Target -AsOf $AsOf
}

Export-ModuleMember -Function @(
    'Get-SayableDuration',
    'Get-SayableSince',
    'Get-SayableUntil',
    'Get-SayableDurationLocale',
    'New-SayableDurationFormatter',
    'Format-SayableDuration',
    'Format-SayableSince',
    'Format-SayableUntil',
    'Resolve-SayableDurationUnit'
)
