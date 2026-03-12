# sayable-time — Janet

Human-friendly clock time formatting — tells time the way people talk.

```janet
(import ./format_time :as st)

(st/format-time "14:15")
# "a quarter past two"
```

## Setup

Plain Janet module. Zero external dependencies.

```bash
cd time/impl/janet
```

Requires Janet >= 1.30. Zero external dependencies.

## Usage

```janet
(import ./format_time :as st)

(st/format-time "09:30")
# "half past nine"

(st/format-time "00:00")
# "midnight"

(st/format-time "12:00")
# "noon"
```

## Internationalization

```janet
(import ./format_time :as st)

(def ja (st/get-locale "ja"))
(def pt (st/make-formatter ja))
((pt :format-time) "15:30")
# "三時半"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```janet
(st/format-time time)    # -> string or nil
(st/get-locale code)     # -> locale struct or nil
```

### Constructor

```janet
(def pt (st/make-formatter locale compactness))
((pt :format-time) time)    # -> string or nil
```

**Parameters:**

- `locale` — A locale struct (e.g., from `(st/get-locale "en")`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `time` — `"HH:MM"` or ISO datetime string. Returns `nil` for empty strings or `nil`.

**Returns:** Formatted string, or `nil` on invalid input.

## Development

```bash
janet test_format_time.janet    # Run tests
```

## License

[MIT](../../LICENSE.md)
