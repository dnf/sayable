# sayable-age — Wren

Human-friendly age formatting — how parents actually talk about little ones.

```wren
import "./sayableage" for SayableAge

SayableAge.formatAge("2025-06-01", "2025-06-15")
// "2 weeks"
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
import "./sayableage" for SayableAge

SayableAge.formatAge("2025-01-15", "2025-07-15")
// "6 months"

SayableAge.formatStage("2025-01-15", "2025-06-15")
// "Infant"
```

## Internationalization

```wren
import "./sayableage" for SayableAge
import "./locales/ja" for JALocale

var pt = SayableAge.new(JALocale)
pt.formatAge("2025-01-01", "2025-07-15")
// "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Static methods (English locale)

```wren
SayableAge.formatAge(dateOfBirth, asOf)              // String or null
SayableAge.formatStage(dateOfBirth, asOf)             // String or null
SayableAge.formatStage(dateOfBirth, asOf, gender)     // String or null
SayableAge.getLocale(code)                            // Locale class or null
SayableAge.version                                    // "0.5.0"
```

### Constructor

```wren
var pt = SayableAge.new(locale)
var pt = SayableAge.new(locale, compactness)
pt.formatAge(dateOfBirth, asOf)                       // String or null
pt.formatStage(dateOfBirth, asOf)                     // String or null
pt.formatStage(dateOfBirth, asOf, gender)             // String or null
```

**Parameters:**

- `locale` — A locale class (e.g., `ENLocale` from `import "./locales/en" for ENLocale`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `dateOfBirth` — `"YYYY-MM-DD"` string. Returns `null` for empty strings or `null`.
- `asOf` — Reference date (`"YYYY-MM-DD"`). Required in Wren (no built-in date library).
- `gender` — `"m"` or `"f"` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string, or `null` on invalid input.

## Development

```bash
wren_cli test_format_age.wren    # Run tests
```

## License

[MIT](../../LICENSE.md)
