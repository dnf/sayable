# sayable-duration -- Wren

Human-friendly duration and relative time formatting.

```wren
import "./format_duration" for SayableDuration

var fmt = SayableDuration.new(ENLocale)
fmt.formatDuration(3600)
// "1 hour"
```

## Setup

Plain Wren module. Requires `wren_cli` >= 0.4.0. Zero external dependencies.

```bash
# macOS
brew install wren-cli

# Linux (build from source)
git clone --depth 1 https://github.com/wren-lang/wren-cli.git
cd wren-cli && make
sudo cp bin/wren_cli /usr/local/bin/
```

## Usage

```wren
import "./format_duration" for SayableDuration
import "./locales/en" for ENLocale

var fmt = SayableDuration.new(ENLocale)
fmt.formatDuration(3600)                                         // "1 hour"
fmt.formatDuration(5400)                                         // "1\u00bd hours"
fmt.formatDuration("2025-01-15T10:00:00", "2025-01-15T11:30:00") // "1\u00bd hours"
fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00")    // "45 minutes ago"
fmt.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00")    // "in 3 hours"
```

## Internationalization

```wren
import "./format_duration" for SayableDuration
import "./locales/ja" for JALocale

var ja = SayableDuration.new(JALocale)
ja.formatDuration(120)  // "2\u5206"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Constructor

```wren
var fmt = SayableDuration.new(locale)
var fmt = SayableDuration.new(locale, compactness)
fmt.formatDuration(seconds)             // String or null
fmt.formatDuration(start, end)          // String or null (ISO timestamps)
fmt.formatSince(start, asOf)            // String or null
fmt.formatUntil(target, asOf)           // String or null
```

**Parameters:**

- `locale` -- A locale class (e.g., `ENLocale` from `import "./locales/en" for ENLocale`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `seconds` -- Duration in seconds (integer). Returns `null` for `null` or negative.
- `start`, `end` -- ISO datetime strings for timestamp-based duration.
- `asOf` -- Reference timestamp for `formatSince`/`formatUntil`.

**Returns:** Formatted string, or `null` on invalid input.

### Static Methods

```wren
SayableDuration.getLocale(code)    // Locale class or null
SayableDuration.version            // "0.5.0"
```

## Development

```bash
wren_cli test_format_duration.wren    # Run tests
```

## License

[MIT](../../LICENSE.md)
