# Code Quality: Compiled Languages

Detailed configuration rationale for languages with complex linter setups. See below for per-language sections.

---

## Go

**Tools:** golangci-lint v2

**Config file:** `.golangci.yml`

### Philosophy

Go's ecosystem has a strong "one way to do things" culture. `go vet` and
`gofmt` are non-negotiable baselines. golangci-lint layers additional analysis
on top without fighting the language's conventions.

### Linters enabled

| Linter        | What it catches                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------- |
| `errcheck`    | Unchecked error returns. The single most important Go linter — ignoring errors is the #1 source of Go bugs.         |
| `govet`       | Suspicious constructs that `go vet` flags: printf format mismatches, struct tag errors, unreachable code.           |
| `staticcheck` | The gold standard Go static analyzer. Catches deprecated API usage, impossible conditions, unnecessary conversions. |
| `unused`      | Unused variables, functions, types. Keeps the codebase clean.                                                       |
| `ineffassign` | Assignments to variables that are never read. Catches leftover debugging assignments.                               |
| `gocritic`    | Opinionated but useful style checks. We enable the `diagnostic`, `style`, and `performance` tags.                   |
| `misspell`    | Typos in comments and strings. Catches "definately", "occured", etc.                                                |
| `unconvert`   | Unnecessary type conversions.                                                                                       |
| `unparam`     | Function parameters that are always called with the same value.                                                     |
| `prealloc`    | Slice declarations that could be preallocated for known sizes.                                                      |

### Formatters

golangci-lint v2 separates formatters from linters:

- `gofmt` — standard Go formatting (not optional in Go culture)
- `goimports` — `gofmt` plus import grouping and removal of unused imports

### Exclusions

- `unparam` is excluded for test files (`_test.go`). Test helper functions
  like `assertContains(t, got, want)` always receive the same type of input,
  which triggers false positives.

### What was considered but not added

- **`revive`** — a configurable replacement for `golint`. Most of its useful
  rules overlap with `gocritic` and `staticcheck`. Adding it would create
  duplicate warnings.
- **`gocyclo`/`cyclop`** — cyclomatic complexity checkers. Go's `format_age`
  function has ~15 complexity from the age tier branches, which is reasonable
  for a single function with clear linear flow.
- **`wsl`/`nlreturn`** — whitespace linters. Too opinionated about blank line
  placement; would fight with `gofmt`.

### Naming

PascalCase for exported identifiers, camelCase for unexported ones — this is
enforced by the language itself, since Go determines visibility from
capitalization. Locale variables use UPPER_CASE (`EN`, `FR`), which is idiomatic
for Go package-level variables that act as constants (Go has no `const` for
non-primitive types).

---

## Rust

**Tools:** `rustc` lints + clippy

**Config file:** `Cargo.toml` `[lints]` section

### Philosophy

Rust's compiler already catches most categories of bugs at compile time (memory
safety, type safety, exhaustive matching). clippy adds idiom enforcement and
performance suggestions. We set the bar high — `deny` for all standard clippy
lints, `warn` for pedantic — then selectively allow the false positives.

### Compiler-level lints (`[lints.rust]`)

| Lint           | Level      | Reason                                                                                                                                                                                                               |
| -------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `unsafe_code`  | **forbid** | This is a pure string-formatting library. There is no reason for `unsafe` — no FFI, no raw pointers, no performance-critical inner loops. `forbid` (not just `deny`) means even `#[allow(unsafe_code)]` is rejected. |
| `missing_docs` | warn       | Public API items should be documented. Set to `warn` rather than `deny` because locale submodules use `#![allow(missing_docs)]` — individual locale data doesn't benefit from per-field documentation.               |

### Clippy lints (`[lints.clippy]`)

**Base levels:**

- `all = deny` (priority -1) — all default clippy lints are hard errors
- `pedantic = warn` (priority -1) — extra-strict suggestions are warnings

**Pedantic allows (with rationale):**

| Lint                       | Reason                                                                                                                                                                                             |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `module_name_repetitions`  | `locales::en::locale()` repeats "locale" — this is the natural naming.                                                                                                                             |
| `must_use_candidate`       | clippy suggests `#[must_use]` on every function that returns a value. For a formatting library where every function returns a value, this would add `#[must_use]` everywhere with no real benefit. |
| `missing_panics_doc`       | No public functions panic, but clippy can't prove it.                                                                                                                                              |
| `missing_errors_doc`       | Same — functions return `Option`, not `Result`.                                                                                                                                                    |
| `return_self_not_must_use` | Builder pattern suggestion. Not applicable.                                                                                                                                                        |
| `wildcard_imports`         | `use crate::locales::*` is the intended pattern for re-exporting all 71 locales.                                                                                                                   |
| `unreadable_literal`       | Date arithmetic constants (e.g., `146097` for Julian Day calculations) are clearer without underscores.                                                                                            |
| `match_same_arms`          | Month-length match arms intentionally list each month explicitly (`1 => 31, 2 => 28, 3 => 31, ...`) for clarity rather than combining identical arms.                                              |
| `cast_possible_truncation` | `i64` → `i32` casts for year values. Years are always in the 0–9999 range, well within i32.                                                                                                        |
| `cast_possible_wrap`       | `u64` → `i64` for timestamp values. Same safe-range argument.                                                                                                                                      |
| `cast_sign_loss`           | Needed for date arithmetic where intermediate values are known-positive.                                                                                                                           |
| `too_many_lines`           | The formatter function is ~80 lines. This is the natural size of the age-tier logic.                                                                                                               |
| `manual_string_new`        | `String::from("")` is fine and clearer than `String::new()` in some contexts.                                                                                                                      |
| `missing_fields_in_debug`  | Custom `Debug` for `AgeLocale` omits function pointer fields (they print as hex addresses, which is useless).                                                                                      |
| `needless_pass_by_value`   | Function pointer arguments (`fn(i32) -> PluralCategory`) are `Copy` but clippy suggests `&fn(...)` references, which is worse.                                                                     |

### What this caught

- `clone()` on `String` through a `&String` reference (inefficient; changed to
  `clone_from()`).
- Uninlined format arguments in test assertions (auto-fixed).
- Several uses of `ref` bindings in `if let` patterns that could use `&` instead.

### Naming

snake_case for functions and fields, PascalCase for types and enum variants,
SCREAMING_SNAKE_CASE for statics and constants. All enforced by compiler
warnings (`non_snake_case`, `non_camel_case_types`, `non_upper_case_globals`) —
violating any of these conventions produces a warning, which our
`clippy::all = deny` setting promotes to an error.

---

## Kotlin

**Tools:** Kotlin compiler options

**Config file:** `build.gradle.kts`

### Philosophy

Kotlin's compiler is already strict by default compared to Java. The
additional strictness we add focuses on API discipline — making the library's
public surface explicit and treating any compiler warning as a potential bug.

### Compiler settings

| Setting               | What it does                                                                                                                                                                                                                                                                                                                                                                                                   |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `explicitApi()`       | **The most impactful setting.** Requires explicit `public`, `internal`, or `private` visibility on every declaration. Without this, everything defaults to `public`, which leads to accidental API surface. This required adding `public` to all types in `Types.kt`, all methods in `ParentTime.kt`, the `Locales` object, and all 71 locale `val` declarations with explicit `: AgeLocale` type annotations. |
| `allWarningsAsErrors` | Treats all compiler warnings as errors. Kotlin warnings include unused variables, deprecated API usage, and platform-specific issues. Promoting them to errors ensures they're addressed immediately.                                                                                                                                                                                                          |
| `progressiveMode`     | Opts into stricter behavior from newer Kotlin versions even when targeting an older language version. This catches code that relies on language quirks that will be fixed in future releases.                                                                                                                                                                                                                  |
| `-Xjsr305=strict`     | Makes JSR-305 `@Nonnull`/`@Nullable` annotations from Java libraries strict. Without this, Kotlin treats Java types as "platform types" (implicitly nullable). With it, nullability violations from Java interop become compile errors. Important for library consumers who might call parent-time from Java.                                                                                                  |
| `jvmTarget = JVM_17`  | Targets JVM 17 bytecode. This is a deliberate choice over JVM 21 — JVM 17 is the current LTS and maximizes compatibility for library consumers.                                                                                                                                                                                                                                                                |

### What was considered but not added

- **detekt** (static analyzer) — detekt is the Kotlin equivalent of ESLint or
  rubocop. We attempted to add it but detekt 1.23.x doesn't support JDK 25
  (the runtime JDK on this machine). The error was not about target bytecode
  version but about the runtime environment: detekt's embedded Kotlin compiler
  doesn't recognize JDK 25 as a valid JVM target. detekt 2.0.0-alpha.2
  supports JDK 25 but is pre-release. When detekt 2.0 goes stable, it should
  be added with rules similar to the Rust clippy configuration (standard rules
  enabled, magic numbers disabled for locale data, complexity thresholds raised
  for the formatter).

- **`-Xjvm-default=all`** — generates default method implementations in
  interfaces. Not relevant since the library doesn't use interfaces with default
  methods.

### Naming

camelCase for functions and properties, PascalCase for classes and objects,
UPPER_CASE for enum entries and locale `val` declarations. The
`explicitApi()` setting ensures all declarations have explicit visibility
modifiers, which reinforces naming discipline by making every public symbol a
deliberate choice.

---

## C++

**Tools:** GCC/Clang compiler warnings + clang-tidy

**Config files:** `CMakeLists.txt`, `.clang-tidy`

### Philosophy

C++ has no built-in safety net — no garbage collector, no borrow checker, no
null safety. The compiler warning flags and static analysis tools are the
primary defense against undefined behavior, memory bugs, and type confusion.
We enable an aggressive set of warnings and treat them all as errors.

### Compiler warnings (CMakeLists.txt)

Applied to both the library and test targets (tests get a slightly reduced set):

| Flag                     | Category      | What it catches                                                                                                                                   |
| ------------------------ | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-Wall`                  | Baseline      | Enables ~50 common warnings: unused variables, uninitialized values, format string mismatches, etc. Despite the name, this is not "all" warnings. |
| `-Wextra`                | Extended      | Adds ~20 more: unused parameters, missing field initializers, sign comparison in conditionals.                                                    |
| `-Wpedantic`             | Standards     | Flags non-standard extensions (GNU extensions, VLAs, etc.). Ensures the code is portable C++17.                                                   |
| `-Werror`                | Enforcement   | All warnings are errors. Nothing slips through.                                                                                                   |
| `-Wshadow`               | Scoping       | Variable in inner scope shadows one in outer scope. Prevents confusing bugs where you think you're modifying the outer variable.                  |
| `-Wnon-virtual-dtor`     | OOP safety    | Class with virtual methods but non-virtual destructor. Prevents undefined behavior when deleting through a base pointer.                          |
| `-Woverloaded-virtual`   | OOP safety    | Derived class hides a base class virtual function instead of overriding it.                                                                       |
| `-Wold-style-cast`       | Type safety   | C-style casts `(int)x` instead of `static_cast<int>(x)`. C++ casts are greppable and less dangerous.                                              |
| `-Wcast-align`           | Memory safety | Casts that increase alignment requirements. Can cause bus errors on strict-alignment architectures.                                               |
| `-Wunused`               | Cleanliness   | Unused functions, variables, labels, typedefs.                                                                                                    |
| `-Wconversion`           | Type safety   | Implicit conversions that may change a value: `int` to `short`, `double` to `float`, signed to unsigned.                                          |
| `-Wsign-conversion`      | Type safety   | Implicit signed/unsigned conversions. Separate from `-Wconversion` because it's even stricter.                                                    |
| `-Wnull-dereference`     | Null safety   | Warns when the compiler can prove a null pointer is dereferenced. Limited but free.                                                               |
| `-Wdouble-promotion`     | Precision     | Implicit `float` to `double` promotion. Not currently triggered but prevents future surprises.                                                    |
| `-Wformat=2`             | Security      | Stricter format string checking (includes `-Wformat-nonliteral` and `-Wformat-security`).                                                         |
| `-Wimplicit-fallthrough` | Control flow  | Switch case falls through without `[[fallthrough]]` annotation.                                                                                   |

**Additional CMake settings:**

- `CMAKE_CXX_EXTENSIONS OFF` — disables compiler-specific extensions (e.g.,
  GNU C++). Ensures the code builds with any C++17 conforming compiler.
- `CMAKE_EXPORT_COMPILE_COMMANDS ON` — generates `compile_commands.json` for
  use by clang-tidy and IDEs.

### clang-tidy (.clang-tidy)

clang-tidy performs deeper semantic analysis than compiler warnings. The
configuration enables seven check categories:

| Category              | Examples                                                                                  |
| --------------------- | ----------------------------------------------------------------------------------------- |
| `bugprone-*`          | Use-after-move, integer division, suspicious string compare, infinite loops.              |
| `clang-analyzer-*`    | Clang's static analyzer: null dereference paths, memory leaks, dead stores.               |
| `cppcoreguidelines-*` | C++ Core Guidelines enforcement: avoid raw `new/delete`, prefer `span` over pointer+size. |
| `misc-*`              | Miscellaneous: redundant expressions, suspicious semicolons, unused `using` declarations. |
| `modernize-*`         | Use C++17 features: `auto`, range-for, `nullptr`, structured bindings, `std::optional`.   |
| `performance-*`       | Unnecessary copies, moves that should be copies, inefficient string concatenation.        |
| `readability-*`       | Naming conventions, misleading indentation, redundant `else` after `return`.              |

**Disabled checks:**

| Check                                                 | Reason                                                                                                                                                                   |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `modernize-use-trailing-return-type`                  | Enforces `auto f() -> int` style. This is a stylistic preference, not a safety issue, and the codebase uses traditional return types.                                    |
| `readability-magic-numbers`                           | Age tier thresholds (3, 12, 24, 36, 84, 156, 216) are domain constants that are clearer inline than as named constants.                                                  |
| `cppcoreguidelines-avoid-magic-numbers`               | Same as above (alias).                                                                                                                                                   |
| `readability-identifier-length`                       | Short variable names (`n`, `m`, `d`, `y`) are standard in date arithmetic.                                                                                               |
| `cppcoreguidelines-pro-bounds-array-to-pointer-decay` | Would flag every string literal passed to a function. Unavoidable in idiomatic C++.                                                                                      |
| `misc-no-recursion`                                   | No recursion exists, but the check's existence in the enabled set would flag any future recursive helper. Recursion is fine for tree-structured data.                    |
| `readability-function-cognitive-complexity`           | Same reasoning as cyclomatic complexity — the formatter function is inherently branchy but linear.                                                                       |
| `bugprone-easily-swappable-parameters`                | Functions like `format_age(dob, as_of)` have two string parameters that could be swapped. The types can't distinguish them, and strong typing would be over-engineering. |
| `misc-use-anonymous-namespace`                        | Suggests replacing `static` with anonymous namespaces. Both are valid; the codebase uses `static` for internal linkage.                                                  |

**Naming conventions** are enforced via `CheckOptions`:

| Entity          | Convention                          |
| --------------- | ----------------------------------- |
| Classes         | `CamelCase`                         |
| Enums           | `CamelCase`                         |
| Functions       | `lower_case`                        |
| Variables       | `lower_case`                        |
| Private members | `lower_case_` (trailing underscore) |

The `locales::EN()` accessor functions use UPPER_CASE despite being
functions. This is a deliberate choice — these are lazy singleton accessors that
semantically behave like constants, and the naming matches every other language's
`EN` constant. clang-tidy's `readability-identifier-naming` is configured to
enforce `lower_case` for functions generally, but the locale accessor functions
in generated code are excluded from this check.

### Const correctness

The C++ implementation uses `const` at every level to prevent accidental
mutation:

- **Methods** — `format_age` and `format_stage` are `const`-qualified, so
  they cannot modify any member fields.
- **Parameters** — all function parameters that aren't modified are `const`
  references (`const std::string&`, `const AgeLocale*`).
- **Local variables** — every local variable that is assigned once and only
  read afterward is declared `const`. This covers ~25 variables across the
  implementation (date components, parsed ages, plural categories, iterators,
  computed week/month/year values).
- **Struct fields** — `AgeComponents` (the internal struct returned by
  `parse_age`) has `const` fields since instances are created via aggregate
  initialization and never modified.

Member fields (`day_`, `week_`, etc.) are intentionally *not* `const`. Making
them `const` would require restructuring the constructor for marginal gain —
the `const` method qualifiers already prevent mutation through the public API.

### What compiled clean with no changes

The C++ implementation was written with these warning flags in mind from the
start. When the flags were added to CMakeLists.txt, the entire codebase —
library and tests — compiled with **zero warnings**. This is notable because
`-Wconversion` and `-Wsign-conversion` are aggressive flags that often require
explicit casts in numeric code, and the date arithmetic in this library involves
significant integer manipulation.

---

## Java

**Tools:** Java compiler flags

**Config file:** `build.gradle.kts`

### Philosophy

Java's compiler warnings are less aggressive than Kotlin's by default, but
`-Xlint:all -Werror` enables all standard lint checks and treats them as errors.
Combined with Java 17's modern features (sealed interfaces, records, pattern
matching), the implementation achieves type safety and immutability without
external tools.

### Compiler settings

| Setting        | What it does                                                                                                      |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| `-Xlint:all`   | Enables all standard javac lint warnings: unchecked operations, deprecation, fallthrough, rawtypes, varargs, etc. |
| `-Werror`      | Treats all warnings as errors. Nothing slips through.                                                             |
| Java 17 target | Matches Kotlin's JVM target. Provides sealed interfaces, records, and pattern matching for switch.                |
| UTF-8 encoding | Explicit `options.encoding = "UTF-8"` ensures consistent handling of Unicode locale data.                         |

### What was considered but not added

- **Checkstyle/PMD/SpotBugs** — these are the Java equivalents of ESLint or
  rubocop. For a library this size, `-Xlint:all -Werror` catches the important
  issues without adding build complexity. If the implementation grows, SpotBugs
  would be the first addition.

- **Error Prone** — Google's compile-time bug checker. Excellent tool, but adds
  a dependency on the Error Prone compiler plugin. The zero-dependency philosophy
  extends to the build where practical.

### Naming

camelCase for methods and fields, PascalCase for classes and interfaces,
UPPER_CASE for enum entries and locale constants. This matches standard Java
conventions and is consistent with the Kotlin implementation's naming.

---

## Groovy

**Tools:** Groovy compiler + Java compiler flags

**Config file:** `build.gradle`, `compiler-config.groovy`

### Philosophy

Groovy is a dynamic JVM language that shares Java's toolchain. The Groovy
implementation follows the same JVM 17 target as Java, Kotlin, and Scala.
Strictness is enforced through Java compiler `-Werror` flags and Groovy's
`@Immutable` annotation for data classes.

### Compiler settings

| Setting                  | What it does                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| `-Werror`                | Treats Java compiler warnings as errors. Applied to all `GroovyCompile` tasks.              |
| `compiler-config.groovy` | Groovy compiler configuration script. Applied via `groovyOptions.configurationScript`.      |
| Java 17 target           | Matches Kotlin/Java/Scala JVM target. Provides maximum compatibility for library consumers. |
| `localGroovy()`          | Uses the Groovy runtime bundled with Gradle. Zero external dependencies.                    |

### Key patterns

- **`@Immutable` data classes** — `UnitForms`, `StageLabel`, `Stages`, `Units`,
  `CompactnessOverride` use Groovy's `@Immutable` annotation, which generates
  immutable classes with constructor, equals/hashCode, and toString.
- **Closure-based plural rules** — locale plural functions are Groovy closures
  (`{ int n -> ... }`), matching the language's idiomatic approach to lambdas.
- **Static convenience methods** — `formatAgeDefault` and `formatStageDefault`
  provide English-default access without instantiation (Groovy has no companion
  objects like Kotlin).

### What was considered but not added

- **CodeNarc** (static analyzer) — CodeNarc is the Groovy equivalent of
  Checkstyle or PMD. For a library this size, `-Werror` and Groovy's dynamic
  nature make CodeNarc less impactful than its Java counterparts. If the
  implementation grows, CodeNarc would be the first addition.

### Naming

camelCase for methods and properties, PascalCase for classes,
UPPER_CASE for enum entries and locale constants. This matches standard
Groovy/Java conventions and is consistent with the other JVM implementations.
