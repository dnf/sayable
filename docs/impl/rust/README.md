# Rust Style Guide

A reference for idiomatic Rust coding style in the Sayable project. Intended for auditing and contributing to the Rust implementation of sayable-age.

## Project constraints

These constraints override any general Rust advice that conflicts with them:

- **Zero runtime dependencies.** The `[dependencies]` section of `Cargo.toml` must remain empty.
- **`unsafe` is forbidden.** `Cargo.toml` sets `unsafe_code = "forbid"`. No `unsafe` blocks, no `unsafe fn`, no `unsafe impl`.
- **All implementations must produce identical output.** Formatting logic must match the other 28 language implementations exactly.

## Sources

This guide synthesizes conventions from:

- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) (C-CASE, C-CONV, C-COMMON-TRAITS, etc.)
- [Rust Style Guide](https://doc.rust-lang.org/nightly/style-guide/) (official formatting rules)
- [Clippy Lint Index](https://rust-lang.github.io/rust-clippy/master/index.html)
- [The Rust Programming Language](https://doc.rust-lang.org/book/) ("The Book")
- [RFC 430 -- Naming Conventions](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md)

---

## 1. Naming Conventions

### Casing Rules (C-CASE)

| Item | Convention | Example |
|---|---|---|
| Crates | `snake_case` | `sayable_age` |
| Modules | `snake_case` | `format_age` |
| Types (structs, enums) | `UpperCamelCase` | `AgeLocale`, `PluralCategory` |
| Traits | `UpperCamelCase` | `Iterator`, `Display` |
| Enum variants | `UpperCamelCase` | `Some`, `None`, `Weeks` |
| Functions | `snake_case` | `format_age` |
| Methods | `snake_case` | `as_bytes`, `to_string` |
| Local variables | `snake_case` | `birth_date`, `age_in_days` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_AGE_MONTHS`, `VERSION` |
| Statics | `SCREAMING_SNAKE_CASE` | `NOW_OVERRIDE` |
| Type parameters | Single uppercase letter or short `CamelCase` | `T`, `U`, `Item` |
| Lifetimes | Short lowercase, prefixed with `'` | `'a`, `'b`, `'src` |
| Macros | `snake_case!` | `vec!`, `println!` |
| Feature flags | `kebab-case` in Cargo.toml | `serde`, `std` |

### Acronym Handling

Treat acronyms as single words. In `UpperCamelCase`, capitalize only the first letter. In `snake_case`, lowercase the entire acronym:

```rust
// Correct
struct HttpRequest;
struct JsonParser;

// Incorrect
struct HTTPRequest;  // treat HTTP as a word: Http
struct JSONParser;   // treat JSON as a word: Json
```

### Crate Naming

Avoid `-rs` or `-rust` suffixes. The crate is already Rust:

```toml
# Correct
[package]
name = "sayable-age"

# Avoid
name = "sayable-age-rs"
```

### Conversion Method Naming (C-CONV)

| Prefix | Cost | Ownership | Example |
|---|---|---|---|
| `as_` | Free | Borrow `&self` -> borrowed view | `str::as_bytes() -> &[u8]` |
| `to_` | Expensive | Borrow `&self` -> new owned value | `str::to_lowercase() -> String` |
| `into_` | Variable | Consume `self` -> new type | `String::into_bytes() -> Vec<u8>` |
| `from_` | Variable | Static constructor | `String::from_utf8(vec) -> Result<String, ...>` |
| `try_` | Fallible | Returns `Result` or `Option` | `u8::try_from(256i32) -> Result<u8, ...>` |

### Getter Naming (C-GETTER)

Omit the `get_` prefix. Name the getter after the field:

```rust
impl Config {
    fn name(&self) -> &str { &self.name }
    fn is_active(&self) -> bool { self.active }
}
```

Boolean getters use `is_`, `has_`, or `can_` prefixes.

### Iterator Method Naming (C-ITER)

Collections should provide `iter()` (yields `&T`), `iter_mut()` (yields `&mut T`), and implement `IntoIterator` (yields `T`, consuming). Iterator type names match the method: `iter()` returns `Iter`, `iter_mut()` returns `IterMut`, `into_iter()` returns `IntoIter`.

---

## 2. Code Formatting

### rustfmt Defaults

Use `rustfmt` with default settings:

- **Indentation:** 4 spaces per level. Never tabs.
- **Maximum line width:** 100 characters (for both code and comments).
- **Trailing commas:** Always in multi-line comma-separated lists.
- **Trailing whitespace:** None.
- **Blank lines:** At most one between items and statements.

### Block Indent over Visual Indent

```rust
// Correct: block indent
a_function_call(
    foo,
    bar,
);

// Avoid: visual indent
a_function_call(foo,
                bar);
```

### Import Ordering and Grouping

Organize `use` statements in groups separated by blank lines:

1. `std` / `core` / `alloc` (standard library)
2. External crate imports (should not exist in this project)
3. `crate::` (current crate absolute paths)
4. `self::` and `super::` (relative paths)

Within each group, sort alphabetically:

```rust
use std::collections::HashMap;
use std::fmt;

use crate::locale::AgeLocale;
use crate::types::PluralCategory;
```

### Brace Style

Opening brace on the same line. Closing brace on its own line at the item's indentation level:

```rust
fn format_age(birth: &str, as_of: Option<&str>) -> Option<String> {
    // ...
}

if age_in_days < 14 {
    locale.just_born.to_string()
} else {
    format!("{} {}", count, unit)
}
```

### Function Signatures

Single-line when they fit. Multi-line with block indent and trailing comma otherwise:

```rust
// Fits on one line
fn add(a: i32, b: i32) -> i32 { a + b }

// Multi-line
fn format_age(
    birth_date: &str,
    as_of: Option<&str>,
    locale: &AgeLocale,
) -> Option<String> {
    // ...
}
```

### Where Clauses

Place `where` on a new line at the same indentation level as `fn`/`impl`. Each bound on its own line, block-indented with a trailing comma:

```rust
fn serialize<T>(value: &T) -> String
where
    T: Display + Serialize,
{
    // ...
}
```

### Comments

- Prefer line comments (`//`) over block comments (`/* */`).
- Comments should be complete sentences: capitalize the first word, end with a period.
- Doc comments use `///` (outer) or `//!` (inner, for module/crate level).
- Comments explain *why*, not *what*. If you need to explain what code does, extract it into a named function or variable.

```rust
/// Formats a human age from a date of birth and reference date.
///
/// Returns a natural-language string like "6 weeks" or "3 1/2 years".
pub fn format_age(birth: &str, as_of: Option<&str>) -> Option<String> {
    // Use whole months after 8 weeks to match how parents talk.
    let months = months_between(birth, now);
    // ...
}
```

### Derive and Attribute Formatting

Use a single `#[derive(...)]` attribute. Place each attribute on its own line above the item:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct AgeLocale {
    pub just_born: &'static str,
}
```

Derive order convention: `Debug`, `Clone`, `Copy` (if applicable), `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, `Default`.

---

## 3. Ownership and Borrowing

### Borrowing Guidelines

**Prefer borrowing over ownership when the function does not need to own the data:**

```rust
// Correct: borrows the string
fn greet(name: &str) {
    println!("Hello, {name}!");
}

// Avoid: takes ownership unnecessarily
fn greet(name: String) {
    println!("Hello, {name}!");
}
```

**Accept `&str` rather than `&String`, and `&[T]` rather than `&Vec<T>`** (C-GENERIC). The borrowed slices are more general:

```rust
// Correct: accepts any string-like type
fn word_count(text: &str) -> usize {
    text.split_whitespace().count()
}
```

### Taking Ownership

When a function needs to store data, use `impl Into<String>` to accept both owned and borrowed inputs ergonomically:

```rust
fn store_name(name: impl Into<String>) {
    let owned = name.into(); // zero-cost if caller passes String, allocates if &str
}
```

For simple internal functions where the caller always has one type, taking `String` or `&str` directly is fine.

### Lifetime Annotations

Use explicit lifetimes only when the compiler cannot infer them:

```rust
// Elision works here (one input reference, one output reference)
fn first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}

// Explicit lifetimes needed: two input references
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

Prefer short lifetime names (`'a`, `'b`) for generic code. Use descriptive names (`'src`, `'de`) when the meaning would otherwise be unclear.

### Common Lifetime Patterns

**Structs that borrow data must declare the lifetime:**

```rust
struct Excerpt<'a> {
    text: &'a str,
}
```

**The `'static` lifetime:** Use for data that lives for the entire program (string literals, constants). Do not use `'static` as an escape hatch for lifetime issues.

---

## 4. Type System

### Structs

Use structs for data with named fields. Prefer private fields with public accessors for types that enforce invariants:

```rust
// Public fields for simple data containers without invariants
pub struct Units {
    pub day: UnitForms,
    pub week: UnitForms,
    pub month: UnitForms,
    pub year: UnitForms,
}

// Private fields when validation is needed
pub struct Age {
    days: u32,
}

impl Age {
    pub fn new(days: u32) -> Self {
        Age { days }
    }

    pub fn days(&self) -> u32 {
        self.days
    }
}
```

### Enums

Use enums to represent a closed set of variants. Each variant can hold different data:

```rust
pub enum PluralCategory {
    Zero,
    One,
    Two,
    Few,
    Many,
    Other,
}

pub enum UnitForms {
    Simple(String),
    Plural(HashMap<PluralCategory, String>),
}
```

### Newtype Pattern (C-NEWTYPE)

Wrap primitive types to create distinct types the compiler enforces:

```rust
// Without newtype: easy to swap arguments
fn set_dimensions(width: u32, height: u32) { ... }

// With newtype: compiler prevents mixing
struct Width(u32);
struct Height(u32);
fn set_dimensions(width: Width, height: Height) { ... }
```

### Traits

Define traits for shared behavior. Keep traits focused on a single responsibility:

```rust
pub trait Formatter {
    fn format(&self, birth: &str, now: &str) -> Option<String>;
}
```

### Generics and Trait Bounds

Use `impl Trait` in argument position for simple cases. Use explicit generics with `where` clauses for complex ones:

```rust
// Simple: impl Trait
fn print_it(item: &impl Display) {
    println!("{item}");
}

// Complex: explicit generics
fn process<T, U>(input: T, output: &mut U)
where
    T: AsRef<str>,
    U: Write,
{
    write!(output, "{}", input.as_ref()).unwrap();
}
```

Use `impl Trait` in return position to hide concrete iterator/closure types:

```rust
fn even_numbers(limit: u32) -> impl Iterator<Item = u32> {
    (0..limit).filter(|n| n % 2 == 0)
}
```

### Associated Types vs. Generic Parameters

Use associated types when there is exactly one implementation per type. Use generic parameters when there can be multiple:

```rust
// Associated type: one output type per iterator
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}

// Generic parameter: a type can be added to many different types
trait Add<Rhs = Self> {
    type Output;
    fn add(self, rhs: Rhs) -> Self::Output;
}
```

---

## 5. Error Handling

### Result and Option

`Result<T, E>` is for operations that can fail. `Option<T>` is for values that may be absent. Do not conflate them:

```rust
// Result: operation can fail with a reason
fn parse_age(input: &str) -> Result<u32, ParseIntError> {
    input.parse()
}

// Option: value may be absent (not an error)
fn find_locale(code: &str) -> Option<&AgeLocale> {
    LOCALES.get(code)
}
```

### The ? Operator

Use `?` to propagate errors up the call stack:

```rust
fn read_config(path: &Path) -> Result<Config, Box<dyn Error>> {
    let contents = fs::read_to_string(path)?;
    let config: Config = serde_json::from_str(&contents)?;
    Ok(config)
}
```

### Custom Error Types (C-GOOD-ERR)

Define custom error types with meaningful variants. Implement `std::error::Error`, `Display`, and `Debug`. Since this project has zero dependencies, implement these traits manually (do not use `thiserror`):

```rust
use std::fmt;

#[derive(Debug)]
pub enum FormatError {
    InvalidDate { birth: String, as_of: String },
    UnknownLocale(String),
}

impl fmt::Display for FormatError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            FormatError::InvalidDate { birth, as_of } => {
                write!(f, "birth date {birth} is after reference date {as_of}")
            }
            FormatError::UnknownLocale(code) => {
                write!(f, "unknown locale: {code}")
            }
        }
    }
}

impl std::error::Error for FormatError {}
```

Error messages should be lowercase, without trailing punctuation, and without the word "error" (the context already establishes that).

### unwrap() and expect()

Do not use `unwrap()` or `expect()` on operations whose failure depends on user input or runtime state the caller controls. Return `Result` or `Option` instead.

`unwrap()` and `expect()` are acceptable when:

- **The invariant is provably upheld.** For example, `Mutex::lock().unwrap()` is standard practice because a poisoned mutex indicates a panic on another thread, and propagating the panic is correct. `UNIX_EPOCH` is guaranteed to precede `SystemTime::now()`.
- **In tests.** Tests should panic on unexpected failures.
- **In examples and prototypes.** Clarity matters more than robustness in sample code.

When using `unwrap()` or `expect()` in non-test code, add a comment explaining why the value is always `Some`/`Ok`:

```rust
// SystemTime::now() is always after UNIX_EPOCH.
let secs = SystemTime::now()
    .duration_since(UNIX_EPOCH)
    .unwrap()
    .as_secs();
```

### When to Use What

| Context | Approach |
|---|---|
| Library public API | Custom error types (manual `Display` + `Error` impls) |
| Library internals | `Result` with specific error types |
| Provably infallible operations | `unwrap()` / `expect()` with a comment |
| Tests | `unwrap()`, `expect()`, or `?` with `Result` return |
| Impossible states | `unreachable!()` |

---

## 6. Pattern Matching

### match

Use `match` for exhaustive pattern matching. The compiler verifies all cases are covered:

```rust
fn plural_category(n: u32) -> PluralCategory {
    match n {
        0 => PluralCategory::Zero,
        1 => PluralCategory::One,
        2 => PluralCategory::Two,
        3..=10 => PluralCategory::Few,
        11..=99 => PluralCategory::Many,
        _ => PluralCategory::Other,
    }
}
```

### if let and let-else

Use `if let` when you care about one variant:

```rust
if let Some(locale) = find_locale("en") {
    println!("Found: {}", locale.just_born);
}
```

Use `let-else` (Rust 1.65+) for early returns on pattern failure:

```rust
fn process(input: Option<&str>) -> Result<(), Error> {
    let Some(value) = input else {
        return Err(Error::MissingInput);
    };
    // value is now &str, not Option<&str>
    println!("{value}");
    Ok(())
}
```

### while let

Use `while let` for loops that continue while a pattern matches:

```rust
let mut stack = vec![1, 2, 3];
while let Some(top) = stack.pop() {
    println!("{top}");
}
```

### Destructuring

Destructure structs, tuples, and enums directly in patterns:

```rust
struct Point { x: f64, y: f64 }

let Point { x, y } = origin;
let (first, second, _) = triple;

match message {
    Message::Quit => println!("quit"),
    Message::Move { x, y } => println!("move to ({x}, {y})"),
    Message::Write(text) => println!("{text}"),
}
```

### Or-Patterns and Guards

Combine patterns with `|` and add conditions with match guards:

```rust
match category {
    PluralCategory::Zero | PluralCategory::One => "singular-ish",
    PluralCategory::Two => "dual",
    _ => "plural",
}

match age_in_months {
    n if n < 1 => "newborn",
    1 => "1 month",
    n if n < 24 => format!("{n} months"),
    _ => format!("{} years", age_in_months / 12),
}
```

### Formatting Match Arms

Place the arm body on the same line for short expressions. Use a block for multi-statement bodies:

```rust
match value {
    1 => "one",
    2 => "two",
    n => {
        let result = compute(n);
        format!("computed: {result}")
    }
}
```

---

## 7. Module Design

### File Layout: foo.rs over foo/mod.rs

Prefer the modern file layout. Instead of `foo/mod.rs`, use `foo.rs` alongside a `foo/` directory:

```
src/
  lib.rs
  formatter.rs              # mod formatter
  types.rs                  # mod types
  locales/                  # mod locales (generated locale files)
    mod.rs                  # re-exports all locale constants
    en.rs
    ja.rs
    ...
```

The `mod.rs` style is supported but discouraged because multiple `mod.rs` files open in an editor are hard to distinguish. The `locales/` directory is an exception: generated locale files live in a subdirectory with a `mod.rs` barrel, as required by the project's codegen system.

### Visibility

Default to private. Widen visibility only as needed:

| Modifier | Scope |
|---|---|
| (none) | Private to the current module and its children |
| `pub(crate)` | Visible within the current crate only |
| `pub(super)` | Visible to the parent module |
| `pub` | Fully public (part of the crate's API) |

```rust
pub struct AgeLocale {            // public API
    pub code: String,             // public field
    pub(crate) cache: Vec<String>, // crate-internal
}

pub(crate) fn compute_months(birth: &str, now: &str) -> i32 {
    // visible to other modules in this crate, but not to consumers
    todo!()
}
```

### Re-exports

Use `pub use` to create a clean public API from internal module structure:

```rust
// src/lib.rs
mod formatter;
mod locales;
mod types;

pub use formatter::{format_age, format_stage, SayableAge, VERSION};
pub use types::{AgeLocale, Compactness, Gender, PluralCategory, UnitForms};
```

This decouples the API surface from the file layout. Consumers import from the crate root; internal organization can change without breaking the public API.

### Module-Level Documentation

Use inner doc comments (`//!`) at the top of each module file:

```rust
//! Locale definitions for age formatting.
//!
//! Each locale provides translations for age units (days, weeks,
//! months, years), delimiters, and plural rules.

use crate::types::PluralCategory;
```

---

## 8. Iterator Patterns

### Prefer Iterators over Index Loops

Iterators are idiomatic, avoid off-by-one errors, and the compiler optimizes them aggressively:

```rust
// Idiomatic
let sum: i32 = numbers.iter().sum();

// Less idiomatic
let mut sum = 0;
for i in 0..numbers.len() {
    sum += numbers[i];
}
```

### Common Combinators

```rust
let names: Vec<&str> = people
    .iter()
    .filter(|p| p.age > 18)
    .map(|p| p.name.as_str())
    .collect();
```

| Combinator | Purpose |
|---|---|
| `map` | Transform each element |
| `filter` | Keep elements matching a predicate |
| `filter_map` | Filter and transform in one step |
| `flat_map` | Map then flatten nested iterators |
| `fold` | Accumulate into a single value |
| `collect` | Gather into a collection |
| `chain` | Concatenate two iterators |
| `zip` | Pair elements from two iterators |
| `enumerate` | Add index to each element |
| `take` / `skip` | Limit or skip elements |
| `any` / `all` | Short-circuit boolean checks |
| `find` | First matching element |

### When to Use Loops Instead

Use explicit loops when:

- You need early `break` with a value or complex control flow.
- The logic involves mutable state that is hard to express functionally.
- The iterator chain exceeds 4-5 combinators and becomes hard to follow.

### Collect with Type Annotation

Use the turbofish (`::<>`) or a type annotation when `collect` cannot infer the target type:

```rust
let names: Vec<String> = input.lines().map(String::from).collect();
let lookup: HashMap<&str, u32> = pairs.into_iter().collect();
```

### Iterator Ownership: iter() vs. into_iter()

```rust
let v = vec![1, 2, 3];

// Borrows: v is still usable after
for x in v.iter() { /* x: &i32 */ }

// Consumes: v is moved, cannot use after
for x in v.into_iter() { /* x: i32 */ }
```

---

## 9. Common Idioms

### From/Into Conversions (C-CONV-TRAITS)

Implement `From` for infallible conversions. `Into` is provided automatically via a blanket impl. Never implement `Into` or `TryInto` directly:

```rust
impl From<NaiveDate> for BirthDate {
    fn from(date: NaiveDate) -> Self {
        BirthDate(date)
    }
}

// Now both work:
let bd = BirthDate::from(date);
let bd: BirthDate = date.into();
```

For fallible conversions, implement `TryFrom`:

```rust
impl TryFrom<&str> for LocaleCode {
    type Error = ParseLocaleError;

    fn try_from(s: &str) -> Result<Self, Self::Error> {
        if is_valid_locale(s) {
            Ok(LocaleCode(s.to_string()))
        } else {
            Err(ParseLocaleError(s.to_string()))
        }
    }
}
```

### Display and Debug (C-COMMON-TRAITS)

All public types should implement `Debug`. Implement `Display` for user-facing output:

```rust
use std::fmt;

#[derive(Debug)]  // Debug via derive
pub struct AgeLocale {
    pub code: String,
    pub just_born: String,
}

impl fmt::Display for AgeLocale {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Locale({})", self.code)
    }
}
```

When a struct contains fields that cannot be derived (like function pointers), implement `Debug` manually:

```rust
impl std::fmt::Debug for AgeLocale {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("AgeLocale")
            .field("code", &self.code)
            .finish()
    }
}
```

### Default (C-COMMON-TRAITS)

Implement `Default` for types with a natural "empty" or "zero" value. When `Default` is implemented, also provide a `new()` constructor:

```rust
#[derive(Debug, Default)]
pub struct FormatterConfig {
    pub use_half: bool,
    pub max_precision: u32,
}

impl FormatterConfig {
    pub fn new() -> Self {
        Self::default()
    }
}
```

### Derive Macros

Derive standard traits eagerly. The orphan rule means you cannot implement foreign traits for foreign types later:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum PluralCategory {
    Zero,
    One,
    Two,
    Few,
    Many,
    Other,
}
```

Derive order convention: `Debug`, `Clone`, `Copy` (if applicable), `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, `Default`.

### Deref and AsRef

Only implement `Deref` for smart pointers (C-DEREF). For newtypes that are transparent wrappers where you want full access to the inner type's API, `Deref` is pragmatically acceptable. For newtypes that enforce invariants, use `AsRef` or explicit accessor methods:

```rust
// AsRef for "view as" conversions
impl AsRef<str> for LocaleCode {
    fn as_ref(&self) -> &str {
        &self.0
    }
}
```

---

## 10. Things to Avoid

### Unnecessary Clones

Do not clone to satisfy the borrow checker without understanding why. Each unnecessary clone is a hidden allocation:

```rust
// Avoid: cloning to dodge borrow issues
let name = config.name.clone();
process(&name);

// Ask: can process() just borrow from config?
process(&config.name);
```

If the borrow checker rejects code, restructure rather than sprinkling `.clone()`: reorder statements, extract into smaller functions, or use separate scopes.

### Stringly-Typed APIs (C-CUSTOM-TYPE)

Use enums and newtypes instead of raw strings or booleans for discrete values:

```rust
// Avoid: boolean parameter with unclear meaning
fn format(locale: &AgeLocale, compact: bool) { ... }

// Prefer: type-safe enum
fn format(locale: &AgeLocale, compactness: Compactness) { ... }
```

### Numeric Casts

Prefer `From`/`TryFrom` for conversions where the range is not statically guaranteed:

```rust
// Risky: silently truncates
let x = 256u32 as u8; // x is 0

// Safe: explicit conversion
let x = u8::try_from(256u32); // Err(TryFromIntError)
```

`as` casts are acceptable when the range is provably safe and the safety reasoning is documented. The project's `Cargo.toml` configures specific Clippy allows (`cast_possible_truncation`, `cast_possible_wrap`, `cast_sign_loss`) for the date arithmetic, where the value ranges are known:

```rust
// Safe: Unix timestamps fit in i64, and year values fit in i32.
let secs = duration.as_secs() as i64;
```

### Other Anti-Patterns

- **Wildcard imports in non-test, non-locale code.** The locale barrel module uses wildcard re-exports by design. Elsewhere, import specific items.
- **Ignoring warnings.** Fix all warnings. Do not use `#[allow(...)]` without a comment explaining why.
- **`String` where `&str` suffices.** Accept `&str` in function parameters unless ownership is needed.
- **Panicking in Drop implementations.** Destructors must not panic. A panic during unwinding causes an abort.
- **Returning `()` as an error type.** Always use a meaningful error type:

    ```rust
    // Avoid
    fn validate(input: &str) -> Result<(), ()> { ... }

    // Prefer
    fn validate(input: &str) -> Result<(), ValidationError> { ... }
    ```

---

## 11. Tooling

### rustfmt

Run on every save and in CI:

```bash
cargo fmt             # format all code
cargo fmt -- --check  # check without modifying (CI mode)
```

Configure via `rustfmt.toml` at the crate root. Prefer default settings:

```toml
# rustfmt.toml
edition = "2021"
max_width = 100
```

### Clippy

The official Rust linter. The project configures it in `Cargo.toml`:

```toml
[lints.clippy]
all = { level = "deny", priority = -1 }
pedantic = { level = "warn", priority = -1 }
```

Run in CI with warnings as errors:

```bash
cargo clippy -- -D warnings
```

The `Cargo.toml` includes targeted allows for lints that conflict with the codebase's needs (date arithmetic casts, locale re-exports, etc.). Each allow has a comment explaining why. Do not add new allows without justification.

### cargo test

```bash
cargo test                        # run all tests
cargo test test_format_age        # run a specific test
cargo test -- --nocapture         # show stdout during tests
cargo test --doc                  # run doc-tests only
```

### cargo doc

Generate and review documentation:

```bash
cargo doc --open                          # build and open in browser
cargo doc --document-private-items        # include private items
RUSTDOCFLAGS="-D warnings" cargo doc --no-deps  # check for broken doc links
```

### CI Pipeline

The minimum CI pipeline for this project:

```bash
cargo fmt -- --check          # formatting
cargo clippy -- -D warnings   # linting
cargo test                    # tests
cargo doc --no-deps           # documentation builds
```

Note: `cargo audit` and `cargo deny` are unnecessary because this project has zero dependencies. `cargo +nightly miri test` is unnecessary because `unsafe` is forbidden.

---

## Quick Reference Checklist

### Automated (verified by CI)

- [ ] `cargo fmt -- --check` passes
- [ ] `cargo clippy -- -D warnings` passes (includes pedantic)
- [ ] `cargo test` passes
- [ ] `cargo doc --no-deps` builds without warnings
- [ ] `unsafe_code = "forbid"` remains in `Cargo.toml`
- [ ] `[dependencies]` section remains empty

### Manual review

- [ ] All public types implement `Debug` (derived or manual)
- [ ] `Display` implemented where user-facing output is needed
- [ ] `unwrap()` / `expect()` in non-test code have comments justifying the invariant
- [ ] No unnecessary `.clone()` calls -- restructure borrows instead
- [ ] Lifetimes are explicit only when elision is insufficient
- [ ] Error types implement `std::error::Error`, `Display`, and `Debug`
- [ ] Error messages are lowercase without trailing punctuation
- [ ] Naming follows RFC 430 (snake_case functions, CamelCase types, SCREAMING_SNAKE_CASE constants)
- [ ] Getters omit the `get_` prefix
- [ ] Conversion methods follow `as_`/`to_`/`into_`/`from_` naming
- [ ] Imports are grouped (std, crate) and sorted alphabetically
- [ ] Visibility is as restricted as possible (`pub(crate)` over `pub` where feasible)
- [ ] All `#[allow(...)]` annotations have a justifying comment
- [ ] Doc comments on all public items
- [ ] `#[must_use]` on functions where ignoring the return value is likely a bug
