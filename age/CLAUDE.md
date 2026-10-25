# age

**sayable-age** — Human-friendly age formatting. Formats ages the way parents and pediatricians actually talk: "6 weeks", "14 months", "3½ years".

## Status

The most mature component: v0.5.0, 51 languages, 168 locales, 217 canonical tests. Has CLI, benchmarks, stress tests, and comprehensive docs.

## Directory structure

```
age/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata (name, description, author, license, repo)
    tests.json             # 217 canonical test cases
  locales/
    src/                   # 159 canonical JSON locale files (single source of truth)
  codegen/
    generate.py            # Main codegen orchestrator (JSON -> all 33 languages)
    docgen.py              # Documentation generator
    banner.py              # DO NOT EDIT banner utility
    targets/               # 33 language emitters (one dir per language)
      <lang>/
        emitter.py         # Generates locale source files from JSON
        plural_rules.py    # CLDR plural rules for this language
  impl/                    # 33 language implementations
    <lang>/
      README.md            # Per-language API docs
      locales/             # Generated locale files (DO NOT EDIT)
      ...                  # Types, formatter, tests (language-idiomatic layout)
  cli/                     # CLI tool
  benchmarks/              # Performance benchmarks
  docs/                    # Comprehensive documentation
    adding-a-locale.md
    versioning.md
    metadata.md
    packaging.md
    locale-reference.md
    locales.md, locales-simple-plural.md, locales-complex-plural.md, locales-no-plural.md
    code-quality.md, code-quality-compiled.md, code-quality-dynamic.md
    gender-and-stages.md
    unsupported-languages.md
  tests/                   # Test documentation
  Dockerfile               # Generated (never edit by hand)
```

## Languages (51)

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

## Locale JSON schema

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "units": {
    "day": { "one": "{n} day", "other": "{n} days" },
    "week": { "one": "{n} week", "other": "{n} weeks" },
    "month": { "one": "{n} month", "other": "{n} months" },
    "year": { "one": "{n} year", "other": "{n} years" }
  },
  "half": "½",
  "delimiter": ", ",
  "justBorn": "newborn",
  "stages": [
    { "upTo": 14, "unit": "day" },
    { "upTo": 90, "unit": "week", "secondary": "day" },
    { "upTo": 730, "unit": "month" },
    { "unit": "year", "secondary": "month" }
  ]
}
```

Plural forms vary by language: one/other (English), zero/one/two/few/many/other (Arabic), etc. 23 distinct CLDR plural patterns cover all locales.

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel) | Bash, Clojure, Dart, Elixir, Elm, Erlang, Gleam, Go, Haskell, Lua, Mojo, OCaml, Octave, Perl, Pharo, PowerShell, Python, Ruby, Rust, Swift, TypeScript |
| Single-file (all locales in one file) | C#, F#, Groovy, Java, Kotlin, PHP, Scala |
| Range-split (locales split into alpha ranges) | C, C++, Fortran |
| Custom | Ada (spec+body pairs), COBOL (copybooks), Odin (single-file), Zig (comptime) |

## Build and test

Commands are run from the **project root** using the root justfile:

```
just test              # all 33 languages in parallel
just test go           # single language
just build rust        # build one compiled language
just lint python       # lint one language
just generate locales  # regenerate all locale files
just check             # verify codegen + docgen are current
```

The root justfile delegates to `.hecatron/tools/` scripts.

## Key patterns

- **Spec-first testing**: All 217 tests defined in `config/tests.json` with explicit `(dateOfBirth, asOf)` pairs
- **Test ID annotations**: Every test in every language carries a comment with its canonical test ID
- **Zero dependencies**: No runtime dependencies in any language
- **CLDR plural rules**: 23 patterns implemented in every language's `plural_rules.py`
- **Generated file banner**: 9-line double-line box-frame DO NOT EDIT banner on all generated files
- **Stage-based formatting**: Ages progress through tiers (days -> weeks+days -> months -> years+months) based on configurable stage thresholds
