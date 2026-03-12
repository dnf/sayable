# sayable-date -- Wren

Human-friendly date formatting -- how people reference dates in conversation.

```wren
import "./format_date" for SayableDate

var fmt = SayableDate.new(ENLocale)
fmt.formatDate("2025-03-15")
// "March 15th"
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
import "./format_date" for SayableDate
import "./locales/en" for ENLocale

var fmt = SayableDate.new(ENLocale)
fmt.formatDate("2025-03-15")          // "March 15th"
fmt.formatDateWithYear("2025-03-15")  // "March 15th, 2025"
fmt.formatRelative("2025-03-16", "2025-03-15")  // "tomorrow"
```

## Internationalization

```wren
import "./format_date" for SayableDate
import "./locales/de" for DELocale

var de = SayableDate.new(DELocale)
de.formatDate("2025-03-15")  // "15. M\u00e4rz"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Constructor

```wren
var fmt = SayableDate.new(locale)
var fmt = SayableDate.new(locale, compactness)
fmt.formatDate(date)                    // String or null
fmt.formatDateWithYear(date)            // String or null
fmt.formatRelative(date, asOf)          // String or null
```

**Parameters:**

- `locale` -- A locale class (e.g., `ENLocale` from `import "./locales/en" for ENLocale`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date` -- `"YYYY-MM-DD"` or ISO datetime string. Returns `null` for empty strings or `null`.
- `asOf` -- Reference date (`"YYYY-MM-DD"`). Required for `formatRelative`.

**Returns:** Formatted string, or `null` on invalid input.

### Static Methods

```wren
SayableDate.getLocale(code)    // Locale class or null
SayableDate.version            // "0.5.0"
```

## Development

```bash
wren_cli test_format_date.wren    # Run tests
```

## License

[MIT](../../LICENSE.md)
