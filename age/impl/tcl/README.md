# sayable-age -- Tcl

Human-friendly age formatting -- how parents actually talk about little ones.

```tcl
source sayableage.tcl

set en [::sayableage::get_locale "en"]
set fmt [::sayableage::new $en]
::sayableage::format_age $fmt "2025-06-01" "2025-06-15"
# "2 weeks"
```

## Setup

Plain Tcl package. Not published to any registry -- use as a local dependency.

```bash
cd age/impl/tcl
```

Requires Tcl >= 8.6. Zero external dependencies.

## Usage

```tcl
source sayableage.tcl

# Module-level convenience functions (English locale)
::sayableage::age "2025-01-15" "2025-07-15"
# "6 months"

::sayableage::stage "2025-01-15" "2025-06-15"
# "Infant"
```

## Internationalization

```tcl
source sayableage.tcl

set ja [::sayableage::get_locale "ja"]
set fmt [::sayableage::new $ja]
::sayableage::format_age $fmt "2025-01-01" "2025-07-15"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```tcl
::sayableage::age date_of_birth ?as_of?          ;# -> string or ""
::sayableage::stage date_of_birth ?as_of? ?gender? ;# -> string or ""
::sayableage::get_locale code                     ;# -> locale dict or ""
```

### Constructor

```tcl
set fmt [::sayableage::new locale ?compactness?]
::sayableage::format_age fmt date_of_birth ?as_of?           ;# -> string or ""
::sayableage::format_stage fmt date_of_birth ?as_of? ?gender? ;# -> string or ""
```

**Parameters:**

- `locale` -- A locale dict (e.g., from `::sayableage::get_locale "en"`).
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `date_of_birth` -- `"YYYY-MM-DD"` string. Returns `""` for empty strings.
- `as_of` -- Reference date (`"YYYY-MM-DD"`). Defaults to today if omitted.
- `gender` -- `"m"` or `"f"` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string, or `""` on invalid input.

## Development

```bash
tclsh test_format_age.tcl    # Run tests
```

## License

[MIT](../../LICENSE.md)
