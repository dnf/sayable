# sayable-date — Janet

Human-friendly date formatting — how people reference dates in conversation.

```janet
(import ./format_date :as sd)

(sd/format-date "2025-03-15")
# "March 15th"
```

## Setup

Plain Janet module. Zero external dependencies.

```bash
cd date/impl/janet
```

Requires Janet >= 1.30. Zero external dependencies.

## Usage

```janet
(import ./format_date :as sd)

(sd/format-date "2025-03-15")
# "March 15th"

(sd/format-relative "2025-03-16" "2025-03-15")
# "tomorrow"
```

## Internationalization

```janet
(import ./format_date :as sd)

(def ja (sd/get-locale "ja"))
(def pt (sd/make-formatter ja))
((pt :format-date) "2025-03-15")
# "3月15日"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```janet
(sd/format-date date)              # -> string or nil
(sd/format-date-with-year date)    # -> string or nil
(sd/format-relative date as-of)    # -> string or nil
(sd/get-locale code)               # -> locale struct or nil
```

### Constructor

```janet
(def pt (sd/make-formatter locale compactness))
((pt :format-date) date)                  # -> string or nil
((pt :format-date-with-year) date)        # -> string or nil
((pt :format-relative) date as-of)        # -> string or nil
```

**Parameters:**

- `locale` — A locale struct (e.g., from `(sd/get-locale "en")`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date` — `"YYYY-MM-DD"` or ISO datetime string. Returns `nil` for empty strings or `nil`.
- `as-of` — Reference date (`"YYYY-MM-DD"`). Required for `format-relative`.

**Returns:** Formatted string, or `nil` on invalid input.

## Development

```bash
janet test_format_date.janet    # Run tests
```

## License

[MIT](../../LICENSE.md)
