# CLAUDE.md

## What this project is

parent-time is a zero-dependency library that formats ages the way parents talk ("6 weeks", "14 months", "3½ years"). It has 8 identical implementations (TypeScript, Python, Go, Ruby, Rust, Kotlin, C++, PHP) and 49 locales. TypeScript is the reference implementation.

## Build and test commands

| Language | Test command |
|----------|-------------|
| TypeScript | `cd typescript && npx vitest run` |
| Python | `cd python && uv run pytest tests/` |
| Go | `cd go && go test ./...` |
| Ruby | `cd ruby && ruby -Ilib test/test_formatter.rb` |
| Rust | `cd rust && cargo test` |
| Kotlin | `cd kotlin && ./gradlew test` |
| C++ | `cd cpp && cmake -B build && cmake --build build && cd build && ctest --output-on-failure` |
| PHP | `cd php && php vendor/bin/phpunit tests/` |
| Codegen check | `python -m codegen.generate --check` |

## Key rules

- **All 8 implementations must produce identical output.** Changes to formatting logic must be applied to all languages.
- **Spec-first testing.** New test cases go in `docs/testing.md` first, then get implemented in all 8 languages. Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero runtime dependencies.** No exceptions in any language.
- **TypeScript is the reference.** When implementations disagree, TypeScript is correct.
- **Locale data lives in `codegen/locales/*.json`.** These JSON files are the single source of truth. To change a locale, edit the JSON file and run `python -m codegen.generate` to regenerate all 8 language implementations. Never edit generated locale files by hand.

## Project layout

```
typescript/    # Reference implementation
python/        # Python
go/            # Go
ruby/          # Ruby
rust/          # Rust
kotlin/        # Kotlin
cpp/           # C++
php/           # PHP
codegen/       # Locale code generator (JSON → all 8 languages)
docs/          # Shared docs, test spec, locale docs
```

Core files per language follow a consistent pattern:
- Formatter: `format-age.ts`, `format_age.py`, `parenttime.go`, `formatter.rb`, `formatter.rs`, `ParentTime.kt`, `parenttime.cpp`, `ParentTime.php`
- Types/Locale: `locale.ts`, `locale.py`, `locale.go`, `locale.rb`, `types.rs`, `Types.kt`, `types.hpp`, `AgeLocale.php`
- Locale data files: `locales/` subdirectory (one file per locale)

## Code style

- Each language follows its community conventions — no cross-language style mandates.
- Zero warnings in CI. When suppressing a lint, document why.
- Don't add comments that restate the code. Comments should explain "why", not "what."
- Locale data files will have long lines — that's expected.

## Commit conventions

- Imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For cross-language changes, prefer a single commit over one-per-language
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
