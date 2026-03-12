# sayable-time -- Wren

Human-friendly clock time formatting -- tells time the way people talk.

```wren
import "./format_time" for SayableTime

var fmt = SayableTime.new(ENLocale)
fmt.formatTime("14:15")
// "a quarter past two"
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
import "./format_time" for SayableTime
import "./locales/en" for ENLocale

var fmt = SayableTime.new(ENLocale)
fmt.formatTime("14:15")                      // "a quarter past two"
fmt.formatTime("09:30")                      // "half past nine"
fmt.formatTime("00:00")                      // "midnight"
fmt.formatTime("2025-01-15T14:15:00")        // "a quarter past two"
```

## Internationalization

```wren
import "./format_time" for SayableTime
import "./locales/ja" for JALocale

var ja = SayableTime.new(JALocale)
ja.formatTime("15:30")  // "\u4e09\u6642\u534a"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Constructor

```wren
var fmt = SayableTime.new(locale)
var fmt = SayableTime.new(locale, compactness)
fmt.formatTime(time)                     // String or null
```

**Parameters:**

- `locale` -- A locale class (e.g., `ENLocale` from `import "./locales/en" for ENLocale`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `time` -- `"HH:MM"` or ISO datetime string. Returns `null` for empty strings or `null`.

**Returns:** Formatted string, or `null` on invalid input.

### Static Methods

```wren
SayableTime.getLocale(code)    // Locale class or null
SayableTime.version            // "0.5.0"
```

## Development

```bash
wren_cli test_format_time.wren    # Run tests
```

## License

[MIT](../../LICENSE.md)
