# sayable-date — Julia

Human-friendly date formatting — how people reference dates in conversation.

```julia
using SayableDate
en = SayableDateFormatter(get_locale("en"))
format_date(en, "2025-03-15")                        # "March 15th"
format_relative(en, "2025-03-16", "2025-03-15")      # "tomorrow"
format_relative(en, "2025-03-19", "2025-03-15")      # "this Wednesday"
```

## Installation

Add to your Julia project:

```julia
using Pkg
Pkg.add(url="https://github.com/dnf/sayable", subdir="date/impl/julia")
```

Requires Julia 1.9+. Zero external dependencies.

## Usage

```julia
using SayableDate

en = SayableDateFormatter(get_locale("en"))

# Absolute date formatting
format_date(en, "2025-03-15")              # "March 15th"
format_date(en, "2025-01-01")              # "January 1st"
format_date(en, "2025-03-15T14:30:00")     # "March 15th" (ISO datetime)

# Date with year
format_date_with_year(en, "2025-03-15")    # "March 15th, 2025"

# Relative date formatting
format_relative(en, "2025-03-15", "2025-03-15")   # "today"
format_relative(en, "2025-03-16", "2025-03-15")   # "tomorrow"
format_relative(en, "2025-03-14", "2025-03-15")   # "yesterday"
format_relative(en, "2025-03-19", "2025-03-15")   # "this Wednesday"
format_relative(en, "2025-03-22", "2025-03-15")   # "next Saturday"
format_relative(en, "2025-04-10", "2025-03-15")   # "April 10th"
format_relative(en, "2026-01-05", "2025-03-15")   # "January 5th, 2026"

# Returns nothing for invalid input
format_date(en, "")             # nothing
format_date(en, "invalid")      # nothing
```

## Internationalization

```julia
using SayableDate

ja = SayableDateFormatter(get_locale("ja"))
format_date(ja, "2025-03-15")                        # "3月15日"
format_relative(ja, "2025-03-16", "2025-03-15")      # "明日"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```julia
using SayableDate

en = get_locale("en")
normal  = SayableDateFormatter(en, Normal)   # "March 15th"
short   = SayableDateFormatter(en, Short)    # "Mar 15"
compact = SayableDateFormatter(en, Compact)  # "3/15"
```

## API

```julia
# Struct-based with locale
SayableDateFormatter(locale::DateLocale, compactness::Compactness = Normal)
format_date(f::SayableDateFormatter, date::String) -> Union{String, Nothing}
format_date_with_year(f::SayableDateFormatter, date::String) -> Union{String, Nothing}
format_relative(f::SayableDateFormatter, date::String, as_of::String) -> Union{String, Nothing}

# Locale lookup
get_locale(code::String) -> Union{DateLocale, Nothing}
```

**Parameters:**

- `date` — `YYYY-MM-DD` or ISO datetime string. Returns `nothing` for empty strings.
- `as_of` — Reference date as `YYYY-MM-DD`.

**Returns:** A human-readable `String`, or `nothing` if input is missing or invalid.

## Development

```bash
julia --project -e 'using Pkg; Pkg.test()'   # Run tests
```

## License

[MIT](../../LICENSE.md)
