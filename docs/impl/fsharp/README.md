# F# Style Guide

A comprehensive guide to idiomatic F# coding style and best practices, intended for code auditing F# implementations.

## Sources

This guide synthesizes recommendations from the following authoritative references:

- [Microsoft F# Style Guide](https://learn.microsoft.com/en-us/dotnet/fsharp/style-guide/) -- the official style guide
- [Microsoft F# Formatting Guidelines](https://learn.microsoft.com/en-us/dotnet/fsharp/style-guide/formatting) -- detailed formatting rules
- [Microsoft F# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/fsharp/style-guide/conventions) -- coding patterns and idioms
- [Microsoft F# Component Design Guidelines](https://learn.microsoft.com/en-us/dotnet/fsharp/style-guide/component-design-guidelines) -- API and library design
- [F# for Fun and Profit](https://fsharpforfunandprofit.com/) -- comprehensive community resource by Scott Wlaschin
- [Fantomas](https://github.com/fsprojects/fantomas) -- the community-standard F# code formatter
- [fsharp.org](https://fsharp.org/) -- official F# Software Foundation site

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Module Design](#4-module-design)
5. [Functional Patterns](#5-functional-patterns)
6. [Pattern Matching](#6-pattern-matching)
7. [Error Handling](#7-error-handling)
8. [Collections](#8-collections)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

F# follows .NET naming conventions with specific adjustments for functional constructs.

### Summary Table

| Construct | Case | Examples |
|---|---|---|
| Types (classes, records, unions, structs, enums) | PascalCase | `AgeLocale`, `PluralCategory`, `PostalAddress` |
| Discriminated union cases | PascalCase | `Some`, `None`, `Success`, `Error` |
| Namespaces | PascalCase | `SayableAge.Locales` |
| Modules | PascalCase | `Formatter`, `Types`, `Locale` |
| Public functions in modules | camelCase or PascalCase | `formatAge`, `List.map` |
| Private functions | camelCase | `calculateMonths`, `selectUnit` |
| Parameters | camelCase | `dateOfBirth`, `asOf`, `locale` |
| `let` bindings (local values) | camelCase | `ageInDays`, `monthsDiff` |
| Properties | PascalCase | `IsEndOfFile`, `Length` |
| Methods (on classes) | PascalCase | `ToString`, `CompareTo` |
| Interfaces | PascalCase with `I` prefix | `IDisposable`, `IComparable` |
| Generic type parameters | PascalCase | `'Key`, `'Value`, `'T` |
| Exceptions | PascalCase with `Exception` suffix | `ArgumentException`, `FormatException` |

### Rules

**Use PascalCase for types, including records, discriminated unions, and type abbreviations:**

```fsharp
type AgeLocale =
    { JustBorn: string
      Delimiter: string }

type PluralCategory =
    | Zero
    | One
    | Two
    | Few
    | Many
    | Other
```

**Use camelCase for function parameters and local `let` bindings:**

```fsharp
let formatAge (dateOfBirth: DateTime) (asOf: DateTime) (locale: AgeLocale) =
    let ageInDays = (asOf - dateOfBirth).Days
    let years = ageInDays / 365
    // ...
```

**Use camelCase for public module functions that follow standard collection function conventions or act like language keywords:**

```fsharp
// Idiomatic -- camelCase for utility functions
let formatAge dateOfBirth asOf locale = ...
let invalidArg paramName message = ...
```

**Use PascalCase for public module values consumed from other .NET languages:**

```fsharp
// When interop matters
let [<Literal>] Version = "1.0.0"
```

**Avoid abbreviations in public APIs.** Use `calculateDistance` not `calcDist`. Common abbreviations like `Async` are acceptable.

**Do not use casing alone to disambiguate names**, since some .NET languages (Visual Basic) are case-insensitive.

---

## 2. Code Formatting

### Automatic Formatting with Fantomas

Fantomas is the community-standard code formatter. Its default settings correspond to the official style guide. Use it to enforce consistent formatting across a codebase.

### Indentation

- **Use spaces, not tabs.** The F# compiler will error on tabs outside of string literals.
- **Use 4 spaces per indentation level** (the recommended default).
- Be consistent within a codebase.

### Line Length

- **Default maximum: 120 characters.** Fantomas breaks lines at this threshold.
- String literals and interpolated strings may exceed this limit on a single line.

### Avoid Name-Sensitive Alignment

Do not align code to identifier names. This creates fragile formatting that breaks when identifiers are renamed.

```fsharp
// Good
let myLongValueName =
    someExpression
    |> anotherExpression

// Bad -- alignment depends on identifier length
let myLongValueName = someExpression
                      |> anotherExpression
```

### Pipeline Formatting

Multi-line pipelines should place each `|>` on a new line, indented under the expression:

```fsharp
// Good
let result =
    input
    |> List.filter isValid
    |> List.map transform
    |> List.sortBy key

// Bad
let result = input
             |> List.filter isValid
             |> List.map transform
```

### Record Formatting

Three accepted multiline styles exist: **Cramped** (default), **Aligned**, and **Stroustrup**. Pick one and stay consistent.

```fsharp
// Cramped (historical default)
let address =
    { Street = "123 Main St"
      City = "Springfield"
      Zip = "62704" }

// Aligned
let address =
    {
        Street = "123 Main St"
        City = "Springfield"
        Zip = "62704"
    }

// Stroustrup
let address = {
    Street = "123 Main St"
    City = "Springfield"
    Zip = "62704"
}
```

Short records can be written on one line:

```fsharp
let point = { X = 1.0; Y = 0.0 }
```

### Discriminated Union Formatting

Indent `|` cases by 4 spaces from the type definition:

```fsharp
// Good
type Volume =
    | Liter of float
    | FluidOunce of float
    | ImperialPint of float

// Bad -- cases should be indented
type Volume =
| Liter of float
| FluidOunce of float
```

Single-case unions may omit the leading `|`:

```fsharp
type EmailAddress = EmailAddress of string
```

### Match Expression Formatting

Use `|` for each clause with no indentation relative to `match`:

```fsharp
// Good
match value with
| Some x -> x
| None -> defaultValue

// Bad -- do not indent cases
match value with
    | Some x -> x
    | None -> defaultValue
```

When the right-hand side is too long, move it to the next line indented one level:

```fsharp
match lam with
| Var v -> 1
| Abs(x, body) ->
    1 + sizeLambda body
| App(lam1, lam2) ->
    sizeLambda lam1 + sizeLambda lam2
```

Do not align match arrows:

```fsharp
// Good
match lam with
| Var v -> v.Length
| Abstraction _ -> 2

// Bad
match lam with
| Var v         -> v.Length
| Abstraction _ -> 2
```

### Function Application Formatting

Provide arguments on the same line when line width allows. Omit parentheses unless required:

```fsharp
// Good
someFunction x.Name x.Quantity

// Unnecessary parentheses
someFunction (x.Name)
```

For `.NET`-style method calls (PascalCase), do not add a space before the parentheses:

```fsharp
// Good
String.Format(pattern, arg)
SomeClass.Invoke()

// Bad
String.Format (pattern, arg)
SomeClass.Invoke ()
```

For lowercase F# function calls, add a space before parenthesized arguments:

```fsharp
// Good
someFunction (x + y)
someFunction ()

// Bad
someFunction(x + y)
someFunction()
```

### Blank Lines

Separate top-level definitions with a single blank line:

```fsharp
let thing1 = 1 + 1

let thing2 = 1 + 2

type ThisThat = This | That
```

### Comments

Prefer `//` line comments over `(* *)` block comments. Comments should be capitalized and well-formed:

```fsharp
// Good: A clear explanation of the intent.
let f x = x + 1

// bad: uncapitalized and terse
let f x = x + 1 // plus one
```

Use `///` XML doc comments for public APIs:

```fsharp
/// Formats a human-readable age string from a date of birth.
let formatAge (dateOfBirth: DateTime) (asOf: DateTime) (locale: AgeLocale) =
    // ...
```

### `open` Statement Ordering

Sort `open` statements **topologically** (by dependency layer), not alphabetically. Separate layers with blank lines:

```fsharp
namespace SayableAge

open System

open SayableAge.Types
open SayableAge.Locales
```

---

## 3. Type System

### Discriminated Unions

Discriminated unions are F#'s most powerful modeling tool. Use them to represent mutually exclusive choices:

```fsharp
type PluralCategory =
    | Zero
    | One
    | Two
    | Few
    | Many
    | Other

type AgeStage =
    | JustBorn
    | InWeeks of int
    | InMonths of int
    | InYears of int * bool  // years and whether to show half
```

Use `[<RequireQualifiedAccess>]` when case names might conflict with other types:

```fsharp
[<RequireQualifiedAccess>]
type Color =
    | Red
    | Green
    | Blue
```

Use single-case unions for domain types that wrap primitives, rather than type abbreviations:

```fsharp
// Good -- a distinct type; the compiler prevents mixing with plain strings
type EmailAddress = EmailAddress of string

// Bad -- just an alias; offers no type safety
type EmailAddress = string
```

### Records

Records model product types with named fields:

```fsharp
type AgeLocale =
    { JustBorn: string
      Delimiter: string
      Weeks: string
      Months: string
      Years: string
      Half: string }
```

Records are immutable by default. Use copy-and-update syntax for modifications:

```fsharp
let updated = { locale with Delimiter = " " }
```

### Option Type

Use `Option<'T>` for values that may or may not be present. Prefer it over null:

```fsharp
let tryFindLocale (code: string) : AgeLocale option =
    localeMap |> Map.tryFind code

// Usage
match tryFindLocale "en" with
| Some locale -> formatAge dob now locale
| None -> "Unknown locale"
```

### Result Type

Use `Result<'T, 'TError>` for operations that can fail with a known error:

```fsharp
type ValidationError =
    | DateInFuture
    | NegativeAge

let validateDates (dob: DateTime) (asOf: DateTime) : Result<unit, ValidationError> =
    if asOf < dob then Error NegativeAge
    else Ok ()
```

### Type Abbreviations

Type abbreviations are aliases, not new types. Use them for shortening complex signatures, not for domain modeling:

```fsharp
// Good -- shortens a complex signature
type Computation = DeviceDescriptor -> Variable -> Function

// Bad -- does not create a real abstraction
type BufferSize = int
```

For domain modeling, prefer single-case discriminated unions (see above).

### Units of Measure

F# supports compile-time units of measure for numeric types:

```fsharp
[<Measure>] type kg
[<Measure>] type m
[<Measure>] type s

let speed (distance: float<m>) (time: float<s>) : float<m/s> =
    distance / time
```

Units are erased at runtime and not visible to other .NET languages.

### Struct Annotations

For small, frequently allocated types (16 bytes or less), consider `[<Struct>]` for performance:

```fsharp
[<Struct>]
type Point = { X: float; Y: float }

[<Struct>]
type Name = Name of string
```

Always measure before and after. Structs are not always faster due to copy overhead.

---

## 4. Module Design

### Module vs. Namespace

| Feature | Namespace | Module |
|---|---|---|
| Can span multiple files | Yes | No |
| Can contain bare `let` functions | No (needs inner module) | Yes |
| .NET compilation target | .NET namespace | Static class |
| Consumable from C# naturally | Yes | Via `using static` |

**Prefer namespaces at the top level** for publicly consumable code:

```fsharp
namespace SayableAge

module Formatter =
    let formatAge dateOfBirth asOf locale = ...

module Types =
    type AgeLocale = { ... }
```

**Use modules for grouping related functions:**

```fsharp
module Formatter =
    let formatAge dateOfBirth asOf locale = ...

    let private calculateMonths (dob: DateTime) (asOf: DateTime) = ...
```

### `[<AutoOpen>]`

Use sparingly. `[<AutoOpen>]` brings all module contents into scope when the parent namespace is opened, which can pollute the namespace.

Acceptable use: a private helper module within an API module:

```fsharp
module MyAPI =
    [<AutoOpen>]
    module private Helpers =
        let helper1 x y z = ...

    let myFunction x =
        helper1 x 1 2  // No qualification needed
```

### `[<RequireQualifiedAccess>]`

Use when module function names might conflict with other modules, or when qualified access improves readability:

```fsharp
[<RequireQualifiedAccess>]
module StringTokenization =
    let parse s = ...

// Must use qualified name
let result = StringTokenization.parse input
```

This is strongly recommended for modules that extend `FSharp.Core` modules like `Seq`, `List`, or `Array`.

### Access Control

- Make types and members non-public by default; expose only what consumers need.
- Keep helper functions `private`.
- Use `internal` for assembly-level visibility.

```fsharp
module Formatter =
    // Public API
    let formatAge dateOfBirth asOf locale = ...

    // Internal helper -- not exposed
    let private selectUnit ageInDays = ...
```

### Signature Files (.fsi)

Signature files provide an explicit declaration of a module's public API. They are useful for:

- Documenting the public surface of a stable library.
- Preventing accidental API changes.
- Separating interface from implementation.

```fsharp
// Formatter.fsi
module SayableAge.Formatter

val formatAge: dateOfBirth: System.DateTime -> asOf: System.DateTime -> locale: AgeLocale -> string
```

Use signature files once an API has stabilized. They add friction to changes, which is the point.

---

## 5. Functional Patterns

### Pipeline Operator (`|>`)

The pipe operator threads a value through a chain of transformations. It is the bread and butter of F# style:

```fsharp
let result =
    input
    |> validate
    |> transform
    |> serialize
```

Pipelines improve readability by making data flow left-to-right, top-to-bottom.

### Function Composition (`>>`)

Compose functions point-free when the resulting pipeline is still clear:

```fsharp
let processInput = validate >> transform >> serialize
```

Avoid excessive point-free composition. Named parameters are important for readability and debugging. If intermediate values help understanding, use `let` bindings:

```fsharp
// Prefer this when clarity matters
let processInput input =
    let validated = validate input
    let transformed = transform validated
    serialize transformed
```

### Partial Application

Partial application is powerful for internal code and reducing boilerplate:

```fsharp
// Creating a specialized version of a general function
let formatWithLocale = formatAge locale

// Using it
dates |> List.map (fun (dob, asOf) -> formatWithLocale dob asOf)
```

**Do not use partial application in public APIs.** Curried functions lose parameter names in tooling, making the API harder to understand:

```fsharp
// In tooling, this shows: string -> int -> unit (no parameter names)
let funcWithApplication = printfn "Name: %s, Age: %d"

// This shows: name:string -> age:int -> unit (parameter names visible)
let func name age = printfn "Name: %s, Age: %d" name age
```

### Computation Expressions

F# computation expressions provide syntactic sugar for monadic patterns. The most common are `async`, `task`, `seq`, and `result`:

```fsharp
let fetchData url = async {
    let! response = Http.AsyncRequest(url)
    let! body = response.Content.ReadAsStringAsync() |> Async.AwaitTask
    return parseJson body
}

let numbers = seq {
    for i in 1..10 do
        if i % 2 = 0 then
            yield i
}
```

For list and array comprehensions, prefer `->` over `do ... yield` when a value is always generated:

```fsharp
// Good
let squares = [ for x in 1..10 -> x * x ]

// Less preferred
let squares = [ for x in 1..10 do yield x * x ]
```

---

## 6. Pattern Matching

### Match Expressions

Pattern matching is fundamental to F#. Always strive for exhaustive matches:

```fsharp
let describe category =
    match category with
    | Zero -> "zero"
    | One -> "one"
    | Two -> "two"
    | Few -> "few"
    | Many -> "many"
    | Other -> "other"
```

### When Guards

Use `when` for conditions that cannot be expressed purely through patterns:

```fsharp
let classifyAge ageInDays =
    match ageInDays with
    | d when d < 0 -> Error "negative age"
    | 0 -> Ok JustBorn
    | d when d < 7 * 13 -> Ok (InWeeks (d / 7))
    | d when d < 365 * 2 -> Ok (InMonths (d / 30))
    | d -> Ok (InYears (d / 365, d % 365 >= 183))
```

### Active Patterns

Active patterns let you define custom decomposition logic for use in `match` expressions.

**Partial active patterns** return `Option`:

```fsharp
let (|Integer|_|) (s: string) =
    match System.Int32.TryParse(s) with
    | true, v -> Some v
    | _ -> None

match input with
| Integer n -> printfn "Got integer: %d" n
| _ -> printfn "Not an integer"
```

**Complete active patterns** partition the input exhaustively:

```fsharp
let (|Even|Odd|) n =
    if n % 2 = 0 then Even else Odd

match number with
| Even -> "even"
| Odd -> "odd"
```

### The `function` Keyword

The `function` keyword combines a function definition with a match expression on its last argument:

```fsharp
let rec length = function
    | [] -> 0
    | _ :: tail -> 1 + length tail
```

Prefer explicit `match` in most cases for clarity. `function` is useful in pipeline lambda arguments:

```fsharp
items
|> List.map (function
    | Some x -> x
    | None -> defaultValue)
```

### Exhaustive Matching

Always handle all cases. Avoid wildcard `_` catch-alls in discriminated union matches unless you deliberately want to ignore new cases:

```fsharp
// Good -- compiler warns if a new case is added
match category with
| Zero -> "zero"
| One -> "one"
| Two -> "two"
| Few -> "few"
| Many -> "many"
| Other -> "other"

// Risky -- silently ignores any new cases added later
match category with
| One -> "one"
| _ -> "other"
```

---

## 7. Error Handling

### Choosing Between Option, Result, and Exceptions

| Mechanism | Use When |
|---|---|
| `Option<'T>` | A value may or may not exist; absence is normal, not exceptional |
| `Result<'T, 'TError>` | An operation can fail with a known, domain-level error; caller should handle it |
| Exceptions | An unexpected, truly exceptional condition; a programming error; or interop with .NET APIs |

### Using Option

```fsharp
let tryDivide x y =
    if y = 0 then None
    else Some(x / y)

match tryDivide 10 0 with
| Some result -> printfn "Result: %d" result
| None -> printfn "Cannot divide by zero"
```

### Using Result

Model domain errors as discriminated unions:

```fsharp
type AgeError =
    | BirthInFuture
    | SameDay

let validateAge (dob: DateTime) (asOf: DateTime) =
    if asOf < dob then Error BirthInFuture
    elif asOf = dob then Error SameDay
    else Ok (asOf - dob).Days
```

### Railway-Oriented Programming

Chain `Result`-returning functions by using `Result.bind` and `Result.map`:

```fsharp
let bind f result =
    match result with
    | Ok value -> f value
    | Error e -> Error e

let map f result =
    match result with
    | Ok value -> Ok (f value)
    | Error e -> Error e

// Compose a pipeline of operations that can fail
let processRequest input =
    input
    |> validate
    |> Result.bind transform
    |> Result.map serialize
```

This keeps the "happy path" clean and automatically short-circuits on the first error.

### Exceptions

When exceptions are appropriate, prefer the specific F# exception-raising functions:

| Function | Exception Raised | Use Case |
|---|---|---|
| `nullArg "paramName"` | `ArgumentNullException` | Null argument detected |
| `invalidArg "paramName" "message"` | `ArgumentException` | Invalid argument value |
| `invalidOp "message"` | `InvalidOperationException` | Invalid state |
| `raise (SomeException(...))` | Any specific exception | General-purpose |

Avoid `failwith` and `failwithf` -- they raise the base `System.Exception`, which is too generic.

```fsharp
// Good
let processValue value =
    if value < 0 then invalidArg (nameof value) "Value must be non-negative"
    else value * 2

// Bad -- raises base Exception
let processValue value =
    if value < 0 then failwith "Value must be non-negative"
    else value * 2
```

### Do Not Over-Wrap Exceptions in Result

The Microsoft guidelines explicitly warn against replacing all exception handling with `Result`. Exceptions carry stack traces and diagnostic information. Wrapping every exception in `Result` leads to deeply nested types like `Result<Result<MyType, string>, string list>` and "stringly typed" error matching:

```fsharp
// Problematic -- callers can only string-match on errors
let tryReadFile path =
    try System.IO.File.ReadAllText path |> Ok
    with e -> Error e.Message
```

Instead, catch *specific* exceptions and return meaningful values:

```fsharp
// Better -- FileNotFoundException has a clear meaning
let tryReadFileIfPresent path =
    try System.IO.File.ReadAllText path |> Some
    with :? System.IO.FileNotFoundException -> None
```

---

## 8. Collections

### Choosing the Right Collection

| Collection | Characteristics | Use When |
|---|---|---|
| `list` | Immutable singly-linked list; O(1) prepend, O(n) index | Default for functional pipelines; small to medium sequences; pattern matching on head/tail |
| `array` | Mutable, fixed-size, contiguous memory; O(1) index | Performance-critical indexed access; interop with .NET APIs; large datasets |
| `seq` (alias for `IEnumerable<T>`) | Lazy evaluation | Large or infinite sequences; when you want deferred computation; API boundaries |
| `Map<'K, 'V>` | Immutable balanced tree; O(log n) lookup | Associative data with immutable semantics |
| `Set<'T>` | Immutable balanced tree; O(log n) membership test | Unique element collections |
| `ResizeArray<'T>` (alias for `List<T>`) | Mutable, growable array | When you need .NET `List<T>` semantics |
| `dict` / `Dictionary<'K, 'V>` | Mutable hash table; O(1) average lookup | Performance-critical lookup; interop |

### List Operations

```fsharp
// Construction
let xs = [ 1; 2; 3 ]
let ys = 0 :: xs              // prepend
let zs = xs @ ys              // concatenation (use sparingly; O(n))

// Pipeline processing
xs
|> List.filter (fun x -> x > 1)
|> List.map (fun x -> x * 2)
|> List.sum
```

### Array Operations

```fsharp
let arr = [| 1; 2; 3 |]
let value = arr[1]            // O(1) indexed access

arr
|> Array.filter (fun x -> x > 1)
|> Array.map (fun x -> x * 2)
```

### Sequence Operations

```fsharp
// Lazy -- elements computed on demand
let naturals = Seq.initInfinite id

naturals
|> Seq.filter (fun x -> x % 2 = 0)
|> Seq.take 10
|> Seq.toList
```

### Map and Set

```fsharp
let localeMap =
    Map.ofList [ ("en", englishLocale); ("fr", frenchLocale) ]

let locale = localeMap |> Map.tryFind "en"

let uniqueItems = Set.ofList [ 1; 2; 2; 3 ]  // { 1; 2; 3 }
```

### Collection Function Naming Conventions

Follow the naming patterns established by `FSharp.Core`:

| Pattern | Examples |
|---|---|
| `Module.verb` | `List.map`, `Array.filter`, `Seq.sort` |
| `Module.tryVerb` | `List.tryFind`, `Map.tryFind` |
| `Module.verbBy` | `List.sortBy`, `List.groupBy`, `List.maxBy` |
| `Module.ofX` / `Module.toX` | `List.ofArray`, `Array.toList`, `Set.ofList` |

### Prefer `seq<'T>` for API Boundaries

When defining public APIs that accept or return collections, prefer `seq<'T>` (i.e., `IEnumerable<'T>`) for maximum flexibility:

```fsharp
// Good -- callers can pass any collection
let processItems (items: seq<string>) = ...

// Less flexible -- requires a specific collection type
let processItems (items: string list) = ...
```

---

## 9. Common Idioms

### `let` Bindings

`let` bindings are the fundamental mechanism for naming values and functions:

```fsharp
// Value binding
let maxAge = 150

// Function binding
let add x y = x + y

// Destructuring binding
let (x, y) = getTuple ()

// Type-annotated binding
let formatAge (dob: DateTime) (asOf: DateTime) : string = ...
```

### `let` vs. `fun`

Prefer named `let` functions over anonymous `fun` lambdas when the function will be reused or benefits from a descriptive name:

```fsharp
// Good -- the function has a name
let isAdult person = person.Age >= 18
people |> List.filter isAdult

// Acceptable -- lambda for one-off transforms
people |> List.map (fun p -> p.Name)

// Unnecessary lambda -- just pass the function directly
people |> List.map (fun p -> getName p)  // Bad
people |> List.map getName               // Good
```

### Type Annotations

F# has powerful type inference. Add type annotations:

- On **public API boundaries** (function parameters and return types).
- When the compiler **cannot infer the type**.
- When annotations **improve readability** of complex code.

```fsharp
// Public API -- annotate for clarity
let formatAge (dateOfBirth: DateTime) (asOf: DateTime) (locale: AgeLocale) : string =
    ...

// Internal code -- inference is usually sufficient
let helper x y =
    x + y
```

### Type Inference and Generics

Let the compiler infer types when possible, but give meaningful names to generic parameters in public APIs:

```fsharp
// Good -- meaningful generic parameter name
let lookup (key: 'Key) (map: Map<'Key, 'Value>) : 'Value option =
    Map.tryFind key map

// Less helpful -- single-letter names in domain code
let lookup (key: 'a) (map: Map<'a, 'b>) : 'b option = ...
```

### String Interpolation

Prefer interpolated strings over `sprintf` for readability:

```fsharp
// Good
let message = $"Age: {years} years and {months} months"

// Older style -- still valid but less readable
let message = sprintf "Age: %d years and %d months" years months
```

### The `ignore` Function

Use `ignore` to discard a return value explicitly:

```fsharp
// Good -- makes intent clear
sideEffectFunction () |> ignore

// Bad -- silently discards
sideEffectFunction ()  // If this returns a value, the compiler warns
```

### XML Documentation

Provide XML documentation on public types and functions:

```fsharp
/// Formats a human-readable age string.
///
/// <param name="dateOfBirth">The date of birth.</param>
/// <param name="asOf">The reference date to calculate age from.</param>
/// <param name="locale">The locale controlling output language.</param>
/// <returns>A human-readable age string like "6 weeks" or "3 1/2 years".</returns>
let formatAge (dateOfBirth: DateTime) (asOf: DateTime) (locale: AgeLocale) : string =
    ...
```

---

## 10. Things to Avoid

### Mutable State

Avoid `mutable` in general code. F# values are immutable by default, and this prevents entire classes of bugs:

```fsharp
// Bad
let mutable total = 0
for x in items do
    total <- total + x

// Good
let total = items |> List.sum
```

When mutation is genuinely needed for performance, encapsulate it behind an immutable interface:

```fsharp
// Acceptable -- mutation is an implementation detail, not exposed
let contains value (array: 'T[]) =
    let mutable found = false
    let mutable i = 0
    while not found && i < array.Length do
        found <- value = array[i]
        i <- i + 1
    found
```

Prefer `let mutable` over `ref` cells when mutation is required:

```fsharp
// Good
let mutable acc = 0
acc <- acc + 1

// Bad -- ref cells are harder to read
let acc = ref 0
acc := !acc + 1
```

### Null

F#-declared types do not support `null` by default. Never introduce it:

- **Do not use `AllowNullLiteral`** on F# types.
- **Do not use `Unchecked.defaultof<_>`** unless required for interop or high-performance code.
- **Do not use `DefaultValue`** on record or class fields.
- Use `Option<'T>` instead of null to represent absence.

At .NET interop boundaries, check for null early and convert to `Option`:

```fsharp
let getLineFromStream (stream: System.IO.StreamReader) =
    stream.ReadLine() |> Option.ofObj
```

### Excessive Use of Classes

F# supports classes, but prefer:

- **Records** for data.
- **Discriminated unions** for choices.
- **Modules with functions** for behavior.

Use classes when you need:

- Encapsulated mutable state.
- Interface implementations with state.
- Interop with .NET frameworks expecting classes.

### Inheritance Hierarchies

Prefer composition over inheritance. Use interfaces and discriminated unions instead of deep class hierarchies:

```fsharp
// Bad -- inheritance hierarchy
type Shape() =
    abstract member Area: float
type Circle(radius) =
    inherit Shape()
    override _.Area = Math.PI * radius * radius

// Good -- discriminated union
type Shape =
    | Circle of radius: float
    | Rectangle of width: float * height: float

let area = function
    | Circle r -> Math.PI * r * r
    | Rectangle(w, h) -> w * h
```

### Imperative Loops Where Functional Code Works

Replace `for`/`while` loops with `List.map`, `List.filter`, `List.fold`, and other higher-order functions:

```fsharp
// Bad
let mutable results = []
for item in items do
    if item > 0 then
        results <- (item * 2) :: results
let results = List.rev results

// Good
let results =
    items
    |> List.filter (fun item -> item > 0)
    |> List.map (fun item -> item * 2)
```

### Excessive Point-Free Programming

Point-free code (no explicit arguments) hurts readability and debugging. Intermediate values cannot be inspected, and tooling cannot show parameter names:

```fsharp
// Too point-free -- hard to read, hard to debug
let processData = List.filter isValid >> List.map transform >> List.sortBy key

// Clearer
let processData data =
    data
    |> List.filter isValid
    |> List.map transform
    |> List.sortBy key
```

### Nested Result Types

Avoid deeply nested `Result` or `Option` types:

```fsharp
// Bad -- deeply nested, painful to unwrap
Result<Result<MyType, string>, string list>

// Better -- flatten with bind, or use a single error union
type AppError =
    | ValidationError of string
    | ProcessingError of string list
```

### Side Effects in Module Initialization

Do not perform I/O or allocate non-thread-safe resources in module-level `let` bindings. Module bindings are compiled as static initializers, and failures manifest as opaque `TypeInitializationException`:

```fsharp
// Bad -- side effects at module load
module Config =
    let settings = File.ReadAllText "/path/to/config.json"

// Good -- use a class or function to defer initialization
type Config(path) =
    member _.Settings = File.ReadAllText path
```

---

## 11. Tooling

### Fantomas (Code Formatter)

[Fantomas](https://github.com/fsprojects/fantomas) is the community-standard F# code formatter. Its defaults align with the official Microsoft formatting guidelines.

**Installation:**

```bash
dotnet tool install fantomas
```

**Usage:**

```bash
# Format a file
dotnet fantomas MyFile.fs

# Format all F# files in a directory
dotnet fantomas src/

# Check formatting without modifying files
dotnet fantomas --check src/
```

**Configuration via `.editorconfig`:**

```editorconfig
[*.fs]
indent_size = 4
max_line_length = 120
fsharp_space_before_lowercase_invocation = true
fsharp_space_before_uppercase_invocation = false
fsharp_space_before_member = false
fsharp_space_before_colon = false
fsharp_space_after_comma = true
fsharp_space_around_delimiter = true
fsharp_multiline_bracket_style = aligned
fsharp_newline_between_type_definition_and_members = true
fsharp_max_record_width = 40
fsharp_max_array_or_list_width = 80
fsharp_max_if_then_else_short_width = 60
fsharp_max_value_binding_width = 80
fsharp_max_function_binding_width = 40
```

Key Fantomas settings:

| Setting | Default | Description |
|---|---|---|
| `indent_size` | 4 | Spaces per indentation level |
| `max_line_length` | 120 | Column at which lines break |
| `fsharp_multiline_bracket_style` | `aligned` | `cramped`, `aligned`, or `stroustrup` |
| `fsharp_space_before_lowercase_invocation` | `true` | Space before `(` in lowercase function calls |
| `fsharp_space_before_uppercase_invocation` | `false` | Space before `(` in uppercase/method calls |
| `fsharp_max_record_width` | 40 | Records wider than this go multiline |
| `fsharp_bar_before_discriminated_union_declaration` | `false` | Whether to put `\|` before every DU case |

### FSharpLint (Static Analyzer)

[FSharpLint](https://github.com/fsprojects/FSharpLint) provides static analysis and linting:

```bash
dotnet tool install dotnet-fsharplint
dotnet fsharplint lint MyProject.fsproj
```

Configurable via `fsharplint.json`. Rules cover naming conventions, source length, formatting, hints for simplification, and more.

### Ionide (Editor Support)

[Ionide](https://ionide.io/) is the primary F# extension for Visual Studio Code. It provides:

- IntelliSense and type information.
- Error highlighting.
- Code navigation (go to definition, find references).
- Fantomas integration (format on save).
- Inline type hints.

### .NET Analyzers

The .NET SDK includes built-in analyzers. For F#-specific analysis:

- **FSharp.Analyzers.SDK** -- a framework for building custom F# analyzers.
- **G-Research analyzers** -- community analyzers for common F# issues.

Configure analyzers in the `.fsproj` file:

```xml
<PropertyGroup>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <OtherFlags>--warnon:3390</OtherFlags>
</PropertyGroup>
```

### dotnet fsi (F# Interactive)

F# Interactive (FSI) is invaluable for exploring and testing code:

```bash
dotnet fsi

> let x = 42;;
val x: int = 42

> List.map (fun n -> n * 2) [1; 2; 3];;
val it: int list = [2; 4; 6]
```

Use `.fsx` script files for prototyping and exploration.
