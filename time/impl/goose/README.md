# sayable-time — Goose

Human-friendly clock time formatting — tells time the way people talk.

```goose
import sayabletime from "../sayabletime";
import std;

fn main() {
    let en, found = sayabletime::get_locale("en");
    let spoken, ok = sayabletime::format_time(en, sayabletime::Compactness.Normal, "14:15");
    print(spoken);  // a quarter past two

    let digital, ok_digital = sayabletime::format_time(en, sayabletime::Compactness.Short, "14:15");
    print(digital); // 2:15 PM
}
```

[Goose](https://aardappel.github.io/goose/) is a memory-safe systems language with no heap: every value lives on compiler-managed stacks, and programs compile to C. This implementation needs nothing beyond the Goose standard library.

## Installation

Install Goose v2026.3 or later (`just install goose` downloads the release), then import the package directory:

```goose
import sayabletime from "path/to/time/impl/goose/sayabletime";
```

## Usage

Input is `HH:MM`, optionally with seconds (`14:15:30`, `14:15:30.250`), or an ISO datetime (`2025-01-15T14:15:00Z`, `...+02:00`). "No value" is reported with a trailing `bool` instead of a null:

```goose
let en, found = sayabletime::get_locale("en");
let normal = sayabletime::Compactness.Normal;

let a, ok_a = sayabletime::format_time(en, normal, "00:00");                // midnight
let b, ok_b = sayabletime::format_time(en, normal, "23:58");                // midnight (rounds to the next day)
let c, ok_c = sayabletime::format_time(en, normal, "07:22");                // twenty past seven
let d, ok_d = sayabletime::format_time(en, normal, "2025-01-15T14:15:00");  // a quarter past two
let e, ok_e = sayabletime::format_time(en, normal, "25:00");                // ok_e = false
```

Spoken times round to the nearest five minutes. Short and compact modes print the exact minute.

## Internationalization

All 168 locales are generated from `time/locales/src/*.json` into `sayabletime/locales/locales.goose` (do not edit it by hand; run `just generate locales`). Look one up by its exact, case-sensitive code with `get_locale(code)`; `LOCALE_CODES` lists them all.

```goose
let ja, found_ja = sayabletime::get_locale("ja");
let t, ok = sayabletime::format_time(ja, sayabletime::Compactness.Normal, "15:30");  // 三時半

let fi, found_fi = sayabletime::get_locale("fi");
let u, ok_u = sayabletime::format_time(fi, sayabletime::Compactness.Short, "14:15"); // 14.15
```

## Compactness

| Mode | English example (`14:15`) |
|------|---------------------------|
| `Compactness.Normal` | `a quarter past two` |
| `Compactness.Short` | `2:15 PM` |
| `Compactness.Compact` | `2:15p` |

A locale without a digital clock for a mode falls back to the spoken clock.

## API

| Function | Returns |
|----------|---------|
| `get_locale(code: u8[:])` | `TimeLocale, bool` — false for an unknown code |
| `format_time(locale: const TimeLocale&, compactness: Compactness, input: u8[:])` | `u8[>..], bool` — false for empty or invalid input, or an hour over 23 / minute over 59 |
| `LOCALE_CODES` | every locale code, sorted |
| `VERSION` | `"0.5.0"` |

## Development

From `time/impl/goose`:

```
goose tests/test_format_time.goose   # run the canonical tests (TinyCC, in-process)
bash build.sh                        # build the tests natively with the system C compiler
bash lint.sh                         # goose check with zero warnings allowed
```

The tests in `tests/test_format_time.goose` implement every case in `time/config/tests.json`, each annotated with its canonical ID.

## License

[MIT](../../../LICENSE.md)
