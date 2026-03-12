# SayableDate — Human-friendly date formatting for PowerShell
# Zero runtime dependencies.

$script:VERSION = '0.5.0'

# Source locale registry
. "$PSScriptRoot/locales/registry.ps1"

function Parse-SayableDate {
    param(
        [AllowNull()][AllowEmptyString()][string]$DateStr
    )

    if ([string]::IsNullOrEmpty($DateStr)) {
        return $null
    }

    # Strip time part from ISO datetime
    $datePart = $DateStr
    $tIdx = $DateStr.IndexOf('T')
    if ($tIdx -ge 0) {
        $datePart = $DateStr.Substring(0, $tIdx)
    }

    $parts = $datePart.Split('-')
    if ($parts.Count -ne 3) {
        return $null
    }

    try {
        [int]$year = $parts[0]
        [int]$month = $parts[1]
        [int]$day = $parts[2]
    } catch {
        return $null
    }

    if ($month -lt 1 -or $month -gt 12 -or $day -lt 1 -or $day -gt 31) {
        return $null
    }

    return @($year, $month, $day)
}

function Get-JulianDayNumber {
    param(
        [int]$Year,
        [int]$Month,
        [int]$Day
    )

    $a = [Math]::Floor((14 - $Month) / 12)
    $y = $Year + 4800 - $a
    $m = $Month + 12 * $a - 3
    return $Day + [Math]::Floor((153 * $m + 2) / 5) + 365 * $y + [Math]::Floor($y / 4) - [Math]::Floor($y / 100) + [Math]::Floor($y / 400) - 32045
}

function Get-Weekday {
    param(
        [int]$Year,
        [int]$Month,
        [int]$Day
    )

    $jdn = Get-JulianDayNumber -Year $Year -Month $Month -Day $Day
    return ($jdn + 1) % 7
}

function New-SayableDateFormatter {
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

    $months = if ($ovr -and $ovr.ContainsKey('months')) { $ovr['months'] } else { $Locale['months'] }
    $monthsInDate = if ($ovr -and $ovr.ContainsKey('monthsInDate')) { $ovr['monthsInDate'] } else { $Locale['monthsInDate'] }
    $weekdays = if ($ovr -and $ovr.ContainsKey('weekdays')) { $ovr['weekdays'] } else { $Locale['weekdays'] }

    # When override provides dayFormat but not dayFormatExceptions, clear exceptions
    if ($ovr -and $ovr.ContainsKey('dayFormat') -and (-not $ovr.ContainsKey('dayFormatExceptions'))) {
        $dayFormat = $ovr['dayFormat']
        $dayFormatExceptions = @{}
    } else {
        $dayFormat = if ($ovr -and $ovr.ContainsKey('dayFormat')) { $ovr['dayFormat'] } else { $Locale['dayFormat'] }
        $dayFormatExceptions = if ($ovr -and $ovr.ContainsKey('dayFormatExceptions')) { $ovr['dayFormatExceptions'] } else { $Locale['dayFormatExceptions'] }
    }

    $datePattern = if ($ovr -and $ovr.ContainsKey('datePattern')) { $ovr['datePattern'] } else { $Locale['datePattern'] }
    $datePatternWithYear = if ($ovr -and $ovr.ContainsKey('datePatternWithYear')) { $ovr['datePatternWithYear'] } else { $Locale['datePatternWithYear'] }
    $today = if ($ovr -and $ovr.ContainsKey('today')) { $ovr['today'] } else { $Locale['today'] }
    $tomorrow = if ($ovr -and $ovr.ContainsKey('tomorrow')) { $ovr['tomorrow'] } else { $Locale['tomorrow'] }
    $yesterday = if ($ovr -and $ovr.ContainsKey('yesterday')) { $ovr['yesterday'] } else { $Locale['yesterday'] }

    return @{
        locale              = $Locale
        compactness         = $Compactness
        months              = $months
        monthsInDate        = $monthsInDate
        weekdays            = $weekdays
        dayFormat           = $dayFormat
        dayFormatExceptions = $dayFormatExceptions
        datePattern         = $datePattern
        datePatternWithYear = $datePatternWithYear
        today               = $today
        tomorrow            = $tomorrow
        yesterday           = $yesterday
    }
}

function Format-SayableDateAbsolute {
    param(
        [hashtable]$Formatter,
        [int]$Year,
        [int]$Month,
        [int]$Day,
        [bool]$IncludeYear
    )

    $dayStr = [string]$Day
    $exceptions = $Formatter['dayFormatExceptions']
    # Keys may be int or string depending on how the hashtable was built
    if ($exceptions -and ($exceptions.ContainsKey($dayStr) -or $exceptions.ContainsKey($Day))) {
        if ($exceptions.ContainsKey($dayStr)) {
            $fmt = $exceptions[$dayStr]
        } else {
            $fmt = $exceptions[$Day]
        }
    } else {
        $fmt = $Formatter['dayFormat']
    }
    $formattedDay = $fmt.Replace('{n}', $dayStr)

    # Pick month name (genitive form if available)
    $monthNames = $Formatter['monthsInDate']
    if ($null -eq $monthNames) {
        $monthNames = $Formatter['months']
    }
    $monthName = $monthNames[$Month - 1]

    $pattern = if ($IncludeYear) { $Formatter['datePatternWithYear'] } else { $Formatter['datePattern'] }
    $result = $pattern.Replace('{month}', $monthName)
    $result = $result.Replace('{day}', $formattedDay)
    $result = $result.Replace('{d}', [string]$Day)
    $result = $result.Replace('{m}', [string]$Month)
    if ($IncludeYear) {
        $result = $result.Replace('{year}', [string]$Year)
        $yy = ($Year % 100).ToString('D2')
        $result = $result.Replace('{yy}', $yy)
    }

    return $result
}

function Format-SayableDate {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$Date
    )

    $parsed = Parse-SayableDate -DateStr $Date
    if ($null -eq $parsed) {
        return $null
    }

    return Format-SayableDateAbsolute -Formatter $Formatter -Year $parsed[0] -Month $parsed[1] -Day $parsed[2] -IncludeYear $false
}

function Format-SayableDateWithYear {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$Date
    )

    $parsed = Parse-SayableDate -DateStr $Date
    if ($null -eq $parsed) {
        return $null
    }

    return Format-SayableDateAbsolute -Formatter $Formatter -Year $parsed[0] -Month $parsed[1] -Day $parsed[2] -IncludeYear $true
}

function Format-SayableRelativeDate {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$Date,
        [AllowNull()][AllowEmptyString()][string]$AsOf
    )

    if ([string]::IsNullOrEmpty($Date) -or [string]::IsNullOrEmpty($AsOf)) {
        return $null
    }

    $parsedDate = Parse-SayableDate -DateStr $Date
    $parsedAsOf = Parse-SayableDate -DateStr $AsOf
    if ($null -eq $parsedDate -or $null -eq $parsedAsOf) {
        return $null
    }

    [int]$dy = $parsedDate[0]; [int]$dm = $parsedDate[1]; [int]$dd = $parsedDate[2]
    [int]$ay = $parsedAsOf[0]; [int]$am = $parsedAsOf[1]; [int]$ad = $parsedAsOf[2]

    $dateJdn = Get-JulianDayNumber -Year $dy -Month $dm -Day $dd
    $asofJdn = Get-JulianDayNumber -Year $ay -Month $am -Day $ad
    $diff = $dateJdn - $asofJdn

    # Today
    if ($diff -eq 0) {
        return $Formatter['today']
    }

    # Tomorrow
    if ($diff -eq 1) {
        return $Formatter['tomorrow']
    }

    # Yesterday
    if ($diff -eq -1) {
        return $Formatter['yesterday']
    }

    $loc = $Formatter['locale']
    $isCompact = $Formatter['compactness'] -eq 'compact'

    # Day after tomorrow (optional, skipped in compact mode)
    if ($diff -eq 2 -and $loc['dayAfterTomorrow'] -and -not $isCompact) {
        return $loc['dayAfterTomorrow']
    }

    # Day before yesterday (optional, skipped in compact mode)
    if ($diff -eq -2 -and $loc['dayBeforeYesterday'] -and -not $isCompact) {
        return $loc['dayBeforeYesterday']
    }

    # Compact mode: skip weekday references, go straight to calendar date
    if ($isCompact) {
        $includeYear = $dy -ne $ay
        return Format-SayableDateAbsolute -Formatter $Formatter -Year $dy -Month $dm -Day $dd -IncludeYear $includeYear
    }

    # This weekday (+2 to +6)
    if ($diff -ge 2 -and $diff -le 6 -and $loc['thisWeekday']) {
        $dow = Get-Weekday -Year $dy -Month $dm -Day $dd
        $weekdayName = $Formatter['weekdays'][$dow]
        return $loc['thisWeekday'].Replace('{weekday}', $weekdayName)
    }

    # Last weekday (-6 to -2)
    if ($diff -ge -6 -and $diff -le -2 -and $loc['lastWeekday']) {
        $dow = Get-Weekday -Year $dy -Month $dm -Day $dd
        $weekdayName = $Formatter['weekdays'][$dow]
        return $loc['lastWeekday'].Replace('{weekday}', $weekdayName)
    }

    # Next weekday (+7 to +13)
    if ($diff -ge 7 -and $diff -le 13 -and $loc['nextWeekday']) {
        $dow = Get-Weekday -Year $dy -Month $dm -Day $dd
        $weekdayName = $Formatter['weekdays'][$dow]
        return $loc['nextWeekday'].Replace('{weekday}', $weekdayName)
    }

    # Calendar fallback
    $includeYear = $dy -ne $ay
    return Format-SayableDateAbsolute -Formatter $Formatter -Year $dy -Month $dm -Day $dd -IncludeYear $includeYear
}

# Module-level convenience: default English locale, normal compactness
$script:_defaultDateLocale = $null
$script:_defaultDateFormatter = $null

function Get-DefaultDateFormatter {
    if ($null -eq $script:_defaultDateFormatter) {
        $script:_defaultDateLocale = Get-SayableDateLocale -Code 'en'
        $script:_defaultDateFormatter = New-SayableDateFormatter -Locale $script:_defaultDateLocale
    }
    return $script:_defaultDateFormatter
}

function Get-SayableDate {
    param(
        [AllowNull()][AllowEmptyString()][string]$Date
    )

    $fmt = Get-DefaultDateFormatter
    return Format-SayableDate -Formatter $fmt -Date $Date
}

function Get-SayableRelativeDate {
    param(
        [AllowNull()][AllowEmptyString()][string]$Date,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null
    )

    $fmt = Get-DefaultDateFormatter
    return Format-SayableRelativeDate -Formatter $fmt -Date $Date -AsOf $AsOf
}

Export-ModuleMember -Function @(
    'Get-SayableDate',
    'Get-SayableRelativeDate',
    'Get-SayableDateLocale',
    'New-SayableDateFormatter',
    'Format-SayableDate',
    'Format-SayableDateWithYear',
    'Format-SayableRelativeDate'
)
