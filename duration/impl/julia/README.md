# sayable-duration — Julia

Human-friendly duration and relative time formatting — how people talk about elapsed time.

```julia
using SayableDuration
en = SayableDurationFormatter(get_locale("en"))
format_duration(en, 3600)               # "1 hour"
format_duration(en, 5400)               # "1½ hours"
format_since(en, "2025-01-15T10:00:00", "2025-01-15T10:45:00")   # "45 minutes ago"
```

## Installation

Add to your Julia project:

```julia
using Pkg
Pkg.add(url="https://github.com/dnf/sayable", subdir="duration/impl/julia")
```

Requires Julia 1.9+. Zero external dependencies.

## Usage

```julia
using SayableDuration

en = SayableDurationFormatter(get_locale("en"))

# Duration from seconds
format_duration(en, 0)        # "just now"
format_duration(en, 45)       # "45 seconds"
format_duration(en, 90)       # "1 minute, 30 seconds"
format_duration(en, 3600)     # "1 hour"
format_duration(en, 5400)     # "1½ hours"
format_duration(en, 86400)    # "1 day"
format_duration(en, 604800)   # "1 week"

# Duration from ISO timestamps
format_duration(en, "2025-01-15T10:00:00", "2025-01-15T11:30:00")  # "1½ hours"

# Elapsed time ("X ago")
format_since(en, "2025-01-15T10:00:00", "2025-01-15T10:45:00")   # "45 minutes ago"

# Remaining time ("in X")
format_until(en, "2025-01-15T13:00:00", "2025-01-15T10:00:00")   # "in 3 hours"

# Returns nothing for invalid input or negative durations
format_duration(en, -1)   # nothing
```

## Internationalization

```julia
using SayableDuration

ja = SayableDurationFormatter(get_locale("ja"))
format_duration(ja, 120)   # "2分"
format_since(ja, "2025-01-15T10:00:00", "2025-01-15T11:00:00")   # "1時間前"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```julia
using SayableDuration

en = get_locale("en")
normal  = SayableDurationFormatter(en, Normal)   # "1 hour"
short   = SayableDurationFormatter(en, Short)    # "1h"
compact = SayableDurationFormatter(en, Compact)  # "1h"
```

## API

```julia
# Struct-based with locale
SayableDurationFormatter(locale::DurationLocale, compactness::Compactness = Normal)
format_duration(f::SayableDurationFormatter, seconds::Int) -> Union{String, Nothing}
format_duration(f::SayableDurationFormatter, start::String, end_time::String) -> Union{String, Nothing}
format_since(f::SayableDurationFormatter, start::String, as_of::String) -> Union{String, Nothing}
format_until(f::SayableDurationFormatter, target::String, as_of::String) -> Union{String, Nothing}

# Locale lookup
get_locale(code::String) -> Union{DurationLocale, Nothing}
```

**Parameters:**

- `seconds` — Non-negative integer. Returns `nothing` for negative values.
- `start`, `end_time`, `as_of`, `target` — ISO 8601 datetime strings.

**Returns:** A human-readable `String`, or `nothing` if input is missing or invalid.

## Development

```bash
julia --project -e 'using Pkg; Pkg.test()'   # Run tests
```

## License

[MIT](../../LICENSE.md)
