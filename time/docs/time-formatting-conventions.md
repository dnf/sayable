# Time Formatting Conventions

This document describes how sayable-time handles the variety of time formatting
conventions found across the world's languages. All locale data is sourced from
the Unicode CLDR (Common Locale Data Repository) and verified against language-specific
references.

## Three compactness levels

Every locale supports three output modes:

| Level | English example (2:15 PM) | Description |
|-------|---------------------------|-------------|
| **Normal** | "a quarter past two" | Spoken time using word patterns |
| **Short** | "2:15 PM" | Digital format, locale-appropriate |
| **Compact** | "2:15p" | Abbreviated digital format |

## Normal compactness: spoken time

Normal mode produces time the way people actually say it. Each locale defines:

- **12 hour words** (`hours` array): The spoken name for each hour (twelve, one, two, ... eleven)
- **12 five-minute patterns** (`patterns` object): Templates for each 5-minute bucket
- **midnight** and **noon**: Special terms for 00:00 and 12:00

Minutes round to the nearest 5-minute mark. Patterns use `{h}` for the current
hour word and `{next_h}` for the next hour word (used in "to" patterns like
"a quarter to three").

### Pattern styles by language family

**Past/to pattern** (English, Spanish, Portuguese, etc.):
```
"five past three", "a quarter to four"
```

**Half-to-next pattern** (German, Danish, Dutch):
German "halb vier" means "half four" = 3:30 (half-way to the next hour).
Danish "fem i halv fire" = "five to half four" = 3:25.

**Additive pattern** (French, Japanese, Chinese):
French "trois heures et quart" = "three hours and quarter".
Japanese "三時半" = "three-hour-half".

**Hour-first pattern** (Turkish, many Asian languages):
Turkish "saat iki buçuk" = "hour two half".

## Short and compact: digital format

### Time separator

Most locales use a colon (`:`) between hours and minutes, but several use a
period/dot (`.`) as their standard time separator. This is controlled by the
`format` field in each locale's short/compact clock configuration.

| Locale | Language | CLDR format | Our format field |
|--------|----------|-------------|------------------|
| `da` | Danish | `HH.mm` | `{h}.{mm}` |
| `fi` | Finnish | `H.mm` | `{h}.{mm}` |
| `id` | Indonesian | `HH.mm` | `{h}.{mm}` |
| `kl` | Kalaallisut | `H.mm` | `{h}.{mm}` |

Some languages have dot format as an alternate variant in CLDR but use colon in
their primary format. We follow the primary format:

| Locale | Language | Primary | Alt-variant |
|--------|----------|---------|-------------|
| `nb` | Norwegian Bokmal | `HH:mm` (colon) | `HH.mm` (dot) |
| `sv` | Swedish | `HH:mm` (colon) | `HH.mm` (dot) |

#### CLDR sources

- Danish: [cldr-json/.../da/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/da/ca-gregorian.json)
- Finnish: [cldr-json/.../fi/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/fi/ca-gregorian.json)
- Indonesian: [cldr-json/.../id/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/id/ca-gregorian.json)
- Kalaallisut: [cldr-json/.../kl/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/kl/ca-gregorian.json)
- Norwegian: [cldr-json/.../nb/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/nb/ca-gregorian.json)
- Swedish: [cldr-json/.../sv/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/sv/ca-gregorian.json)

### 12-hour vs 24-hour clock

Each locale specifies whether short/compact mode uses 12-hour or 24-hour format
via the `use24h` field. When `use24h` is false, the locale provides `amPm` labels.

**12-hour locales** (English, Spanish, Malay, etc.):
```json
{ "use24h": false, "amPm": ["AM", "PM"], "format": "{h}:{mm} {ampm}" }
```

**24-hour locales** (German, French, Finnish, Danish, etc.):
```json
{ "use24h": true, "format": "{h}:{mm}" }
```

#### Reference

The choice of 12h vs 24h follows CLDR `timeFormatShort` patterns:
- Patterns starting with `h` (lowercase) indicate 12-hour format
- Patterns starting with `H` (uppercase) indicate 24-hour format

See: [CLDR Date/Time Symbols](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table)

## Spoken phrases in every locale

Normal compactness is always words, never digits, in every locale. Where a
language has no "past/to" idiom (many pidgins, creoles and languages that
borrowed clock time), the patterns use the plain spoken "hour and minutes" form
with the minutes spelled out, e.g. Tok Pisin "tupela kilok" and "kwata pas
tupela".

Phrases nobody has checked with a native speaker carry a `review` note in the
locale file (see [adding a locale](../../docs/adding-a-locale.md#review-notes)).
They appear at the top of that locale's page in `docs/locales/`, and all of them
are listed in [`docs/locales/README.md`](../../docs/locales/README.md).

## Adding or modifying locale data

1. Edit the `time` section of `locales/{code}.json` at the repository root (one file per language, shared by all four libraries)
2. Run `just generate locales` from the repository root (it regenerates every library's locale code and `docs/locales/{code}.md`)
3. Run `just check`, `just test cli` and the native suites to verify all implementations pass

See [`docs/adding-a-locale.md`](../../docs/adding-a-locale.md) for every field of the `time` section.

When adding a new locale, verify the time format against CLDR data at:
https://github.com/unicode-org/cldr-json/tree/main/cldr-json/cldr-dates-full/main

Key CLDR fields to check:
- `timeFormats.short` — separator (`.` vs `:`) and 12h vs 24h
- `dayPeriods` — AM/PM labels for 12-hour locales
