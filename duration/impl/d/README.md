# sayable-duration — D

Human-friendly duration and relative time formatting — how people talk about elapsed time.

```d
import sayableduration.format_duration;
import sayableduration.locales;

auto sd = SayableDuration(EN);
sd.formatDuration(3600).get;   // "1 hour"
sd.formatDuration(5400).get;   // "1½ hours"
```

## Installation

Add the source files to your D project. Requires LDC or DMD. Zero external dependencies.

## Usage

```d
import sayableduration.format_duration;
import sayableduration.locales;

auto sd = SayableDuration(EN);

// Duration from seconds
sd.formatDuration(0).get;       // "just now"
sd.formatDuration(90).get;      // "1 minute, 30 seconds"
sd.formatDuration(3600).get;    // "1 hour"
sd.formatDuration(5400).get;    // "1½ hours"
sd.formatDuration(86400).get;   // "1 day"

// Duration from ISO timestamps
sd.formatDurationISO("2025-01-15T10:00:00", "2025-01-15T11:30:00").get;  // "1½ hours"

// Elapsed time
sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00").get;  // "45 minutes ago"

// Remaining time
sd.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00").get;  // "in 3 hours"

// Returns null for invalid input
auto result = sd.formatDuration(-1);
assert(result.isNull);
```

## Internationalization

```d
auto loc = getLocale("de");
auto sd = SayableDuration(*loc);
sd.formatDuration(3600).get;  // "1 Stunde"
sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00").get;  // "vor 5 Minuten"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```d
SayableDuration(EN).formatDuration(3600).get;                        // "1 hour"
SayableDuration(EN, Compactness.short_).formatDuration(3600).get;    // "1h"
SayableDuration(EN, Compactness.compact).formatDuration(3600).get;   // "1h"
```

## API

```d
struct SayableDuration {
    this(ref const DurationLocale locale, Compactness compactness = Compactness.normal);

    Nullable!string formatDuration(int totalSeconds);
    Nullable!string formatDurationISO(string start, string end);
    Nullable!string formatSince(string start, string asOf);
    Nullable!string formatUntil(string target, string asOf);
}

const(DurationLocale)* getLocale(string code);
```

**Parameters:**

- `totalSeconds` — Duration in seconds (non-negative).
- `start`, `end`, `asOf`, `target` — ISO 8601 datetime strings.

**Returns:** `Nullable!string` — check with `.isNull` before accessing `.get`.

## Development

```bash
ldc2 -unittest -main -I=source source/sayableduration/*.d && ./source/sayableduration/format_duration
```

## License

[MIT](../../LICENSE.md)
