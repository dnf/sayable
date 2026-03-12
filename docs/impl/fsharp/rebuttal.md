# F# Style Guide -- Senior Engineering Review

Reviewer: Senior Staff Engineer
Date: 2026-03-11
Document under review: `docs/impl/fsharp/README.md`

---

## Overall Assessment

The guide is well-structured and covers most important areas of F# style. The sourcing is solid, the formatting section is thorough, and the advice on discriminated unions, pattern matching, and error handling is largely sound. However, there are several guidelines that are either technically incorrect, overly dogmatic, contextually inappropriate for this project, or subtly misleading. This review addresses each in detail.

---

## Disagreement 1: Blanket Prohibition of `failwith` and `failwithf`

### Quoted Guideline

> Avoid `failwith` and `failwithf` -- they raise the base `System.Exception`, which is too generic.

### Why It Is Problematic

This is a common oversimplification. `failwith` raises `System.Exception` -- that is correct. But the advice to *never* use it conflates two different concerns: **API boundary error reporting** and **internal assertion/invariant enforcement**.

Inside a function that has already validated its inputs, `failwith` is the idiomatic way to signal "this should be unreachable." Replacing it with `invalidArg` or `invalidOp` in an internal match arm that represents a logic error (not an invalid argument) is semantically wrong -- you are lying about the nature of the failure. The .NET exception hierarchy matters: `ArgumentException` means "the caller passed bad data," while a bare `Exception` from `failwith` in a wildcard match arm means "the programmer made a mistake."

Additionally, `failwithf` (or `failwith $"..."` with interpolation) is standard practice in F# codebases including FSharp.Core itself. Telling engineers to avoid it entirely pushes them toward more verbose patterns that obscure intent.

### Recommended Alternative

Replace the blanket prohibition with nuanced guidance:

- At **public API boundaries**, prefer `invalidArg`, `nullArg`, or `invalidOp` because they communicate specific failure modes to callers.
- For **internal invariant violations** (unreachable code, exhaustive match fallbacks), `failwith` is appropriate and idiomatic. It signals a programming error, not a caller error.
- Avoid `failwith` for domain-level errors that callers should handle -- use `Result` or `Option` instead.

---

## Disagreement 2: `open` Statement Ordering -- Topological Over Alphabetical

### Quoted Guideline

> Sort `open` statements **topologically** (by dependency layer), not alphabetically. Separate layers with blank lines.

### Why It Is Problematic

This advice creates an ordering that is **implicit, subjective, and impossible to enforce automatically**. What counts as a "dependency layer"? Is `System.Collections.Generic` in the same layer as `System`? If I open `SayableAge.Types` and `SayableAge.Locales`, which is "lower"?

Topological ordering requires every developer to maintain a mental model of the module dependency graph. It cannot be validated by a linter. It generates pointless disagreements in code review. And it is at odds with what the F# community actually does -- Fantomas does not sort opens at all, and most large F# codebases (Fable, FAKE, Ionide) use either alphabetical ordering or no consistent ordering.

The cited Microsoft style guide does not actually mandate topological ordering of opens. It discusses *namespace design* topologically, not import ordering.

### Recommended Alternative

Adopt a pragmatic two-group rule:

1. `System.*` and external framework namespaces first.
2. Project-internal namespaces second.

Within each group, alphabetical ordering is fine. This is enforceable, unambiguous, and matches what developers do instinctively.

---

## Disagreement 3: `seq<'T>` as Default for API Boundaries

### Quoted Guideline

> When defining public APIs that accept or return collections, prefer `seq<'T>` (i.e., `IEnumerable<'T>`) for maximum flexibility.

### Why It Is Problematic

This is C# advice transplanted into F# without considering F#'s different trade-offs. In F#:

1. **`seq<'T>` is lazy and re-evaluable.** Passing a `seq` to a function that iterates it twice causes double evaluation. This is a common source of subtle bugs that `list` and `array` avoid entirely.
2. **`seq<'T>` has no structural equality or comparison.** You cannot use `=` on two seqs, you cannot put them in sets or use them as map keys. This matters in F# far more than in C#.
3. **`seq<'T>` is not pattern-matchable.** You lose one of F#'s core capabilities.
4. **F# collection modules are type-specific.** `List.map`, `Array.filter`, etc. If your API returns `seq`, the caller must convert before using the rich typed collection functions, or use `Seq.*` which is less efficient for materialized data.
5. **In a zero-dependency library like sayable-age**, there is no interop concern. The consumers are F# code. Returning `list` or `array` is more useful.

The Microsoft Component Design Guidelines do suggest `seq<'T>` for *C#-facing* APIs. But for F#-to-F# code, this advice creates friction rather than reducing it.

### Recommended Alternative

For F#-centric libraries:

- Prefer `list` for return types and small collections (it is the default F# collection).
- Prefer `array` when performance or .NET interop matters.
- Use `seq<'T>` for *input* parameters when you want to accept any collection, and for *deferred computation* scenarios.
- Use `seq<'T>` for return types only when laziness is intentional and documented.

---

## Disagreement 4: Discouraging the `function` Keyword

### Quoted Guideline

> Prefer explicit `match` in most cases for clarity. `function` is useful in pipeline lambda arguments.

### Why It Is Problematic

This understates the value of `function`. The `function` keyword is not merely a shorthand -- it is the *original* ML pattern-matching construct, and in many cases it produces code that is more readable, not less:

```fsharp
// With function -- clear, concise
let rec depth = function
    | Leaf -> 0
    | Node(_, l, r) -> 1 + max (depth l) (depth r)

// With match -- the parameter name adds nothing
let rec depth tree =
    match tree with
    | Leaf -> 0
    | Node(_, l, r) -> 1 + max (depth l) (depth r)
```

When the function's sole purpose is to dispatch on the structure of its argument, `function` is *more* readable because it eliminates the noise of naming an argument that is never referenced outside the patterns. The guide should acknowledge this instead of treating `function` as a second-class citizen.

### Recommended Alternative

Use `function` when a function's body is a single match expression on its last argument and the argument name would be meaningless (e.g., `x`, `value`, `input`). Use `match` when the argument has a meaningful name, when you need to reference it outside the match, or when the function does work before matching.

---

## Disagreement 5: Struct Annotation Size Threshold

### Quoted Guideline

> For small, frequently allocated types (16 bytes or less), consider `[<Struct>]` for performance.

### Why It Is Problematic

The 16-byte threshold is an outdated .NET Framework heuristic. On modern .NET (6+), the JIT inlines and optimizes struct passing more aggressively, and the crossover point depends on:

- Whether the struct is passed by value or by reference (`inref<'T>`, `byref<'T>`).
- Whether it is used in generic contexts (which may box it).
- Whether it lives on the stack or gets captured in a closure (which forces heap allocation regardless).
- The specific CPU architecture and cache line size.

Stating "16 bytes" as a rule gives false confidence. An engineer reads it, measures their struct at 12 bytes, marks it `[<Struct>]`, and then gets worse performance because it is captured in a closure inside a `List.map` lambda.

### Recommended Alternative

Remove the specific byte threshold. Instead:

- Advise using `[<Struct>]` for types that are allocated in hot loops and are not captured by closures.
- Always benchmark with realistic workloads. The only valid threshold is the one your profiler gives you.
- Note that struct records and struct DUs have restrictions (no recursive types, value-type semantics on assignment) that affect correctness, not just performance.

---

## Disagreement 6: The Mutable State Escape-Hatch Example

### Quoted Guideline

The guide presents this as "acceptable" mutation:

```fsharp
let contains value (array: 'T[]) =
    let mutable found = false
    let mutable i = 0
    while not found && i < array.Length do
        found <- value = array[i]
        i <- i + 1
    found
```

### Why It Is Problematic

This example is misleading for two reasons:

1. **It reimplements `Array.contains`**, which already exists in FSharp.Core and is optimized. A style guide should not show engineers how to hand-roll standard library functions as an example of "acceptable" mutation.
2. **The equality constraint is unconstrained.** Using `=` on a generic `'T` requires structural equality, but the type annotation does not express this. The actual `Array.contains` function handles this correctly.

More importantly, the example teaches engineers to write imperative loops when F# already provides the function. This directly contradicts the guide's own Section 10 advice to "replace for/while loops with higher-order functions."

### Recommended Alternative

If the guide needs a mutation example, use one where no standard library function exists -- like building a lookup table, populating a mutable cache, or interop with a .NET API that requires a mutable buffer. The example should illustrate *why* mutation is necessary, not just *how* to do it.

---

## Disagreement 7: Railway-Oriented Programming -- Redefining Standard Functions

### Quoted Guideline

The guide defines `bind` and `map` from scratch:

```fsharp
let bind f result =
    match result with
    | Ok value -> f value
    | Error e -> Error e

let map f result =
    match result with
    | Ok value -> Ok (f value)
    | Error e -> Error e
```

### Why It Is Problematic

`Result.bind` and `Result.map` have been in FSharp.Core since F# 4.1 (2017). Redefining them in a style guide:

1. Implies they do not exist, encouraging engineers to write their own.
2. Introduces potential for subtly different semantics if someone copies and modifies the guide's version.
3. Wastes the reader's time on something they can look up in the standard library docs.

### Recommended Alternative

Show only the *usage* of `Result.bind` and `Result.map`, with a note that they are in FSharp.Core. If the guide wants to explain the concept, reference Scott Wlaschin's Railway-Oriented Programming article directly rather than re-implementing the functions inline.

---

## Disagreement 8: XML Documentation Style

### Quoted Guideline

```fsharp
/// Formats a human-readable age string.
///
/// <param name="dateOfBirth">The date of birth.</param>
/// <param name="asOf">The reference date to calculate age from.</param>
/// <param name="locale">The locale controlling output language.</param>
/// <returns>A human-readable age string like "6 weeks" or "3 1/2 years".</returns>
let formatAge (dateOfBirth: DateTime) (asOf: DateTime) (locale: AgeLocale) : string =
```

### Why It Is Problematic

The guide shows verbose XML `<param>` tags as the recommended style. For F# functions with typed, well-named parameters, this is pure noise. The parameter names `dateOfBirth`, `asOf`, and `locale` are self-documenting. The type annotations are visible. Repeating "The date of birth" for `dateOfBirth` adds zero information.

XML doc tags exist for C# interop scenarios where tools like IntelliSense need structured metadata. In a pure F# library (which this project is), a concise `///` summary is sufficient and much more likely to be maintained.

### Recommended Alternative

Recommend a concise `///` summary for all public APIs. Reserve full XML `<param>`/`<returns>` tags for libraries that will be consumed from C# or that generate API reference documentation. For F#-to-F# code, well-named parameters with type annotations are the documentation.

---

## Disagreement 9: Discouraging Type Abbreviations for Domain Types

### Quoted Guideline

> ```fsharp
> // Bad -- does not create a real abstraction
> type BufferSize = int
> ```

### Why It Is Problematic

The guide presents single-case DUs as the only acceptable alternative to type abbreviations for domain modeling. While single-case DUs do provide compile-time safety, they come with costs:

1. **Wrapping and unwrapping overhead** -- every use requires pattern matching or a `.Value`-style accessor.
2. **Serialization friction** -- JSON serializers, ORMs, and other .NET tools do not understand single-case DUs without custom converters.
3. **Performance cost** -- each single-case DU is a heap allocation (unless marked `[<Struct>]`, which has its own trade-offs).

Type abbreviations are appropriate when you want **documentation and readability** without **enforcement**. They are not "bad" -- they serve a different purpose. Calling `type BufferSize = int` "bad" conflates "not type-safe" with "not useful."

### Recommended Alternative

Present both options honestly:

- **Type abbreviations** provide documentation and readability. They are aliases, not new types. Use them when the overhead of wrapping/unwrapping is not justified, or when interop requires the underlying type.
- **Single-case DUs** provide compile-time type safety. Use them when accidentally mixing two values of the same underlying type would be a bug (e.g., `CustomerId` vs `OrderId`, both `int`).

---

## Disagreement 10: Missing Guidance on Recursive Functions and Tail Calls

### What Is Missing

The guide covers pattern matching, pipelines, and collections but says nothing about recursion -- the fundamental looping mechanism in functional programming. There is no mention of:

- `rec` keyword usage and when to prefer it over higher-order functions.
- Tail-call optimization and the `[<TailCall>]` attribute (F# 8+).
- The performance difference between tail-recursive and non-tail-recursive functions.
- When to use accumulator patterns vs. continuation-passing style.

For a style guide intended for "code auditing F# implementations," this is a significant omission. An auditor who does not know to check for stack-overflow-prone non-tail-recursive functions is missing one of the most important F# code review checks.

### Recommended Addition

Add a section on recursion covering:

- Prefer higher-order functions (`List.fold`, `List.map`, etc.) over explicit recursion when they fit.
- When recursion is necessary, ensure it is tail-recursive for unbounded inputs.
- Use the `[<TailCall>]` attribute (F# 8+) to get compiler warnings if tail-call optimization cannot be applied.
- Show the accumulator pattern for converting non-tail-recursive functions.

---

## Disagreement 11: Computation Expressions -- Misleading `yield` Advice

### Quoted Guideline

> For list and array comprehensions, prefer `->` over `do ... yield` when a value is always generated:
>
> ```fsharp
> // Good
> let squares = [ for x in 1..10 -> x * x ]
>
> // Less preferred
> let squares = [ for x in 1..10 do yield x * x ]
> ```

### Why It Is Problematic

Since F# 6, `yield` is implicit in computation expressions. The "less preferred" example is actually how nobody writes F# anymore -- the modern equivalent is simply:

```fsharp
let squares = [ for x in 1..10 do x * x ]
```

The `->` syntax is older and less flexible (it cannot be combined with `if` guards in the same expression without switching syntax). The guide's advice effectively points engineers toward the oldest syntax while deprecating a syntax that is not even how modern F# works.

### Recommended Alternative

Show the modern implicit-yield style as the default:

```fsharp
let squares = [ for x in 1..10 do x * x ]

let evens = [
    for x in 1..20 do
        if x % 2 = 0 then x
]
```

Mention `->` as a concise alternative for simple projections, not as the preferred form.

---

## Disagreement 12: Incomplete Guidance on Record Formatting Styles

### Quoted Guideline

> Three accepted multiline styles exist: **Cramped** (default), **Aligned**, and **Stroustrup**. Pick one and stay consistent.

### Why It Is Problematic

The guide labels Cramped as the "historical default" but fails to note that Fantomas changed its default to **Aligned** (called `aligned` in `.editorconfig`) as of Fantomas 5.x. The guide's own `.editorconfig` example later sets `fsharp_multiline_bracket_style = aligned`, contradicting the "cramped is default" framing.

Additionally, the Fantomas configuration table says the default for `fsharp_multiline_bracket_style` is `aligned`, while the prose says `cramped`. This internal inconsistency will confuse engineers trying to configure their project.

### Recommended Alternative

State clearly that Fantomas's current default is Aligned. If the project uses a different style, say so explicitly. Do not present three options as equal when the tooling has already chosen one.

---

## Summary of Actionable Changes

| # | Issue | Severity | Action |
|---|-------|----------|--------|
| 1 | Blanket `failwith` prohibition | High | Add nuance for internal vs. API-boundary usage |
| 2 | Topological `open` ordering | Medium | Replace with enforceable two-group rule |
| 3 | `seq<'T>` as default for API boundaries | High | Correct for F#-centric context |
| 4 | `function` keyword treated as second-class | Medium | Elevate to equal status with `match` |
| 5 | Struct 16-byte threshold | Medium | Remove specific number, advise benchmarking |
| 6 | Mutation example reimplements stdlib | Low | Replace with a non-trivial example |
| 7 | Railway-oriented programming redefines stdlib | Low | Show usage, not reimplementation |
| 8 | Verbose XML doc recommendation | Medium | Recommend concise `///` for F#-to-F# code |
| 9 | Type abbreviations called "bad" | Medium | Present as valid tool with different trade-offs |
| 10 | Missing recursion guidance | High | Add section on tail calls and `[<TailCall>]` |
| 11 | Outdated `yield` / `->` advice | Medium | Update to modern implicit-yield style |
| 12 | Contradictory record formatting defaults | Low | Align prose with Fantomas actual defaults |
