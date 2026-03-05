# sayable-age — Gleam

Human-friendly age formatting — how parents actually talk about little ones.

```gleam
let assert Ok(age) = sayableage.format_age(
  en.locale(), types.Normal, "2025-06-01", "2025-06-15")
// age = "2 weeks"
```

## Setup

Gleam project targeting Erlang/OTP. Not published to Hex — use as a local dependency.

```bash
cd src/gleam
gleam build
```

Requires Gleam 1.0+ / OTP 26+. Zero external dependencies (gleam_stdlib only).

## Usage

```gleam
import sayableage
import sayableage/locales/en
import sayableage/types

let locale = en.locale()

let assert Ok(age) = sayableage.format_age(locale, types.Normal, "2025-01-15", "2025-07-15")
// age = "6 months"

let assert Ok(stage) = sayableage.format_stage(locale, "2025-01-15", "2025-06-15", Error(Nil))
// stage = "Infant"
```

## Internationalization

```gleam
let assert Ok(locale) = sayableage.get_locale("ja")
let assert Ok(age) = sayableage.format_age(locale, types.Normal, "2025-01-01", "2025-07-15")
// age = "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```gleam
pub fn format_age(
  locale: AgeLocale,
  compactness: Compactness,
  dob: String,
  as_of: String,
) -> Result(String, Nil)

pub fn format_stage(
  locale: AgeLocale,
  dob: String,
  as_of: String,
  gender: Result(Gender, Nil),
) -> Result(String, Nil)

pub fn get_locale(code: String) -> Result(AgeLocale, Nil)
```

**Parameters:**

- `locale` — An `AgeLocale` record from a locale module.
- `compactness` — `Normal`, `Short`, or `Compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `Error(Nil)` for empty strings.
- `as_of` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `Ok(string)` on success, `Error(Nil)` on invalid input or future dates.

## Development

```bash
gleam test    # Run tests
gleam build   # Build
```

## License

[MIT](../../LICENSE.md)
