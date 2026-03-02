# CLAUDE.md

## What this project is

parent-time is a zero-dependency library that formats ages the way parents talk ("6 weeks", "14 months", "3½ years"). It has 18 identical implementations (C, C#, C++, Clojure, Elm, Erlang, Go, Haskell, Java, Kotlin, PHP, Python, Ruby, Rust, Scala, Swift, TypeScript, Zig) and 71 locales.

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

| Shortcut | Command |
|----------|---------|
| Codegen check | `just check` or `python -m codegen.generate --check` |
| Codegen subset | `python -m codegen.generate --locales core` |
| Codegen tests | `just test codegen` |
| List groups | `python -m codegen.generate --list-groups` |
| Clean artifacts | `just clean` or `just clean <lang\|codegen>` |

## Key rules

- **All implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in `docs/testing.md` first, then get implemented in all languages. Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Canonical test IDs.** Every test must be annotated with the ID(s) from `docs/testing.md` that it implements — as a comment above the test or inline. This enables cross-language verification that all tests map to their canonical definition.
- **Zero runtime dependencies.** No exceptions in any language.
- **Locale data lives in `locales/*.json`.** These JSON files are the single source of truth. To change a locale, edit the JSON file and run `python -m codegen.generate` to regenerate all language implementations. Never edit generated locale files by hand.
- **Generated files carry a prominent banner.** Every generated file starts with a 9-line box-frame `DO NOT EDIT` banner (from `codegen/banner.py`) referencing the generator path. Locale files also include a `Source: locales/{code}.json` comment linking to the canonical JSON.
- **Every language must have a `src/<lang>/README.md`** with API docs and a `## License` section linking to `LICENSE.md`. The root `README.md` table must link to it in the Docs column.

## Project layout

```
src/
  c/           # C (freestanding)
  clojure/     # Clojure
  cpp/         # C++
  csharp/      # C#
  elm/         # Elm
  erlang/      # Erlang
  go/          # Go
  haskell/     # Haskell
  java/        # Java
  kotlin/      # Kotlin
  php/         # PHP
  python/      # Python
  ruby/        # Ruby
  rust/        # Rust
  scala/       # Scala
  swift/       # Swift
  typescript/  # TypeScript
  zig/         # Zig
locales/       # Canonical locale JSON files (single source of truth)
codegen/       # Locale code generator (JSON → all languages)
docs/          # Shared docs, test spec, locale docs
```

Core files per language follow a consistent pattern:
- Formatter: `parenttime.c` (generated), `formatter.clj`, `parenttime.cpp`, `ParentTime.cs`, `Formatter.elm`, `parenttime_formatter.erl`, `parenttime.go`, `Formatter.hs`, `ParentTime.java`, `ParentTime.kt`, `ParentTime.php`, `format_age.py`, `formatter.rb`, `formatter.rs`, `ParentTime.scala`, `ParentTime.swift`, `format-age.ts`, `parenttime.zig`
- Types/Locale: `parenttime.h` (generated), (maps), `types.hpp`, `AgeLocale.cs`, `Types.elm`, `parenttime.hrl`, `locale.go`, `Types.hs`, `AgeLocale.java`, `Types.kt`, `AgeLocale.php`, `locale.py`, `locale.rb`, `types.rs`, `Types.scala`, `AgeLocale.swift`, `locale.ts`, `locales.zig` (generated)
- Locale data files: `locales/` subdirectory (one file per locale)

## Code style

- Each language follows its community conventions — no cross-language style mandates.
- Zero warnings in CI. When suppressing a lint, document why.
- Don't add comments that restate the code. Comments should explain "why", not "what."
- Locale data files will have long lines — that's expected.
- Language-specific build artifacts (e.g., `_build/`, `dist-newstyle/`, `build/`) go in `src/.gitignore`, not the root `.gitignore`. The root `.gitignore` is for cross-language patterns only (e.g., `__pycache__/`, `.logs/`).

## Adding a new locale

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for the full guide. Summary:

1. Identify the CLDR plural rule — one of the 23 existing rules covers every CLDR cardinal pattern
2. Create `locales/{code}.json` with units, half marker, delimiter, justBorn, and stages
3. Run `python -m codegen.generate` — generates locale files in all languages
4. Run `just test && just lint` to verify
5. Optionally add locale-specific test cases to `docs/testing.md`

## Adding a new language

See [`docs/adding-a-language.md`](docs/adding-a-language.md) for the full guide. Summary:

1. Create `codegen/targets/<lang>/emitter.py` — emits locale source files from JSON
2. Create `codegen/targets/<lang>/plural_rules.py` with all 23 plural patterns
3. Register the generator in `codegen/generate.py` (`_GENERATORS` dict)
4. Implement types (`AgeLocale`, `PluralCategory`, etc.) and the core formatter (port from an existing implementation)
5. Implement all test cases from `docs/testing.md`
6. Add to `justfile` (test, build, lint, clean recipes)
7. Configure the language's standard linter with zero warnings
8. Update bootstrap scripts (`Dockerfile`, `scripts/bootstrap-macos.sh`, `scripts/bootstrap-linux.sh`)
9. Create `src/<lang>/README.md` with a `## License` section linking to `LICENSE.md`
10. Update cross-language doc tables (keep rows sorted alphabetically; don't hardcode counts in prose — update only the `CLAUDE.md` project description)
11. Verify: `just generate && just check && just test && just lint`

## Commit conventions

- Imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For cross-language changes, prefer a single commit over one-per-language
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
