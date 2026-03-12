# Gleam Style Guide

Style conventions and best practices for Gleam code in this project. This guide covers project-specific decisions and opinionated choices; for general Gleam syntax, see the [Language Tour](https://tour.gleam.run/everything/).

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Imports](#3-imports)
4. [Type System](#4-type-system)
5. [Pattern Matching](#5-pattern-matching)
6. [Error Handling](#6-error-handling)
7. [Control Flow with `use`](#7-control-flow-with-use)
8. [Functional Patterns](#8-functional-patterns)
9. [Data Modeling](#9-data-modeling)
10. [API Design](#10-api-design)
11. [Things to Avoid](#11-things-to-avoid)
12. [Tooling](#12-tooling)
13. [References](#13-references)

---

## 1. Naming Conventions

### Functions, variables, and constants: `snake_case`

All function names, variable bindings, and module-level constants use lowercase with underscores. Unlike many languages, constants are `snake_case`, not `SCREAMING_SNAKE_CASE`.

```gleam
let user_name = "Alice"
const max_retries = 3
const default_name = "world"

fn calculate_total(unit_price: Float, quantity: Int) -> Float {
  unit_price *. int.to_float(quantity)
}
```

### Types and constructors: `PascalCase`

Custom type names and their constructors are the only place PascalCase appears in Gleam.

```gleam
pub type Season {
  Spring
  Summer
  Autumn
  Winter
}

pub type HttpError {
  NotFound
  Unauthorized(reason: String)
  ServerError(code: Int, message: String)
}
```

### Modules: `snake_case` path segments

Module names are derived from the file path relative to `src/`. There is no explicit module declaration.

```
src/my_app.gleam              -> module: my_app
src/my_app/http_client.gleam  -> module: my_app/http_client
```

### Discard variables: prefix with `_`

Unused variables must be prefixed with `_` to suppress compiler warnings. The name after `_` is documentation for the reader. A bare `_` discards without naming.

```gleam
let _unused = expensive_computation()
let #(_first, second, _third) = triple

case value {
  #(_, second) -> second
}
```

### Test functions: suffix with `_test`

Any public function in the `test/` directory whose name ends in `_test` is automatically run by `gleeunit`.

```gleam
pub fn addition_test() {
  add(1, 2) |> should.equal(3)
}
```

---

## 2. Code Formatting

### `gleam format` is authoritative

All code must be formatted with `gleam format`. It is the single, non-configurable formatter. No options, no configuration files. Run it before every commit.

```sh
gleam format           # Format all .gleam files in src/ and test/
gleam format --check   # Check without modifying (CI)
```

### Indentation and line length

The formatter uses 2-space indentation. It targets 80 columns but will not break all long lines. Long expressions in locale data or generated code are acceptable.

### Pipeline formatting

Multi-line pipelines place each step on its own line with `|>` at the start. The formatter enforces this.

```gleam
"Hello, Mike!"
|> string.drop_end(1)
|> string.drop_start(7)
|> string.uppercase
|> io.println
```

### Function call wrapping and trailing commas

When arguments do not fit on one line, each goes on its own line indented by 2 spaces. The formatter adds trailing commas to multi-line argument lists, record fields, and list literals.

```gleam
pub fn format_age(
  locale: AgeLocale,
  compactness: Compactness,
  dob: String,
  as_of: String,
) -> Result(String, Nil) {
  // ...
}
```

---

## 3. Imports

### Qualified imports are the default

Qualified access via the module name is the preferred style. It makes the origin of every function explicit.

```gleam
import gleam/int
import gleam/string
import gleam/list

pub fn format_items(items: List(Int)) -> String {
  items
  |> list.map(int.to_string)
  |> string.join(", ")
}
```

### Unqualified imports: types and constructors only

Import types and constructors unqualified when they appear in type annotations or pattern matching. Keep functions qualified.

```gleam
import gleam/option.{type Option, None, Some}
import sayableage/types.{type AgeLocale, type Gender, Female, Male}

fn describe(opt: Option(String)) -> String {
  case opt {
    Some(value) -> value
    None -> "nothing"
  }
}
```

Import types with the `type` keyword prefix:

```gleam
import gleam/string_tree.{type StringTree}
```

### Module aliases

Use `as` to shorten long module paths. Choose meaningful short names.

```gleam
import gleam/string_tree as st
import my_app/database/queries as db
```

### Import ordering

Separate imports into three groups with blank lines between them. Sort alphabetically within each group.

1. Standard library (`gleam/*`)
2. External packages
3. Project modules

```gleam
import gleam/int
import gleam/list
import gleam/string

import gleeunit/should

import sayableage/formatter
import sayableage/types.{type AgeLocale}
```

The formatter does not enforce import ordering, so this convention must be followed manually and enforced in code review.

---

## 4. Type System

### Custom types

Custom types are the primary data modeling tool, replacing enums, structs, and tagged unions from other languages. Every custom type has one or more constructors.

```gleam
// Enum-like: constructors with no fields
pub type Direction {
  North
  South
  East
  West
}

// Record-like: single constructor with named fields
pub type Person {
  Person(name: String, age: Int)
}

// Sum type: multiple constructors, some with data
pub type Shape {
  Circle(radius: Float)
  Rectangle(width: Float, height: Float)
  Point
}
```

### Type aliases

Type aliases create alternate names for existing types. They provide no additional type safety and do not create new types. Use them sparingly for readability in complex signatures.

```gleam
pub type Headers = List(#(String, String))
```

### Generics

Generic type parameters use lowercase names. Short names (`a`, `b`, `e`) for abstract parameters; descriptive names for domain-specific ones.

```gleam
fn identity(x: a) -> a {
  x
}

fn map(result: Result(a, e), fun: fn(a) -> b) -> Result(b, e) {
  case result {
    Ok(value) -> Ok(fun(value))
    Error(reason) -> Error(reason)
  }
}
```

### Opaque types

`pub opaque type` exports the type name but hides its constructors. External modules cannot construct or pattern-match on opaque values. Use opaque types to enforce invariants.

```gleam
pub opaque type PositiveInt {
  PositiveInt(inner: Int)
}

pub fn new(n: Int) -> Result(PositiveInt, String) {
  case n > 0 {
    True -> Ok(PositiveInt(n))
    False -> Error("Must be positive")
  }
}

pub fn value(p: PositiveInt) -> Int {
  p.inner
}
```

### Visibility defaults

Functions, types, and constants are private by default. Use `pub` to export. For types, `pub type` exports both the type and its constructors; `pub opaque type` exports only the type name.

```gleam
fn helper() -> Int { 42 }           // Private
pub fn api_function() -> Int { helper() }  // Public
```

### No null, no exceptions

Gleam has no null and no exception system. Optional values use `Option(a)` from `gleam/option` (constructors: `Some(a)` and `None`). Fallible operations use `Result(ok, error)` (constructors: `Ok(ok)` and `Error(error)`). Both are enforced at the type level with no escape hatches.

### `Option` vs `Result(_, Nil)` in this project

`Option(a)` and `Result(a, Nil)` are structurally similar but semantically distinct. In this project, optional fields use `Result(value, Nil)` rather than `Option` because it composes directly with `result.try` and `use` expressions without requiring `option.to_result` conversions. This is visible in the `CompactnessOverride` type where every field is `Result(UnitForms, Nil)` or `Result(String, Nil)`.

Follow this convention: use `Result(_, Nil)` for optional data that participates in result chains. Use `Option` when interfacing with external libraries that expect it.

---

## 5. Pattern Matching

### Exhaustive matching preferred

The compiler enforces exhaustive pattern matching. Prefer handling all constructors explicitly over using wildcard `_` catch-alls. Wildcards suppress exhaustiveness checking -- when a new constructor is added to a type, a wildcard silently swallows it instead of producing a compile error.

```gleam
// Preferred: all constructors handled explicitly
case direction {
  North -> #(0, 1)
  South -> #(0, -1)
  East -> #(1, 0)
  West -> #(-1, 0)
}

// Acceptable: wildcards for numeric ranges or genuinely uniform defaults
case age_in_months {
  m if m < 2 -> "newborn"
  m if m < 12 -> "infant"
  _ -> "older"
}
```

### Multiple subjects

Match on multiple values simultaneously by separating them with commas.

```gleam
case x, y {
  0, 0 -> "origin"
  0, _ -> "y-axis"
  _, 0 -> "x-axis"
  _, _ -> "elsewhere"
}
```

### Guards

Guards add conditions to pattern arms using `if`. Guards cannot contain function calls -- only operators and comparisons.

```gleam
case age_in_months {
  m if m < 2 -> "newborn"
  m if m < 12 -> "infant"
  m if m < 36 -> "toddler"
  _ -> "older"
}
```

### Alternative patterns and aliases

Use `|` for multiple patterns with the same body. Use `as` to bind a matched value.

```gleam
case month {
  1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
  4 | 6 | 9 | 11 -> 30
  2 -> 28
  _ -> 30
}

case list {
  [_, ..] as non_empty -> process(non_empty)
  [] -> default_value
}
```

### String prefix matching

Match string prefixes with the `<>` operator.

```gleam
case greeting {
  "Hello, " <> name -> name
  _ -> "stranger"
}
```

---

## 6. Error Handling

### The `Result` type

`Result(value, error)` is the standard way to represent fallible operations. Chain them with `result.try` or the `use` keyword (see Section 7).

```gleam
pub fn parse_int(s: String) -> Result(Int, String) {
  case int.parse(s) {
    Ok(n) -> Ok(n)
    Error(Nil) -> Error("Invalid integer: " <> s)
  }
}
```

### Key `result` module functions

This table covers the most commonly used functions. See [gleam/result hexdocs](https://hexdocs.pm/gleam_stdlib/gleam/result.html) for the complete API.

| Function | Purpose |
|----------|---------|
| `try` | Chain fallible operations (short-circuits on Error) |
| `map` | Transform the Ok value |
| `map_error` | Transform the Error value |
| `unwrap` | Extract Ok or use a default |
| `lazy_unwrap` | Extract Ok or compute a default |
| `flatten` | Unwrap nested Results |
| `all` | Combine a list of Results into a Result of a list |
| `values` | Keep only Ok values from a list |
| `or` | Return the first Ok |
| `replace` | Replace the Ok value |
| `is_ok` / `is_error` | Test which variant (useful in assertions) |
| `nil_error` | Discard the error type, replacing with Nil |

### `let assert` -- tests only

`let assert` performs a partial pattern match that panics on mismatch. Restrict its use to test code. In library code, return `Result` and let callers decide how to handle failure.

```gleam
// In tests: acceptable
let assert Ok(locale) = get_locale("en")

// In library code: return Result instead
pub fn first(items: List(a)) -> Result(a, Nil) {
  case items {
    [first, ..] -> Ok(first)
    [] -> Error(Nil)
  }
}
```

### `panic` and `todo`

`panic` crashes the program immediately. Use it only for provably unreachable states. `todo` also crashes but signals unfinished code -- the compiler emits a warning.

```gleam
fn unreachable() -> Nil {
  panic as "This branch is unreachable because ..."
}

fn not_yet_done() -> Int {
  todo as "Implement the scoring algorithm"
}
```

Neither should appear in production library code.

---

## 7. Control Flow with `use`

The `use` keyword is Gleam's most powerful control flow tool. It eliminates callback nesting by capturing the remainder of a function body as an implicit continuation. It works with any function whose last parameter is a callback.

### `use` with `result.try` -- chaining fallible operations

This is the most common `use` pattern. Each `use` line short-circuits on `Error`.

```gleam
// Without use: deeply nested callbacks
fn process(a: String, b: String) -> Result(Int, Nil) {
  result.try(int.parse(a), fn(x) {
    result.try(int.parse(b), fn(y) {
      Ok(x + y)
    })
  })
}

// With use: flat and readable
fn process(a: String, b: String) -> Result(Int, Nil) {
  use x <- result.try(int.parse(a))
  use y <- result.try(int.parse(b))
  Ok(x + y)
}
```

### `use` with `bool.guard` -- early returns

`bool.guard` is Gleam's equivalent of a guard clause or early return. When the condition is true, it returns the given value immediately. When false, it calls the continuation (the rest of the function body after the `use` line).

```gleam
import gleam/bool

fn process(input: String) -> Result(Int, Nil) {
  use n <- result.try(int.parse(input))
  // If n <= 0, return Error(Nil) immediately.
  // Otherwise, continue with the rest of the function.
  use <- bool.guard(when: n <= 0, return: Error(Nil))
  Ok(n * 2)
}
```

This replaces the imperative pattern:
```
if (n <= 0) return Error(Nil)
```

Use `bool.lazy_guard` when the return value is expensive to compute:

```gleam
use <- bool.lazy_guard(when: need_fallback, return: fn() { compute_fallback() })
```

### `use` with `list.each` -- iteration with side effects

```gleam
use item <- list.each(items)
io.println(item)
```

### Desugaring rule

Every `use` expression desugars into a function call where everything after the `use` line becomes the callback body. Understanding this desugaring is essential for reading and writing `use` expressions:

```gleam
// This:
use x <- result.try(parse(input))
Ok(x + 1)

// Desugars to:
result.try(parse(input), fn(x) {
  Ok(x + 1)
})
```

---

## 8. Functional Patterns

### Pipe operator `|>`

The pipe operator passes the left-hand value as the first argument to the right-hand function. It is the defining idiom of Gleam code.

```gleam
input
|> string.trim
|> string.uppercase
|> io.println
```

When the value needs to go to a non-first argument, use a function capture:

```gleam
"1"
|> string.append("2")       // append("1", "2") -> "12"
|> string.append("3", _)    // append("3", "12") -> "312"
```

### Function captures

The `_` placeholder creates a one-argument anonymous function.

```gleam
let add_one = int.add(1, _)      // fn(x) { int.add(1, x) }
let double = int.multiply(_, 2)  // fn(x) { int.multiply(x, 2) }
```

### Prefer stdlib over manual recursion

Use `list.map`, `list.filter`, `list.fold`, and other standard library functions over manual recursion. They are well-tested, readable, and handle target-specific optimizations.

```gleam
[1, 2, 3] |> list.map(int.multiply(_, 2))          // [2, 4, 6]
[1, 2, 3, 4] |> list.filter(fn(x) { x > 2 })      // [3, 4]
[1, 2, 3] |> list.fold(0, int.add)                  // 6
```

### Use labeled arguments from the stdlib

The standard library uses labeled arguments for readability. Use them at call sites.

```gleam
list.fold(over: items, from: 0, with: int.add)
list.sort(items, by: int.compare)
string.replace(in: text, each: ",", with: " ")
```

### Recursion and tail calls: target-dependent

When manual recursion is necessary, use an accumulator parameter to make it tail-recursive. Note that tail call optimization depends on the compilation target:

- **Erlang target**: The BEAM VM guarantees tail call optimization. Deep recursion is safe.
- **JavaScript target**: TCO is not reliably supported (only Safari/JavaScriptCore implements it; V8 and SpiderMonkey do not). For potentially deep recursion targeting JavaScript, prefer stdlib higher-order functions.

```gleam
// Tail-recursive with accumulator
fn factorial(n: Int) -> Int {
  factorial_loop(n, 1)
}

fn factorial_loop(n: Int, acc: Int) -> Int {
  case n {
    0 | 1 -> acc
    _ -> factorial_loop(n - 1, n * acc)
  }
}
```

---

## 9. Data Modeling

### Make impossible states impossible

Design custom types so that invalid states cannot be represented. This is the most important data modeling principle.

```gleam
// Bad: nothing prevents is_loading=True AND error=Some("...")
pub type PageState {
  PageState(
    data: Option(Data),
    is_loading: Bool,
    error: Option(String),
  )
}

// Good: each state is a distinct constructor
pub type PageState {
  Loading
  Loaded(data: Data)
  Failed(error: String)
}
```

### Custom types over dictionaries for known structures

When the set of keys is known at compile time, use a custom type. It provides compile-time field access checking and exhaustive pattern matching.

```gleam
// Bad: runtime key lookup, no compile-time guarantees
let locale = dict.from_list([#("code", "en"), #("name", "English")])

// Good: compile-time checked
pub type Locale {
  Locale(code: String, name: String)
}
```

### Records: single-constructor custom types

A custom type with one constructor and named fields serves as Gleam's record type. Access fields with dot syntax. Use the spread operator `..` to create modified copies.

```gleam
pub type Config {
  Config(host: String, port: Int, max_connections: Int)
}

let config = Config(host: "localhost", port: 8080, max_connections: 100)
let host = config.host
let updated = Config(..config, port: 9090)
```

### Tuples for small anonymous groupings

Use tuples for temporary groupings of 2-3 values in internal code. For public APIs or anything larger, use a named custom type with self-documenting fields.

```gleam
// Fine for internal use
fn parse_date(s: String) -> Result(#(Int, Int, Int), Nil) {
  // ...
}

// Better for public APIs
pub type Date {
  Date(year: Int, month: Int, day: Int)
}
```

---

## 10. API Design

### Design functions for piping

The subject type should be the first argument to enable `|>` piping. Module functions that operate on a type form its "methods."

```gleam
pub fn new() -> Counter {
  Counter(0)
}

pub fn increment(counter: Counter) -> Counter {
  Counter(counter.value + 1)
}

// Used with pipes
new() |> increment |> increment
```

### Labeled arguments for clarity

When the purpose of parameters is not obvious from their types, use labeled arguments. Labels can differ from internal parameter names -- the label is what callers see, the internal name is what the function body uses.

```gleam
pub fn replace(
  in string: String,
  each pattern: String,
  with substitute: String,
) -> String {
  // ...
}

// Called as:
replace(in: text, each: ",", with: " ")
```

When the variable name matches the label, use the shorthand syntax:

```gleam
let quantity = 5.0
let unit_price = 10.0
calculate_total(quantity:, unit_price:)
```

### String building

For building strings incrementally, use `gleam/string_tree` instead of repeated `<>` concatenation. `StringTree` uses a tree structure where append and prepend are O(1). For joining a list of strings, `string.join` is simpler.

```gleam
string_tree.new()
|> string_tree.append("Hello")
|> string_tree.append(", ")
|> string_tree.append("world!")
|> string_tree.to_string

// Or simply:
["Hello", "world"] |> string.join(", ")
```

### Documentation comments

Use `///` for function and type documentation. Use `////` at the top of a file for module-level documentation. These are rendered by `gleam docs build`.

```gleam
//// This module handles age formatting for human-readable display.

/// Formats an age as a human-readable string.
///
/// ## Examples
///
/// ```gleam
/// format_age(locale, Normal, "2020-01-01", "2025-01-01")
/// // -> Ok("5 years")
/// ```
///
pub fn format_age(
  locale: AgeLocale,
  compactness: Compactness,
  dob: String,
  as_of: String,
) -> Result(String, Nil) {
  // ...
}
```

### Deprecation

Mark deprecated functions with `@deprecated`. The message should name the replacement and the version in which the deprecated function will be removed.

```gleam
@deprecated("Use format_age instead. Will be removed in v0.6.0.")
pub fn old_format(dob: String) -> String {
  // ...
}
```

---

## 11. Things to Avoid

### Unnecessary wildcards in case expressions

Wildcards suppress exhaustiveness checking. When a new constructor is added, a wildcard silently swallows it instead of producing a compile error. Use them only for genuinely uniform defaults (numeric ranges, string matching).

### `let assert` in library code

Causes a runtime crash on pattern mismatch. Return `Result` in library code; restrict `let assert` to tests.

### `panic` for expected failure modes

`panic` is for provably impossible states. If a function can legitimately fail, return `Result`.

### Importing functions unqualified

Keep functions qualified so readers can tell where they come from. Only import types and constructors unqualified (for type annotations and pattern matching).

```gleam
// Avoid
import gleam/list.{map, filter, fold}

// Prefer
import gleam/list
list.map(items, transform)
```

### Deep nesting

Flatten deeply nested `case` expressions and callbacks using `use` expressions, pipe operators, and helper functions.

```gleam
// Avoid
fn process(input: String) -> Result(String, Nil) {
  case int.parse(input) {
    Ok(n) ->
      case n > 0 {
        True ->
          case int.remainder(n, 2) {
            Ok(0) -> Ok("even positive")
            _ -> Ok("odd positive")
          }
        False -> Error(Nil)
      }
    Error(Nil) -> Error(Nil)
  }
}

// Prefer
fn process(input: String) -> Result(String, Nil) {
  use n <- result.try(int.parse(input))
  use <- bool.guard(when: n <= 0, return: Error(Nil))
  case int.remainder(n, 2) {
    Ok(0) -> Ok("even positive")
    _ -> Ok("odd positive")
  }
}
```

### `Dict` for static structures

Dictionaries are for dynamic key-value data. If you know all the keys at compile time, use a custom type.

### Matching on booleans when you could match on data

Prefer matching on the underlying sum type rather than deriving a boolean and matching on `True`/`False`. The former is more informative and catches missing cases.

```gleam
// Avoid: matching on a derived boolean
let is_empty = list.is_empty(items)
case is_empty {
  True -> "no items"
  False -> "has items"
}

// Prefer: matching on the data directly
case items {
  [] -> "no items"
  [_, ..] -> "has items"
}
```

### Separate int and float operators

Gleam uses distinct operators for integer and float arithmetic. Mixing them is a compile error.

| Operation | Int | Float |
|-----------|-----|-------|
| Add | `+` | `+.` |
| Subtract | `-` | `-.` |
| Multiply | `*` | `*.` |
| Divide | `/` | `/.` |
| Compare | `>` `<` `>=` `<=` | `>.` `<.` `>=.` `<=.` |
| Equality | `==` `!=` | `==` `!=` |

---

## 12. Tooling

### Project configuration: `gleam.toml`

`gleam.toml` is the project configuration file, controlling the target platform, dependencies, package metadata, and build settings. This project targets the Erlang platform.

### Core commands

| Command | Purpose |
|---------|---------|
| `gleam format` | Format all source files (non-configurable, authoritative) |
| `gleam format --check` | Check formatting without modifying (CI) |
| `gleam check` | Type-check without building artifacts (fast validation) |
| `gleam build` | Compile for the target platform |
| `gleam build --warnings-as-errors` | Treat warnings as errors (required in CI) |
| `gleam test` | Run all test functions |
| `gleam docs build` | Generate HTML documentation from `///` comments |
| `gleam add <package>` | Add a dependency to `gleam.toml` |
| `gleam add <package> --dev` | Add a dev dependency |
| `gleam clean` | Remove build artifacts |

### Target selection

Commands that compile or run code accept a `--target` flag:

```sh
gleam build --target erlang
gleam build --target javascript
gleam test --target javascript
```

### Recommended CI pipeline

```sh
gleam format --check
gleam build --warnings-as-errors
gleam test
```

---

## 13. References

- [Language Tour (single page)](https://tour.gleam.run/everything/) -- All language features on one page
- [Standard library docs](https://hexdocs.pm/gleam_stdlib/) -- Full API documentation
- [gleam/result](https://hexdocs.pm/gleam_stdlib/gleam/result.html) -- Error handling functions
- [gleam/option](https://hexdocs.pm/gleam_stdlib/gleam/option.html) -- Optional values
- [gleam/list](https://hexdocs.pm/gleam_stdlib/gleam/list.html) -- List operations
- [gleam/string](https://hexdocs.pm/gleam_stdlib/gleam/string.html) -- String manipulation
- [gleam/string_tree](https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html) -- Efficient string building
- [Writing Gleam](https://gleam.run/writing-gleam/) -- Project creation and development guide
- [FAQ / Design Philosophy](https://gleam.run/frequently-asked-questions/) -- Why Gleam excludes certain features
- [Command Line Reference](https://gleam.run/command-line-reference/) -- All CLI commands and flags
- [Package index](https://packages.gleam.run) -- Published Gleam packages
- [Gleam GitHub](https://github.com/gleam-lang/gleam) -- Language source and issue tracker
