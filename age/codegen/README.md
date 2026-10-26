# Locale Code Generator

The `codegen/` directory generates sayable-age's locale definitions in every language implementation from a single canonical source. The other three libraries (date, duration, time) have the same generator in their own `codegen/` directories, with the same structure and the same source files.

## Why

168 locales across 51 languages means thousands of locale files per library. Before this generator, every locale change required editing files by hand across every language. The generator eliminates that by deriving all locale source files from one set of JSON definitions.

## Architecture

```
locales/                  # Repository root: one JSON file per language, shared by all four libraries
  en.json
  fr.json
  ar.json
  ...
age/codegen/
  generate.py             # Orchestrator: loads the age section of each locale, runs emitters, writes files
  docgen.py               # `--sections`: the Age section of each docs/locales/<code>.md page
  banner.py               # Re-exports the banner and locale loader from .hecatron/tools/codegen/util.py
  locale_groups.py        # Named groups for `--locales` subsetting
  test_locale_groups.py   # Unit tests (`just test codegen`)
  align_tables.py         # Markdown table aligner (`just maintain docs`)
  targets/                # One subdirectory per target language (51)
    ada/                  #   emitter.py + plural_rules.py
    bash/
    ...
    zig/
```

## Canonical JSON format

One file per language, `locales/<code>.json`, with the shared `code`, `name` and `pluralRule` and then a section per library. `load_component_locales("age")` in `.hecatron/tools/codegen/util.py` gives this generator the shared fields plus the `age` section, so emitters see one flat dict per locale. From `locales/fr.json`:

```json
{
  "code": "fr",
  "name": "French",
  "pluralRule": "one_other_zero_one",
  "age": {
    "units": {
      "day":   { "one": "{n} jour", "other": "{n} jours" },
      "week":  { "one": "{n} semaine", "other": "{n} semaines" },
      "month": "{n} mois",
      "year":  { "one": "{n} an", "other": "{n} ans" }
    },
    "half": "{0} et demi",
    "delimiter": ", ",
    "justBorn": "Nouveau-né",
    "stages": {
      "newborn": { "m": "Nouveau-né", "f": "Nouveau-née" },
      "infant": "Nourrisson",
      "toddler": "Tout-petit",
      "child": "Enfant",
      "teenager": { "m": "Adolescent", "f": "Adolescente" },
      "adult": "Adulte"
    },
    "short": { "units": { ... } },
    "compact": { "units": { ... }, "delimiter": "", "half": "{n}½" }
  },
  "date": { ... },
  "duration": { ... },
  "time": { ... }
}
```

### Field rules

- **`units`**: A string value means no plural forms (e.g. `"{n} mois"` for French months). An object maps plural categories to templates (`"other"` is required, rest optional).
- **`stages`**: A string means gender-neutral. An `{"m": ..., "f": ...}` object means gendered.
- **`pluralRule`**: One of the 23 named rules below. The rule's logic lives in each `targets/<lang>/plural_rules.py`, not in the JSON.
- **`short`** / **`compact`**: Compactness overrides for `units`, `half`, `delimiter` and `justBorn`; omitted keys fall back to the normal values.

[`docs/adding-a-locale.md`](../../docs/adding-a-locale.md) documents every field of every library's section.

## 23 plural rules

All CLDR cardinal plural patterns are supported. See
[`docs/adding-a-locale.md`](../../docs/adding-a-locale.md) for the full rule table.

Each rule is defined once per language in `targets/<lang>/plural_rules.py` as a code string in the target language. Duration, the other library that uses plurals, has its own copy in `duration/codegen/targets/<lang>/plural_rules.py`.

## Output per language

Paths are relative to `age/impl/<lang>/`.

| Language    | Output files                                                                  | Pattern                          |
| ----------- | ----------------------------------------------------------------------------- | -------------------------------- |
| Ada         | `src/locales/sayableage_locales.ads` + `.adb`                                 | single spec + body               |
| Bash        | `locales/{code}.sh` + `locales/registry.sh`                                   | one per locale + registry        |
| C           | `src/locales/{code}.c` + `src/locales_registry.c`, `include/sayableage/locales.h`, `include/sayableage/sayableage.h`, `src/sayableage.c` | one per locale + registry, header and formatter |
| C#          | `SayableAge/Locales/Locales.cs`                                               | single file                      |
| C++         | `src/locales/locales_{a_e,f_k,l_r,s_z}.cpp` + `locales_registry.cpp`, `include/sayableage/locales/locales.hpp` | 4 files by alpha range + registry + header |
| Clojure     | `src/sayableage/locales/{code}.clj` + `src/sayableage/locales.clj`            | one per locale + registry        |
| COBOL       | `src/locales/Locales.cbl`                                                     | single file                      |
| Common Lisp | `locales/{code}.lisp` + `locales/registry.lisp`                               | one per locale + registry        |
| Crystal     | `src/sayable_age/locales/{code}.cr` + `registry.cr`                           | one per locale + registry        |
| D           | `source/sayableage/locales.d`                                                 | single file                      |
| Dart        | `lib/src/locales/{code}.dart` + `locales.dart`                                | one per locale + barrel          |
| Elixir      | `lib/sayable_age/locales/{code}.ex` + `lib/sayable_age/locales.ex`            | one per locale + registry        |
| Elm         | `src/SayableAge/Locales/{Code}.elm` + `src/SayableAge/Locales.elm`            | one per locale + barrel          |
| Erlang      | `src/locales/sayableage_locales_{code}.erl` + `sayableage_locales.erl`        | one per locale + registry        |
| F#          | `SayableAge/Locales/Locales.fs`                                               | single file                      |
| Fortran     | `src/locales/sayableage_locales.f90`                                          | single file                      |
| Gleam       | `src/sayableage/locales/{code}.gleam` + `locales.gleam`                       | one per locale + registry        |
| Go          | `locales/locale_{code}.go` + `locale_registry.go`, `helpers.go`               | one per locale + registry        |
| Goose       | `sayableage/locales/locales.goose`                                            | single file                      |
| Groovy      | `src/main/groovy/sayableage/locales/Locales.groovy`                           | single file                      |
| Haskell     | `src/SayableAge/Locales/{Code}.hs` + `src/SayableAge/Locales.hs`              | one per locale + barrel          |
| Janet       | `locales/{code}.janet` + `locales/registry.janet`                             | one per locale + registry        |
| Java        | `src/main/java/sayableage/locales/Locales.java`                               | single file                      |
| Julia       | `src/locales/{code}.jl` + `src/locales/registry.jl`                           | one per locale + registry        |
| Kotlin      | `src/main/kotlin/sayableage/locales/Locales.kt`                               | single file                      |
| Lua         | `locales/{code}.lua` + `locales/init.lua`                                     | one per locale + barrel          |
| Mojo        | `src/sayable_age/locales/{code}.mojo` + `registry.mojo`                       | one per locale + registry        |
| Nim         | `src/sayable_age/locales/{code}.nim` + `registry.nim`                         | one per locale + registry        |
| OCaml       | `lib/locales/{code}.ml` + `lib/locales/locales.ml`                            | one per locale + barrel          |
| Octave      | `locales/locale_{code}.m` + `locales/get_age_locale.m`                        | one per locale + lookup          |
| Odin        | `locales.odin`                                                                | single file                      |
| Pascal      | `locales/SayableAgeLocales.pas`                                               | single file                      |
| Perl        | `lib/SayableAge/Locales/{CODE}.pm` + `lib/SayableAge/Locales.pm`              | one per locale + registry        |
| Pharo       | `locales/{code}.st` + `locales/registry.st`                                   | one per locale + registry        |
| PHP         | `src/Locales/Locales.php`                                                     | single file                      |
| PowerShell  | `locales/{code}.ps1` + `locales/registry.ps1`                                 | one per locale + registry        |
| Prolog      | `locales/{code}.pl` + `locales/registry.pl`                                   | one per locale + registry        |
| Python      | `src/sayable_age/locales/{code}.py` + `__init__.py`                           | one per locale + barrel          |
| R           | `locales/{code}.R` + `locales/registry.R`                                     | one per locale + registry        |
| Racket      | `locales/{code}.rkt` + `locales/registry.rkt`                                 | one per locale + registry        |
| Raku        | `lib/SayableAge/Locales/{CODE}.rakumod` + `Registry.rakumod`                  | one per locale + registry        |
| Ruby        | `lib/sayable_age/locales/{code}.rb` + `registry.rb`                           | one per locale + registry        |
| Rust        | `src/locales/{code}.rs` + `src/locales/mod.rs`                                | one per locale + barrel          |
| Scala       | `src/main/scala/sayableage/locales/Locales.scala`                             | single file                      |
| Swift       | `Sources/SayableAge/Locales/Locales.swift`                                    | single file                      |
| Tcl         | `locales/{code}.tcl` + `locales/registry.tcl`                                 | one per locale + registry        |
| TypeScript  | `src/locales/{code}.ts` + `src/locales/index.ts`                              | one per locale + barrel          |
| V           | `locales/locale_{code}.v` + `locales/registry.v`                              | one per locale + registry        |
| VB.NET      | `SayableAge/Locales/Locales.vb`                                               | single file                      |
| Wren        | `locales/{code}.wren` + `locales/registry.wren`                               | one per locale + registry        |
| Zig         | `src/locales/locales.zig`                                                     | single file                      |

Locale codes that are reserved words in a target (`is`, `or`) get a suffixed file or identifier name there (e.g. Mojo's `is_locale.mojo`).

Every generated file begins with the 9-line `DO NOT EDIT` banner from `.hecatron/tools/codegen/util.py`, and each locale file carries a `Source: locales/<code>.json` comment.

## Usage

### Generate all locale files and docs

```bash
just generate locales
```

From the repository root, this runs `codegen/generate.py` in each of the four libraries (locale source files), then `tools/generate_locale_docs.py`, which calls each library's `codegen/docgen.py --sections` and writes `docs/locales/<code>.md` and `locales/README.md`.

### Generate for one language only

For language-specific codegen, run this library's generator directly from `age/` (it writes code only, not docs):

```bash
python3 -m codegen.generate --lang typescript
python3 -m codegen.generate --lang python
python3 -m codegen.generate --lang go
# etc.
```

### Subsetting with `--locales`

By default all 168 locales are generated. This library's generator accepts `--locales` to generate only what you need (run from `age/`; the other libraries' generators don't take it):

```bash
python3 -m codegen.generate --locales core          # top 10 by internet users
python3 -m codegen.generate --locales core,ja,ko    # core group + extras
python3 -m codegen.generate --locales cjk,romance   # combine groups
python3 -m codegen.generate --locales fr            # just en + fr (en always included)
```

Tokens are comma-separated. Each token is either a named group or a locale code. Use `--list-groups` to see all groups:

```bash
python3 -m codegen.generate --list-groups
```

Works with other flags:

```bash
python3 -m codegen.generate --locales core --lang typescript
python3 -m codegen.generate --locales core --check
```

When subsetting, stale locale files from previous full generations are automatically deleted (or flagged in `--check` mode). Run a full `just generate locales` before committing.

### Check for drift (CI mode)

```bash
just check
```

Checks every library's locale codegen and the locale docs (plus the Dockerfile, compatibility table, CI workflows and geography maps). Exits with code 1 if any generated file would change. This runs in CI to ensure locale files stay in sync with the canonical JSON.

## Workflows

### Modifying an existing locale

1. Edit the locale's `age` section in `locales/{code}.json`
2. Run `just generate locales`
3. Review `docs/locales/{code}.md` and run the test suites to verify

### Adding a new locale

See [`docs/adding-a-locale.md`](../../docs/adding-a-locale.md). In short:

1. Create `locales/{code}.json` with the shared fields and all four library sections (use an existing plural rule — all 23 CLDR patterns are supported)
2. Run `just generate locales`
3. Add test cases to the libraries' `config/tests.json` and implement them in all test files
4. Run all test suites, `just test cli` and `just fuzz`

### Fixing a plural rule

1. Edit the rule in `plural_rules.py` (it has per-language code strings), in both `age/codegen/targets/<lang>/` and `duration/codegen/targets/<lang>/`
2. Run `just generate locales`
3. Run all test suites

## Why generated files are checked into source control

The generated locale files are committed to each language's directory rather than being `.gitignore`d and rebuilt on demand:

- **Each language's locale files are part of its published package.** npm, PyPI, crates.io, etc. ship what's in the repo — there's no codegen step in the downstream build.
- **Consumers can browse source on GitHub** without running the generator to see what a locale looks like.
- **Contributors can clone and test immediately** without installing Python or running the generator first.
- **CI `--check` mode prevents drift.** `just check` exits non-zero if any generated file would change, so the canonical JSON and the checked-in files can never get out of sync.

## Requirements

Python 3.10+ (stdlib only, no dependencies).
