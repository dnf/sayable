# sayable-age -- Swift

Human-friendly age formatting — how parents actually talk about little ones.

```swift
let age = SayableAgeFormatter.formatAgeDefault("2025-06-01", "2025-06-15")  // "2 weeks"
let stage = SayableAgeFormatter.formatStageDefault("2025-01-15", "2025-06-15")  // "Infant"
```

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dnf/sayable.git", from: "0.1.0")
]
```

Then add `"SayableAge"` as a dependency to your target:

```swift
.target(name: "YourApp", dependencies: ["SayableAge"])
```

Requires Swift 6.0+. Zero external dependencies.

## Usage

```swift
import SayableAge

// Static convenience methods -- English default
let age = SayableAgeFormatter.formatAgeDefault("2025-06-15", "2025-06-15")    // "Newborn"
let age2 = SayableAgeFormatter.formatAgeDefault("2025-06-01", "2025-06-15")   // "2 weeks"
let age3 = SayableAgeFormatter.formatAgeDefault("2025-01-15", "2025-07-15")   // "6 months"
let age4 = SayableAgeFormatter.formatAgeDefault("2022-06-15", "2025-12-15")   // "3 1/2 years"

let stage = SayableAgeFormatter.formatStageDefault("2025-01-15", "2025-06-15")  // "Infant"

// Returns nil for empty/future dates or ages exceeding 500 years
let nothing = SayableAgeFormatter.formatAgeDefault("")  // nil

// Instance-based with locale
let pt = SayableAgeFormatter(Locales.ja)
pt.formatAge("2022-06-15", "2025-12-15")   // "3 1/2 years"
pt.formatStage("2022-06-15", "2025-06-15") // "Child"
```

## Internationalization

```swift
import SayableAge

let pt = SayableAgeFormatter(Locales.ja)
pt.formatAge("2025-01-01", "2025-07-15")   // "6ヶ月"
pt.formatStage("2025-01-01", "2025-07-15") // "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```swift
import SayableAge

let normal  = SayableAgeFormatter(Locales.en)                      // "3 months"
let short_  = SayableAgeFormatter(Locales.en, compactness: .short)   // "3 mo"
let compact = SayableAgeFormatter(Locales.en, compactness: .compact) // "3m"
```

## API

```swift
public struct SayableAgeFormatter {
    public init(_ locale: AgeLocale, compactness: Compactness = .normal)

    public func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String?
    public func formatStage(_ dateOfBirth: String?, _ asOf: String? = nil, gender: String? = nil) -> String?

    // Static convenience methods using default English locale
    public static func formatAgeDefault(_ dateOfBirth: String?, _ asOf: String? = nil) -> String?
    public static func formatStageDefault(_ dateOfBirth: String?, _ asOf: String? = nil, gender: String? = nil) -> String?
}
```

**Parameters:**

- `dateOfBirth` -- `YYYY-MM-DD` string. Returns `nil` for empty strings.
- `asOf` -- Optional reference date. Defaults to today.

**Returns:** `String?` (optional) -- the formatted string, or `nil` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
swift test    # Run tests
swift build   # Build
```

## Code quality

- `StrictConcurrency` enabled -- all concurrency warnings are errors
- Swift 6.0 -- structured concurrency, typed throws
- Swift Testing for tests
- See [code quality docs](../../docs/code-quality-compiled.md#swift) for details

## License

[MIT](../../LICENSE.md)
