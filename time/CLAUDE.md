# time

**sayable-time** — Human-friendly clock time formatting. Tells time the way people talk: "a quarter past three", "half past seven", "midnight".

## Status

v0.5.0, 15 languages, 110 locales, 27 canonical tests.

## Directory structure

```
time/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 27 canonical test cases
  locales/
    src/                   # 110 canonical JSON locale files
    examples/              # Generated markdown docs per locale
  codegen/
    generate.py            # Main codegen orchestrator
    docgen.py              # Documentation generator
    banner.py              # DO NOT EDIT banner utility
    targets/               # 15 language emitters (no plural_rules — time doesn't need them)
      <lang>/
        emitter.py         # Generates locale source files
  impl/                    # 15 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales
  justfile                 # Component-level task runner
```

## Languages (15)

C++, Clojure, C#, F#, Go, Haskell, Java, Kotlin, Lua, PHP, Python, Ruby, Rust, Scala, TypeScript

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

## API functions

- `format_time(time)` — Format a time string (HH:MM) as human-readable spoken time

Supports three compactness levels: normal (default), short, compact.

## Build and test

Commands are run from the **time/** directory using the component justfile:

```
just test              # all 15 languages in parallel + codegen check
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
| Per-file (one locale per file + barrel/registry) | Clojure, Go, Haskell, Lua, Python, Ruby, Rust, TypeScript |
| Single-file (all locales in one file) | C#, F#, Java, Kotlin, PHP, Scala |
| Range-split (locales split into alpha ranges) | C++ |

No `plural_rules.py` needed — time formatting doesn't use plural forms.

## Test structure

27 tests across 7 sections in `config/tests.json`:
- Null/edge cases
- Clock time (normal, short, compact compactness)
- Locale-specific: German, French, Japanese
