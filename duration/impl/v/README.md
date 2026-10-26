# sayable-duration — V

Human-friendly duration and relative time formatting — formats durations the way people speak.

```v
import locales

fn main() {
    sd := locales.new_sayable_duration(locales.get_duration_locale('en')!, .normal)
    println(sd.format_duration(5400) or { '' })  // "1½ hours"
}
```

## Installation

Copy the V source files into your project. Requires V 0.4+. Zero external dependencies.

## Usage

```v
import locales

fn main() {
    en := locales.get_duration_locale('en')!
    sd := locales.new_sayable_duration(en, .normal)

    // Duration from seconds
    println(sd.format_duration(0) or { '' })        // "just now"
    println(sd.format_duration(45) or { '' })       // "45 seconds"
    println(sd.format_duration(90) or { '' })       // "1 minute, 30 seconds"
    println(sd.format_duration(5400) or { '' })     // "1½ hours"
    println(sd.format_duration(86400) or { '' })    // "1 day"

    // Duration from ISO timestamps
    println(sd.format_duration_iso('2025-01-15T10:00:00', '2025-01-15T11:30:00') or { '' })  // "1½ hours"

    // Elapsed time
    println(sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:45:00') or { '' })  // "45 minutes ago"

    // Time until
    println(sd.format_until('2025-01-15T13:00:00', '2025-01-15T10:00:00') or { '' })  // "in 3 hours"

    // Short compactness
    sd_short := locales.new_sayable_duration(en, .short)
    println(sd_short.format_duration(3600) or { '' })  // "1h"

    // Compact
    sd_compact := locales.new_sayable_duration(en, .compact)
    println(sd_compact.format_duration(90) or { '' })   // "1m30s"
}
```

## Internationalization

```v
ja := locales.get_duration_locale('ja')!
sd := locales.new_sayable_duration(ja, .normal)
println(sd.format_duration(120) or { '' })  // "2分"
```

## API

```v
fn new_sayable_duration(locale &DurationLocale, compactness Compactness) SayableDuration
fn (sd &SayableDuration) format_duration(total_seconds i64) ?string
fn (sd &SayableDuration) format_duration_iso(start string, end string) ?string
fn (sd &SayableDuration) format_since(start string, as_of string) ?string
fn (sd &SayableDuration) format_until(target string, as_of string) ?string
fn get_duration_locale(code string) ?DurationLocale
```

**Parameters:**

- `total_seconds` — Duration in seconds.
- `start`, `end`, `as_of`, `target` — ISO datetime strings.

**Returns:** `?string` — optional string. Returns `none` for invalid or negative input.

## Development

```bash
v test .
```

## License

[MIT](../../LICENSE.md)
