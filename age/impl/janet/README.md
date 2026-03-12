# sayable-age — Janet

Human-friendly age formatting — how parents actually talk about little ones.

```janet
(import ./sayableage :as sa)

(sa/format-age "2025-06-01" "2025-06-15")
# "2 weeks"
```

## Setup

Plain Janet module. Zero external dependencies.

```bash
cd age/impl/janet
```

Requires Janet >= 1.30. Zero external dependencies.

## Usage

```janet
(import ./sayableage :as sa)

(sa/format-age "2025-01-15" "2025-07-15")
# "6 months"

(sa/format-stage "2025-01-15" "2025-06-15")
# "Infant"
```

## Internationalization

```janet
(import ./sayableage :as sa)

(def ja (sa/get-locale "ja"))
(def pt (sa/make-formatter ja))
((pt :format-age) "2025-01-01" "2025-07-15")
# "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```janet
(sa/format-age date-of-birth as-of)      # -> string or nil
(sa/format-stage date-of-birth as-of gender)  # -> string or nil
(sa/get-locale code)                      # -> locale struct or nil
```

### Constructor

```janet
(def pt (sa/make-formatter locale compactness))
((pt :format-age) date-of-birth as-of)             # -> string or nil
((pt :format-stage) date-of-birth as-of gender)     # -> string or nil
```

**Parameters:**

- `locale` — A locale struct (e.g., from `(sa/get-locale "en")`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date-of-birth` — `"YYYY-MM-DD"` string. Returns `nil` for empty strings or `nil`.
- `as-of` — Reference date (`"YYYY-MM-DD"`). Defaults to today if omitted.
- `gender` — `"m"` or `"f"` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string, or `nil` on invalid input.

## Development

```bash
janet test_format_age.janet    # Run tests
```

## License

[MIT](../../LICENSE.md)
