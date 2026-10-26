# sayable-age — Goose

Human-friendly age formatting — how parents actually talk about little ones.

```goose
import sayableage from "../sayableage";
import std;

fn main() {
    let en, found = sayableage::get_locale("en");
    let age, ok = sayableage::format_age(en, sayableage::Compactness.Normal, "2025-06-01", "2025-06-15");
    print(age);    // 2 weeks

    let stage, ok_stage = sayableage::format_stage(en, "2025-01-15", "2025-06-15", "");
    print(stage);  // Infant
}
```

[Goose](https://aardappel.github.io/goose/) is a memory-safe systems language with no heap: every value lives on compiler-managed stacks, and programs compile to C. This implementation needs nothing beyond the Goose standard library.

## Installation

Install Goose v2026.3 or later (`just install goose` downloads the release), then import the package directory:

```goose
import sayableage from "path/to/age/impl/goose/sayableage";
```

## Usage

Every function takes explicit dates (`YYYY-MM-DD`) and reports "no value" with a trailing `bool` instead of a null:

```goose
let fr, found = sayableage::get_locale("fr");
let age, ok = sayableage::format_age(fr, sayableage::Compactness.Normal, "2021-12-01", "2025-06-15");
// age = "3 ans et demi", ok = true

let bad, ok_bad = sayableage::format_age(fr, sayableage::Compactness.Normal, "not-a-date", "2025-06-15");
// ok_bad = false
```

## Internationalization

All 168 locales are generated from the shared `locales/*.json` files into `sayableage/locales/locales.goose` (do not edit it by hand; run `just generate locales`). Look one up by its exact, case-sensitive code with `get_locale(code)`; `LOCALE_CODES` lists them all.

Each locale carries its CLDR plural rule as a `PluralRule` enum: Goose cannot store function values, so `plural_category(rule, n)` dispatches on it.

## Compactness

| Mode | English example |
|------|-----------------|
| `Compactness.Normal` | `3½ years` |
| `Compactness.Short` | `3½ yr` |
| `Compactness.Compact` | `3½y` |

## API

| Function | Returns |
|----------|---------|
| `get_locale(code: u8[:])` | `Locale, bool` — false for an unknown code |
| `format_age(locale: const Locale&, compactness: Compactness, dob: u8[:], as_of: u8[:])` | `u8[>..], bool` — false for invalid dates, `as_of` before `dob`, or ages over 500 years |
| `format_stage(locale: const Locale&, dob: u8[:], as_of: u8[:], gender: u8[:])` | `const u8[:], bool` — the feminine label when `gender` starts with `f` and the locale has one; pass `""` for no gender |
| `VERSION` | `"0.5.0"` |

## Development

```
just test goose     # run the canonical tests (TinyCC, in-process)
just build goose    # build the tests natively with the system C compiler
just lint goose     # goose check with zero warnings allowed
```

The tests in `tests/test_format_age.goose` implement every case in `age/config/tests.json` except the default-asOf ones (15.1, 15.2, 23.1–23.3), each annotated with its canonical ID.

## License

[MIT](../../../LICENSE.md)
