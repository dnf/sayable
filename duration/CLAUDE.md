# duration

**sayable-duration** — Human-friendly duration and relative time formatting. Formats durations the way people speak: "just now", "3 minutes, 42 seconds", "2½ hours", "1 year, 3 months ago".

## Status

v0.5.0, 33 languages, 159 locales, 55 canonical tests.

## Directory structure

```
duration/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 55 canonical test cases
  locales/
    src/                   # 159 canonical JSON locale files
  codegen/
    generate.py            # Main codegen orchestrator
    docgen.py              # Documentation generator
    banner.py              # DO NOT EDIT banner utility
    targets/               # 33 language emitters
      <lang>/
        emitter.py         # Generates locale source files
        plural_rules.py    # CLDR plural rules (duration uses plurals)
  impl/                    # 33 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales
  justfile                 # Component-level task runner
  docs/                    # (empty)
  tests/                   # Test documentation
```

## Languages (33)

Ada, C, C++, C#, Clojure, COBOL, Crystal, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Groovy, Haskell, Java, Kotlin, Lua, Nim, OCaml, Perl, PHP, Python, R, Ruby, Rust, Scala, Swift, TypeScript, VB.NET, Zig

## Locale JSON schema

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "units": {
    "second": { "one": "{n} second", "other": "{n} seconds" },
    "minute": { "one": "{n} minute", "other": "{n} minutes" },
    "hour":   { "one": "{n} hour",   "other": "{n} hours" },
    "day":    { "one": "{n} day",    "other": "{n} days" },
    "week":   { "one": "{n} week",   "other": "{n} weeks" },
    "month":  { "one": "{n} month",  "other": "{n} months" },
    "year":   { "one": "{n} year",   "other": "{n} years" }
  },
  "half": "{n}½",
  "delimiter": ", ",
  "justNow": "just now",
  "ago": "{0} ago",
  "inFuture": "in {0}",
  "short": { "units": {...}, "ago": "...", "inFuture": "..." },
  "compact": { "units": {...}, "delimiter": "", "ago": "...", "inFuture": "..." }
}
```

Seven time units with CLDR plural forms. `{n}` is the count placeholder in units; `{0}` wraps the formatted duration in ago/inFuture templates.

## Duration formatting tiers

| Seconds | Output |
|---------|--------|
| 0 | justNow |
| 1-59 | seconds |
| 60-299 | minutes + seconds |
| 300-3599 | minutes |
| 3600-21599 | hours + minutes (30min = half) |
| 21600-86399 | hours |
| 86400-172799 | days + hours (12h = half) |
| 172800-604799 | days |
| 604800-2629743 | weeks + days |
| 2629744+ | months (30.44d avg), then years + months |

Half-marker: When half is present, plural category is forced to "other" (e.g., "1½ hours" not "1½ hour").

## API functions

- `format_duration(seconds)` — Format a duration in seconds as human-readable text
- `format_since(start, asOf)` — Format elapsed time between two ISO timestamps
- `format_until(target, asOf)` — Format remaining time between two ISO timestamps

All three support three compactness levels: normal (default), short, compact.

## Build and test

Commands are run from the **duration/** directory using the component justfile:

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
| Per-file (one locale per file + barrel/registry) | Clojure, Go, Haskell, Lua, Python, Ruby, Rust, TypeScript |
| Single-file (all locales in one file) | C#, F#, Java, Kotlin, PHP, Scala |
| Range-split (locales split into alpha ranges) | C++ |

## Test structure

55 tests across 17 sections in `config/tests.json`:
- Null/edge cases, each duration tier, ISO timestamp parsing, format_since, format_until, locale-specific (German, French, Japanese), short compactness, compact compactness
