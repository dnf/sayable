# sayable-date -- Tcl

Human-friendly date formatting -- how people reference dates in conversation.

```tcl
source format_date.tcl

set en [::sayabledate::get_locale "en"]
set fmt [::sayabledate::new $en]
::sayabledate::format_date $fmt "2025-03-15"
# "March 15th"
```

## Setup

Plain Tcl package. Not published to any registry -- use as a local dependency.

```bash
cd date/impl/tcl
```

Requires Tcl >= 8.6. Zero external dependencies.

## Usage

```tcl
source format_date.tcl

# Module-level convenience functions (English locale)
::sayabledate::date "2025-03-15"
# "March 15th"

::sayabledate::relative "2025-03-16" "2025-03-15"
# "tomorrow"
```

## Internationalization

```tcl
source format_date.tcl

set ja [::sayabledate::get_locale "ja"]
set fmt [::sayabledate::new $ja]
::sayabledate::format_date $fmt "2025-03-15"
# "3月15日"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```tcl
::sayabledate::date date                           ;# -> string or ""
::sayabledate::relative date as_of                 ;# -> string or ""
::sayabledate::get_locale code                     ;# -> locale dict or ""
```

### Constructor

```tcl
set fmt [::sayabledate::new locale ?compactness?]
::sayabledate::format_date fmt date                ;# -> string or ""
::sayabledate::format_date_with_year fmt date       ;# -> string or ""
::sayabledate::format_relative fmt date as_of       ;# -> string or ""
```

**Parameters:**

- `locale` -- A locale dict (e.g., from `::sayabledate::get_locale "en"`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date` -- `"YYYY-MM-DD"` or ISO datetime string. Returns `""` for empty strings.
- `as_of` -- Reference date (`"YYYY-MM-DD"`).

**Returns:** Formatted string, or `""` on invalid input.

## Development

```bash
tclsh test_format_date.tcl    # Run tests
```

## License

[MIT](../../LICENSE.md)
