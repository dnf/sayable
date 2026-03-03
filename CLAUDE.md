# CLAUDE.md

## What this project is

parent-time is a zero-dependency library that formats ages the way parents talk ("6 weeks", "14 months", "3½ years"). It has 22 identical implementations (C, C#, C++, Clojure, Dart, Elixir, Elm, Erlang, Go, Haskell, Java, Kotlin, OCaml, Perl, PHP, Python, Ruby, Rust, Scala, Swift, TypeScript, Zig) and 71 locales.

## Build and test commands

The `justfile` is the primary task runner. Running `just test`, `just build`, or `just lint` with no arguments runs all languages **in parallel**, capturing output to log files and printing a summary:

```
just test          # all test suites + codegen check, in parallel
just build         # all compiled languages, in parallel
just lint          # all linters, in parallel
```

Single-language commands stream to terminal and save to a log file:

```
just test go       # run one suite   → .logs/test/go.log
just build rust    # build one       → .logs/build/rust.log
just lint python   # lint one        → .logs/lint/python.log
```

All output is captured to `.logs/<command>/<language>.log` — both parallel and single-language runs.

| Shortcut         | Command                             |
| ---------------- | ----------------------------------- |
| Onboarding       | `just get-started`                  |
| Install langs    | `just install` or `just install go` |
| Uninstall langs  | `just uninstall go rust`            |
| Generate locales | `just generate locales`             |
| Quality check    | `just check`                        |
| Codegen tests    | `just test codegen`                 |
| Maintain docs    | `just maintain docs`                |
| Clean artifacts  | `just clean` or `just clean <lang>` |

## Key rules

- **All implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in `tests/testing.md` first, then get implemented in all languages. Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Canonical test IDs.** Every test must be annotated with the ID(s) from `tests/testing.md` that it implements — as a comment above the test or inline. This enables cross-language verification that all tests map to their canonical definition.
- **Zero runtime dependencies.** No exceptions in any language.
- **Locale data lives in `locales/*.json`.** These JSON files are the single source of truth. To change a locale, edit the JSON file and run `just generate locales` to regenerate all language implementations. Never edit generated locale files by hand.
- **Generated locale files must be in their own subdirectory.** Every language implementation must place generated locale files in a dedicated `locales/` (or language-idiomatic equivalent) subdirectory, separate from hand-written source files.
- **Generated locale files and docs must be current.** Run `just generate locales` after editing `locales/*.json`. `just check` verifies this in CI.
- **Markdown tables must be aligned.** Run `just maintain docs` after editing any documentation tables. `just check` verifies alignment in CI.
- **Generated files carry a prominent banner.** Every generated file starts with a 9-line box-frame `DO NOT EDIT` banner (from `codegen/banner.py`) referencing the generator path. Locale files also include a `Source: locales/{code}.json` comment linking to the canonical JSON.
- **Every language must have a `src/<lang>/README.md`** with API docs and a `## License` section linking to `LICENSE.md`. The root `README.md` table must link to it in the Docs column.
- **Every language must have a CI workflow** at `.github/workflows/<lang>.yml` that runs tests on push and PR to `main`. Use a version matrix when the language supports it.
- **Installer scripts** live in `scripts/installers/<lang>.sh`. See [`docs/installers.md`](docs/installers.md) for the full reference. Key points:
  - Shared toolchains (cmake→C/C++, JDK→Java/Kotlin/Scala, Node→TypeScript/Elm) mean uninstalling one language can break another.
  - JDK uninstall is a no-op (shared by 3 languages). Perl and Swift on macOS are also no-ops (system-provided).
  - `just install` (all) continues past individual failures and reports them at the end.
  - Elm has no arm64 Linux binary; the installer detects this and skips with a message.
- **Justfile recipes must support `help`/`--help`.** Every recipe that accepts language arguments (test, build, lint, clean, install, uninstall) must handle `help` and `--help` as a first argument, printing usage with a consistent structure: Usage line, description, language list (alphabetical, with abbreviations), flags (if applicable), and examples. Error messages for unknown languages should print to stderr and point to help (e.g. `"try 'just test help'"`), not dump inline language lists.

## Project layout

```
src/
  c/           # C (freestanding)
  clojure/     # Clojure
  cpp/         # C++
  dart/        # Dart
  csharp/      # C#
  elixir/      # Elixir
  elm/         # Elm
  erlang/      # Erlang
  go/          # Go
  haskell/     # Haskell
  java/        # Java
  kotlin/      # Kotlin
  ocaml/       # OCaml
  perl/        # Perl
  php/         # PHP
  python/      # Python
  ruby/        # Ruby
  rust/        # Rust
  scala/       # Scala
  swift/       # Swift
  typescript/  # TypeScript
  zig/         # Zig
tests/         # Canonical test specification (testing.md)
locales/       # Canonical locale JSON files (single source of truth)
codegen/       # Locale code generator (JSON → all languages)
scripts/       # Shared scripts (runner/, get-started, installers/)
docs/          # Shared docs, locale docs
```

Core files per language follow a consistent pattern:
- Formatter: `parenttime.c` (generated), `formatter.clj`, `parenttime.cpp`, `ParentTime.cs`, `format_age.dart`, `formatter.ex`, `Formatter.elm`, `parenttime_formatter.erl`, `parenttime.go`, `Formatter.hs`, `ParentTime.java`, `ParentTime.kt`, `formatter.ml`, `Formatter.pm`, `ParentTime.php`, `format_age.py`, `formatter.rb`, `formatter.rs`, `ParentTime.scala`, `ParentTime.swift`, `format-age.ts`, `parenttime.zig`
- Types/Locale: `parenttime.h` (generated), (maps), `types.hpp`, `AgeLocale.cs`, `types.dart`, `locale.ex`, `Types.elm`, `parenttime.hrl`, `locale.go`, `Types.hs`, `AgeLocale.java`, `Types.kt`, `types.ml`, `Locale.pm`, `AgeLocale.php`, `locale.py`, `locale.rb`, `types.rs`, `Types.scala`, `AgeLocale.swift`, `locale.ts`, `locales.zig` (generated)
- Locale data files: `locales/` subdirectory (one file per locale)

## Code style

- Each language follows its community conventions — no cross-language style mandates.
- Zero warnings in CI. When suppressing a lint, document why.
- Don't add comments that restate the code. Comments should explain "why", not "what."
- Locale data files will have long lines — that's expected.
- Markdown tables must be column-aligned with spaces so pipe delimiters line up vertically in raw text. Run `just maintain docs` to fix alignment automatically.
- Language-specific build artifacts (e.g., `_build/`, `dist-newstyle/`, `build/`) go in `src/.gitignore`, not the root `.gitignore`. The root `.gitignore` is for cross-language patterns only (e.g., `__pycache__/`, `.logs/`).
- **Gitignore sections must be alphabetically ordered.** In `src/.gitignore`, language sections are ordered alphabetically by language name (C, C#, C++, Clojure, …, Zig). In the root `.gitignore`, entries are also kept in alphabetical order.

## Adding a new locale

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for the full guide. Summary:

1. Identify the CLDR plural rule — one of the 23 existing rules covers every CLDR cardinal pattern
2. Create `locales/{code}.json` with units, half marker, delimiter, justBorn, and stages
3. Run `just generate locales` — generates locale files and docs in all languages
4. Run `just test && just lint` to verify
5. Optionally add locale-specific test cases to `tests/testing.md`

## Adding a new language

See [`docs/adding-a-language.md`](docs/adding-a-language.md) for the full guide. Summary:

1. Create `codegen/targets/<lang>/emitter.py` — emits locale source files from JSON
2. Create `codegen/targets/<lang>/plural_rules.py` with all 23 plural patterns
3. Register the generator in `codegen/generate.py` (`_GENERATORS` dict)
4. Implement types (`AgeLocale`, `PluralCategory`, etc.) and the core formatter (port from an existing implementation)
5. Implement all test cases from `tests/testing.md`
6. Add to `justfile` (test, build, lint, clean recipes)
7. Configure the language's standard linter with zero warnings
8. Create installer script at `scripts/installers/<lang>.sh` and update `Dockerfile`
9. Create `src/<lang>/README.md` with a `## License` section linking to `LICENSE.md`
10. Create `.github/workflows/<lang>.yml` CI workflow with a version matrix
11. Update cross-language doc tables (keep rows sorted alphabetically; don't hardcode counts in prose — update only the `CLAUDE.md` project description)
12. Verify: `just generate locales && just check && just test && just lint`

## Commit conventions

- Imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For cross-language changes, prefer a single commit over one-per-language
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
