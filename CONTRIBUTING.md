# Contributing to parent-time

Thanks for your interest in contributing! This project maintains identical implementations across 8 languages, so contributions follow a few specific patterns.

## Getting started

1. Fork and clone the repository
2. Pick the language(s) you want to work with — each lives in its own directory
3. Follow the language-specific README for build and test instructions

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
docs/          # Shared documentation and test specifications
```

## Key principles

- **All 8 implementations produce identical output** for the same inputs. Changes to formatting logic must be applied to all languages.
- **Deterministic tests.** Every test uses explicit `(dateOfBirth, asOf)` date pairs — never "today."
- **Zero dependencies.** No runtime dependencies in any language. Pure date arithmetic.
- **Spec-first testing.** The canonical test specification lives in [`docs/testing.md`](docs/testing.md). Add new test cases there first, then implement in all 8 languages.

## Types of contributions

### Locale improvements

Native speaker feedback is especially welcome. If a translation sounds unnatural, a plural rule is wrong, or a stage label uses the wrong register, please open an issue or PR. You only need to fix the locales you know — we'll propagate to the other 7 languages.

See [`docs/gender-and-stages.md`](docs/gender-and-stages.md) for the gender analysis of stage labels.

### New locales

To add a new locale:

1. Define the locale data (plural rules, unit templates, stage labels, half-year marker)
2. Add it to all 8 implementations
3. Add a test verifying basic output

### Bug fixes

If you find a discrepancy between implementations, the TypeScript version is the reference. File an issue with the input and the differing outputs.

### New features

Open an issue to discuss before implementing. Features must work across all 8 languages, so design discussions help avoid wasted effort.

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

## Code style

Each language follows its community conventions. There are no strict formatting requirements beyond what each language's linter enforces. See [`docs/code-quality.md`](docs/code-quality.md) for details.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE.md).
