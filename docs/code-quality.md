# Code Quality Configuration

This document describes the static analysis, type checking, and linting
configuration for each of the eight parent-time implementations. The goal is
"worthwhile strictness" — every check that catches real bugs or improves
readability is enabled, while checks that produce noise for this specific
codebase are suppressed with a documented rationale.

## Design principles

1. **Zero warnings in CI.** Every implementation compiles or lints with zero
   errors and zero warnings. This means new regressions are immediately visible.

2. **Suppress with a reason, not a blanket ignore.** When a pedantic rule is
   disabled, the suppression is annotated with *why* it's a false positive for
   this codebase (e.g., locale data files naturally have long lines).

3. **Match the ecosystem's conventions.** Each language uses the tool its
   community considers standard — ruff for Python, clippy for Rust, ESLint for
   TypeScript — rather than trying to impose a uniform meta-linter.

4. **Zero external dependencies for the library itself.** Linters and type
   checkers are dev-only. The shipped library in every language has zero
   runtime dependencies.

## Cross-cutting considerations

### i18n locale data

All eight implementations contain 71 locale files with Unicode string literals
(Arabic, Chinese, Devanagari, Cyrillic, etc.). This creates predictable
friction with certain lint rules:

- **Long lines** — locale data maps are naturally wide. Suppressed per-file in
  Python (E501), Ruby (Layout/LineLength), and Rust (too_many_lines).
- **Ambiguous Unicode characters** — Cyrillic "а" looks like Latin "a", Arabic
  diacritics look like combining marks. Suppressed globally in Python (RUF001,
  RUF003) and noted in Rust.
- **Magic numbers** — month thresholds (2, 3, 12, 24, 36, 84, 156, 216) are
  domain constants that are clearer as literals. Suppressed in C++ (clang-tidy)
  and not flagged elsewhere because the other linters don't check for them by
  default.

### Complexity metrics

The core `format_age` function in every implementation has the same structure:
a series of if/else branches for the seven age tiers. This is inherently
~20 cyclomatic complexity regardless of language. Rather than refactoring into
something less readable, we raise the threshold for this specific function
pattern (Ruby AbcSize: 45, CyclomaticComplexity: 20; Go: excluded via
function-level pragma; others don't flag it).

### Test files

Test files are excluded from most style rules in every language. Test code
prioritizes readability of test cases over production code standards — long
table-driven test arrays, multiple assertions per function, and helper
functions with fixed parameters are all expected patterns.

## Per-language details

The configurations are documented in detail in separate files, grouped by
language family:

- **[Dynamic languages](code-quality-dynamic.md)** — TypeScript, Python, Ruby, PHP
- **[Compiled languages](code-quality-compiled.md)** — Go, Rust, Kotlin, C++

## Quick reference

| Language   | Tools                       | Key strictness                                                 | Tests | Assertions |
|------------|-----------------------------|----------------------------------------------------------------|------:|-----------:|
| TypeScript | tsc + ESLint                | `strict` + 7 extra flags; `strict-type-checked` ESLint rules  |   147 |        168 |
| Python     | ruff + pyright              | 11 rule categories; pyright `strict`                           |   145 |        166 |
| Go         | golangci-lint v2            | 10 linters + gofmt/goimports formatters                        |    72 |        128 |
| Ruby       | RuboCop                     | NewCops enabled; frozen strings; practical metric thresholds   |   117 |        173 |
| Rust       | clippy + rustc lints        | `unsafe_code = forbid`; `clippy::all = deny`; pedantic = warn  |    38 |        172 |
| Kotlin     | Kotlin compiler             | `explicitApi()`; `allWarningsAsErrors`; `-Xjsr305=strict`      |   115 |        191 |
| C++        | Compiler flags + clang-tidy | `-Wall -Wextra -Wpedantic -Werror` + 13 more; clang-tidy config |   164 |        167 |
| PHP        | PHPStan + PHP-CS-Fixer      | PHPStan level 9; PER-CS2.0 + risky; `declare(strict_types=1)` |   168 |        179 |

All eight implementations cover the same [163 canonical test cases](testing.md).
**Tests** is what each framework reports when you run the suite. **Assertions** is
the count of individual assertion calls in the test source. These numbers differ
across languages because each ecosystem has its own idiomatic test granularity —
Go uses table-driven tests (many assertions per function), PHP uses
one-assertion-per-method — but the underlying spec coverage is identical.
