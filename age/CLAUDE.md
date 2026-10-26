# age

**sayable-age** — Human-friendly age formatting. Formats ages the way parents and pediatricians actually talk: "6 weeks", "14 months", "3½ years".

One of four peer libraries (age, date, duration, time) built the same way. See the root [`CLAUDE.md`](../CLAUDE.md) for the rules every library follows.

## Status

v0.5.0, 51 languages, 168 locales, 234 canonical tests. Also has benchmarks and a stress test.

## Directory structure

```
age/
  config/
    version.json           # Single source of truth for version (0.5.0)
    metadata.json          # Package metadata (name, description, author, license, repo)
    tests.json             # 234 canonical test cases
  codegen/
    generate.py            # Codegen orchestrator: locales/*.json (age section) -> all 51 languages
    docgen.py              # `--sections`: each locale's Age section for docs/locales/<code>.md
    banner.py              # Re-exports the DO NOT EDIT banner and locale loader from .hecatron/tools/codegen/util.py
    locale_groups.py       # Named locale groups for `--locales` subsetting
    align_tables.py        # Markdown table aligner (`just maintain docs`)
    README.md              # How the generator works
    targets/               # 51 language emitters (one dir per language)
      <lang>/
        emitter.py         # Generates locale source files from JSON
        plural_rules.py    # The 23 CLDR plural rules in this language
  impl/                    # 51 language implementations
    .gitignore             # Language-specific build artifacts
    <lang>/
      README.md            # Per-language API docs
      locales/             # Generated locale files (DO NOT EDIT)
      ...                  # Types, formatter, tests (language-idiomatic layout)
  benchmarks/              # Performance benchmarks
  docs/                    # Library docs
    versioning.md, metadata.md, packaging.md
    locales.md, locale-reference.md, locales-simple-plural.md, locales-complex-plural.md, locales-no-plural.md
    code-quality.md, code-quality-compiled.md, code-quality-dynamic.md
    gender-and-stages.md
    unsupported-languages.md
  tests/                   # Test documentation
  stress-test.sh
  Dockerfile               # Generated (never edit by hand); toolchains for every language
```

Locale data is not in this directory: it is the `age` section of the shared `locales/<code>.json` files at the repository root. The guide to adding a locale is [`docs/adding-a-locale.md`](../docs/adding-a-locale.md).

## Languages (51)

Ada, Bash, C, C#, C++, Clojure, COBOL, Common Lisp, Crystal, D, Dart, Elixir, Elm, Erlang, F#, Fortran, Gleam, Go, Goose, Groovy, Haskell, Janet, Java, Julia, Kotlin, Lua, Mojo, Nim, OCaml, Octave, Odin, Pascal, Perl, Pharo, PHP, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Scala, Swift, Tcl, TypeScript, V, VB.NET, Wren, Zig

## Locale data: the `age` section

Each `locales/<code>.json` holds the shared `code`, `name` and `pluralRule`, then this library's section under `"age"`. The codegen sees the shared fields plus this section. From `locales/en.json`:

```json
{
  "code": "en",
  "name": "English",
  "pluralRule": "one_other",
  "age": {
    "units": {
      "day": { "one": "{n} day", "other": "{n} days" },
      "week": { "one": "{n} week", "other": "{n} weeks" },
      "month": { "one": "{n} month", "other": "{n} months" },
      "year": { "one": "{n} year", "other": "{n} years" }
    },
    "half": "{n}½",
    "delimiter": ", ",
    "justBorn": "Newborn",
    "stages": {
      "newborn": "Newborn",
      "infant": "Infant",
      "toddler": "Toddler",
      "child": "Child",
      "teenager": "Teenager",
      "adult": "Adult"
    },
    "short": { "units": { "day": "{n} d", "week": "{n} wk", "month": "{n} mo", "year": "{n} yr" } },
    "compact": { "units": { "day": "{n}d", "week": "{n}w", "month": "{n}m", "year": "{n}y" }, "delimiter": "" }
  },
  "date": { ... }, "duration": { ... }, "time": { ... }
}
```

- A unit is a string (no plural forms) or a map of plural categories; `other` is always required.
- `half` uses `{n}` (modifies the number: "3½ years") or `{0}` (wraps the expression: "3 ans et demi").
- A stage label is a string or `{"m": ..., "f": ...}` for gendered locales.
- `short` / `compact` override `units`, `half`, `delimiter` and `justBorn`.

Plural forms vary by language: one/other (English), zero/one/two/few/many/other (Arabic), etc. 23 distinct CLDR plural patterns cover all locales.

## Formatting tiers

| Age | Output |
|-----|--------|
| 0 days | justBorn |
| 1–6 days | days |
| 7 days to <3 calendar months | weeks + days |
| 3–23 months | months |
| 24–35 months | years + months |
| 3–6 years | years, with the half marker from 6 months past the birthday |
| 7+ years | years |

Stages use fixed boundaries: newborn <2 months, infant 2–11, toddler 12–35, child 36–155 (3–12 years), teenager 156–215 (13–17 years), adult 216+.

## API functions

- `format_age(dateOfBirth, asOf)` — Human-friendly age
- `format_stage(dateOfBirth, asOf, gender)` — Developmental stage label (`gender` `m` or `f` for gendered locales)

Both are available with a locale and one of three compactness levels: normal (default), short, compact.

## Build and test

From the **project root**:

```
just test              # every language's age suite in parallel, plus the codegen check
just test go           # one language's age suite
just build rust        # build one compiled language
just lint python       # lint one language
just test codegen      # codegen unit tests (locale groups)
just test cli          # canonical tests of all four libraries through every language's CLI
just fuzz              # random requests to every CLI; all must agree
just generate locales  # regenerate locale code for all four libraries, plus docs/locales/ and locales/README.md
just check             # verify generated code, locale docs, Dockerfile and workflows are current
```

To regenerate only this library's code, or one language: `cd age && python3 -m codegen.generate [--lang <lang>] [--check]`.

## Codegen emitter strategies

| Strategy | Languages |
|----------|-----------|
| Per-file (one locale per file + barrel/registry) | Bash, C, Clojure, Common Lisp, Crystal, Dart, Elixir, Elm, Erlang, Gleam, Go, Haskell, Janet, Julia, Lua, Mojo, Nim, OCaml, Octave, Perl, Pharo, PowerShell, Prolog, Python, R, Racket, Raku, Ruby, Rust, Tcl, TypeScript, V, Wren |
| Single-file (all locales in one file) | Ada (spec + body), COBOL, C#, D, F#, Fortran, Goose, Groovy, Java, Kotlin, Odin, Pascal, PHP, Scala, Swift, VB.NET, Zig |
| Range-split (locales split into alpha ranges) | C++ |

## Key patterns

- **Spec-first testing**: All 234 tests defined in `config/tests.json` with explicit `(dateOfBirth, asOf)` pairs
- **Test ID annotations**: Every test in every language carries a comment with its canonical test ID
- **Zero dependencies**: No runtime dependencies in any language
- **CLDR plural rules**: 23 patterns implemented in every language's `plural_rules.py`
- **Generated file banner**: 9-line double-line box-frame DO NOT EDIT banner on all generated files, plus `Source: locales/<code>.json` on locale files
- **Tiered formatting**: Ages progress through fixed tiers (days -> weeks+days -> months -> years+months -> half years -> years)
