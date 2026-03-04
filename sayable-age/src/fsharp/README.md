# sayable-age -- F#

A thoughtful time formatting library that reflects how we think about little ones.

```fsharp
open SayableAgeLib.Formatter

let age = formatAgeDefault (Some "2025-06-01") (Some "2025-06-15")   // Some "2 weeks"
let stage = formatStageDefault (Some "2025-01-15") (Some "2025-06-15") None  // Some "Infant"
```

## Installation

Add to your `.fsproj`:

```xml
<PackageReference Include="SayableAge" Version="0.1.0" />
```

Requires .NET 8.0+. Zero external dependencies.

## Usage

```fsharp
open SayableAgeLib.Types
open SayableAgeLib.Formatter
open SayableAgeLib.Locales

// Static convenience functions -- English default
let age = formatAgeDefault (Some "2025-06-15") (Some "2025-06-15")     // Some "Newborn"
let age2 = formatAgeDefault (Some "2025-06-01") (Some "2025-06-15")    // Some "2 weeks"
let age3 = formatAgeDefault (Some "2025-01-15") (Some "2025-07-15")    // Some "6 months"
let age4 = formatAgeDefault (Some "2022-06-15") (Some "2025-12-15")    // Some "3 1/2 years"

let stage = formatStageDefault (Some "2025-01-15") (Some "2025-06-15") None  // Some "Infant"

// Returns None for empty/future dates or ages exceeding 500 years
let nothing = formatAgeDefault (Some "") (Some "2025-06-15")  // None

// Instance-based with locale
let pt = SayableAgeFormatter(EN)
pt.FormatAge(Some "2022-06-15", Some "2025-12-15")   // Some "3 1/2 years"
pt.FormatStage(Some "2022-06-15", Some "2025-06-15")  // Some "Child"
```

## Internationalization

```fsharp
open SayableAgeLib.Types
open SayableAgeLib.Formatter
open SayableAgeLib.Locales

let pt = SayableAgeFormatter(JA)
pt.FormatAge(Some "2025-01-01", Some "2025-07-15")    // Some "6ヶ月"
pt.FormatStage(Some "2025-01-01", Some "2025-07-15")   // Some "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```fsharp
open SayableAgeLib.Types
open SayableAgeLib.Formatter
open SayableAgeLib.Locales

let normal  = SayableAgeFormatter(EN)                  // "3 months"
let short_  = SayableAgeFormatter(EN, Short)           // "3 mo"
let compact = SayableAgeFormatter(EN, Compact)         // "3m"
```

## API

```fsharp
module SayableAgeLib.Formatter

type SayableAgeFormatter =
    new: locale: AgeLocale * ?compactness: Compactness -> SayableAgeFormatter

    member FormatAge: dateOfBirth: string option * ?asOf: string option -> string option
    member FormatStage: dateOfBirth: string option * ?asOf: string option * ?gender: string option -> string option

// Static convenience functions using default English locale
val formatAgeDefault: dateOfBirth: string option -> asOf: string option -> string option
val formatStageDefault: dateOfBirth: string option -> asOf: string option -> gender: string option -> string option
```

**Parameters:**

- `dateOfBirth` -- `YYYY-MM-DD` string option. Returns `None` for empty strings or `None`.
- `asOf` -- Optional reference date. Defaults to today.

**Returns:** `string option` -- the formatted string, or `None` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
dotnet test    # Run tests
dotnet build   # Build
```

## Code quality

- `TreatWarningsAsErrors` -- all compiler warnings are errors
- .NET 8.0 -- discriminated unions, pattern matching, immutable records
- xUnit for testing
- See [code quality docs](../../docs/code-quality.md) for details

## License

[MIT](../../LICENSE.md)
