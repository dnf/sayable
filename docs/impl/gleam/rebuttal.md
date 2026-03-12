# Rebuttal: Gleam Style Guide Review

Senior Staff Engineer review of the Gleam style guide at `docs/impl/gleam/README.md`. This document identifies guidelines that are incorrect, misleading, incomplete, or counterproductive, with technical analysis and recommended alternatives.

---

## 1. Incorrect claim: "No `if/else`"

### Quoted guideline

> Gleam does not have `if/else` expressions. Use `case` on booleans instead. This is a deliberate language design choice to keep pattern matching as the single control flow mechanism.

### Problem

This was true historically but is no longer accurate. Gleam 1.4 (released 2024) introduced `bool.guard` and the community has long used `bool.guard` as an early-return mechanism, but more importantly, the `case True/False` pattern is now supplemented by more idiomatic alternatives. The guide presents this as a hard language constraint without acknowledging `bool.guard`, `bool.lazy_guard`, and the `use <- bool.guard(...)` idiom, which the guide itself shows in Section 10 under "Excessive nesting" but fails to connect back here. A reader hitting "No if/else" in Section 10 and then seeing `bool.guard` used casually elsewhere will be confused.

Additionally, the example is misleading because `case is_valid { True -> ... False -> ... }` is often a code smell in Gleam -- it usually means you should be matching on the underlying data rather than a derived boolean.

### Recommendation

Acknowledge that Gleam has no syntactic `if/else` keyword, but immediately introduce `bool.guard` and `bool.lazy_guard` as the idiomatic alternatives for conditional logic that does not involve destructuring. Emphasize that matching on an underlying sum type is almost always preferable to matching on a boolean.

---

## 2. `Option(a)` described as `Result(a, Nil)` -- misleading conflation

### Quoted guideline

> Absence is modeled with `Option(a)` (which is `Result(a, Nil)`).

### Problem

While it is technically true that `gleam/option.{type Option}` is defined as `Option(a) { Some(a) None }` and is *isomorphic* to `Result(a, Nil)`, saying one "is" the other conflates two distinct types with different constructors, different module functions, and different semantic intent. `Option` has constructors `Some` and `None`; `Result` has `Ok` and `Error`. They are not interchangeable in pattern matches, and the `gleam/option` module provides its own set of combinators (`option.map`, `option.unwrap`, `option.to_result`, etc.) distinct from `gleam/result`.

A developer reading this guide who internalizes "Option is just Result(a, Nil)" might:
- Try to pattern match `Option` values with `Ok`/`Error` (compiler error)
- Skip learning the `gleam/option` module entirely
- Use `Result(a, Nil)` everywhere instead of `Option`, losing semantic clarity

### Recommendation

State that Gleam has a dedicated `Option(a)` type in `gleam/option` with `Some(a)` and `None` constructors for representing optional values. Mention that it is structurally similar to `Result(a, Nil)` and that conversion functions exist (`option.to_result`, `result.to_option`), but do not claim one "is" the other.

---

## 3. Tail call optimization claim is overstated

### Quoted guideline

> Gleam optimizes tail-recursive functions (where the recursive call is the last expression). Use an accumulator parameter to make recursion tail-recursive.

### Problem

Whether tail calls are optimized depends on the compilation target, not on Gleam itself. On the Erlang target, the BEAM VM guarantees tail call optimization. On the JavaScript target, tail call optimization is only supported in Safari/JavaScriptCore; V8 and SpiderMonkey do not implement TCO despite it being in the ES2015 spec. Gleam compiling to JavaScript does not magically add TCO to engines that lack it.

For a project like sayable-age that may target both Erlang and JavaScript, this distinction matters. Code that relies on deep tail recursion will work on Erlang but could blow the stack on JavaScript in Node.js.

### Recommendation

State clearly that TCO behavior depends on the compilation target. On Erlang, tail calls are guaranteed to be optimized. On JavaScript, they are not reliably optimized. When targeting JavaScript, prefer `list.fold`, `list.map`, and other stdlib higher-order functions (which use iteration internally on the JS target) over manual recursion for potentially deep recursion.

---

## 4. Missing guidance on `use` with `bool.guard` -- the most important `use` pattern after `result.try`

### Quoted guideline (Section 9, "use expressions beyond Result")

> ```gleam
> // With bool.guard for early returns
> use <- bool.guard(when: list.is_empty(items), return: default)
> ```

### Problem

This is shown as a one-liner example with no explanation of how it works or why it is important. The `use <- bool.guard(...)` pattern is the idiomatic way to do early returns in Gleam, replacing the `if (condition) return early` pattern from imperative languages. It deserves first-class treatment, not a bullet point. The guide should explain:

1. That `bool.guard` takes a condition, a return value, and a continuation
2. That the `use <-` syntax captures the continuation implicitly
3. That this replaces the common "guard clause" pattern from other languages
4. That `bool.lazy_guard` exists for when the return value is expensive to compute

The guide's Section 10 shows the pattern used in practice (the "flat with use" example) but does not explain it. A reader who does not already know Gleam will not understand why `use <- bool.guard(when: n <= 0, return: Error(Nil))` works.

### Recommendation

Add a dedicated subsection explaining the `bool.guard` early-return pattern with a clear before/after example and an explanation of the desugaring.

---

## 5. Import organization guidance is too vague

### Quoted guideline

> Group imports logically: standard library first, then external packages, then internal modules. The formatter does not enforce import ordering, so this is a convention to follow manually.

### Problem

"Group imports logically" is not actionable guidance. The guide does not specify:
- Whether blank lines should separate groups
- How to order imports within each group (alphabetical? by frequency of use?)
- Whether `gleam/` prefixed imports count as "standard library" (they do, but it is not stated)

Looking at the actual project code in `formatter.gleam`, imports are: `gleam/int`, `gleam/string`, then `sayableage/types` with unqualified imports -- matching the convention but not explicitly called out.

### Recommendation

Be specific: standard library (`gleam/*`) first, external packages second, project modules third. Separate groups with a blank line. Within each group, sort alphabetically by module path. This is verifiable in code review.

---

## 6. The `Result` table is helpful but incomplete

### Quoted guideline (Section 6, "Key result module functions" table)

The table lists `try`, `map`, `map_error`, `unwrap`, `lazy_unwrap`, `flatten`, `all`, `values`, `or`, `replace`.

### Problem

The table omits several commonly used functions:
- `is_ok` and `is_error` -- useful in guards and assertions
- `then` -- an alias/alternative to `try` in some contexts
- `partition` -- splits a list of Results into Ok and Error lists
- `nil_error` -- converts `Result(a, e)` to `Result(a, Nil)`, frequently needed when composing results with different error types

More critically, the table does not mention `result.guard`, which exists in recent stdlib versions and mirrors `bool.guard` for Result-based early returns.

### Recommendation

Either make the table comprehensive or explicitly state it covers only the most common functions and link to the hexdocs for the complete API. The latter is more maintainable.

---

## 7. The "Bit arrays" section is out of place

### Quoted guideline (Section 9)

> Bit arrays provide low-level binary data manipulation with a rich pattern matching syntax.

### Problem

This is a general-purpose style guide for a project that does string formatting. Bit arrays are a niche feature primarily used for binary protocol parsing, network programming, and Erlang interop. Including them in a general style guide without context on when to use them (and when not to) wastes reader attention. The section has no guidance on style or best practices -- it is purely a syntax reference, which belongs in the language tour, not a style guide.

### Recommendation

Either remove the section entirely (it adds no style guidance) or reduce it to a single sentence noting that bit arrays exist for binary data work, with a link to the language tour for details.

---

## 8. Deprecation annotations section lacks practical guidance

### Quoted guideline

> Mark deprecated functions with `@deprecated` to generate compiler warnings.

### Problem

The section shows the syntax but provides no guidance on:
- When to deprecate vs. remove
- How to structure migration paths (what should the deprecation message contain?)
- Whether deprecated functions should remain in the public API or be moved to internal modules
- How deprecation interacts with semantic versioning

For a project with 29 language implementations and a stated versioning policy, deprecation guidance should be more substantive.

### Recommendation

Add practical guidance: deprecation messages should name the replacement function and the version in which the deprecated function will be removed. Link to the project's versioning policy.

---

## 9. The guide conflates "style guide" with "language tutorial"

### Problem (structural)

Approximately 60% of the document is Gleam language reference material (how types work, what pattern matching is, what the pipe operator does, the complete list of int vs float operators). This is valuable for onboarding, but it dilutes the actual style guidance -- the opinionated decisions about how this project writes Gleam code.

A developer who already knows Gleam has to wade through tutorial content to find the project-specific conventions. A developer who does not know Gleam would be better served by the official language tour (which is linked in Section 12).

### Recommendation

Separate the document into two concerns:
1. A concise style guide covering project-specific conventions, opinionated choices, and things that are not obvious from the language defaults
2. A "Gleam quick reference" appendix (or just a link to the language tour) for developers who need a syntax refresher

The style guide sections that add genuine value are: naming conventions, import organization, exhaustive matching preference, `let assert` restrictions, `use` patterns, data modeling principles, and the "Things to Avoid" section. These should be the core of the document.

---

## 10. Missing: guidance on the `gleam/option` module

### Problem

The guide mentions `Option(a)` exactly once (in the misleading "which is Result(a, Nil)" aside) and never discusses idiomatic usage of the `gleam/option` module. The actual project code uses `Result(x, Nil)` as its optional type (visible in `types.gleam` where `CompactnessOverride` fields are `Result(UnitForms, Nil)`), which is a valid Gleam pattern but deserves explicit discussion.

The guide should state whether the project prefers `Option` or `Result(_, Nil)` for optional values, and why. This is a genuine style decision that affects consistency across the codebase.

### Recommendation

Add a section on optional values that explains the project's convention. If the project uses `Result(_, Nil)` for optional fields (as the code suggests), state that explicitly and explain the rationale (likely: it composes better with `result.try` and `use` expressions without needing `option.to_result` conversions).

---

## 11. No mention of `gleam.toml` configuration

### Problem

The Tooling section covers CLI commands but never mentions `gleam.toml`, which is the project configuration file controlling the target platform, dependencies, and build settings. For a project that targets a specific platform (Erlang in this case), documenting the expected `gleam.toml` target is important.

### Recommendation

Add a brief note in the Tooling section about `gleam.toml` as the project configuration file, and document the expected target platform for this project.

---

## 12. The "No OOP patterns" section states the obvious for Gleam

### Quoted guideline

> Gleam has no classes, inheritance, interfaces, or method syntax. Functions are the only abstraction.

### Problem

This is a language constraint, not a style choice. It cannot be violated even if a developer wanted to. Including it in a style guide implies there is an alternative that should be avoided, but there is no alternative in Gleam. The section is only useful for developers coming from OOP languages who might be confused about how to structure code -- but in that case, the guidance should be "here is the idiomatic Gleam equivalent" rather than "do not do OOP."

The example showing module functions with pipe-friendly signatures is genuinely useful, but it should be framed as a positive pattern ("Design module APIs for piping") rather than a negative ("No OOP").

### Recommendation

Reframe as "Designing pipe-friendly APIs" -- emphasize that the subject type should be the first argument to enable piping. Drop the "no OOP" framing; Gleam developers cannot write OOP code regardless.

---

## 13. Labeled arguments section has a confusing example

### Quoted guideline

> ```gleam
> // Unclear: what do these strings mean?
> pub fn format(String, String, String) -> String
>
> // Clear: labels document the API
> pub fn format(
>   template template: String,
>   with value: String,
>   locale locale: String,
> ) -> String
> ```

### Problem

The "clear" example uses the double-name pattern (`template template:`, `locale locale:`) which is the degenerate case where the label and internal name are the same. The guide should use the label shorthand syntax here (`template:` instead of `template template:`) since it was introduced in Gleam 1.4+ and is mentioned later in the same section. Showing the verbose form first and the shorthand later creates confusion about which to prefer.

The label `with value:` is good -- it shows the power of having different external/internal names. But `template template:` adds noise.

### Recommendation

Use the shorthand for same-name labels and reserve the long form for different external/internal names. Lead with the `replace(in:, each:, with:)` example from the stdlib, which is the canonical example of good label design.

---

## Summary

The guide is thorough as a language reference but needs work as a style guide. The main issues are:

1. **Factual errors**: The `Option`/`Result` conflation and the unqualified TCO claim
2. **Structural**: Too much tutorial content diluting actual style decisions
3. **Gaps**: No guidance on `Option` vs `Result(_, Nil)`, no `gleam.toml` mention, incomplete `bool.guard` treatment
4. **Framing**: Several sections frame language constraints as style choices, which adds noise

The foundation is solid. The sections on exhaustive matching, data modeling, `use` expressions, and "Things to Avoid" are genuinely valuable. They just need to be extracted from the tutorial material and sharpened.
