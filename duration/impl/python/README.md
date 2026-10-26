# sayable-duration (Python)

Human-friendly duration and relative time formatting — how people say how long something took.

## Installation

```bash
pip install sayable-duration
```

## Usage

```python
from sayable_duration import SayableDuration, EN, DE, format_duration, format_since, format_until

# Convenience functions (English, normal compactness)
format_duration(222)                                                 # "3 minutes, 42 seconds"
format_duration(5400)                                                # "1½ hours"
format_duration("2025-03-15T09:00:00Z", "2025-03-15T11:30:00Z")      # "2½ hours"
format_since("2025-03-12T09:00:00Z", "2025-03-15T09:00:00Z")         # "3 days ago"
format_until("2025-03-15T11:00:00Z", "2025-03-15T09:00:00Z")         # "in 2 hours"

# The class gives locale and compactness control
SayableDuration(DE).format_duration(5400)                            # "1½ Stunden"
SayableDuration(EN, "compact").format_duration(5400)                 # "1½h"
```

## API

### `SayableDuration(locale, compactness="normal")`

Create a formatter with a specific locale and compactness level.

- **locale**: A `DurationLocale` instance (e.g. `EN`, `DE`, `JA`), or `get_locale(code)`
- **compactness**: `"normal"` | `"short"` | `"compact"`

### `format_duration(start_or_seconds, end=None) -> str | None`

Format a duration given in seconds (`int`), or between two ISO timestamps.

### `format_since(start, as_of) -> str | None`

Elapsed time between two ISO timestamps ("3 days ago"); "just now" when they're equal.

### `format_until(target, as_of) -> str | None`

Remaining time between two ISO timestamps ("in 2 hours").

All return `None` for invalid input, negative durations and durations over 500 years.

## Locales

168 locales. Look one up by code:

```python
from sayable_duration import get_locale

locale = get_locale("fr")
```

## License

[MIT](../../../LICENSE.md)
