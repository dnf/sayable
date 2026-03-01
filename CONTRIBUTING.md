# Contributing to parent-time

Thanks for your interest in contributing! This project maintains identical implementations across 8 languages, so contributions follow a few specific patterns.

## Discuss before implementing

Because every change must work across 8 languages, please **open an issue before starting work** on anything beyond a small locale correction. This applies to new features, API changes, new locales, and non-trivial bug fixes. A quick discussion upfront prevents 8x wasted effort if the approach needs adjustment.

The only exception: if you're a native speaker fixing a translation or plural rule in a locale you know, go ahead and open a PR directly.

## Getting started

1. Fork and clone the repository
2. Pick the language(s) you want to work with — each lives in its own directory
3. Follow the language-specific README for build and test instructions
4. Look for issues labeled `good first issue` for well-scoped tasks. Adding a locale you speak natively is another excellent first contribution.

## Project structure

```
typescript/    # TypeScript (reference implementation)
python/        # Python
go/            # Go
ruby/          # Ruby
rust/          # Rust
kotlin/        # Kotlin
cpp/           # C++
php/           # PHP
codegen/       # Locale code generator (JSON → all 8 languages)
  locales/     # 63 JSON files — single source of truth for locale data
  targets/     # One directory per target language (emitter + plural rules)
  generate.py  # Orchestrator: loads JSON, runs emitters, writes files
docs/          # Shared documentation and test specifications
```

## Key principles

- **All 8 implementations produce identical output** for the same inputs. Changes to formatting logic must be applied to all languages.
- **Deterministic tests.** Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero dependencies.** No runtime dependencies in any language. Pure date arithmetic.
- **Spec-first testing.** The canonical test specification lives in [`docs/testing.md`](docs/testing.md). Add new test cases there first, then implement in all 8 languages.

## What we won't merge

To save you time, here's what falls outside the project's scope:

- **Features that can't be implemented consistently across all 8 languages.** If it relies on a language-specific capability, it doesn't fit.
- **Runtime dependencies.** The library is zero-dependency in every language. No exceptions.
- **Timezone or system locale detection.** The library takes explicit date strings and locale objects. It does not sniff the environment.
- **Date parsing or manipulation.** This library formats ages, not dates.

## Types of contributions

### Locale improvements

Native speaker feedback is especially welcome. If a translation sounds unnatural, a plural rule is wrong, or a stage label uses the wrong register, please open an issue or PR.

To fix a locale:

1. Edit the JSON file in `codegen/locales/{code}.json`
2. Run `python -m codegen.generate` to regenerate all 8 language implementations
3. Run the test suites to verify

Never edit the generated locale files (e.g. `typescript/src/locales/fr.ts`) by hand — they will be overwritten by the generator. See [`codegen/README.md`](codegen/README.md) for full details.

See [`docs/gender-and-stages.md`](docs/gender-and-stages.md) for the gender analysis of stage labels.

### New locales

See [`docs/adding-a-locale.md`](docs/adding-a-locale.md) for a detailed guide. In short:

1. Identify the CLDR plural rule for the language (one of the 12 existing rules usually fits)
2. Create `codegen/locales/{code}.json` with the locale data
3. Run `python -m codegen.generate` to generate locale files in all 8 languages
4. Add test cases to `docs/testing.md` and implement them in all 8 test files
5. Run all test suites

### Bug fixes

If you find a discrepancy between implementations, the TypeScript version is the reference. File an issue with the input and the differing outputs.

### New features

Open an issue to discuss before implementing. Features must work across all 8 languages, so design discussions help avoid wasted effort.

## Reporting bugs

A good bug report includes:

- **Which language implementation(s)** are affected
- **The exact `dateOfBirth` and `asOf` values** that produce the wrong output
- **The locale** used (e.g., `es`, `ar`)
- **Expected output** vs **actual output**

The fastest way to get a bug fixed is to include a failing test case in the format used by [`docs/testing.md`](docs/testing.md). If you can't reproduce it with a specific date pair, we probably can't either.

## Native speaker policy

Locale changes require native speaker verification before merging:

- If you're a native speaker, say so in your PR.
- If you're not a native speaker, your PR will be tagged for review by someone who is.
- For locales without an active native speaker reviewer, we may merge with a note and revisit if feedback arrives later.

## Pull request checklist

Before submitting a PR, verify:

- [ ] Tests pass in all affected languages
- [ ] New test cases added to `docs/testing.md` first (if applicable)
- [ ] Locale changes reviewed by a native speaker (or self-attested)
- [ ] Locale changes made in `codegen/locales/*.json` and regenerated (not hand-edited)
- [ ] `python -m codegen.generate --check` passes
- [ ] All 8 implementations updated (for logic/feature changes)
- [ ] No runtime dependencies added

## Running tests

| Language | Command |
|----------|---------|
| TypeScript | `cd typescript && npx vitest run` |
| Python | `cd python && uv run pytest tests/` |
| Go | `cd go && go test ./...` |
| Ruby | `cd ruby && ruby -Ilib test/test_formatter.rb` |
| Rust | `cd rust && cargo test` |
| Kotlin | `cd kotlin && ./gradlew test` |
| C++ | `cd cpp && mkdir -p build && cd build && cmake .. && make && ./test_parenttime` |
| PHP | `cd php && php vendor/bin/phpunit tests/` |

CI runs all 8 language test suites on every pull request. PRs that break any language will not be merged.

## Commit messages

- Use imperative mood: "Add Finnish locale" not "Added Finnish locale"
- For locale PRs, name the locale: "Fix plural rules for Arabic (ar)"
- For cross-language changes, a single commit is preferred over one-per-language

## Code style

Each language follows its community conventions. There are no strict formatting requirements beyond what each language's linter enforces. See [`docs/code-quality.md`](docs/code-quality.md) for details.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE.md).
