# sayable-age — Pharo

Human-friendly age formatting — how parents actually talk about little ones.

```smalltalk
SayableAge formatAge: '2025-06-01' asOf: '2025-06-15'.  "=> '2 weeks'"
SayableAge formatAge: '2025-01-15' asOf: '2025-07-15'.  "=> '6 months'"
SayableAge formatAge: '2022-06-15' asOf: '2025-12-15'.  "=> '3½ years'"
```

## Installation

Load the `.st` files into your Pharo image:

```smalltalk
FileStream fileIn: 'SayableAgeLocale.st'.
FileStream fileIn: 'SayableAgeLocales.st'.
"Load all locale files from locales/"
FileStream fileIn: 'SayableAge.st'.
```

Requires Pharo 12+. Zero runtime dependencies.

## Usage

```smalltalk
"Module-level methods — English default"
SayableAge formatAge: '2025-06-15' asOf: '2025-06-15'.  "=> 'Newborn'"
SayableAge formatAge: '2025-06-01' asOf: '2025-06-15'.  "=> '2 weeks'"
SayableAge formatAge: '2025-01-15' asOf: '2025-07-15'.  "=> '6 months'"
SayableAge formatAge: '2024-06-15' asOf: '2025-06-15'.  "=> '12 months'"
SayableAge formatAge: '2023-06-15' asOf: '2025-07-15'.  "=> '2 years, 1 month'"
SayableAge formatAge: '2022-06-15' asOf: '2025-12-15'.  "=> '3½ years'"
SayableAge formatAge: '2018-06-15' asOf: '2025-06-15'.  "=> '7 years'"

"Developmental stage label"
SayableAge formatStage: '2025-06-15' asOf: '2025-06-15'.  "=> 'Newborn'"
SayableAge formatStage: '2025-01-15' asOf: '2025-06-15'.  "=> 'Infant'"
SayableAge formatStage: '2024-06-15' asOf: '2025-06-15'.  "=> 'Toddler'"

"Returns nil for nil/empty/future dates or ages exceeding 500 years"
SayableAge formatAge: nil asOf: '2025-06-15'.  "=> nil"

"Instance-based with locale"
| pt |
pt := SayableAge withLocale: (SayableAgeLocales get: 'en').
pt formatAge: '2022-06-15' asOf: '2025-12-15'.   "=> '3½ years'"
pt formatStage: '2022-06-15' asOf: '2025-06-15'. "=> 'Child'"
```

## Internationalization

```smalltalk
| pt |
pt := SayableAge withLocale: (SayableAgeLocales get: 'ja').
pt formatAge: '2025-01-01' asOf: '2025-07-15'.  "=> '6ヶ月'"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```smalltalk
| normal short compact |
normal  := SayableAge withLocale: (SayableAgeLocales get: 'en').                        "=> '3 months'"
short   := SayableAge withLocale: (SayableAgeLocales get: 'en') compactness: #short.    "=> '3 mo'"
compact := SayableAge withLocale: (SayableAgeLocales get: 'en') compactness: #compact.  "=> '3m'"
```

## API

```smalltalk
"Class methods — English default"
SayableAge formatAge: dateOfBirth asOf: asOfDate.   "=> String or nil"
SayableAge formatStage: dateOfBirth asOf: asOfDate.  "=> String or nil"

"Instance creation"
SayableAge withLocale: aLocale.                             "=> SayableAge"
SayableAge withLocale: aLocale compactness: aSymbol.        "=> SayableAge"

"Instance methods"
formatter formatAge: dateOfBirth asOf: asOfDate.            "=> String or nil"
formatter formatStage: dateOfBirth asOf: asOfDate.          "=> String or nil"
formatter formatStage: dateOfBirth asOf: asOfDate gender: g. "=> String or nil"
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `nil` if `nil` or empty.
- `asOfDate` — Reference date as `YYYY-MM-DD`. Defaults to today.
- `gender` — `'m'` or `'f'` for gendered locales. Defaults to masculine.

**Returns:** A `String`, or `nil` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
pharo --headless Pharo.image st run_tests.st
```

## License

[MIT](../../LICENSE.md)
