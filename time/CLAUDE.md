# time

**sayable-time** — Human-friendly clock time formatting. Tells time the way people talk: "a quarter past three", "half past seven", "midnight".

## Status

v0.5.0, 33 languages, 159 locales, 26 canonical tests.

## Directory structure

```
time/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 26 canonical test cases
  locales/
    src/                   # 159 canonical JSON locale files
    examples/              # Generated markdown docs per locale
  codegen/
    generate.py            # Main codegen orchestrator
    docgen.py              # Documentation generator
    banner.py              # DO NOT EDIT banner utility
    targets/               # 33 language emitters (no plural_rules — time doesn't need them)
      <lang>/
        emitter.py         # Generates locale source files
  impl/                    # 33 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales
  justfile                 # Component-level task runner
```

## Languages (33)

Ada, C, C++, C#, Clojure, COBOL, Crystal, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Groovy, Haskell, Java, Kotlin, Lua, Nim, OCaml, Perl, PHP, Python, R, Ruby, Rust, Scala, Swift, TypeScript, VB.NET, Zig

## Locale JSON schema

```json
{
  "code": "en",
  "name": "English",
  "clock": {
    "hours": ["twelve", "one", "two", ..., "eleven"],
    "midnight": "midnight",
    "noon": "noon",
    "patterns": {
      "0": "{h} o'clock",
      "5": "five past {h}",
      "10": "ten past {h}",
      "15": "a quarter past {h}",
      "20": "twenty past {h}",
      "25": "twenty-five past {h}",
      "30": "half past {h}",
      "35": "twenty-five to {next_h}",
      "40": "twenty to {next_h}",
      "45": "a quarter to {next_h}",
      "50": "ten to {next_h}",
      "55": "five to {next_h}"
    }
  },
  "short": {
    "clock": { "use24h": false, "amPm": ["AM", "PM"], "format": "{h}:{mm} {ampm}" }
  },
  "compact": {
    "clock": { "use24h": false, "amPm": ["a", "p"], "format": "{h}:{mm}{ampm}" }
  }
}
```

- **Normal compactness**: Spoken time using 12 named hours + 12 five-minute-bucket patterns with `{h}` and `{next_h}` placeholders. Minutes round to nearest 5. Special handling for midnight (00:00) and noon (12:00).
- **Short compactness**: Digital format with AM/PM or 24-hour clock.
- **Compact compactness**: Abbreviated digital format.

### Time separator conventions

The `format` field in short/compact clock config controls the separator between hours and minutes. Most locales use a colon (`{h}:{mm}`), but several use a dot/period (`{h}.{mm}`) per their CLDR data:

| Locale | Language | CLDR short format | Source |
|--------|----------|-------------------|--------|
| `da` | Danish | `HH.mm` | [CLDR da/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/da/ca-gregorian.json) |
| `fi` | Finnish | `H.mm` | [CLDR fi/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/fi/ca-gregorian.json) |
| `id` | Indonesian | `HH.mm` | [CLDR id/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/id/ca-gregorian.json) |
| `kl` | Kalaallisut | `H.mm` | [CLDR kl/ca-gregorian.json](https://github.com/unicode-org/cldr-json/blob/main/cldr-json/cldr-dates-full/main/kl/ca-gregorian.json) |

Some languages (Norwegian Bokmål `nb`, Swedish `sv`) have dot format as a CLDR `short-alt-variant` but use colon in their primary format — we follow the primary format.

The formatter's `_format_digital` does string replacement on the `format` template, so `{h}.{mm}` works without any code changes. Test coverage for this is in Section 8 of `config/tests.json`.

### Numeric clock pattern fallback

Languages without established spoken clock conventions (e.g., pidgin and creole languages like Tok Pisin, Pijin, Bislama) use a numeric pattern for normal compactness: `"{h}:05"`, `"{h}:15"`, etc. This avoids inventing spoken time expressions that don't exist in the language. The hours array still uses native-language number words, and midnight/noon get native terms. Short and compact modes use the standard digital format.

## API functions

- `format_time(time)` — Format a time string (HH:MM) as human-readable spoken time

Supports three compactness levels: normal (default), short, compact.

## Build and test

Commands are run from the **time/** directory using the component justfile:

```
just test              # all 33 languages in parallel + codegen check
just test go           # single language
just build rust        # build one compiled language
just lint python       # lint one language
just generate locales  # regenerate all locale files
just check             # verify codegen + docgen are current
just clean             # remove build artifacts
```

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel/registry) | Clojure, Crystal, Dart, Elixir, Elm, Erlang, Gleam, Go, Groovy, Haskell, Lua, Nim, OCaml, Perl, Python, R, Ruby, Rust, Swift, TypeScript |
| Single-file (all locales in one file) | Ada, C, C#, COBOL, F#, Fortran, Java, Kotlin, PHP, Scala, VB.NET, Zig |
| Range-split (locales split into alpha ranges) | C++ |

No `plural_rules.py` needed — time formatting doesn't use plural forms.

## Test structure

26 tests across 8 sections in `config/tests.json`:
- Null/edge cases
- Clock time (normal, short, compact compactness)
- Locale-specific: German, French, Japanese, Finnish (dot separator)
