# Rust Style Guide

A comprehensive reference for idiomatic Rust coding style and best practices. Intended for code auditing Rust implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) (C-CASE, C-CONV, C-COMMON-TRAITS, etc.)
- [Rust Style Guide](https://doc.rust-lang.org/nightly/style-guide/) (official formatting rules)
- [Clippy Lint Index](https://rust-lang.github.io/rust-clippy/master/index.html)
- [The Rust Programming Language](https://doc.rust-lang.org/book/) ("The Book")
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust Design Patterns](https://rust-unofficial.github.io/patterns/)
- [RFC 430 — Naming Conventions](https://github.com/rust-lang/rfcs/blob/master/text/0430-finalizing-naming-conventions.md)

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
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES`, `DEFAULT_LOCALE` |
| Statics | `SCREAMING_SNAKE_CASE` | `GLOBAL_ALLOCATOR` |
| Type parameters | Single uppercase letter or short `CamelCase` | `T`, `U`, `K`, `V`, `Item` |
| Lifetimes | Short lowercase, prefixed with `'` | `'a`, `'b`, `'src`, `'de` |
| Macros | `snake_case!` | `vec!`, `println!`, `format_args!` |
| Feature flags | `kebab-case` in Cargo.toml | `serde`, `std`, `alloc` |

### Acronym Handling

Treat acronyms as single words. In `UpperCamelCase`, only capitalize the first letter. In `snake_case`, lowercase the entire acronym:

```rust
// Correct
struct HttpRequest;
struct JsonParser;
fn is_xid_start() -> bool { todo!() }

// Incorrect
struct HTTPRequest;  // treat HTTP as a word: Http
struct JSONParser;   // treat JSON as a word: Json
```

### Crate Naming

Avoid `-rs` or `-rust` suffixes in crate names. The crate is already Rust; the suffix adds noise:

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
| `as_` | Free | Borrow `&self` → borrowed view | `str::as_bytes() -> &[u8]` |
| `to_` | Expensive | Borrow `&self` → new owned value | `str::to_lowercase() -> String` |
| `into_` | Variable | Consume `self` → new type | `String::into_bytes() -> Vec<u8>` |
| `from_` | Variable | Static constructor | `String::from_utf8(vec) -> Result<String, ...>` |
| `try_` | Fallible | Returns `Result` or `Option` | `u8::try_from(256i32) -> Result<u8, ...>` |

### Getter Naming (C-GETTER)

Omit the `get_` prefix. Name the getter after the field:

```rust
impl Config {
    // Correct
    fn name(&self) -> &str { &self.name }
    fn is_active(&self) -> bool { self.active }

    // Avoid
    fn get_name(&self) -> &str { &self.name }
    fn get_is_active(&self) -> bool { self.active }
}
```

Boolean getters use `is_`, `has_`, or `can_` prefixes.

### Iterator Method Naming (C-ITER)

Collections should provide three iterator methods:

```rust
impl MyCollection<T> {
    fn iter(&self) -> Iter<'_, T> { ... }         // yields &T
    fn iter_mut(&mut self) -> IterMut<'_, T> { ... } // yields &mut T
}

impl<T> IntoIterator for MyCollection<T> {
    type Item = T;
    type IntoIter = IntoIter<T>;
    fn into_iter(self) -> IntoIter<T> { ... }      // yields T (consuming)
}
```

Iterator type names match the method: `iter()` returns `Iter`, `iter_mut()` returns `IterMut`, `into_iter()` returns `IntoIter`.

---

## 2. Code Formatting

### rustfmt Defaults

Use `rustfmt` with default settings. The official Rust style guide establishes these rules:

- **Indentation:** 4 spaces per level. Never tabs.
- **Maximum line width:** 100 characters.
- **Trailing commas:** Always use trailing commas in multi-line comma-separated lists.
- **Trailing whitespace:** None, on any line.
- **Blank lines:** Zero or one between items and statements (never two or more consecutive blank lines).

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

Organize `use` statements in groups separated by blank lines, in this order:

1. `std` / `core` / `alloc` (standard library)
2. External crate imports
3. `crate::` (current crate absolute paths)
4. `self::` and `super::` (relative paths)

Within each group, sort alphabetically. Always use `self` and `super` first within a brace group:

```rust
use std::collections::HashMap;
use std::fmt;

use chrono::NaiveDate;
use serde::{Deserialize, Serialize};

use crate::locale::AgeLocale;
use crate::types::PluralCategory;
```

### Brace Style

Opening brace on the same line as the item declaration (K&R / Rust style). Closing brace on its own line at the item's indentation level:

```rust
fn format_age(birth: NaiveDate, now: NaiveDate) -> String {
    // ...
}

struct AgeLocale {
    just_born: &'static str,
    delimiter: &'static str,
}

if age_in_days < 14 {
    locale.just_born.to_string()
} else {
    format!("{} {}", count, unit)
}
```

### Function Signatures

Single-line when they fit within the line limit. Multi-line with block indent otherwise:

```rust
// Fits on one line
fn add(a: i32, b: i32) -> i32 { a + b }

// Multi-line: block indent, trailing comma
fn format_age(
    birth_date: NaiveDate,
    as_of: NaiveDate,
    locale: &AgeLocale,
) -> String {
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

impl<T> Formatter for Container<T>
where
    T: Display + Clone,
{
    // ...
}
```

### Comments

- Prefer line comments (`//`) over block comments (`/* */`).
- Comments should be complete sentences: capitalize the first word, end with a period.
- Doc comments use `///` (outer) or `//!` (inner, for module/crate level only).
- Line comments should not exceed 80 characters (excluding indentation) or the max line width, whichever is smaller.
- Comments explain *why*, not *what*. If you need to explain what code does, extract it into a named function or variable.

```rust
/// Formats a human age from a date of birth and reference date.
///
/// Returns a natural-language string like "6 weeks" or "3 1/2 years".
pub fn format_age(birth: NaiveDate, now: NaiveDate) -> String {
    // Use whole months after 8 weeks to match how parents talk.
    let months = months_between(birth, now);
    // ...
}
```

### Derive and Attribute Formatting

Use a single `#[derive(...)]` attribute. Place each attribute on its own line above the item:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
#[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
pub struct AgeLocale {
    pub just_born: &'static str,
}
```

---

## 3. Ownership and Borrowing

### The Three Rules of Ownership

1. Each value has exactly one owner.
2. When the owner goes out of scope, the value is dropped.
3. There can be either one mutable reference or any number of immutable references at a time, but not both.

### Borrowing Guidelines

**Prefer borrowing over ownership when the function does not need to own the data:**

```rust
// Correct: borrows the string, does not need ownership
fn greet(name: &str) {
    println!("Hello, {name}!");
}

// Avoid: takes ownership unnecessarily
fn greet(name: String) {
    println!("Hello, {name}!");
}
```

**Accept `&str` rather than `&String`, and `&[T]` rather than `&Vec<T>`** (C-GENERIC). The borrowed slices are more general because `String` derefs to `str` and `Vec<T>` derefs to `[T]`:

```rust
// Correct: accepts any string-like type
fn word_count(text: &str) -> usize {
    text.split_whitespace().count()
}

// Avoid: unnecessarily restrictive
fn word_count(text: &String) -> usize {
    text.split_whitespace().count()
}
```

### Clone vs. Borrow (C-CALLER-CONTROL)

Let the caller decide when to clone. If a function needs ownership, take ownership explicitly rather than accepting a reference and cloning internally:

```rust
// Correct: caller decides when to clone
fn store_name(name: String) {
    // owns the string
}

// Avoid: hidden clone inside the function
fn store_name(name: &str) {
    let owned = name.to_string(); // caller cannot avoid this allocation
}
```

### Lifetime Annotations

Use explicit lifetimes only when the compiler cannot infer them. For simple cases, lifetime elision handles it:

```rust
// Elision works here (one input reference, one output reference)
fn first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}

// Explicit lifetimes needed: two input references, must specify which
// the output borrows from
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

Prefer short lifetime names (`'a`, `'b`) for generic code. Use descriptive names (`'src`, `'de`, `'input`) when the meaning would otherwise be unclear.

### Common Lifetime Patterns

**Structs that borrow data must declare the lifetime:**

```rust
struct Excerpt<'a> {
    text: &'a str,
}

impl<'a> Excerpt<'a> {
    fn new(text: &'a str) -> Self {
        Excerpt { text }
    }
}
```

**The `'static` lifetime:** Use for data that lives for the entire program (string literals, leaked allocations). Do not use `'static` as an escape hatch for lifetime issues.

---

## 4. Type System

### Structs

Use structs for data with named fields. Prefer private fields with public accessors for types that enforce invariants:

```rust
// Public fields for simple data containers without invariants
pub struct Point {
    pub x: f64,
    pub y: f64,
}

// Private fields when validation is needed (C-STRUCT-PRIVATE)
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

pub enum AgeStage {
    JustBorn,
    Weeks(u32),
    Months { count: u32, half: bool },
    Years { count: u32, half: bool },
}
```

### Newtype Pattern (C-NEWTYPE)

Wrap primitive types to create distinct types that the compiler enforces:

```rust
// Without newtype: easy to swap arguments
fn set_dimensions(width: u32, height: u32) { ... }

// With newtype: compiler prevents mixing them up
struct Width(u32);
struct Height(u32);
fn set_dimensions(width: Width, height: Height) { ... }
```

### Traits

Define traits for shared behavior. Keep traits focused on a single responsibility:

```rust
pub trait Formatter {
    fn format(&self, birth: NaiveDate, now: NaiveDate) -> String;
}

// Provide default implementations when sensible
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}
```

### Generics and Trait Bounds

Use generics to write flexible code. Prefer `impl Trait` in argument position for simple cases and explicit generics for complex ones:

```rust
// Simple: impl Trait (C-GENERIC)
fn print_it(item: &impl Display) {
    println!("{item}");
}

// Complex: explicit generics with where clause
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

### PhantomData

Use `PhantomData<T>` when a struct is logically parameterized by `T` but does not physically contain `T`. Common in type-state patterns and FFI wrappers:

```rust
use std::marker::PhantomData;

struct Locked;
struct Unlocked;

struct Door<State> {
    _state: PhantomData<State>,
}

impl Door<Locked> {
    fn unlock(self) -> Door<Unlocked> {
        Door { _state: PhantomData }
    }
}

impl Door<Unlocked> {
    fn lock(self) -> Door<Locked> {
        Door { _state: PhantomData }
    }

    fn open(&self) {
        println!("Door is open");
    }
}
```

---

## 5. Error Handling

### Result and Option

`Result<T, E>` is for operations that can fail. `Option<T>` is for values that may or may not exist. Do not conflate them:

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

Use `?` to propagate errors up the call stack. It replaces verbose `match` blocks:

```rust
fn read_config(path: &Path) -> Result<Config, Box<dyn Error>> {
    let contents = fs::read_to_string(path)?;
    let config: Config = serde_json::from_str(&contents)?;
    Ok(config)
}
```

### Custom Error Types (C-GOOD-ERR)

Define custom error types with meaningful variants. Implement `std::error::Error`, `Display`, and `Debug`:

```rust
use std::fmt;

#[derive(Debug)]
pub enum FormatError {
    InvalidDate { birth: NaiveDate, as_of: NaiveDate },
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

### thiserror and anyhow

For library code, use [`thiserror`](https://docs.rs/thiserror) to reduce boilerplate in custom error types:

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum FormatError {
    #[error("birth date {birth} is after reference date {as_of}")]
    InvalidDate { birth: NaiveDate, as_of: NaiveDate },

    #[error("unknown locale: {0}")]
    UnknownLocale(String),
}
```

For application code (binaries, CLI tools), use [`anyhow`](https://docs.rs/anyhow) for ergonomic error handling without defining custom types:

```rust
use anyhow::{Context, Result};

fn main() -> Result<()> {
    let config = read_config("config.toml")
        .context("failed to read configuration")?;
    Ok(())
}
```

### When to Use What

| Context | Approach |
|---|---|
| Library public API | Custom error types (or `thiserror`) |
| Library internals | `Result` with specific error types |
| Application/binary | `anyhow::Result` for convenience |
| Prototype/example | `unwrap()` / `expect()` with a reason |
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

Use `if let` when you care about one variant and want to ignore the rest:

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

### Or-Patterns

Combine patterns with `|`:

```rust
match category {
    PluralCategory::Zero | PluralCategory::One => "singular-ish",
    PluralCategory::Two => "dual",
    _ => "plural",
}
```

### Guards

Use match guards for additional conditions:

```rust
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

Prefer the modern file layout. Instead of `foo/mod.rs`, use `foo.rs` alongside a `foo/` directory for submodules:

```
src/
  lib.rs
  formatter.rs              # mod formatter
  formatter/
    locale.rs               # mod formatter::locale
    types.rs                # mod formatter::types
```

```rust
// src/lib.rs
mod formatter;
pub use formatter::format_age;

// src/formatter.rs
mod locale;
mod types;
pub use types::AgeLocale;
```

The `mod.rs` style is still supported but discouraged because multiple `mod.rs` files open in an editor are hard to distinguish.

### Visibility

Default to private. Widen visibility only as needed:

| Modifier | Scope |
|---|---|
| (none) | Private to the current module and its children |
| `pub(crate)` | Visible within the current crate only |
| `pub(super)` | Visible to the parent module |
| `pub(in path)` | Visible within a specific ancestor module |
| `pub` | Fully public (part of the crate's API) |

```rust
pub struct AgeLocale {            // public API
    pub just_born: &'static str,  // public field
    pub(crate) cache: Vec<String>, // crate-internal
}

pub(crate) fn compute_months(birth: NaiveDate, now: NaiveDate) -> u32 {
    // visible to other modules in this crate, but not to consumers
    todo!()
}
```

### Re-exports

Use `pub use` to create a clean public API from internal module structure. This decouples the API surface from the file layout:

```rust
// src/lib.rs
mod formatter;
mod locale;
mod types;

pub use formatter::format_age;
pub use locale::AgeLocale;
pub use types::PluralCategory;
```

### Prelude Pattern

For crates with many commonly-used types, provide an optional prelude module:

```rust
// src/prelude.rs
pub use crate::AgeLocale;
pub use crate::PluralCategory;
pub use crate::format_age;

// Consumer usage
use sayable_age::prelude::*;
```

Use this sparingly. Glob imports reduce readability when overused.

### Module-Level Documentation

Use inner doc comments (`//!`) at the top of each module file:

```rust
//! Locale definitions for age formatting.
//!
//! Each locale provides translations for age units (days, weeks,
//! months, years), delimiters, and plural rules.

use crate::types::PluralCategory;
// ...
```

---

## 8. Iterator Patterns

### Prefer Iterators over Index Loops

Iterators are idiomatic, avoid off-by-one errors, and the compiler optimizes them aggressively (zero-cost abstractions):

```rust
// Idiomatic: iterator
let sum: i32 = numbers.iter().sum();

// Less idiomatic: index loop
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

| Combinator | Purpose | Example |
|---|---|---|
| `map` | Transform each element | `.map(\|x\| x * 2)` |
| `filter` | Keep elements matching a predicate | `.filter(\|x\| x > &0)` |
| `filter_map` | Filter and transform in one step | `.filter_map(\|x\| x.parse().ok())` |
| `flat_map` | Map then flatten nested iterators | `.flat_map(\|x\| x.children())` |
| `fold` | Accumulate into a single value | `.fold(0, \|acc, x\| acc + x)` |
| `collect` | Gather into a collection | `.collect::<Vec<_>>()` |
| `chain` | Concatenate two iterators | `a.iter().chain(b.iter())` |
| `zip` | Pair elements from two iterators | `keys.iter().zip(values.iter())` |
| `enumerate` | Add index to each element | `.enumerate()` yields `(usize, T)` |
| `take` / `skip` | Limit or skip elements | `.take(5)`, `.skip(3)` |
| `any` / `all` | Short-circuit boolean checks | `.any(\|x\| x > 100)` |
| `find` | First matching element | `.find(\|x\| x.name == "en")` |
| `position` | Index of first match | `.position(\|x\| x == target)` |
| `peekable` | Lookahead without consuming | `.peekable()` then `.peek()` |

### When to Use Loops Instead

Use explicit loops when:

- You need early `break` with a value or complex control flow.
- The logic involves mutable state that is hard to express functionally.
- The iterator chain becomes deeply nested and hard to read (more than 4-5 combinators).

```rust
// A loop is clearer here: complex early-exit logic
let mut result = None;
for item in &items {
    if let Some(value) = item.try_compute() {
        if value.is_valid() {
            result = Some(value);
            break;
        }
    }
}
```

### Collect with Type Annotation

Use the turbofish (`::<>`) or a type annotation when `collect` cannot infer the target type:

```rust
// Turbofish on collect
let names: Vec<String> = input.lines().map(String::from).collect();

// Or let the binding type drive inference
let lookup: HashMap<&str, u32> = pairs.into_iter().collect();
```

### Iterator Ownership: iter() vs. into_iter()

```rust
let v = vec![1, 2, 3];

// Borrows: v is still usable after
for x in v.iter() { /* x: &i32 */ }

// Consumes: v is moved, cannot use after
for x in v.into_iter() { /* x: i32 */ }
// v is gone here

// Mutable borrows
for x in v.iter_mut() { /* x: &mut i32 */ }
```

---

## 9. Common Idioms

### From/Into Conversions (C-CONV-TRAITS)

Implement `From` for infallible conversions. `Into` is provided automatically via a blanket impl:

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

Never implement `Into` or `TryInto` directly; they have blanket impls based on `From` and `TryFrom`.

### Display and Debug (C-COMMON-TRAITS, C-DEBUG)

Implement `Display` for user-facing output and `Debug` for developer-facing output. All public types should implement `Debug`:

```rust
use std::fmt;

#[derive(Debug)]  // Debug via derive
pub struct AgeLocale {
    pub code: &'static str,
    pub just_born: &'static str,
}

impl fmt::Display for AgeLocale {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Locale({})", self.code)
    }
}
```

### Default (C-COMMON-TRAITS)

Implement `Default` for types with a natural "empty" or "zero" value. When `Default` is implemented, also provide a `new()` constructor that does the same thing:

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

### Builder Pattern (C-BUILDER)

Use the builder pattern for types with many optional parameters:

```rust
pub struct QueryBuilder {
    locale: String,
    max_age: Option<u32>,
    include_half: bool,
}

impl QueryBuilder {
    pub fn new(locale: impl Into<String>) -> Self {
        QueryBuilder {
            locale: locale.into(),
            max_age: None,
            include_half: true,
        }
    }

    pub fn max_age(mut self, age: u32) -> Self {
        self.max_age = Some(age);
        self
    }

    pub fn include_half(mut self, include: bool) -> Self {
        self.include_half = include;
        self
    }

    pub fn build(self) -> Query {
        Query {
            locale: self.locale,
            max_age: self.max_age.unwrap_or(150),
            include_half: self.include_half,
        }
    }
}

// Usage
let query = QueryBuilder::new("en")
    .max_age(100)
    .include_half(false)
    .build();
```

### Type-State Pattern

Use zero-sized types and generics to encode state transitions at compile time:

```rust
struct Draft;
struct Published;

struct Article<State> {
    title: String,
    body: String,
    _state: PhantomData<State>,
}

impl Article<Draft> {
    fn publish(self) -> Article<Published> {
        Article {
            title: self.title,
            body: self.body,
            _state: PhantomData,
        }
    }
}

impl Article<Published> {
    fn url(&self) -> String {
        format!("/articles/{}", self.title)
    }
}
// article.url() only compiles if the article has been published
```

### Derive Macros

Derive standard traits eagerly. The Rust orphan rule means you cannot implement traits for types defined in other crates, so derive early (C-COMMON-TRAITS):

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct LocaleCode(String);

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

Derive order convention: `Debug`, `Clone`, `Copy` (if applicable), `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`, `Default`, then third-party derives like `Serialize`, `Deserialize`.

### Deref and AsRef

Only implement `Deref` for smart pointers (C-DEREF). Use `AsRef` for lightweight borrowing conversions:

```rust
// Correct: AsRef for "view as" conversions
impl AsRef<str> for LocaleCode {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

// Incorrect: Deref for non-smart-pointer types
// Do not do this — it makes the API confusing
impl Deref for LocaleCode {
    type Target = str;
    fn deref(&self) -> &str { &self.0 }
}
```

---

## 10. Things to Avoid

### unwrap() and expect() in Library Code

Never use `unwrap()` or `expect()` in library code. Return `Result` or `Option` to let the caller decide how to handle errors:

```rust
// Avoid in library code
fn get_locale(code: &str) -> &AgeLocale {
    LOCALES.get(code).unwrap() // panics on unknown locale
}

// Correct: return Option
fn get_locale(code: &str) -> Option<&AgeLocale> {
    LOCALES.get(code)
}

// Or return Result with context
fn get_locale(code: &str) -> Result<&AgeLocale, FormatError> {
    LOCALES.get(code).ok_or_else(|| FormatError::UnknownLocale(code.into()))
}
```

Reserve `unwrap()` and `expect()` for tests, examples, and cases where you can prove the value is always `Some`/`Ok` (and add a comment explaining why).

### Unnecessary Clones

Do not clone to satisfy the borrow checker without understanding why. Each unnecessary clone is a hidden allocation:

```rust
// Avoid: cloning to dodge borrow issues
let name = config.name.clone();
process(&name);

// Ask: can process() just borrow from config?
process(&config.name);
```

If the borrow checker rejects code, restructure the code rather than sprinkling `.clone()`. Common fixes: reorder statements, extract into smaller functions, or use separate scopes.

### Stringly-Typed APIs (C-CUSTOM-TYPE)

Use enums and newtypes instead of raw strings or booleans for discrete values:

```rust
// Avoid: stringly-typed
fn format(locale: &str, use_half: bool) { ... }
format("en", true);

// Prefer: type-safe
fn format(locale: Locale, precision: Precision) { ... }
format(Locale::English, Precision::Half);
```

### Arc<Mutex<T>> Overuse

`Arc<Mutex<T>>` is a code smell in many contexts. Before reaching for it:

1. Can the data be passed by value or reference instead of shared?
2. Can the architecture be restructured to avoid shared mutable state?
3. Is message passing (channels) more appropriate?
4. Would `RwLock` (for read-heavy workloads) or atomics (for simple counters) suffice?

```rust
// Smell: wrapping everything in Arc<Mutex>
let state = Arc::new(Mutex::new(AppState::new()));

// Better: use channels for message passing
let (tx, rx) = mpsc::channel();
// Or restructure to avoid shared state entirely
```

### Premature Use of unsafe

Never use `unsafe` without a clear, documented safety invariant. Every `unsafe` block should have a `// SAFETY: ...` comment explaining why the invariant holds:

```rust
// Correct: documented safety invariant
let value = unsafe {
    // SAFETY: we checked that index < len on the line above,
    // so this access is within bounds.
    *slice.get_unchecked(index)
};

// Avoid: unexplained unsafe
let value = unsafe { *slice.get_unchecked(index) };
```

### Other Anti-Patterns

- **Wildcard imports in non-test code.** Use `use crate::prelude::*` sparingly. Elsewhere, import specific items for clarity.
- **Complex type aliases hiding ownership.** `type Result<T> = std::result::Result<T, MyError>` in a module is fine. Deeply nested aliases are not.
- **Ignoring warnings.** Fix all warnings. Do not use `#[allow(...)]` without a comment explaining why.
- **Using `as` for numeric casts.** Prefer `From`/`TryFrom` for safe conversions. `as` silently truncates:

    ```rust
    // Risky: silently truncates
    let x = 256u32 as u8; // x is 0

    // Safe: explicit conversion
    let x = u8::try_from(256u32); // Err(TryFromIntError)
    ```

- **`String` where `&str` suffices.** Accept `&str` in function parameters unless ownership is needed.
- **Panicking in Drop implementations.** Destructors must not panic (C-DTOR-FAIL). A panic during unwinding causes an abort.
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

The standard code formatter. Run it on every save and in CI:

```bash
# Format all code
cargo fmt

# Check formatting without modifying (CI mode)
cargo fmt -- --check
```

Configure via `rustfmt.toml` at the crate root. Prefer default settings. Common overrides:

```toml
# rustfmt.toml
edition = "2021"
max_width = 100
use_small_heuristics = "Default"
```

### Clippy

The official Rust linter with 800+ lints across these categories:

| Category | Default Level | Purpose |
|---|---|---|
| `correctness` | deny | Code that is objectively wrong |
| `suspicious` | warn | Patterns that are likely bugs |
| `style` | warn | Non-idiomatic code |
| `complexity` | warn | Unnecessarily complicated code |
| `perf` | warn | Performance anti-patterns |
| `pedantic` | allow | Stricter quality guidelines |
| `nursery` | allow | Experimental lints, may have false positives |
| `restriction` | allow | Project-specific opt-in rules |

Run Clippy in CI with warnings as errors:

```bash
# Standard run
cargo clippy

# CI: deny all warnings
cargo clippy -- -D warnings

# Enable pedantic lints (recommended for quality-focused projects)
cargo clippy -- -W clippy::pedantic
```

Notable lints to be aware of:

```rust
// clippy::unwrap_used — flags unwrap() calls
// clippy::expect_used — flags expect() calls
// clippy::clone_on_ref_ptr — flags Arc/Rc clone via method syntax
// clippy::cast_lossless — suggests u64::from(x) over x as u64
// clippy::needless_pass_by_value — suggests borrowing instead of owning
// clippy::manual_map — suggests map() over if-let-some-wrap
// clippy::redundant_closure — suggests function pointer over closure
```

Configure lint levels in `Cargo.toml` or at the crate root:

```rust
// In lib.rs or main.rs
#![warn(clippy::pedantic)]
#![allow(clippy::module_name_repetitions)] // with justification
```

### cargo audit

Scans dependencies for known security vulnerabilities. Run periodically and in CI:

```bash
# Install
cargo install cargo-audit

# Run
cargo audit
```

### cargo deny

Comprehensive dependency linter. Checks licenses, bans specific crates, detects duplicate versions, and audits for vulnerabilities:

```bash
# Install
cargo install cargo-deny

# Run all checks
cargo deny check

# Run specific checks
cargo deny check licenses
cargo deny check bans
cargo deny check advisories
```

Configure via `deny.toml`:

```toml
# deny.toml
[licenses]
allow = ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause"]

[bans]
multiple-versions = "warn"
```

### Miri

An interpreter for Rust's mid-level intermediate representation (MIR). Detects undefined behavior in unsafe code:

```bash
# Install via rustup
rustup +nightly component add miri

# Run tests under Miri
cargo +nightly miri test
```

Miri catches:
- Use-after-free and out-of-bounds access
- Invalid use of uninitialized data
- Violation of aliasing rules (Stacked Borrows)
- Data races (when using `-Zmiri-disable-isolation`)
- Memory leaks

Use it for any crate that contains `unsafe` code.

### cargo test

```bash
# Run all tests
cargo test

# Run a specific test
cargo test test_format_age

# Run tests with output displayed
cargo test -- --nocapture

# Run only doc-tests
cargo test --doc

# Run ignored tests
cargo test -- --ignored
```

### cargo doc

Generate and review documentation:

```bash
# Build docs and open in browser
cargo doc --open

# Build docs with private items visible
cargo doc --document-private-items

# Check for broken doc links (CI)
RUSTDOCFLAGS="-D warnings" cargo doc --no-deps
```

### Summary: CI Pipeline

A minimal CI pipeline for a Rust project:

```bash
cargo fmt -- --check          # formatting
cargo clippy -- -D warnings   # linting
cargo test                    # tests
cargo doc --no-deps           # documentation builds
cargo audit                   # vulnerability scan
```

---

## Quick Reference Checklist

For auditing a Rust implementation, verify:

- [ ] `cargo fmt -- --check` passes with no changes
- [ ] `cargo clippy -- -D warnings` passes with no warnings
- [ ] All public types implement `Debug`
- [ ] `Display` implemented where user-facing output is needed
- [ ] No `unwrap()` or `expect()` in library code (only in tests)
- [ ] Functions accept `&str` instead of `&String`, `&[T]` instead of `&Vec<T>`
- [ ] `From` implemented instead of `Into`; `TryFrom` instead of `TryInto`
- [ ] Error types implement `std::error::Error`, `Display`, and `Debug`
- [ ] Error messages are lowercase without trailing punctuation
- [ ] No unnecessary `.clone()` calls
- [ ] Lifetimes are explicit only when elision is insufficient
- [ ] `unsafe` blocks have `// SAFETY:` comments
- [ ] Numeric conversions use `From`/`TryFrom`, not `as`
- [ ] Imports are grouped (std, external, crate) and sorted alphabetically
- [ ] Naming follows RFC 430 (snake_case functions, CamelCase types, SCREAMING_SNAKE_CASE constants)
- [ ] Getters omit the `get_` prefix
- [ ] Conversion methods follow `as_`/`to_`/`into_`/`from_` naming
- [ ] Acronyms are treated as words (`HttpRequest`, not `HTTPRequest`)
- [ ] Structs with invariants have private fields and constructors
- [ ] No `Deref` on non-smart-pointer types
- [ ] Module file layout uses `foo.rs` over `foo/mod.rs`
- [ ] Visibility is as restricted as possible (`pub(crate)` over `pub` where feasible)
- [ ] All `#[allow(...)]` annotations have a justifying comment
- [ ] Doc comments on all public items with examples
- [ ] `#[must_use]` on functions where ignoring the return value is likely a bug
