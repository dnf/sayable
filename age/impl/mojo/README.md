# sayable-age -- Mojo

Human-friendly age formatting -- how parents actually talk about little ones.

```mojo
from sayable_age.formatter import format_age, format_stage

var age1 = format_age("2025-06-01", "2025-06-15")   # "2 weeks"
var age2 = format_age("2025-01-15", "2025-07-15")    # "6 months"
var age3 = format_age("2022-06-15", "2025-12-15")    # "3½ years"
```

## Requirements

Mojo SDK (via [Modular CLI](https://www.modular.com/mojo)). Zero external dependencies.

## Usage

```mojo
from sayable_age.formatter import SayableAge, format_age, format_stage
from sayable_age.locales.en import build_en

# Free functions -- English default
var age = format_age("2025-06-15", "2025-06-15")  # "Newborn"
var stage = format_stage("2025-01-15", "2025-06-15")  # "Infant"

# Returns empty string for invalid/future dates or ages exceeding 500 years
var invalid = format_age("", "2025-06-15")  # ""

# Struct-based with locale
var sa = SayableAge(build_en())
var result = sa.format_age("2022-06-15", "2025-12-15")  # "3½ years"
```

## Internationalization

```mojo
from sayable_age.formatter import SayableAge
from sayable_age.locales.ja import build_ja

var sa = SayableAge(build_ja())
var age = sa.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```mojo
var normal  = SayableAge(build_en())            # "3 months"
var short   = SayableAge(build_en(), "short")   # "3 mo"
var compact = SayableAge(build_en(), "compact") # "3m"
```

## API

```mojo
# Struct -- locale set once at construction
struct SayableAge:
    fn __init__(out self, locale: AgeLocale, compactness: String = "normal")
    fn format_age(self, dob: String, as_of: String = "") -> String
    fn format_stage(self, dob: String, as_of: String = "", gender: String = "") -> String

# Free functions -- English default
fn format_age(dob: String, as_of: String = "") -> String
fn format_stage(dob: String, as_of: String = "", gender: String = "") -> String
```

**Parameters:**

- `dob` -- Date of birth as `YYYY-MM-DD`. Returns empty string for empty strings.
- `as_of` -- Reference date as `YYYY-MM-DD`. Empty string is not supported (Mojo has no date stdlib).

**Returns:** `String` -- formatted age/stage, or empty string if input is invalid, DOB is in the future, or age exceeds 500 years.

**Note:** Unlike implementations in languages with date standard libraries, the Mojo implementation requires an explicit `as_of` date (defaulting to today is not supported since Mojo has no date/time stdlib).

## Development

```bash
mojo run tests/test_format_age.mojo   # Run tests
mojo build src/sayable_age            # Build
```

## Date Arithmetic

Since Mojo does not have a date/time standard library, this implementation includes manual date parsing and arithmetic using Julian Day Number calculations, following the same approach as the C implementation.

## License

[MIT](../../LICENSE.md)
