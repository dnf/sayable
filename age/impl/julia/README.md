# sayable-age — Julia

Human-friendly age formatting — how parents actually talk about little ones.

```julia
using SayableAge
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2022-06-15", "2025-12-15")  # "3½ years"
```

## Installation

Add to your Julia project:

```julia
using Pkg
Pkg.add(url="https://github.com/dnf/sayable", subdir="age/impl/julia")
```

Requires Julia 1.9+. Zero external dependencies (only stdlib `Dates`).

## Usage

```julia
using SayableAge

# Module-level functions — English default
format_age("2025-06-15", "2025-06-15")  # "Newborn"
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"
format_age("2022-06-15", "2025-12-15")  # "3½ years"

# Developmental stage label
format_stage("2025-06-15", "2025-06-15")  # "Newborn"
format_stage("2025-01-15", "2025-06-15")  # "Infant"
format_stage("2024-06-15", "2025-06-15")  # "Toddler"

# Returns nothing for invalid/future dates or ages exceeding 500 years
format_age("")  # nothing
```

## Internationalization

```julia
using SayableAge

loc = get_locale("ja")
formatter = SayableAgeFormatter(loc, Normal)
format_age(formatter, "2025-01-01", "2025-07-15")  # "6ヶ月"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```julia
using SayableAge

en = get_locale("en")
normal  = SayableAgeFormatter(en, Normal)   # "3 months"
short   = SayableAgeFormatter(en, Short)    # "3 mo"
compact = SayableAgeFormatter(en, Compact)  # "3m"
```

## API

```julia
# Struct-based with locale
SayableAgeFormatter(locale::AgeLocale, compactness::Compactness = Normal)
format_age(f::SayableAgeFormatter, dob::String, as_of::String) -> Union{String, Nothing}
format_stage(f::SayableAgeFormatter, dob::String, as_of::String; gender::String="") -> Union{String, Nothing}

# Module-level functions — English default
format_age(dob::String, as_of::String) -> Union{String, Nothing}
format_stage(dob::String, as_of::String; gender::String="") -> Union{String, Nothing}

# Locale lookup
get_locale(code::String) -> Union{AgeLocale, Nothing}
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string. Returns `nothing` for empty strings.
- `as_of` — Reference date as `YYYY-MM-DD`.

**Returns:** A human-readable `String`, or `nothing` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
julia --project -e 'using Pkg; Pkg.test()'   # Run tests
```

## License

[MIT](../../LICENSE.md)
