# date

**sayable-date** — Human-friendly date formatting. How people reference dates in conversation: "today", "next Thursday", "March 15th", "April 10, 2024".

One of four peer libraries (age, date, duration, time) built the same way. See the root [`CLAUDE.md`](../CLAUDE.md) for the rules every library follows.

## Status

v0.5.0, 51 languages, 168 locales, 70 canonical tests.

## Directory structure

```
date/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 70 canonical test cases
  codegen/
    generate.py            # Codegen orchestrator: locales/*.json (date section) -> all 51 languages
    docgen.py              # `--sections`: each locale's Date section for docs/locales/<code>.md
    banner.py              # Re-exports the DO NOT EDIT banner and locale loader from tools/codegen_util.py
    targets/               # 51 language emitters (no plural_rules — date doesn't need them)
      <lang>/
        emitter.py         # Generates locale source files from JSON
  impl/                    # 51 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales/ (DO NOT EDIT)
  docs/
    date-formatting-conventions.md
  tests/                   # Test documentation
  justfile                 # Library task runner (a subset of languages; see Build and test)
```

Locale data is not in this directory: it is the `date` section of the shared `locales/<code>.json` files at the repository root. The guide to adding a locale is [`docs/adding-a-locale.md`](../docs/adding-a-locale.md).

## Languages (51)

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

## Locale data: the `date` section

Each `locales/<code>.json` holds the shared `code`, `name` and `pluralRule`, then this library's section under `"date"`. The codegen sees the shared fields plus this section (date doesn't use `pluralRule`). From `locales/en.json`:

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "age": { ... },
  "date": {
    "months": ["January", "February", ..., "December"],
    "weekdays": ["Sunday", "Monday", ..., "Saturday"],
    "dayFormat": "{n}th",
    "dayFormatExceptions": { "1": "{n}st", "2": "{n}nd", "3": "{n}rd", "21": "{n}st", ... },
    "datePattern": "{month} {day}",
    "datePatternWithYear": "{month} {day}, {year}",
    "today": "today",
    "tomorrow": "tomorrow",
    "yesterday": "yesterday",
    "dayAfterTomorrow": "the day after tomorrow",
    "dayBeforeYesterday": "the day before yesterday",
    "thisWeekday": "this {weekday}",
    "nextWeekday": "next {weekday}",
    "lastWeekday": "last {weekday}",
    "short": {
      "months": ["Jan", "Feb", ...],
      "weekdays": ["Sun", "Mon", ...],
      "dayFormat": "{n}",
      "datePattern": "{month} {day}",
      "datePatternWithYear": "{month} {day}, {year}"
    },
    "compact": {
      "datePattern": "{m}/{d}",
      "datePatternWithYear": "{m}/{d}/{yy}"
    }
  },
  "duration": { ... }, "time": { ... }
}
```

- `weekdays` start on Sunday. `dayFormat` with `dayFormatExceptions` handles ordinal suffixes (1st, 2nd, 3rd, 11th, 21st, etc.); a `short.dayFormat` without exceptions drops them.
- `{month}`, `{day}`, `{year}` and, for numeric dates, `{d}`, `{m}`, `{yy}` are pattern placeholders; `{weekday}` is used in the weekday phrases.
- Some locales have `monthsInDate` for genitive month forms (e.g. Russian, Polish); when present it is used inside dates at every compactness level.
- `dayAfterTomorrow` and `dayBeforeYesterday` are optional.

## Relative date formatting tiers

| Offset (days) | Output |
|---------------|--------|
| 0 | today |
| +1 | tomorrow |
| -1 | yesterday |
| +2 | dayAfterTomorrow (if the locale has it), else this {weekday} |
| -2 | dayBeforeYesterday (if the locale has it), else last {weekday} |
| +2 to +6 | this {weekday} |
| -2 to -6 | last {weekday} |
| +7 to +13 | next {weekday} |
| Beyond | Calendar format (datePatternWithYear if the year differs, else datePattern) |

Compact compactness skips the ±2 and weekday tiers and goes straight to calendar format.

## API functions

- `format_date(date)` — Format an absolute date in locale-appropriate form
- `format_date_with_year(date)` — The same, always with the year
- `format_relative(date, asOf)` — Pick the most natural reference relative to a given date

All are available with a locale and one of three compactness levels: normal (default), short, compact.

## Build and test

From the **project root**:

```
just test cli          # canonical tests of all four libraries through every language's CLI
just fuzz              # random requests to every CLI; all must agree
just generate locales  # regenerate locale code for all four libraries, plus docs/locales/ and locales/README.md
just check             # verify generated code, locale docs, Dockerfile and workflows are current
```

From **date/**, the library justfile runs the native suites of C++, Clojure, C#, F#, Go, Haskell, Java, Kotlin, Lua, PHP, Python, Ruby, Rust, Scala and TypeScript:

```
just test              # those languages in parallel + codegen check
just test go           # one language
just build rust        # build one compiled language
just lint python       # lint one language
just clean             # remove build artifacts
python3 -m codegen.generate [--lang <lang>] [--check]   # this library's locale code only
```

For any language, `just test <lang>` from the project root runs its date suite along with the other three libraries' (via `.hecatron/languages/<lang>/test.sh`).

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel/registry) | Bash, C, Clojure, Common Lisp, Crystal, Dart, Elixir, Elm, Erlang, Gleam, Go, Haskell, Janet, Julia, Lua, Mojo, Nim, OCaml, Octave, Perl, Pharo, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Tcl, TypeScript, V, Wren |
| Single-file (all locales in one file) | Ada (spec + body), COBOL, C#, D, F#, Fortran, Goose, Groovy, Java, Kotlin, Odin, Pascal, PHP, Scala, Swift, VB.NET, Zig |
| Range-split (locales split into alpha ranges) | C++ |

No `plural_rules.py` needed — date formatting doesn't use plural forms.

## Test structure

70 tests across 16 sections in `config/tests.json`:
- Null/edge cases and input validation
- format_date (normal, short, compact) and format_date_with_year
- format_relative proximity tiers, short phrases, compact skipping weekday references
- Locale-specific: German, French, Japanese, Russian (genitive months), Arabic, Spanish, and short month names in locales that keep the full genitive
