# sayable-duration — Goose

Human-friendly duration and relative time formatting: "just now", "1 minute, 30 seconds", "1½ hours", "3 hours ago", "in 20 minutes".

```goose
import sayableduration from "../sayableduration";
import std;

fn main() {
    let en, found = sayableduration::get_locale("en");
    let d, ok = sayableduration::format_duration(en, sayableduration::Compactness.Normal, 5400);
    print(d);    // 1½ hours

    let s, ok_s = sayableduration::format_since(en, sayableduration::Compactness.Normal, "2025-01-15T10:00:00", "2025-01-15T10:45:00");
    print(s);    // 45 minutes ago
}
```

[Goose](https://aardappel.github.io/goose/) is a memory-safe systems language with no heap: every value lives on compiler-managed stacks, and programs compile to C. This implementation needs nothing beyond the Goose standard library.

## Installation

Install Goose v2026.3 or later (`just install goose` downloads the release), then import the package directory:

```goose
import sayableduration from "path/to/duration/impl/goose/sayableduration";
```

## Usage

Timestamps are ISO 8601 (`YYYY-MM-DDTHH:MM[:SS[.fff]]` naming a real calendar day; a `Z` or `±hh:mm` suffix is accepted but not applied), as defined in [`docs/input-formats.md`](../../../docs/input-formats.md). Durations longer than 500 years (6000 months) have no value. Every function reports "no value" with a trailing `bool` instead of a null:

```goose
let en, found = sayableduration::get_locale("en");
let normal = sayableduration::Compactness.Normal;

let a, ok_a = sayableduration::format_duration_iso(en, normal, "2025-01-15T10:00:00", "2025-01-15T11:30:00");
// a = "1½ hours"
let b, ok_b = sayableduration::format_until(en, normal, "2025-01-15T13:00:00", "2025-01-15T10:00:00");
// b = "in 3 hours"
let c, ok_c = sayableduration::format_since(en, normal, "2025-01-15T10:00:00", "2025-01-15T09:00:00");
// ok_c = false: as_of is before start
```

## Internationalization

All 168 locales are generated from the shared `locales/*.json` files into `sayableduration/locales/locales.goose` (do not edit it by hand; run `just generate locales`). Look one up by its exact, case-sensitive code with `get_locale(code)`; `LOCALE_CODES` lists them all.

```goose
let ja, found = sayableduration::get_locale("ja");
let d, ok = sayableduration::format_since(ja, sayableduration::Compactness.Normal, "2025-01-15T10:00:00", "2025-01-15T11:00:00");
// d = "1時間前"
```

Each locale carries its CLDR plural rule as a `PluralRule` enum: Goose cannot store function values, so `plural_category(rule, n)` dispatches on it.

## Compactness

| Mode | English example (90 seconds) |
|------|------------------------------|
| `Compactness.Normal` | `1 minute, 30 seconds` |
| `Compactness.Short` | `1m, 30s` |
| `Compactness.Compact` | `1m30s` |

## API

| Function | Returns |
|----------|---------|
| `get_locale(code: u8[:])` | `Locale, bool` — false for an unknown code |
| `format_duration(locale: const Locale&, compactness: Compactness, seconds: i64)` | `u8[>..], bool` — false for a negative count or one over 500 years |
| `format_duration_iso(locale: const Locale&, compactness: Compactness, start: u8[:], end: u8[:])` | `u8[>..], bool` — the duration between two timestamps in either order; false for an empty or malformed one |
| `format_since(locale: const Locale&, compactness: Compactness, start: u8[:], as_of: u8[:])` | `u8[>..], bool` — "… ago"; false when `as_of` is before `start` |
| `format_until(locale: const Locale&, compactness: Compactness, target: u8[:], as_of: u8[:])` | `u8[>..], bool` — "in …"; false when `target` is before `as_of` |
| `VERSION` | `"0.5.0"` |

## Development

```
bash build.sh                                # build the tests natively → build/test_format_duration
goose tests/test_format_duration.goose       # run the canonical tests (TinyCC, in-process)
bash lint.sh                                 # goose check with zero warnings allowed
```

The tests in `tests/test_format_duration.goose` implement every case in `duration/config/tests.json`, each annotated with its canonical ID.

## License

[MIT](../../../LICENSE.md)
