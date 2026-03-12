# sayable-duration — Janet

Human-friendly duration and relative time formatting — how people speak about elapsed and remaining time.

```janet
(import ./format_duration :as sd)

(sd/format-duration 5400)
# "1½ hours"
```

## Setup

Plain Janet module. Zero external dependencies.

```bash
cd duration/impl/janet
```

Requires Janet >= 1.30. Zero external dependencies.

## Usage

```janet
(import ./format_duration :as sd)

(sd/format-duration 3600)
# "1 hour"

(sd/format-since "2025-01-15T10:00:00" "2025-01-15T10:45:00")
# "45 minutes ago"

(sd/format-until "2025-01-15T13:00:00" "2025-01-15T10:00:00")
# "in 3 hours"
```

## Internationalization

```janet
(import ./format_duration :as sd)

(def ja (sd/get-locale "ja"))
(def pt (sd/make-formatter ja))
((pt :format-duration) 120)
# "2分"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```janet
(sd/format-duration seconds-or-start &opt end)  # -> string or nil
(sd/format-since start as-of)                    # -> string or nil
(sd/format-until target as-of)                   # -> string or nil
(sd/get-locale code)                             # -> locale struct or nil
```

### Constructor

```janet
(def pt (sd/make-formatter locale compactness))
((pt :format-duration) seconds-or-start &opt end)  # -> string or nil
((pt :format-since) start as-of)                    # -> string or nil
((pt :format-until) target as-of)                   # -> string or nil
```

**Parameters:**

- `locale` — A locale struct (e.g., from `(sd/get-locale "en")`).
- `compactness` — `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `seconds-or-start` — Integer (seconds) or ISO datetime string. Returns `nil` for `nil`.
- `end` — ISO datetime end (required when start is a string).
- `start` / `target` — ISO datetime strings for relative time.
- `as-of` — Reference timestamp (ISO datetime).

**Returns:** Formatted string, or `nil` on invalid input.

## Development

```bash
janet test_format_duration.janet    # Run tests
```

## License

[MIT](../../LICENSE.md)
