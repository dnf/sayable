# sayable-time -- Tcl

Human-friendly clock time formatting -- tells time the way people talk.

```tcl
source format_time.tcl

set en [::sayabletime::get_locale "en"]
set fmt [::sayabletime::new $en]
::sayabletime::format_time $fmt "14:15"
# "a quarter past two"
```

## Setup

Plain Tcl package. Not published to any registry -- use as a local dependency.

```bash
cd time/impl/tcl
```

Requires Tcl >= 8.6. Zero external dependencies.

## Usage

```tcl
source format_time.tcl

# Module-level convenience functions (English locale)
::sayabletime::time_fmt "09:30"
# "half past nine"
```

## Internationalization

```tcl
source format_time.tcl

set ja [::sayabletime::get_locale "ja"]
set fmt [::sayabletime::new $ja]
::sayabletime::format_time $fmt "15:30"
# "三時半"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```tcl
::sayabletime::time_fmt time                       ;# -> string or ""
::sayabletime::get_locale code                     ;# -> locale dict or ""
```

### Constructor

```tcl
set fmt [::sayabletime::new locale ?compactness?]
::sayabletime::format_time fmt time                ;# -> string or ""
```

**Parameters:**

- `locale` -- A locale dict (e.g., from `::sayabletime::get_locale "en"`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `time` -- `"HH:MM"` or ISO datetime string. Returns `""` for empty strings.

**Returns:** Formatted string, or `""` on invalid input.

## Development

```bash
tclsh test_format_time.tcl    # Run tests
```

## License

[MIT](../../LICENSE.md)
