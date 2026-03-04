# sayable-date (Python)

Human-friendly date formatting — how people reference dates in conversation.

## Installation

```bash
pip install sayable-date
```

## Usage

```python
from sayable_date import SayableDate, EN, format_date, format_relative

# Using convenience functions (English, normal compactness)
format_date("2025-03-15")                              # "March 15th"
format_relative("2025-03-16", as_of="2025-03-15")     # "tomorrow"

# Using the class for locale and compactness control
sd = SayableDate(EN)
sd.format_date("2025-03-15")                            # "March 15th"
sd.format_relative("2025-03-16", as_of="2025-03-15")   # "tomorrow"
sd.format_relative("2025-03-20", as_of="2025-03-15")   # "this Thursday"
sd.format_relative("2025-04-10", as_of="2025-03-15")   # "April 10th"

# Short compactness
sd_short = SayableDate(EN, "short")
sd_short.format_date("2025-03-15")                      # "Mar 15"

# Compact
sd_compact = SayableDate(EN, "compact")
sd_compact.format_date("2025-03-15")                    # "3/15"
```

## API

### `SayableDate(locale, compactness="normal")`

Create a formatter with a specific locale and compactness level.

- **locale**: A `DateLocale` instance (e.g., `EN`, `DE`, `FR`, `JA`)
- **compactness**: `"normal"` | `"short"` | `"compact"`

### `format_date(date) -> str | None`

Format a calendar date. Always absolute — no proximity logic.

- **date**: `"YYYY-MM-DD"` or ISO datetime string

### `format_relative(date, *, as_of) -> str | None`

Format a date relative to `as_of`, picking the most natural reference.

- **date**: `"YYYY-MM-DD"` or ISO datetime string
- **as_of**: `"YYYY-MM-DD"` or ISO datetime string

Returns `None` for invalid input.

## Locales

71 locales available. Import by code:

```python
from sayable_date.locales.de import DE
from sayable_date.locales.ja import JA
from sayable_date import get_locale

locale = get_locale("fr")  # look up by code string
```

## License

[MIT](../../../LICENSE.md)
