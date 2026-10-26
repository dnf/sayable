# sayable-date — Goose

Human-friendly date formatting — how people refer to dates in conversation: "today", "next Thursday", "March 15th".

```goose
import sayabledate from "../sayabledate";
import std;

fn main() {
    let en, found = sayabledate::get_locale("en");
    let day, ok = sayabledate::format_date(en, sayabledate::Compactness.Normal, "2025-03-15");
    print(day);    // March 15th

    let rel, ok_rel = sayabledate::format_relative(en, sayabledate::Compactness.Normal, "2025-03-20", "2025-03-15");
    print(rel);    // this Thursday
}
```

[Goose](https://aardappel.github.io/goose/) is a memory-safe systems language with no heap: every value lives on compiler-managed stacks, and programs compile to C. This implementation needs nothing beyond the Goose standard library.

## Installation

Install Goose v2026.3 or later (`just install goose` downloads the release), then import the package directory:

```goose
import sayabledate from "path/to/date/impl/goose/sayabledate";
```

## Usage

Every function takes explicit dates (`YYYY-MM-DD`, or an ISO datetime whose time part is ignored) and reports "no value" with a trailing `bool` instead of a null:

```goose
let fr, found = sayabledate::get_locale("fr");
let day, ok = sayabledate::format_date(fr, sayabledate::Compactness.Normal, "2025-03-01");
// day = "1er mars", ok = true

let rel, ok_rel = sayabledate::format_relative(fr, sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15");
// rel = "demain"

let bad, ok_bad = sayabledate::format_date(fr, sayabledate::Compactness.Normal, "not-a-date");
// ok_bad = false
```

## Relative tiers

| Offset from `as_of` | English output |
|---------------------|----------------|
| 0 | `today` |
| +1 / −1 | `tomorrow` / `yesterday` |
| +2 / −2 | `the day after tomorrow` / `the day before yesterday` (when the locale has them) |
| +2 to +6 | `this Wednesday` |
| −2 to −6 | `last Tuesday` |
| +7 to +13 | `next Saturday` |
| further | `March 1st`, or `January 5th, 2026` in a different year |

`Compactness.Compact` skips the ±2 and weekday tiers and goes straight to the calendar date.

## Internationalization

All 168 locales are generated from the shared `locales/*.json` files into `sayabledate/locales/locales.goose` (do not edit it by hand; run `just generate locales`). Look one up by its exact, case-sensitive code with `get_locale(code)`; `LOCALE_CODES` lists them all.

## Compactness

| Mode | `format_date` | `format_relative` (other year) |
|------|---------------|--------------------------------|
| `Compactness.Normal` | `March 15th` | `January 5th, 2026` |
| `Compactness.Short` | `Mar 15` | `Jan 5, 2026` |
| `Compactness.Compact` | `3/15` | `1/5/26` |

## API

| Function | Returns |
|----------|---------|
| `get_locale(code: u8[:])` | `DateLocale, bool` — false for an unknown code |
| `format_date(locale: const DateLocale&, compactness: Compactness, date: u8[:])` | `u8[>..], bool` — false for an empty or invalid date |
| `format_date_with_year(locale: const DateLocale&, compactness: Compactness, date: u8[:])` | `u8[>..], bool` — the same, always including the year |
| `format_relative(locale: const DateLocale&, compactness: Compactness, date: u8[:], as_of: u8[:])` | `u8[>..], bool` — false when either date is empty or invalid |
| `VERSION` | `"0.5.0"` |

## Development

```
bash build.sh       # build the tests natively with the system C compiler
bash lint.sh        # goose check with zero warnings allowed
goose tests/test_format_date.goose   # run the canonical tests (TinyCC, in-process)
```

The tests in `tests/test_format_date.goose` implement every case in `date/config/tests.json`, each annotated with its canonical ID.

## License

[MIT](../../../LICENSE.md)
