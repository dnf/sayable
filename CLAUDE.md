# CLAUDE.md

## What this project is

parent-time is a zero-dependency library that formats ages the way parents talk ("6 weeks", "14 months", "3½ years"). It has 14 identical implementations (C, TypeScript, Python, Go, Ruby, Rust, Kotlin, C++, PHP, Java, C#, Swift, Haskell, Erlang) and 71 locales.

## Build and test commands

The `justfile` is the primary task runner. Running `just test`, `just build`, or `just lint` with no arguments runs all languages **in parallel**, capturing output to log files and printing a summary:

```
just test          # all 14 test suites + codegen check, in parallel
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

- **All 14 implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in `docs/testing.md` first, then get implemented in all 14 languages. Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero runtime dependencies.** No exceptions in any language.
- **Locale data lives in `codegen/locales/*.json`.** These JSON files are the single source of truth. To change a locale, edit the JSON file and run `python -m codegen.generate` to regenerate all 14 language implementations. Never edit generated locale files by hand.

## Project layout

```
src/
  c/           # C (freestanding)
  typescript/  # TypeScript
  python/      # Python
  go/          # Go
  ruby/        # Ruby
  rust/        # Rust
  kotlin/      # Kotlin
  cpp/         # C++
  php/         # PHP
  java/        # Java
  csharp/      # C#
  swift/       # Swift
  haskell/     # Haskell
  erlang/      # Erlang
codegen/       # Locale code generator (JSON → all 14 languages)
docs/          # Shared docs, test spec, locale docs
```

Core files per language follow a consistent pattern:
- Formatter: `parenttime.c` (generated), `format-age.ts`, `format_age.py`, `parenttime.go`, `formatter.rb`, `formatter.rs`, `ParentTime.kt`, `parenttime.cpp`, `ParentTime.php`, `ParentTime.java`, `ParentTime.cs`, `ParentTime.swift`, `Formatter.hs`, `parenttime_formatter.erl`
- Types/Locale: `parenttime.h` (generated), `locale.ts`, `locale.py`, `locale.go`, `locale.rb`, `types.rs`, `Types.kt`, `types.hpp`, `AgeLocale.php`, `AgeLocale.java`, `AgeLocale.cs`, `AgeLocale.swift`, `Types.hs`, `parenttime.hrl`
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
2. Create `codegen/locales/{code}.json` with units, half marker, delimiter, justBorn, and stages
3. Run `python -m codegen.generate` — generates locale files in all 14 languages
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
8. Verify: `just generate && just check && just test && just lint`

## Commit conventions

- Imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For cross-language changes, prefer a single commit over one-per-language
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
