# sayable-time (Python)

Human-friendly clock time formatting — tells time the way people talk.

## Installation

```bash
pip install sayable-time
```

## Usage

```python
from sayable_time import SayableTime, format_time, get_locale

# Convenience function (English, normal compactness)
format_time("15:15")                                         # "a quarter past three"
format_time("07:30")                                         # "half past seven"
format_time("14:58")                                         # "three o'clock" (rounds to 5 minutes)
format_time("00:00")                                         # "midnight"

# The class gives locale and compactness control
SayableTime(get_locale("de")).format_time("15:30")           # "halb vier"
SayableTime(get_locale("fr")).format_time("14:45")           # "trois heures moins le quart"
SayableTime(get_locale("en"), "short").format_time("14:15")  # "2:15 PM"
SayableTime(get_locale("en"), "compact").format_time("14:15")  # "2:15p"
```

## API

### `SayableTime(locale, compactness="normal")`

Create a formatter with a specific locale and compactness level.

- **locale**: A `TimeLocale` instance, e.g. `get_locale("ja")`
- **compactness**: `"normal"` (spoken) | `"short"` (digital) | `"compact"` (terse digital)

### `format_time(time) -> str | None`

Format an `"HH:MM"` time. Normal compactness rounds to the nearest 5 minutes and speaks the time;
short and compact use the locale's digital format. Returns `None` for invalid input.

## Locales

168 locales. Look one up by code with `get_locale("sw")`.

## License

[MIT](../../../LICENSE.md)
