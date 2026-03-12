# sayable-age — V

Human-friendly age formatting — how parents actually talk about little ones.

```v
import locales

fn main() {
    mut sa := locales.new_sayable_age(locales.get_locale('en')!)
    println(sa.format_age('2025-06-01', '2025-06-15') or { 'null' })  // "2 weeks"
}
```

## Installation

Copy the V source files into your project. Requires V 0.4+. Zero external dependencies.

## Usage

```v
import locales

fn main() {
    en := locales.get_locale('en')!
    mut sa := locales.new_sayable_age(en)

    // Human-readable age string
    println(sa.format_age('2025-06-15', '2025-06-15') or { '' })  // "Newborn"
    println(sa.format_age('2025-06-01', '2025-06-15') or { '' })  // "2 weeks"
    println(sa.format_age('2025-01-15', '2025-07-15') or { '' })  // "6 months"
    println(sa.format_age('2022-06-15', '2025-12-15') or { '' })  // "3½ years"

    // Developmental stage label
    println(sa.format_stage('2025-06-15', '2025-06-15') or { '' })  // "Newborn"
    println(sa.format_stage('2025-01-15', '2025-06-15') or { '' })  // "Infant"

    // Returns none for invalid/future dates or ages exceeding 500 years
    _ := sa.format_age('', '2025-06-15') or { 'null' }  // "null"
}
```

## Internationalization

```v
ja := locales.get_locale('ja')!
mut sa := locales.new_sayable_age(ja)
println(sa.format_age('2025-01-01', '2025-07-15') or { '' })  // "6ヶ月"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```v
en := locales.get_locale('en')!
mut normal  := locales.new_sayable_age(en)                              // "6 months"
mut short   := locales.new_sayable_age(en, compactness: .short_)        // "6 mo"
mut compact := locales.new_sayable_age(en, compactness: .compact)       // "6m"
```

## API

```v
fn new_sayable_age(locale AgeLocale, compactness Compactness) SayableAge
fn (mut sa SayableAge) format_age(dob string, as_of string) ?string
fn (mut sa SayableAge) format_stage(dob string, as_of string) ?string
fn get_locale(code string) ?AgeLocale
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string.
- `as_of` — Reference date as `YYYY-MM-DD`.

**Returns:** `?string` — optional string. Returns `none` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
v test .
```

## License

[MIT](../../LICENSE.md)
