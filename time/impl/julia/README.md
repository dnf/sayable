# sayable-time — Julia

Human-friendly clock time formatting — tells time the way people talk.

```julia
using SayableTime
en = SayableTimeFormatter(get_locale("en"))
format_time(en, "14:15")   # "a quarter past two"
format_time(en, "09:30")   # "half past nine"
format_time(en, "00:00")   # "midnight"
```

## Installation

Add to your Julia project:

```julia
using Pkg
Pkg.add(url="https://github.com/dnf/sayable", subdir="time/impl/julia")
```

Requires Julia 1.9+. Zero external dependencies.

## Usage

```julia
using SayableTime

en = SayableTimeFormatter(get_locale("en"))

# Natural language clock reading
format_time(en, "00:00")     # "midnight"
format_time(en, "12:00")     # "noon"
format_time(en, "15:00")     # "three o'clock"
format_time(en, "14:15")     # "a quarter past two"
format_time(en, "09:30")     # "half past nine"
format_time(en, "10:45")     # "a quarter to eleven"
format_time(en, "08:05")     # "five past eight"
format_time(en, "16:55")     # "five to five"

# ISO datetime input
format_time(en, "2025-01-15T14:15:00")   # "a quarter past two"

# Returns nothing for invalid input
format_time(en, "")          # nothing
format_time(en, "25:00")     # nothing
```

## Internationalization

```julia
using SayableTime

de = SayableTimeFormatter(get_locale("de"))
format_time(de, "15:30")   # "halb vier"

ja = SayableTimeFormatter(get_locale("ja"))
format_time(ja, "15:30")   # "三時半"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```julia
using SayableTime

en = get_locale("en")
normal  = SayableTimeFormatter(en, Normal)   # "a quarter past two"
short   = SayableTimeFormatter(en, Short)    # "2:15 PM"
compact = SayableTimeFormatter(en, Compact)  # "2:15p"
```

## API

```julia
# Struct-based with locale
SayableTimeFormatter(locale::TimeLocale, compactness::Compactness = Normal)
format_time(f::SayableTimeFormatter, time::String) -> Union{String, Nothing}

# Locale lookup
get_locale(code::String) -> Union{TimeLocale, Nothing}
```

**Parameters:**

- `time` — `HH:MM` or ISO datetime string. Returns `nothing` for empty or invalid strings.

**Returns:** A human-readable `String`, or `nothing` if input is missing or invalid.

## Development

```bash
julia --project -e 'using Pkg; Pkg.test()'   # Run tests
```

## License

[MIT](../../LICENSE.md)
