# Code Quality Configuration

This document describes the static analysis, type checking, and linting
configuration for each of the parent-time implementations. The goal is
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

5. **Name over comment.** When a line of code needs a comment to explain *what*
   it does (not *why*), extract it into a named function or variable. The name
   replaces the comment. This applies especially to raw escape sequences, magic
   numbers, and opaque shell idioms.

## Naming conventions

Each language follows its community's standard naming conventions. The table
below summarizes the patterns across all implementations:

| Language   | Classes/Types | Functions/Methods     | Constants           | Fields/Properties     | Enum variants         |
| ---------- | ------------- | --------------------- | ------------------- | --------------------- | --------------------- |
| Ada        | PascalCase    | PascalCase            | PascalCase (`EN`)   | PascalCase (record)   | PascalCase            |
| C#         | PascalCase    | PascalCase            | UPPER_CASE (`EN`)   | PascalCase            | PascalCase            |
| C++        | PascalCase    | snake_case            | UPPER_CASE (`EN()`) | snake_case            | PascalCase            |
| Elixir     | PascalCase    | snake_case            | UPPER_CASE (`EN`)   | atom keys             | n/a (atom literals)   |
| Elm        | PascalCase    | camelCase             | lowercase (`en`)    | camelCase             | PascalCase            |
| F#         | PascalCase    | camelCase             | PascalCase (`En`)   | PascalCase (record)   | PascalCase            |
| Fortran    | n/a (modules) | snake_case            | UPPER_CASE (`PT_*`) | snake_case (%)        | integer parameters    |
| Gleam      | PascalCase    | snake_case            | lowercase (`en`)    | snake_case (record)   | PascalCase            |
| Go         | PascalCase    | PascalCase (exported) | UPPER_CASE (`EN`)   | PascalCase (exported) | PascalCase            |
| Groovy     | PascalCase    | camelCase             | UPPER_CASE (`EN`)   | camelCase             | UPPER_CASE            |
| Java       | PascalCase    | camelCase             | UPPER_CASE (`EN`)   | camelCase             | UPPER_CASE            |
| Kotlin     | PascalCase    | camelCase             | UPPER_CASE (`EN`)   | camelCase             | UPPER_CASE            |
| Lua        | n/a (tables)  | snake_case            | UPPER_CASE (`EN`)   | snake_case (table)    | n/a (string literals) |
| OCaml      | PascalCase    | snake_case            | PascalCase (`En`)   | snake_case (record)   | PascalCase            |
| Perl       | PascalCase    | snake_case            | UPPER_CASE (`EN`)   | snake_case (hashref)  | n/a (string literals) |
| PHP        | PascalCase    | camelCase             | UPPER_CASE (`EN()`) | camelCase             | PascalCase            |
| Python     | PascalCase    | snake_case            | UPPER_CASE (`EN`)   | snake_case            | n/a (string literals) |
| Ruby       | PascalCase    | snake_case            | UPPER_CASE (`EN`)   | snake_case symbols    | n/a                   |
| Rust       | PascalCase    | snake_case            | UPPER_CASE (`EN`)   | snake_case            | PascalCase            |
| Scala      | PascalCase    | camelCase             | UPPER_CASE (`EN`)   | camelCase             | UPPER_CASE            |
| Swift      | PascalCase    | camelCase             | UPPER_CASE (`EN`)   | camelCase             | camelCase             |
| TypeScript | PascalCase    | camelCase             | lowercase (`en`)    | camelCase             | n/a (string literals) |
| Zig        | PascalCase    | camelCase             | lowercase (`en`)    | snake_case            | .snake_case           |

The locale JSON source files use camelCase keys (`justBorn`, `formatNumber`).
The code generator translates these to each language's idiomatic convention
during generation — for example, `justBorn` becomes `just_born` in Python and
Rust, stays `justBorn` in TypeScript and Kotlin, and so on.

**TypeScript locale constants** use lowercase (`en`, `fr`) rather than
UPPER_CASE because they are module-level `const` bindings — plain values, not
class-level or "true" constants in the Python/Go sense. Lowercase is the
TypeScript community norm for exported `const` values.

**Two deliberate deviations:** C++ locale accessors (`locales::EN()`) and PHP
locale accessors (`Locales::EN()`) use UPPER_CASE for function names. These
are lazy singleton accessors that semantically behave like constants, and the
naming matches every other language's `EN` constant. See the per-language
details for rationale.

## Immutability

All implementations treat the `ParentTime` formatter as immutable after
construction. Fields are set once during `__init__` / the constructor and never
modified — every formatting method is a pure read. The table below summarizes
how each language enforces this:

| Language   | Mechanism                             | Notes                                                                             |
| ---------- | ------------------------------------- | --------------------------------------------------------------------------------- |
| Ada        | `in` mode parameters                  | Locale passed as `in` mode; record fields set at initialization, not modified     |
| C#         | `private readonly` fields             | Fields set in constructor; `TreatWarningsAsErrors` in project                     |
| C++        | `const` methods + `const` locals      | Methods are `const`-qualified; local variables use `const` where assigned once    |
| Elixir     | Immutable by language design          | All data is immutable in Elixir; functions are pure by convention                 |
| Elm        | Pure functions (no mutable state)     | Elm has no mutable state; all functions are pure by language design               |
| F#         | `private` fields + immutable records  | Records are immutable by default; fields set in constructor                       |
| Fortran    | `intent(in)` on all locale args       | Derived types passed as `intent(in)` prevent modification; pure where possible    |
| Gleam      | Immutable by language design          | All data is immutable in Gleam; custom types and records are immutable by default |
| Go         | Unexported fields                     | Only the package can access them; methods use value receivers                     |
| Groovy     | `@Immutable` + `private final` fields | Groovy `@Immutable` generates immutable class; fields set in constructor          |
| Java       | `private final` fields                | Fields set in constructor, never modified; all formatting methods are pure reads  |
| Kotlin     | `private val` fields                  | `val` is compile-time immutable; `private` hides from consumers                   |
| Lua        | Closure-captured locals               | Upvalues captured at construction; no public field access                         |
| OCaml      | Immutable by language design          | All data is immutable in OCaml; records and ADTs are immutable by default         |
| Perl       | Hashref-based (convention)            | Fields set in constructor; `use strict` prevents undeclared variable access       |
| PHP        | `readonly` class                      | PHP 8.2 `readonly` prevents field reassignment after construction                 |
| Python     | `_`-prefixed fields + pyright strict  | Convention-based; pyright prevents external access to `_` members                 |
| Ruby       | `freeze` in `initialize`              | Runtime error on any mutation after construction                                  |
| Rust       | `&self` on all methods                | Borrow checker prevents mutation through shared references                        |
| Scala      | `private val` fields                  | `val` is compile-time immutable; `private` hides from consumers                   |
| Swift      | `private let` fields + `Sendable`     | `let` is compile-time immutable; struct conforms to `Sendable`                    |
| TypeScript | `private readonly` fields             | Compiler error on reassignment                                                    |

## Cross-cutting considerations

### Generated file headers

Every file produced by `codegen/generate.py` carries two markers:

1. **Box-frame banner** — a 9-line ASCII box (`codegen/banner.py`) that names
   the generator path and warns against manual edits. Each language uses its
   native comment syntax (`//`, `#`, `/* */`, `--`, `%%`, `;;`).
2. **Locale source comment** — a single line
   `Source: locales/{code}.json` linking to the canonical JSON.
   Per-file languages place it after the banner; single-file languages place it
   above each locale block.

Barrel, registry, and header files carry only the banner (they don't correspond
to a single locale).

### i18n locale data

All implementations contain 71 locale files with Unicode string literals
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

### Documentation formatting

Markdown tables across all project documentation are enforced to be
column-aligned so pipe delimiters line up vertically in raw text.
`codegen/align_tables.py` handles alignment automatically.

- `just maintain docs` — aligns all project-owned markdown files
- `just check` — verifies table alignment (exits non-zero if misaligned)
- Files covered: `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`,
  `codegen/README.md`, `locales/README.md`, `tests/README.md`,
  `tests/testing.md`, `docs/*.md`, `src/*/README.md`
- Generated files (`locales/example-output/*.md`) are excluded — they are
  maintained by `codegen/docgen.py`

### Canonical test IDs

Every test must be annotated with the ID(s) from [`tests/testing.md`](../tests/testing.md)
that it implements. This enables cross-language verification that all
implementations cover the same spec. See the "Test ID convention" section of
`tests/testing.md` for the three placement patterns (comment above, trailing
comment, or inline comment) used across languages.

## Per-language details

The configurations are documented in detail in separate files, grouped by
language family:

- **[Dynamic languages](code-quality-dynamic.md)** — TypeScript, Python, Ruby, PHP
- **[Compiled languages](code-quality-compiled.md)** — Go, Rust, Kotlin, C++, Java

## Quick reference

| Language   | Tools                       | Key strictness                                                  | Tests | Assertions |
| ---------- | --------------------------- | --------------------------------------------------------------- | ----: | ---------: |
| Ada        | GNAT compiler               | `-gnatwa -gnatwe -gnata -gnatVa`; CTest-style harness           | 214   | 214        |
| C#         | .NET compiler               | `TreatWarningsAsErrors`; xUnit                                  | 140   | 191        |
| C++        | Compiler flags + clang-tidy | `-Wall -Wextra -Wpedantic -Werror` + 13 more; clang-tidy config | 164   | 167        |
| Elixir     | Mix compiler                | `warnings_as_errors: true`; ExUnit                              | 209   | 209        |
| Elm        | Elm compiler                | Compiler warnings-as-errors; `elm-explorations/test`            | 209   | 209        |
| F#         | .NET compiler               | `TreatWarningsAsErrors`; xUnit                                  | 215   | 208        |
| Fortran    | gfortran compiler           | `-Wall -Wextra -Wpedantic -Werror -std=f2008`; CTest            | 214   | 214        |
| Gleam      | Gleam compiler              | Warnings-as-errors; gleeunit                                    | 208   | 208        |
| Go         | golangci-lint v2            | 10 linters + gofmt/goimports formatters                         | 72    | 128        |
| Groovy     | Groovy + Java compiler      | `-Werror`; Java 17; `@Immutable` data classes                   | 140   | 291        |
| Java       | Java compiler               | `-Xlint:all -Werror`; Java 17; sealed interfaces, records       | 135   | 191        |
| Kotlin     | Kotlin compiler             | `explicitApi()`; `allWarningsAsErrors`; `-Xjsr305=strict`       | 115   | 191        |
| Lua        | luacheck                    | Lua 5.4 std; busted globals for tests                           | 194   | 194        |
| OCaml      | Dune + OCaml compiler       | `-warn-error +a`; Alcotest                                      | 209   | 209        |
| Perl       | strict + warnings           | `use strict; use warnings` in all modules                       | 261   | 261        |
| PHP        | PHPStan + PHP-CS-Fixer      | PHPStan level 9; PER-CS2.0 + risky; `declare(strict_types=1)`   | 168   | 179        |
| Python     | ruff + pyright              | 11 rule categories; pyright `strict`                            | 145   | 166        |
| Ruby       | RuboCop                     | NewCops enabled; frozen strings; practical metric thresholds    | 117   | 173        |
| Rust       | clippy + rustc lints        | `unsafe_code = forbid`; `clippy::all = deny`; pedantic = warn   | 38    | 172        |
| Scala      | Scala compiler              | `-Werror`; Scala 3 enums, sealed traits                         | 115   | 191        |
| Swift      | Swift compiler              | `StrictConcurrency`; Swift Testing                              | 140   | 191        |
| TypeScript | tsc + ESLint                | `strict` + 7 extra flags; `strict-type-checked` ESLint rules    | 147   | 168        |
| Zig        | Zig compiler                | Warnings-as-errors; built-in test framework                     | 163   | 163        |

All implementations cover the same [212 canonical test cases](../tests/testing.md).
**Tests** is what each framework reports when you run the suite. **Assertions** is
the count of individual assertion calls in the test source. These numbers differ
across languages because each ecosystem has its own idiomatic test granularity —
Go uses table-driven tests (many assertions per function), PHP uses
one-assertion-per-method — but the underlying spec coverage is identical.
