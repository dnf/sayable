# sayable-duration -- Tcl

Human-friendly duration and relative time formatting -- how people talk about time spans.

```tcl
source format_duration.tcl

set en [::sayableduration::get_locale "en"]
set fmt [::sayableduration::new $en]
::sayableduration::format_duration $fmt 5400
# "1½ hours"
```

## Setup

Plain Tcl package. Not published to any registry -- use as a local dependency.

```bash
cd duration/impl/tcl
```

Requires Tcl >= 8.6. Zero external dependencies.

## Usage

```tcl
source format_duration.tcl

# Module-level convenience functions (English locale)
::sayableduration::duration 3600
# "1 hour"

::sayableduration::since "2025-01-15T10:00:00" "2025-01-15T10:45:00"
# "45 minutes ago"

::sayableduration::until "2025-01-15T13:00:00" "2025-01-15T10:00:00"
# "in 3 hours"
```

## Internationalization

```tcl
source format_duration.tcl

set ja [::sayableduration::get_locale "ja"]
set fmt [::sayableduration::new $ja]
::sayableduration::format_duration $fmt 120
# "2分"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```tcl
::sayableduration::duration value ?end?             ;# -> string or ""
::sayableduration::since start as_of                ;# -> string or ""
::sayableduration::until target as_of               ;# -> string or ""
::sayableduration::get_locale code                  ;# -> locale dict or ""
```

### Constructor

```tcl
set fmt [::sayableduration::new locale ?compactness?]
::sayableduration::format_duration fmt seconds       ;# -> string or ""
::sayableduration::format_duration fmt start end     ;# -> string or ""
::sayableduration::format_since fmt start as_of      ;# -> string or ""
::sayableduration::format_until fmt target as_of     ;# -> string or ""
```

**Parameters:**

- `locale` -- A locale dict (e.g., from `::sayableduration::get_locale "en"`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `seconds` -- Integer number of seconds. Negative values return `""`.
- `start`, `end`, `target`, `as_of` -- ISO datetime strings (`"YYYY-MM-DDTHH:MM:SS"`).

**Returns:** Formatted string, or `""` on invalid input.

## Development

```bash
tclsh test_format_duration.tcl    # Run tests
```

## License

[MIT](../../LICENSE.md)
