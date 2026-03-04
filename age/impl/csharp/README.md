# sayable-age -- C#

Human-friendly age formatting — how parents actually talk about little ones.

```csharp
string age = SayableAgeFormatter.FormatAgeDefault("2025-06-01", "2025-06-15");  // "2 weeks"
string stage = SayableAgeFormatter.FormatStageDefault("2025-01-15", "2025-06-15");  // "Infant"
```

## Installation

Add to your `.csproj`:

```xml
<PackageReference Include="SayableAge" Version="0.1.0" />
```

Requires .NET 8.0+. Zero external dependencies.

## Usage

```csharp
using SayableAgeLib;

// Static convenience methods -- English default
string age = SayableAgeFormatter.FormatAgeDefault("2025-06-15", "2025-06-15");    // "Newborn"
string age2 = SayableAgeFormatter.FormatAgeDefault("2025-06-01", "2025-06-15");   // "2 weeks"
string age3 = SayableAgeFormatter.FormatAgeDefault("2025-01-15", "2025-07-15");   // "6 months"
string age4 = SayableAgeFormatter.FormatAgeDefault("2022-06-15", "2025-12-15");   // "3 1/2 years"

string stage = SayableAgeFormatter.FormatStageDefault("2025-01-15", "2025-06-15");  // "Infant"

// Returns null for empty/future dates or ages exceeding 500 years
string? nothing = SayableAgeFormatter.FormatAgeDefault("");  // null

// Instance-based with locale
var pt = new SayableAgeFormatter(Locales.EN);
pt.FormatAge("2022-06-15", "2025-12-15");   // "3 1/2 years"
pt.FormatStage("2022-06-15", "2025-06-15"); // "Child"
```

## Internationalization

```csharp
using SayableAgeLib;

var pt = new SayableAgeFormatter(Locales.JA);
pt.FormatAge("2025-01-01", "2025-07-15");   // "6ヶ月"
pt.FormatStage("2025-01-01", "2025-07-15"); // "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```csharp
using SayableAgeLib;

var normal  = new SayableAgeFormatter(Locales.EN);                          // "3 months"
var short_  = new SayableAgeFormatter(Locales.EN, Compactness.Short);       // "3 mo"
var compact = new SayableAgeFormatter(Locales.EN, Compactness.Compact);     // "3m"
```

## API

```csharp
namespace SayableAgeLib;

public class SayableAgeFormatter
{
    public SayableAgeFormatter(AgeLocale locale, Compactness? compactness = null)

    public string? FormatAge(string? dateOfBirth, string? asOf = null)
    public string? FormatStage(string? dateOfBirth, string? asOf = null, string? gender = null)

    // Static convenience methods using default English locale
    public static string? FormatAgeDefault(string? dateOfBirth, string? asOf = null)
    public static string? FormatStageDefault(string? dateOfBirth, string? asOf = null, string? gender = null)
}
```

**Parameters:**

- `dateOfBirth` -- `YYYY-MM-DD` string. Returns `null` for empty strings.
- `asOf` -- Optional reference date. Defaults to today.

**Returns:** `string?` (nullable) -- the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
dotnet test    # Run tests
dotnet build   # Build
```

## Code quality

- `TreatWarningsAsErrors` -- all compiler warnings are errors
- .NET 8.0 -- nullable reference types, pattern matching
- xUnit for testing
- See [code quality docs](../../docs/code-quality-compiled.md#csharp) for details

## License

[MIT](../../LICENSE.md)
