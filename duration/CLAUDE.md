# duration

**sayable-duration** — Human-friendly duration and relative time formatting. Formats durations the way people speak: "just now", "3 minutes, 42 seconds", "2½ hours", "1 year, 3 months ago".

One of four peer libraries (age, date, duration, time) built the same way. See the root [`CLAUDE.md`](../CLAUDE.md) for the rules every library follows.

## Status

v0.5.0, 51 languages, 168 locales, 64 canonical tests.

## Directory structure

```
duration/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 64 canonical test cases
  codegen/
    generate.py            # Codegen orchestrator: locales/*.json (duration section) -> all 51 languages
    docgen.py              # `--sections`: each locale's Duration section for docs/locales/<code>.md
    banner.py              # Re-exports the DO NOT EDIT banner and locale loader from tools/codegen_util.py
    targets/               # 51 language emitters
      <lang>/
        emitter.py         # Generates locale source files from JSON
        plural_rules.py    # The 23 CLDR plural rules in this language (duration uses plurals)
  impl/                    # 51 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales/ (DO NOT EDIT)
  docs/
    duration-formatting-conventions.md
  justfile                 # Library task runner (a subset of languages; see Build and test)
```

Locale data is not in this directory: it is the `duration` section of the shared `locales/<code>.json` files at the repository root. The guide to adding a locale is [`docs/adding-a-locale.md`](../docs/adding-a-locale.md).

## Languages (51)

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

## Locale data: the `duration` section

Each `locales/<code>.json` holds the shared `code`, `name` and `pluralRule`, then this library's section under `"duration"`. The codegen sees the shared fields plus this section. From `locales/en.json`:

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "age": { ... }, "date": { ... },
  "duration": {
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
  },
  "time": { ... }
}
```

Seven time units with CLDR plural forms (`other` is always required). `{n}` is the count placeholder in units; `{0}` wraps the formatted duration in `ago`/`inFuture` templates. `short` / `compact` override `units`, `half`, `delimiter`, `ago` and `inFuture`; `justNow` is the same at every level. Some locales also carry a `clock` object in this section; no duration code reads it.

## Duration formatting tiers

| Seconds | Output |
|---------|--------|
| 0 | justNow |
| 1–59 | seconds |
| 60–299 | minutes + seconds |
| 300–3599 | minutes |
| 3600–21599 | hours + minutes (exactly 30 min = half) |
| 21600–86399 | hours |
| 86400–259199 | days + hours (exactly 12 h = half) |
| 259200–604799 | days |
| 604800 to <30 days | weeks + days |
| 30+ days | months (30.44-day average), then years + months; more than 500 years has no value |

Half-marker: When half is present, plural category is forced to "other" (e.g., "1½ hours" not "1½ hour").

## API functions

- `format_duration(seconds)` or `format_duration(start, end)` — Format a duration in seconds, or between two ISO timestamps
- `format_since(start, asOf)` — Elapsed time between two ISO timestamps ("3 days ago")
- `format_until(target, asOf)` — Remaining time between two ISO timestamps ("in 2 hours")

All are available with a locale and one of three compactness levels: normal (default), short, compact.

## Build and test

From the **project root**:

```
just test cli          # canonical tests of all four libraries through every language's CLI
just fuzz              # random requests to every CLI; all must agree
just generate locales  # regenerate locale code for all four libraries, plus docs/locales/ and locales/README.md
just check             # verify generated code, locale docs, Dockerfile and workflows are current
```

From **duration/**, the library justfile runs the native suites of C++, Clojure, C#, F#, Go, Haskell, Java, Kotlin, Lua, PHP, Python, Ruby, Rust, Scala and TypeScript:

```
just test              # those languages in parallel + codegen check
just test go           # one language
just build rust        # build one compiled language
just lint python       # lint one language
just clean             # remove build artifacts
python3 -m codegen.generate [--lang <lang>] [--check]   # this library's locale code only
```

For any language, `just test <lang>` from the project root runs its duration suite along with the other three libraries' (via `.hecatron/languages/<lang>/test.sh`).

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel/registry) | Bash, C, Clojure, Common Lisp, Crystal, Dart, Elixir, Elm, Erlang, Gleam, Go, Haskell, Janet, Julia, Lua, Mojo, Nim, OCaml, Octave, Perl, Pharo, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Tcl, TypeScript, V, Wren |
| Single-file (all locales in one file) | Ada (spec + body), COBOL, C#, D, F#, Fortran, Goose, Java, Kotlin, Odin, Pascal, PHP, Scala, Swift, VB.NET, Zig |
| Range-split (locales split into alpha ranges) | C++, Groovy |

## Test structure

64 tests across 20 sections in `config/tests.json`:
- Null/edge cases, each duration tier, ISO timestamp parsing and validation, format_since, format_until
- Locale-specific (German, French, Japanese), short and compact compactness
- The 500-year range ceiling
