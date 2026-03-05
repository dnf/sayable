# sayable-age — Lua

Human-friendly age formatting — how parents actually talk about little ones.

```lua
local sayableage = require("sayableage")

sayableage.format_age("2025-06-01", "2025-06-15")
-- "2 weeks"
```

## Setup

Plain Lua module. Not published to LuaRocks — use as a local dependency.

```bash
cd src/lua
```

Requires Lua >= 5.3. Zero external dependencies.

## Usage

```lua
local sayableage = require("sayableage")

sayableage.format_age("2025-01-15", "2025-07-15")
-- "6 months"

sayableage.format_stage("2025-01-15", "2025-06-15")
-- "Infant"
```

## Internationalization

```lua
local sayableage = require("sayableage")
local ja = require("locales.ja")

local pt = sayableage.new(ja)
pt.format_age("2025-01-01", "2025-07-15")
-- "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```lua
sayableage.format_age(date_of_birth, as_of)    --> string or nil
sayableage.format_stage(date_of_birth, as_of, gender)  --> string or nil
sayableage.get_locale(code)                     --> locale table or nil
```

### Constructor

```lua
local pt = sayableage.new(locale, compactness)
pt.format_age(date_of_birth, as_of)            --> string or nil
pt.format_stage(date_of_birth, as_of, gender)  --> string or nil
```

**Parameters:**

- `locale` — A locale table (e.g., `require("locales.en")`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date_of_birth` — `"YYYY-MM-DD"` string. Returns `nil` for empty strings or `nil`.
- `as_of` — Reference date (`"YYYY-MM-DD"`). Defaults to today if omitted.
- `gender` — `"m"` or `"f"` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string, or `nil` on invalid input.

## Development

```bash
busted test_sayableage.lua    # Run tests
luacheck sayableage.lua locales/  # Lint
```

## License

[MIT](../../LICENSE.md)
