# SayableAge — Human-friendly age formatting for PowerShell
# Zero runtime dependencies.

$script:VERSION = '0.5.0'
$script:MAX_AGE_MONTHS = 6000

# Source locale registry
. "$PSScriptRoot/locales/registry.ps1"

function Resolve-SayableAgeUnit {
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
        $pluralFunc = $Locale['plural']
        $cat = & $pluralFunc $Count
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

function Resolve-SayableAgeStage {
    param(
        $Label,
        [string]$Gender = $null
    )

    if ($Label -is [string]) {
        return $Label
    }

    if ($Gender -eq 'f') {
        return $Label['f']
    }
    return $Label['m']
}

function Get-StageKey {
    param([int]$Months)

    if ($Months -lt 2) { return 'newborn' }
    if ($Months -lt 12) { return 'infant' }
    if ($Months -lt 36) { return 'toddler' }
    if ($Months -lt 156) { return 'child' }
    if ($Months -lt 216) { return 'teenager' }
    return 'adult'
}

function Get-DaysInMonthAge {
    param([int]$Year, [int]$Month)
    if ($Month -eq 2) {
        $isLeap = ($Year % 4 -eq 0 -and $Year % 100 -ne 0) -or ($Year % 400 -eq 0)
        return $(if ($isLeap) { 29 } else { 28 })
    }
    if ($Month -in @(4, 6, 9, 11)) { return 30 }
    return 31
}

# Parse exactly YYYY-MM-DD naming a real calendar day into @(year, month, day), else $null.
function ConvertFrom-SayableAgeDate {
    param([string]$DateStr)

    $m = [regex]::Match($DateStr, '\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z')
    if (-not $m.Success) {
        return $null
    }
    [int]$year = $m.Groups[1].Value
    [int]$month = $m.Groups[2].Value
    [int]$day = $m.Groups[3].Value
    if ($month -lt 1 -or $month -gt 12 -or $day -lt 1 -or $day -gt (Get-DaysInMonthAge -Year $year -Month $month)) {
        return $null
    }
    return @($year, $month, $day)
}

# Proleptic Gregorian day number, so calendar reforms and year 0 don't matter.
function Get-SayableAgeJulianDay {
    param([int]$Year, [int]$Month, [int]$Day)
    $a = [Math]::Floor((14 - $Month) / 12)
    $y = $Year + 4800 - $a
    $m = $Month + 12 * $a - 3
    return $Day + [Math]::Floor((153 * $m + 2) / 5) + 365 * $y + [Math]::Floor($y / 4) - [Math]::Floor($y / 100) + [Math]::Floor($y / 400) - 32045
}

function Parse-SayableAge {
    param(
        [AllowNull()][AllowEmptyString()][string]$DateOfBirth,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null
    )

    if ([string]::IsNullOrEmpty($DateOfBirth)) {
        return $null
    }

    $dob = ConvertFrom-SayableAgeDate -DateStr $DateOfBirth
    if ($null -eq $dob) {
        return $null
    }
    $dobY, $dobM, $dobD = $dob

    if (-not [string]::IsNullOrEmpty($AsOf)) {
        $ref = ConvertFrom-SayableAgeDate -DateStr $AsOf
        if ($null -eq $ref) {
            return $null
        }
        $refY, $refM, $refD = $ref
    } else {
        $today = [DateTime]::Today
        [int]$refY = $today.Year
        [int]$refM = $today.Month
        [int]$refD = $today.Day
    }

    $diffDays = (Get-SayableAgeJulianDay -Year $refY -Month $refM -Day $refD) - (Get-SayableAgeJulianDay -Year $dobY -Month $dobM -Day $dobD)
    if ($diffDays -lt 0) {
        return $null
    }

    $lastDay = Get-DaysInMonthAge -Year $refY -Month $refM
    $clampedBirthday = [Math]::Min($dobD, $lastDay)
    $months = ($refY - $dobY) * 12 + ($refM - $dobM)
    if ($refD -lt $clampedBirthday) {
        $months--
    }
    if ($months -gt $script:MAX_AGE_MONTHS) {
        return $null
    }

    return @($months, $diffDays)
}

function New-SayableAgeFormatter {
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
    foreach ($k in @('day', 'week', 'month', 'year')) {
        if ($ovrUnits -and $ovrUnits.ContainsKey($k)) {
            $units[$k] = $ovrUnits[$k]
        } else {
            $units[$k] = $Locale['units'][$k]
        }
    }

    $half = if ($ovr -and $ovr.ContainsKey('half')) { $ovr['half'] } else { $Locale['half'] }
    $delimiter = if ($ovr -and $ovr.ContainsKey('delimiter')) { $ovr['delimiter'] } else { $Locale['delimiter'] }
    $justBorn = if ($ovr -and $ovr.ContainsKey('justBorn')) { $ovr['justBorn'] } else { $Locale['justBorn'] }

    return @{
        locale    = $Locale
        units     = $units
        half      = $half
        delimiter = $delimiter
        justBorn  = $justBorn
    }
}

function Format-SayableAge {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$DateOfBirth,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null
    )

    $parsed = Parse-SayableAge -DateOfBirth $DateOfBirth -AsOf $AsOf
    if ($null -eq $parsed) {
        return $null
    }

    $months = $parsed[0]
    $diffDays = $parsed[1]
    $loc = $Formatter['locale']

    # Tier 1: 0 days
    if ($diffDays -eq 0) {
        return $Formatter['justBorn']
    }

    # Tier 1b: 1-6 days
    if ($diffDays -lt 7) {
        return Resolve-SayableAgeUnit -Count $diffDays -UnitForms $Formatter['units']['day'] -Locale $loc
    }

    # Tier 2: weeks + days until 3 calendar months
    if ($months -lt 3) {
        $weeks = [Math]::Floor($diffDays / 7)
        $days = $diffDays % 7
        $result = Resolve-SayableAgeUnit -Count $weeks -UnitForms $Formatter['units']['week'] -Locale $loc
        if ($days -gt 0) {
            $dayStr = Resolve-SayableAgeUnit -Count $days -UnitForms $Formatter['units']['day'] -Locale $loc
            $result = $result + $Formatter['delimiter'] + $dayStr
        }
        return $result
    }

    # Tier 3: 3-23 months
    if ($months -lt 24) {
        return Resolve-SayableAgeUnit -Count $months -UnitForms $Formatter['units']['month'] -Locale $loc
    }

    # Tier 4: 24-35 months -> years + months
    if ($months -lt 36) {
        $years = [Math]::Floor($months / 12)
        $rem = $months % 12
        if ($rem -eq 0) {
            return Resolve-SayableAgeUnit -Count $years -UnitForms $Formatter['units']['year'] -Locale $loc
        }
        $yearStr = Resolve-SayableAgeUnit -Count $years -UnitForms $Formatter['units']['year'] -Locale $loc
        $monthStr = Resolve-SayableAgeUnit -Count $rem -UnitForms $Formatter['units']['month'] -Locale $loc
        return $yearStr + $Formatter['delimiter'] + $monthStr
    }

    # Tier 5: 3-6 years -> years with half marker
    if ($months -lt 84) {
        $years = [Math]::Floor($months / 12)
        $rem = $months % 12
        if ($rem -ge 6) {
            return Resolve-SayableAgeUnit -Count $years -UnitForms $Formatter['units']['year'] -Locale $loc -Half $Formatter['half']
        }
        return Resolve-SayableAgeUnit -Count $years -UnitForms $Formatter['units']['year'] -Locale $loc
    }

    # Tier 6: 7+ years
    $years = [Math]::Floor($months / 12)
    return Resolve-SayableAgeUnit -Count $years -UnitForms $Formatter['units']['year'] -Locale $loc
}

function Format-SayableAgeStage {
    param(
        [hashtable]$Formatter,
        [AllowNull()][AllowEmptyString()][string]$DateOfBirth,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null,
        [AllowNull()][AllowEmptyString()][string]$Gender = $null
    )

    $parsed = Parse-SayableAge -DateOfBirth $DateOfBirth -AsOf $AsOf
    if ($null -eq $parsed) {
        return $null
    }

    $months = $parsed[0]
    $key = Get-StageKey -Months $months
    return Resolve-SayableAgeStage -Label $Formatter['locale']['stages'][$key] -Gender $Gender
}

# Module-level convenience: default English locale, normal compactness
$script:_defaultLocale = $null
$script:_defaultFormatter = $null

function Get-DefaultFormatter {
    if ($null -eq $script:_defaultFormatter) {
        $script:_defaultLocale = Get-SayableAgeLocale -Code 'en'
        $script:_defaultFormatter = New-SayableAgeFormatter -Locale $script:_defaultLocale
    }
    return $script:_defaultFormatter
}

function Get-SayableAge {
    param(
        [AllowNull()][AllowEmptyString()][string]$DateOfBirth,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null
    )

    $fmt = Get-DefaultFormatter
    return Format-SayableAge -Formatter $fmt -DateOfBirth $DateOfBirth -AsOf $AsOf
}

function Get-SayableAgeStage {
    param(
        [AllowNull()][AllowEmptyString()][string]$DateOfBirth,
        [AllowNull()][AllowEmptyString()][string]$AsOf = $null,
        [AllowNull()][AllowEmptyString()][string]$Gender = $null
    )

    $fmt = Get-DefaultFormatter
    return Format-SayableAgeStage -Formatter $fmt -DateOfBirth $DateOfBirth -AsOf $AsOf -Gender $Gender
}

Export-ModuleMember -Function @(
    'Get-SayableAge',
    'Get-SayableAgeStage',
    'Get-SayableAgeLocale',
    'New-SayableAgeFormatter',
    'Format-SayableAge',
    'Format-SayableAgeStage',
    'Resolve-SayableAgeStage',
    'Resolve-SayableAgeUnit'
)
