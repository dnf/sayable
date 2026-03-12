# sayable-time — D

Human-friendly clock time formatting — tells time the way people talk.

```d
import sayabletime.format_time;
import sayabletime.locales;

auto st = SayableTime(EN);
st.formatTime("14:15").get;   // "a quarter past two"
st.formatTime("09:30").get;   // "half past nine"
```

## Installation

Add the source files to your D project. Requires LDC or DMD. Zero external dependencies.

## Usage

```d
import sayabletime.format_time;
import sayabletime.locales;

auto st = SayableTime(EN);

// Natural language clock time
st.formatTime("00:00").get;   // "midnight"
st.formatTime("12:00").get;   // "noon"
st.formatTime("15:00").get;   // "three o'clock"
st.formatTime("14:15").get;   // "a quarter past two"
st.formatTime("09:30").get;   // "half past nine"
st.formatTime("10:45").get;   // "a quarter to eleven"

// Accepts ISO datetime strings
st.formatTime("2025-01-15T14:15:00").get;  // "a quarter past two"

// Returns null for invalid input
auto result = st.formatTime("");
assert(result.isNull);
```

## Internationalization

```d
auto loc = getLocale("de");
auto st = SayableTime(*loc);
st.formatTime("15:30").get;  // "halb vier"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```d
SayableTime(EN).formatTime("14:15").get;                       // "a quarter past two"
SayableTime(EN, Compactness.short_).formatTime("14:15").get;   // "2:15 PM"
SayableTime(EN, Compactness.compact).formatTime("14:15").get;  // "2:15p"
```

## API

```d
struct SayableTime {
    this(ref const TimeLocale locale, Compactness compactness = Compactness.normal);

    Nullable!string formatTime(string input);
}

const(TimeLocale)* getLocale(string code);
```

**Parameters:**

- `input` — Time as `HH:MM` or ISO 8601 datetime string.

**Returns:** `Nullable!string` — check with `.isNull` before accessing `.get`.

## Development

```bash
ldc2 -unittest -main -I=source source/sayabletime/*.d && ./source/sayabletime/format_time
```

## License

[MIT](../../LICENSE.md)
