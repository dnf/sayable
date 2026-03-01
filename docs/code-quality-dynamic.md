# Code Quality: Dynamic Languages

Detailed configuration rationale for TypeScript, Python, Ruby, and PHP.

---

## TypeScript

**Tools:** `tsc` (compiler) + ESLint with `@typescript-eslint`

**Config files:** `tsconfig.json`, `eslint.config.js`

### Compiler strictness (tsconfig.json)

TypeScript's `"strict": true` is the baseline — it enables `strictNullChecks`,
`noImplicitAny`, `strictFunctionTypes`, and several others. On top of that, we
enable seven additional flags:

| Flag | Why |
|------|-----|
| `noUncheckedIndexedAccess` | Array element access (`arr[i]`) returns `T \| undefined` instead of `T`. This caught a real bug: `.split('-').map(Number)` destructuring assumed exactly 3 elements. The fix uses explicit indexed access with `?? 0` defaults. |
| `noFallthroughCasesInSwitch` | Prevents accidental case fallthrough. Free safety with no false positives. |
| `exactOptionalPropertyTypes` | Distinguishes `{ x?: string }` (missing) from `{ x: string \| undefined }` (present but undefined). Catches subtle bugs in locale override merging. |
| `noImplicitOverride` | Requires `override` keyword. Not currently triggered (no class inheritance) but prevents future mistakes. |
| `noPropertyAccessFromIndexSignature` | Forces bracket notation for index signatures, making dynamic access explicit. |
| `forceConsistentCasingInFileNames` | Prevents import path casing mismatches between macOS (case-insensitive) and Linux CI (case-sensitive). |
| `isolatedModules` | Ensures every file can be transpiled independently, which is required by esbuild/swc bundlers. |
| `verbatimModuleSyntax` | Requires `import type` for type-only imports. Makes the type/value boundary explicit and enables better tree-shaking. |

### ESLint (eslint.config.js)

Uses the flat config format with `@typescript-eslint/strict-type-checked` — the
strictest recommended ruleset from the TypeScript-ESLint project. This is
type-aware linting that uses the TypeScript compiler's type information.

**One override:**

- `restrict-template-expressions` is configured to `allowNumber: true`. The
  default rule forbids `${count}` in template literals because `count` might
  be `NaN` or `Infinity`. For this library, all interpolated numbers are
  validated integers from date parsing, so the rule's default is overly
  cautious.

### What was considered but not added

- **`noUncheckedSideEffectImports`** — would require explicit `import type` for
  side-effect imports. Not relevant since the library has no side-effect imports.
- **ESLint `stylistic` rules** — formatting is handled by the TypeScript
  compiler and Prettier (if used). Adding ESLint stylistic rules would create
  conflicts.

---

## Python

**Tools:** ruff (linter + formatter) + pyright (type checker)

**Config file:** `pyproject.toml`

### ruff

ruff replaces flake8, isort, pyupgrade, and several flake8 plugins in a single
fast tool. We enable 11 rule categories:

| Code | Plugin | Why |
|------|--------|-----|
| E, W | pycodestyle | Standard PEP 8 style (whitespace, indentation, line length). |
| F | pyflakes | Unused imports, undefined names, redefined variables. |
| I | isort | Import ordering. Deterministic, zero-effort. |
| N | pep8-naming | Class/function/variable naming conventions. |
| UP | pyupgrade | Flags Python 2 idioms and pre-3.10 patterns. Keeps code modern. |
| B | flake8-bugbear | Catches common bugs: mutable default arguments, `assert` in production, `except Exception`. |
| A | flake8-builtins | Prevents shadowing built-in names (`list`, `type`, `id`). |
| SIM | flake8-simplify | Suggests cleaner alternatives (e.g., `x if cond else y`). |
| TCH | flake8-type-checking | Moves type-only imports into `TYPE_CHECKING` blocks, reducing runtime import cost. |
| RUF | ruff-specific | Ruff's own rules for ambiguous Unicode, `__all__` sorting, etc. |

**Suppressed rules:**

| Rule | Reason |
|------|--------|
| RUF001 | Ambiguous Unicode characters (Cyrillic "а" vs Latin "a"). Expected in i18n locale strings with 63 languages. |
| RUF003 | Ambiguous Unicode in comments. We use EN DASH (–) in doc comments for readability. |
| SIM108 | Ternary expression suggestions. `if isinstance(x, str): ... else: ...` is more readable than a ternary when the branches are complex. |
| E501 (locale files only) | Long lines in locale data are unavoidable — a single `PluralUnit({"one": "...", "other": "...", "few": "..."})` call naturally exceeds 120 chars. |

### pyright

Set to `strict` mode — the maximum type checking level. This enforces:

- All function parameters and return types must be annotated
- No implicit `Any` types
- `reportMissingTypeStubs = false` — suppressed because this is a zero-dependency
  library; there are no third-party stubs to be missing

**What this caught:** The `Callable` import in `locale.py` was a runtime import
but only used in type annotations. pyright + ruff's TCH003 rule identified it
as a type-checking-only import, which was moved into an `if TYPE_CHECKING:`
block.

### What was considered but not added

- **ANN rules** (flake8-annotations) — redundant with pyright strict mode, which
  already enforces annotation completeness.
- **D rules** (pydocstyle) — docstring enforcement is valuable for public APIs
  but excessive for locale data files. Would require too many per-file ignores.
- **S rules** (bandit/security) — no user input, no network calls, no file I/O.
  Security linting would be pure noise for a date-formatting library.

---

## Ruby

**Tools:** RuboCop

**Config files:** `.rubocop.yml`, `Gemfile`

### Philosophy

Ruby's type system is entirely runtime, so RuboCop serves as both linter and
the closest thing to a type checker. The configuration prioritizes catching
actual mistakes while respecting Ruby's expressive idioms.

### Key settings

**`AllCops` section:**

- `TargetRubyVersion: 3.0` — minimum supported Ruby. Ensures RuboCop doesn't
  suggest syntax that requires Ruby 3.1+.
- `NewCops: enable` — automatically opt into new cops as RuboCop adds them.
  This is the proactive choice; we'd rather fix a new false positive than miss
  a new real bug.
- `SuggestExtensions: false` — disables "you should install rubocop-rspec"
  suggestions. We use Minitest, not RSpec.

**Style choices:**

| Cop | Setting | Reason |
|-----|---------|--------|
| `FrozenStringLiteralComment` | Enabled | Enforces `# frozen_string_literal: true` on every file. Immutable strings are faster and catch accidental mutation bugs. Required for Ruby 4.0 compatibility. |
| `Documentation` | Excluded for core files | Locale data files, formatter internals, and test files don't benefit from class-level documentation comments. The public API is documented in the README. |
| `HashSyntax` | `EnforcedShorthandSyntax: either` | Allows both `{ key: value }` and `{ key => value }` syntax. Locale data uses symbol keys with hash rockets for visual alignment. |
| `OneClassPerFile` | Excluded for tests | Minitest pattern uses multiple test classes per file, organized by feature. |

**Metrics thresholds:**

The formatter's `format_age` method is inherently complex — it handles seven
age tiers with locale-aware formatting, plural resolution, and half-marker
substitution. Rather than breaking it into tiny methods that would be harder to
follow, we raise the limits:

| Metric | Default | Our setting | Justification |
|--------|---------|-------------|---------------|
| `AbcSize` | 17 | 45 | The formatter does many assignments and branches but follows a linear flow. |
| `CyclomaticComplexity` | 7 | 20 | Seven age tiers = seven branches + subbranches for plural/half logic. |
| `PerceivedComplexity` | 8 | 20 | Same as cyclomatic — the tiers are simple individually. |
| `MethodLength` | 10 | 30 | The formatter method is ~25 lines. Breaking it up would scatter the tier logic. |

**Special case:**

- `Lint/StructNewOverride: Enabled: false` — RuboCop warns when a `Struct`
  field name shadows a `Struct` instance method. Our `CompactnessOverride`
  struct has a field called `compact`, which shadows `Struct#compact`. This is
  intentional — the field name matches the `Compactness::COMPACT` enum value
  and is the natural name for the concept.

### Compatibility note

RuboCop 1.85 introduced automatic plugin detection that tries to load
`rubocop-minitest`, `rubocop-rake`, and other extension gems when it detects
their corresponding libraries. This works well on Ruby 3.x in CI. On Ruby 4.0
(which extracted several stdlib gems), additional `gem` declarations may be
needed in the Gemfile to satisfy rubocop's transitive dependencies.

---

## PHP

### PHPStan

PHPStan runs at **level 9** (maximum), configured in `phpstan.neon`:

- Level 9 enables all checks including strict union type analysis
- CLDR plural range checks suppressed: `smallerOrEqual.alwaysTrue` and `notIdentical.alwaysTrue` in `Locales.php` — these are intentional CLDR-faithful range bounds that PHPStan proves redundant from prior conditions

### PHP-CS-Fixer

Configured in `.php-cs-fixer.php`:

- **PER-CS2.0** coding standard (PHP-FIG's latest)
- **Risky rules enabled** — includes rules that may change code behavior
- `native_function_invocation` — backslash-prefixes all native PHP function calls for opcache optimization
- `declare_strict_types` — enforced in every file
- `no_unused_imports` — dead import detection
- `ordered_imports` — alphabetical ordering

### PHPUnit

Configured in `phpunit.xml`:

- `failOnRisky="true"` — tests that don't assert anything fail
- `failOnWarning="true"` — PHPUnit warnings treated as failures
- `executionOrder="depends,defects"` — run dependent tests in order, failed tests first

### Language-level strictness

- `declare(strict_types=1)` in every file — no implicit type coercion
- `readonly` classes for all immutable data types (`AgeLocale`, `Stages`, `Units`, `CompactnessOverride`)
- PHP 8.1+ enums for `PluralCategory` and `Compactness` (type-safe, no magic strings)
- `final` classes — prevents inheritance of data types
- Named arguments throughout — explicit constructor parameter binding
