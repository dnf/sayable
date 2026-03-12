# sayable-date — V

Human-friendly date formatting — how people reference dates in conversation.

```v
import locales

fn main() {
    sd := locales.new_sayable_date(locales.get_date_locale('en')!, .normal)
    println(sd.format_date('2025-03-15') or { '' })  // "March 15th"
}
```

## Installation

Copy the V source files into your project. Requires V 0.4+. Zero external dependencies.

## Usage

```v
import locales

fn main() {
    en := locales.get_date_locale('en')!

    // Normal compactness
    mut sd := locales.new_sayable_date(en, .normal)
    println(sd.format_date('2025-03-15') or { '' })         // "March 15th"
    println(sd.format_date('2025-01-01') or { '' })         // "January 1st"

    // With year
    println(sd.format_date_with_year('2025-03-15') or { '' }) // "March 15th, 2025"

    // Relative dates
    println(sd.format_relative('2025-03-16', '2025-03-15') or { '' })  // "tomorrow"
    println(sd.format_relative('2025-03-19', '2025-03-15') or { '' })  // "this Wednesday"

    // Short compactness
    sd_short := locales.new_sayable_date(en, .short)
    println(sd_short.format_date('2025-03-15') or { '' })   // "Mar 15"

    // Compact
    sd_compact := locales.new_sayable_date(en, .compact)
    println(sd_compact.format_date('2025-03-15') or { '' })  // "3/15"
}
```

## Internationalization

```v
ja := locales.get_date_locale('ja')!
sd := locales.new_sayable_date(ja, .normal)
println(sd.format_date('2025-03-15') or { '' })  // "3月15日"
```

## API

```v
fn new_sayable_date(locale &DateLocale, compactness Compactness) SayableDate
fn (sd &SayableDate) format_date(date string) ?string
fn (sd &SayableDate) format_date_with_year(date string) ?string
fn (sd &SayableDate) format_relative(date string, as_of string) ?string
fn get_date_locale(code string) ?DateLocale
```

**Parameters:**

- `date` — `YYYY-MM-DD` or ISO datetime string.
- `as_of` — Reference date as `YYYY-MM-DD`.

**Returns:** `?string` — optional string. Returns `none` if input is missing or invalid.

## Development

```bash
v test .
```

## License

[MIT](../../LICENSE.md)
