# date

**sayable-date** — Human-friendly date formatting. How people reference dates in conversation: "today", "next Thursday", "March 15th", "April 10, 2024".

## Status

v0.5.0, 15 languages, 110 locales, 52 canonical tests.

## Directory structure

```
date/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata
    tests.json             # 52 canonical test cases
  locales/
    src/                   # 110 canonical JSON locale files
    examples/              # Generated markdown docs per locale
  codegen/
    generate.py            # Main codegen orchestrator
    docgen.py              # Documentation generator
    banner.py              # DO NOT EDIT banner utility
    targets/               # 15 language emitters (no plural_rules — date doesn't need them)
      <lang>/
        emitter.py         # Generates locale source files
  impl/                    # 15 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/                # Types, formatter, tests, generated locales
  justfile                 # Component-level task runner
  docs/                    # (empty)
  tests/                   # Test documentation
```

## Languages (15)

C++, Clojure, C#, F#, Go, Haskell, Java, Kotlin, Lua, PHP, Python, Ruby, Rust, Scala, TypeScript

## Locale JSON schema

```json
{
  "code": "en",
  "name": "English",
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
}
```

- `dayFormat` with `dayFormatExceptions` handles ordinal suffixes (1st, 2nd, 3rd, 11th, 21st, etc.)
- `{month}`, `{day}`, `{year}`, `{yy}` are pattern placeholders; `{weekday}` in proximity strings
- Some locales have `monthsInDate` for genitive month forms (e.g., Russian)

## Relative date formatting tiers

| Offset | Output |
|--------|--------|
| 0 | today |
| +1 | tomorrow |
| -1 | yesterday |
| +2 | dayAfterTomorrow (if locale has it) |
| -2 | dayBeforeYesterday (if locale has it) |
| +3 to +6 | this {weekday} |
| +7 to +13 | next {weekday} |
| -3 to -6 | last {weekday} |
| Beyond | Calendar format (datePattern or datePatternWithYear if different year) |

Compact compactness skips the weekday-reference tiers — goes straight to calendar format.

## API functions

- `format_date(date)` — Format an absolute date in locale-appropriate form
- `format_relative(date, asOf)` — Pick the most natural reference relative to a given date

Both support three compactness levels: normal (default), short, compact.

## Build and test

Commands are run from the **date/** directory using the component justfile:

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

No `plural_rules.py` needed — date formatting doesn't use plural forms.

## Test structure

52 tests across 10+ sections in `config/tests.json`:
- Null/edge cases
- format_date (normal, short, compact)
- format_relative proximity tiers
- Compact skips weekday references
- Locale-specific: German, French, Japanese, Russian (genitive months)
