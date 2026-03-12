# sayable-age — PowerShell

Human-friendly age formatting — how parents actually talk about little ones.

```powershell
Get-SayableAge -DateOfBirth '2025-06-01' -AsOf '2025-06-15'  # "2 weeks"
Get-SayableAge -DateOfBirth '2025-01-15' -AsOf '2025-07-15'  # "6 months"
Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-12-15'  # "3½ years"
```

## Installation

```powershell
# Copy the module to your PowerShell modules directory
Copy-Item -Recurse age/impl/powershell $HOME/.local/share/powershell/Modules/SayableAge
```

Requires PowerShell 7.0+. Zero runtime dependencies.

## Usage

```powershell
Import-Module SayableAge

# Module-level functions — English default
Get-SayableAge -DateOfBirth '2025-06-15' -AsOf '2025-06-15'  # "Newborn"
Get-SayableAge -DateOfBirth '2025-06-01' -AsOf '2025-06-15'  # "2 weeks"
Get-SayableAge -DateOfBirth '2025-01-15' -AsOf '2025-07-15'  # "6 months"
Get-SayableAge -DateOfBirth '2024-06-15' -AsOf '2025-06-15'  # "12 months"
Get-SayableAge -DateOfBirth '2023-06-15' -AsOf '2025-07-15'  # "2 years, 1 month"
Get-SayableAge -DateOfBirth '2022-06-15' -AsOf '2025-12-15'  # "3½ years"
Get-SayableAge -DateOfBirth '2018-06-15' -AsOf '2025-06-15'  # "7 years"

# Developmental stage label
Get-SayableAgeStage -DateOfBirth '2025-06-15' -AsOf '2025-06-15'  # "Newborn"
Get-SayableAgeStage -DateOfBirth '2025-01-15' -AsOf '2025-06-15'  # "Infant"
Get-SayableAgeStage -DateOfBirth '2024-06-15' -AsOf '2025-06-15'  # "Toddler"

# Returns $null for null/empty/future dates or ages exceeding 500 years
Get-SayableAge -DateOfBirth $null  # $null

# Formatter with locale
$locale = Get-SayableAgeLocale -Code 'en'
$fmt = New-SayableAgeFormatter -Locale $locale
Format-SayableAge -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-12-15'   # "3½ years"
Format-SayableAgeStage -Formatter $fmt -DateOfBirth '2022-06-15' -AsOf '2025-06-15' # "Child"
```

## Internationalization

```powershell
$locale = Get-SayableAgeLocale -Code 'ja'
$fmt = New-SayableAgeFormatter -Locale $locale
Format-SayableAge -Formatter $fmt -DateOfBirth '2025-01-01' -AsOf '2025-07-15'  # "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```powershell
$locale = Get-SayableAgeLocale -Code 'en'
$normal  = New-SayableAgeFormatter -Locale $locale                            # "3 months"
$short   = New-SayableAgeFormatter -Locale $locale -Compactness 'short'       # "3 mo"
$compact = New-SayableAgeFormatter -Locale $locale -Compactness 'compact'     # "3m"
```

## API

```powershell
# Module-level functions — English default
Get-SayableAge [-DateOfBirth] <string> [-AsOf <string>]          # => String or $null
Get-SayableAgeStage [-DateOfBirth] <string> [-AsOf <string>] [-Gender <string>]  # => String or $null

# Locale lookup
Get-SayableAgeLocale -Code <string>                              # => Hashtable or $null

# Formatter creation
New-SayableAgeFormatter -Locale <hashtable> [-Compactness <string>]  # => Hashtable

# Formatter functions
Format-SayableAge -Formatter <hashtable> [-DateOfBirth] <string> [-AsOf <string>]
Format-SayableAgeStage -Formatter <hashtable> [-DateOfBirth] <string> [-AsOf <string>] [-Gender <string>]
```

**Parameters:**

- `DateOfBirth` — `YYYY-MM-DD` string. Returns `$null` if `$null` or empty.
- `AsOf` — Reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** A `String`, or `$null` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
# Run tests with Pester
pwsh -Command "Invoke-Pester tests/"
```

## License

[MIT](../../LICENSE.md)
