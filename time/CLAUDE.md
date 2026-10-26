# time

**sayable-time** — Human-friendly clock time formatting. Tells time the way people talk: "a quarter past three", "half past seven", "midnight".

One of four peer libraries (age, date, duration, time) built the same way. See the root [`CLAUDE.md`](../CLAUDE.md) for the rules every library follows.

## Status

v0.5.0, 51 languages, 168 locales, 37 canonical tests.

## Directory structure

```
time/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 37 canonical test cases
  codegen/
    generate.py            # Codegen orchestrator: locales/*.json (time section) -> all 51 languages
    docgen.py              # `--sections`: each locale's Time section for docs/locales/<code>.md
    banner.py              # Re-exports the DO NOT EDIT banner and locale loader from .hecatron/tools/codegen/util.py
    targets/               # 51 language emitters (no plural_rules — time doesn't need them)
      <lang>/
        emitter.py         # Generates locale source files from JSON
  impl/                    # 51 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales/ (DO NOT EDIT)
  docs/
    time-formatting-conventions.md
  justfile                 # Library task runner (a subset of languages; see Build and test)
```

Locale data is not in this directory: it is the `time` section of the shared `locales/<code>.json` files at the repository root. The guide to adding a locale is [`docs/adding-a-locale.md`](../docs/adding-a-locale.md).

## Languages (51)

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

## Locale data: the `time` section

Each `locales/<code>.json` holds the shared `code`, `name` and `pluralRule`, then this library's section under `"time"`. The codegen sees the shared fields plus this section (time doesn't use `pluralRule`). From `locales/en.json`:

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "age": { ... }, "date": { ... }, "duration": { ... },
  "time": {
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
}
```

- **Normal compactness**: Spoken time using 12 named hours (index 0 is twelve) + 12 five-minute-bucket patterns with `{h}` (this hour) and `{next_h}` (the next hour) placeholders. Minutes round to nearest 5. Special handling for midnight (00:00) and noon (12:00) after rounding.
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

From the **project root**:

```
just test cli          # canonical tests of all four libraries through every language's CLI
just fuzz              # random requests to every CLI; all must agree
just generate locales  # regenerate locale code for all four libraries, plus docs/locales/ and locales/README.md
just check             # verify generated code, locale docs, Dockerfile and workflows are current
```

From **time/**, the library justfile runs the native suites of C++, Clojure, C#, F#, Go, Haskell, Java, Kotlin, Lua, PHP, Python, Ruby, Rust, Scala and TypeScript:

```
just test              # those languages in parallel + codegen check
just test go           # one language
just build rust        # build one compiled language
just lint python       # lint one language
just clean             # remove build artifacts
python3 -m codegen.generate [--lang <lang>] [--check]   # this library's locale code only
```

For any other language, run the time step of its CI workflow (`.hecatron/languages/<lang>/workflow.yml`), which tests every library.

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel/registry) | Bash, C, Clojure, Common Lisp, Crystal, Dart, Elixir, Elm, Erlang, Gleam, Go, Haskell, Janet, Julia, Lua, Mojo, Nim, OCaml, Octave, Perl, Pharo, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Tcl, TypeScript, V, Wren |
| Single-file (all locales in one file) | Ada (spec + body), COBOL, C#, D, F#, Fortran, Goose, Groovy, Java, Kotlin, Odin, Pascal, PHP, Scala, Swift, VB.NET, Zig |
| Range-split (locales split into alpha ranges) | C++ |

No `plural_rules.py` needed — time formatting doesn't use plural forms.

## Test structure

37 tests across 10 sections in `config/tests.json`:
- Null/edge cases and input validation
- Clock time (normal, short, compact compactness), minutes in short and compact modes
- Locale-specific: German, French, Japanese, Finnish (dot separator)
