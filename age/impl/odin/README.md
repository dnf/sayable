# sayable-age -- Odin

Human-friendly age formatting -- how parents actually talk about little ones.

```odin
package main

import sa "sayableage"

main :: proc() {
    buf: [256]u8
    age := sa.format_age(buf[:], &sa.locale_en, .Normal, "2025-06-01", "2025-06-15")
    // "2 weeks"

    stage := sa.format_stage(&sa.locale_en, "2025-01-15", "2025-06-15", "")
    // "Infant"
}
```

## Installation

Copy `sayableage.odin` and `locales.odin` into your project.

Zero external dependencies.

## Usage

```odin
package main

import sa "sayableage"

main :: proc() {
    buf: [256]u8

    age := sa.format_age(buf[:], &sa.locale_en, .Normal, "2025-06-15", "2025-06-15")
    // "Newborn"

    age2 := sa.format_age(buf[:], &sa.locale_en, .Normal, "2025-06-01", "2025-06-15")
    // "2 weeks"

    age3 := sa.format_age(buf[:], &sa.locale_en, .Normal, "2025-01-15", "2025-07-15")
    // "6 months"

    age4 := sa.format_age(buf[:], &sa.locale_en, .Normal, "2022-06-15", "2025-12-15")
    // "3½ years"

    stage := sa.format_stage(&sa.locale_en, "2025-01-15", "2025-06-15", "")
    // "Infant"

    // Returns nil for empty/future dates or ages exceeding 500 years
    nothing := sa.format_age(buf[:], &sa.locale_en, .Normal, "", "2025-06-15")
    // nil
}
```

## Internationalization

```odin
package main

import sa "sayableage"

main :: proc() {
    buf: [256]u8
    age := sa.format_age(buf[:], &sa.locale_ja, .Normal, "2025-01-01", "2025-07-15")
    // "6ヶ月"

    stage := sa.format_stage(&sa.locale_ja, "2025-01-01", "2025-07-15", "")
    // "乳児"
}
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```odin
normal  := sa.format_age(buf[:], &sa.locale_en, .Normal,  dob, as_of) // "3 months"
short_m := sa.format_age(buf[:], &sa.locale_en, .Short,   dob, as_of) // "3 mo"
compact := sa.format_age(buf[:], &sa.locale_en, .Compact, dob, as_of) // "3m"
```

## API

```odin
format_age :: proc(buf: []u8, locale: ^Age_Locale, compactness: Compactness, dob, as_of: string) -> Maybe(string)

format_stage :: proc(locale: ^Age_Locale, dob, as_of, gender: string) -> Maybe(string)
```

**Parameters:**

- `buf` -- Output buffer for `format_age` (caller-provided, no allocation).
- `locale` -- Pointer to a locale definition.
- `compactness` -- `.Normal`, `.Short`, or `.Compact`.
- `dob` -- `YYYY-MM-DD` date string.
- `as_of` -- Reference date string.
- `gender` -- `"f"` for feminine stage labels, or `""`.

**Returns:** `Maybe(string)` -- a slice of `buf` with the formatted string, or `nil` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
odin test .    # Run tests
odin build .   # Build
```

## License

[MIT](../../LICENSE.md)
