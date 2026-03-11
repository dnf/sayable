# Gleam Style Guide

A comprehensive guide to idiomatic Gleam coding style and best practices for code auditing.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Module Design](#4-module-design)
5. [Pattern Matching](#5-pattern-matching)
6. [Error Handling](#6-error-handling)
7. [Functional Patterns](#7-functional-patterns)
8. [Data Modeling](#8-data-modeling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [References](#12-references)

---

## 1. Naming Conventions

### Functions and Variables: `snake_case`

All function names, variable bindings, and module-level constants use lowercase with underscores.

```gleam
let user_name = "Alice"
let max_retries = 3

fn calculate_total(unit_price: Float, quantity: Int) -> Float {
  unit_price *. int.to_float(quantity)
}
```

### Types and Constructors: `PascalCase`

Custom type names and their constructors use PascalCase. This is the only place PascalCase appears in Gleam.

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

### Constants: `snake_case`

Unlike many languages, Gleam constants use `snake_case`, not `SCREAMING_SNAKE_CASE`. Constants are defined at module level with the `const` keyword and may only contain literal values (no function calls).

```gleam
// Correct
const max_retries = 3
const default_name = "world"
const supported_codes = ["en", "fr", "de"]

// Wrong -- do not use SCREAMING_SNAKE_CASE
const MAX_RETRIES = 3
```

### Modules: `snake_case` path segments

Modules are named by their file path relative to `src/`, using `snake_case` for each segment. There is no explicit module declaration -- the file path is the module name.

```
src/my_app.gleam           -> module: my_app
src/my_app/http_client.gleam -> module: my_app/http_client
src/my_app/json_decoder.gleam -> module: my_app/json_decoder
```

### Discard variables: prefix with `_`

Unused variables must be prefixed with `_` to suppress compiler warnings. The name after `_` is documentation for the reader.

```gleam
let _unused = expensive_computation()
let #(_first, second, _third) = triple
```

A bare `_` discards without naming:

```gleam
case value {
  #(_, second) -> second
}
```

### Test functions: suffix with `_test`

Any public function in the `test/` directory with a name ending in `_test` is automatically run as a test by `gleeunit`.

```gleam
pub fn addition_test() {
  add(1, 2) |> should.equal(3)
}
```

---

## 2. Code Formatting

### `gleam format` is authoritative

All Gleam code must be formatted with `gleam format`. This is the single, non-configurable formatter for the language. There are no options, no configuration files, and no debates. Run it before every commit.

```sh
gleam format           # Format all .gleam files in src/ and test/
gleam format --check   # Check without modifying (useful in CI)
```

### Indentation: 2 spaces

The formatter uses 2-space indentation. Tabs are not used.

```gleam
pub fn greet(name: String) -> String {
  case name {
    "" -> "Hello, stranger!"
    _ -> "Hello, " <> name <> "!"
  }
}
```

### Line length

The formatter targets 80 columns but will not break all long lines. Long expressions (especially in locale data or generated code) are acceptable. The formatter handles wrapping of function signatures and pipelines automatically.

### Pipeline formatting

When a pipeline spans multiple lines, each step goes on its own line with `|>` at the start. The formatter enforces this.

```gleam
// Single line is fine when short
"hello" |> string.uppercase

// Multi-line: one step per line
"Hello, Mike!"
|> string.drop_end(1)
|> string.drop_start(7)
|> string.uppercase
|> io.println
```

### Function call wrapping

When a function call's arguments don't fit on one line, each argument goes on its own line, indented by 2 spaces.

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

### Trailing commas

The formatter adds trailing commas to multi-line argument lists, record fields, and list literals. This reduces diff noise when adding items.

```gleam
pub type AgeLocale {
  AgeLocale(
    code: String,
    day: UnitForms,
    week: UnitForms,
  )
}
```

---

## 3. Type System

### Custom types

Custom types are Gleam's primary data modeling tool. They replace enums, structs, tagged unions, and sum types from other languages. Every custom type has one or more constructors.

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

Type aliases create alternate names for existing types. They do not create new types and provide no additional type safety. Use them sparingly for readability.

```gleam
pub type Headers = List(#(String, String))
pub type UserId = Int
```

### Generics (type variables)

Generic type parameters use lowercase names. The convention is short names like `a`, `b`, `e` for abstract parameters, and descriptive names for domain-specific ones.

```gleam
pub type Result(value, error) {
  Ok(value)
  Error(error)
}

pub type Option(inner) {
  Some(inner)
  None
}

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

The `pub opaque type` declaration exports the type name but hides its constructors. External modules cannot construct or pattern-match on opaque type values -- they can only interact through the module's public API. Use opaque types to enforce invariants.

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

### No null, no exceptions

Gleam has no null, nil-as-absence, or exception system. Absence is modeled with `Option(a)` (which is `Result(a, Nil)`). Failure is modeled with `Result(ok, error)`. This is enforced at the type level -- there are no escape hatches.

---

## 4. Module Design

### One file, one module

Every `.gleam` file is exactly one module. The module name is derived from its file path relative to `src/`. There is no explicit `module` declaration.

### Default privacy

Functions, types, and constants are private by default. Use the `pub` keyword to export them. This is the reverse of many languages and encourages minimal public APIs.

```gleam
// Private -- only accessible within this module
fn helper() -> Int {
  42
}

// Public -- accessible from other modules
pub fn api_function() -> Int {
  helper()
}
```

For types, `pub type` exports both the type and its constructors. `pub opaque type` exports only the type name.

```gleam
// Constructors exported: callers can create and match
pub type Color {
  Red
  Green
  Blue
}

// Only the type name exported: constructors are hidden
pub opaque type Email {
  Email(String)
}
```

### Qualified imports (preferred)

The default import style uses qualified access via the module name. This is the preferred style in the Gleam community because it makes the origin of every function clear.

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

### Module aliases

Use `as` to shorten long module paths. Choose meaningful short names.

```gleam
import gleam/string_tree as st
import my_app/database/queries as db

let tree = st.new()
```

### Unqualified imports

Unqualified imports bring specific values or types into scope without a module prefix. Use them sparingly -- primarily for types that appear frequently and for constructors used in pattern matching.

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

### Import organization

Group imports logically: standard library first, then external packages, then internal modules. The formatter does not enforce import ordering, so this is a convention to follow manually.

```gleam
// Standard library
import gleam/int
import gleam/list
import gleam/string

// External packages
import gleeunit/should

// Internal modules
import my_app/formatter
import my_app/types.{type Config}
```

---

## 5. Pattern Matching

### Case expressions

`case` is the primary control flow mechanism in Gleam. There are no `if/else` expressions (booleans are matched with `case`).

```gleam
case value {
  0 -> "zero"
  1 -> "one"
  n -> "other: " <> int.to_string(n)
}
```

### Exhaustive matching

The compiler enforces exhaustive pattern matching. Every possible value must be handled. Do not add a wildcard `_` catch-all unless you genuinely want to handle all remaining cases the same way. Unnecessary wildcards hide bugs when new constructors are added.

```gleam
// Good: all constructors handled explicitly
case direction {
  North -> #(0, 1)
  South -> #(0, -1)
  East -> #(1, 0)
  West -> #(-1, 0)
}

// Risky: if a new Season constructor is added, this silently handles it
case season {
  Summer -> "hot"
  _ -> "not hot"
}
```

### Destructuring

Pattern matching destructures custom types, tuples, and lists.

```gleam
// Record destructuring
case person {
  Person(name: name, age: age) -> name <> " is " <> int.to_string(age)
}

// Tuple destructuring
let #(x, y, z) = coordinates

// List head-tail
case items {
  [] -> "empty"
  [first, ..rest] -> "first is " <> first
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

Guards add conditions to pattern arms using `if`. Guards cannot contain function calls, only operators and comparisons.

```gleam
case age_in_months {
  m if m < 2 -> "newborn"
  m if m < 12 -> "infant"
  m if m < 36 -> "toddler"
  m if m < 156 -> "child"
  m if m < 216 -> "teenager"
  _ -> "adult"
}
```

### Alternative patterns

Use `|` to match multiple patterns with the same body.

```gleam
case month {
  1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
  4 | 6 | 9 | 11 -> 30
  2 -> 28
  _ -> 30
}
```

### Pattern aliases

Bind a matched value to a name with `as`.

```gleam
case list {
  [_, ..] as non_empty -> process(non_empty)
  [] -> default_value
}
```

### String patterns

Match string prefixes with the `<>` operator.

```gleam
case greeting {
  "Hello, " <> name -> name
  _ -> "stranger"
}
```

### `let assert` for partial matching

`let assert` performs a partial pattern match that crashes (panics) if the pattern does not match. Use it only when you are certain the match will succeed, or in tests.

```gleam
// In tests: acceptable
let assert Ok(locale) = get_locale("en")

// With a message explaining why the assertion is safe
let assert [first, ..] = items as "items is guaranteed non-empty by caller"
```

Avoid `let assert` in library code. Prefer returning `Result` instead.

---

## 6. Error Handling

### The `Result` type

`Result(value, error)` is the standard way to represent operations that can fail. It has two constructors: `Ok(value)` and `Error(error)`.

```gleam
pub fn parse_int(s: String) -> Result(Int, String) {
  case int.parse(s) {
    Ok(n) -> Ok(n)
    Error(Nil) -> Error("Invalid integer: " <> s)
  }
}
```

### Chaining with `result.try`

`result.try` applies a function to the `Ok` value and short-circuits on `Error`. This is the fundamental way to chain fallible operations.

```gleam
import gleam/result

fn process(input: String) -> Result(Int, Nil) {
  input
  |> int.parse
  |> result.try(fn(n) {
    case n > 0 {
      True -> Ok(n * 2)
      False -> Error(Nil)
    }
  })
}
```

### `use` expressions for Result chaining

The `use` keyword is syntactic sugar that eliminates callback nesting. It is the idiomatic way to chain `result.try` calls.

```gleam
// Without use -- deeply nested
fn process(a: String, b: String) -> Result(Int, Nil) {
  result.try(int.parse(a), fn(x) {
    result.try(int.parse(b), fn(y) {
      Ok(x + y)
    })
  })
}

// With use -- flat and readable
fn process(a: String, b: String) -> Result(Int, Nil) {
  use x <- result.try(int.parse(a))
  use y <- result.try(int.parse(b))
  Ok(x + y)
}
```

The `use` pattern works with any function that takes a callback as its last argument. The `<-` arrow binds the callback parameter.

### Key `result` module functions

| Function | Signature | Purpose |
|----------|-----------|---------|
| `try` | `fn(Result(a, e), fn(a) -> Result(b, e)) -> Result(b, e)` | Chain fallible operations |
| `map` | `fn(Result(a, e), fn(a) -> b) -> Result(b, e)` | Transform the Ok value |
| `map_error` | `fn(Result(a, e), fn(e) -> f) -> Result(a, f)` | Transform the Error value |
| `unwrap` | `fn(Result(a, e), a) -> a` | Extract Ok or use default |
| `lazy_unwrap` | `fn(Result(a, e), fn() -> a) -> a` | Extract Ok or compute default |
| `flatten` | `fn(Result(Result(a, e), e)) -> Result(a, e)` | Unwrap nested Results |
| `all` | `fn(List(Result(a, e))) -> Result(List(a), e)` | Combine list of Results |
| `values` | `fn(List(Result(a, e))) -> List(a)` | Keep only Ok values |
| `or` | `fn(Result(a, e), Result(a, e)) -> Result(a, e)` | Return first Ok |
| `replace` | `fn(Result(a, e), b) -> Result(b, e)` | Replace Ok value |

### `panic` and `todo`

`panic` crashes the program immediately. Use it only for genuinely impossible states. `todo` also crashes but signals unfinished code -- the compiler emits a warning for it.

```gleam
// Acceptable: a state that is provably unreachable
fn unreachable() -> Nil {
  panic as "This branch is unreachable because ..."
}

// During development only -- compiler warns
fn not_yet_done() -> Int {
  todo as "Implement the scoring algorithm"
}
```

Neither `panic` nor `todo` should appear in production library code. If something can fail, return `Result`.

---

## 7. Functional Patterns

### Pipe operator `|>`

The pipe operator passes the left-hand value as the first argument to the right-hand function. It is the defining idiom of Gleam code.

```gleam
// Without pipe
io.println(string.uppercase(string.trim(input)))

// With pipe -- reads top to bottom, left to right
input
|> string.trim
|> string.uppercase
|> io.println
```

When the value needs to be passed as a non-first argument, use a function capture:

```gleam
"1"
|> string.append("2")       // append("1", "2") -> "12"
|> string.append("3", _)    // append("3", "12") -> "312"
```

### Function captures

The `_` placeholder creates a one-argument anonymous function from a multi-argument call.

```gleam
let add_one = int.add(1, _)      // fn(x) { int.add(1, x) }
let double = int.multiply(_, 2)  // fn(x) { int.multiply(x, 2) }
```

### Higher-order functions

Functions are first-class values. Pass them as arguments, return them from functions, and store them in data structures.

```gleam
fn apply_twice(x: a, f: fn(a) -> a) -> a {
  x |> f |> f
}

let result = apply_twice(5, int.add(1, _))  // 7
```

### List operations

The `gleam/list` module provides the standard functional toolkit. Prefer these over manual recursion.

```gleam
import gleam/list

// Transform
[1, 2, 3] |> list.map(int.multiply(_, 2))          // [2, 4, 6]

// Filter
[1, 2, 3, 4] |> list.filter(fn(x) { x > 2 })      // [3, 4]

// Reduce
[1, 2, 3] |> list.fold(0, int.add)                  // 6

// Find
[1, 2, 3] |> list.find(fn(x) { x > 1 })            // Ok(2)

// Fallible map
["1", "2", "x"]
|> list.try_map(int.parse)                           // Error(Nil)

// Filter and transform in one pass
[Ok(1), Error("x"), Ok(3)]
|> result.values                                     // [1, 3]
```

### Labeled arguments in standard library

Gleam's standard library uses labeled arguments extensively for readability. When calling these functions, use the labels.

```gleam
list.fold(over: items, from: 0, with: int.add)
list.filter(items, keeping: fn(x) { x > 0 })
list.sort(items, by: int.compare)
string.replace(in: text, each: ",", with: " ")
```

### Recursion and tail calls

Gleam optimizes tail-recursive functions (where the recursive call is the last expression). Use an accumulator parameter to make recursion tail-recursive.

```gleam
// Not tail-recursive (builds stack)
fn factorial(n: Int) -> Int {
  case n {
    0 | 1 -> 1
    _ -> n * factorial(n - 1)
  }
}

// Tail-recursive (constant stack)
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

## 8. Data Modeling

### Records as single-constructor custom types

A custom type with one constructor and named fields serves as Gleam's record type.

```gleam
pub type Config {
  Config(
    host: String,
    port: Int,
    max_connections: Int,
  )
}
```

### Record access

Fields are accessed with dot syntax.

```gleam
let config = Config(host: "localhost", port: 8080, max_connections: 100)
let host = config.host
```

### Record updates

The spread operator `..` creates a new record with some fields changed. It always creates a copy -- records are immutable.

```gleam
let updated = Config(..config, port: 9090, max_connections: 200)
```

### Making impossible states impossible

Design custom types so that invalid states cannot be represented. This is the most important data modeling principle in Gleam.

```gleam
// Bad: nothing prevents setting is_loading=True AND error=Some("...")
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

### Use custom types instead of dictionaries for known structures

When the set of keys is known at compile time, use a custom type, not a `Dict`. Custom types provide compile-time field access checking and exhaustive pattern matching.

```gleam
// Bad: runtime key lookup, no compile-time guarantees
let locale = dict.from_list([#("code", "en"), #("name", "English")])

// Good: compile-time checked field access
pub type Locale {
  Locale(code: String, name: String)
}
```

### Tuples for small anonymous groupings

Use tuples for temporary groupings of 2-3 values. For anything larger or anything that appears in a public API, use a named custom type.

```gleam
// Fine for internal use
fn parse_date(s: String) -> Result(#(Int, Int, Int), Nil) {
  // year, month, day
  // ...
}

// Better for public APIs -- fields are self-documenting
pub type Date {
  Date(year: Int, month: Int, day: Int)
}
```

---

## 9. Common Idioms

### `use` expressions beyond Result

The `use` keyword works with any function whose last parameter is a callback. Common uses include:

```gleam
// With result.try (most common)
use value <- result.try(parse(input))

// With bool.guard for early returns
use <- bool.guard(when: list.is_empty(items), return: default)

// With list.each for iteration with side effects
use item <- list.each(items)
io.println(item)
```

### Labeled arguments for readable APIs

Design public functions with labeled arguments when the purpose of each parameter is not obvious from its type.

```gleam
// Unclear: what do these strings mean?
pub fn format(String, String, String) -> String

// Clear: labels document the API
pub fn format(
  template template: String,
  with value: String,
  locale locale: String,
) -> String
```

Labels can differ from internal parameter names. The label is what callers see; the internal name is what the function body uses.

```gleam
pub fn replace(in string: String, each pattern: String, with substitute: String) -> String {
  // `string`, `pattern`, and `substitute` are used in the body
  // `in`, `each`, and `with` are used at call sites
  // ...
}

// Called as:
replace(in: text, each: ",", with: " ")
```

### Label shorthand

When the variable name matches the label, you can use the shorthand syntax:

```gleam
let quantity = 5.0
let unit_price = 10.0
calculate_total(quantity:, unit_price:)
// Equivalent to: calculate_total(quantity: quantity, unit_price: unit_price)
```

### String building with `string_tree`

For building strings incrementally (especially in loops), use `gleam/string_tree` instead of repeated `<>` concatenation. `StringTree` uses a tree structure where append and prepend are O(1). The final `to_string` traverses the tree once.

```gleam
import gleam/string_tree

string_tree.new()
|> string_tree.append("Hello")
|> string_tree.append(", ")
|> string_tree.append("world!")
|> string_tree.to_string
// "Hello, world!"
```

For joining a list of strings, `string.join` is simpler:

```gleam
["Hello", "world"] |> string.join(", ")
```

### Bit arrays

Bit arrays provide low-level binary data manipulation with a rich pattern matching syntax.

```gleam
// Create
let data = <<1, 2, 3>>
let text = <<"Hello":utf8>>
let flags = <<0b1010:size(4)>>

// Pattern match
case data {
  <<first, _rest:bytes>> -> first  // 1
  _ -> 0
}
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

### Deprecation annotations

Mark deprecated functions with `@deprecated` to generate compiler warnings.

```gleam
@deprecated("Use format_age instead")
pub fn old_format(dob: String) -> String {
  // ...
}
```

---

## 10. Things to Avoid

### Unnecessary wildcards in case expressions

Wildcards suppress the compiler's exhaustiveness checking. When a new constructor is added to a type, a wildcard silently swallows it instead of producing a compile error.

```gleam
// Avoid: hides missing cases
case color {
  Red -> "red"
  _ -> "not red"
}

// Prefer: explicit about all cases
case color {
  Red -> "red"
  Green -> "green"
  Blue -> "blue"
}
```

Use wildcards only when you genuinely intend to handle all remaining cases identically, such as a default branch in a numeric range.

### Excessive nesting

Deep nesting of `case` expressions or callbacks makes code hard to follow. Use `use` expressions, pipe operators, and helper functions to flatten the structure.

```gleam
// Avoid: deeply nested
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

// Prefer: flat with use
fn process(input: String) -> Result(String, Nil) {
  use n <- result.try(int.parse(input))
  use <- bool.guard(when: n <= 0, return: Error(Nil))
  case int.remainder(n, 2) {
    Ok(0) -> Ok("even positive")
    _ -> Ok("odd positive")
  }
}
```

### Using `Dict` for static structure

Dictionaries are for dynamic key-value data. If you know all the keys at compile time, use a custom type instead.

### `let assert` in library code

`let assert` causes a runtime crash on pattern mismatch. In library code, return `Result` instead and let callers decide how to handle failure.

```gleam
// Avoid in library code
pub fn first(items: List(a)) -> a {
  let assert [first, ..] = items
  first
}

// Prefer: return Result
pub fn first(items: List(a)) -> Result(a, Nil) {
  case items {
    [first, ..] -> Ok(first)
    [] -> Error(Nil)
  }
}
```

### `panic` for expected failure modes

`panic` is for truly impossible states. If a function can legitimately fail (bad input, missing data, I/O errors), return `Result`.

### Importing everything unqualified

Wholesale unqualified imports make code harder to understand because readers cannot tell where functions come from. Import types and constructors unqualified when needed for pattern matching; keep functions qualified.

```gleam
// Avoid: where does `map` come from?
import gleam/list.{map, filter, fold}

// Prefer: origin is clear
import gleam/list

list.map(items, transform)
list.filter(items, keeping: predicate)
```

### Separate int and float operators

Gleam uses distinct operators for integer and float arithmetic. Mixing them up is a compile error, not a runtime surprise.

| Operation | Int | Float |
|-----------|-----|-------|
| Add | `+` | `+.` |
| Subtract | `-` | `-.` |
| Multiply | `*` | `*.` |
| Divide | `/` | `/.` |
| Greater | `>` | `>.` |
| Less | `<` | `<.` |
| Greater-equal | `>=` | `>=.` |
| Less-equal | `<=` | `<=.` |
| Equality | `==` | `==` |

Equality (`==`, `!=`) works across all types using structural comparison.

### No `if/else`

Gleam does not have `if/else` expressions. Use `case` on booleans instead. This is a deliberate language design choice to keep pattern matching as the single control flow mechanism.

```gleam
// This does not exist in Gleam:
// if condition { ... } else { ... }

// Use case instead:
case is_valid {
  True -> proceed()
  False -> reject()
}
```

### No OOP patterns

Gleam has no classes, inheritance, interfaces, or method syntax. Functions are the only abstraction. If you find yourself wanting methods on a type, write module functions that take the type as their first argument (enabling piping).

```gleam
// Module functions that work with piping
pub fn new() -> Counter {
  Counter(0)
}

pub fn increment(counter: Counter) -> Counter {
  Counter(counter.value + 1)
}

// Used with pipes
new() |> increment |> increment
```

---

## 11. Tooling

### `gleam format`

Formats all Gleam source files. Non-configurable. Run before every commit.

```sh
gleam format         # Format in-place
gleam format --check # Check only (CI)
gleam format --stdin # Format from stdin
```

### `gleam check`

Type-checks the project without building artifacts. Faster than `gleam build` for quick validation during development.

```sh
gleam check
gleam check --target erlang
gleam check --target javascript
```

### `gleam build`

Compiles the project for the target platform.

```sh
gleam build
gleam build --target erlang
gleam build --target javascript
gleam build --warnings-as-errors  # Treat warnings as errors (recommended for CI)
```

### `gleam test`

Runs all test functions (public functions ending in `_test` in the `test/` directory).

```sh
gleam test
gleam test --target erlang
gleam test --target javascript
```

### `gleam docs build`

Generates HTML documentation from `///` and `////` comments. The generated docs follow hexdocs conventions.

```sh
gleam docs build
```

### `gleam add`

Adds a dependency to `gleam.toml`.

```sh
gleam add gleam_json
gleam add gleeunit --dev
```

### `gleam clean`

Removes build artifacts.

```sh
gleam clean
```

### `gleam lsp`

Runs the language server for editor integration. Provides diagnostics, completions, hover documentation, and go-to-definition.

### Recommended CI pipeline

```sh
gleam format --check   # Formatting is correct
gleam build --warnings-as-errors  # No warnings
gleam test             # All tests pass
```

---

## 12. References

### Official documentation

- **Language Tour**: <https://tour.gleam.run/> -- Interactive in-browser introduction covering all language features
- **Language Tour (single page)**: <https://tour.gleam.run/everything/> -- All language features on one page
- **Writing Gleam**: <https://gleam.run/writing-gleam/> -- Project creation and development guide
- **FAQ / Design Philosophy**: <https://gleam.run/frequently-asked-questions/> -- Why Gleam excludes certain features
- **Command Line Reference**: <https://gleam.run/command-line-reference/> -- All `gleam` CLI commands and flags

### Standard library

- **Standard library docs**: <https://hexdocs.pm/gleam_stdlib/> -- Full API documentation
- **gleam/result**: <https://hexdocs.pm/gleam_stdlib/gleam/result.html> -- Error handling functions
- **gleam/list**: <https://hexdocs.pm/gleam_stdlib/gleam/list.html> -- List operations
- **gleam/string**: <https://hexdocs.pm/gleam_stdlib/gleam/string.html> -- String manipulation
- **gleam/string_tree**: <https://hexdocs.pm/gleam_stdlib/gleam/string_tree.html> -- Efficient string building
- **gleam/dict**: <https://hexdocs.pm/gleam_stdlib/gleam/dict.html> -- Dictionary operations
- **gleam/option**: <https://hexdocs.pm/gleam_stdlib/gleam/option.html> -- Optional values

### Cheatsheets

- **Gleam for Erlang users**: <https://gleam.run/cheatsheets/gleam-for-erlang-users/>
- **Gleam for Elixir users**: <https://gleam.run/cheatsheets/gleam-for-elixir-users/>
- **Gleam for Elm users**: <https://gleam.run/cheatsheets/gleam-for-elm-users/>
- **Gleam for Rust users**: <https://gleam.run/cheatsheets/gleam-for-rust-users/>
- **Gleam for Python users**: <https://gleam.run/cheatsheets/gleam-for-python-users/>

### Community

- **Package index**: <https://packages.gleam.run> -- Published Gleam packages
- **Awesome Gleam**: <https://github.com/gleam-lang/awesome-gleam> -- Curated community resources
- **Gleam GitHub**: <https://github.com/gleam-lang/gleam> -- Language source and issue tracker
